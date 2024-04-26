//
//  CalcalTests.swift
//  CalcalTests
//
//  Created by Iaroslav Erokhin on 18.04.24.
//

import XCTest
@testable import Calcal

final class CalcalTests: XCTestCase {

    func testGeneralParsing() throws {
        let parser = Parser(text: """
Date: 18 April 2024

Breakfast - 45 kcal
- Cappuccino, 1, 45 kcal

Lunch - 800 kcal
- Chicker Burger, 1, 700 kcal
- Sweet Potato Fries, 1, 100 kcal

Total: 12345 kcal

Date: 19 April 2024

Breakfast - 45 kcal
- Cappuccino, 1, 45 kcal

Date: 20 April 2024

Breakfast - 45 kcal
- Cappuccino, 1, 45 kcal

Total: 12345 kcal
""")
    
        let result = try parser.parse()

        let expectation = [
            EntryEntity(
                date: "18 April 2024",
                sections: [
                    EntryEntity.Section(
                        id: "Breakfast",
                        items: [
                            EntryEntity.Item(
                                title: "Cappuccino",
                                quantity: 1,
                                measurement: .portion,
                                calories: 45
                            )
                        ]
                    ),
                    EntryEntity.Section(
                        id: "Lunch",
                        items: [
                            EntryEntity.Item(
                                title: "Chicker Burger",
                                quantity: 1,
                                measurement: .portion,
                                calories: 700
                            ),
                            EntryEntity.Item(
                                title: "Sweet Potato Fries",
                                quantity: 1,
                                measurement: .portion,
                                calories: 100
                            )
                        ]
                    )
                ]
            ),
            EntryEntity(
                date: "19 April 2024",
                sections: [
                    EntryEntity.Section(
                        id: "Breakfast",
                        items: [
                            EntryEntity.Item(
                                title: "Cappuccino",
                                quantity: 1,
                                measurement: .portion,
                                calories: 45
                            )
                        ]
                    )
                ]
            ),
            EntryEntity(
                date: "20 April 2024",
                sections: [
                    EntryEntity.Section(
                        id: "Breakfast",
                        items: [
                            EntryEntity.Item(
                                title: "Cappuccino",
                                quantity: 1,
                                measurement: .portion,
                                calories: 45
                            )
                        ]
                    )
                ]
            )
        ]
        
        XCTAssertEqual(expectation, result)
    }
    
    func testOptionalQuantity() throws {
        let parser = Parser(text: """
Date: 19 April 2024

Breakfast - 45 kcal
- Cappuccino, 45 kcal
""")
        let result = try parser.parse()
        
        let expectation = [
            EntryEntity(
                date: "19 April 2024",
                sections: [
                    EntryEntity.Section(
                        id: "Breakfast",
                        items: [
                            EntryEntity.Item(
                                title: "Cappuccino",
                                quantity: 1,
                                measurement: .portion,
                                calories: 45
                            )
                        ]
                    )
                ]
            )
        ]
        
        XCTAssertEqual(expectation, result)
    }
    
    func testGramsMilliliters() throws {
        let parser = Parser(text: """
Date: 19 April 2024

Breakfast - 227 kcal
- Chocolate Cookies, 30g, 150 kcal
- Chocolate Cookies, 30 gram, 150 kcal
- Chocolate Cookies, 30gr, 150 kcal
- Orange Juice, 220ml, 77 kcal
- Orange Juice, 220 milliliter, 77 kcal
- Orange Juice, 220 millilitre, 77 kcal
""")
        let result = try parser.parse()
        
        let expectation = [
            EntryEntity(
                date: "19 April 2024",
                sections: [
                    EntryEntity.Section(
                        id: "Breakfast",
                        items: [
                            EntryEntity.Item(
                                title: "Chocolate Cookies",
                                quantity: 0.030,
                                measurement: .kilogramm,
                                calories: 150
                            ),
                            EntryEntity.Item(
                                title: "Chocolate Cookies",
                                quantity: 0.030,
                                measurement: .kilogramm,
                                calories: 150
                            ),
                            EntryEntity.Item(
                                title: "Chocolate Cookies",
                                quantity: 0.030,
                                measurement: .kilogramm,
                                calories: 150
                            ),
                            EntryEntity.Item(
                                title: "Orange Juice",
                                quantity: 0.220,
                                measurement: .liter,
                                calories: 77
                            ),
                            EntryEntity.Item(
                                title: "Orange Juice",
                                quantity: 0.220,
                                measurement: .liter,
                                calories: 77
                            ),
                            EntryEntity.Item(
                                title: "Orange Juice",
                                quantity: 0.220,
                                measurement: .liter,
                                calories: 77
                            )
                        ]
                    )
                ]
            )
        ]
        
        XCTAssertEqual(expectation, result)
    }
}

extension EntryEntity: CustomStringConvertible {
    public var description: String {
        "\n\(date)\n\(sections.map(\.description).joined(separator: "\n"))"
    }
}

extension EntryEntity.Section: CustomStringConvertible {
    public var description: String {
        "\(id)\n\(items.map(\.description).joined(separator: "\n"))"
    }
}

extension EntryEntity.Item: CustomStringConvertible {
    public var description: String {
        "- \(title), \(quantity) \(measurement), \(calories) kcal"
    }
}
