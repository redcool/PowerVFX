#if !defined(COMMON_LIB_INC)
#define COMMON_LIB_INC
#define FLT_MIN  1.175494351e-38
// ---- custom symbols
#define branch_if UNITY_BRANCH if
#define loop_for UNITY_LOOP for

// #define USE_URP
#include "../../../PowerShaderLib/Lib/UnityLib.hlsl"
#include "../../../PowerShaderLib/Lib/MathLib.hlsl"
#include "../../../PowerShaderLib/Lib/PowerUtils.hlsl"
// #include "../../../PowerShaderLib/Lib/Fragment.hlsl"

#endif //COMMON_LIB_INC