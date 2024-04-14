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
        VStack(spacing: 8) {
            HStack {
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
        .padding()
    }
}
