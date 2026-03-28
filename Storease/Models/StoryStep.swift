//
//  StoryContinuation.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 30/11/25.
//

import Foundation

struct StoryStep: Identifiable, Codable, Hashable {
    let id: UUID
    let createdAt: Date
    var text: String

    init(id: UUID = UUID(), createdAt: Date = Date(), text: String) {
        self.id = id
        self.createdAt = createdAt
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
