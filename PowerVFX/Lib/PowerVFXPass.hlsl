#if !defined(POWER_VFX_PASS_CGINC)
#define POWER_VFX_PASS_CGINC

#include "PowerVFXCore.hlsl"
#include "../../PowerShaderLib/UrpLib/URP_AdditionalLightShadows.hlsl"

v2f vert(appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v,o);

    float3 worldPos = TransformObjectToWorld(v.vertex.xyz);
    float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);
    float3 worldNormal = TransformObjectToWorldNormal(v.normal);


    o.color = v.color;

    // --------------  composite custom datas
    o.customData1 = float4(v.uv.zw,v.uv1.xy);// particle custom data (Custom1.zw)(Custom2.xy)
    o.customData2 = float4(v.uv1.zw,v.uv2.xy); // particle custom data (Custom2.xy)
    float customDatas[8] = {o.customData1,o.customData2};

    #if defined(VERTEX_WAVE_ON)
    // branch_if(_VertexWaveOn)
    {
        float attenMaskCData = customDatas[_VertexWaveAttenMaskOffsetCustomData];
        float waveIntensityCData = customDatas[_VertexWaveIntensityCustomData];
        float waveDirAttenCData = customDatas[_VertexWaveDirAttenCustomData];
        ApplyVertexWaveWorldSpace(worldPos.xyz/**/,worldNormal,v.color,v.uv,attenMaskCData,waveIntensityCData,waveDirAttenCData);
    }
    #endif

    // project to fullscreen [-0.5 ,0.5]
    // o.vertex = _FullScreenMode>0 ? float4(v.vertex.xy*2,UNITY_NEAR_CLIP_VALUE,UNITY_RAW_FAR_CLIP_VALUE) : TransformWorldToHClip(worldPos); // some pc driver has bug (gl)
    o.vertex = lerp(TransformWorldToHClip(worldPos) , float4(v.vertex.xy*2,UNITY_NEAR_CLIP_VALUE,UNITY_RAW_FAR_CLIP_VALUE) ,_FullScreenMode);

    // --------------  uv.xy : main uv, zw : custom data1.xy
    float mainTexOffsetCdataX = customDatas[_MainTexOffset_CustomData_X];
    float mainTexOffsetCdataY = customDatas[_MainTexOffset_CustomData_Y];
    o.uv = MainTexOffset(float4(v.uv.xy,mainTexOffsetCdataX,mainTexOffsetCdataY));

    // float3 viewNormal = (mul((half3x3)UNITY_MATRIX_MV,v.normal));
    // o.viewNormal = viewNormal.xy;

    /* 
        Calc tangent space
        light, fresnel need normal
    */
    // #if defined(PBR_LIGHTING) 
    float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
    TANGENT_SPACE_COMBINE_WORLD(worldPos,worldNormal,float4(worldTangent,v.tangent.w),o/**/);
    // #endif

    // -------------- calc env reflect and refract
    o.viewDirTS.xyz = WorldToTangent(viewDir,o.tSpace0,o.tSpace1,o.tSpace2);

    float3 normalDistorted = SafeNormalize(worldNormal + _EnvOffset.xyz);
    #if defined(ENV_REFLECT_ON)
    branch_if(_EnvReflectOn)
    {
        float3 reflectDir = reflect(- viewDir,normalDistorted);
        RotateReflectDir(reflectDir/**/,_EnvRotateInfo.xyz,_EnvRotateInfo.w,_EnvRotateAutoStop);
        o.reflectRefractDir.xy = reflectDir.xy;
    }
    #endif

    #if defined(ENV_REFRACTION_ON)
    branch_if(_EnvRefractionOn)
    {
        // ior  https://en.wikipedia.org/wiki/Refractive_index
        float3 refractDir = refract(-viewDir,normalDistorted,1/_EnvRefractionIOR);
        RotateReflectDir(refractDir/**/,_EnvRefractRotateInfo.xyz,_EnvRefractRotateInfo.w,_EnvRefractRotateAutoStop);
        o.reflectRefractDir.zw = refractDir.xy;
    }
    #endif

    // --------------  fog 
    o.animBlendUV_fogCoord.xy = v.uv2.zw; // particle anim blend uv
    o.animBlendUV_fogCoord.zw = CalcFogFactor(worldPos);
    // UNITY_TRANSFER_FOG(o,o.vertex);

    o.viewDir_AnimBlendFactor = float4(viewDir,v.uv3.x);// viewDir and particle anim blend factor

    #if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        o.shadowCoord = TransformWorldToShadowCoord(worldPos.xyz); // move to frag
    #endif


    // --------------  for ugui
    o.uiMask = GetUIMask(v.vertex,o.vertex.w,_ClipRect,half2(_UIMaskSoftnessX,_UIMaskSoftnessY));

    return o;
}

half4 frag(v2f i,half faceId:VFACE) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    TANGENT_SPACE_SPLIT(i);
    normal *= faceId<= 0 ? -1 : 1;

    float3 viewDir = normalize(i.viewDir_AnimBlendFactor.xyz);
    float3 animBlendUVFactor = float3(i.animBlendUV_fogCoord.xy,i.viewDir_AnimBlendFactor.w);
    float2 fogCoord = i.animBlendUV_fogCoord.zw;

    float4 mainColor = float4(0,0,0,1);
    float4 screenColor=0;
    
    float3 reflectDir = ConstructVector(i.reflectRefractDir.xy);
    float3 refractDir = ConstructVector(i.reflectRefractDir.zw);

    float parallaxWeight = 1;
    #if defined(_PARALLAX)
        float heightValue = ApplyParallax(i.uv.xy/**/,i.viewDirTS.xyz); // move to vs
        
        parallaxWeight = 1- heightValue > _ParallaxWeightOffset;
    #endif
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
    SheetAnimBlendParams animBlendParams = GetSheetAnimBlendParams(animBlendUVFactor,_MainTexSheetAnimBlendOn);
    
