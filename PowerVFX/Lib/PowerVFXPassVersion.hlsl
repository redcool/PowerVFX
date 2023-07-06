#if !defined(POWER_VFX_PASS_VERSION_HLSL)
#define POWER_VFX_PASS_VERSION_HLSL

// #if !defined(PBR_LIGHTING) &&!defined(ADDITIONAL_LIGHT_SHADOWS_SOFT) &&!defined(ERTEX_WAVE_ON) &&!defined(RESNEL_ON) &&!defined(LPHA_TEST) &&!defined(ISTORTION_ON) &&!defined(ISSOLVE_ON) &&!defined(FFSET_ON) &&!defined(NV_REFLECT_ON) &&!defined(NV_REFRACTION_ON) &&!defined(ATCAP_ON) &&!defined(ATCAP_ROTATE_ON) &&!defined(EPTH_FADING_ON) &&!defined(OUBLE_EFFECT_ON) &&!defined(OFFSET_BLEND_REPLACE_MODE) &&!defined(HEET_ANIM_BLEND_ON)
//     #define MIN_VERSION
// #endif

/**
    uncomments this, if you wanna use custom min version
*/
// #define CUSTOM_MIN_VERSION

#if defined(CUSTOM_MIN_VERSION)
    #include "PowerVFXPassMinVersionCustom.hlsl"    // custom min version
#elif defined(MIN_VERSION)
    #include "PowerVFXPassMinVersion.hlsl"  // standard min version
#else
    #include "PowerVFXPass.hlsl"    //standard version
#endif

#endif //POWER_VFX_PASS_VERSION_HLSL