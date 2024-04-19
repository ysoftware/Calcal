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
    
    var textRemainder: Substring {
        initialText[i..<endIndex]
    }
    
    private func eatWhitespaces() {
        while (endIndex > i && textRemainder[i].isWhitespace && !textRemainder[i].isNewline) {
            advanceIfPossible(after: i)
        }
    }
    
    private func advanceIfPossible(after: String.Index) {
        if endIndex > after {
            i = textRemainder.index(after: after)
        } else {
            i = endIndex
        }
    }
    
    private func printErrorPosition() {
        print("Parser: Error occured after: '\(textRemainder[i..<endIndex].prefix(10))'")
    }
    
    func parse() throws -> [EntryEntity] {
        var entries: [EntryEntity] = []
            
        while (endIndex > i) {
            eatWhitespaces()
            guard textRemainder[i..<endIndex].starts(with: "Date: "),
                  let indexAfterDate = textRemainder.firstIndex(of: " ")
            else {
                printErrorPosition()
                throw Error.expectedEntry
            }
            advanceIfPossible(after: indexAfterDate)
            
            eatWhitespaces()
            guard let dateNewLineIndex = textRemainder.firstIndex(of: "\n")
            else {
                printErrorPosition()
                throw Error.expectedEOF
            }
            let dateString = String(textRemainder[i..<dateNewLineIndex]).trimmingCharacters(in: .whitespaces)
            advanceIfPossible(after: dateNewLineIndex)
            
            var sections: [EntryEntity.Section] = []
            
            while (endIndex > i) {
                eatWhitespaces()
                
                // Date means new entry
                if textRemainder[i..<endIndex].starts(with: "Date: ") {
                    break
                }
                
                guard let sectionSeparatorIndex = textRemainder.firstIndex(of: "-") else {
                    guard !sections.isEmpty else {
                        printErrorPosition()
                        throw Error.expectedMeal
                    }
                    break
                }
                
                let sectionName = String(textRemainder[i..<sectionSeparatorIndex]).trimmingCharacters(in: .whitespaces)
                advanceIfPossible(after: sectionSeparatorIndex)
                
                guard let sectionNewLineIndex = textRemainder.firstIndex(of: "\n") else {
                    printErrorPosition()
                    throw Error.expectedEOF
                }
                advanceIfPossible(after: sectionNewLineIndex)
                
                var foodItems: [EntryEntity.Item] = []
                
                while (endIndex > i) {
                    eatWhitespaces()
                    
                    // new line means end of section
                    if textRemainder.starts(with: "\n") {
                        advanceIfPossible(after: i)
                        break
                    }
                    
                    guard let itemStartIndex = textRemainder.firstIndex(of: "-") else {
                        guard !foodItems.isEmpty else {
                            printErrorPosition()
                            throw Error.expectedFoodItem
                        }
                        break
                    }
                    advanceIfPossible(after: itemStartIndex)
                    
                    eatWhitespaces()
                    guard let itemNameSeparator = textRemainder.firstIndex(of: ",") else {
                        printErrorPosition()
                        throw Error.expectedCalorieValue
                    }
                    let itemName = String(textRemainder[i..<itemNameSeparator]).trimmingCharacters(in: .whitespaces)
                    advanceIfPossible(after: itemNameSeparator)
                    
                    // TODO: count commas in line to see if we have quantity
                    // TODO: make this optional
                    eatWhitespaces()
                    guard let itemQuantitySeparator = textRemainder.firstIndex(of: ",") else {
                        printErrorPosition()
                        throw Error.expectedCalorieValue
                    }
                    let itemQuantityString = String(textRemainder[i..<itemQuantitySeparator]).trimmingCharacters(in: .whitespaces)
                    advanceIfPossible(after: itemQuantitySeparator)
                    
                    eatWhitespaces()
                    let itemNewLine = textRemainder.firstIndex(of: "\n") ?? endIndex
                    var itemCalorieString = String(textRemainder[i..<itemNewLine]).trimmingCharacters(in: .whitespaces)
                    guard itemCalorieString.contains(" kcal") else {
                        printErrorPosition()
                        throw Error.invalidCalories
                    }
                    itemCalorieString = String(itemCalorieString.dropLast(" kcal".count))
                    advanceIfPossible(after: itemNewLine)
                    
                    // finalise item
                    guard let (quantityValue, measurement) = Self.getQuantity(text: itemQuantityString)
                    else { 
                        printErrorPosition()
                        throw Error.invalidQuantity
                    }
                    
                    guard let caloriesValue = itemCalorieString.floatValue else {
                        printErrorPosition()
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
                if textRemainder[i..<endIndex].starts(with: "Total: ") {
                    if let newLineAfterTotal = textRemainder.firstIndex(of: "\n") {
                        advanceIfPossible(after: newLineAfterTotal)
                        eatWhitespaces()
                        advanceIfPossible(after: i)
                    } else {
                        advanceIfPossible(after: endIndex)
                    }
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
            case .liter: ["milliliter", "millilitre", "liter", "litre", "ml", "l"]
            case .kilogramm: ["kilogram", "gram", "kg", "gr", "g"]
            case .cup: ["cup"]
            case .portion: ["portion", "part"]
            }
            
            let subdivisionValues = [
                "gram", "gr", "g", "milliliter", "millilitre", "ml"
            ]
            
            for value in acceptableValues {
                guard text.hasSuffix(value) else { continue }
                let textWithoutSuffix = String(text.dropLast(value.count)).trimmingCharacters(in: .whitespaces)
                guard let quantityValue = textWithoutSuffix.floatValue else { return nil }
                let subdivision: Float = subdivisionValues.contains(value) ? 1000.0 : 1
                return (quantityValue / subdivision, measurement)
            }
        }
        return nil
    }
}
