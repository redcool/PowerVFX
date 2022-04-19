Shader "Unlit/ShowCameraTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "queue"="transparent"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                half4 vertex : POSITION;
                half2 uv : TEXCOORD0;
            };

            struct v2f
            {
                half2 uv : TEXCOORD0;
                half4 vertex : SV_POSITION;
                half4 grabPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            half4 _MainTex_ST;
            sampler2D _CameraOpaqueTexture;
            sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.grabPos = ComputeGrabScreenPos(o.vertex);
                #if defined(UNITY_UV_STARTS_AT_TOP)
                o.grabPos.y = o.grabPos.w - o.grabPos.y;
                #endif
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 grabPos = i.grabPos.xy/i.grabPos.w;
                fixed4 col = tex2D(_CameraOpaqueTexture, grabPos);
                return col;
            }
            ENDCG
        }
    }
}
