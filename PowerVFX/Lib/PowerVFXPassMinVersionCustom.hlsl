#if !defined(POWERVFX_PASS_MIN_VERSION_CUSTOM_HLSL)
#define POWERVFX_PASS_MIN_VERSION_CUSTOM_HLSL

/**
    click menu: PowerUtilities/PowerVFX/CheckMinVersion

    min version features:
    1 mainTex 
        uv offset
        color
    2 mainTex sheet
    3 sphere fog
    4 vertex color
    5 alpha test
*/

#include "../../PowerShaderLib/Lib/UnityLib.hlsl"
#include "../../PowerShaderLib/UrpLib/URP_Fog.hlsl"
#include "PowerVFXCore.hlsl"

v2f vert(appdata v){
    v2f o = (v2f)0;
    // o.uv.xy = TRANSFORM_TEX(v.uv,_MainTex);
    o.uv = MainTexOffset(float4(v.uv.xy,0,0));
    o.color = v.color;
    o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
    o.worldPos.xyz = TransformObjectToWorld(v.vertex.xyz);
    #if FOG_LINEAR
        o.animBlendUV_fogCoord.zw = CalcFogFactor(o.worldPos.xyz);
    #endif
    return o;
}

half4 frag(v2f i) : SV_Target
{
    float2 fogCoord = i.animBlendUV_fogCoord.zw;
    float3 worldPos= i.worldPos.xyz;

    float4 mainTex = tex2D(_MainTex,i.uv.xy);
    half4 mainColor = mainTex * _Color * i.color;
    
    #if defined(ALPHA_TEST)
        clip(mainColor.a - _Cutoff - 0.0001);
    #endif
    float4 mainTexMask=0;
    ApplyMainTexMask(mainColor/**/,mainTexMask/**/,i.uv.xy,0);

    // mainColor.xyz = MixFog(mainColor.xyz,fogCoord);
    ApplyFog(mainColor.xyz/**/,worldPos,fogCoord);
    return mainColor;
}

#endif //POWERVFX_PASS_MIN_VERSION_CUSTOM_HLSL