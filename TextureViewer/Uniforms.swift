//
//  Uniforms.swift
//  TextureViewer
//
//  Created by Rohan van Klinken on 30/7/21.
//

import Foundation
import simd
import MetalKit

struct Uniforms {
  var transformation: matrix_float4x4
  
  func toBuffer(device: MTLDevice) -> MTLBuffer {
    let size = MemoryLayout<Uniforms>.stride
    var uniforms = self
    let buffer = device.makeBuffer(bytes: &uniforms, length: size, options: [])!
    buffer.label = "dev.stackotter.TextureViewer.uniforms"
    return buffer
  }
}