/** 
    Screen Space UV and mainUV
*/
    float2 screenUV = i.vertex.xy/_ScaledScreenParams.xy;
    float2 mainTexOffset = UVOffset(_MainTex_ST.zw,_MainTexOffsetStop);
    screenUV = lerp(screenUV,screenUV.xy * _MainTex_ST.xy + mainTexOffset,_MainTexUseScreenUV);
    mainUV.xy = lerp(mainUV.xy,screenUV,saturate(_MainTexUseScreenColor + _MainTexUseScreenUV));

    // for sprite
    mainUV.xy = _SpriteUVStart.z ? UVRepeat(mainUV.xy,_MainTex_ST.xy,_SpriteUVStart.xy) : mainUV.xy;
    
    float2 uvDistorted = mainUV.zw;
    #if defined(DISTORTION_ON)
    // branch_if(_DistortionOn)
    {
        float4 distortUV = mainUV.zwzw * _DistortTile + frac(_DistortDir * _Time.xxxx);
        branch_if(_DistortionRadialUVOn)
        {
            float4 p = _DistortionRadialCenter_Scale;
            distortUV.xy = PolarUV(mainUV.zw,p.xy,p.zw,_DistortionRadialRot,_DistortionRadialUVOffset);
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
        branch_if(_NormalMapOn){
            float2 normalUV = i.uv.xy * _NormalMap_ST.xy+_NormalMap_ST.zw;
            normal = SampleNormalMap(normalUV,i.tSpace0,i.tSpace1,i.tSpace2);
        }
        ApplyPbrLighting(mainColor.xyz/**/,worldPos,i.shadowCoord,uvDistorted,normal,viewDir);

    #endif //PBR_LIGHTING

    #if defined(ENV_REFLECT_ON) || defined(ENV_REFRACTION_ON)
    branch_if(_EnvReflectOn || _EnvRefractionOn)
    {
        float envMask = lerp(1,mainTexMask[_EnvMapMaskChannel],_EnvMaskUseMainTexMask);
        ApplyEnv(mainColor/**/,mainUV,reflectDir,refractDir,envMask,i.viewDirTS);
    }
    #endif

    #if defined(OFFSET_ON)
    // branch_if(_OffsetOn)
    {
        half4 offsetDir = _OffsetDir * (_StopAutoOffset? 1:_Time.xxxx); // lerp(_Time.xxxx,1,_StopAutoOffset) * _OffsetDir;
        offsetDir.xy = _OffsetCustomDataOn ? offsetLayer1CData : offsetDir.xy; ///lerp(offsetDir.xy,offsetLayer1CData,_OffsetCustomDataOn);
        float4 offsetUV = (_DistortionApplyToOffset ? uvDistorted.xyxy : mainUV.zwzw) * _OffsetTile + (offsetDir); //暂时去除 frac

        // to polar
        branch_if(_OffsetRadialUVOn)
        {
            float4 p = _OffsetRadialCenter_Scale;
            offsetUV.xy = PolarUV(mainUV.xy,p.xy,p.zw,_OffsetRadialRot * offsetDir.x,_OffsetRadialUVOffset*offsetDir.y);
        }
        float2 maskUVOffset = UVOffset(_OffsetMaskTex_ST.zw, _OffsetMaskPanStop);
        float2 maskUV = mainUV.zw * _OffsetMaskTex_ST.xy + maskUVOffset;
        ApplyOffset(mainColor,offsetUV,maskUV,parallaxWeight);
    }
    #endif

    //------------- dissolve
    #if defined(DISSOLVE_ON)
    // branch_if(_DissolveOn)
    {
        float2 dissolveUVOffset = UVOffset(_DissolveTex_ST.zw,_DissolveTexOffsetStop);
        float2 dissolveUV = (_DistortionApplyToDissolve ? uvDistorted : mainUV.zw) * _DissolveTex_ST.xy + dissolveUVOffset;
        ApplyDissolve(mainColor,dissolveUV,i.color,dissolveCustomData,dissolveEdgeWidthCustomData,mainUV.zw);
    }
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
        float3 viewNormal = mul(UNITY_MATRIX_V,normal);
        ApplyMatcap(mainColor,mainUV.zw,viewNormal);
    }
    #endif

    #if defined(DEPTH_FADING_ON)
    // branch_if(_DepthFadingOn)
    {
        float curZ = IsOrthographicCamera() ? OrthographicDepthBufferToLinear(i.vertex.z) : i.vertex.w;
        ApplySoftParticle(mainColor/**/,screenUV,curZ); // change vertex color
    }
    #endif


    // apply fog
    #if defined(FOG_LINEAR)
        // mainColor.xyz = MixFog(mainColor.xyz,fogCoord);
        ApplyFog(mainColor.xyz/**/,worldPos,fogCoord);
    #endif

    #ifdef UNITY_UI_CLIP_RECT
        half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(i.uiMask.xy)) * i.uiMask.zw);
        mainColor.a *= m.x * m.y;
        // clip(mainColor.a -0.001);
    #endif

    mainColor.a = saturate(mainColor.a );
    return mainColor;
}


#endif //POWER_VFX_PASS_CGINC