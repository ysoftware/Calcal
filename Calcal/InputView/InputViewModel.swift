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
    
    func onArrowDownPress() {
        DispatchQueue.main.async { [self] in
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
    }
    
    func onArrowUpPress() {
        DispatchQueue.main.async { [self] in
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
    }
    
    func setupInitialState() {
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
        objectWillChange.send()
    }
}
