import SwiftUI

enum AppColors {
    /// Main brand / accent color (dynamic based on user setting).
    static func accent(from key: String) -> Color {
        switch key {
        case "yellow":
            return Color(red: 0.80, green: 0.65, blue: 0.20)
        case "blue":
            return Color(red: 0.25, green: 0.50, blue: 0.90)
        case "liliac":
            return Color(red: 0.60, green: 0.45, blue: 0.85)
        case "orange":
            return Color(red: 0.90, green: 0.55, blue: 0.20)
        case "red":
            return Color(red: 0.85, green: 0.35, blue: 0.35)
        case "green":
            return Color(red: 0.25, green: 0.85, blue: 0.45)
        default:
            return Color(red: 0.80, green: 0.65, blue: 0.20)
        }
    }
    
    /// Background tones for a warmer notebook feel.
    static let lightBackgroundTop = Color(red: 0.97, green: 0.96, blue: 0.93)
    static let lightBackgroundBottom = Color(red: 0.91, green: 0.89, blue: 0.84)
    
    static let darkBackgroundTop = Color(red: 0.16, green: 0.13, blue: 0.11)
    static let darkBackgroundBottom = Color(red: 0.06, green: 0.05, blue: 0.05)
    
    /// Secondary text color used for subtitles, placeholders, and de-emphasized content.
    static let primaryText = Color.primary
    static let secondaryText = Color.primary

    /// Card background color for surfaces like story cards and list rows.
    static let cardBackground = Color.primary.opacity(0.9)
}
