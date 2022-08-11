Shader "Unlit/TestSheet"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Sheet("_Sheet",vector)=(1,1,1,1)
        _Id("id",int) = 0
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
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _Sheet;
            float _Id;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 RectUV(float2 uv,float2 sheet){
                int id = (_Id)%(sheet.x*sheet.y);
                int x = id % sheet.x;
                int y = id / sheet.x; 
                float2 size = 1/sheet;
                return float4(float2(x,y)*size,float2(x+1,y+1)*size);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 rect = RectUV(i.uv,_Sheet);
                float2 uv = lerp(rect.xy,rect.zw,i.uv);
                // sample the texture
                fixed4 col = tex2D(_MainTex, uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
