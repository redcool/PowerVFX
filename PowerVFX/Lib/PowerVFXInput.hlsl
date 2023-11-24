#if !defined(POWER_VFX_INPUT_CGINC)
#define POWER_VFX_INPUT_CGINC

    sampler2D _MainTex;
    sampler2D _MainTexMask;// (r,a)
    sampler2D _DistortionNoiseTex;//FlowMap,(xy : layer1,zw : layer2)
    sampler2D _DistortionMaskTex;//(r,a)
    sampler2D _DissolveTex;

    sampler2D _OffsetTex;
    sampler2D _OffsetMaskTex;//(r,a)
    sampler2D _CameraOpaqueTexture;
    // samplerCUBE _EnvMap;
    TEXTURECUBE(_EnvMap);SAMPLER(sampler_EnvMap);
    sampler2D _PbrMask;//(r,a)
    
    sampler2D _MatCapTex;
    sampler2D _VertexWaveAtten_MaskMap;//r
    sampler2D _CameraDepthTexture;
    sampler2D _NormalMap;
    TEXTURE2D(_ParallaxMap);SAMPLER(sampler_ParallaxMap);

    // half4 _MainLightPosition;
    // half4 _MainLightColor;

/**
    Particle system custom data
    vector1
        1 (xy)_MainTexOffset_CustomData
        2 (zw)_DissolveCustomData,_DissolveEdgeWidthCustomData
    vector2 
        (x) _DistortionCustomData
        (y) _VertexWaveAttenMaskOffsetCustomData
*/

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainUVAngle)
    UNITY_DEFINE_INSTANCED_PROP(half4,_Color)
    UNITY_DEFINE_INSTANCED_PROP(half,_ColorScale)
    UNITY_DEFINE_INSTANCED_PROP(half,_PerChannelColorOn)
    UNITY_DEFINE_INSTANCED_PROP(half4,_ColorX)
    UNITY_DEFINE_INSTANCED_PROP(half4,_ColorY)
    UNITY_DEFINE_INSTANCED_PROP(half4,_ColorZ)

    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexSaturate)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexSingleChannelOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexChannel)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexMultiAlpha)
    UNITY_DEFINE_INSTANCED_PROP(half,_PremultiVertexColor)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexColorChannelOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexColorChannel)
    
    
    UNITY_DEFINE_INSTANCED_PROP(half,_BackFaceOn)
    UNITY_DEFINE_INSTANCED_PROP(half4,_BackFaceColor)
    UNITY_DEFINE_INSTANCED_PROP(half4,_MainTex_ST)
    UNITY_DEFINE_INSTANCED_PROP(half4,_MainTex_TexelSize)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexOffsetStop)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexOffset_CustomData_On)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexOffset_CustomData_X)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexOffset_CustomData_Y) // default Custom1.xy

    UNITY_DEFINE_INSTANCED_PROP(half,_DoubleEffectOn) //2层效果,
    UNITY_DEFINE_INSTANCED_PROP(half4,_MainTexMask_ST)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexMaskOffsetStop)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexMaskChannel)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexMaskOffsetCustomDataOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexMaskOffsetCustomDataX)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexMaskOffsetCustomDataY) // default Custom2.zw
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexUseScreenColor)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexUseScreenUV)
    UNITY_DEFINE_INSTANCED_PROP(half,_FullScreenMode)
    
    UNITY_DEFINE_INSTANCED_PROP(half2,_MainTexSheet)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexSheetAnimSpeed)
    UNITY_DEFINE_INSTANCED_PROP(half,_MainTexSheetAnimBlendOn)
    // UNITY_DEFINE_INSTANCED_PROP(half,_MainTexSheetPlayOnce)
// ==================================================_VertexWaveOn
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_NoiseUseAttenMaskMap)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveSpeed)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveSpeedManual)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveIntensity)
  
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveIntensityCustomDataOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveIntensityCustomData)

    // vertex wave attenuations
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveAtten_VertexColor)
    UNITY_DEFINE_INSTANCED_PROP(half4,_VertexWaveDirAtten)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveDirAttenCustomDataOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveDirAttenCustomData)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveDirAlongNormalOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveDirAtten_LocalSpaceOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveAtten_NormalAttenOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_UVCircleDist2)
    
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveAtten_MaskMapOn)
    UNITY_DEFINE_INSTANCED_PROP(half4,_VertexWaveAtten_MaskMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveAtten_MaskMapOffsetStopOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveAtten_MaskMapChannel)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveAttenMaskOffsetCustomDataOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_VertexWaveAttenMaskOffsetCustomData)//default custom2.y
