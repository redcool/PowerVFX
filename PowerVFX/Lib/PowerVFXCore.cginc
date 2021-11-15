#if !defined(POWER_VFX_CGINC)
#define POWER_VFX_CGINC
#define FRESNEL_COLOR_REPLACE 0
#define FRESNEL_COLOR_MULTIPLY 1

#include "PowerVFXInput.cginc"
#include "PowerVFXData.cginc"
#include "NodeLib.cginc"
#include "UtilLib.cginc"

float4 SampleAttenMap(float2 mainUV,float attenMaskCDATA){
    float2 offsetScale = 0;
    // auto offset
    if(!_VertexWaveAtten_MaskMapOffsetStopOn){
        offsetScale = _Time.y  * _VertexWaveAtten_MaskMap_ST.zw;
    }
    // offset by custom data
    if(_VertexWaveAttenMaskOffsetScale_UseCustomeData2_X){
        offsetScale = attenMaskCDATA;
    }
    float4 attenMapUV = float4(mainUV * _VertexWaveAtten_MaskMap_ST.xy + _VertexWaveAtten_MaskMap_ST.zw + offsetScale,0,0);
    return tex2Dlod(_VertexWaveAtten_MaskMap,attenMapUV);
}

void ApplyVertexWaveWorldSpace(inout float3 worldPos,float3 normal,float3 vertexColor,float2 mainUV,float attenMaskCDATA){
    float2 worldUV = worldPos.xz + _VertexWaveSpeed * lerp(_Time.xx,1,_VertexWaveSpeedManual);
    float noise = 0;
    float4 attenMap=0;

    if(_NoiseUseAttenMaskMap){
        attenMap = SampleAttenMap(mainUV,attenMaskCDATA);

        noise = attenMap.x;
    }else{
        noise = Unity_GradientNoise(worldUV,_VertexWaveIntensity);
    }

    //1 vertex color atten
    //2 uniform dir atten
    float3 dir = SafeNormalize(_VertexWaveDirAtten.xyz) * _VertexWaveDirAtten.w;
    if(_VertexWaveDirAlongNormalOn)
        dir *= normal;
    
    if(_VertexWaveDirAtten_LocalSpaceOn)
        dir = mul(unity_ObjectToWorld,dir);

    float3 vcAtten = _VertexWaveAtten_VertexColor? vertexColor : 1;
    float3 atten = dir * vcAtten;
    //3 normal direction atten
    if(_VertexWaveAtten_NormalAttenOn){
        atten *= saturate(dot(dir,normal));
    }
    //4 atten map
    if(_VertexWaveAtten_MaskMapOn){
        if(! _NoiseUseAttenMaskMap)
            attenMap = SampleAttenMap(mainUV,attenMaskCDATA);
        atten *= attenMap[_VertexWaveAtten_MaskMapChannel];
    }
    worldPos.xyz +=  noise * atten;
}

/**
    return : float4
    xy:ofset and scalel vertex uv,
    zw:vertex uv
*/
float4 MainTexOffset(float4 uv){
    float2 offsetScale = lerp(_Time.xx, 1 ,_MainTexOffsetStop);
    float2 mainTexOffset = (_MainTex_ST.zw * offsetScale);
    mainTexOffset = lerp(mainTexOffset,uv.zw, _MainTexOffsetUseCustomData_XY); // vertex uv0.z : particle customData1.xy

    float4 scrollUV = (float4)0;
    scrollUV.xy = uv.xy * _MainTex_ST.xy + mainTexOffset;
    scrollUV.zw = uv.xy;
    return scrollUV;
}

void ApplySaturate(inout float4 mainColor){
    mainColor.xyz = lerp(Gray(mainColor.xyz),mainColor.xyz,_MainTexSaturate);
}

float4 SampleMainTex(float2 uv,float4 vertexColor,float faceId){
    float4 color = _BackFaceOn ? lerp(_BackFaceColor,_Color,faceId) : _Color;
    float4 mainTex = _MainTexUseScreenColor ==0 ? tex2D(_MainTex,uv) : tex2D(_CameraOpaqueTexture,uv);

    ApplySaturate(mainTex);

    if(_MainTexSingleChannelOn){
        mainTex = mainTex[_MainTexChannel];
    }
    mainTex.xyz *= lerp(1,mainTex.a * vertexColor.a * color.a,_MainTexMultiAlpha);
    mainTex *= color * vertexColor * _ColorScale;
    return mainTex;
}

void ApplyMainTexMask(inout float4 mainColor,float2 uv){
    float2 maskTexOffset = _MainTexMaskOffsetStop ? _MainTexMask_ST.zw : _MainTexMask_ST.zw * _Time.xx;
    float4 maskTex = tex2D(_MainTexMask,uv*_MainTexMask_ST.xy + maskTexOffset);// fp opearate mask uv.
    mainColor.a *= maskTex[_MainTexMaskChannel];
}

float2 ApplyDistortion(inout float4 mainColor,float4 mainUV,float4 distortUV,float4 color,float faceId){
    half2 noise = (tex2D(_DistortionNoiseTex, distortUV.xy).xy -0.5) * 2;
    if(_DoubleEffectOn){
        noise += (tex2D(_DistortionNoiseTex, distortUV.zw).xy -0.5)*2;
        noise *= 0.5;
    }
    
    float2 maskUV = _MainTexUseScreenColor == 0 ? mainUV.xy : mainUV.zw;
    maskUV = maskUV * _DistortionMaskTex_ST.xy + _DistortionMaskTex_ST.zw;
    float4 maskTex = tex2D(_DistortionMaskTex,maskUV);

    half2 duv = mainUV.xy + noise * 0.2  * _DistortionIntensity * maskTex[_DistortionMaskChannel];
    mainColor = SampleMainTex(duv,color,faceId);
    return duv;
}

