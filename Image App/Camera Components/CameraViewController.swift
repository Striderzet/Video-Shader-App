//
//  CameraViewController.swift
//  Image App
//
//  Created by Tony Buckner on 11/8/24.
//

import Combine
import Foundation
import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    var captureSession = AVCaptureSession()
    var videoOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var onRecordingComplete: ((URL) -> Void)?
    
    var recordingToggle = PassthroughSubject<Bool, Never>()
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setSubscribers()
    }

    private func setupCamera() {
        captureSession.sessionPreset = .high

        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let audioDevice = AVCaptureDevice.default(for: .audio),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else { return }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if let error = error {
            print(Constants.FunctionalStrings.recordingError(withError: error))
            deleteUsedVideoUrl(url: outputFileURL)
            startRecording()
        } else {
            onRecordingComplete?(outputFileURL)
        }
        
    }
    
    private func setSubscribers() {
        
        recordingToggle
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] toggle in
                if toggle {
                    self?.startRecording()
                } else {
                    self?.videoOutput.stopRecording()
                }
            })
            .store(in: &cancellable)
        
    }
    
    private func startRecording() {
        let outputPath = Constants.FunctionalStrings.outputPath(withURL: NSTemporaryDirectory()).value
        let outputURL = URL(fileURLWithPath: outputPath)
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    private func deleteUsedVideoUrl(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error.localizedDescription)
        }
    }
}