// ==================================================_DistortionOn
    // UNITY_DEFINE_INSTANCED_PROP(half,_DistortionOn) //DISTORTION_ON
    UNITY_DEFINE_INSTANCED_PROP(half,_DistortionMaskChannel)
    UNITY_DEFINE_INSTANCED_PROP(half,_DissolveMaskResampleOn) 
    UNITY_DEFINE_INSTANCED_PROP(half4,_DistortionMaskTex_ST)
    UNITY_DEFINE_INSTANCED_PROP(half,_DistortionIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half,_DistortionCustomDataOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_DistortionCustomData) // default uv1.z(Custom2.x)
    UNITY_DEFINE_INSTANCED_PROP(half4,_DistortTile)
    UNITY_DEFINE_INSTANCED_PROP(half4,_DistortDir)
    UNITY_DEFINE_INSTANCED_PROP(half,_DistortionRadialUVOn)
    UNITY_DEFINE_INSTANCED_PROP(half4,_DistortionRadialCenter_Scale)
    UNITY_DEFINE_INSTANCED_PROP(half,_DistortionRadialUVOffset)
    
    UNITY_DEFINE_INSTANCED_PROP(half,_DistortionRadialRot)
    UNITY_DEFINE_INSTANCED_PROP(half,_DistortionApplyToOffset)
    UNITY_DEFINE_INSTANCED_PROP(half,_DistortionApplyToMainTexMask)
    UNITY_DEFINE_INSTANCED_PROP(half,_DistortionApplyToDissolve)
// ==================================================_DissolveOn
    // UNITY_DEFINE_INSTANCED_PROP(half,_DissolveOn) //DISSOLVE_ON
    UNITY_DEFINE_INSTANCED_PROP(half,_DissolveByVertexColor)
    UNITY_DEFINE_INSTANCED_PROP(half,_DissolveCustomDataOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_DissolveCustomData) // default uv1.x(Custom1.z)
    UNITY_DEFINE_INSTANCED_PROP(half,_DissolveTexChannel)

    UNITY_DEFINE_INSTANCED_PROP(half,_DissolveMaskFromTexOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_DissolveMaskChannel)

    UNITY_DEFINE_INSTANCED_PROP(half4,_DissolveTex_ST)
    UNITY_DEFINE_INSTANCED_PROP(half,_DissolveTexOffsetStop)
    // UNITY_DEFINE_INSTANCED_PROP(half,_DissolveClipOn) //ALPHA_TEST
    UNITY_DEFINE_INSTANCED_PROP(half,_Cutoff)

    UNITY_DEFINE_INSTANCED_PROP(half,_PixelDissolveOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_PixelWidth)

    UNITY_DEFINE_INSTANCED_PROP(half,_DissolveEdgeOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_DissolveEdgeWidthCustomDataOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_DissolveEdgeWidthCustomData) // default uv1.y(Custom1.w)
    UNITY_DEFINE_INSTANCED_PROP(half,_EdgeWidth)
    UNITY_DEFINE_INSTANCED_PROP(half4,_EdgeColor)
    UNITY_DEFINE_INSTANCED_PROP(half4,_EdgeColor2)

    UNITY_DEFINE_INSTANCED_PROP(half,_DissolveFadingMin)
    UNITY_DEFINE_INSTANCED_PROP(half,_DissolveFadingMax)
