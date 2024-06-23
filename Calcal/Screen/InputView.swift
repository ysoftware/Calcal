//
//  InputView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI

struct AutocompleteItemPresenter {
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
            HStack(alignment: .center, spacing: Style.itemSpacing) {
                textField
                
                viewModel.closeButton
                    .map { ButtonView(presenter: $0) }
            }
            .padding(.bottom, Style.itemSpacing)
            .padding(.horizontal, Style.padding)
            
            autocompletions
            
            quickSuggestions
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var quickSuggestions: some View {
        if isShowingSuggestions, !viewModel.popularEntries.isEmpty {
            ScrollView(.vertical) {
                VStack(spacing: 5) {
                    ForEach(viewModel.popularEntries.swiftUIEnumerated, id: \.0) { _, item in
                        #if os(iOS)
                        ButtonView(presenter: item, color: Color.suggestionItem)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 40)
                        #else
                        ButtonView(presenter: item, color: Color.suggestionItem)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        #endif
                    }
                }
                .padding(.vertical, 1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Style.padding)
            }
        }
    }
    
    @ViewBuilder
    private var autocompletions: some View {
        if !viewModel.autocompleteSuggestions.isEmpty {
            ScrollView(.vertical) {
                VStack(spacing: Style.textSpacing) {
                    ForEach(viewModel.autocompleteSuggestions.swiftUIEnumerated, id: \.0) { index, item in
                        #if os(iOS)
                        ButtonView(presenter: ButtonPresenter(title: item.title, action: item.onAcceptItem))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 40)
                        #else
                        Text(item.title)
                            .foregroundStyle(Color.autocompletionItem)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 20)
                            .background {
                                if item.isSelected {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.selectedAutocompletionItemBackground)
                                        .padding(.trailing, Style.padding)
                                }
                            }
                        #endif
                    }
                }
                .padding(.horizontal, Style.padding)
            }
        }
    }
    
    private var textField: some View {
        TextField(viewModel.inputPlaceholder, text: $text)
            .isNumpad(isNumpadKeyboardType)
            .textFieldStyle(.plain)
            .font(.system(size: 18))
            .focused($isTextFieldFocused)
            .frame(height: 40, alignment: .center)
            .padding(.horizontal, Style.itemSpacing)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                Color.inputFieldBackground
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .onChange(of: text, initial: false) { _, newValue in
                viewModel.onTextChange(newText: newValue)
            }
            .onChange(of: viewModel.text) { _, newValue in
                text = newValue
            }
#if os(iOS)
            .onSubmit {
                viewModel.onEnterPress()
                isTextFieldFocused = true
            }
#endif
            .onAppear {
                isTextFieldFocused = true
            }
    }
    
    private var isNumpadKeyboardType: Bool {
        switch viewModel.state {
        case .quantity, .calories:
            return true
        default:
            return false
        }
    }
    
    private var isShowingSuggestions: Bool {
        text.isEmpty && viewModel.state == .name
    }
}

extension TextField {
    func isNumpad(_ value: Bool) -> some View {
        #if os(iOS)
        self.keyboardType(value ? .numbersAndPunctuation : .default)
        #else
        self
        #endif
    }
}
