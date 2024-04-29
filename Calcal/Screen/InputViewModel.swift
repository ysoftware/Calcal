//
//  InputViewModel.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation
import Algorithms
import SwiftUI

class InputViewModel: ObservableObject {
    
    private let model: Model
    private let shouldInputSectionName: Bool
    private let completeInput: (EntryEntity.Item?, String?) -> Void
    
    // saved input values
    // todo: prefill also quantity input based on selected autocomplete item
    private var selectedItemCaloricInformation: CaloricInformation?
    private var name: String?
    private var quantity: Float?
    private var quantityMeasurement: EntryEntity.QuantityMeasurement?
    private var calories: Float?
    private var sectionName: String?
    
    // ui values
    private(set) var inputPlaceholder: String = ""
    private(set) var state: InputViewState = .name
    private(set) var selectedAutocompleteIndex: Int?
    private(set) var autocompleteSuggestions: [AutocompleteItemPresenter] = []
    private(set) var popularEntries: [QuickItemPresenter] = []
    private(set) var text: String = ""
    
    init(
        model: Model,
        shouldInputSectionName: Bool,
        completeInput: @escaping (EntryEntity.Item?, String?) -> Void
    ) {
        self.model = model
        self.shouldInputSectionName = shouldInputSectionName
        self.completeInput = completeInput
    }
    
    func onTextChange(newText: String) {
        self.text = newText
        self.selectedAutocompleteIndex = nil
        updatePresenter()
    }
    
    private func resetAllInput() {
        if shouldInputSectionName {
            state = .sectionName
            inputPlaceholder = "New meal name"
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
    
    func setupInitialState() {
        text = ""
        
        resetAllInput()
    
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
                    // todo: reuse presentation from main view
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

    private func updatePresenter() {
        DispatchQueue.main.async { [self] in
            refreshAutocompleteItems()
            objectWillChange.send()
        }
    }
    
    private func refreshAutocompleteItems() {
        guard state == .name else { return }
        
        let allEntries = model.getAllEntries()
        
        // todo: cache this unfiltered list long term
        self.autocompleteSuggestions = Array(allEntries
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
    
    func onEscapePress() {
        if selectedAutocompleteIndex != nil {
            selectedAutocompleteIndex = nil
        } else {
            completeInput(nil, nil)
        }
        updatePresenter()
    }
    
    func onArrowDownPress() {
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
    
    func onArrowUpPress() {
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
    
    func onEnterPress() {
        if let selectedAutocompleteIndex { // select autocompletion item
            assert(selectedAutocompleteIndex >= 0)
            assert(autocompleteSuggestions.count > selectedAutocompleteIndex)
            
            autocompleteSuggestions[selectedAutocompleteIndex].onAcceptItem()
        } else {
            processInputState() // just press enter with the input
        }
    }
    
    private func processInputState() {
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
                // error
                print("Error: incorrect name: '\(text)'")
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
                // error
                print("Error: incorrect quantity: '\(text)'")
            }
        case .calories:
            // todo: feature - specify calories per weight or per measurement
            if let calorieValue = text.floatValue {
                self.calories = calorieValue
                self.text = ""
                createItem()
            } else {
                // error
                print("Error: incorrect calories: '\(text)'")
            }
        }
        
        updatePresenter()
    }
    
    private func createItem() {
        guard let name,
              let quantity,
              let quantityMeasurement
        else { return } // todo: show validation error
        
        let caloriesValue: Float
        
        if let selectedItemCaloricInformation {
            caloriesValue = (selectedItemCaloricInformation.value * quantity).rounded()
        } else if let calories {
            caloriesValue = calories
        } else {
            // todo: show validation error
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
}
