#if !defined(POWERVFX_PASS_MIN_VERSION_HLSL)
#define POWERVFX_PASS_MIN_VERSION_HLSL

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
    o.color = v.color;

    // --------------  composite custom datas
    o.customData1 = float4(v.uv.zw,v.uv1.xy);// particle custom data (Custom1.zw)(Custom2.xy)
    o.customData2 = float4(v.uv1.zw,v.uv2.xy); // particle custom data (Custom2.xy)
    float customDatas[8] = {o.customData1,o.customData2};

    // --------------  uv.xy : main uv, zw : custom data1.xy
    float mainTexOffsetCdataX = customDatas[_MainTexOffset_CustomData_X];
    float mainTexOffsetCdataY = customDatas[_MainTexOffset_CustomData_Y];
    o.uv = MainTexOffset(float4(v.uv.xy,mainTexOffsetCdataX,mainTexOffsetCdataY));    

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
    float4 mainUV = i.uv;
/**  
    get particle system's custom data

*/
    float customDatas[8] = {i.customData1,i.customData2};

    float dissolveCustomData = customDatas[_DissolveCustomData];
    float dissolveEdgeWidthCustomData = customDatas[_DissolveEdgeWidthCustomData];
    float distortionCustomData = customDatas[_DistortionCustomData];
    float2 mainTexMaskOffsetCustomData = float2(customDatas[_MainTexMaskOffsetCustomDataX] , customDatas[_MainTexMaskOffsetCustomDataY]);

    float2 uvDistorted = mainUV.zw;
    #if defined(DISTORTION_ON)
    // branch_if(_DistortionOn)
    {
        float4 distortUV = mainUV.zwzw * _DistortTile + frac(_DistortDir * _Time.xxxx);
        float2 uvDistortion = GetDistortionUV(mainUV.zw,distortUV,distortionCustomData);
        uvDistorted += uvDistortion;
        mainUV.xy += uvDistortion;
    }
    #endif
    
    // Sample MainTex
    float4 mainTex = tex2D(_MainTex,mainUV.xy);
    half4 mainColor = mainTex * _Color * i.color;
    //select a channel
    mainColor = lerp(mainColor, mainColor[_MainTexChannel] ,_MainTexSingleChannelOn);
    // per channel tint
    mainColor.xyz = lerp(mainColor,mainColor.x * _ColorX + mainColor.y * _ColorY + mainColor.z * _ColorZ,_PerChannelColorOn).xyz;

    // #if defined(ALPHA_TEST)
    //     clip(mainColor.a - _Cutoff - 0.0001);
    // #endif
    
    float4 mainTexMask=0;
    ApplyMainTexMask(mainColor/**/,mainTexMask/**/,_DistortionApplyToMainTexMask ? uvDistorted : mainUV.zw,0);
    
    //------------- dissolve
    #if defined(DISSOLVE_ON)
    // branch_if(_DissolveOn)
    {
        float2 dissolveUVOffset = UVOffset(_DissolveTex_ST.zw,_DissolveTexOffsetStop);
        float2 dissolveUV = (_DistortionApplyToDissolve ? uvDistorted : mainUV.zw) * _DissolveTex_ST.xy + dissolveUVOffset;
        ApplyDissolve(mainColor,dissolveUV,i.color,dissolveCustomData,dissolveEdgeWidthCustomData);
    }
    #endif 


    // mainColor.xyz = MixFog(mainColor.xyz,fogCoord);
    ApplyFog(mainColor.xyz/**/,worldPos,fogCoord);
    return mainColor;
}

#endif //POWERVFX_PASS_MIN_VERSION_HLSL