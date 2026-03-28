//
//  MainFlowView.swift
//  Storease
//
//  Created by Fabio Antonucci on 11/12/25.
//

import SwiftUI
import SwiftData
import Vision
import UIKit

struct MainFlowView: View {
    @StateObject private var story = StoryModel()
    @State private var selectedImage: UIImage?
    @State private var tags: [String] = []
    @State private var initialDescription: String = ""
    @State private var continuationText: String = ""
    @State private var options: [String] = []
    @State private var selectedOption: String?
    @State private var isGenerating = false
    @State private var showContinuationField = false
    @State private var errorMessage: String?
    @State private var storyTitle: String = "" // NEW: user-provided story name
    @State private var showSavedBanner: Bool = false
    @State private var isCustomOptionSelected: Bool = false
    @State private var showNewStoryConfirmation: Bool = false

    @Environment(\.dismiss) private var dismiss

    // Camera presentation state
    @State private var isShowingCamera = false

    // Keyboard focus for the continuation field
    @FocusState private var isContinuationFocused: Bool
    
    @AppStorage("appAccentColor") private var appAccentColor: String = "yellow"


    @Environment(\.modelContext) private var modelContext
    @State private var savedStory: SavedStory?
    private let llmManager = OnDeviceLLMManager()

    var body: some View {
        NavigationStack {
            ZStack {
    
                VStack(spacing: 0) {
                    if showSavedBanner {
                        HStack(spacing: 8) {
                            Image(systemName: "books.vertical.fill")
                            Text("Story saved to your library")
                                .font(.subheadline)
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }

                    StoryEditorView(
                        story: story,
                        selectedImage: $selectedImage,
                        tags: $tags,
                        storyTitle: $storyTitle,
                        initialDescription: $initialDescription,
                        continuationText: $continuationText,
                        options: $options,
                        selectedOption: $selectedOption,
                        isGenerating: $isGenerating,
                        showContinuationField: $showContinuationField,
                        isShowingCamera: $isShowingCamera,
                        isCustomOptionSelected: $isCustomOptionSelected,
                        isContinuationFocused: $isContinuationFocused,
                        classifySelectedImage: classifySelectedImage,
                        handleInitialContinue: handleInitialContinue,
                        handleContinuationSubmit: handleContinuationSubmit
                    )
                    .onTapGesture {
                        isContinuationFocused = false
                    }
                    .padding(.top, showSavedBanner ? 4 : 0)
                }
            }
            // Dynamic title: fall back to "Create" until the user provides a name
            .navigationTitle(
                storyTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "Create"
                : storyTitle
            )
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let savedStory {
                        Text(savedStory.createdAt, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Button {
                            saveStory()
                        } label: {
                            Label("Save", systemImage: "square.and.arrow.down")
                        }
                        .disabled(story.steps.isEmpty)
                    }
                }
            }
            // Apply both tint (controls) and accentColor (for places using Color.accentColor)
            .tint(AppColors.accent(from: appAccentColor))
            .accentColor(AppColors.accent(from: appAccentColor))
            .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "")
            }
            .confirmationDialog(
                "Start a new story?",
                isPresented: $showNewStoryConfirmation,
                titleVisibility: .visible
            ) {
                Button("New Story", role: .destructive) { resetStory() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Your current draft will remain saved in the Library if you already saved it.")
            }
            // Present the camera full-screen when requested
            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraPicker(
                    selectedImage: $selectedImage,
                    isPresented: $isShowingCamera,
                    // No navigation in this flow; keep false
                    navigateToCatchView: .constant(false)
                )
            }
            .onChange(of: story.steps) {
                autosaveIfNeeded()
            }
            .onChange(of: storyTitle) {
                autosaveIfNeeded()
            }
            .onChange(of: tags) {
                autosaveIfNeeded()
            }
            .onChange(of: selectedImage) {
                autosaveIfNeeded()
            }
            .onChange(of: initialDescription) {
                autosaveIfNeeded()
            }
        }
    }

    private func handleInitialContinue() {
        story.reset()
        story.addStep(text: initialDescription)
        isCustomOptionSelected = false
        Task { await generateOptions() }
    }

    private func handleContinuationSubmit() {
        let text = continuationText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty == false else { return }

        if let selectedOption {
            // record the chosen LLM option as part of the story
            story.addStep(text: selectedOption)
        }

        story.addStep(text: text) // user continuation
        continuationText = ""
        selectedOption = nil
        isCustomOptionSelected = false
        withAnimation(.snappy) {
            showContinuationField = false
        }
        // Dismiss keyboard if still focused
        isContinuationFocused = false
        Task { await generateOptions() }
    }

    private func generateOptions() async {
        guard story.steps.isEmpty == false else { return }
        isGenerating = true
        isCustomOptionSelected = false
        do {
            options = try await llmManager.generateOptions(
                storySoFarText: story.combinedText,
                imageIdentifiers: tags
            )
        } catch {
            errorMessage = error.localizedDescription
            options = []
        }
        isGenerating = false
    }

    private func canResetStory() -> Bool {
        savedStory != nil ||
        story.steps.isEmpty == false ||
        storyTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ||
        initialDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ||
        tags.isEmpty == false ||
        selectedImage != nil
    }

    private func resetStory() {
        savedStory = nil
        story.reset()
        selectedImage = nil
        tags = []
        initialDescription = ""
        continuationText = ""
        options = []
        selectedOption = nil
        isCustomOptionSelected = false
        isGenerating = false
        showContinuationField = false
        errorMessage = nil
        storyTitle = ""
        withAnimation(.snappy) {
            showSavedBanner = false
        }
    }

    private func classifySelectedImage() async {
        #if targetEnvironment(simulator)
        errorMessage = "Image classification isn’t available in the Simulator. Please run on a device."
        return
        #else
        guard let selectedImage else { return }
        do {
            if let ciImage = CIImage(image: selectedImage) {
                let request = ClassifyImageRequest()
                let results = try await request.perform(on: ciImage)
                tags = results
                    .filter { $0.confidence > 0.05 }
                    .map { $0.identifier }
            }
        } catch {
            errorMessage = "Vision classification failed: \(error.localizedDescription)"
        }
        #endif
    }

    private func saveStory() {
        guard savedStory == nil else { return }
        // Prefer the user-provided title; otherwise fall back to first sentence
        let trimmedTitle = storyTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let derivedTitle = story.steps.first?.text.split(separator: ".").first.map(String.init) ?? "Untitled"
        let titleToSave = trimmedTitle.isEmpty ? derivedTitle : trimmedTitle
        let saved = SavedStory(
            title: titleToSave,
            body: story.combinedText,
            imageIdentifiers: tags,
            imageData: selectedImageData()
        )
        savedStory = saved
        modelContext.insert(saved)
        do {
            try modelContext.save()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                showSavedBanner = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    showSavedBanner = false
                }
            }
            NotificationCenter.default.post(name: .storySavedToLibrary, object: nil)
        } catch {
            errorMessage = "Could not save story: \(error.localizedDescription)"
        }
    }

    private func autosaveIfNeeded() {
        guard let savedStory else { return }

        let trimmedTitle = storyTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let derivedTitle = story.steps.first?.text.split(separator: ".").first.map(String.init) ?? "Untitled"
        let titleToSave = trimmedTitle.isEmpty ? derivedTitle : trimmedTitle

        savedStory.title = titleToSave
        savedStory.body = story.combinedText
        savedStory.imageIdentifiers = tags
        savedStory.imageData = selectedImageData()

        do {
            try modelContext.save()
        } catch {
            errorMessage = "Could not auto-save story: \(error.localizedDescription)"
        }
    }

    private func selectedImageData() -> Data? {
        guard let selectedImage else { return nil }
        return selectedImage.jpegData(compressionQuality: 0.8)
    }
}

extension Notification.Name {
    static let storySavedToLibrary = Notification.Name("storySavedToLibrary")
}


