Shader "Unlit/TestSceneFog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            #include "SceneFogLib.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 posWorld:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;//TRANSFORM_TEX(v.uv, _MainTex);
                o.posWorld = mul(unity_ObjectToWorld,v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_TRANSFER_FOG(i,i.vertex);
                // return i.fogCoord.w;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_TRANSFER_FOG(i,o.posWorld);
                UNITY_APPLY_FOG(i.fogCoord, col);
                half edge = i.fogCoord.w;
                // return edge;
                // edge *=( 1-i.fogCoord.w-0.5) *10;
//                 half4 fogColor = CalcFogColor(i.fogCoord.xyz);
// return saturate(smoothstep(0.2,0.5,fogColor.x) * edge *10);
                // return fogColor.x * 1;
                return col;
            }
            ENDCG
        }
    }
}
