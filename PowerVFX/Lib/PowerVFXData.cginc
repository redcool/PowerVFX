#if !defined(POWER_VFX_DATA_CGINC)
#define POWER_VFX_DATA_CGINC
#include "../../PowerShaderLib/Lib/TangentLib.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float3 normal:NORMAL;
    float4 tangent:TANGENT;
    float4 color : COLOR;
    /**
        uv.xy : main uv
        uv.zw : mainTex scroll (particle's customData Custom1.xy)
    */
    float4 uv : TEXCOORD0; 
    /**
        uv1.xy (x:dissolve,y:dissolveEdgeWidth (particle's customData Custom1.zw)
        uv1.z (_DistortionCustomData)(custom2.x)
        uv1.w(_VertexWaveAttenMaskOffsetCustomData) (particle's customData Custom2.y)
    */
    float4 uv1:TEXCOORD1;
    /**
        uv2.x (_MainTexMask scroll.x)
        uv2.y(_MainTexMask scroll.y)
    */        
    float4 uv2:TEXCOORD2; // particles customData Custom2.zw
};

struct v2f
{
    float4 vertex : SV_POSITION;
    
    float4 color : COLOR;
    float3 reflectDir:COLOR1;
    float2 viewNormal:COLOR2;
    float3 refractDir:COLOR3;

    float4 uv : TEXCOORD0;
    // x y:customData.x,z:_VertexWaveAttenMask_UseCustomeData2_X
    float4 customData1:TEXCOORD1;
    // 
    float4 customData2:TEXCOORD2;
    // float4 grabPos:TEXCOORD2;
    TANGENT_SPACE_DECLARE(3,4,5);
    UNITY_FOG_COORDS(6)
    float3 viewDir :TEXCOORD7;
    
};


#endif //