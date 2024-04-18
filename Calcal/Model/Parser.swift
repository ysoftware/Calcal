//
//  Parser.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 18.04.24.
//

import Foundation

class Parser {
    
    enum Error: Swift.Error {
        case expectedEntry
        case expectedMeal
        case expectedEOF
        case expectedFoodItem
        case expectedCalorieValue
        case invalidQuantity
        case invalidCalories
    }

    private let initialText: String
    private let endIndex: String.Index
    
    private var i: String.Index
    
    init(text: String) {
        self.initialText = text
        self.endIndex = text.endIndex
        self.i = text.startIndex
    }
    
    var text: Substring {
        initialText[i..<endIndex]
    }
    
    private func eatWhitespaces() {
        while (endIndex > i && text[i].isWhitespace && !text[i].isNewline) {
            advanceIfPossible(after: i)
        }
    }
    
    private func advanceIfPossible(after: String.Index) {
        if endIndex > after {
            i = text.index(after: after)
        } else {
            i = endIndex
        }
    }
    
    func parse() throws -> [EntryEntity] {
        var entries: [EntryEntity] = []
            
        while (endIndex > i) {
            eatWhitespaces()
            guard text[i..<endIndex].starts(with: "Date: "),
                  let indexAfterDate = text.firstIndex(of: " ")
            else { throw Error.expectedEntry }
            advanceIfPossible(after: indexAfterDate)
            
            eatWhitespaces()
            guard let dateNewLineIndex = text.firstIndex(of: "\n") else { throw Error.expectedEOF }
            let dateString = String(text[i..<dateNewLineIndex]).trimmingCharacters(in: .whitespaces)
            advanceIfPossible(after: dateNewLineIndex)
            
            var sections: [EntryEntity.Section] = []
            
            while (endIndex > i) {
                eatWhitespaces()
                
                // Date means new entry
                if text[i..<endIndex].starts(with: "Date: ") {
                    break
                }
                
                guard let sectionSeparatorIndex = text.firstIndex(of: "-") else {
                    guard !sections.isEmpty else {
                        throw Error.expectedMeal
                    }
                    break
                }
                
                let sectionName = String(text[i..<sectionSeparatorIndex]).trimmingCharacters(in: .whitespaces)
                advanceIfPossible(after: sectionSeparatorIndex)
                
                guard let sectionNewLineIndex = text.firstIndex(of: "\n") else { throw Error.expectedEOF }
                let sectionCalorieString = String(text[i..<sectionNewLineIndex]).trimmingCharacters(in: .whitespaces)
                advanceIfPossible(after: sectionNewLineIndex)
                
                var foodItems: [EntryEntity.Item] = []
                
                while (endIndex > i) {
                    eatWhitespaces()
                    
                    // new line means end of section
                    if text.starts(with: "\n") {
                        advanceIfPossible(after: i)
                        break
                    }
                    
                    guard let itemStartIndex = text.firstIndex(of: "-") else {
                        guard !foodItems.isEmpty else {
                            throw Error.expectedFoodItem
                        }
                        break
                    }
                    advanceIfPossible(after: itemStartIndex)
                    
                    eatWhitespaces()
                    guard let itemNameSeparator = text.firstIndex(of: ",") else { throw Error.expectedCalorieValue }
                    let itemName = String(text[i..<itemNameSeparator]).trimmingCharacters(in: .whitespaces)
                    advanceIfPossible(after: itemNameSeparator)
                    
                    // TODO: count commas in line to see if we have quantity
                    // TODO: make this optional
                    eatWhitespaces()
                    guard let itemQuantitySeparator = text.firstIndex(of: ",") else { throw Error.expectedCalorieValue }
                    let itemQuantityString = String(text[i..<itemQuantitySeparator]).trimmingCharacters(in: .whitespaces)
                    advanceIfPossible(after: itemQuantitySeparator)
                    
                    eatWhitespaces()
                    let itemNewLine = text.firstIndex(of: "\n") ?? endIndex
                    var itemCalorieString = String(text[i..<itemNewLine]).trimmingCharacters(in: .whitespaces)
                    guard itemCalorieString.contains(" kcal") else {
                        throw Error.invalidCalories
                    }
                    itemCalorieString = String(itemCalorieString.dropLast(" kcal".count))
                    advanceIfPossible(after: itemNewLine)
                    
                    // finalise item
                    guard let (quantityValue, measurement) = Self.getQuantity(text: itemQuantityString)
                    else { throw Error.invalidQuantity }
                    
                    guard let caloriesValue = itemCalorieString.floatValue else {
                        throw Error.invalidCalories
                    }
                    
                    let foodItem = EntryEntity.Item(
                        title: itemName,
                        quantity: quantityValue,
                        measurement: measurement,
                        calories: caloriesValue
                    )
                    foodItems.append(foodItem)
                }
                
                // finalise section
                let section = EntryEntity.Section(
                    id: .breakfast, // TODO: fix
                    items: foodItems
                )
                sections.append(section)
                
                eatWhitespaces()
                if text[i..<endIndex].starts(with: "Total: "),
                    let newLineAfterTotal = text.firstIndex(of: "\n") {
                    advanceIfPossible(after: newLineAfterTotal)
                    eatWhitespaces()
                    advanceIfPossible(after: i)
                    break
                }
            }
            
            // finalise entry
            let entry = EntryEntity(
                date: dateString,
                sections: sections
            )
            entries.append(entry)
        }
        
        return entries
    }
    
    static func getQuantity(text: String) -> (Float, EntryEntity.QuantityMeasurement)? {
        if let quantityValue = text.floatValue {
            return (quantityValue, .portion)
        }
        
        for measurement in EntryEntity.QuantityMeasurement.allCases {
            let acceptableValues = switch measurement {
            case .liter: ["l", "liter", "litre", "ml", "millilitre", "milliliter"]
            case .kilogramm: ["kg", "kilogram", "g", "gr", "gram"]
            case .cup: ["cup"]
            case .portion: ["portion", "part"]
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
