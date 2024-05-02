//
//  Mapper.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 29.04.24.
//

import Foundation

struct Mapper {
    
    static func measurementDisplayValue(
        quantity: Float,
        measurement: EntryEntity.QuantityMeasurement
    ) -> String {
        let baseQuantity = quantity
            .formatted
            .replacingOccurrences(of: ",", with: ".")
        
        let multipliedQuantity = (quantity*1000)
            .formatted
            .replacingOccurrences(of: ",", with: ".")
        
        switch measurement {
        case .portion:
            if quantity == 1 {
                return "1"
            }
            return "\(baseQuantity)"
        case .cup:
            if quantity == 1 {
                return "1 cup"
            }
            return "\(baseQuantity) cups"
        case .liter:
            if quantity > 0.5 {
                return "\(baseQuantity) l"
            }
            return "\(multipliedQuantity) ml"
        case .kilogram:
            if quantity > 0.5 {
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
                        quantity: Self.measurementDisplayValue(
                            quantity: item.quantity,
                            measurement: item.measurement
                        ),
                        deleteButton: ButtonPresenter(
                            title: "delete",
                            action: {
                                onDeleteItem(section.id, index)
                            }
                        )
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
    
    static func map(entity: EntryEntity) -> String {
        var entryText = ""
        var totalCalories: Float = 0
        
        for section in entity.sections {
            var itemsText = ""
            var sectionCalories: Float = 0
            
            for item in section.items {
                let quantityValue = Self.measurementDisplayValue(
                    quantity: item.quantity,
                    measurement: item.measurement
                )
                itemsText.append("- \(item.title), \(quantityValue), \(item.calories.formatted) kcal\n")
                sectionCalories += item.calories
            }
            
            entryText.append("\(section.id) - \(sectionCalories.formatted)) kcal\n\(itemsText)\n")
            totalCalories += sectionCalories
        }
        
        return """
        Date: \(entity.date)
        
        \(entryText.trimmingCharacters(in: .whitespacesAndNewlines))
        
        Total: \(totalCalories.formatted) kcal
        """
    }
}

extension Float {
    var formatted: String {
        self.formatted(.number.rounded().grouping(.never))
    }
}
