//
//  CalcalApp.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI

@main
struct CalcalApp: App {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @State var inputViewModel: InputViewModel
    @State var mainViewModel: MainViewModel
    
    init() {
        let inputViewModel = InputViewModel()
        
        let mainViewModel = MainViewModel(
            inputViewModel: inputViewModel
        )
        
        self._inputViewModel = State(initialValue: inputViewModel)
        self._mainViewModel = State(initialValue: mainViewModel)
    }
    
    var body: some Scene {
        Window("Calcal", id: WindowId.main) {
            MainView(viewModel: mainViewModel)
                .onAppear {
                    mainViewModel.setupExternalActions(
                        openWindow: { openWindow(id: $0) },
                        dismissWindow: { dismissWindow(id: $0) }
                    )
                    mainViewModel.setupInitialState()
                }
        }
        .defaultSize(width: 350, height: 600)
        
        Window("Add shit", id: WindowId.input) {
            InputView(viewModel: inputViewModel)
        }
        .windowResizability(.contentSize)
    }
}

enum WindowId {
    static let main = "main"
    static let input = "input"
}
