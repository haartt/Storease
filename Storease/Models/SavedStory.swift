//
//  PersistentStory.swift
//  StoryCatch
//
//  Created by AI on 03/12/25.
//

import Foundation
import SwiftData

@Model
final class SavedStory {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var title: String
    var body: String
    var imageIdentifiers: [String]
    var imageData: Data? // Optional stored image for thumbnail/detail

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        title: String,
        body: String,
        imageIdentifiers: [String],
        imageData: Data? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.body = body
        self.imageIdentifiers = imageIdentifiers
        self.imageData = imageData
    }
}
