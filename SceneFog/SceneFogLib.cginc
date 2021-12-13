#if !defined(SCENE_FOG_LIB_CGINC)
#define SCENE_FOG_LIB_CGINC

// half4 unity_FogColor;

sampler2D _SceneFogMap;
sampler2D _FogMainNoiseMap,_FogDetailNoiseMap;
sampler2D _HighlightTex;

half4 _HighlightColor;

half3 _SceneMin;
half3 _SceneMax;
half4 _FogNoiseTilingOffset;
half4 _DetailFogTiling,_DetailFogOffset;

half _SceneFogOn;
half _SceneHeightFogOn;
half _SceneHeightFogFading;

half _CameraFadeDist;

half4 CalcFogFactor(half3 worldPos){
    half3 worldUV = saturate((worldPos - _SceneMin)/max(0.0001,_SceneMax - _SceneMin));
    half4 fogMap = tex2Dlod(_SceneFogMap,half4(worldUV.xz,0,0));
    half fogAtten = fogMap.y ;
    half fogRate = lerp( _SceneHeightFogFading , 0.6 ,worldUV.y * _SceneHeightFogOn) * fogAtten;
    half4 sceneFogFactor = half4(worldUV,saturate(fogRate));
    // // -------- sphere fog
    // half3 viewDir = (_WorldSpaceCameraPos.xyz - worldPos);
    // half viewDist = length(viewDir);

    // // --------- vertical linear fog
    half viewDist = (_WorldSpaceCameraPos.y - worldPos.y);

    half viewFade = lerp(0.1,1,viewDist / max(0.001,_CameraFadeDist));
    sceneFogFactor.w *= saturate(viewFade);

    return sceneFogFactor;
}

half4 CaclHighLight(half3 worldPos){
        // high light
    float4 highlightTex = tex2D(_HighlightTex,worldPos.xz);
    float highlight = abs(sin(_Time.y)) * highlightTex.x;
    return highlight * _HighlightColor;
}

half4 CalcFogColor(half3 worldUV){
    half4 noiseUV = worldUV.xzxz * _DetailFogTiling + _DetailFogOffset * _Time.xxxx;
    half2 noise = tex2D(_FogDetailNoiseMap,noiseUV.xy);
    noise += tex2D(_FogDetailNoiseMap,noiseUV.zw);
// return float4(noise.xy*0.5,0,1);

    // xz
    half2 mainOffset = _Time.xx * _FogNoiseTilingOffset.zw;
    half2 mainNoiseUV = worldUV.xz* _FogNoiseTilingOffset.xy + mainOffset;
    // mainNoiseUV += (worldUV.xy+worldUV.yz)*0.5;
    // mainNoiseUV *= 0.3;
    half4 noiseMap = tex2D(_FogMainNoiseMap,mainNoiseUV + noise *0.05);
    half4 highlightColor = CaclHighLight(worldUV);

    return noiseMap * unity_FogColor + highlightColor;
}

#define UNITY_FOG_COORDS(idx) half4 fogCoord:TEXCOORD##idx;
#define UNITY_TRANSFER_FOG(o,posClip) \
    if(_SceneFogOn){\
        o.fogCoord = CalcFogFactor(o.posWorld);\
    }
#define UNITY_APPLY_FOG(coord,col) \
    if(_SceneFogOn){\
        half4 fogColor = CalcFogColor(coord.xyz);\
        col.xyz = lerp(col.xyz,fogColor.xyz, coord.w);\
    }

#endif //SCENE_FOG_LIB_CGINC