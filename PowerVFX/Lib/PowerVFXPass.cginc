#if !defined(POWER_VFX_PASS_CGINC)
#define POWER_VFX_PASS_CGINC
#include "UnityCG.cginc"
#include "PowerVFXCore.cginc"

v2f vert(appdata v)
{
    half4 worldPos = mul(unity_ObjectToWorld,v.vertex);
    half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos.xyz));
    half3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));

    v2f o = (v2f)0;
    o.color = v.color;
    if(_VertexWaveOn){
        half attemMaskCDATA = v.uv1.z;
        ApplyVertexWaveWorldSpace(worldPos.xyz/**/,worldNormal,v.color,v.uv,attemMaskCDATA);
    }
    o.vertex = UnityWorldToClipPos(worldPos);

    // o.uv = v.uv; // uv.xy : main uv, zw : custom data.xy
    o.uv = MainTexOffset(v.uv);
    o.grabPos = ComputeGrabScreenPos(o.vertex);
    COMPUTE_EYEDEPTH(o.grabPos.z);

    // #if defined(UNITY_UV_STARTS_AT_TOP)
    //     if(_MainTex_TexelSize.y < 0)
    //         o.grabPos.y = o.grabPos.w - o.grabPos.y;
    // #endif

    half3 normalDistorted = SafeNormalize(worldNormal + _EnvOffset.xyz);
    if(_EnvReflectOn)
        o.reflectDir = reflect(- viewDir,normalDistorted);
    if(_EnvRefractionOn)
        o.refractDir = refract(viewDir,-normalDistorted,1/_EnvRefractionIOR);

    half3 viewNormal = normalize(mul((half3x3)UNITY_MATRIX_MV,v.normal));
    o.viewNormal = viewNormal.xy * 0.5 + 0.5;

    if(_FresnelOn)
        o.fresnal_customDataZ.x = 1 - dot(worldNormal,viewDir) ;

    o.fresnal_customDataZ.yzw = v.uv1.xyz;// particle custom data (Custom1).zw

    if(_LightOn){
        half3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
        TANGENT_SPACE_COMBINE(worldPos,worldNormal,half4(worldTangent,v.tangent.w),o/**/);
    }
    UNITY_TRANSFER_FOG(o,o.vertex);
    return o;
}

fixed4 frag(v2f i,fixed faceId:VFACE) : SV_Target
{
    TANGENT_SPACE_SPLIT(i);
    half3 reflectDir = i.reflectDir;
    half3 refractDir = i.refractDir;

    half4 mainColor = half4(0,0,0,1);
    half4 screenColor=0;
    // setup mainUV, move to vs
    // half4 mainUV = MainTexOffset(i.uv);
    half4 mainUV = i.uv;

// get particle system's custom data
    half dissolveCustomData = i.fresnal_customDataZ.y;
    half dissolveEdgeWidth = i.fresnal_customDataZ.z;
    half distortionCustomData = i.fresnal_customDataZ.w;

    //use _CameraOpaqueTexture
    half2 screenUV = i.grabPos.xy/i.grabPos.w;
    mainUV.xy = _MainTexUseScreenColor == 0 ? mainUV.xy : screenUV;
    
    half2 uvDistorted = mainUV.zw;
    if(_DistortionOn){
        half4 distortUV = mainUV.zwzw * _DistortTile + frac(_DistortDir * _Time.xxxx);
        if(_DistortionRadialUVOn){
            half4 p = _DistortionRadialCenter_LenScale_LenOffset;
            distortUV.xy = PolarUV(mainUV.zw,p.xy,p.z,p.w*_Time.x,_DistortionRadialRot);
        }
        uvDistorted = ApplyDistortion(mainUV,distortUV,distortionCustomData);
        SampleMainTex(mainColor/**/,screenColor/**/,uvDistorted,screenUV,i.color,faceId);
    }else{
        SampleMainTex(mainColor/**/,screenColor/**/,mainUV.xy,screenUV,i.color,faceId);
    }
    
    //-------- mainColor, screenColor prepared done
    
    ApplyMainTexMask(mainColor,mainUV.zw);

    if(_EnvReflectOn || _EnvRefractionOn)
        ApplyEnv(mainColor,mainUV.zw,reflectDir,refractDir);

    if(_OffsetOn){
        half4 offsetUV = (_ApplyToOffset ? uvDistorted.xyxy : mainUV.zwzw) * _OffsetTile + (_Time.xxxx * _OffsetDir); //暂时去除 frac
        if(_OffsetRadialUVOn){
            half4 p = _OffsetRadialCenter_LenScale_LenOffset;
            offsetUV.xy = PolarUV(mainUV.zw,p.xy,p.z,p.w*_Time.x,_OffsetRadialRot);
        }
        // half2 maskUVOffset = _OffsetMaskTex_ST.zw * (1 + _Time.xx *(1- _OffsetMaskPanStop) );
        half2 maskUVOffset = UVOffset(_OffsetMaskTex_ST.zw, _OffsetMaskPanStop);
        half2 maskUV = mainUV.zw * _OffsetMaskTex_ST.xy + maskUVOffset;
        ApplyOffset(mainColor,offsetUV,maskUV);
    }

    //dissolve
    if(_DissolveOn){
        half2 dissolveUVOffset = UVOffset(_DissolveTex_ST.zw,_DissolveTexOffsetStop);
        half2 dissolveUV = mainUV.zw * _DissolveTex_ST.xy + dissolveUVOffset;
        ApplyDissolve(mainColor,dissolveUV,i.color,dissolveCustomData,dissolveEdgeWidth);
    }

    if(_FresnelOn){
        half fresnal = i.fresnal_customDataZ.x;
        ApplyFresnal(mainColor,fresnal,screenColor);
    }
    
    if(_MatCapOn)
        ApplyMatcap(mainColor,mainUV.zw,i.viewNormal);
        return mainColor;

    if(_LightOn)
    {
        ApplyLight(mainColor/**/,normal);
    }
    
    if(_DepthFadingOn)
        ApplySoftParticle(mainColor/**/,i.grabPos); // change vertex color
    
    mainColor.a = saturate(mainColor.a );
    // apply fog
    UNITY_APPLY_FOG(i.fogCoord , mainColor);
    // mainColor.xyz *= lerp(1,mainColor.a,_MainTexMultiAlpha);

    return mainColor;
}


#endif //POWER_VFX_PASS_CGINC