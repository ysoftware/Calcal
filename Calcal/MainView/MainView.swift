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
            viewModel.entryPresenter
                .map(EntryView.init(presenter:))
            
            viewModel.openInputButton
                .map(ButtonView.init(presenter:))
        }
        .padding()
    }
}
