//
//  RecentStoriesView.swift
//  Storease
//
//  Created by Fabio Antonucci on 25/12/25.
//

import SwiftUI

struct RecentStoriesView: View {
    let stories: [SavedStory]
    let onStoryTap: (SavedStory) -> Void
    
    var body: some View {
        ZStack {
            // Glass shell identical to main card
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
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Recent stories")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
                
                if stories.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 64))
                            .foregroundStyle(.white.opacity(0.35))
                        Text("No stories in here")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, minHeight: 400)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(stories) { story in
                                RecentStoryCard(story: story) {
                                    onStoryTap(story)
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 40, style: .continuous)
                                .fill(Color.clear)
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: 40, style: .continuous)
                        )
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 46, style: .continuous))
        .frame(maxWidth: 480)
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
}

#Preview {
    RecentStoriesView(
        stories: [
            SavedStory(
                id: UUID(),
                createdAt: Date(),
                title: "My Adventure",
                body: "Once upon a time in a magical forest, there lived a brave young hero.",
                imageIdentifiers: []
            ),
            SavedStory(
                id: UUID(),
                createdAt: Date(),
                title: "The Mystery",
                body: "It was a dark and stormy night when everything changed forever.",
                imageIdentifiers: []
            ),
            SavedStory(
                id: UUID(),
                createdAt: Date(),
                title: "Journey Beyond",
                body: "In the depths of space, explorers discovered something incredible and amazing.",
                imageIdentifiers: []
            )
        ]
    ) { story in
        print("Tapped: \(story.title)")
    }
    .background(Color.black)
}
