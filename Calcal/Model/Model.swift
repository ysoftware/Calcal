//
//  Model.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 16.04.24.
//

import Foundation
import OSLog

struct EntryRepresentation {
    let date: String
    let text: String
    let total: String
}

class Model {
    
    private var data: [EntryEntity] = []
    
    init() {
        loadModel()
    }
    
    func appendItem(item: EntryEntity.Item, destination: ItemDestination) {
        assert(!destination.entryId.isEmpty)
        assert(!destination.sectionId.isEmpty)
        
        guard var entry = getAllEntries().first(where: { $0.date == destination.entryId }) else { return }
        
        if entry.sections.firstIndex(where: { $0.id == destination.sectionId }) == nil {
            entry.sections.append(EntryEntity.Section(id: destination.sectionId, items: []))
        }
        
        guard let sectionIndex = entry.sections.firstIndex(where: { $0.id == destination.sectionId })
        else { return assertionFailure("the section must have been added") }
        
        entry.sections[sectionIndex].items.append(item)
        addOrUpdateEntry(entry: entry)
        
        saveModel()
    }
    
    func addOrUpdateEntry(entry: EntryEntity) {
        if let entryIndex = data.firstIndex(where: { $0.date == entry.date }) {
            data[entryIndex] = entry
        } else {
            data.append(entry)
        }
    }
    
    func getAllEntries() -> [EntryEntity] {
        data
    }
    
    // MARK: - Work with Storage
    
    private func loadModel() {
        do {
            guard let documentsUrl = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first else { return }
            
            let url = documentsUrl
                .appendingPathComponent("Other")
                .appendingPathComponent("Calcal-data.txt")
            
            let contents = try String(contentsOf: url, encoding: .utf8)
            let entities = try Parser(text: contents).parse()
            self.data = entities
        } catch {
            logger.error("Model: init: \(error)")
            resetToInitialFile()
        }
    }
    
    private func resetToInitialFile() {
        do {
            guard let url = Bundle.main.url(forResource: "data", withExtension: "txt") else { return }
            let contents = try String(contentsOf: url)
            let entities = try Parser(text: contents).parse()
            self.data = entities
            saveModel()
        } catch {
            logger.error("Model: resetToInitialFile: \(error)")
        }
    }
    
    private func saveModel() {
        guard let documentsUrl = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else { return }
        
        let url = documentsUrl
            .appendingPathComponent("Other")
            .appendingPathComponent("Calcal-data.txt")
        
        let content = data
            .map(Mapper.map(entity:))
            .map(Mapper.map(representation:))
            .joined(separator: "\n\n")
        
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            logger.error("Model: saveModel: \(error)")
        }
    }
}

struct ItemDestination {
    let entryId: String
    let sectionId: String
}

let logger = Logger(subsystem: "app", category: "main")
