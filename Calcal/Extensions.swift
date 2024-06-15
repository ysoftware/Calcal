//
//  Extensions.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation
import OSLog

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM yyyy"
    return formatter
}()

extension Array {
    
    /// This looks weird, but it's needed to get index
    /// and `enumerated()` has been known to produce crashes.
    /// Use it like `ForEach(presenter.items.swiftUIEnumerated, id: \.0) { index, item in`.
    var swiftUIEnumerated: [(Int, Element)] {
        [(Int, Element)](zip(indices, self))
    }
}

extension String {
    var floatValue: Float? {
        guard !self.isEmpty else { return nil }
        return Float(self.replacingOccurrences(of: ",", with: "."))
    }
}

extension Logger {
    static var main: Logger { Logger(subsystem: "app", category: "main") }
}
