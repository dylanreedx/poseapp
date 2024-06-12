import SwiftUI

struct ContentView: View {
    @StateObject private var model = FrameHandler()
    @State private var showAlbumView = false

    var body: some View {
        ZStack {
            FrameView(image: model.frame)
                .edgesIgnoringSafeArea(.all)
                .zIndex(0)

            RecordingButton(model: model)
                .zIndex(1)

            if showAlbumView {
                AlbumView(showAlbumView: $showAlbumView)
                    .transition(.move(edge: .bottom))
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height < -50 {
                        withAnimation {
                            showAlbumView = true
                        }
                    }
                }
        )
        .navigationBarHidden(true)
    }
}

#Preview {
    ContentView()
}
