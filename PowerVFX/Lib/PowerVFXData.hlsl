#if !defined(POWER_VFX_DATA_CGINC)
#define POWER_VFX_DATA_CGINC
#include "../../PowerShaderLib/Lib/TangentLib.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float4 color : COLOR;
    /**
        uv.xy : main uv
        uv.zw : mainTex scroll (particle's customData Custom1.xy)
    */
    float4 uv : TEXCOORD0; 

    #if !defined(MIN_VERSION)
    float3 normal:NORMAL;
    float4 tangent:TANGENT;
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
    float4 uv2:TEXCOORD2; // xy:(particles customData Custom2.zw) ,zw:(particle uv2)
    float4 uv3:TEXCOORD3; // (x : particle AnimBlend)
    #endif
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float4 color : COLOR;
    float4 uv : TEXCOORD0;
    float4 animBlendUVFactor_fogCoord:TEXCOORD6;

    #if !defined(MIN_VERSION)
    float3 reflectDir:COLOR1;
    float2 viewNormal:COLOR2;
    float3 refractDir:COLOR3;

    // x y:customData.x,z:_VertexWaveAttenMask_UseCustomeData2_X
    float4 customData1:TEXCOORD1;
    float4 customData2:TEXCOORD2;
    TANGENT_SPACE_DECLARE(3,4,5);
    float4 viewDir :TEXCOORD7; //(xyz:ViewDir)(w:particle AnimBlend)
    float4 shadowCoord:TEXCOORD8;
    #endif
};

/*
    particle system's sheet AnimBlend feature
*/
struct SheetAnimBlendParams
{
    bool isBlendOn;
    float2 blendUV;
    float blendRate;
};

SheetAnimBlendParams GetSheetAnimBlendParams(float3 animBlendUVFactor)
{
    SheetAnimBlendParams p;
    p.blendUV = animBlendUVFactor.xy;
    p.blendRate = animBlendUVFactor.z;
    p.isBlendOn = false;
    #if defined(SHEET_ANIM_BLEND_ON)
        p.isBlendOn = true;
    #endif
    return p;
}

#endif //