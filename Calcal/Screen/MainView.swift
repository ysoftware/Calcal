//
//  ContentView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 10) {
                HStack(spacing: 0) {
                    viewModel.previousButton
                        .map { ButtonView(presenter: $0) }
                    
                    Spacer()
                    
                    viewModel.nextButton
                        .map { ButtonView(presenter: $0) }
                }
                
                viewModel.entryPresenter
                    .map { EntryView(presenter: $0) }
                
                Spacer()
                
                VStack(spacing: 10) {
                    viewModel.inputText
                        .map { Text($0) }
                    
                    HStack(spacing: 0) {
                        viewModel.newSectionInputButton
                            .map { ButtonView(presenter: $0) }
                        
                        Spacer()
                        
                        viewModel.openInputButton
                            .map { ButtonView(presenter: $0) }
                    }
                }
            }
            .frame(width: 350)
            
            if let inputViewModel = viewModel.inputViewModel {
                
                Divider()
                
                InputView(viewModel: inputViewModel)
                    .frame(width: 350)
            }
        }
        .padding(10)
        .frame(minHeight: 500)
    }
}
