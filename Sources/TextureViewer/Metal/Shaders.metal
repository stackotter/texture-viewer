//
//  Shaders.metal
//  TextureViewer
//
//  Created by Rohan van Klinken on 30/7/21.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
  float3 position;
  float2 uv;
  float shade;
};

struct RasteriserData {
  float2 uv;
  float shade;
  float4 position [[position]];
};

struct Uniforms {
  float4x4 transformation;
};

constexpr sampler textureSampler (mag_filter::linear,
                                  min_filter::linear);

vertex RasteriserData vertexShader(uint vertexId [[vertex_id]], constant Vertex *vertices [[buffer(0)]],
                                        constant Uniforms &uniforms [[buffer(1)]]) {
  Vertex in = vertices[vertexId];
  RasteriserData out;
  
  // Transform vertex
  out.position = float4(in.position, 1.0) * uniforms.transformation;
  out.shade = in.shade;
  out.uv = in.uv;
  
  return out;
}

fragment float4 fragmentShader(RasteriserData in [[stage_in]],
                               texture2d<float> texture [[texture(0)]]) {
  float4 color = texture.sample(textureSampler, in.uv);
  return color * in.shade;
}
