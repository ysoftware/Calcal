//
//  InputViewModel.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation
import SwiftUI

class InputViewModel: ObservableObject {
    
    @Published var text: String = ""
    
    func onTextChange(newText: String) {
        self.text = newText
    }
    
    func setupInitialState() {
        text = ""
    }
}
