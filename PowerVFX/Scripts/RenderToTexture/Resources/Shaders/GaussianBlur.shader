Shader "Hidden/GaussianBlur"
{
    Properties
    {
        _MainTex("_MainTex",2d) = ""{}
        _Scale("_Scale",range(1,10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        CGINCLUDE
            #include "UnityCG.cginc"
            #include "BlurLib.hlsl"
            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv:TEXCOORD;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _Scale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
        ENDCG

        // h+v 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            half4 frag (v2f i) : SV_Target
            {
                half2 uv = i.uv;
                half3 col = 0;

                col += Gaussian7(_MainTex,uv, _MainTex_TexelSize.xy * _Scale * half2(1,0));
                col += Gaussian7(_MainTex,uv, _MainTex_TexelSize.xy * _Scale * half2(0,1));
                col *= 0.5;
                return half4(col,1);
            }
            ENDCG
        }
        
        // 1 h
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            half4 frag (v2f i) : SV_Target
            {
                half2 uv = i.uv;
                half3 col = 0;

                col += GaussianBlur10(_MainTex,uv, _Scale * half2(1,0));

                return half4(col,1);
            }
            ENDCG
        }

        //2 v
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            half4 frag (v2f i) : SV_Target
            {
                half2 uv = i.uv;
                half3 col = 0;

                col += GaussianBlur10(_MainTex,uv , _Scale * half2(0,1));
                return half4(col,1);
            }
            ENDCG            
        }

    }
}
