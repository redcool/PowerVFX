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

CBUFFER_START(UnityPerMaterial)
half _MainUVAngle;
half4 _Color;
half _ColorScale;
half _PerChannelColorOn;
half4 _ColorX;
half4 _ColorY;
half4 _ColorZ;

half _MainTexSaturate;
half _MainTexSingleChannelOn;
half _MainTexChannel;
half _MainTexMultiAlpha;
half _PremultiVertexColor;
half _VertexColorChannelOn;
half _VertexColorChannel;
    
    
half _BackFaceOn;
half4 _BackFaceColor;
half4 _MainTex_ST;
half4 _MainTex_TexelSize;
half _MainTexOffsetStop;
half _MainTexOffset_CustomData_On;
half _MainTexOffset_CustomData_X;
half _MainTexOffset_CustomData_Y; // default Custom1.xy

half _DoubleEffectOn; //2层效果,
half4 _MainTexMask_ST;
half _MainTexMaskOffsetStop;
half _MainTexMaskChannel;
half _MainTexMaskOffsetCustomDataOn;
half _MainTexMaskOffsetCustomDataX;
half _MainTexMaskOffsetCustomDataY; // default Custom2.zw
half _MainTexUseScreenColor;
half _MainTexUseScreenUV;
half _FullScreenMode;
    
half2 _MainTexSheet;
half _MainTexSheetAnimSpeed;
half _MainTexSheetAnimBlendOn;
half _MainTexSheetPlayOnce;
// ==================================================_VertexWaveOn
half _VertexWaveOn;
half _NoiseUseAttenMaskMap;
half _VertexWaveSpeed;
half _VertexWaveSpeedManual;
half _VertexWaveIntensity;
  
half _VertexWaveIntensityCustomDataOn;
half _VertexWaveIntensityCustomData;

    // vertex wave attenuations
half _VertexWaveAtten_VertexColor;
half4 _VertexWaveDirAtten;
half _VertexWaveDirAttenCustomDataOn;
half _VertexWaveDirAttenCustomData;
half _VertexWaveDirAlongNormalOn;
half _VertexWaveDirAtten_LocalSpaceOn;
half _VertexWaveAtten_NormalAttenOn;
half _UVCircleDist2;
    
half _VertexWaveAtten_MaskMapOn;
half4 _VertexWaveAtten_MaskMap_ST;
half _VertexWaveAtten_MaskMapOffsetStopOn;
half _VertexWaveAtten_MaskMapChannel;
half _VertexWaveAttenMaskOffsetCustomDataOn;
half _VertexWaveAttenMaskOffsetCustomData;//default custom2.y
// ==================================================_DistortionOn
half _DistortionOn; //DISTORTION_ON
half _DistortionMaskChannel;
half _DissolveMaskResampleOn; 
half4 _DistortionMaskTex_ST;
half _DistortionIntensity;
half _DistortionCustomDataOn;
half _DistortionCustomData; // default uv1.z(Custom2.x)
half4 _DistortTile;
half4 _DistortDir;
half _DistortionRadialUVOn;
half4 _DistortionRadialCenter_Scale;
half _DistortionRadialUVOffset;
    
half _DistortionRadialRot;
    
half _DistortionApplyToMainTex;
half _DistortionApplyToOffset;
half _DistortionApplyToMainTexMask;
half _DistortionApplyToDissolve;
// ==================================================_DissolveOn
half _DissolveOn; //DISSOLVE_ON
half _DissolveByVertexColor;
half _DissolveCustomDataOn;
half _DissolveCustomData; // default uv1.x(Custom1.z)
half _DissolveTexChannel;
half _DissolveUVType;
    

half _DissolveMaskFromTexOn;
half _DissolveMaskChannel;

half4 _DissolveTex_ST;
half4 _DissolveMask_ST;
half _DissolveTexOffsetStop;
half _DissolveClipOn; //ALPHA_TEST
half _Cutoff;

half _PixelDissolveOn;
half _PixelWidth;

half _DissolveEdgeOn;
half _DissolveEdgeWidthCustomDataOn;
half _DissolveEdgeWidthCustomData; // default uv1.y(Custom1.w)
half _EdgeWidth;
half4 _EdgeColor;
half4 _EdgeColor2;

