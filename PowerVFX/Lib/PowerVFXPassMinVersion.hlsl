#if !defined(POWERVFX_PASS_MIN_VERSION_HLSL)
#define POWERVFX_PASS_MIN_VERSION_HLSL

/**
    min version features:
    1 uv offset
    2 mainTex sheet
    3 fog
    4 vertex color
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
    o.animBlendUVFactor_fogCoord.w = ComputeFogFactor(o.vertex.z);
    return o;
}

half4 frag(v2f i) : SV_Target
{
    float fogCoord = i.animBlendUVFactor_fogCoord.w;
    float4 mainTex = tex2D(_MainTex,i.uv);
    half4 mainColor = mainTex * _Color;
    mainColor.xyz = MixFog(mainColor.xyz,fogCoord);
    return mainColor;
}

#endif //POWERVFX_PASS_MIN_VERSION_HLSL