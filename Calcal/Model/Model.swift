//
//  Model.swift
//  Calcal
//
//  Created by Iaroslav Erokhin on 16.04.24.
//

import Foundation

class Model {
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
        if let entryIndex = mockEntries.firstIndex(where: { $0.date == entry.date }) {
            mockEntries[entryIndex] = entry
        } else {
            mockEntries.append(entry)
        }
    }
    
    func getAllEntries() -> [EntryEntity] {
        mockEntries
    }
}

var mockEntries: [EntryEntity] = []
