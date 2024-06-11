//

import Foundation
import AVFoundation
import Photos

class VideoRecorder {
    let customAlbum: PHAssetCollection?

    init() {
        createCustomAlbum()
    }

    func createCustomAlbum() {
        // Create a custom album
        let albumTitle = "My App Videos"
        var album: PHAssetCollection?
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumTitle)

        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let firstObject = fetchResult.firstObject {
            album = firstObject
        } else {
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumTitle).execute({ [weak self] success, error in
                if success {
                    print("Custom album created successfully")
                    self?.customAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject
                } else {
                    print("Error creating custom album: $$error?.localizedDescription ?? "")")
                }
            })
        }
    }

    func saveVideoToCustomAlbum(videoURL: URL) {
        // Save the video to the custom album
        PHAssetChangeRequest.creationRequestForAsset(from: videoURL).execute({ [weak self] success, error in
            if success {
                let asset = PHAsset.fetchAssets(with: .video, options: nil).firstObject
                PHAssetCollectionChangeRequest.addAssets([asset], to: self?.customAlbum).execute({ success, error in
                    if success {
                        print("Video saved to custom album successfully")
                    } else {
                        print("Error saving video to custom album: $$error?.localizedDescription ?? "")")
                    }
                })
            } else {
                print("Error saving video to custom album: $$error?.localizedDescription ?? "")")
            }
        })
    }
}
