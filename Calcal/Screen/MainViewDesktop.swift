//
//  ContentView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

#if os(OSX)
import SwiftUI

enum Style {
    static let content: Font = .system(size: 14, weight: .regular)
    static let sectionTitle: Font = .system(size: 14, weight: .semibold)
    static let title: Font = .system(size: 14, weight: .medium)
    static let accent: Font = .system(size: 18, weight: .semibold)
    
    static let bigSpacing: CGFloat = 20
    static let sectionSpacing: CGFloat = 20
    static let itemSpacing: CGFloat = 10
    static let textSpacing: CGFloat = 5
    
    static let padding: CGFloat = 10
}

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: Style.itemSpacing) {
            mainView
            
            if let inputViewModel = viewModel.inputViewModel {
                Divider()
                
                InputView(viewModel: inputViewModel)
                    .frame(width: 350)
            }
        }
        .padding(.vertical, Style.itemSpacing)
        .frame(minHeight: 500)
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
            
            ScrollView(showsIndicators: false) {
                viewModel.entryPresenter
                    .map { EntryView(presenter: $0) }
            }
                
            VStack(spacing: Style.itemSpacing) {
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
            .padding(.horizontal, Style.padding)
        }
        .frame(width: 350)
    }
}
#endif
