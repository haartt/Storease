//
//  StoryModel.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 30/11/25.
//

import Foundation
import Combine

final class StoryModel: ObservableObject {
    @Published private(set) var steps: [StoryStep] = []

    var combinedText: String {
        steps.map { $0.text }.joined(separator: "\n\n")
    }

    func addStep(text: String) {
        guard text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else { return }
        steps.append(StoryStep(text: text))
    }

    func updateStep(id: UUID, text: String) {
        guard let index = steps.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        steps[index].text = trimmed
    }

    func reset() {
        steps.removeAll()
    }
}
