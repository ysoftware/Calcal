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
    @ObservedObject var viewModel: InputViewModel
    
    @State private var text: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                TextField(stateText, text: $text)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 25))
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                
                Spacer()
            }
            .padding()
//            .opacity(isShowingSuggestions ? 0 : 1)
            
            if isShowingSuggestions {
                ScrollView(.vertical) {
                    VStack {
                        ForEach(viewModel.popularEntries.swiftUIEnumerated, id: \.0) { _, item in
                            Button(item.title, action: item.onAcceptItem)
                                .fixedSize()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(width: 350)
        .frame(minHeight: 100)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private var isShowingSuggestions: Bool {
        text.isEmpty && viewModel.state == .name
    }
    
    private var stateText: String {
        switch viewModel.state {
        case .name:
            return "Name"
        case .quantity:
            return "Quantity"
        case .calories:
            return "Calories"
        }
    }
}
