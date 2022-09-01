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




#endif //UTIL_LIB_CGINC