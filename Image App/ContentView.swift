//
//  ContentView.swift
//  Image App
//
//  Created by Tony Buckner on 11/7/24.
//

import Foundation
import AVFoundation
import AVKit
import MetalKit
import Photos
import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State private var isRecording = false
    @State private var recordedVideoURL: URL?
    @State private var device = MTLCreateSystemDefaultDevice()!
    @State private var presentMetalPreview = false

    var body: some View {
        VStack {
            
            CameraView(isRecording: $isRecording, recordedVideoURL: $recordedVideoURL)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                HStack {
                    
                    Button(action: {
                        isRecording.toggle()
                    }) {
                        Text(isRecording ? Constants.Text.stopRecording.rawValue : Constants.Text.startRecording.rawValue)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(isRecording ? Color.red : Color.green)
                            .cornerRadius(Constants.Floats.buttonCorners.rawValue)
                    }
                    
                    Button(action: { presentMetalPreview = true }) {
                        Text(Constants.Text.review.rawValue)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(Constants.Floats.buttonCorners.rawValue)
                    }
                    .disabled(recordedVideoURL == nil || isRecording)
                    .opacity(recordedVideoURL == nil || isRecording ? Constants.Floats.halfOpacity.rawValue : Constants.Floats.fullOpacity.rawValue)
                    
                }
            }
            .padding()
            .sheet(isPresented: $presentMetalPreview, content: {
                VideoReviewView(url: $recordedVideoURL, device: device)
            })
        }
    }

}

#Preview {
    ContentView()
}
