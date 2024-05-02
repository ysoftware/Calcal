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
    let color: SwiftUI.Color
    
    init(presenter: ButtonPresenter, color: SwiftUI.Color = Color.button) {
        self.presenter = presenter
        self.color = color
    }
    
    var body: some View {
        Button(action: presenter.action) {
            Text(presenter.title)
                .foregroundStyle(color)
                .font(Style.content)
        }
    }
}
