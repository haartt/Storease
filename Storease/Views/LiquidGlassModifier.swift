import SwiftUI

/// Liquid glass effect modifier similar to tab bars - darker, more opaque material with subtle borders
struct LiquidGlassModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(.regularMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        colorScheme == .dark 
                            ? Color.white.opacity(0.1) 
                            : Color.black.opacity(0.08),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: colorScheme == .dark ? .black.opacity(0.4) : .black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

extension View {
    /// Applies a liquid glass effect similar to tab bars
    func liquidGlass() -> some View {
        modifier(LiquidGlassModifier())
    }
}

/// Lighter liquid glass for nested elements
struct LightLiquidGlassModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(.thinMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        colorScheme == .dark 
                            ? Color.white.opacity(0.08) 
                            : Color.black.opacity(0.06),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}

extension View {
    /// Applies a lighter liquid glass effect for nested elements
    func lightLiquidGlass() -> some View {
        modifier(LightLiquidGlassModifier())
    }
}
