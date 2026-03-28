import SwiftUI

/// Editable timeline for story steps (used in Edit flow).
/// Uses multiline `TextField(axis: .vertical)` to avoid nested scrolling issues.
struct EditableStoryTimeline: View {
    @ObservedObject var story: StoryModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(story.steps) { step in
                VStack(alignment: .leading, spacing: 8) {
                    Text("Step \(index(of: step) + 1)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField(
                        "Write…",
                        text: Binding(
                            get: { step.text },
                            set: { story.updateStep(id: step.id, text: $0) }
                        ),
                        axis: .vertical
                    )
                    .lineLimit(1...12)
                    .padding(12)
                    .lightLiquidGlass()
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func index(of step: StoryStep) -> Int {
        story.steps.firstIndex(where: { $0.id == step.id }) ?? 0
    }
}


