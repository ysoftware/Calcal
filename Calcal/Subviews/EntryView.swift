//
//  EntryView.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import Foundation
import SwiftUI

struct EntryPresenter {
    let date: String
    let total: String
    let sections: [Section]
}

extension EntryPresenter {
    struct Section {
        let name: String
        let calories: String
        let items: [Item]
    }
    
    struct Item {
        let title: String
        let calories: String
        let quantity: String
        let deleteButton: ButtonPresenter
    }
}

struct EntryView: View {
    @State private var hoverIndex: (Int, Int)? = nil
    
    let presenter: EntryPresenter
    
    private func isHoveringCell(_ sectionIndex: Int, _ itemIndex: Int) -> Bool {
        guard let hoverIndex else { return false }
        return hoverIndex == (sectionIndex, itemIndex)
    }
    
    var body: some View {
        VStack(spacing: Style.itemSpacing) {
            HStack(alignment: .bottom, spacing: 0) {
                Text(presenter.date)
                    .font(Style.title)
                    .foregroundStyle(Color.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(presenter.total)
                    .font(Style.accent)
                    .foregroundStyle(Color.text)
            }
            .padding(.horizontal, Style.padding)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Style.sectionSpacing) {
                    ForEach(presenter.sections.swiftUIEnumerated, id: \.0) { sectionIndex, section in
                        VStack(spacing: Style.textSpacing) {
                            HStack(spacing: Style.textSpacing) {
                                Text(section.name)
                                    .foregroundStyle(Color.text)
                                    .font(Style.sectionTitle)
                                    .frame(width: 120, alignment: .leading)
                                
                                Text(section.calories)
                                    .font(Style.sectionTitle)
                                    .foregroundStyle(Color.text)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Style.padding)
                            
                            if !section.items.isEmpty {
                                List {
                                    ForEach(section.items.swiftUIEnumerated, id: \.0) { itemIndex, item in
                                        HStack(alignment: .center, spacing: Style.textSpacing) {
                                            Text(item.title)
                                                .font(Style.content)
                                                .foregroundStyle(Color.text)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text(item.quantity)
                                                .font(Style.content)
                                                .foregroundStyle(Color.text)
                                                .frame(width: 60, alignment: .leading)
                                            
                                            Text(item.calories)
                                                .font(Style.content)
                                                .foregroundStyle(Color.text)
                                                .frame(width: 60, alignment: .trailing)
                                        }
                                        .padding(.horizontal, Style.padding)
                                        .frame(height: 20)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            ButtonView(presenter: item.deleteButton)
                                                .tint(Color.deleteButtonBackground)
                                        }
                                        .setupRowStyle()
                                        .background(itemIndex % 2 == 0 ? Color.evenItemBackground : .clear)
                                    }
                                }
                                .setupStyle()
                                .scrollDisabled(true)
                                .frame(height: CGFloat(section.items.count) * 20 + CGFloat(section.items.count-1) * Style.textSpacing)
                            }
                        }
                    }
                }
            }
        }
    }
}

private extension View {
    func setupRowStyle() -> some View {
        #if os(macOS)
        self
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .listRowBackground(SwiftUI.Color.clear)
        #else
        self
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .listRowBackground(SwiftUI.Color.clear)
            .listRowSpacing(0)
        #endif
    }
}

private extension List {
    
    func setupStyle() -> some View {
        #if os(macOS)
        self
            .padding(EdgeInsets(top: 0, leading: -8, bottom: 0, trailing: -8))
            .clipShape(Rectangle())
            .contentMargins(0)
            .padding(EdgeInsets())
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        #else
        self
            .clipShape(Rectangle())
            .contentMargins(0)
            .listRowSpacing(Style.textSpacing)
            .padding(EdgeInsets())
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 10)
        #endif
    }
}