// ==================================================_OffsetOn
    // UNITY_DEFINE_INSTANCED_PROP(half,_OffsetOn) //OFFSET_ON
    UNITY_DEFINE_INSTANCED_PROP(half,_StopAutoOffset)
    UNITY_DEFINE_INSTANCED_PROP(half,_OffsetCustomDataOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_OffsetLayer1_CustomData_X)
    UNITY_DEFINE_INSTANCED_PROP(half,_OffsetLayer1_CustomData_Y)

    UNITY_DEFINE_INSTANCED_PROP(half4,_OffsetMaskTex_ST)
    UNITY_DEFINE_INSTANCED_PROP(half,_OffsetMaskPanStop)
    UNITY_DEFINE_INSTANCED_PROP(half,_OffsetMaskChannel)
    UNITY_DEFINE_INSTANCED_PROP(half,_OffsetMaskApplyMainTexAlpha)
    
    UNITY_DEFINE_INSTANCED_PROP(half4,_OffsetTexColorTint)
    UNITY_DEFINE_INSTANCED_PROP(half4,_OffsetTexColorTint2)
    UNITY_DEFINE_INSTANCED_PROP(half4,_OffsetTile)
    UNITY_DEFINE_INSTANCED_PROP(half4,_OffsetDir)
    UNITY_DEFINE_INSTANCED_PROP(half,_OffsetBlendIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half,_OffsetBlendMode)
    UNITY_DEFINE_INSTANCED_PROP(half,_OffsetBlendReplaceMode)
    UNITY_DEFINE_INSTANCED_PROP(half,_OffsetBlendReplaceMode_Channel)
    // radial uv 
    UNITY_DEFINE_INSTANCED_PROP(half,_OffsetRadialUVOn)
    UNITY_DEFINE_INSTANCED_PROP(half4,_OffsetRadialCenter_Scale)
    UNITY_DEFINE_INSTANCED_PROP(half,_OffsetRadialRot)
    UNITY_DEFINE_INSTANCED_PROP(half,_OffsetRadialUVOffset)
    
// ==================================================_FresnelOn
    // UNITY_DEFINE_INSTANCED_PROP(half,_FresnelOn) //FRESNEL_ON
    UNITY_DEFINE_INSTANCED_PROP(half,_FresnelColorMode)
    UNITY_DEFINE_INSTANCED_PROP(half4,_FresnelColor)
    UNITY_DEFINE_INSTANCED_PROP(half4,_FresnelColor2)
    UNITY_DEFINE_INSTANCED_PROP(half,_FresnelPowerMin)
    UNITY_DEFINE_INSTANCED_PROP(half,_FresnelPowerMax)
    UNITY_DEFINE_INSTANCED_PROP(half,_BlendScreenColor)
    UNITY_DEFINE_INSTANCED_PROP(half,_FresnelAlphaBase)
    
// ==================================================_EnvReflectOn
    // UNITY_DEFINE_INSTANCED_PROP(half,_EnvReflectOn)
    UNITY_DEFINE_INSTANCED_PROP(half4,_EnvReflectionColor)
    // UNITY_DEFINE_INSTANCED_PROP(half4,_EnvMapMask_ST)
    UNITY_DEFINE_INSTANCED_PROP(half,_EnvMaskUseMainTexMask)
    UNITY_DEFINE_INSTANCED_PROP(half,_EnvMapMaskChannel)
    UNITY_DEFINE_INSTANCED_PROP(half,_EnvIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half4,_EnvOffset)
    UNITY_DEFINE_INSTANCED_PROP(half4,_EnvRotateInfo)
    UNITY_DEFINE_INSTANCED_PROP(half,_EnvRotateAutoStop)
    UNITY_DEFINE_INSTANCED_PROP(half4,_EnvRefractRotateInfo)
    UNITY_DEFINE_INSTANCED_PROP(half,_EnvRefractRotateAutoStop)    

    // UNITY_DEFINE_INSTANCED_PROP(half,_EnvRefractionOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_EnvRefractionIOR)
    UNITY_DEFINE_INSTANCED_PROP(half4,_EnvRefractionColor)
    UNITY_DEFINE_INSTANCED_PROP(half4,_EnvMap_HDR)
    UNITY_DEFINE_INSTANCED_PROP(half,_RefractMode)
// ==================================================_MatCapOn
    // UNITY_DEFINE_INSTANCED_PROP(half,_MatCapOn) // to keyword MATCAP_ON
    UNITY_DEFINE_INSTANCED_PROP(half4,_MatCapColor)
    UNITY_DEFINE_INSTANCED_PROP(half,_MatCapIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half,_MatCapRotateOn) // 
    UNITY_DEFINE_INSTANCED_PROP(half,_MatCapAngle)
