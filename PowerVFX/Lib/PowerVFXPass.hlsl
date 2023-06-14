#if !defined(POWER_VFX_PASS_CGINC)
#define POWER_VFX_PASS_CGINC
#include "../../PowerShaderLib/Lib/UnityLib.hlsl"
#include "../../PowerShaderLib/UrpLib/URP_Fog.hlsl"
#include "PowerVFXCore.hlsl"
#include "../../PowerShaderLib/UrpLib/URP_AdditionalLightShadows.hlsl"

v2f vert(appdata v)
{
    float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
    float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);
    float3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));

    v2f o = (v2f)0;
    o.color = v.color;
    o.viewDir = float4(viewDir,0);

    // composite custom datas
    o.customData1 = float4(v.uv.zw,v.uv1.xy);// particle custom data (Custom1.zw)(Custom2.xy)
    o.customData2 = float4(v.uv1.zw,v.uv2.xy); // particle custom data (Custom2.xy)
    float customDatas[8] = {o.customData1,o.customData2};

    #if defined(VERTEX_WAVE_ON)
    // branch_if(_VertexWaveOn)
    {
        float attenMaskCData = customDatas[_VertexWaveAttenMaskOffsetCustomData];
        float waveIntensityCData = customDatas[_VertexWaveIntensityCustomData];
        ApplyVertexWaveWorldSpace(worldPos.xyz/**/,worldNormal,v.color,v.uv,attenMaskCData,waveIntensityCData);
    }
    #endif
    o.vertex = UnityWorldToClipPos(worldPos);

    // uv.xy : main uv, zw : custom data1.xy
    float mainTexOffsetCdataX = customDatas[_MainTexOffset_CustomData_X];
    float mainTexOffsetCdataY = customDatas[_MainTexOffset_CustomData_Y];
    o.uv = MainTexOffset(float4(v.uv.xy,mainTexOffsetCdataX,mainTexOffsetCdataY));

    float3 viewNormal = normalize(mul((half3x3)UNITY_MATRIX_MV,v.normal));
    o.viewNormal = viewNormal.xy * 0.5 + 0.5;

    /* 
        Calc tangent space
        light, fresnel need normal
    */
    // #if defined(PBR_LIGHTING) 
    float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
    TANGENT_SPACE_COMBINE_WORLD(worldPos,worldNormal,float4(worldTangent,v.tangent.w),o/**/);
    // #endif

    // calc env reflect and refract

    float3 viewDirTS = WorldToTangent(viewDir,o.tSpace0,o.tSpace1,o.tSpace2);

    // #if defined(ENV_REFLECT_ON)
    float3 normalDistorted = SafeNormalize(worldNormal + _EnvOffset.xyz);
    branch_if(_EnvReflectOn)
    {
        o.reflectDir = reflect(- viewDir,normalDistorted);
        RotateReflectDir(o.reflectDir/**/,_EnvRotateInfo.xyz,_EnvRotateInfo.w,_EnvRotateAutoStop);
    }
    branch_if(_EnvRefractionOn)
    {
        // ior  https://en.wikipedia.org/wiki/Refractive_index
        o.refractDir = refract(-viewDir,normalDistorted,1/_EnvRefractionIOR);
        // o.refractDir = CalcInteriorMapReflectDir(viewDirTS,o.uv.xy);
        RotateReflectDir(o.refractDir/**/,_EnvRefractRotateInfo.xyz,_EnvRefractRotateInfo.w,_EnvRefractRotateAutoStop);
    }
    // #endif

    // fog 
    o.animBlendUVFactor_fogCoord.xyz = float3(v.uv2.zw,v.uv3.x);
    o.animBlendUVFactor_fogCoord.w = ComputeFogFactor(o.vertex.z);
    // UNITY_TRANSFER_FOG(o,o.vertex);

    #if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        o.shadowCoord = TransformWorldToShadowCoord(worldPos.xyz); // move to frag
    #endif

    // for ugui
    o.uiMask = GetUIMask(v.vertex,o.vertex.w,_ClipRect,half2(_UIMaskSoftnessX,_UIMaskSoftnessY));

    return o;
}

