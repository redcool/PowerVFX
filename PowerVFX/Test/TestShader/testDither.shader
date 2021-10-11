Shader "Unlit/testDither"
{
    Properties
    {
        _Scale("_Scale",float) = 1
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

            #include "UnityCG.cginc"
            #include "../NodeLib.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Scale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 v;
                i.screenPos.xyz /= i.screenPos.w;
                i.screenPos *= 0.5;
                Unity_Dither_float4(_Scale,i.screenPos,v);
                clip(0.1- v);
                return v;
            }
            ENDCG
        }
    }
}