// ==================================================    _DepthFadingOn
    // UNITY_DEFINE_INSTANCED_PROP(half,_DepthFadingOn) //DEPTH_FADING_ON
    UNITY_DEFINE_INSTANCED_PROP(half,_DepthFadingWidth)
    UNITY_DEFINE_INSTANCED_PROP(half,_DepthFadingMax)
// ==================================================   _Alpha 
    UNITY_DEFINE_INSTANCED_PROP(half,_AlphaMax)
    UNITY_DEFINE_INSTANCED_PROP(half,_AlphaMin)
    UNITY_DEFINE_INSTANCED_PROP(half,_AlphaScale)

// ==================================================   Light
    // UNITY_DEFINE_INSTANCED_PROP(half,_PbrLightOn)
    UNITY_DEFINE_INSTANCED_PROP(half,_CustomLightOn)
    UNITY_DEFINE_INSTANCED_PROP(half4,_CustomLightDir) 
    UNITY_DEFINE_INSTANCED_PROP(half4,_CustomLightColor) 
    UNITY_DEFINE_INSTANCED_PROP(half,_CustomLightColorUsage)

    UNITY_DEFINE_INSTANCED_PROP(half,_MainLightSoftShadowScale)
    // UNITY_DEFINE_INSTANCED_PROP(half,_CustomShadowNormalBias)
    // UNITY_DEFINE_INSTANCED_PROP(half,_CustomShadowDepthBias)

    UNITY_DEFINE_INSTANCED_PROP(half,_Metallic)
    UNITY_DEFINE_INSTANCED_PROP(half,_Smoothness)
    UNITY_DEFINE_INSTANCED_PROP(half,_Occlusion)

    UNITY_DEFINE_INSTANCED_PROP(half,_GIDiffuseOn)
    UNITY_DEFINE_INSTANCED_PROP(half4,_GIColorColor)

    UNITY_DEFINE_INSTANCED_PROP(half,_NormalMapOn) 
    UNITY_DEFINE_INSTANCED_PROP(half,_NormalMapScale)
    // UNITY_DEFINE_INSTANCED_PROP(half4,_NormalMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half,_AdditionalLightSoftShadowScale)
// ==================================================   Glitch
    UNITY_DEFINE_INSTANCED_PROP(half,_SnowFlakeIntensity)

    UNITY_DEFINE_INSTANCED_PROP(half4,_JitterInfo)
    
    UNITY_DEFINE_INSTANCED_PROP(half,_VerticalJumpIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half,_HorizontalShake)
    
    UNITY_DEFINE_INSTANCED_PROP(half,_ColorDriftSpeed)
    UNITY_DEFINE_INSTANCED_PROP(half,_ColorDriftIntensity)
    UNITY_DEFINE_INSTANCED_PROP(half,_HorizontalIntensity)
//--------------------------------- Fog
    UNITY_DEFINE_INSTANCED_PROP(half ,_FogOn)
    // UNITY_DEFINE_INSTANCED_PROP(half ,_FogNoiseOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_DepthFogOn)
    UNITY_DEFINE_INSTANCED_PROP(half ,_HeightFogOn)

//--------------------------------- Parallax
//#if defined(_PARALLAX)
    UNITY_DEFINE_INSTANCED_PROP(half ,_ParallaxIterate)
    UNITY_DEFINE_INSTANCED_PROP(half ,_ParallaxHeight)
    UNITY_DEFINE_INSTANCED_PROP(half ,_ParallaxMapChannel)
    // UNITY_DEFINE_INSTANCED_PROP(half4 ,_ParallaxMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half ,_ParallaxWeightOffset)
    
//#endif

