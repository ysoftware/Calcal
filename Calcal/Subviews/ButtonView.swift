//
//  Button.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation
import SwiftUI

struct ButtonPresenter {
    let title: String
    let action: () -> Void
}

struct ButtonView: View {
    let presenter: ButtonPresenter
    
    var body: some View {
        Button(action: presenter.action) {
            Text(presenter.title)
                .font(Style.content)
        }
    }
}
