//
//  Model.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation

struct EntryEntity {
    let date: Date
    let sections: [Section]
}

extension EntryEntity {
    struct Section {
        let title: String
        let items: [Item]
    }
    
    struct Item {
        let title: String
        let quantity: Float
        let measurement: QuantityMeasurement
        let calories: Float
    }
    
    enum QuantityMeasurement {
        case piece
        case liter
        case kilogramm
        case cup
        case tablespoon
    }
}
