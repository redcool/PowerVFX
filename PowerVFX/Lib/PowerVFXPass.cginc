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
    o.grabPos.z = COMPUTE_EYEDEPTH(o.grabPos.z);

    half3 normalDistorted = SafeNormalize(worldNormal + _EnvOffset.xyz);
    if(_EnvReflectOn)
        o.reflectDir = reflect(- viewDir,normalDistorted);
    if(_EnvRefractionOn)
        o.refractDir = refract(viewDir,-normalDistorted,1/_EnvRefractionIOR);

    half3 viewNormal = normalize(mul((half3x3)UNITY_MATRIX_MV,v.normal));
    o.viewNormal = viewNormal.xy * 0.5 + 0.5;

    if(_FresnelOn)
        o.fresnal_customDataZ.x = 1 - dot(worldNormal,viewDir) ;

    o.fresnal_customDataZ.yz = v.uv1.xy;// particle custom data (Custom1).zw

    if(_LightOn){
        half3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
        TANGENT_SPACE_COMBINE(worldPos,worldNormal,half4(worldTangent,v.tangent.w),o/**/);
    }
    return o;
}

fixed4 frag(v2f i,fixed faceId:VFACE) : SV_Target
{
    TANGENT_SPACE_SPLIT(i);
    half3 reflectDir = i.reflectDir;
    half3 refractDir = i.refractDir;

    half4 mainColor = half4(0,0,0,1);
    // setup mainUV, move to vs
    // half4 mainUV = MainTexOffset(i.uv);
    half4 mainUV = i.uv;

    half dissolveCustomData = i.fresnal_customDataZ.y;
    half dissolveEdgeWidth = i.fresnal_customDataZ.z;


    //use _CameraOpaqueTexture
    mainUV.xy = _MainTexUseScreenColor == 0 ? mainUV.xy : i.grabPos.xy/i.grabPos.w;
    
    half2 uvDistorted = mainUV.zw;
    if(_DistortionOn){
        half4 distortUV = mainUV.zwzw * _DistortTile + frac(_DistortDir * _Time.xxxx);
        if(_DistortionRadialUVOn){
            half4 p = _DistortionRadialCenter_LenScale_LenOffset;
            distortUV.xy = PolarUV(mainUV.zw,p.xy,p.z,p.w*_Time.x,_DistortionRadialRot);
        }
        uvDistorted = ApplyDistortion(mainColor,mainUV,distortUV,i.color,faceId);
    }else{
        mainColor = SampleMainTex(mainUV.xy,i.color,faceId);
    }
    
    ApplyMainTexMask(mainColor,mainUV.zw);

    if(_EnvReflectOn || _EnvRefractionOn)
        ApplyEnv(mainColor,mainUV.zw,reflectDir,refractDir);

    if(_OffsetOn){
        half4 offsetUV = (_ApplyToOffset ? uvDistorted.xyxy : mainUV.zwzw) * _OffsetTile + (_Time.xxxx * _OffsetDir); //暂时去除 frac
        if(_OffsetRadialUVOn){
            half4 p = _OffsetRadialCenter_LenScale_LenOffset;
            offsetUV.xy = PolarUV(mainUV.zw,p.xy,p.z,p.w*_Time.x,_OffsetRadialRot);
        }
        half2 maskUV = mainUV.zw * _OffsetMaskTex_ST.xy + _OffsetMaskTex_ST.zw;
        ApplyOffset(mainColor,offsetUV,maskUV);
    }

    //dissolve
    if(_DissolveOn){
        half2 dissolveUVOffsetScale = lerp(_Time.xx,1,_DissolveTexOffsetStop);
        half2 dissolveUV = mainUV.zw * _DissolveTex_ST.xy + _DissolveTex_ST.zw * dissolveUVOffsetScale;
        ApplyDissolve(mainColor,dissolveUV,i.color,dissolveCustomData,dissolveEdgeWidth);
    }

    if(_FresnelOn){
        half fresnal = i.fresnal_customDataZ.x;
        ApplyFresnal(mainColor,fresnal);
    }
    
    if(_MatCapOn)
        ApplyMatcap(mainColor,mainUV.zw,i.viewNormal);

    if(_LightOn)
    {
        ApplyLight(mainColor/**/,normal);
    }
    
    if(_DepthFadingOn)
        ApplySoftParticle(mainColor/**/,i.grabPos); // change vertex color
    
    mainColor.a = saturate(mainColor.a );
    return mainColor;
}


#endif //POWER_VFX_PASS_CGINC