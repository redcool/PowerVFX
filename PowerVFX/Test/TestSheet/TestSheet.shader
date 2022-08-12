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

            /**
                Remap uv to rect uv

                sheet[x:number of row,y:number of column]

                Testcase:
                    float2 uv = i.uv;
                    uv = RectUV(_Id * _Time.y,uv,_Sheet,true);
                    half4 col = tex2D(_MainTex, uv);
            */

            float2 RectUV(float id,float2 uv,half2 sheet,bool invertY,bool playOnce){
                /*
                    id = id % (sheet.x*sheet.y); // play loop
                    id = min(sheet.x*sheet.y-0.1,id) // play once
                */
                half count = sheet.x*sheet.y;
                id %= count;
                // id = playOnce ? min(count-0.1,id) : id % count; // play mode

                int x = (id % sheet.x);
                int y = (id / sheet.x);
                y= invertY ? (sheet.y-y-1) : y;

                half2 size = 1.0/sheet;
                half4 rect = half4(half2(x,y),half2(x+1,y+1)) * size.xyxy;
                return lerp(rect.xy,rect.zw,uv);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                uv  = RectUV(_Id * _Time.y,uv,_Sheet,true,1);
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
