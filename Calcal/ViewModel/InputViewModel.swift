//
//  InputViewModel.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation
import Algorithms
import OSLog
import SwiftUI

final class InputViewModel: ObservableObject, @unchecked Sendable {
    
    private let model: Model
    private let shouldInputSectionName: Bool
    private let completeInput: (EntryEntity.Item?, String?) -> Void
    
    // saved input values
    private var selectedItemCaloricInformation: CaloricInformation?
    private var name: String?
    private var quantity: Float?
    private var quantityMeasurement: EntryEntity.QuantityMeasurement?
    private var calories: Float?
    private var sectionName: String?
    
    // ui values
    @MainActor private(set) var closeButton: ButtonPresenter?
    @MainActor private(set) var inputPlaceholder: String = ""
    @MainActor private(set) var state: State = .name
    @MainActor private(set) var selectedAutocompleteIndex: Int?
    @MainActor private(set) var autocompleteSuggestions: [AutocompleteItemPresenter] = []
    @MainActor private(set) var popularEntries: [QuickItemPresenter] = []
    @MainActor private(set) var text: String = ""
    
    init(
        model: Model,
        shouldInputSectionName: Bool,
        completeInput: @escaping @Sendable (EntryEntity.Item?, String?) -> Void
    ) {
        self.model = model
        self.shouldInputSectionName = shouldInputSectionName
        self.completeInput = completeInput
    }
    
    @MainActor func onTextChange(newText: String) {
        self.text = newText
        self.selectedAutocompleteIndex = nil
        updatePresenter()
    }
    
    @MainActor private func resetAllInput() {
        if shouldInputSectionName {
            state = .sectionName
            inputPlaceholder = "Meal name"
        } else {
            state = .name
            inputPlaceholder = "Item name"
        }
        
        sectionName = nil
        name = nil
        quantity = nil
        quantityMeasurement = nil
        calories = nil
    }
    
    @MainActor func setupInitialState() {
        text = ""
        
        resetAllInput()
        
        closeButton = ButtonPresenter(
            title: "Cancel",
            action: { [weak self] in
                self?.completeInput(nil, nil)
            }
        )
        
        let allItems = model.getAllEntries()
            .flatMap { $0.sections }
            .flatMap { $0.items }
        
        var items: [PopularItem] = []
        
        for item in allItems {
            if let foundItemIndex = items.firstIndex(where: {
                $0.title == item.title && $0.quantity == item.quantity && $0.measurement == item.measurement
            }) {
                items[foundItemIndex] = PopularItem(
                    title: item.title,
                    occurencesCount: items[foundItemIndex].occurencesCount + 1,
                    quantity: item.quantity,
                    measurement: item.measurement,
                    calories: item.calories
                )
            } else {
                items.append(
                    PopularItem(
                        title: item.title,
                        occurencesCount: 1,
                        quantity: item.quantity,
                        measurement: item.measurement,
                        calories: item.calories
                    )
                )
            }
        }
        
        self.popularEntries = Array(
            items
                .sorted { $0.occurencesCount > $1.occurencesCount }
                .prefix(14)
                .map { item in
                    // todo: improvement: use mapper
                    QuickItemPresenter(
                        title: "\(item.title), \(item.quantity) \(item.measurement), \(item.calories) kcal (x\(item.occurencesCount))",
                        onAcceptItem: { [weak self] in
                            guard let self else { return }
                            
                            let entryItem = EntryEntity.Item(
                                title: item.title,
                                quantity: item.quantity,
                                measurement: item.measurement,
                                calories: item.calories
                            )
                            self.completeInput(entryItem, self.sectionName)
                        }
                    )
                }
        )
        
        updatePresenter()
    }
    
    @MainActor private func updatePresenter() {
        self.refreshAutocompleteItems()
        self.objectWillChange.send()
    }
    
    @MainActor private func refreshAutocompleteItems() {
        switch state {
        case .name:
            setAutocompleteForNameInput()
        case .sectionName:
            setAutocompleteForSectionNameInput()
        case .quantity:
            setAutocompleteForQuantityInput()
        case .calories:
            // todo: feature: maybe list of top-calorie foods?
            autocompleteSuggestions = []
        }
    }
    
    @MainActor private func setAutocompleteForQuantityInput() {
        guard let name else {
            self.autocompleteSuggestions = []
            return
        }
        
        self.autocompleteSuggestions = Array(model.getAllEntries()
            .flatMap { $0.sections }
            .flatMap { $0.items }
            .filter { $0.title == name }
            .enumerated()
            .map { index, item in
                AutocompleteItemPresenter(
                    title: "\(item.title), \(item.quantity) \(item.measurement): \(item.calories) kcal",
                    isSelected: index == self.selectedAutocompleteIndex,
                    onAcceptItem: { [weak self] in
                        guard let self else { return }
                        
                        self.text = "\(item.quantity) \(item.measurement)"
                        self.processInputState()
                        self.selectedAutocompleteIndex = nil
                    }
                )
            }
        )
    }
    
    @MainActor private func setAutocompleteForSectionNameInput() {
        self.autocompleteSuggestions = [
            "Breakfast", "Lunch", "Dinner", "Snack", "Snack 2"
        ]
            .enumerated()
            .map { index, item in
                AutocompleteItemPresenter(
                    title: "\(item)",
                    isSelected: index == self.selectedAutocompleteIndex,
                    onAcceptItem: { [weak self] in
                        guard let self else { return }
                        
                        self.text = item
                        self.processInputState()
                        self.selectedAutocompleteIndex = nil
                    }
                )
            }
    }
    
