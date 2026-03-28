//
//  StoryCardView.swift
//  Storease
//
//  Created by Fabio Antonucci on 27/12/25.
//


import SwiftUI
import UIKit

struct StoryCardView: View {
    let story: SavedStory
    let appAccentColor: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.primary.opacity(0.05))
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)

            HStack(spacing: 16) {
                if let data = story.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.primary.opacity(0.08))
                        .frame(width: 70, height: 70)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundStyle(.secondary)
                        }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(story.title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text(story.body)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 8)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
        }
    }
}

#Preview {
    StoryCardView(
        story: SavedStory(title: "Sample", body: "Preview text", imageIdentifiers: [], imageData: nil),
        appAccentColor: "yellow"
    )
}