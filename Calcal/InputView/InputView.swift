//
//  InputView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI

struct InputView: View {
    @ObservedObject var viewModel: InputViewModel
    
    @State private var text: String = "hello mate"
    
    var body: some View {
        VStack {
            Text(viewModel.text)
                .font(.system(size: 25))
            
            TextField("LLL", text: $text)
                .onChange(of: text, initial: false) { _, newValue in
                    viewModel.onTextChange(newText: newValue)
                }
                .onChange(of: viewModel.text) { _, newValue in
                    text = newValue
                }
        }
    }
}
