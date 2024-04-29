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
    
    func appendItem(item: EntryEntity.Item, destination: ItemDestination) {
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
    
    func saveModel() {
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
            .joined(separator: "\n")
        
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            Logger().error("\(error.localizedDescription)")
        }
    }
    
    func getAllEntries() -> [EntryEntity] {
        data
    }
}

struct ItemDestination {
    let entryId: String
    let sectionId: String
}

struct Mapper {
    
    static func measurementDisplayValue(item: EntryEntity.Item) -> String {
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
    
    static func map(entity: EntryEntity) -> EntryRepresentation {
        var entryText = ""
        var totalCalories: Float = 0
        
        for section in entity.sections {
            var itemsText = ""
            var sectionCalories: Float = 0
            
            for item in section.items {
                itemsText.append("- \(item.title), \(Self.measurementDisplayValue(item: item)), \(item.calories.formatted(.number.rounded())) kcal\n")
                sectionCalories += item.calories
            }
            
            entryText.append("\(section.id) - \(sectionCalories.formatted(.number.rounded())) kcal\n\(itemsText)\n")
            totalCalories += sectionCalories
        }
        
        return EntryRepresentation(
            date: entity.date.uppercased(),
            text: entryText.trimmingCharacters(in: .whitespacesAndNewlines),
            total: "Total: \(totalCalories.formatted(.number.rounded().grouping(.never))) kcal"
        )
    }
    
    static func map(representation: EntryRepresentation) -> String {
"""
\(representation.date)

\(representation.text)

\(representation.total)
"""
    }
}
