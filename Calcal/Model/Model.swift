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
    
    /// load data once, update locally, never save to backend
    private static let TEST_DATA_CHANGES_LOCALLY = false

    private var data: [EntryEntity] = []
    
    func appendItem(item: EntryEntity.Item, destination: ItemDestination) async throws {
        assert(!destination.entryId.isEmpty)
        assert(!destination.sectionId.isEmpty)
        
        guard var entry = getAllEntries().first(where: { $0.date == destination.entryId }) else { return }
        
        if entry.sections.firstIndex(where: { $0.id == destination.sectionId }) == nil {
            entry.sections.append(EntryEntity.Section(id: destination.sectionId, items: []))
        }
        
        guard let sectionIndex = entry.sections.firstIndex(where: { $0.id == destination.sectionId })
        else { return assertionFailure("the section must have been added") }
        
        entry.sections[sectionIndex].items.append(item)
        
        try await addOrUpdateEntry(entry: entry)
        try await saveModel()
    }
    
    func addOrUpdateEntry(entry: EntryEntity) async throws {
        if let entryIndex = data.firstIndex(where: { $0.date == entry.date }) {
            data[entryIndex] = entry
        } else {
            data.append(entry)
        }
        try await saveModel()
    }
    
    func getAllEntries() -> [EntryEntity] {
        data
    }
    
    // MARK: - Work with Storage
    
    private let apiUrl = URL(string: "https://whoniverse-app.com/calcal/main.php")!
    
    func fetchModel() async throws {
        if Self.TEST_DATA_CHANGES_LOCALLY {
            // loads data once
            if !self.data.isEmpty { return }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: apiUrl)
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
            guard statusCode == 200, let contents = String(data: data, encoding: .utf8)
            else { throw Error.invalidResponse(code: statusCode) }
            
            let entities = try Parser(text: contents).parse()
            self.data = entities
        } catch {
            Logger.main.error("Model: loadModel: \(error)")
        }
    }
    
    private func saveModel() async throws {
        if Self.TEST_DATA_CHANGES_LOCALLY {
            return
        }
        
        let content = data
            .map(Mapper.map(entity:))
            .map(Mapper.map(representation:))
            .joined(separator: "\n\n")
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"text.txt\"\r\n")
        body.append("Content-Type: text/plain\r\n\r\n")
        body.append(content)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: body)
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
        guard statusCode == 200 else { throw Error.invalidResponse(code: statusCode) }
    }
    
    enum Error: Swift.Error {
        case invalidResponse(code: Int)
    }
}

struct ItemDestination {
    let entryId: String
    let sectionId: String
}

private extension Data {
    mutating func append(_ value: String) {
        guard let stringData = value.data(using: .utf8) else { return }
        
        stringData.withUnsafeBytes { bytes in
            self.append(contentsOf: bytes)
        }
    }
}
