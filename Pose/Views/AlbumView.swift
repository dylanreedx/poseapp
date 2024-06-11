import SwiftUI
import Photos

struct AlbumView: View {
    @StateObject private var albumManager = AlbumManager()
    @State private var thumbnails: [UIImage] = []
    
    let spacing: CGFloat = 10 // Define the spacing between grid items
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 2) // Two columns with spacing
    
    var body: some View {
        GeometryReader { geometry in
            let thumbnailWidth = (geometry.size.width - (3 * spacing)) / 2 // Calculate thumbnail width
            let thumbnailHeight = thumbnailWidth * 1.5 // Adjust height to be 1.5 times the width for a taller thumbnail
            
            VStack {
                Text("Album content")
                    .font(.largeTitle)
                    .padding()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(thumbnails.indices, id: \.self) { index in
                            ZStack {
                                Image(uiImage: thumbnails[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: thumbnailWidth, height: thumbnailHeight)
                                    .cornerRadius(spacing * 2)
                                    .clipped() // Ensure the image doesn't overflow the frame
                            }
                        }
                        .padding(spacing)
                    }
                    
                    Button(action: {
                        // Close the drawer
                    }) {
                        Text("Close")
                    }
                    .padding()
                }
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    albumManager.fetchAlbumVideos()
                }
                .onChange(of: albumManager.videos) {
                    fetchThumbnails()
                }
            }
        }
    }
    
    private func fetchThumbnails() {
        thumbnails = [] // Clear previous thumbnails
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true // Ensure the request is synchronous for simplicity
        
        for video in albumManager.videos {
            manager.requestImage(for: video, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    DispatchQueue.main.async {
                        self.thumbnails.append(image)
                    }
                }
            }
        }
    }
}

#Preview {
    AlbumView()
}
