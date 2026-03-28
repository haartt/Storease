import SwiftUI
import PhotosUI

struct PhotoControlsCard: View {
    @Binding var selectedImage: UIImage?
    @Binding var isShowingCamera: Bool
    @State private var pickerItem: PhotosPickerItem?
    @State private var isShowingPhotoPicker = false
    @AppStorage("appAccentColor") private var appAccentColor: String = "yellow"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Photo")
                .font(.headline)
                .foregroundStyle(.primary)

            HStack(spacing: 12) {
                Menu {
                    Button {
                        presentPhotoLibrary()
                    } label: {
                        Label("Import from Gallery", systemImage: "photo.on.rectangle")
                    }

                    Button {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            isShowingCamera = true
                        } else {
                            #if targetEnvironment(simulator)
                            print("Camera not available in Simulator.")
                            #endif
                        }
                    } label: {
                        Label("Take Photo", systemImage: "camera")
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppColors.accent(from: appAccentColor))
                        Text(selectedImage == nil ? "Add Photo" : "Change Photo")
                            .foregroundStyle(AppColors.accent(from: appAccentColor))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .lightLiquidGlass()
                }

                if selectedImage != nil {
                    Button {
                        withAnimation(.snappy) {
                            selectedImage = nil
                        }
                    } label: {
                        Label("Remove", systemImage: "trash")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .liquidGlass()
        .photosPicker(
            isPresented: $isShowingPhotoPicker,
            selection: $pickerItem,
            matching: .images
        )
        .onChange(of: pickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    withAnimation(.snappy) {
                        selectedImage = image
                    }
                }
            }
        }
    }

    private func presentPhotoLibrary() {
        isShowingPhotoPicker = true
    }
}
