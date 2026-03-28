import SwiftUI

struct NotebookBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Group {
            if colorScheme == .light {
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.94, blue: 0.85),
                        Color(red: 0.94, green: 0.88, blue: 0.72),
                        Color(red: 0.90, green: 0.82, blue: 0.62)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.42, green: 0.30, blue: 0.20),
                        Color(red: 0.32, green: 0.22, blue: 0.15),
                        Color(red: 0.22, green: 0.15, blue: 0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .ignoresSafeArea(.all)
    }
}


#Preview {
    NotebookBackground()
}
