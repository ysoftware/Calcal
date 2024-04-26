//
//  InputView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI

enum InputViewState {
    case name
    case quantity
    case calories
}

struct QuickItemPresenter {
    let title: String
    let onAcceptItem: () -> Void
}

struct AutocompleteItemPresenter {
    // todo: implement separate search text field
    let title: String
    let isSelected: Bool
    let onAcceptItem: () -> Void
}

struct InputView: View {
    @FocusState var isTextFieldFocused: Bool
    @ObservedObject var viewModel: InputViewModel
    
    @State private var text: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            textField
            autocompletions
            quickSuggestions
        }
    }
    
    @ViewBuilder
    private var quickSuggestions: some View {
        if isShowingSuggestions {
            ScrollView(.vertical) {
                VStack(spacing: 10) {
                    ForEach(viewModel.popularEntries.swiftUIEnumerated, id: \.0) { _, item in
                        Button(item.title, action: item.onAcceptItem)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.trailing, 10)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var autocompletions: some View {
        VStack(spacing: 2) {
            ForEach(viewModel.autocompleteSuggestions.swiftUIEnumerated, id: \.0) { _, item in
                Text(item.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        if item.isSelected {
                            Color.accentColor.opacity(0.3)
                        }
                    }
            }
        }
    }
    
    private var textField: some View {
        TextField(viewModel.inputPlaceholder, text: $text)
            .textFieldStyle(.plain)
            .font(.system(size: 18))
            .focused($isTextFieldFocused)
            .frame(height: 40, alignment: .center)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                Color.white.clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .padding(.bottom, 10)
            .onChange(of: text, initial: false) { _, newValue in
                viewModel.onTextChange(newText: newValue)
            }
            .onChange(of: viewModel.text) { _, newValue in
                text = newValue
            }
            .onKeyPress(.downArrow, action: {
                viewModel.onArrowDownPress()
                return .handled
            })
            .onKeyPress(.upArrow, action: {
                viewModel.onArrowUpPress()
                return .handled
            })
            .onKeyPress(.return, action: {
                viewModel.onEnterPress()
                return .handled
            })
            .onKeyPress(.escape, action: {
                viewModel.onEscapePress()
                return .handled
            })
            .onAppear {
                isTextFieldFocused = true
            }
    }
    
    private var isShowingSuggestions: Bool {
        text.isEmpty && viewModel.state == .name
    }
}
