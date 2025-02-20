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
        VStack(alignment: .leading, spacing: Style.itemSpacing) {
            if let presenter = viewModel.errorPresenter {
                ErrorView(presenter: presenter)
            } else if let presenter = viewModel.calendarPresenter {
                CalendarView(presenter: presenter)
            } else if let entryPresenter = viewModel.entryPresenter {
                if viewModel.inputViewModel == nil {
                    mainView(entryPresenter: entryPresenter)
                }
                
                if let inputViewModel = viewModel.inputViewModel {
                    viewModel.inputText
                        .map { Text($0) }
                        .foregroundStyle(Color.text)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    InputView(viewModel: inputViewModel)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(maxHeight: .infinity, alignment: .center)
            }
        }
        .background(Color.background)
    }
    
    private func mainView(entryPresenter: EntryPresenter) -> some View {
        VStack(spacing: Style.itemSpacing) {
            HStack(spacing: 0) {
                viewModel.previousButton
                    .map { ButtonView(presenter: $0) }
                
                Spacer()
                
                viewModel.nextButton
                    .map { ButtonView(presenter: $0) }
            }
            .padding(.horizontal, Style.padding)
            
            EntryView(presenter: entryPresenter)
            
            Spacer()
            
            VStack(spacing: Style.itemSpacing) {
                HStack(spacing: Style.itemSpacing) {
                    viewModel.openCalendarButton
                        .map { ButtonView(presenter: $0) }

                    Spacer()
                    
                    viewModel.newSectionInputButton
                        .map { ButtonView(presenter: $0) }
                        .padding(.trailing, Style.bigSpacing)
                    
                    viewModel.openInputButton
                        .map { ButtonView(presenter: $0) }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(Style.padding)
        }
    }
}
#endif
