#if !defined(POWER_VFX_DATA_CGINC)
#define POWER_VFX_DATA_CGINC
#include "TangentLib.cginc"

    struct appdata
    {
        half4 vertex : POSITION;
        half3 normal:NORMAL;
        half4 tangent:TANGENT;
        half4 color : COLOR;
        half4 uv : TEXCOORD0; // xy:main uv,zw : particle's customData(mainTex scroll)
        half4 uv1:TEXCOORD1; //particle's customData(x:dissolve,y:dissolveEdgeWidth,z : _VertexWaveAttenMask_UseCustomeData2_X)
    };

    struct v2f
    {
        half4 vertex : SV_POSITION;
        half4 color : COLOR;
        half3 reflectDir:COLOR1;
        half2 viewNormal:COLOR2;
        half3 refractDir:COLOR3;

        half4 uv : TEXCOORD0;
        half4 fresnal_customDataZ:TEXCOORD1;// x:fresnal,y:customData.x,z:_VertexWaveAttenMask_UseCustomeData2_X
        half4 grabPos:TEXCOORD2;
        TANGENT_SPACE_DECLARE(3,4,5);
    };


#endif //