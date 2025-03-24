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
    6 DISSOLVE_ON
    7 FRESNEL
    8 OFFSET_ON
*/

#include "../../PowerShaderLib/Lib/UnityLib.hlsl"
#include "../../PowerShaderLib/UrpLib/URP_Fog.hlsl"
#include "PowerVFXCore.hlsl"

v2f vert(appdata v){

    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v,o);

    o.color = v.color;

    // --------------  composite custom datas
    o.customData1 = float4(v.uv.zw,v.uv1.xy);// particle custom data (Custom1.zw)(Custom2.xy)
    o.customData2 = float4(v.uv1.zw,v.uv2.xy); // particle custom data (Custom2.xy)

    // --------------  uv.xy : main uv, zw : custom data1.xy
    float mainTexOffsetCdataX = GET_CUSTOM_DATA(o,_MainTexOffset_CustomData_X);
    float mainTexOffsetCdataY = GET_CUSTOM_DATA(o,_MainTexOffset_CustomData_Y);
    o.uv = MainTexOffset(float4(v.uv.xy,mainTexOffsetCdataX,mainTexOffsetCdataY));    

    o.vertex = TransformObjectToHClip(v.vertex.xyz);
    float3 worldPos = TransformObjectToWorld(v.vertex.xyz);
    float3 worldNormal = TransformObjectToWorldNormal(v.normal);
    float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
    TANGENT_SPACE_COMBINE_WORLD(worldPos,worldNormal,float4(worldTangent,v.tangent.w),o/**/);

    float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);

    #if defined(FOG_LINEAR)
        o.animBlendUV_fogCoord.zw = CalcFogFactor(worldPos.xyz);
    #endif
    o.viewDir_AnimBlendFactor = float4(viewDir,0);// viewDir and particle anim blend factor
    return o;
}

half4 frag(v2f i) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
    //split,
    TANGENT_SPACE_SPLIT(i);
    float3 viewDir = normalize(i.viewDir_AnimBlendFactor.xyz);

    float2 fogCoord = i.animBlendUV_fogCoord.zw;
    float4 mainUV = i.uv;
    
    // for sprite
    mainUV.xy = _SpriteUVStart.z?UVRepeat(mainUV.xy,_MainTex_ST.xy,_SpriteUVStart.xy) : mainUV.xy;
/**  
    get particle system's custom data

*/
    float dissolveCustomData = GET_CUSTOM_DATA(i,_DissolveCustomData);
    float dissolveEdgeWidthCustomData = GET_CUSTOM_DATA(i,_DissolveEdgeWidthCustomData);
    float distortionCustomData = GET_CUSTOM_DATA(i,_DistortionCustomData);
    float2 mainTexMaskOffsetCustomData = float2(GET_CUSTOM_DATA(i,_MainTexMaskOffsetCustomDataX) , GET_CUSTOM_DATA(i,_MainTexMaskOffsetCustomDataY));
    float2 offsetLayer1CData = float2(GET_CUSTOM_DATA(i,_OffsetLayer1_CustomData_X),GET_CUSTOM_DATA(i,_OffsetLayer1_CustomData_Y));

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
    half4 mainColor = mainTex;
    
    //select a channel
    // mainColor = lerp(mainColor, mainColor[_MainTexChannel] ,_MainTexSingleChannelOn);
    mainColor = _MainTexSingleChannelOn ? mainColor[_MainTexChannel] : mainColor;
    mainColor *= _Color * (_PremultiVertexColor ? i.color : 1);

    // per channel tint
    mainColor.xyz = _PerChannelColorOn ? (mainColor.x * _ColorX + mainColor.y * _ColorY + mainColor.z * _ColorZ).xyz : mainColor.xyz;

    // #if defined(ALPHA_TEST)
    //     clip(mainColor.a - _Cutoff - 0.0001);
    // #endif
    
    float4 mainTexMask=0;
    ApplyMainTexMask(mainColor/**/,mainTexMask/**/,_DistortionApplyToMainTexMask ? uvDistorted : mainUV.zw,0);
  
    #if defined(OFFSET_ON)
    // branch_if(_OffsetOn)
    {
        half4 offsetDir = _OffsetDir * (_StopAutoOffset? 1:_Time.xxxx); // lerp(_Time.xxxx,1,_StopAutoOffset) * _OffsetDir;
        offsetDir.xy = _OffsetCustomDataOn ? offsetLayer1CData : offsetDir.xy; ///lerp(offsetDir.xy,offsetLayer1CData,_OffsetCustomDataOn);
        float4 offsetUV = (_DistortionApplyToOffset ? uvDistorted.xyxy : mainUV.zwzw) * _OffsetTile + (offsetDir); //暂时去除 frac

        // to polar
        // branch_if(_OffsetRadialUVOn)
        // {
        //     float4 p = _OffsetRadialCenter_Scale;
        //     offsetUV.xy = PolarUV(mainUV.xy,p.xy,p.zw,_OffsetRadialRot * offsetDir.x,_OffsetRadialUVOffset*offsetDir.y);
        // }
        float2 maskUVOffset = UVOffset(_OffsetMaskTex_ST.zw, _OffsetMaskPanStop);
        float2 maskUV = mainUV.zw * _OffsetMaskTex_ST.xy + maskUVOffset;
        ApplyOffset(mainColor,offsetUV,maskUV,1);

    }
    #endif
    //------------- dissolve
    #if defined(DISSOLVE_ON)
    // branch_if(_DissolveOn)
    {
        float2 dissolveUVOffset = UVOffset(_DissolveTex_ST.zw,_DissolveTexOffsetStop);
        float2 dissolveUV = (_DistortionApplyToDissolve ? uvDistorted : mainUV.zw) * _DissolveTex_ST.xy + dissolveUVOffset;
        ApplyDissolve(mainColor,dissolveUV,i.color,dissolveCustomData,dissolveEdgeWidthCustomData);
    }
    #endif 
    #if defined(FRESNEL_ON)
    branch_if(_FresnelOn)
    {
        
        float fresnel = 1 - dot(normal,viewDir);
        ApplyFresnal(mainColor,fresnel,0/*screenColor*/);
    }
    #endif
    #if defined(FOG_LINEAR)
    // mainColor.xyz = MixFog(mainColor.xyz,fogCoord);
    ApplyFog(mainColor.xyz/**/,worldPos,fogCoord);
    #endif
    return mainColor;
}

#endif //POWERVFX_PASS_MIN_VERSION_HLSL