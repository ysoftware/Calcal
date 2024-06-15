//
//  CalendarView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 15.06.24.
//

import SwiftUI

struct CalendarPresenter {
    let months: [Month]
    let dismissButton: ButtonPresenter
}

extension CalendarPresenter {
    struct Month {
        let title: String
        let rows: [[Column]]
    }
    
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
                ForEach(presenter.months.swiftUIEnumerated, id: \.0) { monthIndex, month in
                    monthView(month: month, index: monthIndex)
                        .overlay(
                            Text(month.title)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(Color.button)
                                .padding(.horizontal, Style.padding)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(maxHeight: .infinity, alignment: .top)
                        )
                }
            }
            .scrollIndicators(.never)
            
            ButtonView(presenter: presenter.dismissButton)
                .padding(.horizontal, Style.padding)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func monthView(month: CalendarPresenter.Month, index: Int) -> some View {
        VStack(spacing: spacing) {
            ForEach(month.rows.swiftUIEnumerated, id: \.0) { _, columns in
                HStack(spacing: spacing) {
                    ForEach(columns.swiftUIEnumerated, id: \.0) { _, column in
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
}
