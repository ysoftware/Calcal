//
//  MainViewModel.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI
import AppKit

class MainViewModel: ObservableObject {
    
    private let model = Model()
    
    // private state
    private var selectedEntryIndex: Int = 0
    private var entries: [EntryEntity] = []
    
    // ui properties
    private(set) var inputViewModel: InputViewModel?
    private(set) var nextButton: ButtonPresenter?
    private(set) var previousButton: ButtonPresenter?
    private(set) var entryPresenter: EntryPresenter?
    private(set) var openInputButton: ButtonPresenter?
    
    func setupInitialState() {
        openInputButton = ButtonPresenter(
            title: "Add",
            action: { [weak self] in
                self?.openInput()
            }
        )
        fetchEntries()
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
            guard let self else { return event }
            
            if event.modifierFlags.contains(.command),
               event.charactersIgnoringModifiers == "v",
               let pasteboardString = NSPasteboard.general.string(forType: .string) {
                acceptPasteEvent(text: pasteboardString)
                return nil
            }
            
            if event.charactersIgnoringModifiers == " " {
                guard self.inputViewModel == nil else { return event }
                openInput()
                return nil
            }
            
            return event
        })
    }
    
    private func acceptPasteEvent(text: String) {
        do {
            let parser = Parser(text: text)
            let entries = try parser.parse()
            self.inputViewModel = nil
            
            for entry in entries {
                self.model.addOrUpdateEntry(entry: entry)
                self.fetchEntries()
            }
        } catch {
            print(error)
        }
    }
    
    private func fetchEntries() {
        self.entries = model.getAllEntries()
        self.selectedEntryIndex = max(0, entries.count - 1)
        updatePresenter()
    }
    
    private func updatePresenter() {
        updateSelectedEntry()
        updateEntrySwitcherButtons()
        
        DispatchQueue.main.async { [self] in
            objectWillChange.send()
        }
    }
    
    private func updateEntrySwitcherButtons() {
        nextButton = if entries.count > selectedEntryIndex + 1 {
            ButtonPresenter(
                title: "Next day",
                action: { [weak self] in
                    guard let self else { return }
                    self.selectedEntryIndex += 1
                    self.updatePresenter()
                }
            )
        } else {
            nil
        }
        
        previousButton = if selectedEntryIndex > 0 {
            ButtonPresenter(
                title: "Previous day",
                action: { [weak self] in
                    guard let self else { return }
                    self.selectedEntryIndex -= 1
                    self.updatePresenter()
                }
            )
        } else {
            nil
        }
    }
    
    private func updateSelectedEntry() {
        guard entries.count > selectedEntryIndex else {
            self.entryPresenter = nil
            return
        }
        
        let selectedEntry = entries[selectedEntryIndex]
        
        // todo: update for better ui
        var entryText = ""
        var totalCalories: Float = 0
        
        for section in selectedEntry.sections {
            var itemsText = ""
            var sectionCalories: Float = 0
            
            for item in section.items {
                itemsText.append("- \(item.title), \(measurementDisplayValue(item: item)), \(item.calories.formatted(.number.rounded())) kcal\n")
                sectionCalories += item.calories
            }
            
            entryText.append("\(section.id.rawValue.uppercased()) - \(sectionCalories.formatted(.number.rounded())) kcal\n\(itemsText)\n")
            totalCalories += sectionCalories
        }
        
        self.entryPresenter = EntryPresenter(
            date: selectedEntry.date.uppercased(),
            text: entryText.trimmingCharacters(in: .whitespacesAndNewlines),
            total: "Total: \(totalCalories.formatted(.number.rounded().grouping(.never))) kcal"
        )
    }
    
    private func measurementDisplayValue(item: EntryEntity.Item) -> String {
        switch item.measurement {
        case .portion:
            if item.quantity == 1 {
                return "1"
            }
            return "\(item.quantity.formatted(.number.rounded()))"
        case .cup:
            if item.quantity == 1 {
                return "1 cup"
            }
            return "\(item.quantity.formatted(.number.rounded())) cups"
        case .liter:
            if item.quantity > 0.5 {
                return "\(item.quantity.formatted(.number.rounded())) l"
            }
            return "\((item.quantity*1000).formatted(.number.rounded())) ml"
        case .kilogramm:
            if item.quantity > 0.5 {
                return "\(item.quantity.formatted(.number.rounded())) kg"
            }
            return "\((item.quantity*1000).formatted(.number.rounded())) g"
        }
    }
    
    private func openInput() {
        let inputViewModel = InputViewModel(
            model: model,
            completeInput: { [weak self] item in
                guard let self else { return }
                
                if let item {
                    assert(entries.count > selectedEntryIndex)
                    let entry = self.entries[selectedEntryIndex]
                    
                    // todo: fix this
                    let sectionId: EntryEntity.SectionId = entry.sections.last?.id ?? .breakfast
                    self.model.appendItemToLastEntry(item: item, sectionId: sectionId)
                    self.fetchEntries()
                }
                
                self.inputViewModel = nil
                self.updatePresenter()
            }
        )
        
        inputViewModel.setupInitialState()
        
        self.inputViewModel = inputViewModel
        self.updatePresenter()
    }
}

