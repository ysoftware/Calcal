//
//  Mapper.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 29.04.24.
//

import SwiftUI

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
                        calories: item.calories.calorieValue,
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
                    calories: sectionCalories.calorieValue,
                    items: items
                )
            )
        }
        
        return EntryPresenter(
            date: entity.date.uppercased(),
            total: totalCalories.calorieValue,
            sections: sections
        )
    }
    
    static func map(entity: EntryEntity) -> String? {
        var entryText = ""
        var totalCalories: Float = 0
        var didAddSections = false
        
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
            
            if !section.items.isEmpty {
                entryText.append("\(section.id) - \(sectionCalories.formatted) kcal\n\(itemsText)\n")
                totalCalories += sectionCalories
                didAddSections = true
            }
        }
        
        guard didAddSections else { return nil }
        
        return """
        Date: \(entity.date)
        
        \(entryText.trimmingCharacters(in: .whitespacesAndNewlines))
        
        Total: \(totalCalories.calorieValue)
        """
    }
    
    static func mapCalendar(
        entries: [EntryEntity],
        dismissButton: ButtonPresenter
    ) -> CalendarPresenter {
        let calendar = Calendar(identifier: .gregorian)
        
        var rows: [[CalendarPresenter.Column]] = []
        
        var i = 0
        while i < entries.count {
            var row: [CalendarPresenter.Column] = []
            for w in 1...7 {
                
                guard entries.count > i, let date = dateFormatter.date(from: entries[i].date) else {
                    i += 1
                    row.append(CalendarPresenter.Column(color: .clear, text: ""))
                    continue
                }
                
                let calories = entries[i].sections.map { $0.items.map { $0.calories }.reduce(0, +) }.reduce(0, +)
                
                // weekday adjusted to start on monday
                var weekday: Int = calendar.component(.weekday, from: date)
                if weekday == 1 {
                    weekday = 7
                } else {
                    weekday -= 1
                }
                
                if weekday == w {
                    row.append(CalendarPresenter.Column(color: color(calories: calories), text: "\(Int(calories))"))
                    i += 1
                    continue
                } else {
                    row.append(CalendarPresenter.Column(color: .clear, text: ""))
                }
            }
            rows.append(row)
        }

        return CalendarPresenter(rows: rows, dismissButton: dismissButton)
    }
    
    static func color(calories: Float) -> SwiftUI.Color {
        if calories <= 1400 {
            Color.entryIncomplete
        } else if calories <= 1900 {
            Color.entryBest
        } else if calories <= 2200 {
            Color.entryGood
        } else if calories <= 2400 {
            Color.entryNormal
        } else if calories <= 2900 {
            Color.entryBad
        } else {
            Color.entryHorrible
        }
    }
}

extension Float {
    var calorieValue: String {
        "\(self.formatted) kcal"
    }
    
    var formatted: String {
        self.formatted(.number.rounded().grouping(.never))
    }
}
