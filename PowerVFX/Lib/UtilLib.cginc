#if !defined(UTIL_LIB_CGINC)
#define UTIL_LIB_CGINC
#define FLT_MIN  1.175494351e-38
// ---- custom symbols
#define if UNITY_BRANCH if
#define for UNITY_LOOP
#define float half

float SafeDiv(float numer, float denom)
{
    return (numer != denom) ? numer / denom : 1;
}
float3 SafeNormalize(float3 inVec)
{
    float3 dp3 = max(FLT_MIN, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

#endif //UTIL_LIB_CGINC