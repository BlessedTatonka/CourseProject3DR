//
//  MT1977Filter.metal
//  MetalFilters
//
//  Created by alexiscn on 2018/6/8.
//

#include <metal_stdlib>
#include "MTIShaderLib.h"
#include "IFShaderLib.h"
using namespace metalpetal;

fragment float4 BlurFragment(VertexOut vertexIn [[ stage_in ]], 
                             texture2d<float, access::sample> inputTexture [[ texture(0) ]],
                             texture2d<float, access::sample> map [[ texture(1) ]],
                             texture2d<float, access::sample> screen [[ texture(2) ]],
                             constant float & strength [[ buffer(0)]],
                             sampler textureSampler [[ sampler(0) ]],
                             sampler mapSampler [[ sampler(1) ]])
{
    //    return map.sample(textureSampler, vertexIn.textureCoordinate);
    float4 source = inputTexture.sample(textureSampler, vertexIn.textureCoordinate);
    float4 mask = map.sample(textureSampler, vertexIn.textureCoordinate);
    
    float maskValue = 1 - mask.r;
    float4 gray = float4(0.299, 0.587, 0.114, 1.0);
    if(maskValue == 0.0){
        const int blurSize = 75;
        
//        return inputTexture.read(uint2(int(vertexIn.position.x / 4) % blurSize,
//                              int(vertexIn.position.y / 4) % blurSize));
        
        int range = floor(blurSize/2.0);
    
        int i = 0;
        
        float4 colors = float4(0);
        for (int x = -range; x <= range; x++) {
            for (int y = -range; y <= range; y++) {
                float4 color = inputTexture.read(uint2(vertexIn.position.x+x,
                                                       vertexIn.position.y+y));
                
                float4 maskColor = map.read(uint2(vertexIn.position.x / 4 + x,
                                                  vertexIn.position.y / 4 + y));
                
                if ((1 - maskColor.r == 0.0)
                    && (1 - maskColor.g == 0.0)
                    && (1 - maskColor.b == 0.0)) {
//                    return maskColor;
                } else {
//                    return color;
                    colors += color;
                    i += 1;
//                    return gray;
                }
                
//                if (1 - maskColor.r == 0.0) {
//                    return float4(0, 0, 0, 0);
//                } else {
//                    return float4(1, 0, 0, 0);
//                }
////                return color;
                
//
            }
    
        }
        return colors * (blurSize * blurSize) / i;
        if (i == 0) {
            return gray;
        }
    
        float4 finalColor = colors / i;
        return finalColor;
    }
    return source;
    return float4(mix(float3(gray),source.rgb,maskValue),1.0);
    
    
    //    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    //    float4 texel = inputTexture.sample(s, vertexIn.textureCoordinate);
    //
    //    if (vertexIn.position.x < inputTexture.get_width() / 4 ||
    //        vertexIn.position.x > 3 * inputTexture.get_width() / 4 ||
    //        vertexIn.position.y < inputTexture.get_height() / 4 ||
    //        vertexIn.position.y > 3 * inputTexture.get_height() / 4) {
    //        return texel;
    //    }
    //
    ////    return 1 - texel;
    //
    //    const int blurSize = 100;
    //    int range = floor(blurSize/2.0);
    //
    //    float4 colors = float4(0);
    //    for (int x = -range; x <= range; x++) {
    //        for (int y = -range; y <= range; y++) {
    //            float4 color = inputTexture.read(uint2(vertexIn.position.x+x,
    //                                                   vertexIn.position.y+y));
    //            colors += color;
    //        }
    //
    //    }
    //
    //    float4 finalColor = colors/float(blurSize*blurSize);
    //    return finalColor;
}
