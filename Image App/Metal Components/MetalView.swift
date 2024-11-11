//
//  MetalView.swift
//  Image App
//
//  Created by Tony Buckner on 11/7/24.
//

import SwiftUI
import AVFoundation
import MetalKit

struct MetalVideoView: UIViewRepresentable {
    var videoURL: URL
    var device: MTLDevice
    weak var mtkView: MTKView?
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView(frame: .zero, device: device)
        mtkView.delegate = context.coordinator
        mtkView.framebufferOnly = false
        context.coordinator.mtkView = mtkView
        context.coordinator.setupVideoPlayback(url: videoURL)
        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        if uiView.delegate == nil {
            context.coordinator.setupVideoPlayback(url: videoURL)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(device: device)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var device: MTLDevice
        var videoPlayer: AVPlayer?
        var videoOutput: AVPlayerItemVideoOutput?
        var commandQueue: MTLCommandQueue?
        var pipelineState: MTLRenderPipelineState?
        var textureCache: CVMetalTextureCache?
        var displayLink: CADisplayLink?
        weak var mtkView: MTKView?
        
        init(device: MTLDevice) {
            self.device = device
            self.commandQueue = device.makeCommandQueue()
            super.init()
            setupPipeline()
            CVMetalTextureCacheCreate(nil, nil, device, nil, &textureCache)
        }

        func setupPipeline() {
            guard let library = device.makeDefaultLibrary(),
                  let vertexFunction = library.makeFunction(name: Constants.FunctionalStrings.vertexShader.value),
                  let fragmentFunction = library.makeFunction(name: Constants.FunctionalStrings.greyscaleShader.value) else { return }
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

            pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }

        func setupVideoPlayback(url: URL) {
            let playerItem = AVPlayerItem(url: url)
            videoPlayer = AVPlayer(playerItem: playerItem)

            let attributes: [String: Any] = [
                (kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32BGRA)
            ]
            videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
            playerItem.add(videoOutput!)
            
            videoPlayer?.play()
            
            displayLink = CADisplayLink(target: self, selector: #selector(updateFrame))
            displayLink?.add(to: .main, forMode: .default)
        }

        @objc func updateFrame() {
            if let currentTime = videoPlayer?.currentTime(),
               videoOutput?.hasNewPixelBuffer(forItemTime: currentTime) == true {
                mtkView?.draw()
            }
        }

        func draw(in view: MTKView) {
            guard let currentDrawable = view.currentDrawable,
                  let pixelBuffer = videoOutput?.copyPixelBuffer(forItemTime: videoPlayer!.currentTime(), itemTimeForDisplay: nil),
                  let pipelineState = pipelineState,
                  let commandBuffer = commandQueue?.makeCommandBuffer(),
                  let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!) else { return }

            var cvMetalTexture: CVMetalTexture?
            CVMetalTextureCacheCreateTextureFromImage(nil, textureCache!, pixelBuffer, nil, .bgra8Unorm, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer), 0, &cvMetalTexture)
            
            guard let metalTexture = cvMetalTexture, let videoTexture = CVMetalTextureGetTexture(metalTexture) else { return }
            
            commandEncoder.setRenderPipelineState(pipelineState)
            commandEncoder.setFragmentTexture(videoTexture, index: 0)
            commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            commandEncoder.endEncoding()
            
            commandBuffer.present(currentDrawable)
            commandBuffer.commit()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        deinit {
            displayLink?.invalidate()
        }
    }
}
