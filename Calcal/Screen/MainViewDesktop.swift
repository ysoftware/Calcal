//
//  ContentView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

#if os(macOS)
import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: Style.itemSpacing) {
            if let presenter = viewModel.errorPresenter {
                ErrorView(presenter: presenter)
            } else {
                mainView
                
                if let inputViewModel = viewModel.inputViewModel {
                    Divider()
                    
                    InputView(viewModel: inputViewModel)
                        .frame(width: 350)
                }
            }
        }
        .padding(.vertical, Style.itemSpacing)
        .frame(minHeight: 500)
        .background(Color.background)
    }
    
    private var mainView: some View {
        VStack(spacing: Style.itemSpacing) {
            HStack(spacing: 0) {
                viewModel.previousButton
                    .map { ButtonView(presenter: $0) }
                
                Spacer()
                
                viewModel.nextButton
                    .map { ButtonView(presenter: $0) }
            }
            .padding(.horizontal, Style.padding)
            
            viewModel.entryPresenter
                .map { EntryView(presenter: $0) }
            
            VStack(spacing: Style.itemSpacing) {
                viewModel.inputText
                    .map { Text($0) }
                    .foregroundStyle(Color.text)
                
                HStack(spacing: 0) {
                    viewModel.newSectionInputButton
                        .map { ButtonView(presenter: $0) }
                    
                    Spacer()
                    
                    viewModel.openInputButton
                        .map { ButtonView(presenter: $0) }
                }
            }
            .padding(.horizontal, Style.padding)
        }
        .frame(width: 350)
    }
}
#endif
