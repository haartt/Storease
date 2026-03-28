import SwiftUI

struct StoryTimeline: View {
    let steps: [StoryStep]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(steps) { step in
                Text(step.text)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .lightLiquidGlass()
            }
        }
        .padding(.vertical, 4)
    }
}

