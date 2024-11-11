//
//  VideoReviewViewModel.swift
//  Image App
//
//  Created by Tony Buckner on 11/8/24.
//

import AVFoundation
import AVKit
import Foundation
import Photos
import SwiftUI

class VideoReviewViewModel: ObservableObject {
    
    @Published var presentSaveVideoAlert = false
    @Published var saveSuccessful = false
    
    private var saveVideoAlertTitle = Constants.Text.great.rawValue
    private var saveVideoAlertMessage = Constants.Messages.videoSaved.value
    
    func saveVideo(fromUrl videoUrl: URL?) {
        
        if let url = videoUrl {
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { [weak self] success, error in
                if success {
                    self?.setAndPresentAlert(title: Constants.Text.great.rawValue,
                                             message: Constants.Messages.videoSaved.value,
                                             isSuccessful: true)
                } else if let error = error {
                    print(Constants.Messages.videoNotSaved(withError: error.localizedDescription).value)
                    self?.setAndPresentAlert(title: Constants.Text.ohNo.rawValue,
                                             message: Constants.Messages.videoNotSaved(withError: error.localizedDescription).value,
                                             isSuccessful: false)
                }
            }
            
        }
    }
    
    func saveVideoAlertMethod(action: @escaping(() -> ()) -> ()) -> Alert {
        return Alert(title: Text(saveVideoAlertTitle),
                     message: Text(saveVideoAlertMessage),
                     dismissButton: .default(Text(Constants.Text.ok.rawValue), action: { action( {} ) } ))
    }
    
    private func setAndPresentAlert(title: String, message: String, isSuccessful: Bool) {
        saveVideoAlertTitle = title
        saveVideoAlertMessage = message
        
        DispatchQueue.main.async {
            self.saveSuccessful = isSuccessful
            self.presentSaveVideoAlert = true
        }
        
    }
    
}
