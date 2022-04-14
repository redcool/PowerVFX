Shader "Unlit/GroupDrawDemo"
{
    Properties
    {
        //show a new Group
        [Group(group1)]
        [GroupItem(group1)]_MainTex1 ("Texture1", 2D) = "white" {}
        // show group item
        [GroupItem(group1)]_FloatVlaue("_FloatVlaue",range(0,1)) = 0.1
        [GroupItem(group1)]_FloatVlaue2("_FloatVlaue",float) = 0.1
        [GroupItem(group1)]_FloatVlaue3("_FloatVlaue",range(0,1)) = 0.1
        // // // show Toggle
        [GroupToggle(group1)]_ToggleNoKeyword("_ToggleNoKeyword",int) = 1
        [GroupToggle(group1,_Ker)]_ToggleWithKeyword("_ToggleWithKeyword",int) = 1


        //[GroupHeader(group1,header1)]
        [LineHeader(group1,header2)]
        // show Enum with keyword
        [GroupEnum(group1, _kEYA _KEYB,true)]_GroupKeywordEnum("_GroupKeywordEnum",int) = 0
        // // show Enum, space is splitter 
        [GroupEnum(group1,A 0 B 1)]_GroupEnum("_GroupEnum",int) = 0
        [GroupEnum(group1,UnityEngine.Rendering.BlendMode)]_GroupEnumBlend("_GroupEnumBlend",int) = 0

        [Group(group2)]
        [GroupItem(group2)]_MainTex2 ("Texture2", 2D) = "white" {}

        //         [Group(group3)]
        // [GroupItem(group3)]_MainTex3 ("Texture2", 2D) = "white" {}

        //         [Group(group4)]
        // [GroupItem(group4)]_MainTex4 ("Texture2", 2D) = "white" {}

        //         [Group(group5)]
        // [GroupItem(group5)]_MainTex5 ("Texture2", 2D) = "white" {}

        //         [Group(group6)]
        // [GroupItem(group6)]_MainTex6 ("Texture2", 2D) = "white" {}
    }
    SubShader{
        pass{
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