// ================================================== UI
    // UNITY_DEFINE_INSTANCED_PROP(half4, _ClipRect)
    // UNITY_DEFINE_INSTANCED_PROP(half, _UIMaskSoftnessX)
    // UNITY_DEFINE_INSTANCED_PROP(half, _UIMaskSoftnessY)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)
    #define _MainUVAngle UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainUVAngle)
    #define _Color UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Color)
    #define _ColorScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ColorScale)
    #define _PerChannelColorOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_PerChannelColorOn)
    #define _ColorX UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ColorX)
    #define _ColorY UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ColorY)
    #define _ColorZ UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ColorZ)
    #define _MainTexSaturate UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexSaturate)
    #define _MainTexSingleChannelOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexSingleChannelOn)
    #define _MainTexChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexChannel)
    #define _MainTexMultiAlpha UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexMultiAlpha)
    #define _PremultiVertexColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_PremultiVertexColor)
    
    #define _VertexColorChannelOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexColorChannelOn)
    #define _VertexColorChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexColorChannel)
    #define _BackFaceOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_BackFaceOn)
    #define _BackFaceColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_BackFaceColor)
    #define _MainTex_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTex_ST)
    #define _MainTex_TexelSize UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTex_TexelSize)
    #define _MainTexOffsetStop UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexOffsetStop)
    #define _MainTexOffset_CustomData_On UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexOffset_CustomData_On)
    #define _MainTexOffset_CustomData_X UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexOffset_CustomData_X)
    #define _MainTexOffset_CustomData_Y UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexOffset_CustomData_Y) // default Custom1.xy

    #define _DoubleEffectOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DoubleEffectOn) //2层效果,
    #define _MainTexMask_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexMask_ST)
    #define _MainTexMaskOffsetStop UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexMaskOffsetStop)
    #define _MainTexMaskChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexMaskChannel)
    #define _MainTexMaskOffsetCustomDataOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexMaskOffsetCustomDataOn)
    #define _MainTexMaskOffsetCustomDataX UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexMaskOffsetCustomDataX)
    #define _MainTexMaskOffsetCustomDataY UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexMaskOffsetCustomDataY) // default Custom2.zw
    #define _MainTexUseScreenColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexUseScreenColor)
    #define _MainTexUseScreenUV UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexUseScreenUV)
    #define _FullScreenMode UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FullScreenMode)
    
    #define _MainTexSheet UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexSheet)
    #define _MainTexSheetAnimSpeed UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexSheetAnimSpeed)
    #define _MainTexSheetAnimBlendOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexSheetAnimBlendOn)
    // #define _MainTexSheetPlayOnce UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainTexSheetPlayOnce)
// ==================================================_VertexWaveOn
    // #define _VertexWaveOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveOn) // use VERTEX_WAVE_ON
    #define _NoiseUseAttenMaskMap UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_NoiseUseAttenMaskMap)
    #define _VertexWaveSpeed UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveSpeed)
    #define _VertexWaveSpeedManual UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveSpeedManual)
    #define _VertexWaveIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveIntensity)
    #define _VertexWaveIntensityCustomDataOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveIntensityCustomDataOn)
    #define _VertexWaveIntensityCustomData UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveIntensityCustomData)
    
    // vertex wave attenuations
    #define _VertexWaveAtten_VertexColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveAtten_VertexColor)
    #define _VertexWaveDirAtten UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveDirAtten)
    #define _VertexWaveDirAttenCustomDataOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveDirAttenCustomDataOn)
    #define _VertexWaveDirAttenCustomData UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveDirAttenCustomData)
    
    #define _VertexWaveDirAlongNormalOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveDirAlongNormalOn)
    #define _VertexWaveDirAtten_LocalSpaceOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveDirAtten_LocalSpaceOn)
    #define _VertexWaveAtten_NormalAttenOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveAtten_NormalAttenOn)
    #define _UVCircleDist2 UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_UVCircleDist2)

    #define _VertexWaveAtten_MaskMapOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveAtten_MaskMapOn)
    #define _VertexWaveAtten_MaskMap_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveAtten_MaskMap_ST)
    #define _VertexWaveAtten_MaskMapOffsetStopOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveAtten_MaskMapOffsetStopOn)
    #define _VertexWaveAtten_MaskMapChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveAtten_MaskMapChannel)
    #define _VertexWaveAttenMaskOffsetCustomDataOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveAttenMaskOffsetCustomDataOn)
    #define _VertexWaveAttenMaskOffsetCustomData UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VertexWaveAttenMaskOffsetCustomData)//default custom2.y
