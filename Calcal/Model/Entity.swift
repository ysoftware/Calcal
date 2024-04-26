//
//  Model.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation

struct EntryEntity: Equatable {
    let date: String
    var sections: [Section]
}

extension EntryEntity {
    struct Section: Equatable {
        let id: String
        var items: [Item]
    }
    
    struct Item: Equatable {
        let title: String
        let quantity: Float
        let measurement: QuantityMeasurement
        let calories: Float
    }
    
    enum QuantityMeasurement: CaseIterable, Equatable {
        case portion
        case liter
        case kilogramm
        case cup
    }
}
