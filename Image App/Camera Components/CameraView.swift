//
//  CameraView.swift
//  Image App
//
//  Created by Tony Buckner on 11/8/24.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    
    @Binding var isRecording: Bool
    @Binding var recordedVideoURL: URL?
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        cameraViewController.onRecordingComplete = { url in
            DispatchQueue.main.async {
                recordedVideoURL = url
            }
        }
        return cameraViewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.recordingToggle.send(isRecording)
    }
}
