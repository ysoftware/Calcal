//
//  MainViewModel.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI

class MainViewModel: ObservableObject {
    
    private let model = Model()
    private let inputViewModel: InputViewModel
    private var openWindow: ((WindowId) -> Void)?
    private var dismissWindow: ((WindowId) -> Void)?
    
    private var selectedEntryIndex: Int = 0
    private var entries: [EntryEntity] = []
    
    private(set) var nextButton: ButtonPresenter?
    private(set) var previousButton: ButtonPresenter?
    
    private(set) var entryPresenter: EntryPresenter?
    private(set) var openInputButton: ButtonPresenter?
    
    init(inputViewModel: InputViewModel) {
        self.inputViewModel = inputViewModel
    }
    
    func setupExternalActions(
        openWindow: @escaping (WindowId) -> Void,
        dismissWindow: @escaping (WindowId) -> Void
    ) {
        self.openWindow = openWindow
        self.dismissWindow = dismissWindow
    }
    
    func setupInitialState() {
        openInputButton = ButtonPresenter(
            title: "Add",
            action: { [weak self] in
                self?.openInput()
            }
        )
        fetchEntries()
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
            guard let self,
                  event.modifierFlags.contains(.command),
                  event.charactersIgnoringModifiers == "v",
                  let pasteboardString = NSPasteboard.general.string(forType: .string)
            else { return event }
            
            do {
                let parser = Parser(text: pasteboardString)
                let entries = try parser.parse()
                
                for entry in entries {
                    self.dismissWindow?(.input)
                    self.model.addOrUpdateEntry(entry: entry)
                    self.fetchEntries()
                }
                return nil
            } catch {
                print(error)
                return event
            }
        })
    }
    
    private func fetchEntries() {
        self.entries = model.getAllEntries()
        self.selectedEntryIndex = max(0, entries.count - 1)
        
        updateSelectedEntry()
        updateView()
    }
    
    private func updateSelectedEntry() {
        guard entries.count > selectedEntryIndex else { return }
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
            return "\(item.quantity.formatted(.number.rounded()))) cups"
        case .liter:
            if item.quantity > 0.5 {
                return "\(item.quantity.formatted(.number.rounded()))l"
            }
            return "\((item.quantity*100).formatted(.number.rounded())))ml"
        case .kilogramm:
            if item.quantity > 0.5 {
                return "\(item.quantity.formatted(.number.rounded()))kg"
            }
            return "\((item.quantity*1000).formatted(.number.rounded()))g"
        }
    }
    
    private func openInput() {
        openWindow?(WindowId.input)
        inputViewModel.setupExternalActions(onProvideInput: { [weak self] item in
            guard let self else { return }
            assert(entries.count > selectedEntryIndex)
            
            let entry = self.entries[selectedEntryIndex]
            
            // todo: fix this
            let sectionId: EntryEntity.SectionId = entry.sections.last?.id ?? .breakfast
            self.model.appendItemToLastEntry(item: item, sectionId: sectionId)
            self.dismissWindow?(.input)
            self.fetchEntries()
        })
        inputViewModel.setupInitialState()
    }
    
    private func updateView() {
        DispatchQueue.main.async { [self] in
            objectWillChange.send()
        }
    }
}

