//
//  ContentView.swift
//  Pose
//
//  Created by Dylan Reed on 2024-06-11.
//

import SwiftUI



struct ContentView: View {
    @StateObject private var model = FrameHandler()
    
    var body: some View {
        FrameView(image: model.frame)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
