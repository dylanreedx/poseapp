import SwiftUI
import AVKit
import Photos

struct VideoDetailView: View {
    let asset: PHAsset

    @State private var playerItem: AVPlayerItem?
    @State private var player: AVPlayer?

    var body: some View {
        VStack {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                        player.replaceCurrentItem(with: nil)
                    }
            } else {
                Text("Loading video...")
            }
        }
        .onAppear {
            loadVideo()
        }
        .onDisappear {
            playerItem = nil
            player = nil
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func loadVideo() {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true

        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            if let urlAsset = avAsset as? AVURLAsset {
                DispatchQueue.main.async {
                    self.playerItem = AVPlayerItem(asset: urlAsset)
                    self.player = AVPlayer(playerItem: self.playerItem)
                }
            }
        }
    }
}
