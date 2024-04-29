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
    private(set) var entryPresenter: EntryRepresentation?
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
        guard entries.count > selectedEntryIndex else {
            self.entryPresenter = nil
            return
        }
        
        let selectedEntry = entries[selectedEntryIndex]
        self.entryPresenter = Mapper.map(entity: selectedEntry)
        
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
    
    private func openInput() {
        let inputViewModel = InputViewModel(
            model: model,
            completeInput: { [weak self] item in
                guard let self else { return }
                
                if let item {
                    assert(entries.count > selectedEntryIndex)
                    let entry = self.entries[selectedEntryIndex]
                    
                    let sectionId = entry.sections.last?.id ?? "Breakfast"
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

