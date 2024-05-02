//
//  Mapper.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 29.04.24.
//

import Foundation

struct Mapper {
    
    static func measurementDisplayValue(item: EntryEntity.Item) -> String {
        let baseQuantity = item.quantity
            .formatted(.number.rounded())
            .replacingOccurrences(of: ",", with: ".")
        
        let multipliedQuantity = (item.quantity*1000)
            .formatted(.number.rounded())
            .replacingOccurrences(of: ",", with: ".")
        
        switch item.measurement {
        case .portion:
            if item.quantity == 1 {
                return "1"
            }
            return "\(baseQuantity)"
        case .cup:
            if item.quantity == 1 {
                return "1 cup"
            }
            return "\(baseQuantity) cups"
        case .liter:
            if item.quantity > 0.5 {
                return "\(baseQuantity) l"
            }
            return "\(multipliedQuantity) ml"
        case .kilogram:
            if item.quantity > 0.5 {
                return "\(baseQuantity) kg"
            }
            return "\(multipliedQuantity) g"
        }
    }
    
    static func map(
        entity: EntryEntity,
        onDeleteItem: @escaping (_ sectionId: String, _ index: Int) -> Void
    ) -> EntryPresenter {
        var totalCalories: Float = 0
        var sections: [EntryPresenter.Section] = []

        for section in entity.sections {
            var items: [EntryPresenter.Item] = []
            var sectionCalories: Float = 0
            
            for (index, item) in section.items.enumerated() {
                items.append(
                    EntryPresenter.Item(
                        title: item.title,
                        calories: item.calories.formatted,
                        quantity: Self.measurementDisplayValue(item: item),
                        onDelete: {
                            onDeleteItem(section.id, index)
                        }
                    )
                )
                sectionCalories += item.calories
            }
            
            totalCalories += sectionCalories
            sections.append(
                EntryPresenter.Section(
                    name: section.id,
                    calories: sectionCalories.formatted,
                    items: items
                )
            )
        }
        
        return EntryPresenter(
            date: entity.date.uppercased(),
            total: totalCalories.formatted,
            sections: sections
        )
    }
    
    static func map(entity: EntryEntity) -> EntryRepresentation {
        var entryText = ""
        var totalCalories: Float = 0
        
        for section in entity.sections {
            var itemsText = ""
            var sectionCalories: Float = 0
            
            for item in section.items {
                itemsText.append("- \(item.title), \(Self.measurementDisplayValue(item: item)), \(item.calories.formatted(.number.rounded())) kcal\n")
                sectionCalories += item.calories
            }
            
            entryText.append("\(section.id) - \(sectionCalories.formatted(.number.rounded())) kcal\n\(itemsText)\n")
            totalCalories += sectionCalories
        }
        
        return EntryRepresentation(
            date: "Date: \(entity.date)",
            text: entryText.trimmingCharacters(in: .whitespacesAndNewlines),
            total: "Total: \(totalCalories.formatted(.number.rounded().grouping(.never))) kcal"
        )
    }
    
    static func map(representation: EntryRepresentation) -> String {
"""
\(representation.date)

\(representation.text)

\(representation.total)
"""
    }
}

extension Float {
    var formatted: String {
        self.formatted(.number.rounded().grouping(.never))
    }
}
