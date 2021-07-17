#if !defined(POWER_VFX_PASS_CGINC)
#define POWER_VFX_PASS_CGINC
#include "UnityCG.cginc"
#include "PowerVFXCore.cginc"

v2f vert(appdata v)
    {
        float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
        float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos.xyz));
        float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));

        v2f o = (v2f)0;
        o.color = v.color;
        if(_VertexWaveOn){
            ApplyVertexWaveWorldSpace(worldPos.xyz/**/,worldNormal,v.color,v.uv);
        }
        o.vertex = UnityWorldToClipPos(worldPos);

        o.uv = v.uv; // uv.xy : main uv, zw : custom data.xy
        o.uv.xy = v.uv;
        o.grabPos = ComputeGrabScreenPos(o.vertex);


        float3 normalDistorted = normalize(worldNormal + _EnvOffset.xyz);
        if(_EnvReflectOn)
            o.reflectDir = reflect(- viewDir,normalDistorted);
        if(_EnvRefractionOn)
            o.refractDir = refract(-viewDir,normalDistorted,1/_EnvRefractionIOR);

        float3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_MV,v.normal));
        o.viewNormal = viewNormal.xy * 0.5 + 0.5;

        if(_FresnelOn)
            o.fresnal_customDataZ.x = 1 - dot(worldNormal,viewDir) ;

        o.fresnal_customDataZ.y = v.uv1.x;// particle custom data (Custom1).z
        o.fresnal_customDataZ.z = v.uv1.y; // particle custom data (Custom1).w
        return o;
    }
    fixed4 frag(v2f i) : SV_Target
    {
        half4 mainColor = float4(0,0,0,1);
        // setup mainUV
        float4 mainUV = MainTexOffset(i.uv);
        float dissolveCustomData = i.fresnal_customDataZ.y;
        float dissolveEdgeWidth = i.fresnal_customDataZ.z;

        //use _CameraOpaqueTexture
        mainUV.xy = _MainTexUseScreenColor == 0 ? mainUV.xy : i.grabPos.xy/i.grabPos.w;

        if(_DistortionOn){
            float4 distortUV = mainUV.zwzw * _DistortTile + frac(_DistortDir * _Time.xxxx);
            ApplyDistortion(mainColor,mainUV,distortUV,i.color);
        }else{
            mainColor = SampleMainTex(mainUV.xy,i.color);
        }

        ApplyMainTexMask(mainColor,mainUV.zw);

        if(_EnvReflectOn || _EnvRefractionOn)
            ApplyEnv(mainColor,mainUV.zw,i.reflectDir,i.refractDir);

        if(_OffsetOn){
            float4 offsetUV = mainUV.zwzw * _OffsetTile + (_Time.xxxx * _OffsetDir); //暂时去除 frac
            ApplyOffset(mainColor,offsetUV,mainUV.zw);
        }

        //dissolve
        if(_DissolveOn){
            float2 dissolveUVOffsetScale = lerp(_Time.xx,1,_DissolveTexOffsetStop);
            float2 dissolveUV = mainUV.zw * _DissolveTex_ST.xy + _DissolveTex_ST.zw * dissolveUVOffsetScale;
            ApplyDissolve(mainColor,dissolveUV,i.color,dissolveCustomData,dissolveEdgeWidth);
        }

        if(_FresnelOn){
            float fresnal = i.fresnal_customDataZ.x;
            ApplyFresnal(mainColor,fresnal);
        }
        
        if(_MatCapOn)
            ApplyMatcap(mainColor,mainUV.zw,i.viewNormal);

        return mainColor;
    }


#endif //POWER_VFX_PASS_CGINC