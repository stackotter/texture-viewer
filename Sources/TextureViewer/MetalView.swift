//
//  MetalView.swift
//  TextureViewer
//
//  Created by Rohan van Klinken on 30/7/21.
//

import Foundation
import MetalKit
import SwiftUI

final class MetalView: NSViewRepresentable {
  var coordinator: RenderCoordinator!
  
  func makeCoordinator() -> RenderCoordinator {
    coordinator = RenderCoordinator(test: false)
    return coordinator
  }
  
  func changeTexture() {
    coordinator.newTexture()
  }
  
  func makeNSView(context: Context) -> some NSView {
    let mtkView = MTKView()
    
    if let metalDevice = MTLCreateSystemDefaultDevice() {
      mtkView.device = metalDevice
    }
    mtkView.delegate = context.coordinator
    mtkView.preferredFramesPerSecond = 60
    mtkView.framebufferOnly = false
    mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
    mtkView.drawableSize = mtkView.frame.size
    
    // Accept input
    mtkView.becomeFirstResponder()
    return mtkView
  }
  
  func updateNSView(_ view: NSViewType, context: Context) {
    
  }
}
