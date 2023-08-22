#if !defined(POWER_VFX_DATA_CGINC)
#define POWER_VFX_DATA_CGINC
#include "../../PowerShaderLib/Lib/TangentLib.hlsl"
#include "../../PowerShaderLib/Lib/MaskLib.hlsl"

/*** Particle System need do:
    1 Renderer/CustomVertexStreams add Custom1.xyzw
    2 Renderer/CustomVertexStreams add Custom2.xyzw
    3 Renderer/CustomVertexStreams add UV/UV2
    4 Renderer/CustomVertexStreams add UV/AnimBlend
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

    #if !defined(MIN_VERSION)
    float3 normal:NORMAL;
    float4 tangent:TANGENT;

    /**
        uv3.x (particle AnimBlend)

    */
    float4 uv3:TEXCOORD3;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID    
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float4 color : COLOR;
    float4 uv : TEXCOORD0;
    float4 animBlendUV_fogCoord:TEXCOORD6; //(xy : particle animBlend'uv),(zw: sphere for coord)

    float4 customData1:TEXCOORD1;
    float4 customData2:TEXCOORD2;

    #if !defined(MIN_VERSION)

    // x y:customData.x,z:_VertexWaveAttenMask_UseCustomeData2_X
    TANGENT_SPACE_DECLARE(3,4,5);
    float4 viewDir_AnimBlendFactor :TEXCOORD7; //(xyz:ViewDir)(w:particle AnimBlend's factor)
    float4 shadowCoord:TEXCOORD8;
    float4  uiMask : TEXCOORD9;
    float4 reflectRefractDir:TEXCOORD10;
    // float3 reflectDir:TEXCOORD10;
    // float3 refractDir:TEXCOORD11;
    half3 viewDirTS:TEXCOORD12;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    #endif

    #if defined(MIN_VERSION)
    float4 worldPos:TEXCOORD3;
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

SheetAnimBlendParams GetSheetAnimBlendParams(float3 animBlendUVFactor,bool isBlendOn)
{
    SheetAnimBlendParams p;
    p.blendUV = animBlendUVFactor.xy;
    p.blendRate = animBlendUVFactor.z;
    p.isBlendOn = isBlendOn;
    // #if defined(SHEET_ANIM_BLEND_ON)
    //     p.isBlendOn = true;
    // #endif
    return p;
}

#endif //