//
//  InputViewModel.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation
import SwiftUI

class InputViewModel: ObservableObject {
    
    private let model: Model
    private var completeInput: ((EntryEntity.Item?) -> Void)?
    
    private var name: String?
    private var quantity: Float?
    private var quantityMeasurement: EntryEntity.QuantityMeasurement?
    private var calories: Float?
    
    private(set) var state: InputViewState = .name
    private(set) var selectedAutocompleteIndex: Int?
    private(set) var autocompleteSuggestions: [AutocompleteItemPresenter] = []
    private(set) var popularEntries: [QuickItemPresenter] = []
    private(set) var text: String = ""
    
    init(model: Model) {
        self.model = model
    }
    
    func onTextChange(newText: String) {
        self.text = newText
        self.selectedAutocompleteIndex = nil
        updatePresenter()
    }
    
    func setupInitialState() {
        
    }
    
    func setup(completeInput: @escaping (EntryEntity.Item?) -> Void) {
        self.completeInput = completeInput
    
        self.state = .name
        self.text = ""
        self.selectedAutocompleteIndex = nil
        
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
                .prefix(10)
                .map { item in
                    // todo: reuse presentation from main view
                    QuickItemPresenter(
                        title: "\(item.title), \(item.quantity) \(item.measurement), \(item.calories) kcal (x\(item.occurencesCount))",
                        onAcceptItem: { [weak self] in
                            let entryItem = EntryEntity.Item(
                                title: item.title,
                                quantity: item.quantity,
                                measurement: item.measurement,
                                calories: item.calories
                            )
                            self?.completeInput?(entryItem)
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
        // todo: carefully update selection on list change
        
        let allEntries = model.getAllEntries()
        
        // todo: cache this unfiltered list
        self.autocompleteSuggestions = allEntries
            .flatMap { $0.sections }
            .flatMap { $0.items }
            .enumerated()
            .map { index, item in
                AutocompleteItemPresenter(
                    title: item.title,
                    isSelected: index == self.selectedAutocompleteIndex,
                    onAcceptItem: { 
                        // todo: implement
                    }
                )
            }
            .filter {
                $0.title.lowercased().contains(text.lowercased())
            }
    }
    
    func onEscapePress() {
        completeInput?(nil)
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
        switch state {
        case .name:
            if text.count > 1 {
                self.name = text
                self.text = ""
                state = .quantity
            } else {
                // error
                print("Error: incorrect name: '\(text)'")
            }
        case .quantity:
            if let (quantityValue, measurement) = Parser.getQuantity(text: text) {
                self.text = ""
                self.quantity = quantityValue
                self.quantityMeasurement = measurement
                
                if hasCaloricInformation {
                    createItem()
                } else {
                    state = .calories
                }
            } else {
                // error
                print("Error: incorrect quantity: '\(text)'")
            }
        case .calories:
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
              let quantityMeasurement,
              let calories,
              let completeInput
        else { return }
        let item = EntryEntity.Item(
            title: name,
            quantity: quantity,
            measurement: quantityMeasurement,
            calories: calories
        )
        completeInput(item) // dismisses window
    }
    
    private var hasCaloricInformation: Bool {
        false // todo: implement
    }
    
    struct PopularItem {
        let title: String
        let occurencesCount: Int
        let quantity: Float
        let measurement: EntryEntity.QuantityMeasurement
        let calories: Float
    }
}
