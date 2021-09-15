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

    float3 _WorldSpaceLightDirection;

CBUFFER_START(UnityPerMaterial)
    float4 _Color;
    float _ColorScale;
    float _MainTexSaturate;
    int _MainTexSingleChannelOn;
    int _MainTexChannel;
    int _MainTexMultiAlpha;
    int _BackFaceOn;
    float4 _BackFaceColor;
    half4 _MainTex_ST;
    float _MainTexOffsetStop;
    float _MainTexOffsetUseCustomData_XY;

    float _DoubleEffectOn; //2层效果,
    float4 _MainTexMask_ST;
    float _MainTexMaskOffsetStop;
    int _MainTexMaskChannel;
    float _MainTexUseScreenColor;
// ==================================================
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
// ==================================================
    float _DistortionOn;
    int _DistortionMaskChannel;
    float _DistortionIntensity;
    float4 _DistortTile,_DistortDir;
    int _DistortionRadialUVOn;
    float4 _DistortionRadialCenter_LenScale_LenOffset;
    float _DistortionRadialRot;
    int _ApplyToOffset;
// ==================================================
    float _DissolveOn;
    float _DissolveByVertexColor;
    float _DissolveByCustomData_Z;
    float _DissolveTexChannel;
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
// ==================================================
    float _OffsetOn;
    float _OffsetMaskChannel;
    float4 _OffsetTexColorTint,_OffsetTexColorTint2;
    float4 _OffsetTile,_OffsetDir;
    float _OffsetBlendIntensity;
    // radial uv 
    int _OffsetRadialUVOn;
    float4 _OffsetRadialCenter_LenScale_LenOffset;
    float _OffsetRadialRot;
// ==================================================
    float _FresnelOn;
    int _FresnelMultiVertexColor;
    float4 _FresnelColor,_FresnelColor2;
    float _FresnelPowerMin;
    float _FresnelPowerMax;
// ==================================================
    float _EnvReflectOn;
    float4 _EnvReflectionColor;
    float _EnvMapMaskChannel;
    float _EnvIntensity;
    float4 _EnvOffset;

    int _EnvRefractionOn;
    float _EnvRefractionIOR;
    float4 _EnvRefractionColor;
// ==================================================
    int _MatCapOn;
    float4 _MatCapColor;
    float _MatCapIntensity;
    int _MatCapRotateOn;
    float _MatCapAngle;
// ==================================================    
    int _DepthFadingOn;
    float _DepthFadingWidth;
    float _LightOn;
CBUFFER_END
#endif //POWER_VFX_INPUT_CGINC