// ==================================================_DistortionOn
    #define _DistortionOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortionOn)
    #define _DistortionMaskChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortionMaskChannel)
    #define _DistortionMaskTex_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortionMaskTex_ST)
    #define _DissolveMaskResampleOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveMaskResampleOn) 
    #define _DistortionIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortionIntensity)
    #define _DistortionCustomDataOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortionCustomDataOn)
    #define _DistortionCustomData UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortionCustomData) // default uv1.z(Custom2.x)
    #define _DistortTile UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortTile)
    #define _DistortDir UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortDir)
    #define _DistortionRadialUVOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortionRadialUVOn)
    #define _DistortionRadialCenter_Scale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortionRadialCenter_Scale)
    #define _DistortionRadialUVOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortionRadialUVOffset)
    
    #define _DistortionRadialRot UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortionRadialRot)
    #define _DistortionApplyToOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortionApplyToOffset)
    #define _DistortionApplyToMainTexMask UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortionApplyToMainTexMask)
    #define _DistortionApplyToDissolve UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DistortionApplyToDissolve)
// ==================================================_DissolveOn
    #define _DissolveOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveOn)
    #define _DissolveByVertexColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveByVertexColor)
    #define _DissolveCustomDataOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveCustomDataOn)
    #define _DissolveCustomData UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveCustomData) // default uv1.x(Custom1.z)
    #define _DissolveTexChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveTexChannel)

    #define _DissolveMaskFromTexOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveMaskFromTexOn)
    #define _DissolveMaskChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveMaskChannel)

    #define _DissolveTex_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveTex_ST)
    #define _DissolveTexOffsetStop UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveTexOffsetStop)
    #define _DissolveClipOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveClipOn)
    #define _Cutoff UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Cutoff)

    #define _PixelDissolveOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_PixelDissolveOn)
    #define _PixelWidth UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_PixelWidth)

    #define _DissolveEdgeOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveEdgeOn)
    #define _DissolveEdgeWidthCustomDataOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveEdgeWidthCustomDataOn)
    #define _DissolveEdgeWidthCustomData UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveEdgeWidthCustomData) // default uv1.y(Custom1.w)
    #define _EdgeWidth UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EdgeWidth)
    #define _EdgeColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EdgeColor)
    #define _EdgeColor2 UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EdgeColor2)

    #define _DissolveFadingMin UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveFadingMin)
    #define _DissolveFadingMax UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DissolveFadingMax)
// ==================================================_OffsetOn
    #define _OffsetOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetOn)
    #define _StopAutoOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_StopAutoOffset)
    #define _OffsetCustomDataOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetCustomDataOn)
    #define _OffsetLayer1_CustomData_X UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetLayer1_CustomData_X)
    #define _OffsetLayer1_CustomData_Y UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetLayer1_CustomData_Y)

    #define _OffsetMaskTex_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetMaskTex_ST)
    #define _OffsetMaskPanStop UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetMaskPanStop)
    #define _OffsetMaskChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetMaskChannel)
    #define _OffsetMaskApplyMainTexAlpha UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetMaskApplyMainTexAlpha)
    
    #define _OffsetTexColorTint UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetTexColorTint)
    #define _OffsetTexColorTint2 UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetTexColorTint2)
    #define _OffsetTile UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetTile)
    #define _OffsetDir UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetDir)
    #define _OffsetBlendIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetBlendIntensity)
    #define _OffsetBlendMode UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetBlendMode)
    #define _OffsetBlendReplaceMode UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetBlendReplaceMode)
    #define _OffsetBlendReplaceMode_Channel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetBlendReplaceMode_Channel)
    // radial uv 
    #define _OffsetRadialUVOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetRadialUVOn)
    #define _OffsetRadialCenter_Scale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetRadialCenter_Scale)
    #define _OffsetRadialRot UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetRadialRot)
    #define _OffsetRadialUVOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_OffsetRadialUVOffset)
    
// ==================================================_FresnelOn
    #define _FresnelOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FresnelOn)
    #define _FresnelColorMode UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FresnelColorMode)
    #define _FresnelColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FresnelColor)
    #define _FresnelColor2 UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FresnelColor2)
    #define _FresnelPowerMin UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FresnelPowerMin)
    #define _FresnelPowerMax UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FresnelPowerMax)
    #define _BlendScreenColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_BlendScreenColor)
    #define _FresnelAlphaBase UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FresnelAlphaBase)
    
