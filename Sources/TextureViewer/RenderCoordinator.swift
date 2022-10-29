//
//  RenderCoordinator.swift
//  TextureViewer
//
//  Created by Rohan van Klinken on 30/7/21.
//

import Foundation
import MetalKit

public class RenderCoordinator: NSObject, MTKViewDelegate {
  private var commandQueue: MTLCommandQueue
  private var blockRenderer: BlockRenderer
  
  private var texture: MTLTexture
  
  public init(test: Bool) {
    guard let device = MTLCreateSystemDefaultDevice() else {
      fatalError("failed to get metal device")
    }
    
    guard let commandQueue = device.makeCommandQueue() else {
      fatalError("failed to make render command queue")
    }
    
    self.commandQueue = commandQueue
    blockRenderer = BlockRenderer(device: device)
    
    texture = Self.requestNewTexture(withDevice: device)
  }
  
  public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
  
  private func getClearColor() -> MTLClearColor {
    return MTLClearColorMake(0.65, 0.8, 1, 1)
  }
  
  private func getAspectRatio(of view: MTKView) -> Float {
    return Float(view.drawableSize.width / view.drawableSize.height)
  }
  
  public func setTextureFromURL(url: URL, withDevice device: MTLDevice) {
    texture = try! MTKTextureLoader(device: device).newTexture(URL: url, options: nil)
  }
  
  private static func requestNewTexture(withDevice device: MTLDevice) -> MTLTexture {
    let dialog = NSOpenPanel()
    dialog.title = "Choose a texture"
    dialog.showsHiddenFiles = true
    dialog.allowsMultipleSelection = false
    dialog.canChooseDirectories = false
    dialog.allowedFileTypes = ["png"]
    
    guard dialog.runModal() == NSApplication.ModalResponse.OK else {
      fatalError("Failed to get texture to use")
    }
    
    guard let result = dialog.url else {
      fatalError("No URL chosen")
    }
    
    return try! MTKTextureLoader(device: device).newTexture(URL: result, options: nil)
  }
  
  public func newTexture() {
    let device = MTLCreateSystemDefaultDevice()!
    texture = Self.requestNewTexture(withDevice: device)
  }
  
  public func draw(in view: MTKView) {
    guard let drawable = view.currentDrawable else {
      fatalError("failed to get current drawable")
    }
    
    guard let device = view.device else {
      fatalError("failed to get metal device (it used to be there)")
    }
    
    // Render
    if let commandBuffer = commandQueue.makeCommandBuffer() {
      if let renderPassDescriptor = view.currentRenderPassDescriptor {
        renderPassDescriptor.colorAttachments[0].clearColor = getClearColor()
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
          blockRenderer.draw(device: device, renderEncoder: renderEncoder, aspect: getAspectRatio(of: view), texture: texture)
          
          renderEncoder.endEncoding()
          commandBuffer.present(drawable)
          commandBuffer.commit()
        }
      }
    }
  }
}
