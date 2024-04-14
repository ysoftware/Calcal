//
//  EntryView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation
import SwiftUI

struct EntryPresenter {
    let text: String
}

struct EntryView: View {
    let presenter: EntryPresenter
    
    var body: some View {
        Text(presenter.text)
    }
}

#Preview {
    EntryView(
        presenter: EntryPresenter(
            text: """
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

Total: 2497 kcal
"""
        )
    )
}
