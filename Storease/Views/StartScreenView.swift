// StartScreenView.swift
import SwiftUI
import _SwiftData_SwiftUI

struct StartScreenView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedStory.createdAt, order: .reverse) private var allStories: [SavedStory]
    
    @State private var showFileBrowser = true
    @State private var selectedDetent: PresentationDetent = .medium
    @State private var storyToEdit: SavedStory?
    @State private var isShowingCreateFlow = false
    
    private var recentStories: [SavedStory] {
        Array(allStories.prefix(6))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                
                ScrollView {
                    LazyVStack(spacing: 32) {
                        Spacer()
                        
                        HeroCardView(isShowingCreateFlow: $isShowingCreateFlow)
                            .frame(maxWidth: 480)
                            .padding(.horizontal, 24)
                        
                        RecentStoriesView(stories: recentStories) { story in
                            storyToEdit = story
                        }
                        
                        Spacer()
                            .frame(height: 100)
                    }
                }
                .scrollIndicators(.hidden)
            }
            
            .navigationTitle("Storease")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $storyToEdit) { story in
                EditStoryFlowView(savedStory: story)
            }
            .fullScreenCover(isPresented: $isShowingCreateFlow) {
                MainFlowView()
            }
            
            .onAppear {
                showFileBrowser = true
            }
        }
    }
}

#Preview {
    StartScreenView()
        .modelContainer(for: SavedStory.self, inMemory: true)
}


// HeroCardView.swift

