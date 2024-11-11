//
//  VideoReviewView.swift
//  Image App
//
//  Created by Tony Buckner on 11/8/24.
//

import MetalKit
import SwiftUI

struct VideoReviewView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var videoReviewViewModel = VideoReviewViewModel()
    
    @Binding var url: URL?
    let device: MTLDevice
    
    var body: some View {
        
        VStack {
            
            MetalVideoView(videoURL: url ?? URL(fileURLWithPath: ""), device: device)
                .edgesIgnoringSafeArea(.all)
            
            HStack(spacing: Constants.Floats.mediumSpacing.rawValue) {
                
                Button(action: {
                    videoReviewViewModel.saveVideo(fromUrl: url)
                }) {
                    Text(Constants.Text.save.rawValue)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(Constants.Floats.buttonCorners.rawValue)
                }
                Button(action: {
                    dismiss()
                }) {
                    Text(Constants.Text.exit.rawValue)
                            .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(Constants.Floats.buttonCorners.rawValue)
                }
                
            }
            .padding()
            .alert(isPresented: $videoReviewViewModel.presentSaveVideoAlert, content: {
                videoReviewViewModel
                    .saveVideoAlertMethod(action: { _ in
                        if videoReviewViewModel.saveSuccessful {
                            url = nil
                            dismiss()
                        }
                    })
            })
        }
    }
}

#Preview {
    VideoReviewView(url: .constant(URL(fileURLWithPath: "")), device: MTLCreateSystemDefaultDevice()!)
}
