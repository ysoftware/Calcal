//
//  ErrorView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 15.06.24.
//

import SwiftUI

struct ErrorPresenter {
    let message: String
    let retryButton: ButtonPresenter?
}

struct ErrorView: View {
    
    let presenter: ErrorPresenter
    
    var body: some View {
        VStack(spacing: 30) {
            Text(presenter.message)
                .font(Style.content)
                .foregroundStyle(Color.errorMessageColor)
                .frame(maxWidth: .infinity, alignment: .center)
            
            if let buttonPresenter = presenter.retryButton {
                ButtonView(presenter: buttonPresenter)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(30)
    }
}