void ApplyDissolve(inout float4 mainColor,float2 dissolveUV,float4 color,float dissolveCDATA,float edgeWidthCDATA){
    
    if(_PixelDissolveOn){
        dissolveUV = abs( dissolveUV - 0.5);
        dissolveUV = round(dissolveUV * _PixelWidth)/max(0.0001,_PixelWidth);
    }

    half4 dissolveTex = tex2D(_DissolveTex,dissolveUV.xy);
    half refDissolve = dissolveTex[_DissolveTexChannel];
    // refDissolve = _DissolveRevert > 0 ? refDissolve : 1 - refDissolve;

    // remap cutoff
    half cutoff = _Cutoff;
    if(_DissolveByVertexColor)
        cutoff =  1 - color.a; // slider or vertex color

    if(_DissolveByCustomData_Z)
        cutoff = 1- dissolveCDATA; // slider or particle's custom data
    
    cutoff = lerp(-0.15,1.01,cutoff);

    half dissolve = refDissolve - cutoff;
    dissolve = saturate(smoothstep(_DissolveFadingMin,_DissolveFadingMax,dissolve));

    if(_DissolveClipOn)
        clip(dissolve-0.01);
    
    mainColor.a *= dissolve;

    if(_DissolveEdgeOn){
        half edgeWidth = _DissolveEdgeWidthByCustomData_W > 0? edgeWidthCDATA : _EdgeWidth;
        float edge = saturate(smoothstep(edgeWidth-0.1,edgeWidth+0.1,dissolve));
        float4 edgeColor = lerp(_EdgeColor,_EdgeColor2,edge);
        // edgeColor.a *= edge;
        edge = saturate(smoothstep(0.,.6,1-dissolve));
        mainColor.xyz = lerp(mainColor.xyz,(mainColor.xyz*0.5+ edgeColor.xyz)*1.5,edge);
    }
    
}

void ApplyOffset(inout float4 mainColor,float4 offsetUV,float2 maskUV){
    half3 offsetColor = tex2D(_OffsetTex,offsetUV.xy) * _OffsetTexColorTint;
    offsetColor += _DoubleEffectOn > 0 ? tex2D(_OffsetTex,offsetUV.zw) * _OffsetTexColorTint2 : 0;

    half mask = tex2D(_OffsetMaskTex,maskUV)[_OffsetMaskChannel];

    offsetColor = mainColor.rgb * offsetColor * _OffsetBlendIntensity * unity_ColorSpaceDouble;
    mainColor.rgb += lerp(0,offsetColor,mask);
}

void ApplyFresnal(inout float4 mainColor,float fresnel){
    float f = smoothstep(_FresnelPowerMin,_FresnelPowerMax,fresnel);
    float4 fresnelColor = f * lerp(_FresnelColor,_FresnelColor2,f);
    mainColor.xyz += (_FresnelColorMode == FRESNEL_COLOR_MULTIPLY? mainColor.xyz : 1 ) * fresnelColor;
    mainColor.a *= fresnelColor.a;
}

void ApplyEnv(inout float4 mainColor,float2 mainUV,float3 reflectDir,float3 refractDir){
    float mask = tex2D(_EnvMapMask,mainUV)[_EnvMapMaskChannel];

    float4 envColor = (half4)0;
    if(_EnvReflectOn)
        envColor += texCUBE(_EnvMap,reflectDir) * _EnvReflectionColor;
    if(_EnvRefractionOn)
        envColor += texCUBE(_EnvMap,refractDir) * _EnvRefractionColor;
    
    envColor *= _EnvIntensity * mask;
    mainColor.rgb += envColor.rgb;
}

void ApplyMatcap(inout float4 mainColor,float2 mainUV,float2 viewNormal){
    if(_MatCapRotateOn){
        // rotate tex by center
        float theta = radians(_MatCapAngle);
        viewNormal = (viewNormal-0.5 )* 2;
        viewNormal = float2(
            dot(float2(cos(theta),sin(theta)),viewNormal),
            dot(float2(-sin(theta),cos(theta)),viewNormal)
        );
        viewNormal = viewNormal * 0.5+0.5;
    }
    
    float4 matCapMap = tex2D(_MatCapTex,viewNormal.xy) * _MatCapColor;
    matCapMap *= _MatCapIntensity;
    mainColor.rgb += matCapMap;
}

void ApplySoftParticle(inout float4 mainColor,float4 projPos){
    float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(projPos)));
    float partZ = projPos.z;
    float delta = (sceneZ-partZ);
    float fade = saturate (_DepthFadingWidth * delta + 0.12*delta);
    // mainColor *= smoothstep(-0.5,0.5,fade);
    mainColor *= fade;
}

void ApplyLight(inout float4 mainColor,float3 normal){
    float3 lightDir = _WorldSpaceLightPos0.xyz + _WorldSpaceLightDirection.xyz;
    float nl = saturate(dot(normal,lightDir));
    mainColor.xyz *= nl;
}
#endif //POWER_VFX_CGINC