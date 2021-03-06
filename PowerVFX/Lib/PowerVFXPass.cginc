#if !defined(POWER_VFX_PASS_CGINC)
#define POWER_VFX_PASS_CGINC
#include "UnityCG.cginc"
#include "PowerVFXCore.cginc"

v2f vert(appdata v)
{
    float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
    float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);
    float3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));

    v2f o = (v2f)0;
    o.color = v.color;

    #if defined(VERTEX_WAVE_ON)
    // if(_VertexWaveOn)
    {
        float attemMaskCDATA = v.uv1.z;
        ApplyVertexWaveWorldSpace(worldPos.xyz/**/,worldNormal,v.color,v.uv,attemMaskCDATA);
    }
    #endif
    o.vertex = UnityWorldToClipPos(worldPos);

    // o.uv = v.uv; // uv.xy : main uv, zw : custom data.xy
    o.uv = MainTexOffset(v.uv);
    o.grabPos = ComputeGrabScreenPos(o.vertex);
    COMPUTE_EYEDEPTH(o.grabPos.z);

    // #if defined(UNITY_UV_STARTS_AT_TOP)
    //     if(_MainTex_TexelSize.y < 0)
    //         o.grabPos.y = o.grabPos.w - o.grabPos.y;
    // #endif

    float3 normalDistorted = SafeNormalize(worldNormal + _EnvOffset.xyz);
    if(_EnvReflectOn)
        o.reflectDir = reflect(- viewDir,normalDistorted);
    if(_EnvRefractionOn)
        o.refractDir = refract(viewDir,-normalDistorted,1/_EnvRefractionIOR);

    float3 viewNormal = normalize(mul((half3x3)UNITY_MATRIX_MV,v.normal));
    o.viewNormal = viewNormal.xy * 0.5 + 0.5;

    #if defined(FRESNEL_ON)
    // if(_FresnelOn)
        o.fresnel_customDataZ.x = 1 - dot(worldNormal,viewDir) ;
    #endif

    o.fresnel_customDataZ.yzw = v.uv1.xyz;// particle custom data (Custom1).zw

    #if defined(PBR_LIGHTING)
    // if(_PbrLightOn){
        float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
        TANGENT_SPACE_COMBINE_WORLD(worldPos,worldNormal,float4(worldTangent,v.tangent.w),o/**/);
    // }
    #endif

    UNITY_TRANSFER_FOG(o,o.vertex);
    return o;
}

fixed4 frag(v2f i,fixed faceId:VFACE) : SV_Target
{
    TANGENT_SPACE_SPLIT(i);
    float3 reflectDir = i.reflectDir;
    float3 refractDir = i.refractDir;

    float4 mainColor = float4(0,0,0,1);
    float4 screenColor=0;
    // setup mainUV, move to vs
    // float4 mainUV = MainTexOffset(i.uv);
    float4 mainUV = i.uv;

// get particle system's custom data
    float dissolveCustomData = i.fresnel_customDataZ.y;
    float dissolveEdgeWidth = i.fresnel_customDataZ.z;
    float distortionCustomData = i.fresnel_customDataZ.w;

    //use _CameraOpaqueTexture
    float2 screenUV = i.grabPos.xy/i.grabPos.w;
    mainUV.xy = _MainTexUseScreenColor == 0 ? mainUV.xy : screenUV;
    
    float2 uvDistorted = mainUV.zw;
    #if defined(DISTORTION_ON)
    // if(_DistortionOn)
    {
        float4 distortUV = mainUV.zwzw * _DistortTile + frac(_DistortDir * _Time.xxxx);
        if(_DistortionRadialUVOn){
            float4 p = _DistortionRadialCenter_LenScale_LenOffset;
            distortUV.xy = PolarUV(mainUV.zw,p.xy,p.z,p.w*_Time.x,_DistortionRadialRot);
        }
        uvDistorted = ApplyDistortion(mainUV,distortUV,distortionCustomData);
    }
    #endif
    
    SampleMainTex(mainColor/**/,screenColor/**/,uvDistorted,i.color,faceId);
    
    //-------- mainColor, screenColor prepared done
    float4 mainTexMask=0;
    ApplyMainTexMask(mainColor/**/,mainTexMask/**/,_DistortionApplyToMainTexMask ? uvDistorted : mainUV.zw);

    #if defined(PBR_LIGHTING)
        normal = SampleNormalMap(uvDistorted,i.tSpace0,i.tSpace1,i.tSpace2);
        float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);
        ApplyPbrLighting(mainColor.xyz/**/,uvDistorted,normal,viewDir);
    #endif

    #if defined(ENV_REFRACTION_ON) || defined(ENV_REFLECT_ON)
    // if(_EnvReflectOn || _EnvRefractionOn)
    {
        float envMask = lerp(1,mainTexMask.w,_EnvMaskUseMainTexMask);
        ApplyEnv(mainColor,mainUV.zw,reflectDir,refractDir,envMask);
    }
    #endif

    #if defined(OFFSET_ON)
    // if(_OffsetOn)
    {
        float4 offsetUV = (_DistortionApplyToOffset ? uvDistorted.xyxy : mainUV.zwzw) * _OffsetTile + (_Time.xxxx * _OffsetDir); //???????????? frac
        if(_OffsetRadialUVOn){
            float4 p = _OffsetRadialCenter_LenScale_LenOffset;
            offsetUV.xy = PolarUV(mainUV.zw,p.xy,p.z,p.w*_Time.x,_OffsetRadialRot);
        }
        // float2 maskUVOffset = _OffsetMaskTex_ST.zw * (1 + _Time.xx *(1- _OffsetMaskPanStop) );
        float2 maskUVOffset = UVOffset(_OffsetMaskTex_ST.zw, _OffsetMaskPanStop);
        float2 maskUV = mainUV.zw * _OffsetMaskTex_ST.xy + maskUVOffset;
        ApplyOffset(mainColor,offsetUV,maskUV);
    }
    #endif

    //------------- dissolve
    #if defined(DISSOLVE_ON)
    // if(_DissolveOn)
    {
        float2 dissolveUVOffset = UVOffset(_DissolveTex_ST.zw,_DissolveTexOffsetStop);
        float2 dissolveUV = (_DistortionApplyToDissolve ? uvDistorted : mainUV.zw) * _DissolveTex_ST.xy + dissolveUVOffset;
        ApplyDissolve(mainColor,dissolveUV,i.color,dissolveCustomData,dissolveEdgeWidth);
    }
    #endif 

    #if defined(FRESNEL_ON)
    // if(_FresnelOn)
    {
        float fresnel = i.fresnel_customDataZ.x;
        ApplyFresnal(mainColor,fresnel,screenColor);
    }
    #endif
    
    #if defined(MATCAP_ON)
    // if(_MatCapOn)
    {
        ApplyMatcap(mainColor,mainUV.zw,i.viewNormal);
    }
    #endif

    #if defined(DEPTH_FADING_ON)
    // if(_DepthFadingOn)
    {
        ApplySoftParticle(mainColor/**/,i.grabPos); // change vertex color
    }
    #endif
    
    mainColor.a = saturate(mainColor.a );
    // apply fog
    UNITY_APPLY_FOG(i.fogCoord , mainColor);
    // mainColor.xyz *= lerp(1,mainColor.a,_MainTexMultiAlpha);

    return mainColor;
}


#endif //POWER_VFX_PASS_CGINC