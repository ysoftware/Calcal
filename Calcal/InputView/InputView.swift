//
//  InputView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI

struct QuickItemPresenter {
    // todo: implement separate search text field
    let title: String
    let onAcceptItem: () -> Void
}

struct InputView: View {
    @ObservedObject var viewModel: InputViewModel
    
    @State private var text: String = "hello mate"
    
    var body: some View {
        ZStack {
            TextField("LLL", text: $text)
                .onChange(of: text, initial: false) { _, newValue in
                    viewModel.onTextChange(newText: newValue)
                }
                .onChange(of: viewModel.text) { _, newValue in
                    text = newValue
                }
                .opacity(0)
                .frame(width: 10, height: 10)
                .offset(x: -10)
            
            if !viewModel.text.isEmpty {
                VStack(spacing: 10) {
                    Text(viewModel.text)
                        .font(.system(size: 25))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 2) {
                        ForEach(viewModel.autocompleteSuggestions.swiftUIEnumerated, id: \.0) { _, item in
                            Text(item.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            } else {
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
