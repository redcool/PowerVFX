#if !defined(POWER_VFX_DATA_CGINC)
#define POWER_VFX_DATA_CGINC

    struct appdata
    {
        float4 vertex : POSITION;
        float3 normal:NORMAL;
        float4 color : COLOR;
        half4 uv : TEXCOORD0; // xy:main uv,zw : particle's customData(mainTex scroll)
        half4 uv1:TEXCOORD1; //particle's customData(x:dissolve,y:dissolveEdgeWidth)
    };

    struct v2f
    {
        float4 vertex : SV_POSITION;
        float4 color : COLOR;
        float3 reflectDir:COLOR1;
        float2 viewNormal:COLOR2;
        float3 refractDir:COLOR3;

        float4 uv : TEXCOORD0;
        float4 fresnal_customDataZ:TEXCOORD1;// x:fresnal,y:customData.x
        float4 grabPos:TEXCOORD2;
    };


#endif //