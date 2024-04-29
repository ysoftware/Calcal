//
//  ContentView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

#if os(iOS)
import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if viewModel.inputViewModel == nil {
                mainView
            }
            
            if let inputViewModel = viewModel.inputViewModel {
                viewModel.inputText
                    .map { Text($0) }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                InputView(viewModel: inputViewModel)
            }
        }
        .padding(10)
    }
    
    private var mainView: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                viewModel.previousButton
                    .map { ButtonView(presenter: $0) }
                
                Spacer()
                
                viewModel.nextButton
                    .map { ButtonView(presenter: $0) }
            }
            
            ScrollView {
                viewModel.entryPresenter
                    .map { EntryView(presenter: $0) }
            }
            
            Spacer()
            
            VStack(spacing: 10) {
                HStack(spacing: 0) {
                    viewModel.newSectionInputButton
                        .map { ButtonView(presenter: $0) }
                    
                    Spacer()
                    
                    viewModel.openInputButton
                        .map { ButtonView(presenter: $0) }
                }
            }
        }
    }
}
#endif
