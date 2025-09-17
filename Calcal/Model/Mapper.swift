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
            
            entryText.append("\(section.id) - \(sectionCalories.formatted) kcal\n\(itemsText)\n")
            totalCalories += sectionCalories
        }
        
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
        let empty = CalendarPresenter.Column(color: .clear, text: "")
        let calendar = Calendar(identifier: .gregorian)
        
        guard !entries.isEmpty,
              let firstDate = dateFormatter.date(from: entries[0].date)
        else {
            return CalendarPresenter(months: [], dismissButton: dismissButton)
        }
        
        var months: [CalendarPresenter.Month] = []
        var currentMonth = calendar.component(.month, from: firstDate)
        var rows: [[CalendarPresenter.Column]] = []
        
        var i = 0
        while i < entries.count {
            var columns: [CalendarPresenter.Column] = []
            for w in 1...7 {
                guard entries.count > i, let date = dateFormatter.date(from: entries[i].date) else {
                    i += 1
                    columns.append(empty)
                    continue
                }
                
                let month = calendar.component(.month, from: date)
                
                if currentMonth != month {
                    let addedColumns = columns.filter { $0.text != "" }
                    if !rows.isEmpty || !addedColumns.isEmpty {
                        if !addedColumns.isEmpty {
                            for _ in 0..<(7-columns.count) {
                                columns.append(empty)
                            }
                            rows.append(columns)
                            columns = []
                        }
                        
                        let averageCalories = rows
                            .flatMap { $0 }
                            .compactMap { Int($0.text) }
                            .filter { $0 > 1100 }
                            .average
                        
                        months.append(
                            CalendarPresenter.Month(
                                title: Self.month(number: currentMonth),
                                subtitle: "∅ \(averageCalories)",
                                rows: rows
                            )
                        )
                        rows = []
                    }
                    currentMonth = month
                    continue
                }
                
                let calories = entries[i].sections
                    .map { $0.items.map { $0.calories }.reduce(0, +) }
                    .reduce(0, +)
                
                // weekday adjusted to start on monday
                var weekday: Int = calendar.component(.weekday, from: date)
                if weekday == 1 {
                    weekday = 7
                } else {
                    weekday -= 1
                }
                
                if weekday == w {
                    columns.append(CalendarPresenter.Column(color: color(calories: calories), text: "\(Int(calories))"))
                    i += 1
                    continue
                } else {
                    columns.append(empty)
                }
            }
            
            let addedColumns = columns.filter { $0.text != "" }
            if !addedColumns.isEmpty {
                rows.append(columns)
                columns = []
            }
        }
        
        if !rows.isEmpty {
            let averageCalories = rows
                .flatMap { $0 }
                .compactMap { Int($0.text) }
                .filter { $0 > 1100 }
                .average
            
            months.append(
                CalendarPresenter.Month(
                    title: Self.month(number: currentMonth),
                    subtitle: "∅ \(averageCalories)",
                    rows: rows
                )
            )
        }

        return CalendarPresenter(months: months, dismissButton: dismissButton)
    }
    
    static func month(number: Int) -> String {
        switch number {
        case 1: return "January"
        case 2: return "February"
        case 3: return "March"
        case 4: return "April"
        case 5: return "May"
        case 6: return "June"
        case 7: return "July"
        case 8: return "August"
        case 9: return "September"
        case 10: return "October"
        case 11: return "November"
        case 12: return "December"
        default: return ""
        }
    }
    
    static func color(calories: Float) -> SwiftUI.Color {
        if calories <= 1100 {
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
    
    // MARK: - Input View Model
    
    static func calculatePopularEntries(
        allItems: [EntryEntity.Item],
        completeInput: @escaping @Sendable (EntryEntity.Item?) -> Void
    ) async -> [ButtonPresenter] {
        await Task.detached(priority: .userInitiated) {
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
            
            return Array(
                items
                    .sorted { $0.occurencesCount > $1.occurencesCount }
                    .prefix(14)
                    .map { item in
                        let quantityDisplayValue = Mapper.measurementDisplayValue(
                            quantity: item.quantity,
                            measurement: item.measurement
                        )
                        
                        return ButtonPresenter(
                            title: "\(item.title), \(quantityDisplayValue), \(item.calories.formatted) kcal (x\(item.occurencesCount))",
                            action: {
                                let entryItem = EntryEntity.Item(
                                    title: item.title,
                                    quantity: item.quantity,
                                    measurement: item.measurement,
                                    calories: item.calories
                                )
                                completeInput(entryItem)
                            }
                        )
                    }
            )
        }.value
    }
    
    static func calculateAutocompleteForSectionNameInput(
        selectedAutocompleteIndex: Int?,
        onAcceptItem: @escaping (String) -> Void
    ) -> [AutocompleteItemPresenter] {
        ["Breakfast", "Lunch", "Dinner", "Snack", "Snack 2"]
            .enumerated()
            .map { index, item in
                AutocompleteItemPresenter(
                    title: "\(item)",
                    isSelected: index == selectedAutocompleteIndex,
                    onAcceptItem: { onAcceptItem(item) }
                )
            }
    }
    
    static func calculateAutocompleteForQuantityInput(
        allItems: [EntryEntity.Item],
        selectedAutocompleteIndex: Int?,
        name: String?,
        onAcceptItem: @escaping @Sendable (String, CaloricInformation) -> Void
    ) async -> [AutocompleteItemPresenter] {
        guard let name else { return [] }
        
        return await Task.detached(priority: .userInitiated) {
            Array(allItems
                .filter { $0.title.lowercased() == name.lowercased() }
                .uniqued(on: { $0.quantity })
                .sorted(by: { $0.quantity < $1.quantity })
                .enumerated()
                .map { index, item in
                    let quantityValue = Mapper.measurementDisplayValue(
                        quantity: item.quantity,
                        measurement: item.measurement
                    )
                    return AutocompleteItemPresenter(
                        title: "\(item.title), \(quantityValue) → \(item.calories.formatted) kcal",
                        isSelected: index == selectedAutocompleteIndex,
                        onAcceptItem: {
                            let caloricInformation = CaloricInformation(
                                value: item.calories / item.quantity,
                                measurement: item.measurement
                            )
                            onAcceptItem("\(item.quantity) \(item.measurement)", caloricInformation)
                        }
                    )
                }
            )
        }.value
    }
    
    // todo: optimize performance
    static func calculateAutocompleteForNameInput(
        allItems: [EntryEntity.Item],
        selectedAutocompleteIndex: Int?,
        text: String,
        onAcceptItem: @escaping @Sendable (String, CaloricInformation) -> Void
    ) async -> [AutocompleteItemPresenter] {
        await Task.detached(priority: .userInitiated) {
            Array(allItems
                .uniqued(on: { "\($0.title.lowercased()) \($0.measurement)" })
                .filter {
                    $0.title.lowercased().contains(text.lowercased())
                }
                .prefix(10)
                .enumerated()
                .map { index, item in
                    AutocompleteItemPresenter(
                        title: "\(item.title) (in \(item.measurement))",
                        isSelected: index == selectedAutocompleteIndex,
                        onAcceptItem: {
                            let caloricInformation = CaloricInformation(
                                value: item.calories / item.quantity,
                                measurement: item.measurement
                            )
                            onAcceptItem(item.title, caloricInformation)
                        }
                    )
                }
            )
        }.value
    }
    
}

extension Array where Element == Int {
    var average: Int {
        guard !isEmpty else { return 0 }
        return sorted().reduce(0, +) / count
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
