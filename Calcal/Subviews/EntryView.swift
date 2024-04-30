//
//  EntryView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation
import SwiftUI

// todo: feature: rework ui
// todo: feature: delete items
// todo: feature: add items to older section?

struct EntryView: View {
    let presenter: EntryRepresentation
    
    var body: some View {
        VStack(spacing: 15) {
            Text(presenter.date)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(presenter.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(presenter.total)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
