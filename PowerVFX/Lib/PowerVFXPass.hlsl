#if !defined(POWER_VFX_PASS_CGINC)
#define POWER_VFX_PASS_CGINC
#include "../../PowerShaderLib/Lib/UnityLib.hlsl"
#include "../../PowerShaderLib/UrpLib/URP_Fog.hlsl"
#include "PowerVFXCore.hlsl"
#include "../../PowerShaderLib/UrpLib/URP_AdditionalLightShadows.hlsl"
v2f vert(appdata v)
{
    float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
    float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);
    float3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));

    v2f o = (v2f)0;
    o.color = v.color;
    o.viewDir = viewDir;

    // composite custom datas
    o.customData1 = float4(v.uv.zw,v.uv1.xy);// particle custom data (Custom1.zw)(Custom2.xy)
    o.customData2 = float4(v.uv1.zw,v.uv2.xy); // particle custom data (Custom2.xy)
    float customDatas[8] = {o.customData1,o.customData2};

    #if defined(VERTEX_WAVE_ON)
    // if(_VertexWaveOn)
    {
        float attemMaskCDATA = customDatas[_VertexWaveAttenMaskOffsetCustomData];
        ApplyVertexWaveWorldSpace(worldPos.xyz/**/,worldNormal,v.color,v.uv,attemMaskCDATA);
    }
    #endif
    o.vertex = UnityWorldToClipPos(worldPos);


    // uv.xy : main uv, zw : custom data1.xy
    float mainTexOffsetCdataX = customDatas[_MainTexOffset_CustomData_X];
    float mainTexOffsetCdataY = customDatas[_MainTexOffset_CustomData_Y];
    o.uv = MainTexOffset(float4(v.uv.xy,mainTexOffsetCdataX,mainTexOffsetCdataY));

    #if defined(DEPTH_FADING_ON)
    o.projPos = o.vertex * 0.5; // [-0.5w,.5w]
    o.projPos.xy = o.projPos.xy * float2(1,_ProjectionParams.x) + o.projPos.w; //[0,w]
    o.projPos.zw = o.vertex.zw;
    #endif

    float3 normalDistorted = SafeNormalize(worldNormal + _EnvOffset.xyz);
    if(_EnvReflectOn)
        o.reflectDir = reflect(- viewDir,normalDistorted);
    if(_EnvRefractionOn)
        o.refractDir = refract(viewDir,-normalDistorted,1/_EnvRefractionIOR);

    float3 viewNormal = normalize(mul((half3x3)UNITY_MATRIX_MV,v.normal));
    o.viewNormal = viewNormal.xy * 0.5 + 0.5;

    /* 
        light, fresnel need nuormal
    */

    // #if defined(PBR_LIGHTING) 
    // if(_PbrLightOn){
        float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
        TANGENT_SPACE_COMBINE_WORLD(worldPos,worldNormal,float4(worldTangent,v.tangent.w),o/**/);
    // }
    // #endif

    o.fogCoord.x = ComputeFogFactor(o.vertex.z);
    // UNITY_TRANSFER_FOG(o,o.vertex);

    #if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        o.shadowCoord = TransformWorldToShadowCoord(worldPos.xyz); // move to frag
    #endif

    return o;
}

half4 frag(v2f i,half faceId:VFACE) : SV_Target
{
    TANGENT_SPACE_SPLIT(i);

    float3 reflectDir = i.reflectDir;
    float3 refractDir = i.refractDir;
    float3 viewDir = normalize(i.viewDir);

    float4 mainColor = float4(0,0,0,1);
    float4 screenColor=0;
    // setup mainUV, move to vs
    // float4 mainUV = MainTexOffset(i.uv);
    float4 mainUV = i.uv;

/**  
    get particle system's custom data

*/
    float customDatas[8] = {i.customData1,i.customData2};

    float dissolveCustomData = customDatas[_DissolveCustomData];
    float dissolveEdgeWidthCustomData = customDatas[_DissolveEdgeWidthCustomData];
    float distortionCustomData = customDatas[_DistortionCustomData];
    float2 mainTexMaskOffsetCustomData = float2(customDatas[_MainTexMaskOffsetCustomDataX] , customDatas[_MainTexMaskOffsetCustomDataY]);
    float2 offsetLayer1CData = float2(customDatas[_OffsetLayer1_CustomData_X],customDatas[_OffsetLayer1_CustomData_Y]);

    //use _CameraOpaqueTexture
    // float2 screenUV = i.projPos.xy;
    float2 screenUV = i.vertex.xy/_ScreenParams.xy;
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
        SampleMainTex(mainColor/**/,screenColor/**/,uvDistorted,i.color,faceId);
    }
    #else
        SampleMainTex(mainColor/**/,screenColor/**/,mainUV.xy,i.color,faceId);
    #endif

    //-------- mainColor, screenColor prepared done
    float4 mainTexMask=0;
    ApplyMainTexMask(mainColor/**/,mainTexMask/**/,_DistortionApplyToMainTexMask ? uvDistorted : mainUV.zw,mainTexMaskOffsetCustomData);

    #if defined(PBR_LIGHTING)
        normal = SampleNormalMap(uvDistorted,i.tSpace0,i.tSpace1,i.tSpace2);
        ApplyPbrLighting(mainColor.xyz/**/,worldPos,i.shadowCoord,uvDistorted,normal,viewDir);

    #endif //PBR_LIGHTING

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
        half4 offsetDir = lerp(_Time.xxxx,1,_StopAutoOffset) * _OffsetDir;
        offsetDir.xy = lerp(offsetDir.xy,offsetLayer1CData,_OffsetCustomDataOn);
        float4 offsetUV = (_DistortionApplyToOffset ? uvDistorted.xyxy : mainUV.zwzw) * _OffsetTile + (offsetDir); //暂时去除 frac
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
        ApplyDissolve(mainColor,dissolveUV,i.color,dissolveCustomData,dissolveEdgeWidthCustomData);
    }
    #endif 

    #if defined(FRESNEL_ON)
    // if(_FresnelOn)
    {
        float fresnel = 1 - dot(normal,viewDir);
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
        // float3 viewPos = mul(unity_MatrixV,worldPos);
        float3 projPos = i.projPos.xyz/i.projPos.w;
        float curZ = LinearEyeDepth(projPos.z,_ZBufferParams);
        ApplySoftParticle(mainColor/**/,projPos.xy,curZ); // change vertex color
    }
    #endif

    mainColor.a = saturate(mainColor.a );
    // apply fog
    mainColor.xyz = MixFog(mainColor.xyz,i.fogCoord);

    return mainColor;
}


#endif //POWER_VFX_PASS_CGINC