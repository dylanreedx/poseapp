import SwiftUI

struct ContentView: View {
    @StateObject private var model = FrameHandler()
    @State private var showDrawer = false

    var body: some View {
        ZStack {
            FrameView(image: model.frame)
                .edgesIgnoringSafeArea(.all)
                .zIndex(0)

            RecordingButton(model: model)
                .zIndex(1)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height < -50 {
                        showDrawer = true
                    }
                }
        )
        .navigationBarHidden(true)
        .sheet(isPresented: $showDrawer) {
            AlbumView()
        }
    }
}

#Preview {
    ContentView()
}
