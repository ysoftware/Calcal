//
//  MainViewModel.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI

class MainViewModel: ObservableObject {
    
    private let inputViewModel: InputViewModel
    private var openWindow: ((String) -> Void)?
    private var dismissWindow: ((String) -> Void)?
    
    private var selectedEntryIndex: Int = 0
    private var entries: [EntryEntity] = []
    
    private(set) var nextButton: ButtonPresenter?
    private(set) var previousButton: ButtonPresenter?
    
    private(set) var entryPresenter: EntryPresenter?
    private(set) var openInputButton: ButtonPresenter?
    
    init(inputViewModel: InputViewModel) {
        self.inputViewModel = inputViewModel
    }
    
    func setupExternalActions(
        openWindow: @escaping (String) -> Void,
        dismissWindow: @escaping (String) -> Void
    ) {
        self.openWindow = openWindow
        self.dismissWindow = dismissWindow
    }
    
    func setupInitialState() {
        self.entries = mockEntries
        self.selectedEntryIndex = max(0, entries.count - 1)
        
        updateSelectedEntry()
        
        openInputButton = ButtonPresenter(
            title: "Add",
            action: { [weak self] in
                self?.openInput()
            }
        )
        
        updateView()
    }
    
    private func updateSelectedEntry() {
        guard entries.count > selectedEntryIndex else { return }
        let selectedEntry = entries[selectedEntryIndex]
        
        // todo: update for better ui
        var entryText = ""
        var totalCalories: Float = 0
        
        for section in selectedEntry.sections {
            var itemsText = ""
            var sectionCalories: Float = 0
            
            for item in section.items {
                itemsText.append("- \(item.title), \(measurementDisplayValue(item: item)), \(item.calories.formatted(.number.rounded())) kcal\n")
                sectionCalories += item.calories
            }
            
            entryText.append("\(section.title) - \(sectionCalories.formatted(.number.rounded())) kcal\n\(itemsText)\n")
            totalCalories += sectionCalories
        }
        
        self.entryPresenter = EntryPresenter(
            date: selectedEntry.date.uppercased(),
            text: entryText.trimmingCharacters(in: .whitespacesAndNewlines),
            total: "Total: \(totalCalories.formatted(.number.rounded().grouping(.never))) kcal"
        )
    }
    
    private func measurementDisplayValue(item: EntryEntity.Item) -> String {
        switch item.measurement {
        case .piece:
            if item.quantity == 1 {
                return "1"
            }
            return "\(item.quantity.formatted(.number.rounded()))"
        case .cup:
            if item.quantity == 1 {
                return "1 cup"
            }
            return "\(item.quantity.formatted(.number.rounded()))) cups"
        case .liter:
            if item.quantity > 0.5 {
                return "\(item.quantity.formatted(.number.rounded()))l"
            }
            return "\((item.quantity*100).formatted(.number.rounded())))ml"
        case .kilogramm:
            if item.quantity > 0.5 {
                return "\(item.quantity.formatted(.number.rounded()))kg"
            }
            return "\((item.quantity*1000).formatted(.number.rounded()))g"
        case .tablespoon:
            return "\(item.quantity.formatted(.number.rounded())) tbsp"
        }
    }
    
    private func openInput() {
        openWindow?(WindowId.input)
        inputViewModel.setupExternalActions(onProvideInput: { [weak self] item in
            // todo: accept item
        })
        inputViewModel.setupInitialState()
    }
    
    private func updateView() {
        objectWillChange.send()
    }
}


let mockEntries = [
    EntryEntity(
        date: "12 April 2024",
        sections: [
            EntryEntity.Section(
                title: "Breakfast",
                items: [
                    EntryEntity.Item(
                        title: "Cappuccino",
                        quantity: 1,
                        measurement: .cup,
                        calories: 45
                    )
                ]
            ),
            EntryEntity.Section(
                title: "Lunch",
                items: [
                    EntryEntity.Item(
                        title: "Fried egg",
                        quantity: 2,
                        measurement: .piece,
                        calories: 180
                    ),
                    EntryEntity.Item(
                        title: "Sucuk",
                        quantity: 0.010,
                        measurement: .kilogramm,
                        calories: 30
                    ),
                    EntryEntity.Item(
                        title: "Cheese",
                        quantity: 0.030,
                        measurement: .kilogramm,
                        calories: 120
                    ),
                    EntryEntity.Item(
                        title: "Jam",
                        quantity: 0.020,
                        measurement: .kilogramm,
                        calories: 56
                    ),
                    EntryEntity.Item(
                        title: "Bread",
                        quantity: 0.045,
                        measurement: .kilogramm,
                        calories: 119
                    )
                ]
            ),
            EntryEntity.Section(
                title: "Snacky",
                items: [
                    EntryEntity.Item(
                        title: "Cappuccino",
                        quantity: 1,
                        measurement: .cup,
                        calories: 45
                    ),
                    EntryEntity.Item(
                        title: "Cheese",
                        quantity: 0.020,
                        measurement: .kilogramm,
                        calories: 80
                    ),
                    EntryEntity.Item(
                        title: "Jam",
                        quantity: 0.020,
                        measurement: .kilogramm,
                        calories: 56
                    ),
                    EntryEntity.Item(
                        title: "Bread",
                        quantity: 0.045,
                        measurement: .kilogramm,
                        calories: 119
                    )
                ]
            ),
            EntryEntity.Section(
                title: "Dinner",
                items: [
                    EntryEntity.Item(
                        title: "Salami cheese baguette",
                        quantity: 1,
                        measurement: .piece,
                        calories: 300
                    ),
                    EntryEntity.Item(
                        title: "m&m's",
                        quantity: 0.045,
                        measurement: .kilogramm,
                        calories: 236
                    ),
                    EntryEntity.Item(
                        title: "Snickers",
                        quantity: 0.050,
                        measurement: .kilogramm,
                        calories: 244
                    )
                ]
            )
        ]
    )
]
