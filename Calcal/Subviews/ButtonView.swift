//
//  Button.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation
import SwiftUI

struct ButtonPresenter: @unchecked Sendable {
    let title: String
    let action: () -> Void
}

struct ButtonView: View {
    let presenter: ButtonPresenter
    let color: SwiftUI.Color
    let isActOnPress: Bool
    
    @State private var isPressing = false
    
    init(
        presenter: ButtonPresenter,
        color: SwiftUI.Color = Color.button,
        isActOnPress: Bool = true
    ) {
        self.isActOnPress = isActOnPress
        self.presenter = presenter
        self.color = color
    }
    
    var body: some View {
        Group {
            #if os(macOS)
            Text(presenter.title)
                .foregroundStyle(color)
                .font(Style.content)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.buttonBackground.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 5))
            #else
            Text(presenter.title)
                .foregroundStyle(color)
                .font(Style.content)
                .padding(.horizontal, 5)
                .padding(.vertical, 10)
            #endif
        }
        .gesture(gesture)
    }
    
    private var gesture: AnyGesture<Void> {
        if isActOnPress {
            AnyGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressing {
                            isPressing = true
                            presenter.action()
                        }
                    }
                    .onEnded { _ in
                        isPressing = false
                    }
                    .map { _ in }
            )
        } else {
            AnyGesture(
                TapGesture()
                    .onEnded {
                        presenter.action()
                    }
                    .map { _ in }
            )
        }
    }
}
