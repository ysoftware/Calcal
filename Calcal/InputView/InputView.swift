//
//  InputView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI

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
    
    @State private var text: String = "hello mate"
    
    var body: some View {
        Group {
            VStack(spacing: 10) {
                TextField("Search...", text: $text)
                    .onKeyPress(.downArrow, action: {
                        viewModel.onArrowDownPress()
                        return .handled
                    })
                    .onKeyPress(.upArrow, action: {
                        viewModel.onArrowUpPress()
                        return .handled
                    })
                    .textFieldStyle(.plain)
                    .font(.system(size: 25))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onChange(of: text, initial: false) { _, newValue in
                        viewModel.onTextChange(newText: newValue)
                    }
                    .onChange(of: viewModel.text) { _, newValue in
                        text = newValue
                    }
                
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
            .opacity(viewModel.text.isEmpty ? 0 : 1)
            
            if viewModel.text.isEmpty {
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
}
