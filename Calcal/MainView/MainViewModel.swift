//
//  MainViewModel.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI

class MainViewModel: ObservableObject {

    @Published var entryPresenter: EntryPresenter?
    @Published var openInputButton: ButtonPresenter?
    
    private let inputViewModel: InputViewModel
    private var openWindow: ((String) -> Void)?
    private var dismissWindow: ((String) -> Void)?
    
    init(inputViewModel: InputViewModel) {
        self.inputViewModel = inputViewModel
    }
    
    func setupExternalActions(
        openWindow: @escaping (String) -> Void,
        dismissWindow: @escaping (String) -> Void
    ) {
        self.openWindow = openWindow
        self.dismissWindow = dismissWindow
    }
    
    func setupInitialState() {
        entryPresenter = EntryPresenter(text: mockEntryText)
        
        openInputButton = ButtonPresenter(
            title: "Add",
            action: { [weak self] in
                self?.openInput()
            }
        )
    }
    
    private func openInput() {
        openWindow?(WindowId.input)
        inputViewModel.setupExternalActions(onProvideInput: { [weak self] item in
            // todo: accept item
        })
        inputViewModel.setupInitialState()
    }
}



let mockEntryText = """
Date: 12 April 2024

Breakfast - 145 kcal
- Cappuccino, 45 kcal
- Chorizo, 25g, 100 kcal

Lunch - 785 kcal
- Pasta Bolognese, 550g, 715 kcal
- Juicy, 200g, 70 kcal

Snack - 430 kcal
- Cappuccino, 45 kcal
- Croissant, 80g, 325 kcal
- Strawberry Jam, 22g, 50 kcal
- Strawberries, 30g, 10 kcal

Dinner 1137 kcal
- Burger, 800 kcal
- Beer, 0.75, 337 kcal
"""
