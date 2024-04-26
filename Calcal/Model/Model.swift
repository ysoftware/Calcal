//
//  Model.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 16.04.24.
//

import Foundation
import OSLog

class Model {
    
    private var data: [EntryEntity] = []
    
    init() {
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
            Logger().error("\(error.localizedDescription)")
        }
    }
    
    func appendItemToLastEntry(item: EntryEntity.Item, sectionId: EntryEntity.SectionId) {
        guard var entry = getAllEntries().last else { return }
        
        if entry.sections.firstIndex(where: { $0.id == sectionId }) == nil {
            entry.sections.append(EntryEntity.Section(id: sectionId, items: []))
        }
        
        guard let sectionIndex = entry.sections.firstIndex(where: { $0.id == sectionId })
        else { return assertionFailure("the section must have been added") }
        
        entry.sections[sectionIndex].items.append(item)
        addOrUpdateEntry(entry: entry)
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
}
