//
//  MainViewModel.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 14.04.24.
//

import SwiftUI
import OSLog

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// todo: bug: ui updates wait for data processing

final class MainViewModel: ObservableObject, @unchecked Sendable {
    
    nonisolated init() { } // swift bug
    
    private let model = Model()
    
    // private state
    private var appBackgroundTimestamp = Date()
    private var selectedEntryIndex: Int = 0
    private var entries: [EntryEntity] = []
    private var inputDestination: ItemDestination?
    
    // other views
    @MainActor private(set) var errorPresenter: ErrorPresenter?
    @MainActor private(set) var calendarPresenter: CalendarPresenter?
    @MainActor private(set) var inputViewModel: InputViewModel?
    
    // ui for this view
    @MainActor private(set) var openCalendarButton: ButtonPresenter?
    @MainActor private(set) var nextButton: ButtonPresenter?
    @MainActor private(set) var previousButton: ButtonPresenter?
    @MainActor private(set) var entryPresenter: EntryPresenter?
    @MainActor private(set) var openInputButton: ButtonPresenter?
    @MainActor private(set) var newSectionInputButton: ButtonPresenter?
    @MainActor private(set) var inputText: String?
    
    func setupInitialState() {
        Task { @MainActor in
            setupAppLifecycleEvents()
            setupKeyDownEvents()
            
            openCalendarButton = ButtonPresenter(
                title: "Calendar",
                action: { [weak self] in
                    self?.openCalendar()
                }
            )
            
            openInputButton = ButtonPresenter(
                title: "Add",
                action: { [weak self] in
                    self?.openInputForLastSection()
                }
            )
            
            newSectionInputButton = ButtonPresenter(
                title: "Add to meal",
                action: { [weak self] in
                    self?.openToAddNewSection()
                }
            )
        }
        
        fetchEntries()
    }
    
    @MainActor private func setupAppLifecycleEvents() {
#if canImport(UIKit)
        let fg = UIApplication.willEnterForegroundNotification
        let bg = UIApplication.didEnterBackgroundNotification
#else
        let fg = NSWindow.didBecomeKeyNotification
        let bg = NSWindow.didResignKeyNotification
#endif
        
        NotificationCenter.default.addObserver(forName: fg, object: nil, queue: .main) { [weak self] _ in
            guard let self, Date().timeIntervalSince(self.appBackgroundTimestamp) >= 10 else { return }
            self.fetchEntries()
        }
        
        NotificationCenter.default.addObserver(forName: bg, object: nil, queue: .main) { [weak self] _ in
            self?.appBackgroundTimestamp = Date()
        }
    }
    
    @MainActor private func setupKeyDownEvents() {
#if canImport(AppKit)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
            guard let self else { return event }
            
            if event.charactersIgnoringModifiers == " " {
                guard self.inputViewModel == nil else { return event }
                if event.modifierFlags.contains(.option) {
                    self.openToAddNewSection()
                } else {
                    self.openInputForLastSection()
                }
                return nil
            }
            
            if event.keyCode == 124, entries.count > selectedEntryIndex + 1 {
                self.nextButton?.action()
                return nil
            }
            
            if event.keyCode == 123, selectedEntryIndex > 0 {
                self.previousButton?.action()
                return nil
            }
            
            return event
        })
#endif
    }
    
    private func fetchEntries() {
        Task { @MainActor in
            do {
                try await model.fetchModel()
                self.entries = model.getAllEntries()
                self.selectedEntryIndex = max(0, entries.count - 1)
            } catch {
                Logger.main.error("MainViewModel.fetchEntries: \(error)")
                self.errorPresenter = ErrorPresenter(
                    message: "Unable to fetch entries: \(error)",
                    retryButton: ButtonPresenter(title: "try fetching again", action: { [weak self] in
                        self?.fetchEntries()
                    })
                )
            }
            updatePresenter()
        }
    }
    
    @MainActor private func updatePresenter() {
        defer { self.objectWillChange.send() }
        
        guard entries.count > selectedEntryIndex else {
            self.entryPresenter = nil // not error, just empty entry
            return
        }
        
        let selectedEntry = entries[selectedEntryIndex]
        self.entryPresenter = Mapper.map(
            entity: selectedEntry,
            onDeleteItem: { [weak self] sectionId, itemIndex in
                guard let self else { return }
                
                Task { @MainActor in
                    do {
                        try await self.model.deleteItem(
                            entryId: selectedEntry.date,
                            sectionId: sectionId,
                            itemIndex: itemIndex
                        )
                        
                        self.fetchEntries()
                    } catch {
                        Logger.main.error("\(error)")
                    }
                }
            }
        )
        
        self.inputText = if let inputDestination {
            if inputDestination.sectionId.isEmpty {
                "adding to meal on \(inputDestination.entryId)"
            } else {
                "adding into \(inputDestination.sectionId) on \(inputDestination.entryId)"
            }
        } else {
            nil
        }
        
        updateEntrySwitcherButtons()
    }
    
    @MainActor private func updateEntrySwitcherButtons() {
        let todayDate = dateFormatter.string(from: Date())
        
        nextButton = if entries.count > selectedEntryIndex + 1 {
            ButtonPresenter(
                title: entries[selectedEntryIndex + 1].date + " →",
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
                title: "← " + entries[selectedEntryIndex - 1].date,
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
        guard entries.count > selectedEntryIndex else { return }
        let entry = self.entries[selectedEntryIndex]
        let dest = ItemDestination(entryId: entry.date, sectionId: "")
        self.openInput(destination: dest)
    }
    
    private func openInputForLastSection() {
        guard entries.count > selectedEntryIndex else { return }
        let entry = self.entries[selectedEntryIndex]
        let sectionId = entry.sections.last?.id ?? "Breakfast"
        let dest = ItemDestination(entryId: entry.date, sectionId: sectionId)
        self.openInput(destination: dest)
    }
    
    private func openCalendar() {
        Task { @MainActor in
            self.calendarPresenter = Mapper.mapCalendar(
                entries: entries,
                dismissButton: ButtonPresenter(title: "Dismiss", action: { [weak self] in
                    guard let self else { return }
                    self.calendarPresenter = nil
                    self.updatePresenter()
                })
            )
            self.updatePresenter()
        }
    }
    
    /// if destination.sectionId is empty, input will request section name from the user
    private func openInput(destination: ItemDestination) {
        assert(!destination.entryId.isEmpty)
        
        let inputViewModel = InputViewModel(
            model: model,
            shouldInputSectionName: destination.sectionId == "",
            completeInput: { [weak self] item, sectionName in
                guard let self else { return }
                
                let destination = ItemDestination(
                    entryId: destination.entryId,
                    sectionId: sectionName ?? destination.sectionId
                )
                
                Task { @MainActor in
                    if let item {
                        do {
                            try await self.model.appendItem(item: item, destination: destination)
                            self.fetchEntries()
                        } catch {
                            Logger.main.error("\(error)")
                        }
                    }
                    
                    self.inputViewModel = nil
                    self.inputDestination = nil
                    self.updatePresenter()
                }
            }
        )
        
        Task { @MainActor in
            inputViewModel.setupInitialState()
            
            self.inputViewModel = inputViewModel
            self.inputDestination = destination
            self.updatePresenter()
        }
    }
}
