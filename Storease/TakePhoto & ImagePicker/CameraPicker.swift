import SwiftUI
import AVFoundation
import UIKit
import Combine

struct CameraPicker: View {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    @Binding var navigateToCatchView: Bool
    
    @State private var cameraManager = CameraManager()
    @State private var capturedImage: UIImage?
    @State private var showPreview = false
    @State private var permissionDenied = false
    
    var body: some View {
        ZStack {
            // Camera preview layer - fills entire screen
            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea(.all)
                .background(Color.black)
            
            if permissionDenied {
                // Permission denied message
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.white.opacity(0.6))
                    Text("Camera access is required")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Please enable camera access in Settings")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    Button {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    } label: {
                        Text("Open Settings")
                            .foregroundStyle(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            
            // Overlay UI
            VStack {
                // Top bar with cancel button
                HStack {
                    Button {
                        cameraManager.stopSession()
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding()
                .padding(.top, 8)
                
                Spacer()
                
                // Bottom controls
                if !permissionDenied {
                    VStack(spacing: 20) {
                        // Capture button
                        Button {
                            cameraManager.capturePhoto { image in
                                if let image = image {
                                    capturedImage = image
                                    selectedImage = image
                                    navigateToCatchView = true
                                    cameraManager.stopSession()
                                    isPresented = false
                                }
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 70, height: 70)
                                Circle()
                                    .stroke(.black, lineWidth: 4)
                                    .frame(width: 64, height: 64)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .background(Color.black)
        .onAppear {
            cameraManager.checkPermissionAndStartSession { denied in
                permissionDenied = denied
            }
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
}

// MARK: - Camera Manager

class CameraManager {
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var photoCaptureDelegate: PhotoCaptureDelegate?
    
    @MainActor
    func checkPermissionAndStartSession(completion: ((Bool) -> Void)? = nil) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
            completion?(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupSession()
                        completion?(false)
                    } else {
                        completion?(true)
                    }
                }
            }
        default:
            completion?(true)
        }
    }
    
    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoDeviceInput),
              session.canAddOutput(photoOutput) else {
            session.commitConfiguration()
            return
        }
        
        session.addInput(videoDeviceInput)
        self.videoDeviceInput = videoDeviceInput
        
        session.addOutput(photoOutput)
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings: AVCapturePhotoSettings
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            settings = AVCapturePhotoSettings()
        }
        
        let delegate = PhotoCaptureDelegate { [weak self] image in
            self?.photoCaptureDelegate = nil
            completion(image)
        }
        photoCaptureDelegate = delegate
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
    
    @MainActor
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }
}

// MARK: - Photo Capture Delegate

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            completion(nil)
            return
        }
        completion(image)
    }
}

// MARK: - Camera Preview View

struct CameraPreviewView: UIViewControllerRepresentable {
    let session: AVCaptureSession
    
    func makeUIViewController(context: Context) -> CameraPreviewViewController {
        let controller = CameraPreviewViewController()
        controller.session = session
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraPreviewViewController, context: Context) {}
}

class CameraPreviewViewController: UIViewController {
    var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if previewLayer == nil, let session = session {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.insertSublayer(previewLayer, at: 0)
            self.previewLayer = previewLayer
        } else {
            previewLayer?.frame = view.bounds
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.previewLayer?.frame = CGRect(origin: .zero, size: size)
        })
    }
}
