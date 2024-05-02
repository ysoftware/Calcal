//
//  ContentView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

#if os(iOS)
import SwiftUI

enum Style {
    static let content: Font = .system(size: 15, weight: .regular)
    static let sectionTitle: Font = .system(size: 15, weight: .semibold)
    static let title: Font = .system(size: 15, weight: .semibold)
    static let accent: Font = .system(size: 20, weight: .heavy)
    
    static let bigSpacing: CGFloat = 30
    static let sectionSpacing: CGFloat = 20
    static let itemSpacing: CGFloat = 10
    static let textSpacing: CGFloat = 5
    
    static let padding: CGFloat = 10
}

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Style.itemSpacing) {
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
        .padding(.vertical, Style.padding)
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
            
            ScrollView {
                viewModel.entryPresenter
                    .map { EntryView(presenter: $0) }
            }
            
            Spacer()
            
            VStack(spacing: Style.itemSpacing) {
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
    }
}
#endif
