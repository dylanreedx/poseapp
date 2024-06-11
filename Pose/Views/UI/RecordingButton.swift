//

import SwiftUI

struct RecordingButton: View {
    @ObservedObject var model: FrameHandler

    var body: some View {
        VStack {
            Spacer()

            Button(action: {
                if model.isRecording {
                    model.stopRecording()
                } else {
                    model.startRecording()
                }
                model.isRecording.toggle()
            }) {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.white)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle()
                            .fill(model.isRecording ? Color.red : Color.white)
                            .frame(width: model.isRecording ? 72: 52, height: model.isRecording ? 72 : 52)
                    )
            }
            .padding(.bottom, 50)
        }
    }
}

