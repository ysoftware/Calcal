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
                        .map(ButtonView.init(presenter:))
                    
                    Spacer()
                    
                    viewModel.nextButton
                        .map(ButtonView.init(presenter:))
                }
                
                viewModel.entryPresenter
                    .map(EntryView.init(presenter:))
                
                Spacer()
                
                viewModel.openInputButton
                    .map(ButtonView.init(presenter:))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(width: 350)
            
            if let inputViewModel = viewModel.inputViewModel {
                
                Divider()
                InputView(viewModel: inputViewModel)
                    .frame(width: 350)
            }
        }
        .padding(10)
        .frame(height: 500)
    }
}
