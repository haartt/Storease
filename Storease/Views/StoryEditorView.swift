import SwiftUI

/// Stateless view that renders the main story editing flow UI.
/// All state is owned by `MainFlowView` and passed in via bindings / callbacks.
struct StoryEditorView: View {
    @ObservedObject var story: StoryModel

    @Binding var selectedImage: UIImage?
    @Binding var tags: [String]
    @Binding var storyTitle: String
    @Binding var initialDescription: String
    @Binding var continuationText: String
    @Binding var options: [String]
    @Binding var selectedOption: String?
    @Binding var isGenerating: Bool
    @Binding var showContinuationField: Bool
    @Binding var isShowingCamera: Bool
    @Binding var isCustomOptionSelected: Bool
    var allowsStepEditing: Bool = false

    @FocusState<Bool>.Binding var isContinuationFocused: Bool

    @AppStorage("appAccentColor") private var appAccentColor: String = "yellow"

    let classifySelectedImage: () async -> Void
    let handleInitialContinue: () -> Void
    let handleContinuationSubmit: () -> Void

    private var primaryTextColor: Color { .primary }
    private var secondaryTextColor: Color { .secondary }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Story Name
                SectionCard(title: "Story Name") {
                    TextField("Enter a name for your story", text: $storyTitle)
                        .foregroundStyle(primaryTextColor)
                        .submitLabel(.done)
                        .padding(12)
                        .lightLiquidGlass()
                }

                // Photo controls + preview
                PhotoControlsCard(
                    selectedImage: $selectedImage,
                    isShowingCamera: $isShowingCamera // controlled by parent
                )

                StoryImageView(image: selectedImage)
                    .transition(.scale.combined(with: .opacity))

                // Inspiration
                SectionCard(title: "Inspiration") {
                    ImageInspirationView(
                        tags: $tags,
                        description: $initialDescription,
                        onClassify: classifySelectedImage,
                        onSave: handleInitialContinue
                    )
                }

                // Timeline (only if there are steps)
                if !story.steps.isEmpty {
                    SectionCard(title: "Story so far") {
                        if allowsStepEditing {
                            EditableStoryTimeline(story: story)
                        } else {
                            StoryTimeline(steps: story.steps)
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Options / Generation state
                SectionCard(title: "Next options") {
                    if isGenerating {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Generating next options…")
                                .foregroundStyle(secondaryTextColor)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    } else if options.isEmpty && story.steps.isEmpty == false {
                        Text("Tap Continue above to generate new branches.")
                            .foregroundStyle(secondaryTextColor)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(options, id: \.self) { option in
                                OptionCardView(
                                    title: option,
                                    action: {
                                        selectedOption = option
                                        isCustomOptionSelected = false
                                        withAnimation(.snappy) {
                                            showContinuationField = true
                                            // Bring up keyboard for continuation
                                            isContinuationFocused = true
                                        }
                                    },
                                    isSelected: option == selectedOption && isCustomOptionSelected == false,
                                    systemImage: "sparkles"
                                )
                            }

                            // Always offer a "write my own" branch.
                            OptionCardView(
                                title: "Write my own…",
                                action: {
                                    selectedOption = nil
                                    isCustomOptionSelected = true
                                    withAnimation(.snappy) {
                                        showContinuationField = true
                                        isContinuationFocused = true
                                    }
                                },
                                isSelected: isCustomOptionSelected,
                                systemImage: "pencil"
                            )
                        }
                    }
                }

                // Continue field
                if showContinuationField {
                    SectionCard(title: "Write your continuation") {
                        VStack(alignment: .leading, spacing: 8) {
                            if let selectedOption {
                                Text("Chosen direction: \(selectedOption)")
                                    .font(.subheadline)
                                    .foregroundStyle(secondaryTextColor)
                            }
                            TextField(
                                "Write the next part of the story…",
                                text: $continuationText,
                                axis: .vertical
                            )
                            .foregroundStyle(primaryTextColor)
                            .focused($isContinuationFocused)
                            .submitLabel(.done)
                            .padding(12)
                            .lightLiquidGlass()
                            .onSubmit {
                                // Dismiss keyboard on Done
                                isContinuationFocused = false
                            }

                            HStack {
                                Spacer()
                                Button {
                                    handleContinuationSubmit()
                                } label: {
                                    Label("Continue", systemImage: "arrow.right.circle.fill")
                                        .font(.headline)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AppColors.accent(from: appAccentColor))
                                .disabled(continuationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding()
            .animation(.snappy, value: isGenerating)
            .animation(.snappy, value: showContinuationField)
            .animation(.snappy, value: options)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

