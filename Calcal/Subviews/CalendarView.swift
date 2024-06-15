//
//  CalendarView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 15.06.24.
//

import SwiftUI

struct CalendarPresenter {
    let rows: [[Column]]
    let dismissButton: ButtonPresenter
}

extension CalendarPresenter {
    struct Column {
        let color: SwiftUI.Color
        let text: String
    }
}

struct CalendarView: View {
    
    let presenter: CalendarPresenter
    
    private let spacing: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 10) {
            ScrollView(.vertical) {
                VStack(spacing: spacing) {
                    ForEach(presenter.rows.swiftUIEnumerated, id: \.0) { _, rows in
                        HStack(spacing: spacing) {
                            ForEach(rows.swiftUIEnumerated, id: \.0) { _, column in
                                ZStack {
                                    column.color
                                        .frame(maxWidth: .infinity)
                                        .aspectRatio(1, contentMode: .fill)
                                    
                                    Text(column.text)
                                        .font(Style.calendarNumber)
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                }
            }
            
            ButtonView(presenter: presenter.dismissButton)
                .padding(.horizontal, Style.padding)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
