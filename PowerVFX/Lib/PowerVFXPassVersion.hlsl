#if !defined(POWER_VFX_PASS_VERSION_HLSL)
#define POWER_VFX_PASS_VERSION_HLSL

#if defined(MIN_VERSION)
    #include "PowerVFXPassMinVersion.hlsl"
#else
    #include "PowerVFXPass.hlsl"
#endif

#endif //POWER_VFX_PASS_VERSION_HLSL