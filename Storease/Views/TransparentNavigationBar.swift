import SwiftUI
import UIKit

/// Shared transparent navigation bar modifier used across the app
/// so the custom notebook background can show through.
struct TransparentNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .toolbarBackground(.hidden, for: .navigationBar)
        } else {
            content
                .onAppear {
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithTransparentBackground()
                    appearance.backgroundEffect = nil
                    appearance.backgroundColor = .clear
                    appearance.shadowColor = .clear
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
        }
    }
}

extension View {
    func transparentNavigationBar() -> some View {
        self.modifier(TransparentNavigationBar())
    }
}

