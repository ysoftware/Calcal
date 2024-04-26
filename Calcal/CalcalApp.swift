//
//  CalcalApp.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI

@main
struct CalcalApp: App {
    let mainViewModel = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: mainViewModel)
                .onAppear {
                    mainViewModel.setupInitialState()
                }
        }
        .windowResizability(.contentSize)
    }
}
