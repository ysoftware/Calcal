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
        let subtitle: String
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
        ZStack {
            ScrollView(.vertical) {
                VStack(spacing: 10) {
                    ForEach(presenter.months.swiftUIEnumerated, id: \.0) { monthIndex, month in
                        VStack(spacing: Style.itemSpacing) {
                            HStack(spacing: Style.itemSpacing) {
                                Text(month.title)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(Color.subtitle)
                                
                                Spacer()
                                
                                Text(month.subtitle)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(Color.subtitle)
                            }
                            .padding(.horizontal, Style.padding)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(maxHeight: .infinity, alignment: .top)
                            
                            monthCellsView(month: month, index: monthIndex)
                        }
                    }
                }
                .padding(.top, Style.padding)
            }
            .scrollIndicators(.never)
            .safeAreaInset(edge: .bottom) {
                ButtonView(presenter: presenter.dismissButton)
                    .padding(.horizontal, Style.padding)
                    .padding(.bottom, Style.padding)
                    .background(
                        Color.background.opacity(0.8)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding(.horizontal, -10) // extend edges
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private func monthCellsView(month: CalendarPresenter.Month, index: Int) -> some View {
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

#Preview {
    let weekRows = [
        CalendarPresenter.Column(color: .blue, text: "0"),
        CalendarPresenter.Column(color: .blue, text: "0"),
        CalendarPresenter.Column(color: .blue, text: "0"),
        CalendarPresenter.Column(color: .blue, text: "0"),
        CalendarPresenter.Column(color: .blue, text: "0"),
        CalendarPresenter.Column(color: .blue, text: "0"),
        CalendarPresenter.Column(color: .blue, text: "0"),
    ]
    
    return CalendarView(presenter: CalendarPresenter(
        months: [
            CalendarPresenter.Month(
                title: "June",
                subtitle: "~2120 kcal/day",
                rows: [
                    weekRows,
                    weekRows,
                    weekRows,
                    weekRows
                ]
            ),
            CalendarPresenter.Month(
                title: "July",
                subtitle: "~2058 kcal/day",
                rows: [
                    weekRows,
                    weekRows,
                    weekRows,
                    weekRows
                ]
            )
        ],
        dismissButton: ButtonPresenter(title: "Dismiss", action: {})
    ))
}
