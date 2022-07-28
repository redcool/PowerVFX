#if !defined(POWER_VFX_DATA_CGINC)
#define POWER_VFX_DATA_CGINC
#include "../../PowerShaderLib/Lib/TangentLib.hlsl"

    struct appdata
    {
        float4 vertex : POSITION;
        float3 normal:NORMAL;
        float4 tangent:TANGENT;
        float4 color : COLOR;
        float4 uv : TEXCOORD0; // xy:main uv,zw : particle's customData(mainTex scroll)
        float4 uv1:TEXCOORD1; //particle's customData(x:dissolve,y:dissolveEdgeWidth,z : _VertexWaveAttenMask_UseCustomeData2_X)
    };

    struct v2f
    {
        float4 vertex : SV_POSITION;
        float4 color : COLOR;
        float3 reflectDir:COLOR1;
        float2 viewNormal:COLOR2;
        float3 refractDir:COLOR3;
        float4 uv : TEXCOORD0;
        float4 fresnal_customDataZ:TEXCOORD1;// x:fresnal,y:customData.x,z:_VertexWaveAttenMask_UseCustomeData2_X
        float4 grabPos:TEXCOORD2;
        TANGENT_SPACE_DECLARE(3,4,5);
        UNITY_FOG_COORDS(6)
    };


#endif //