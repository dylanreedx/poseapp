import AVFoundation
import CoreImage
import Photos

class FrameHandler: NSObject, ObservableObject {
    @Published var frame: CGImage?
    @Published var isRecording: Bool = false

    private var permissionGranted = false
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let context = CIContext()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let movieFileOutput = AVCaptureMovieFileOutput()
    private let albumName = "Pose App" // Your custom album name
    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            
        case .notDetermined:
            requestPermission()
            
        default:
            permissionGranted = false
        }
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            if self.permissionGranted {
                self.setupCaptureSession()
                self.captureSession.startRunning()
            } else {
                print("Camera access denied")
                // Handle denied camera access, e.g., display an alert
            }
        }
        PHPhotoLibrary.requestAuthorization { status in
            if status != .authorized {
                print("Photo library access denied")
                // Handle denied photo library access, e.g., display an alert
            }
        }
    }
    func setupCaptureSession() {
        guard permissionGranted else { return }
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera ,for: .video, position: .front) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        captureSession.beginConfiguration()
        captureSession.addInput(videoDeviceInput)
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)
        captureSession.addOutput(movieFileOutput)
        captureSession.commitConfiguration()
        videoOutput.connection(with: .video)?.videoRotationAngle = 90
        videoOutput.connection(with: .video)?.isVideoMirrored = true
        
        if let connection = movieFileOutput.connection(with: .video) {
            connection.isVideoMirrored = true
        }
        
        
    }
    
    func startRecording() {
        sessionQueue.async {
            guard !self.movieFileOutput.isRecording else { return }
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let outputFilePath = documentsDirectory.appendingPathComponent("output.mov").path
            
            if FileManager.default.fileExists(atPath: outputFilePath) {
                try? FileManager.default.removeItem(atPath: outputFilePath)
            }
            
            let fileURL = URL(fileURLWithPath: outputFilePath)
            self.movieFileOutput.startRecording(to: fileURL, recordingDelegate: self)
        }
        
        isRecording = true
    }
    
    func stopRecording() {
        sessionQueue.async {
            if self.movieFileOutput.isRecording {
                self.movieFileOutput.stopRecording()
            }
        }
        
        isRecording = false
    }
    
    private func saveToAlbum(outputFileURL: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Photo library access denied")
                return
            }
            
            self.getAlbum { album in
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                       let placeholder = assetChangeRequest?.placeholderForCreatedAsset {
                        albumChangeRequest.addAssets([placeholder] as NSArray)
                    }
                }) { success, error in
                    if let error = error {
                        print("Error saving video to album: \(error.localizedDescription)")
                    } else {
                        print("Video saved to album")
                    }
                }
            }
        }
    }
    
    private func getAlbum(completion: @escaping (PHAssetCollection) -> Void) {
        if let album = fetchAlbum() {
            completion(album)
        } else {
            createAlbum(completion: completion)
        }
    }
    
    private func fetchAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        return collection.firstObject
    }
    
    private func createAlbum(completion: @escaping (PHAssetCollection) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
        }) { success, error in
            if success {
                if let album = self.fetchAlbum() {
                    completion(album)
                }
            } else if let error = error {
                print("Error creating album: \(error.localizedDescription)")
            }
        }
    }
}

extension FrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        DispatchQueue.main.async { [unowned self] in
            self.frame = cgImage
        }
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        return cgImage
    }
}

extension FrameHandler: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording movie: \(error.localizedDescription)")
        } else {
            print("Movie recorded successfully to: \(outputFileURL)")
            saveToAlbum(outputFileURL: outputFileURL)
        }
    }
}
