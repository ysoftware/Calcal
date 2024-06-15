//
//  Style.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 02.05.24.
//

import SwiftUI

#if os(macOS)
import AppKit

enum Style {
    static let calendarNumber: Font = .system(size: 13, weight: .regular)
    
    static let content: Font = .system(size: 14, weight: .regular)
    static let sectionTitle: Font = .system(size: 14, weight: .semibold)
    static let title: Font = .system(size: 14, weight: .medium)
    static let accent: Font = .system(size: 18, weight: .semibold)
    
    static let bigSpacing: CGFloat = 20
    static let sectionSpacing: CGFloat = 20
    static let itemSpacing: CGFloat = 10
    static let textSpacing: CGFloat = 5
    
    static let padding: CGFloat = 10
}
#else
import UIKit

enum Style {
    static let calendarNumber: Font = .system(size: 13, weight: .regular)
    
    static let content: Font = .system(size: 15, weight: .regular)
    static let sectionTitle: Font = .system(size: 15, weight: .semibold)
    static let title: Font = .system(size: 15, weight: .semibold)
    static let accent: Font = .system(size: 20, weight: .heavy)
    
    static let bigSpacing: CGFloat = 30
    static let sectionSpacing: CGFloat = 20
    static let itemSpacing: CGFloat = 10
    static let textSpacing: CGFloat = 5
    
    static let padding: CGFloat = 10
}
#endif

enum Color {
    static let suggestionItem = SwiftUI.Color("suggestionItem")
    static let autocompletionItem = SwiftUI.Color("autocompletionItem")
    static let button = SwiftUI.Color("button")
    static let inputFieldBackground = SwiftUI.Color("inputFieldBackgroundColor")
    static let evenItemBackground = SwiftUI.Color("evenItemBackgroundColor")
    static let background = SwiftUI.Color("backgroundColor")
    static let text = SwiftUI.Color("textColor")
    static let selectedAutocompletionItemBackground = SwiftUI.Color("selectedAutocompletionItemBackground")
    static let deleteButtonBackground = SwiftUI.Color("deleteButtonBackground")
    static let errorMessage = SwiftUI.Color("errorMessageColor")
    
    static let entryBest = SwiftUI.Color("entryBestColor")
    static let entryGood = SwiftUI.Color("entryGoodColor")
    static let entryNormal = SwiftUI.Color("entryNormalColor")
    static let entryBad = SwiftUI.Color("entryBadColor")
    static let entryHorrible = SwiftUI.Color("entryHorribleColor")
    static let entryIncomplete = SwiftUI.Color("entryIncompleteColor")
}
