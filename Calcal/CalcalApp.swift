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
        let model = Model()
        let inputViewModel = InputViewModel(model: model)
        
        let mainViewModel = MainViewModel(
            inputViewModel: inputViewModel,
            model: model
        )
        
        self._inputViewModel = State(initialValue: inputViewModel)
        self._mainViewModel = State(initialValue: mainViewModel)
    }
    
    var body: some Scene {
        Window("Calcal", id: WindowId.main.rawValue) {
            MainView(viewModel: mainViewModel)
                .onAppear {
                    mainViewModel.setupExternalActions(
                        openWindow: { openWindow(id: $0.rawValue) },
                        dismissWindow: { dismissWindow(id: $0.rawValue) }
                    )
                    mainViewModel.setupInitialState()
                }
        }
        .defaultSize(width: 350, height: 600)
        
        Window("Add shit", id: WindowId.input.rawValue) {
            InputView(viewModel: inputViewModel)
        }
        .windowResizability(.contentSize)
    }
}

enum WindowId: String {
    case main
    case input
}
