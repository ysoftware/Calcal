//
//  InputViewModel.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation
import SwiftUI

class InputViewModel: ObservableObject {
    
    let mockData = [
        ("Sosis", "70g"),
        ("More sosis", "50g"),
        ("Kashkavalcheese", "20g"),
        ("Banica", "70g"),
        ("Cappuccino", "1 cup"),
    ]

    private var onProvideInput: ((EntryEntity.Item) -> Void)?
        
    private var name: String?
    private var quantity: Float?
    private var quantityMeasurement: EntryEntity.QuantityMeasurement?
    private var calories: Float?
    
    private(set) var state: InputViewState = .name
    private(set) var selectedAutocompleteIndex: Int?
    private(set) var autocompleteSuggestions: [AutocompleteItemPresenter] = []
    private(set) var popularEntries: [QuickItemPresenter] = []
    private(set) var text: String = ""
    
    
    func onTextChange(newText: String) {
        self.text = newText
        self.selectedAutocompleteIndex = nil
        self.refreshAutocompleteItems()
        updateView()
    }
    
    func setupExternalActions(onProvideInput: @escaping (EntryEntity.Item) -> Void) {
        self.onProvideInput = onProvideInput
    }
    
    func setupInitialState() {
        self.state = .name
        self.text = ""
        self.selectedAutocompleteIndex = nil
        self.refreshAutocompleteItems()
        
        self.popularEntries = mockData
            .map { value in
                QuickItemPresenter(
                    title: "\(value.0), \(value.1)",
                    onAcceptItem: { }
                )
            }
        
        updateView()
    }
    
    private func refreshAutocompleteItems() {
        // todo: make items dynamic
        // todo: carefully update selection on list change
        
        self.autocompleteSuggestions = mockData.enumerated()
            .map { index, value in
                AutocompleteItemPresenter(
                    title: value.0,
                    isSelected: index == self.selectedAutocompleteIndex,
                    onAcceptItem: { }
                )
            }
            .filter {
                $0.title.lowercased().contains(text.lowercased())
            }
    }
    
    private func updateView() {
        DispatchQueue.main.async { [self] in
            objectWillChange.send()
        }
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
        refreshAutocompleteItems()
        updateView()
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
        refreshAutocompleteItems()
        updateView()
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
            if let (quantityValue, measurement) = getQuantity(text: text) {
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
        
        updateView()
    }
    
    private func createItem() {
        guard let name,
              let quantity,
              let quantityMeasurement,
              let calories,
              let onProvideInput
        else { return }
        let item = EntryEntity.Item(
            title: name,
            quantity: quantity,
            measurement: quantityMeasurement,
            calories: calories
        )
        onProvideInput(item) // dismisses window
    }
    
    private var hasCaloricInformation: Bool {
        false // todo: implement
    }
    
    private func getQuantity(text: String) -> (Float, EntryEntity.QuantityMeasurement)? {
        if let quantityValue = text.floatValue {
            return (quantityValue, .piece)
        }
        
        for measurement in EntryEntity.QuantityMeasurement.allCases {
            let acceptableValues = switch measurement {
            case .liter: ["l", "liter", "litre", "ml", "millilitre", "milliliter"]
            case .kilogramm: ["kg", "kilogram", "g", "gr", "gram"]
            case .cup: ["cup"]
            case .piece: ["piece", "part"]
            }
            
            for value in acceptableValues {
                guard text.hasSuffix(value) else { continue }
                let textWithoutSuffix = String(text.dropLast(value.count)).trimmingCharacters(in: .whitespaces)
                guard let quantityValue = textWithoutSuffix.floatValue else { return nil }
                return (quantityValue, measurement)
            }
        }
        return nil
    }
}
