import Photos

class AlbumManager: NSObject, ObservableObject {
    let albumName = "Pose App" // Your custom album name

    @Published var videos: [PHAsset] = []

    func fetchAlbumVideos() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized, .limited:
                self?.getAlbum { album in
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

                    let assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
                    DispatchQueue.main.async {
                        self?.videos = assets.objects(at: IndexSet(0..<assets.count))
                    }
                }
            case .denied:
                print("Access denied")
            case .restricted:
                print("Access restricted")
            case .notDetermined:
                print("Access not determined")
            @unknown default:
                print("Unknown authorization status")
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
