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

CBUFFER_START(UnityPerMaterial)
    fixed4 _Color;
    float _ColorScale;
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
    float _VertexWaveSpeed;
    float _VertexWaveIntensity;
    // vertex wave attenuations
    float _VertexWaveAtten_VertexColor;
    float4 _VertexWaveDirAtten;
    int _VertexWaveDirAtten_LocalSpaceOn;
    int _VertexWaveAtten_NormalAttenOn;

    int _VertexWaveAtten_MaskMapOn;
    float4 _VertexWaveAtten_MaskMap_ST;
    int _VertexWaveAtten_MaskMapOffsetStopOn;
    int _VertexWaveAtten_MaskMapChannel;
// ==================================================
    float _DistortionOn;
    int _DistortionMaskChannel;
    float _DistortionIntensity;
    float4 _DistortTile,_DistortDir;
// ==================================================
    float _DissolveOn;
    float _DissolveRevert;
    float _DissolveByVertexColor;
    float _DissolveByCustomData;
    float _DissolveTexChannel;
    float4 _DissolveTex_ST;
    float _DissolveTexOffsetStop;
    float _DissolveClipOn;
    float _Cutoff;

    float _PixelDissolveOn;
    float _PixelWidth;

    float _DissolveEdgeOn;
    float _DissolveEdgeWidthBy_Custom1;
    float _EdgeWidth;
    float4 _EdgeColor;
    float4 _EdgeColor2;

    float _DissolveFadingOn;
    float _DissolveFading;
    float _DissolveFadingWidth;
// ==================================================
    float _OffsetOn;
    float _OffsetMaskTexUseR;
    float4 _OffsetTexColorTint,_OffsetTexColorTint2;
    float4 _OffsetTile,_OffsetDir;
    float _BlendIntensity;
// ==================================================
    float _FresnelOn;
    int _FresnelInvertOn;
    float4 _FresnelColor;
    float _FresnelPower;
    float _FresnelTransparentOn;
    float _FresnelTransparent;
// ==================================================
    float _EnvReflectOn;
    float _EnvMapMaskUseR;
    float _EnvIntensity;
    float4 _EnvOffset;
// ==================================================
    int _MatCapOn;
    float _MatCapIntensity;
CBUFFER_END
#endif //POWER_VFX_INPUT_CGINC