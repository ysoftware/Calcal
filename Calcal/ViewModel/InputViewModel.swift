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

// todo: optimise calculations on first open

final class InputViewModel: ObservableObject, @unchecked Sendable {
    
    private let model: Model
    private let shouldInputSectionName: Bool
    private let completeInput: @Sendable (EntryEntity.Item?, String?) -> Void
    
    private var allItems: [EntryEntity.Item] = []
    
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
    @MainActor private(set) var popularEntries: [ButtonPresenter] = []
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
    
    @MainActor private func setupKeyDownEvents() {
#if canImport(AppKit)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
            guard let self else { return event }
            
            if event.keyCode == Keycode.arrowDown {
                onArrowDownPress()
                return nil
            }
            
            if event.keyCode == Keycode.arrowUp {
                onArrowUpPress()
                return nil
            }
            
            if event.keyCode == Keycode.return {
                onEnterPress()
                return nil
            }
            
            if event.keyCode == Keycode.escape {
                onEscapePress()
                return nil
            }
            
            return event
        })
#endif
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
        
        Task { @MainActor in
            setupKeyDownEvents()
        }
        
        allItems = model.getAllEntries()
            .flatMap { $0.sections }
            .flatMap { $0.items }
        
        resetAllInput()
        
        closeButton = ButtonPresenter(
            title: "Cancel",
            action: { [weak self] in
                self?.completeInput(nil, nil)
            }
        )
        
        updatePresenter()
        
        Task { @MainActor in
            self.popularEntries = await Mapper.calculatePopularEntries(
                allItems: allItems,
                completeInput: { [weak self] item in
                    guard let self else { return }
                    self.completeInput(item, self.sectionName)
                }
            )
            updatePresenter()
        }
    }
    
    @MainActor private func updatePresenter() {
        Task { @MainActor in
            await self.refreshAutocompleteItems()
            self.objectWillChange.send()
        }
    }
    
    @MainActor private func refreshAutocompleteItems() async {
        switch state {
        case .name:
            autocompleteSuggestions = await Mapper.calculateAutocompleteForNameInput(
                allItems: allItems,
                selectedAutocompleteIndex: selectedAutocompleteIndex,
                text: text,
                onAcceptItem: { @Sendable [weak self] text, caloricInformation in
                    guard let self else { return }
                    
                    Task { @MainActor in
                        self.text = text
                        self.selectedItemCaloricInformation = caloricInformation
                        self.processInputState()
                        self.selectedAutocompleteIndex = nil
                    }
                }
            )
        case .sectionName:
            autocompleteSuggestions = Mapper.calculateAutocompleteForSectionNameInput(
                selectedAutocompleteIndex: selectedAutocompleteIndex,
                onAcceptItem: { [weak self] text in
                    guard let self else { return }
                    
                    Task { @MainActor in
                        self.text = text
                        self.processInputState()
                        self.selectedAutocompleteIndex = nil
                    }
                }
            )
        case .quantity:
            autocompleteSuggestions = await Mapper.calculateAutocompleteForQuantityInput(
                allItems: allItems,
                selectedAutocompleteIndex: selectedAutocompleteIndex,
                name: name,
                onAcceptItem: { @Sendable [weak self] text in
                    guard let self else { return }
                    
                    Task { @MainActor in
                        self.text = text
                        self.processInputState()
                        self.selectedAutocompleteIndex = nil
                    }
                }
            )
        case .calories:
            // todo: feature: maybe list of top-calorie foods?
            autocompleteSuggestions = []
        }
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
            caloriesValue = (selectedItemCaloricInformation.value * quantity)
        } else if let calories {
            caloriesValue = calories
        } else {
            return
        }
        
        let item = EntryEntity.Item(
            title: name,
            quantity: quantity,
            measurement: quantityMeasurement,
            calories: caloriesValue.rounded()
        )
        completeInput(item, sectionName)
    }
    
    enum State {
        case sectionName
        case name
        case quantity
        case calories
    }
}
