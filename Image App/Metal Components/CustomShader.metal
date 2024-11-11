//
//  CustomShader.metal
//  Image App
//
//  Created by Tony Buckner on 11/8/24.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[position]];
    float2 textureCoordinate;
};

vertex VertexIn vertexShader(uint vertexID [[vertex_id]]) {
    float4 positions[4] = {
        float4(-1.0, -1.0, 0.0, 1.0),
        float4( 1.0, -1.0, 0.0, 1.0),
        float4(-1.0,  1.0, 0.0, 1.0),
        float4( 1.0,  1.0, 0.0, 1.0)
    };
    
    float2 textureCoords[4] = {
        float2(1.0, 1.0),
        float2(1.0, 0.0),
        float2(0.0, 1.0),
        float2(0.0, 0.0)
    };

    VertexIn out;
    out.position = positions[vertexID];
    out.textureCoordinate = textureCoords[vertexID];
    return out;
}

fragment float4 grayscaleShader(VertexIn in [[stage_in]], texture2d<float> videoTexture [[texture(0)]]) {
    
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
    float4 color = videoTexture.sample(textureSampler, in.textureCoordinate);
    
    float gray = dot(color.rgb, float3(0.3, 0.59, 0.11));
    return float4(gray, gray, gray, 1.0);
}

