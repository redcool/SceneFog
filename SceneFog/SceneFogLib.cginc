#if !defined(SCENE_FOG_LIB_CGINC)
#define SCENE_FOG_LIB_CGINC

// float4 unity_FogColor;

sampler2D _SceneFogMap;
sampler2D _FogMainNoiseMap,_FogDetailNoiseMap;
float3 _SceneMin;
float3 _SceneMax;
float4 _FogNoiseTilingOffset;

float _SceneFogOn;
float _SceneHeightFogOn;
float _CameraFadeDist;

float4 CalcFogFactor(float3 worldPos){
    float3 worldUV = (worldPos - _SceneMin)/max(0.0001,_SceneMax - _SceneMin);
    float4 fogMap = tex2Dlod(_SceneFogMap,float4(worldUV.xz,0,0));
    float fogRate = lerp(1,0.6,worldUV.y * _SceneHeightFogOn) * fogMap.y;
    float4 sceneFogFactor = float4(worldUV,saturate(fogRate));
    // // -------- sphere fog
    // float3 viewDir = (_WorldSpaceCameraPos.xyz - worldPos);
    // float viewDist = length(viewDir);

    // // --------- vertical linear fog
    float viewDist = (_WorldSpaceCameraPos.y - worldPos.y);

    float viewFade = lerp(0.1,1,viewDist / max(0.001,_CameraFadeDist));
    sceneFogFactor.w *= saturate(viewFade);

    return sceneFogFactor;
}

float4 CalcFogColor(float3 worldUV){
    float2 noiseUVScroll =_Time.y * _FogNoiseTilingOffset.zw;
    // xz
    float2 noiseUV = worldUV.xz * _FogNoiseTilingOffset.xy + noiseUVScroll;
    float4 detailNoiseMap = tex2D(_FogDetailNoiseMap,noiseUV);

    float4 noiseMap = tex2D(_FogMainNoiseMap,noiseUV + detailNoiseMap.xy * 0.2);

    // xy
    noiseUV = worldUV.xy + noiseUVScroll;
    noiseMap += tex2D(_FogMainNoiseMap,noiseUV + detailNoiseMap.xy * 0.2);
    noiseMap *= 0.5;

    // noiseMap.xyz *= saturate(lerp(2,0.9,(worldUV.y + detailNoiseMap.y*0.2)))  * _SceneHeightFogOn;

    return noiseMap * unity_FogColor;
}

#define UNITY_FOG_COORDS(idx) float4 fogCoord:TEXCOORD##idx;
#define UNITY_TRANSFER_FOG(o,posClip) \
    if(_SceneFogOn){\
        o.fogCoord = CalcFogFactor(o.posWorld);\
    }
#define UNITY_APPLY_FOG(coord,col) \
    if(_SceneFogOn){\
        float4 fogColor = CalcFogColor(coord.xyz);\
        col = lerp(col,fogColor,saturate(coord.w + fogColor.x));\
    }

#endif //SCENE_FOG_LIB_CGINC