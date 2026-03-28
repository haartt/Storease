///  StoriesView.swift
//  Storease
//
//  Created by Fabio Antonucci on 11/12/25.
//

import SwiftUI
import SwiftData
import UIKit

struct StoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedStory.createdAt, order: .reverse) private var stories: [SavedStory]

    @State private var storyToEdit: SavedStory?
    
    @AppStorage("appAccentColor") private var appAccentColor: String = "yellow"

    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    if stories.isEmpty {
                        ContentUnavailableView(
                            "No Saved Stories",
                            systemImage: "books.vertical",
                            description: Text("Your saved stories will appear here.")
                        )
                        .padding()
                        .foregroundStyle(.primary)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(stories) { story in
                                    NavigationLink(value: story) {
                                        StoryCardView(story: story, appAccentColor: appAccentColor)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .contextMenu {
                                        Button {
                                            storyToEdit = story
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        
                                        Button(role: .destructive) {
                                            if stories.firstIndex(where: { $0.id == story.id }) != nil {
                                                deleteStory(story)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            deleteStory(story)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        
                                        Button {
                                            storyToEdit = story
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(AppColors.accent(from: appAccentColor))
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    }
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: SavedStory.self) { story in
                StoryDetailView(story: story, onEdit: { storyToEdit = story })
            }
        }
        .foregroundStyle(.primary)
        .tint(AppColors.accent(from: appAccentColor))
        .sheet(item: $storyToEdit) { story in
            EditStoryFlowView(savedStory: story)
        }
    }

    private func deleteStory(_ story: SavedStory) {
        modelContext.delete(story)
        try? modelContext.save()
    }

    private func deleteStories(at offsets: IndexSet) {
        let storiesToDelete = offsets.map { stories[$0] }
        for story in storiesToDelete {
            modelContext.delete(story)
        }
        try? modelContext.save()
    }
}

// Extracted card view for better organization

// Enhanced detail view

#Preview {
    StoriesView()
        .modelContainer(for: SavedStory.self, inMemory: true)
}
