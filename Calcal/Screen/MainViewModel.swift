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
    private var inputDestination: ItemDestination?
    
    // ui properties
    private(set) var inputViewModel: InputViewModel?
    private(set) var nextButton: ButtonPresenter?
    private(set) var previousButton: ButtonPresenter?
    private(set) var entryPresenter: EntryRepresentation?
    private(set) var openInputButton: ButtonPresenter?
    private(set) var inputText: String?
    
    func setupInitialState() {
        openInputButton = ButtonPresenter(
            title: "Add",
            action: { [weak self] in
                self?.openInputForLastSection()
            }
        )
        fetchEntries()
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
            guard let self else { return event }
            
            if event.modifierFlags.contains(.command),
               event.charactersIgnoringModifiers == "v",
               let pasteboardString = NSPasteboard.general.string(forType: .string) {
                self.acceptPasteEvent(text: pasteboardString)
                return nil
            }
            
            if event.charactersIgnoringModifiers == " " {
                guard self.inputViewModel == nil else { return event }
                self.openInputForLastSection()
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
            self.inputDestination = nil
            
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
        guard entries.count > selectedEntryIndex else {
            self.entryPresenter = nil
            return
        }
        
        let selectedEntry = entries[selectedEntryIndex]
        self.entryPresenter = Mapper.map(entity: selectedEntry)
        
        self.inputText = if let inputDestination {
            "adding into \(inputDestination.sectionId) on \(inputDestination.entryId)"
        } else {
            nil
        }
        
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
    
    private func openInputForLastSection() {
        assert(entries.count > selectedEntryIndex)
        let entry = self.entries[selectedEntryIndex]
        let sectionId = entry.sections.last?.id ?? "Breakfast"
        let dest = ItemDestination(entryId: entry.date, sectionId: sectionId)
        self.openInput(destination: dest)
    }
    
    private func openInput(destination: ItemDestination) {
        let inputViewModel = InputViewModel(
            model: model,
            completeInput: { [weak self] item in
                guard let self else { return }
                
                if let item {
                    self.model.appendItem(
                        item: item,
                        destination: destination
                    )
                    self.fetchEntries()
                }
                
                self.inputViewModel = nil
                self.inputDestination = nil
                self.updatePresenter()
            }
        )
        
        inputViewModel.setupInitialState()
        
        self.inputViewModel = inputViewModel
        self.inputDestination = destination
        self.updatePresenter()
    }
}
