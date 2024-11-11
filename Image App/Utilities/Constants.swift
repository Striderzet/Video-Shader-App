//
//  Constants.swift
//  Image App
//
//  Created by Tony Buckner on 11/11/24.
//

import Foundation

struct Constants {
    
    enum Text: String {
        case stopRecording = "Stop Recording"
        case startRecording = "Start Recording"
        case review = "Review"
        case save = "Save"
        case exit = "Exit"
        case ok = "OK"
        case ohNo = "Oh No"
        case great = "Great"
    }
    
    enum Messages {
        
        case videoSaved
        case videoNotSaved(withError: String)
        
        var value: String {
            switch self {
            case .videoSaved:
                return "Video saved to Photos"
            case .videoNotSaved(let error):
                return "Error saving video: \(error)"
            }
        }
    }
    
    enum Floats: CGFloat {
        case halfOpacity = 0.5
        case fullOpacity = 1.0
        case mediumSpacing = 16
        case buttonCorners = 10
    }
    
    enum FunctionalStrings {
        
        case recordingError(withError: Error)
        case outputPath(withURL: String)
        case vertexShader
        case greyscaleShader
        
        var value: String {
            switch self {
            case .recordingError(let error):
                return "Recording error, retrying effort: \(error)"
            case .outputPath(let url):
                return url + "output.mov"
            case .vertexShader:
                return "vertexShader"
            case .greyscaleShader:
                return "grayscaleShader"
            }
        }
    }
    
}
