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
    sampler2D _PbrMask;//(r,a)
    
    sampler2D _MatCapTex;
    sampler2D _VertexWaveAtten_MaskMap;//r
    UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
    sampler2D _NormalMap;

    float4 _MainLightPosition;
    float4 _MainLightColor;

CBUFFER_START(UnityPerMaterial)
    float _MainUVAngle;
    float4 _Color;
    float _ColorScale;
    float _MainTexSaturate;
    int _MainTexSingleChannelOn;
    int _MainTexChannel;
    int _MainTexMultiAlpha;
    int _BackFaceOn;
    float4 _BackFaceColor;
    float4 _MainTex_ST;
    float4 _MainTex_TexelSize;
    float _MainTexOffsetStop;
    float _MainTexOffsetUseCustomData_XY;

    float _DoubleEffectOn; //2层效果,
    float4 _MainTexMask_ST;
    float _MainTexMaskOffsetStop;
    int _MainTexMaskChannel;
    float _MainTexUseScreenColor;
// ==================================================_VertexWaveOn
    float _VertexWaveOn;
    float _NoiseUseAttenMaskMap;
    float _VertexWaveSpeed;
    int _VertexWaveSpeedManual;
    float _VertexWaveIntensity;
    // vertex wave attenuations
    float _VertexWaveAtten_VertexColor;
    float4 _VertexWaveDirAtten;
    int _VertexWaveDirAlongNormalOn;
    int _VertexWaveDirAtten_LocalSpaceOn;
    int _VertexWaveAtten_NormalAttenOn;

    int _VertexWaveAtten_MaskMapOn;
    float4 _VertexWaveAtten_MaskMap_ST;
    int _VertexWaveAtten_MaskMapOffsetStopOn;
    int _VertexWaveAtten_MaskMapChannel;
    int _VertexWaveAttenMaskOffsetScale_UseCustomeData2_X;
// ==================================================_DistortionOn
    float _DistortionOn;
    int _DistortionMaskChannel;
    float4 _DistortionMaskTex_ST;
    float _DistortionIntensity;
    float _DistortionByCustomData_Vector2_X;
    float4 _DistortTile,_DistortDir;
    int _DistortionRadialUVOn;
    float4 _DistortionRadialCenter_LenScale_LenOffset;
    float _DistortionRadialRot;
    int _DistortionApplyToOffset;
    int _DistortionApplyToMainTexMask;
    int _DistortionApplyToDissolve;
// ==================================================_DissolveOn
    float _DissolveOn;
    float _DissolveByVertexColor;
    float _DissolveByCustomData_Z;
    float _DissolveTexChannel;

    float _DissolveMaskFromTexOn;
    float _DissolveMaskChannel;

    float4 _DissolveTex_ST;
    float _DissolveTexOffsetStop;
    float _DissolveClipOn;
    float _Cutoff;

    float _PixelDissolveOn;
    float _PixelWidth;

    float _DissolveEdgeOn;
    float _DissolveEdgeWidthByCustomData_W;
    float _EdgeWidth;
    float4 _EdgeColor;
    float4 _EdgeColor2;

    float _DissolveFadingMin;
    float _DissolveFadingMax;
// ==================================================_OffsetOn
    float _OffsetOn;
    float4 _OffsetMaskTex_ST;
    float _OffsetMaskPanStop;
    float _OffsetMaskChannel;
    float4 _OffsetTexColorTint,_OffsetTexColorTint2;
    float4 _OffsetTile,_OffsetDir;
    float _OffsetBlendIntensity;
    float _OffsetBlendMode;
    // radial uv 
    int _OffsetRadialUVOn;
    float4 _OffsetRadialCenter_LenScale_LenOffset;
    float _OffsetRadialRot;
// ==================================================_FresnelOn
    float _FresnelOn;
    int _FresnelColorMode;
    float4 _FresnelColor,_FresnelColor2;
    float _FresnelPowerMin;
    float _FresnelPowerMax;
    float _BlendScreenColor;
    
// ==================================================_EnvReflectOn
    float _EnvReflectOn;
    float4 _EnvReflectionColor;
    float4 _EnvMapMask_ST;
    int _EnvMaskUseMainTexMask;
    float _EnvMapMaskChannel;
    float _EnvIntensity;
    float4 _EnvOffset;

    int _EnvRefractionOn;
    float _EnvRefractionIOR;
    float4 _EnvRefractionColor;
    float4 _EnvMap_HDR;
// ==================================================_MatCapOn
    int _MatCapOn;
    float4 _MatCapColor;
    float _MatCapIntensity;
    int _MatCapRotateOn;
    float _MatCapAngle;
// ==================================================    _DepthFadingOn
    int _DepthFadingOn;
    float _DepthFadingWidth;
// ==================================================   _Alpha 
    float _AlphaMax,_AlphaMin,_AlphaScale;

// ==================================================   Light
    // float _PbrLightOn;
    float _Metallic,_Smoothness,_Occlusion;
    float _NormalMapScale;
CBUFFER_END
#endif //POWER_VFX_INPUT_CGINC