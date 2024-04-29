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
                .border(appBorder)
        }
        .windowResizability(.contentSize)
    }
    
    private var appBorder: Color {
        if Model.TEST_DATA_NEVER_UPLOAD {
            return .red
        }
        
        if Model.TEST_DATA_CHANGES_LOCAL_BACKEND {
            return .green
        }
        return .clear
    }
}
