import SwiftUI
import SwiftData
import UIKit
import Vision

/// Entry point for editing an existing `SavedStory`.
/// This wraps `StoryEditorView` but preloads the content from the persisted model
/// and keeps the binding between edits and the underlying `SavedStory`.
struct EditStoryFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var story = StoryModel()
    
    @AppStorage("appAccentColor") private var appAccentColor: String = "yellow"
    
    @State private var selectedImage: UIImage?
    @State private var tags: [String] = []
    @State private var initialDescription: String = ""
    @State private var continuationText: String = ""
    @State private var options: [String] = []
    @State private var selectedOption: String?
    @State private var isCustomOptionSelected: Bool = false
    @State private var isGenerating = false
    @State private var showContinuationField = false
    @State private var errorMessage: String?
    @State private var storyTitle: String = ""
    @State private var isShowingCamera: Bool = false
    
    @FocusState private var isContinuationFocused: Bool
    
    let savedStory: SavedStory
    private let llmManager = OnDeviceLLMManager()
    
    init(savedStory: SavedStory) {
        self.savedStory = savedStory
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                
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
                    allowsStepEditing: true,
                    isContinuationFocused: $isContinuationFocused,
                    classifySelectedImage: classifySelectedImage,
                    handleInitialContinue: handleInitialContinue,
                    handleContinuationSubmit: handleContinuationSubmit
                )
                .onTapGesture {
                    isContinuationFocused = false
                }
            }
            .navigationTitle(
                storyTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "Edit Story"
                : storyTitle
            )
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveEdits()
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "checkmark.circle.fill")
                    }
                }
            }
            .tint(AppColors.accent(from: appAccentColor))
            .accentColor(AppColors.accent(from: appAccentColor))
            .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "")
            }
            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraPicker(
                    selectedImage: $selectedImage,
                    isPresented: $isShowingCamera,
                    navigateToCatchView: .constant(false)
                )
            }
            .onAppear {
                preloadFromSavedStory()
            }
        }
    }
    
    // MARK: - Preload existing story
    
    private func preloadFromSavedStory() {
        story.reset()
        
        storyTitle = savedStory.title
        tags = savedStory.imageIdentifiers
        
        if let data = savedStory.imageData, let uiImage = UIImage(data: data) {
            selectedImage = uiImage
        }
        
        let paragraphs = savedStory.body
            .components(separatedBy: "\n\n")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        for paragraph in paragraphs {
            story.addStep(text: paragraph)
        }
        
        if let first = paragraphs.first {
            initialDescription = first
        }
    }
    
    // MARK: - Actions
    
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
            story.addStep(text: selectedOption)
        }
        
        story.addStep(text: text)
        continuationText = ""
        selectedOption = nil
        isCustomOptionSelected = false
        withAnimation(.snappy) {
            showContinuationField = false
        }
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
    
    private func saveEdits() {
        let trimmedTitle = storyTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let derivedTitle = story.steps.first?.text.split(separator: ".").first.map(String.init) ?? "Untitled"
        let titleToSave = trimmedTitle.isEmpty ? derivedTitle : trimmedTitle
        
        savedStory.title = titleToSave
        savedStory.body = story.combinedText
        savedStory.imageIdentifiers = tags
        savedStory.imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Could not save edits: \(error.localizedDescription)"
        }
    }
}

// MARK: - Preview
#Preview {
    // Create a temporary in-memory SwiftData container for preview
    let schema = Schema([SavedStory.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = container.mainContext

    // Seed a sample SavedStory
    let sample = SavedStory(
        title: "Sample Story",
        body: "It was a dark and stormy night.\n\nA door creaked open.",
        imageIdentifiers: ["night", "storm"],
        imageData: nil
    )
    context.insert(sample)

    return EditStoryFlowView(savedStory: sample)
        .modelContainer(container)
}