// ==================================================_EnvReflectOn
    #define _EnvReflectOn 1 //UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvReflectOn)
    #define _EnvReflectionColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvReflectionColor)
    // #define _EnvMapMask_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvMapMask_ST)
    #define _EnvMaskUseMainTexMask UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvMaskUseMainTexMask)
    #define _EnvMapMaskChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvMapMaskChannel)
    #define _EnvIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvIntensity)
    #define _EnvOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvOffset)
    #define _EnvRotateInfo UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvRotateInfo)
    #define _EnvRotateAutoStop UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvRotateAutoStop)
    #define _EnvRefractRotateInfo UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvRefractRotateInfo)
    #define _EnvRefractRotateAutoStop UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvRefractRotateAutoStop)

    #define _EnvRefractionOn 1 //UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvRefractionOn)
    #define _RefractMode UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_RefractMode)
    #define _EnvRefractionIOR UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvRefractionIOR)
    #define _EnvRefractionColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvRefractionColor)
    #define _EnvMap_HDR UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_EnvMap_HDR)
// ==================================================_MatCapOn
    // #define _MatCapOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MatCapOn) // to keyword MATCAP_ON
    #define _MatCapColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MatCapColor)
    #define _MatCapIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MatCapIntensity)
    #define _MatCapRotateOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MatCapRotateOn) // to keyword MATCAP_ROTATE_ON
    #define _MatCapAngle UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MatCapAngle)
// ==================================================    _DepthFadingOn
    #define _DepthFadingOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DepthFadingOn)
    #define _DepthFadingWidth UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DepthFadingWidth)
    #define _DepthFadingMax UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DepthFadingMax)
// ==================================================   _Alpha 
    #define _AlphaMax UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_AlphaMax)
    #define _AlphaMin UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_AlphaMin)
    #define _AlphaScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_AlphaScale)

// ==================================================   Light
    // #define _PbrLightOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_PbrLightOn)
    #define _CustomLightOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomLightOn)
    #define _CustomLightDir UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomLightDir)
    #define _CustomLightColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomLightColor)
    #define _CustomLightColorUsage UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomLightColorUsage)

    #define _MainLightSoftShadowScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_MainLightSoftShadowScale)
    // #define _CustomShadowNormalBias UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomShadowNormalBias)
    // #define _CustomShadowDepthBias UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_CustomShadowDepthBias)

    #define _Metallic UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Metallic)
    #define _Smoothness UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Smoothness)
    #define _Occlusion UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Occlusion)
    #define _GIDiffuseOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_GIDiffuseOn)  
    #define _GIColorColor UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_GIColorColor) 
    #define _NormalMapOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_NormalMapOn) 
    #define _NormalMapScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_NormalMapScale)
    // #define _NormalMap_ST UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_NormalMap_ST)
    #define _AdditionalLightSoftShadowScale UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_AdditionalLightSoftShadowScale)
// ==================================================   Glitch
    #define _SnowFlakeIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_SnowFlakeIntensity)

    #define _JitterInfo UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_JitterInfo)
    #define _VerticalJumpIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_VerticalJumpIntensity)
    #define _HorizontalShake UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_HorizontalShake)
    
    #define _ColorDriftSpeed UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ColorDriftSpeed)
    #define _ColorDriftIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ColorDriftIntensity)
    #define _HorizontalIntensity UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_HorizontalIntensity)
//--------------------------------- Fog
    #define _FogOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FogOn)
    // #define _FogNoiseOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_FogNoiseOn)
    #define _DepthFogOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_DepthFogOn)
    #define _HeightFogOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_HeightFogOn)

//--------------------------------- Parallax
    #define _ParallaxIterate UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ParallaxIterate)
    #define _ParallaxInVSOn UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ParallaxInVSOn)
    #define _ParallaxHeight UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ParallaxHeight)
    #define _ParallaxMapChannel UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ParallaxMapChannel)
    #define _ParallaxWeightOffset UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ParallaxWeightOffset)

// ================================================== UI
    // #define _ClipRect UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_ClipRect)
    // #define _UIMaskSoftnessX UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_UIMaskSoftnessX)
    // #define _UIMaskSoftnessY UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_UIMaskSoftnessY)
// ================================================== Global Varables
half4 _ClipRect;
half _UIMaskSoftnessX,_UIMaskSoftnessY;
#endif //POWER_VFX_INPUT_CGINC