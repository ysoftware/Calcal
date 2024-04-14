//
//  EntryView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation
import SwiftUI

struct EntryPresenter {
    let date: String
    let text: String
    let total: String
}

struct EntryView: View {
    let presenter: EntryPresenter
    
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
