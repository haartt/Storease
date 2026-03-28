//
//  HeroCardView.swift
//  Storease
//
//  Created by Fabio Antonucci on 26/12/25.
//


import SwiftUI

struct HeroCardView: View {
    @Binding var isShowingCreateFlow: Bool
    @AppStorage("appAccentColor") private var appAccentColor: String = "yellow"
    
    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good morning"
        case 12..<18:
            return "Good afternoon"
        case 18..<21:
            return "Good evening"
        default:
            return "Good night"
        }
    }
    
    var body: some View {
        ZStack {
            // Transparent dark overlay that works in both light and dark mode
            RoundedRectangle(cornerRadius: 48, style: .continuous)
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
                    // Inner glow
                    RoundedRectangle(cornerRadius: 48, style: .continuous)
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
                            lineWidth: 2
                        )
                )
                .overlay(
                    // Outer subtle border
                    RoundedRectangle(cornerRadius: 48, style: .continuous)
                        .strokeBorder(
                            Color.white.opacity(0.15),
                            lineWidth: 1
                        )
                        .padding(1)
                )
                .shadow(color: .black.opacity(0.3), radius: 40, x: 0, y: 25)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                .compositingGroup()
                .drawingGroup()
            
            VStack(spacing: 28) {
                // Greeting
                VStack(alignment: .leading, spacing: 4) {
                    Text(timeBasedGreeting)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                // Call to action button
                Button {
                    isShowingCreateFlow = true
                } label: {
                    HStack(spacing: 10) {
                        Text("Create Story")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(
                        LinearGradient(
                            colors: [
                                AppColors.accent(from: appAccentColor),
                                AppColors.accent(from: appAccentColor).opacity(0.85)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: AppColors.accent(from: appAccentColor).opacity(0.5), radius: 15, y: 8)
                    .shadow(color: AppColors.accent(from: appAccentColor).opacity(0.3), radius: 8, y: 4)
                }
                .padding(.horizontal, 42)
                .padding(.top, 8)
                
                // Feature hints with icons
                HStack(spacing: 32) {
                    FeatureHintView(icon: "photo.on.rectangle", text: "Capture")
                    FeatureHintView(icon: "brain.head.profile", text: "Think")
                    FeatureHintView(icon: "text.book.closed", text: "Build")
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 32)
        }
    }
}
