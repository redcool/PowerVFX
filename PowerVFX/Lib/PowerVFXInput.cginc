#if !defined(POWER_VFX_INPUT_CGINC)
#define POWER_VFX_INPUT_CGINC

    sampler2D _MainTex;
    sampler2D _MainTexMask;// (r,a)
    sampler2D _DistortionNoiseTex;//(xy : layer1,zw : layer2)
    sampler2D _DistortionMaskTex;//(r,a)
    sampler2D _DissolveTex;

    sampler2D _OffsetTex;
    sampler2D _OffsetMaskTex;//(r,a)
    sampler2D _CameraOpaqueTexture;
    samplerCUBE _EnvMap;
    sampler2D _EnvMapMask;//(r,a)
    
    sampler2D _MatCapTex;
    sampler2D _VertexWaveAtten_MaskMap;//r
    UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

    half3 _WorldSpaceLightDirection;

CBUFFER_START(UnityPerMaterial)
    half4 _Color;
    half _ColorScale;
    half _MainTexSaturate;
    int _MainTexSingleChannelOn;
    int _MainTexChannel;
    int _MainTexMultiAlpha;
    int _BackFaceOn;
    half4 _BackFaceColor;
    half4 _MainTex_ST;
    half _MainTexOffsetStop;
    half _MainTexOffsetUseCustomData_XY;

    half _DoubleEffectOn; //2层效果,
    half4 _MainTexMask_ST;
    half _MainTexMaskOffsetStop;
    int _MainTexMaskChannel;
    half _MainTexUseScreenColor;
// ==================================================
    half _VertexWaveOn;
    half _NoiseUseAttenMaskMap;
    half _VertexWaveSpeed;
    int _VertexWaveSpeedManual;
    half _VertexWaveIntensity;
    // vertex wave attenuations
    half _VertexWaveAtten_VertexColor;
    half4 _VertexWaveDirAtten;
    int _VertexWaveDirAlongNormalOn;
    int _VertexWaveDirAtten_LocalSpaceOn;
    int _VertexWaveAtten_NormalAttenOn;

    int _VertexWaveAtten_MaskMapOn;
    half4 _VertexWaveAtten_MaskMap_ST;
    int _VertexWaveAtten_MaskMapOffsetStopOn;
    int _VertexWaveAtten_MaskMapChannel;
    int _VertexWaveAttenMaskOffsetScale_UseCustomeData2_X;
// ==================================================
    half _DistortionOn;
    int _DistortionMaskChannel;
    half4 _DistortionMaskTex_ST;
    half _DistortionIntensity;
    half4 _DistortTile,_DistortDir;
    int _DistortionRadialUVOn;
    half4 _DistortionRadialCenter_LenScale_LenOffset;
    half _DistortionRadialRot;
    int _ApplyToOffset;
// ==================================================
    half _DissolveOn;
    half _DissolveByVertexColor;
    half _DissolveByCustomData_Z;
    half _DissolveTexChannel;
    half4 _DissolveTex_ST;
    half _DissolveTexOffsetStop;
    half _DissolveClipOn;
    half _Cutoff;

    half _PixelDissolveOn;
    half _PixelWidth;

    half _DissolveEdgeOn;
    half _DissolveEdgeWidthByCustomData_W;
    half _EdgeWidth;
    half4 _EdgeColor;
    half4 _EdgeColor2;

    half _DissolveFadingMin;
    half _DissolveFadingMax;
// ==================================================
    half _OffsetOn;
    half4 _OffsetMaskTex_ST;
    half _OffsetMaskChannel;
    half4 _OffsetTexColorTint,_OffsetTexColorTint2;
    half4 _OffsetTile,_OffsetDir;
    half _OffsetBlendIntensity;
    // radial uv 
    int _OffsetRadialUVOn;
    half4 _OffsetRadialCenter_LenScale_LenOffset;
    half _OffsetRadialRot;
// ==================================================
    half _FresnelOn;
    int _FresnelColorMode;
    half4 _FresnelColor,_FresnelColor2;
    half _FresnelPowerMin;
    half _FresnelPowerMax;
// ==================================================
    half _EnvReflectOn;
    half4 _EnvReflectionColor;
    half4 _EnvMapMask_ST;
    half _EnvMapMaskChannel;
    half _EnvIntensity;
    half4 _EnvOffset;

    int _EnvRefractionOn;
    half _EnvRefractionIOR;
    half4 _EnvRefractionColor;
// ==================================================
    int _MatCapOn;
    half4 _MatCapColor;
    half _MatCapIntensity;
    int _MatCapRotateOn;
    half _MatCapAngle;
// ==================================================    
    int _DepthFadingOn;
    half _DepthFadingWidth;
    half _LightOn;
// ==================================================    
    half _AlphaMax,_AlphaMin,_AlphaScale;

CBUFFER_END
#endif //POWER_VFX_INPUT_CGINC