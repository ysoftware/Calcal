//
//  MainViewModel.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI
import OSLog

#if canImport(AppKit)
import AppKit
#endif

// todo: bug: ui updates wait for data processing
// todo: feature: round values during creation of an item

class MainViewModel: ObservableObject {
    
    private let dateFormatter = DateFormatter()
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
    private(set) var newSectionInputButton: ButtonPresenter?
    private(set) var inputText: String?
    
    func setupInitialState() {
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        openInputButton = ButtonPresenter(
            title: "Add",
            action: { [weak self] in
                self?.openInputForLastSection()
            }
        )
        
        newSectionInputButton = ButtonPresenter(
            title: "Add new meal",
            action: { [weak self] in
                self?.openToAddNewSection()
            }
        )
        
        fetchEntries()
        
        #if canImport(AppKit)
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
                if event.modifierFlags.contains(.option) {
                    self.openToAddNewSection()
                } else {
                    self.openInputForLastSection()
                }
                return nil
            }
            
            return event
        })
        #endif
    }
    
    private func acceptPasteEvent(text: String) {
        do {
            let parser = Parser(text: text)
            let entries = try parser.parse()
            self.inputViewModel = nil
            self.inputDestination = nil
            
            for entry in entries {
                Task {
                    do {
                        try await self.model.addOrUpdateEntry(entry: entry)
                        self.fetchEntries()
                    } catch {
                        Logger.main.error("\(error)")
                    }
                }
            }
        } catch {
            Logger.main.error("Main: acceptPasteEvent: \(error)")
        }
    }
    
    private func fetchEntries() {
        Task {
            do {
                try await model.fetchModel()
                self.entries = model.getAllEntries()
                self.selectedEntryIndex = max(0, entries.count - 1)
                
                updatePresenter()
            } catch {
                Logger.main.error("\(error)")
            }
        }
    }
    
    private func updatePresenter() {
        guard entries.count > selectedEntryIndex else {
            self.entryPresenter = nil
            return
        }
        
        let selectedEntry = entries[selectedEntryIndex]
        self.entryPresenter = Mapper.map(entity: selectedEntry)
        
        self.inputText = if let inputDestination {
            if inputDestination.sectionId.isEmpty {
                "starting new meal on \(inputDestination.entryId)"
            } else {
                "adding into \(inputDestination.sectionId) on \(inputDestination.entryId)"
            }
        } else {
            nil
        }
        
        updateEntrySwitcherButtons()
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    private func updateEntrySwitcherButtons() {
        let todayDate = self.dateFormatter.string(from: Date())

        nextButton = if entries.count > selectedEntryIndex + 1 {
            ButtonPresenter(
                title: "Next day",
                action: { [weak self] in
                    guard let self else { return }
                    
                    guard entries.count > selectedEntryIndex + 1 else { return }
                    self.selectedEntryIndex += 1
                    self.updatePresenter()
                }
            )
        } else if !entries.contains(where: { $0.date.lowercased() == todayDate.lowercased() }) {
            ButtonPresenter(
                title: "Add day",
                action: { [weak self] in
                    guard let self else { return }
                    
                    Task {
                        do {
                            let todayEntry = EntryEntity(date: todayDate, sections: [])
                            try await self.model.addOrUpdateEntry(entry: todayEntry)
                            self.fetchEntries()
                            
                        } catch {
                            Logger.main.error("\(error)")
                        }
                    }
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
                    
                    guard selectedEntryIndex - 1 >= 0 else { return }
                    self.selectedEntryIndex -= 1
                    self.updatePresenter()
                }
            )
        } else {
            nil
        }
    }
    
    private func openToAddNewSection() {
        assert(entries.count > selectedEntryIndex)
        let entry = self.entries[selectedEntryIndex]
        let dest = ItemDestination(entryId: entry.date, sectionId: "")
        self.openInput(destination: dest)
    }
    
    private func openInputForLastSection() {
        assert(entries.count > selectedEntryIndex)
        let entry = self.entries[selectedEntryIndex]
        let sectionId = entry.sections.last?.id ?? "Breakfast"
        let dest = ItemDestination(entryId: entry.date, sectionId: sectionId)
        self.openInput(destination: dest)
    }
    
    /// if destination.sectionId is empty, input will request section name from the user
    private func openInput(destination: ItemDestination) {
        assert(!destination.entryId.isEmpty)
        
        let inputViewModel = InputViewModel(
            model: model,
            shouldInputSectionName: destination.sectionId == "",
            completeInput: { [weak self] item, sectionName in
                guard let self else { return }
                
                // todo: feature: add number to section name if exists when adding a section
                
                let destination = ItemDestination(
                    entryId: destination.entryId,
                    sectionId: sectionName ?? destination.sectionId
                )
                
                if let item {
                    Task {
                        do {
                            try await self.model.appendItem(item: item, destination: destination)
                            self.fetchEntries()
                        } catch {
                            Logger.main.error("\(error)")
                        }
                    }
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
