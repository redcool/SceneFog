Shader "Unlit/testFog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _NoiseTex("_NoiseTex",2d) = "bump"{}
        _WorldUV("_WorldUV(xy:pos,zw:border)",vector) = (0,0,0,0)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 screenPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _WorldUV;

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            sampler2D _CameraOpaqueTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv,_NoiseTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 screenUV = i.screenPos.xy/i.screenPos.w;

                float dist = length(screenUV - _WorldUV);
                dist = smoothstep(_WorldUV.z,_WorldUV.w,dist);
                // clip(dist-0.5);
                
                float4 noiseTex = tex2D(_NoiseTex, i.uv.zw);
                float distNoise = saturate(dist + noiseTex.x);
                dist = lerp(dist,distNoise,dist);
                // return dist;

                float4 screenColor = tex2D(_CameraOpaqueTexture,screenUV);
                
                // sample the texture
                float4 col = tex2D(_MainTex,i.uv.xy);
                col = lerp(screenColor,col,dist);

                return col;
            }
            ENDCG
        }
    }
}
