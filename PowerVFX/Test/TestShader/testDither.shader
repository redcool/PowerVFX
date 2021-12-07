Shader "Unlit/testDither"
{
    Properties
    {
        _Scale("_Scale",half) = 1
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
            #include "../../Lib/NodeLib.cginc"

            struct appdata
            {
                half4 vertex : POSITION;
                half2 uv : TEXCOORD0;
            };

            struct v2f
            {
                half2 uv : TEXCOORD0;
                half4 vertex : SV_POSITION;
                half4 screenPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            half4 _MainTex_ST;

            half _Scale;

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
                half4 v;
                i.screenPos.xyz /= i.screenPos.w;
                i.screenPos *= 0.5;
                Unity_Dither_half4(_Scale,i.screenPos,v);
                clip(0.1- v);
                return v;
            }
            ENDCG
        }
    }
}
