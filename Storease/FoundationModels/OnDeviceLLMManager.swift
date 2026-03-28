import Foundation
import FoundationModels
import Combine
import SwiftUI

enum StoryResponseType: String {
    case concise
    case detailed
    case humorous
}

enum OnDeviceLLMManagerError: Error, LocalizedError {
    case modelNotAvailable
    case sessionBusy
    case noOptions

    var errorDescription: String? {
        switch self {
        case .modelNotAvailable: return "On-device model is not available."
        case .sessionBusy: return "Model is already responding. Please wait."
        case .noOptions: return "Could not generate options."
        }
    }
}

final class OnDeviceLLMManager: ObservableObject {
    @Published var isResponding = false

    private let model = SystemLanguageModel.default
    private var session: LanguageModelSession?

    private var isModelAvailable: Bool { model.availability == .available }

    @AppStorage("storyResponseType") private var storyResponseType: String = StoryResponseType.concise.rawValue

    func checkModelAvailability() -> (Bool, String) {
        switch model.availability {
        case .available: return (true, "On-device model is available.")
        case .unavailable(.deviceNotEligible): return (false, "Device not eligible for on-device model.")
        case .unavailable(.appleIntelligenceNotEnabled): return (false, "Apple Intelligence not enabled.")
        case .unavailable(.modelNotReady): return (false, "Model not ready.")
        case .unavailable(let other): return (false, "On-device model unavailable: \(other).")
        }
    }

    private func masterPrompt() -> String {
        switch StoryResponseType(rawValue: storyResponseType) ?? .concise {
        case .concise:
            return """
            You are a professional storytelling assistant.
            - Always continue the story logically.
            - Use short sentences (1–2).
            - Stay inspired by image identifiers.
            - Avoid complicated words.
            - Give branching options clearly different from each other.
            """
        case .detailed:
            return """
            You are a professional storytelling assistant.
            - Expand each step with rich details.
            - Include setting, character thoughts, and actions.
            - Use full sentences with varied structure.
            - Make branching options vivid and imaginative.
            """
        case .humorous:
            return """
            You are a professional storytelling assistant.
            - Continue the story with a humorous tone.
            - Include funny twists or playful dialogue.
            - Keep sentences clear but entertaining.
            - Branching options should be amusing and different.
            """
        }
    }

    func generateOptions(storySoFarText: String, imageIdentifiers: [String]) async throws -> [String] {
        guard isModelAvailable else { throw OnDeviceLLMManagerError.modelNotAvailable }

        let currentSession: LanguageModelSession
        if let session {
            guard session.isResponding == false else { throw OnDeviceLLMManagerError.sessionBusy }
            currentSession = session
        } else {
            currentSession = LanguageModelSession()
            self.session = currentSession
        }

        let identifiersText = imageIdentifiers.joined(separator: ", ")

        let baseInfo = """
Story so far:
\(storySoFarText)

Image identifiers:
\(identifiersText)
"""

        let prompt1 = """
\(masterPrompt())

You are generating the next step of a branching story. Produce ONE short suggestion (1–2 sentences) that continues the story and is inspired by the image identifiers. Keep it concise and concrete. Don't use complicated words.

\(baseInfo)
"""

        let prompt2 = """
\(masterPrompt())

You are generating a DIFFERENT branch of the story. Produce ONE short suggestion (1–2 sentences) that continues the story in a clearly different direction than the first suggestion. Still stay inspired by the image identifiers. Don't use complicated words.

\(baseInfo)
"""

        isResponding = true
        let response1 = try await currentSession.respond(to: prompt1)
        let option1 = response1.content
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let response2 = try await currentSession.respond(to: prompt2)
        let option2 = response2.content
            .trimmingCharacters(in: .whitespacesAndNewlines)
        isResponding = false

        guard option1.isEmpty == false, option2.isEmpty == false else {
            throw OnDeviceLLMManagerError.noOptions
        }

        return [option1, option2]
    }
}
