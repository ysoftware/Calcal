//
//  Model.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 16.04.24.
//

import Foundation

class Model {
    func appendItemToLastEntry(item: EntryEntity.Item, sectionId: EntryEntity.SectionId) {
        guard var entry = getAllEntries().last else { return }
        
        if entry.sections.firstIndex(where: { $0.id == sectionId }) == nil {
            entry.sections.append(EntryEntity.Section(id: sectionId, items: []))
        }
        
        guard let sectionIndex = entry.sections.firstIndex(where: { $0.id == sectionId })
        else { return assertionFailure("the section must have been added") }
        
        entry.sections[sectionIndex].items.append(item)
        addOrUpdateEntry(entry: entry)
    }
    
    func addOrUpdateEntry(entry: EntryEntity) {
        guard let entryIndex = mockEntries.firstIndex(where: { $0.date == entry.date }) else { return }
        mockEntries[entryIndex] = entry
    }
    
    func getAllEntries() -> [EntryEntity] {
        mockEntries
    }
}

var mockEntries = [
    EntryEntity(
        date: "12 April 2024",
        sections: [
            EntryEntity.Section(
                id: .breakfast,
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
                id: .lunch,
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
                id: .snack,
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
                id: .dinner,
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
