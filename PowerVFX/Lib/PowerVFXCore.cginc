#if !defined(POWER_VFX_CGINC)
#define POWER_VFX_CGINC
#define FRESNEL_COLOR_REPLACE 0
#define FRESNEL_COLOR_MULTIPLY 1

#include "PowerVFXInput.cginc"
#include "PowerVFXData.cginc"
#include "NodeLib.cginc"
#include "UtilLib.cginc"

half4 SampleAttenMap(half2 mainUV,half attenMaskCDATA){
    half2 offsetScale = 0;
    // auto offset
    if(!_VertexWaveAtten_MaskMapOffsetStopOn){
        offsetScale = _Time.y  * _VertexWaveAtten_MaskMap_ST.zw;
    }
    // offset by custom data
    if(_VertexWaveAttenMaskOffsetScale_UseCustomeData2_X){
        offsetScale = attenMaskCDATA;
    }
    half4 attenMapUV = half4(mainUV * _VertexWaveAtten_MaskMap_ST.xy + _VertexWaveAtten_MaskMap_ST.zw + offsetScale,0,0);
    return tex2Dlod(_VertexWaveAtten_MaskMap,attenMapUV);
}

void ApplyVertexWaveWorldSpace(inout half3 worldPos,half3 normal,half3 vertexColor,half2 mainUV,half attenMaskCDATA){
    half2 worldUV = worldPos.xz + _VertexWaveSpeed * lerp(_Time.xx,1,_VertexWaveSpeedManual);
    half noise = 0;
    half4 attenMap=0;

    if(_NoiseUseAttenMaskMap){
        attenMap = SampleAttenMap(mainUV,attenMaskCDATA);

        noise = attenMap.x;
    }else{
        noise = Unity_GradientNoise(worldUV,_VertexWaveIntensity);
    }

    //1 vertex color atten
    //2 uniform dir atten
    half3 dir = SafeNormalize(_VertexWaveDirAtten.xyz) * _VertexWaveDirAtten.w;
    if(_VertexWaveDirAlongNormalOn)
        dir *= normal;
    
    if(_VertexWaveDirAtten_LocalSpaceOn)
        dir = mul(unity_ObjectToWorld,dir);

    half3 vcAtten = _VertexWaveAtten_VertexColor? vertexColor : 1;
    half3 atten = dir * vcAtten;
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
    return : half4
    xy:ofset and scalel vertex uv,
    zw:vertex uv
*/
half4 MainTexOffset(half4 uv){
    RotateUV(_MainUVAngle,0.5,uv.xy/**/);

    half2 offsetScale = lerp(_Time.xx, 1 ,_MainTexOffsetStop);
    half2 mainTexOffset = (_MainTex_ST.zw * offsetScale);
    mainTexOffset = lerp(mainTexOffset,uv.zw, _MainTexOffsetUseCustomData_XY); // vertex uv0.z : particle customData1.xy

    half4 scrollUV = (half4)0;
    scrollUV.xy = uv.xy * _MainTex_ST.xy + mainTexOffset;
    scrollUV.zw = uv.xy;
    return scrollUV;
}

void ApplySaturate(inout half4 mainColor){
    mainColor.xyz = lerp(Gray(mainColor.xyz),mainColor.xyz,_MainTexSaturate);
}

half4 SampleMainTex(half2 uv,half4 vertexColor,half faceId){
    half4 color = _BackFaceOn ? lerp(_BackFaceColor,_Color,faceId) : _Color;
    half4 mainTex = _MainTexUseScreenColor ==0 ? tex2D(_MainTex,uv) : tex2D(_CameraOpaqueTexture,uv);

    ApplySaturate(mainTex);

    if(_MainTexSingleChannelOn){
        mainTex = mainTex[_MainTexChannel];
    }
    mainTex.xyz *= lerp(1,mainTex.a * vertexColor.a * color.a,_MainTexMultiAlpha);
    mainTex *= color * vertexColor * _ColorScale;
    // for alpha
    mainTex.w *= _AlphaScale;
    mainTex.w = smoothstep(_AlphaMin,_AlphaMax,mainTex.w);
    return mainTex;
}

void ApplyMainTexMask(inout half4 mainColor,half2 uv){
    half2 maskTexOffset = _MainTexMask_ST.zw + _Time.xx *(1-_MainTexMaskOffsetStop);
    half4 maskTex = tex2D(_MainTexMask,uv*_MainTexMask_ST.xy + maskTexOffset);// fp opearate mask uv.
    mainColor.a *= maskTex[_MainTexMaskChannel];
}

half2 ApplyDistortion(inout half4 mainColor,half4 mainUV,half4 distortUV,half4 color,half faceId){
    half2 noise = (tex2D(_DistortionNoiseTex, distortUV.xy).xy -0.5) * 2;
    if(_DoubleEffectOn){
        noise += (tex2D(_DistortionNoiseTex, distortUV.zw).xy -0.5)*2;
        noise *= 0.5;
    }
    
    half2 maskUV = _MainTexUseScreenColor == 0 ? mainUV.xy : mainUV.zw;
    maskUV = maskUV * _DistortionMaskTex_ST.xy + _DistortionMaskTex_ST.zw;
    half4 maskTex = tex2D(_DistortionMaskTex,maskUV);

    half2 duv = mainUV.xy + noise * 0.2  * _DistortionIntensity * maskTex[_DistortionMaskChannel];
    mainColor = SampleMainTex(duv,color,faceId);
    return duv;
}

void ApplyDissolve(inout half4 mainColor,half2 dissolveUV,half4 color,half dissolveCDATA,half edgeWidthCDATA){
    
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

    #if defined(ALPHA_TEST)
    if(_DissolveClipOn)
        clip(dissolve-0.01);
    #endif
    
    mainColor.a *= dissolve;

    if(_DissolveEdgeOn){
        half edgeWidth = _DissolveEdgeWidthByCustomData_W > 0? edgeWidthCDATA : _EdgeWidth;
        half edge = saturate(smoothstep(edgeWidth-0.1,edgeWidth+0.1,dissolve));
        half4 edgeColor = lerp(_EdgeColor,_EdgeColor2,edge);
        // edgeColor.a *= edge;
        edge = saturate(smoothstep(0.,.6,1-dissolve));
        mainColor.xyz = lerp(mainColor.xyz,(mainColor.xyz*0.5+ edgeColor.xyz)*1.5,edge);
    }
    
}

void ApplyOffset(inout half4 mainColor,half4 offsetUV,half2 maskUV){
    half3 offsetColor = tex2D(_OffsetTex,offsetUV.xy) * _OffsetTexColorTint;
    offsetColor += _DoubleEffectOn > 0 ? tex2D(_OffsetTex,offsetUV.zw) * _OffsetTexColorTint2 : 0;

    half mask = tex2D(_OffsetMaskTex,maskUV)[_OffsetMaskChannel];

    offsetColor =  offsetColor * _OffsetBlendIntensity * unity_ColorSpaceDouble * mask;
    
    mainColor.rgb = mainColor.rgb * (_OffsetBlendMode + offsetColor);
}

void ApplyFresnal(inout half4 mainColor,half fresnel){
    half f = smoothstep(_FresnelPowerMin,_FresnelPowerMax,fresnel);
    half4 fresnelColor = f * lerp(_FresnelColor,_FresnelColor2,f);
    mainColor.xyz += (_FresnelColorMode == FRESNEL_COLOR_MULTIPLY? mainColor.xyz : 1 ) * fresnelColor;
    mainColor.a *= fresnelColor.a;
}

void ApplyEnv(inout half4 mainColor,half2 mainUV,half3 reflectDir,half3 refractDir){
    half mask = tex2D(_EnvMapMask,mainUV*_EnvMapMask_ST.xy+_EnvMapMask_ST.zw)[_EnvMapMaskChannel];

    half4 envColor = (half4)0;
    if(_EnvReflectOn)
        envColor += texCUBE(_EnvMap,reflectDir) * _EnvReflectionColor;
    if(_EnvRefractionOn)
        envColor += texCUBE(_EnvMap,refractDir) * _EnvRefractionColor;
    
    envColor *= _EnvIntensity * mask;
    mainColor.rgb += envColor.rgb;
}

void ApplyMatcap(inout half4 mainColor,half2 mainUV,half2 viewNormal){
    if(_MatCapRotateOn){
        // rotate tex by center
        half theta = radians(_MatCapAngle);
        viewNormal = (viewNormal-0.5 )* 2;
        viewNormal = half2(
            dot(half2(cos(theta),sin(theta)),viewNormal),
            dot(half2(-sin(theta),cos(theta)),viewNormal)
        );
        viewNormal = viewNormal * 0.5+0.5;
    }
    
    half4 matCapMap = tex2D(_MatCapTex,viewNormal.xy) * _MatCapColor;
    matCapMap *= _MatCapIntensity;
    mainColor.rgb += matCapMap;
}

void ApplySoftParticle(inout half4 mainColor,half4 projPos){
    half sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(projPos)));
    half partZ = projPos.z;
    half delta = (sceneZ-partZ);
    half fade = saturate (_DepthFadingWidth * delta + 0.12*delta);
    // mainColor *= smoothstep(-0.5,0.5,fade);
    mainColor *= fade;// xyz,a all multi fade
}

void ApplyLight(inout half4 mainColor,half3 normal){
    half3 lightDir = _WorldSpaceLightPos0.xyz + _WorldSpaceLightDirection.xyz;
    half nl = saturate(dot(normal,lightDir));
    mainColor.xyz *= nl;
}
#endif //POWER_VFX_CGINC