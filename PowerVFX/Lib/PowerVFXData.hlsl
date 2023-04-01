#if !defined(POWER_VFX_DATA_CGINC)
#define POWER_VFX_DATA_CGINC
#include "../../PowerShaderLib/Lib/TangentLib.hlsl"
#include "../../PowerShaderLib/Lib/MaskLib.hlsl"

/*** Particle System need do:
    1 Particle system add Custom1.xyzw
    2 Particle system add Custom2.xyzw
    3 Particle system add UV/UV2
    4 Particle system add UV/AnimBlend
*/
struct appdata
{
    float4 vertex : POSITION;
    float4 color : COLOR;
    /**
        uv.xy : main uv or(particle's uv)
        uv.zw : (particle's customData Custom1.xy)

    */
    float4 uv : TEXCOORD0; 

    #if !defined(MIN_VERSION)
    float3 normal:NORMAL;
    float4 tangent:TANGENT;
    /** 
        uv1.xy (particle's customData Custom1.zw)
        uv1.zw (particle's customData Custom2.xy)

    */
    float4 uv1:TEXCOORD1;
    /**
        uv2.xy (particle's customData Custom2.zw)
        uv2.zw:(particle uv2)

    */        
    float4 uv2:TEXCOORD2;
    /**
        uv3.x (particle AnimBlend)

    */
    float4 uv3:TEXCOORD3;
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
    half4  uiMask : TEXCOORD9;
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