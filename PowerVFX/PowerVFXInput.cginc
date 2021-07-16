#if !defined(POWER_VFX_INPUT_CGINC)
#define POWER_VFX_INPUT_CGINC

    sampler2D _MainTex;
    sampler2D _MainTexMask;
    sampler2D _NoiseTex;
    sampler2D _NoiseTex2;
    sampler2D _DistortionMaskTex;

    sampler2D _DissolveTex;
    sampler2D _OffsetTex;
    sampler2D _OffsetMaskTex;
    sampler2D _CameraOpaqueTexture;
    samplerCUBE _EnvMap;

    sampler2D _EnvMapMask;
    sampler2D _MatCapTex;

CBUFFER_START(UnityPerMaterial)
    fixed4 _Color;
    float _ColorScale;
    half4 _MainTex_ST;
    float _MainTexOffsetStop;
    float _MainTexOffsetUseCustomData_XY;

    float _DoubleEffectOn; //2层效果,
    float4 _MainTexMask_ST;
    float _MainTexMaskOffsetStop; //
    float _MainTexMaskUseR;
    float _MainTexUseScreenColor;
// ==================================================
    float _VertexWaveOn;
    float _VertexWaveSpeed;
    float _VertexWaveIntensity;
    // vertex wave attenuations
    float3 _VertexWaveDirAtten;
    float _VertexWaveAtten_VertexColor;
    float _VertexWaveAtten_ForwardAtten;
    float _VertexWaveForawdLength;
// ==================================================
    // #if defined(DISTORTION_ON)
        float _DistortionOn;
        float _DistortionNoiseTex2On;
        float _DistortionMaskUseR;
        float _DistortionIntensity;
        float4 _DistortTile,_DistortDir;
    // #endif

    // #if defined(DISSOLVE_ON)
        float _DissolveOn;
        float _DissolveRevert;
        float _DissolveByVertexColor;
        float _DissolveByCustomData;
        float _DissolveTexUseR;
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
    // #endif

    // #if defined(OFFSET_ON)
        float _OffsetOn;
        float _OffsetMaskTexUseR;
        float4 _OffsetTexColorTint,_OffsetTexColorTint2;
        float4 _OffsetTile,_OffsetDir;
        float _BlendIntensity;
    // #endif


    // #if defined(FRESNAL_ON)
    float _FresnelOn;
    float4 _FresnelColor;
    float _FresnelPower;
    float _FresnelTransparentOn;
    float _FresnelTransparent;
    // #endif

    // #if defined(ENV_REFLECT)
    float _EnvReflectOn;
    float _EnvMapMaskUseR;
    float _EnvIntensity;
    float4 _EnvOffset;
    // #endif


    float _MatCapIntensity;
CBUFFER_END
#endif //POWER_VFX_INPUT_CGINC