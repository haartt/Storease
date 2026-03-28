import SwiftUI

// MARK: - Recent Story Card Component
struct RecentStoryCard: View {
    let story: SavedStory
    let onTap: () -> Void
    
    private var previewText: String {
        let text = story.body
        let words = text.split(separator: " ").prefix(6)
        let preview = words.joined(separator: " ")
        return preview + (words.count >= 6 ? "..." : "")
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // Transparent dark overlay card
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.4),
                                Color.black.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // Subtle blur effect
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.ultraThinMaterial.opacity(0.3))
                    )
                    .overlay(
                        // Inner glow
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.3),
                                        .white.opacity(0.1),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .overlay(
                        // Outer subtle border
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(
                                Color.white.opacity(0.15),
                                lineWidth: 1
                            )
                            .padding(1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Story thumbnail (if available)
                if let imageData = story.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            // Dark gradient overlay for text readability
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .black.opacity(0.7)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(story.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    
                    Text(previewText)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(3)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Color.black.opacity(0.40)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .alignmentGuide(.bottom) { d in d[.bottom] }
                        .blur(radius: 40)
                )
                .padding(.bottom, 12)
            }
            .frame(width: 200, height: 260)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    RecentStoryCard(story: SavedStory(
        title: "My Adventure",
        body: "Once upon a time in a magical forest, there lived a brave young hero who...",
        imageIdentifiers: [], imageData: UIImage(named: "Image")?.pngData()
    )) {
        print("Card tapped")
    }
    .padding()
    .background(Color.black)
}