half _DissolveFadingMin;
half _DissolveFadingMax;
// ==================================================_OffsetOn
half _OffsetOn; //OFFSET_ON
half _StopAutoOffset;
half _OffsetCustomDataOn;
half _OffsetLayer1_CustomData_X;
half _OffsetLayer1_CustomData_Y;

half4 _OffsetMaskTex_ST;
half _OffsetMaskPanStop;
half _OffsetMaskChannel;
half _OffsetMaskApplyMainTexAlpha;
    
half4 _OffsetTexColorTint;
half4 _OffsetTexColorTint2;
half4 _OffsetTile;
half4 _OffsetDir;
half _OffsetBlendIntensity;
half _OffsetBlendMode;
half _OffsetBlendReplaceMode;
half _OffsetBlendReplaceMode_Channel;
    // radial uv 
half _OffsetRadialUVOn;
half4 _OffsetRadialCenter_Scale;
half _OffsetRadialRot;
half _OffsetRadialUVOffset;
    
// ==================================================_FresnelOn
half _FresnelOn;
// #define _FresnelOn 1
half _FresnelColorMode;
half4 _FresnelColor;
half4 _FresnelColor2;
half _FresnelPowerMin;
half _FresnelPowerMax;
half _BlendScreenColor;
half _FresnelAlphaBase;
    
// ==================================================_EnvReflectOn
// half _EnvReflectOn;
#define _EnvReflectOn 1
half4 _EnvReflectionColor;
half4 _EnvMapMask_ST;
half _EnvMaskUseMainTexMask;
half _EnvMapMaskChannel;
half _EnvIntensity;
half4 _EnvOffset;
half4 _EnvRotateInfo;
half _EnvRotateAutoStop;
half4 _EnvRefractRotateInfo;
half _EnvRefractRotateAutoStop;    

// half _EnvRefractionOn;
#define _EnvRefractionOn 1
half _EnvRefractionIOR;
half4 _EnvRefractionColor;
half4 _EnvMap_HDR;
half _RefractMode;
// ==================================================_MatCapOn
half _MatCapOn; // to keyword MATCAP_ON
half4 _MatCapColor;
half _MatCapIntensity;
half _MatCapRotateOn; // 
half _MatCapAngle;
// ==================================================    _DepthFadingOn
half _DepthFadingOn; //DEPTH_FADING_ON
half _DepthFadingWidth;
half _DepthFadingMax;
half4 _DepthFadingColor;
// ==================================================   _Alpha 
half _AlphaMax;
half _AlphaMin;
half _AlphaScale;
half _OverrideAlphaChannel;
half _ViewFadingDist;
// ==================================================   Light
half _PbrLightOn;
half _CustomLightOn;
half4 _CustomLightDir; 
half4 _CustomLightColor; 
half _CustomLightColorUsage;

half _MainLightSoftShadowScale;
half _CustomShadowNormalBias;
half _CustomShadowDepthBias;

half _Metallic;
half _Smoothness;
half _Occlusion;

half _GIDiffuseOn;
half4 _GIColorColor;

half _NormalMapOn; 
half _NormalMapScale;
half4 _NormalMap_ST;
half _AdditionalLightSoftShadowScale;
// ==================================================   Glitch
half _SnowFlakeIntensity;

half4 _JitterInfo;
    
half _VerticalJumpIntensity;
half _HorizontalShake;
    
half _ColorDriftSpeed;
half _ColorDriftIntensity;
half _HorizontalIntensity;
//--------------------------------- Fog
half _FogOn;
half _FogNoiseOn;
half _DepthFogOn;
half _HeightFogOn;

//--------------------------------- Parallax
//#if defined(_PARALLAX)
half _ParallaxIterate;
half _ParallaxHeight;
half _ParallaxMapChannel;
half4 _ParallaxMap_ST;
half _ParallaxWeightOffset;
    
//#endif
// ================================================== sprite
float3 _SpriteUVStart;

CBUFFER_END

// ================================================== Global Varables
half4 _ClipRect;
half _UIMaskSoftnessX,_UIMaskSoftnessY;

#endif //POWER_VFX_INPUT_CGINC