half4 frag(v2f i,half faceId:VFACE) : SV_Target
{
    TANGENT_SPACE_SPLIT(i);

    float3 viewDir = normalize(i.viewDir.xyz);
    float3 animBlendUVFactor = i.animBlendUVFactor_fogCoord.xyz;
    float fogCoord = i.animBlendUVFactor_fogCoord.w;

    float4 mainColor = float4(0,0,0,1);
    float4 screenColor=0;

    float3 reflectDir = i.reflectDir;
    float3 refractDir = i.refractDir;
    /* 
        setup mainUV, move to vs
        float4 mainUV = MainTexOffset(i.uv);
        mainUV.xy : mainTex
        mainUV.zw : vertex.uv
    */
    float4 mainUV = i.uv;
/**  
    get particle system's custom data

*/
    float customDatas[8] = {i.customData1,i.customData2};

    float dissolveCustomData = customDatas[_DissolveCustomData];
    float dissolveEdgeWidthCustomData = customDatas[_DissolveEdgeWidthCustomData];
    float distortionCustomData = customDatas[_DistortionCustomData];
    float2 mainTexMaskOffsetCustomData = float2(customDatas[_MainTexMaskOffsetCustomDataX] , customDatas[_MainTexMaskOffsetCustomDataY]);
    float2 offsetLayer1CData = float2(customDatas[_OffsetLayer1_CustomData_X],customDatas[_OffsetLayer1_CustomData_Y]);
/**
    particle system sheet animBlend
*/
    SheetAnimBlendParams animBlendParams = GetSheetAnimBlendParams(animBlendUVFactor);
    
    //use _CameraOpaqueTexture
    float2 screenUV = i.vertex.xy/_ScaledScreenParams.xy;
    mainUV.xy = lerp(mainUV.xy,screenUV,_MainTexUseScreenColor);
    
    float2 uvDistorted = mainUV.zw;
    #if defined(DISTORTION_ON)
    // branch_if(_DistortionOn)
    {
        float4 distortUV = mainUV.zwzw * _DistortTile + frac(_DistortDir * _Time.xxxx);
        branch_if(_DistortionRadialUVOn){
            float4 p = _DistortionRadialCenter_LenScale_LenOffset;
            distortUV.xy = PolarUV(mainUV.zw,p.xy,p.z,p.w*_Time.x,_DistortionRadialRot);
        }
        float2 uvDistortion = GetDistortionUV(mainUV.zw,distortUV,distortionCustomData);
        uvDistorted += uvDistortion;
        mainUV.xy += uvDistortion;
    }
    #endif
    // sample main texture
    SampleMainTex(mainColor/**/,screenColor/**/,mainUV.xy,i.color,faceId,animBlendParams);

    //-------- mainColor, screenColor prepared done
    float4 mainTexMask=0;
    ApplyMainTexMask(mainColor/**/,mainTexMask/**/,_DistortionApplyToMainTexMask ? uvDistorted : mainUV.zw,mainTexMaskOffsetCustomData);

    #if defined(PBR_LIGHTING)
        float2 normalUV = i.uv.xy * _MainTex_ST.xy+_MainTex_ST.zw;
        normal = SampleNormalMap(normalUV,i.tSpace0,i.tSpace1,i.tSpace2);
        ApplyPbrLighting(mainColor.xyz/**/,worldPos,i.shadowCoord,uvDistorted,normal,viewDir);

    #endif //PBR_LIGHTING

    // #if defined(ENV_REFLECT_ON) || defined(ENV_REFRACTION_ON)
    branch_if(_EnvReflectOn || _EnvRefractionOn)
    {
        float envMask = lerp(1,mainTexMask[_EnvMapMaskChannel],_EnvMaskUseMainTexMask);
        ApplyEnv(mainColor,mainUV.zw,reflectDir,refractDir,envMask);
    }
    // #endif

    #if defined(OFFSET_ON)
    // branch_if(_OffsetOn)
    {
        half4 offsetDir = lerp(_Time.xxxx,1,_StopAutoOffset) * _OffsetDir;
        offsetDir.xy = lerp(offsetDir.xy,offsetLayer1CData,_OffsetCustomDataOn);
        float4 offsetUV = (_DistortionApplyToOffset ? uvDistorted.xyxy : mainUV.zwzw) * _OffsetTile + (offsetDir); //暂时去除 frac
        branch_if(_OffsetRadialUVOn){
            float4 p = _OffsetRadialCenter_LenScale_LenOffset;
            offsetUV.xy = PolarUV(mainUV.zw,p.xy,p.z,p.w*_Time.x,_OffsetRadialRot);
        }
        // float2 maskUVOffset = _OffsetMaskTex_ST.zw * (1 + _Time.xx *(1- _OffsetMaskPanStop) );
        float2 maskUVOffset = UVOffset(_OffsetMaskTex_ST.zw, _OffsetMaskPanStop);
        float2 maskUV = mainUV.zw * _OffsetMaskTex_ST.xy + maskUVOffset;
        ApplyOffset(mainColor,offsetUV,maskUV);
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
    return mainColor;
    #endif 

    #if defined(FRESNEL_ON)
    // branch_if(_FresnelOn)
    {
        float fresnel = 1 - dot(normal,viewDir);
        ApplyFresnal(mainColor,fresnel,screenColor);
    }
    #endif
    
    #if defined(MATCAP_ON)
    // branch_if(_MatCapOn)
    {
        ApplyMatcap(mainColor,mainUV.zw,i.viewNormal);
    }
    #endif

    #if defined(DEPTH_FADING_ON)
    // branch_if(_DepthFadingOn)
    {
        float curZ = IsOrthographicCamera() ? OrthographicDepthBufferToLinear(i.vertex.z) : i.vertex.w;
        ApplySoftParticle(mainColor/**/,screenUV,curZ); // change vertex color
    }
    #endif


    mainColor.a = saturate(mainColor.a );
    // apply fog
    mainColor.xyz = MixFog(mainColor.xyz,fogCoord);

    #ifdef UNITY_UI_CLIP_RECT
        half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(i.uiMask.xy)) * i.uiMask.zw);
        mainColor.a *= m.x * m.y;
        // clip(mainColor.a -0.001);
    #endif

    return mainColor;
}


#endif //POWER_VFX_PASS_CGINC