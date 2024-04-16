//
//  Model.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation

struct EntryEntity {
    let date: String
    var sections: [Section]
}

extension EntryEntity {
    struct Section {
        let id: SectionId
        var items: [Item]
    }
    
    struct Item {
        let title: String
        let quantity: Float
        let measurement: QuantityMeasurement
        let calories: Float
    }
    
    enum QuantityMeasurement: CaseIterable {
        case piece
        case liter
        case kilogramm
        case cup
    }
    
    enum SectionId: String {
        case breakfast
        case brunch
        case lunch
        case secondLunch
        case snack
        case dinner
    }
}
