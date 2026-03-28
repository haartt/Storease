//
//  StoryDetailView.swift
//  Storease
//
//  Created by Fabio Antonucci on 27/12/25.
//


import SwiftUI
import SwiftData
import UIKit

struct StoryDetailView: View {
    let story: SavedStory
    var onEdit: () -> Void
    @AppStorage("appAccentColor") private var appAccentColor: String = "yellow"
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Hero Image Section
                if let data = story.imageData, let uiImage = UIImage(data: data) {
                    StoryImageView(image: uiImage)
                }
                
                // Content Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Story")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    JustifiedDropCapText(
                        text: story.body,
                        dropCapFont: .custom("Times New Roman", size: 36),
                        bodyFont: .system(size: 16, weight: .regular)
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity) // ensures width
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.primary.opacity(0.04))
                )
                
                // Action Buttons
                VStack(spacing: 10) {
                    Button {
                        onEdit()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 22))
                            
                            Text("Edit Story")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppColors.accent(from: appAccentColor))
                        )
                    }
                    
                    Button {
                        showShareSheet = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                            
                            Text("Share Story")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                            
                            Spacer()
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.primary.opacity(0.06))
                        )
                    }
                }
                
                // Metadata
                let createdAt = story.createdAt
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13))
                    
                    Text("Created \(createdAt.formatted(date: .long, time: .omitted))")
                        .font(.system(size: 14, design: .rounded))
                }
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .navigationTitle(story.title)
        .navigationBarTitleDisplayMode(.large)
        .foregroundStyle(.primary)
        .tint(AppColors.accent(from: appAccentColor))
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareText])
        }
    }
    
    private var shareText: String {
        """
        \(story.title)
        
        \(story.body)
        """
    }
}

// Share Sheet Helper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#if DEBUG
struct StoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleStory = SavedStory(
            createdAt: Date(), title: "Sample Story Title",
            body: "This is a preview of a story's body. It can be several sentences long and demonstrates how the text will appear in the detail view.",
            imageIdentifiers: ["dog"], imageData: nil
        )
        StoryDetailView(story: sampleStory, onEdit: {})
    }
}
#endif

