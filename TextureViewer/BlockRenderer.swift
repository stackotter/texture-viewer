//
//  BlockRenderer.swift
//  TextureViewer
//
//  Created by Rohan van Klinken on 30/7/21.
//

import Foundation
import MetalKit

struct BlockRenderer {
  var pipelineState: MTLRenderPipelineState
  
  init(device: MTLDevice) {
    log.info("Loading shaders")
    guard
      let defaultLibrary = device.makeDefaultLibrary(),
      let vertex = defaultLibrary.makeFunction(name: "vertexShader"),
      let fragment = defaultLibrary.makeFunction(name: "fragmentShader")
    else {
      fatalError("Failed to load chunk shaders")
    }
    
    // create pipeline descriptor
    log.debug("Creating pipeline descriptor")
    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.label = "dev.stackotter.TextureView.renderer"
    pipelineStateDescriptor.vertexFunction = vertex
    pipelineStateDescriptor.fragmentFunction = fragment
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    // create pipeline state
    log.debug("Creating pipeline state")
    do {
      pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    } catch {
      log.critical("Failed to create render pipeline state")
      fatalError("Failed to create render pipeline state")
    }
    
    log.info("BlockRenderer ready")
  }
  
  func createProjection(aspect: Float) -> matrix_float4x4 {
    let cameraPosition = simd_float3(0, 0, -3)
    
    let depth: Float = 100.0
    let height: Float = 3.0
    let cameraSize = simd_float3(aspect * height, height, depth)
    
    let mouseLocation = NSEvent.mouseLocation
    
    let rotationX = Float(.pi / 4.0) * Float(mouseLocation.y / 80)
    let rotationY = Float(.pi / 4.0) * Float(mouseLocation.x / 80)
    let rotationMatrix = MatrixUtil.rotationMatrix(y: rotationY) * MatrixUtil.rotationMatrix(x: -rotationX)
    
    let matrix = rotationMatrix * MatrixUtil.translationMatrix(-cameraPosition) * MatrixUtil.scalingMatrix(1 / cameraSize)
    return matrix
  }
  
  func draw(device: MTLDevice, renderEncoder: MTLRenderCommandEncoder, aspect: Float, texture: MTLTexture) {
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setFrontFacing(.clockwise)
    renderEncoder.setCullMode(.back)
    
    let transformation = createProjection(aspect: aspect)
    let uniforms = Uniforms(transformation: transformation)
    let uniformsBuffer = uniforms.toBuffer(device: device)
    
    let cubeVertexPositions = [
      simd_float3(-1, -1, -1), // bottom left front
      simd_float3(-1, 1, -1), // top left front
      simd_float3(1, 1, -1), // top right front
      simd_float3(1, -1, -1), // bottom right front
      simd_float3(1, -1, 1), // bottom right back
      simd_float3(1, 1, 1), // top right back
      simd_float3(-1, 1, 1), // top left back
      simd_float3(-1, -1, 1) // bottom left back
    ]
    
    let positionIndices: [UInt32] = [
      0, 1, 2, 2, 3, 0, // front
      7, 6, 1, 1, 0, 7, // left
      4, 5, 6, 6, 7, 4, // back
      3, 2, 5, 5, 4, 3, // right
      1, 6, 5, 5, 2, 1, // top
      7, 0, 3, 3, 4, 7  // bottom
    ]
    
    let shades: [Float] = [
      0.8, // front
      0.6, // left
      0.8, // back
      0.6, // right
      1.0, // top
      0.5  // bottom
    ]
    
    let uvs: [simd_float2] = [
      simd_float2(0, 1),
      simd_float2(0, 0),
      simd_float2(1, 0),
      simd_float2(1, 1)
    ]
    
    var vertices: [Vertex] = []
    var indices: [UInt32] = []
    for (i, index) in positionIndices.enumerated() {
      let shadeIndex = i / 6
      let uvIndex = positionIndices[Int(i % 6)]
      let uv = uvs[Int(uvIndex)]
      let shade = shades[shadeIndex]
      let vertex = Vertex(position: cubeVertexPositions[Int(index)], uv: uv, shade: shade)
      vertices.append(vertex)
      indices.append(UInt32(i))
    }
    
    let vertexBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: [])!
    let indexBuffer = device.makeBuffer(bytes: &indices, length: MemoryLayout<UInt32>.stride * indices.count, options: [])!
    
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)
    renderEncoder.setFragmentTexture(texture, index: 0)
    
    renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint32, indexBuffer: indexBuffer, indexBufferOffset: 0)
  }
}
