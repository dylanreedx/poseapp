import SwiftUI
import Photos

struct AlbumView: View {
    @StateObject private var albumManager = AlbumManager()
    @State private var thumbnails: [UIImage] = []
    @Binding var showAlbumView: Bool
    @State private var showVideoDetail = false
    @State private var selectedAsset: PHAsset?

    let spacing: CGFloat = 10
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 2)

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: {
                        withAnimation {
                            showAlbumView = false
                        }
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.title)
                            .padding()
                    }
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showAlbumView = false
                        }
                    }) {
                        Text("")
                    }
                }
                .background(Color.black)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.top, safeAreaTopInset())
                
                // Album Content
                Text("Album content")
                    .font(.largeTitle)
                    .padding()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(albumManager.videos.indices, id: \.self) { index in
                            if let thumbnailImage = thumbnailImage(at: index) {
                                ThumbnailView(
                                    image: thumbnailImage,
                                    selected: selectedAsset == albumManager.videos[index],
                                    action: {
                                        selectedAsset = albumManager.videos[index]
                                        showVideoDetail = true
                                    }
                                )
                            }
                        }
                    }
                    .padding(spacing)
                }
                
                // NavigationLink for Video Detail View
                if showVideoDetail, let asset = selectedAsset {
                    NavigationLink(destination: VideoDetailView(asset: asset), isActive: $showVideoDetail) {
                        EmptyView()
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .background(Color.black)
            .onAppear {
                albumManager.fetchAlbumVideos()
            }
            .onChange(of: albumManager.videos) { _ in
                fetchThumbnails()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use this style for iPad compatibility
    }
    
    private func fetchThumbnails() {
        thumbnails = []
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        
        for video in albumManager.videos {
            manager.requestImage(for: video, targetSize: CGSize(width: 200, height: 300), contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    DispatchQueue.main.async {
                        self.thumbnails.append(image)
                    }
                }
            }
        }
    }
    
    private func safeAreaTopInset() -> CGFloat {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.safeAreaInsets.top ?? 0
    }

    private func thumbnailImage(at index: Int) -> Image? {
        guard index < thumbnails.count else { return nil }
        return Image(uiImage: thumbnails[index])
    }
}

struct ThumbnailView: View {
    var image: Image
    var selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: (UIScreen.main.bounds.width / 2) - 15, height: ((UIScreen.main.bounds.width / 2) - 15) * 1.5)
                .clipped()
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
