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
            } else if let presenter = viewModel.calendarPresenter {
                CalendarView(presenter: presenter)
            } else if let entryPresenter = viewModel.entryPresenter {
                mainView(entryPresenter: entryPresenter)
                
                if let inputViewModel = viewModel.inputViewModel {
                    Divider()
                    
                    InputView(viewModel: inputViewModel)
                        .frame(width: 350)
                        .padding(.top, Style.padding)
                }
            } else {
                ProgressView()
                    .frame(width: 350)
            }
        }
        .frame(minHeight: 500)
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
            
            VStack(spacing: Style.itemSpacing) {
                viewModel.inputText
                    .map { Text($0) }
                    .foregroundStyle(Color.text)
                
                HStack(spacing: Style.itemSpacing) {
                    viewModel.openCalendarButton
                        .map { ButtonView(presenter: $0) }

                    Spacer()
                    
                    viewModel.newSectionInputButton
                        .map { ButtonView(presenter: $0) }
                    
                    viewModel.openInputButton
                        .map { ButtonView(presenter: $0) }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, Style.padding)
        }
        .padding(.vertical, Style.padding)
        .frame(width: 350)
    }
}
#endif
