#if !defined(UTIL_LIB_CGINC)
#define UTIL_LIB_CGINC
#define FLT_MIN  1.175494351e-38
// ---- custom symbols
#define if UNITY_BRANCH if
#define for UNITY_LOOP for
#include "../../../PowerShaderLib/Lib/MathLib.hlsl"

float SafeDiv(float numer, float denom)
{
    return (numer != denom) ? numer / denom : 1;
}
float3 SafeNormalize(float3 inVec)
{
    float3 dp3 = max(FLT_MIN, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

/**
    uv_t : uv translation part,like _MainTex_ST.zw
    autoStop : a switch
    return : uv_t or uv_t + _Time.xx
*/
float2 UVOffset(float2 uv_t,float autoStop){
    return uv_t * ( 1+ _Time.xx *( 1 - autoStop) );
}

half3 UnpackScaleNormalRGorAG(half4 packednormal, half bumpScale)
{
    #if defined(UNITY_NO_DXT5nm)
        half3 normal = packednormal.xyz * 2 - 1;
        #if (SHADER_TARGET >= 30)
            // SM2.0: instruction count limitation
            // SM2.0: normal scaler is not supported
            normal.xy *= bumpScale;
        #endif
        return normal;
    #elif defined(UNITY_ASTC_NORMALMAP_ENCODING)
        half3 normal;
        normal.xy = (packednormal.wy * 2 - 1);
        normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
        normal.xy *= bumpScale;
        return normal;
    #else
        // This do the trick
        packednormal.x *= packednormal.w;

        half3 normal;
        normal.xy = (packednormal.xy * 2 - 1);
        #if (SHADER_TARGET >= 30)
            // SM2.0: instruction count limitation
            // SM2.0: normal scaler is not supported
            normal.xy *= bumpScale;
        #endif
        normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
        return normal;
    #endif
}

half3 UnpackScaleNormal(half4 packednormal, half bumpScale)
{
    return UnpackScaleNormalRGorAG(packednormal, bumpScale);
}

#endif //UTIL_LIB_CGINC