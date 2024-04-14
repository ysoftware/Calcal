//
//  InputViewModel.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation
import SwiftUI

class InputViewModel: ObservableObject {
    
    private var onProvideInput: ((EntryEntity.Item) -> Void)?
    
    @Published var autocompleteSuggestions: [QuickItemPresenter] = []
    @Published var popularEntries: [QuickItemPresenter] = []
    @Published var text: String = ""
    
    func onTextChange(newText: String) {
        self.text = newText
        
        // todo: calculate autocomplete
        autocompleteSuggestions = [
            .init(title: "Sosis", onAcceptItem: { }),
            .init(title: "More sosis", onAcceptItem: { }),
            .init(title: "Kashkavalcheese", onAcceptItem: { }),
            .init(title: "Banica", onAcceptItem: { }),
            .init(title: "Cappuccino", onAcceptItem: { }),
        ]
            .filter {
                $0.title.lowercased().contains(newText.lowercased())
            }
    }
    
    func setupExternalActions(onProvideInput: @escaping (EntryEntity.Item) -> Void) {
        self.onProvideInput = onProvideInput
    }
    
    func setupInitialState() {
        text = ""
        
        // todo: calculate top entries
        popularEntries = [
            .init(title: "Sosis, 70g", onAcceptItem: { }),
            .init(title: "More sosis, 50g", onAcceptItem: { }),
            .init(title: "Kashkavalcheese, 20g", onAcceptItem: { }),
            .init(title: "Banica, 70g", onAcceptItem: { }),
            .init(title: "Cappuccino, 1 cup", onAcceptItem: { }),
        ]
    }
}
