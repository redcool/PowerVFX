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
    // samplerCUBE _EnvMap;
    TEXTURECUBE(_EnvMap);SAMPLER(sampler_EnvMap);
    sampler2D _PbrMask;//(r,a)
    
    sampler2D _MatCapTex;
    sampler2D _VertexWaveAtten_MaskMap;//r
    sampler2D _CameraDepthTexture;
    sampler2D _NormalMap;

    // float4 _MainLightPosition;
    // float4 _MainLightColor;

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
    int _MainTexOffset_CustomData_On,_MainTexOffset_CustomData_X,_MainTexOffset_CustomData_Y; // default Custom1.xy

    float _DoubleEffectOn; //2层效果,
    float4 _MainTexMask_ST;
    float _MainTexMaskOffsetStop;
    int _MainTexMaskChannel;
    int _MainTexMaskOffsetCustomDataOn,_MainTexMaskOffsetCustomDataX,_MainTexMaskOffsetCustomDataY; // default Custom2.zw
    float _MainTexUseScreenColor;
    half2 _MainTexSheet;
    half _MainTexSheetAnimSpeed;
    // int _MainTexSheetPlayOnce;
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
    int _VertexWaveAttenMaskOffsetCustomDataOn,_VertexWaveAttenMaskOffsetCustomData;//default custom2.y
// ==================================================_DistortionOn
    float _DistortionOn;
    int _DistortionMaskChannel;
    float4 _DistortionMaskTex_ST;
    float _DistortionIntensity;
    int _DistortionCustomDataOn , _DistortionCustomData; // default uv1.z(Custom2.x)
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
    int _DissolveCustomDataOn,_DissolveCustomData; // default uv1.x(Custom1.z)
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
    int _DissolveEdgeWidthCustomDataOn,_DissolveEdgeWidthCustomData ; // default uv1.y(Custom1.w)
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
    // int _MatCapOn; // to keyword MATCAP_ON
    float4 _MatCapColor;
    float _MatCapIntensity;
    // int _MatCapRotateOn; // to keyword MATCAP_ROTATE_ON
    float _MatCapAngle;
// ==================================================    _DepthFadingOn
    int _DepthFadingOn;
    float _DepthFadingWidth;
    float _DepthFadingMax;
// ==================================================   _Alpha 
    float _AlphaMax,_AlphaMin,_AlphaScale;

// ==================================================   Light
    // float _PbrLightOn;
    half _MainLightSoftShadowScale;
    float _Metallic,_Smoothness,_Occlusion;
    float _NormalMapScale;
    // float4 _NormalMap_ST;
CBUFFER_END
#endif //POWER_VFX_INPUT_CGINC