    @MainActor private func setAutocompleteForNameInput() {
        // todo: improvement: cache this unfiltered list long term
        self.autocompleteSuggestions = Array(model.getAllEntries()
            .flatMap { $0.sections }
            .flatMap { $0.items }
            .filter {
                $0.title.lowercased().contains(text.lowercased())
            }
            .uniqued(on: { "\($0.title) \($0.measurement)" })
            .prefix(10)
            .enumerated()
            .map { index, item in
                AutocompleteItemPresenter(
                    title: "\(item.title) (in \(item.measurement))",
                    isSelected: index == self.selectedAutocompleteIndex,
                    onAcceptItem: { [weak self] in
                        guard let self else { return }
                        
                        self.text = item.title
                        self.selectedItemCaloricInformation = CaloricInformation(
                            value: item.calories / item.quantity,
                            measurement: item.measurement
                        )
                        self.processInputState()
                        self.selectedAutocompleteIndex = nil
                    }
                )
            }
        )
    }
    
    @MainActor func onEscapePress() {
        if selectedAutocompleteIndex != nil {
            selectedAutocompleteIndex = nil
        } else {
            completeInput(nil, nil)
        }
        updatePresenter()
    }
    
    @MainActor func onArrowDownPress() {
        if autocompleteSuggestions.isEmpty {
            self.selectedAutocompleteIndex = nil
        } else if let selectedAutocompleteIndex,
                  selectedAutocompleteIndex < autocompleteSuggestions.count - 1 {
            self.selectedAutocompleteIndex = selectedAutocompleteIndex + 1
        } else {
            self.selectedAutocompleteIndex = 0
        }
        updatePresenter()
    }
    
    @MainActor func onArrowUpPress() {
        if autocompleteSuggestions.isEmpty {
            self.selectedAutocompleteIndex = nil
        } else if let selectedAutocompleteIndex,
                  selectedAutocompleteIndex > 0 {
            self.selectedAutocompleteIndex = selectedAutocompleteIndex - 1
        } else {
            self.selectedAutocompleteIndex = autocompleteSuggestions.count - 1
        }
        updatePresenter()
    }
    
    @MainActor func onEnterPress() {
        if let selectedAutocompleteIndex { // select autocompletion item
            assert(selectedAutocompleteIndex >= 0)
            assert(autocompleteSuggestions.count > selectedAutocompleteIndex)
            
            autocompleteSuggestions[selectedAutocompleteIndex].onAcceptItem()
        } else {
            processInputState() // just press enter with the input
        }
    }
    
    @MainActor private func processInputState() {
        switch state {
        case .sectionName:
            self.sectionName = text
            self.text = ""
            state = .name
        case .name:
            if text.count > 1 {
                self.name = text
                self.text = ""
                
                state = .quantity
                if let selectedItemCaloricInformation {
                    inputPlaceholder = "Quantity (\(selectedItemCaloricInformation.measurement))"
                } else {
                    inputPlaceholder = "Quantity"
                }
            } else {
                Logger.main.error("Input: incorrect name: '\(self.text)'")
            }
        case .quantity:
            if let (quantityValue, measurement) = Parser.getQuantity(text: text) {
                self.text = ""
                self.quantity = quantityValue
                self.quantityMeasurement = measurement
                
                if let selectedItemCaloricInformation {
                    if selectedItemCaloricInformation.measurement == measurement || measurement == .portion {
                        self.quantityMeasurement = selectedItemCaloricInformation.measurement
                        createItem()
                    } else {
                        self.selectedItemCaloricInformation = nil // reset invalid
                        state = .calories
                        inputPlaceholder = "Calories"
                    }
                } else {
                    state = .calories
                    inputPlaceholder = "Calories"
                }
            } else {
                Logger.main.error("Input: incorrect quantity: '\(self.text)'")
            }
        case .calories:
            if text.hasSuffix("/"), let quantity, let quantityMeasurement, let calorieValue = String(text.dropLast()).floatValue {
                switch quantityMeasurement {
                case .cup, .portion:
                    self.calories = calorieValue * quantity
                case .kilogram, .liter:
                    // input "40/":
                    // for quantity entered 100ml, `quantity` will be 0.1
                    // for calories entered 40kcal/100ml, result should be 40
                    // 40 * 0.1 * 10 = 40
                    self.calories = calorieValue * quantity * 10
                }
                self.text = ""
                createItem()
            } else if let calorieValue = text.floatValue {
                self.calories = calorieValue
                self.text = ""
                createItem()
            } else {
                Logger.main.error("Input: incorrect calories: '\(self.text)'")
            }
        }
        
        updatePresenter()
    }
    
    private func createItem() {
        guard let name,
              let quantity,
              let quantityMeasurement
        else { return }
        
        let caloriesValue: Float
        
        if let selectedItemCaloricInformation {
            caloriesValue = (selectedItemCaloricInformation.value * quantity).rounded()
        } else if let calories {
            caloriesValue = calories
        } else {
            return
        }
        
        let item = EntryEntity.Item(
            title: name,
            quantity: quantity,
            measurement: quantityMeasurement,
            calories: caloriesValue
        )
        completeInput(item, sectionName)
    }
    
    struct CaloricInformation {
        let value: Float
        let measurement: EntryEntity.QuantityMeasurement
    }
    
    struct PopularItem {
        let title: String
        let occurencesCount: Int
        let quantity: Float
        let measurement: EntryEntity.QuantityMeasurement
        let calories: Float
    }
    
    enum State {
        case sectionName
        case name
        case quantity
        case calories
    }
}
