//
//  CalcalApp.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI

@main
struct CalcalApp: App {
    @StateObject var mainViewModel = MainViewModel()
    
    @State private var isAlertPresented: Bool = false
    @State private var alertPresenter: AlertPresenter?
    
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: mainViewModel)
                .alert(
                    "Alert",
                    isPresented: $isAlertPresented,
                    presenting: alertPresenter,
                    actions: { alertPresenter in
                        ForEach(alertPresenter.actions.swiftUIEnumerated, id: \.0) { _, action in
                            Button(action.title, role: action.buttonRole, action: action.action)
                        }
                    }
                ) { alertPresenter in
                    Text(alertPresenter.message)
                }
                .onAppear {
                    mainViewModel.setupInitialState(
                        presentAlert: { alertPresenter in
                            self.isAlertPresented = true
                            self.alertPresenter = alertPresenter
                        }
                    )
                }
                .border(appBorder)
        }
        .windowResizability(.contentSize)
    }
    
    private var appBorder: SwiftUI.Color {
        if Model.TEST_DATA_NEVER_UPLOAD {
            return .red
        }
        
        if Model.TEST_DATA_CHANGES_LOCAL_BACKEND {
            return .green
        }
        return .clear
    }
}

struct AlertPresenter {
    let message: String
    let actions: [Action]
    
    struct Action {
        let title: String
        let buttonRole: ButtonRole?
        let action: () -> Void
    }
}
