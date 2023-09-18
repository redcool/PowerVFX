#if !defined(POWER_VFX_CGINC)
#define POWER_VFX_CGINC
#define FRESNEL_COLOR_REPLACE 0
#define FRESNEL_COLOR_MULTIPLY 1

#include "CommonLib.hlsl"
#include "PowerVFXInput.hlsl"
#include "PowerVFXData.hlsl"
#include "../../PowerShaderLib/Lib/NodeLib.hlsl"
#include "../../PowerShaderLib/Lib/UVMapping.hlsl"
#include "../../PowerShaderLib/Lib/Colors.hlsl"
#include "../../PowerShaderLib/Lib/MathLib.hlsl"
#include "../../PowerShaderLib/UrpLib/Lighting.hlsl"
#include "../../PowerShaderLib/Lib/FogLib.hlsl"
#include "../../PowerShaderLib/Lib/ParallaxMapping.hlsl"

float4 SampleAttenMap(float2 mainUV,float attenMaskCData){
    // auto offset
    float2 uvOffset = UVOffset(_VertexWaveAtten_MaskMap_ST.zw,_VertexWaveAtten_MaskMapOffsetStopOn);
    // offset by custom data
    uvOffset = lerp(uvOffset,attenMaskCData + _VertexWaveAtten_MaskMap_ST.zw,_VertexWaveAttenMaskOffsetCustomDataOn);

    float4 attenMapUV = float4(mainUV * _VertexWaveAtten_MaskMap_ST.xy + uvOffset,0,0);
    return tex2Dlod(_VertexWaveAtten_MaskMap,attenMapUV);
}

void ApplyVertexWaveWorldSpace(inout float3 worldPos,float3 normal,float3 vertexColor,float2 mainUV,float attenMaskCData,float waveIntensityCData){
    float2 worldUV = worldPos.xz + _VertexWaveSpeed * lerp(_Time.xx,1,_VertexWaveSpeedManual);
    float noise = 0;
    float4 attenMap=0;
    float waveIntensity = _VertexWaveIntensityCustomDataOn ? waveIntensityCData : _VertexWaveIntensity;

    branch_if(_NoiseUseAttenMaskMap){
        attenMap = SampleAttenMap(mainUV,attenMaskCData);

        noise = attenMap.x;
    }else{
        noise = Unity_GradientNoise(worldUV,waveIntensity);
    }

    //1 vertex color atten
    //2 uniform dir atten
    float3 dir = SafeNormalize(_VertexWaveDirAtten.xyz) * _VertexWaveDirAtten.w;
    dir *= lerp(1,normal,_VertexWaveDirAlongNormalOn);
    
    branch_if(_VertexWaveDirAtten_LocalSpaceOn)
        dir = mul(unity_ObjectToWorld,float4(dir,1)).xyz;

    float3 vcAtten = _VertexWaveAtten_VertexColor? vertexColor : 1;
    float3 atten = dir * vcAtten;
    //3 normal direction atten
    atten *= lerp(1 , saturate(dot(dir,normal)) , _VertexWaveAtten_NormalAttenOn);

    //4 atten map
    branch_if(_VertexWaveAtten_MaskMapOn){
        branch_if(! _NoiseUseAttenMaskMap)
            attenMap = SampleAttenMap(mainUV,attenMaskCData);
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
    float2 mainUV = uv.xy;
    RotateUV(_MainUVAngle,0.5,mainUV/**/);

    float2 mainTexOffset = UVOffset(_MainTex_ST.zw,_MainTexOffsetStop);
    mainTexOffset = lerp(mainTexOffset,uv.zw, _MainTexOffset_CustomData_On); // vertex uv0.z : particle customData1.xy

    //apply sheet
    mainUV = RectUV(_Time.y*_MainTexSheetAnimSpeed,mainUV,_MainTexSheet,true,0);

    float4 scrollUV = (float4)0;
    scrollUV.xy = mainUV * _MainTex_ST.xy + mainTexOffset;
    scrollUV.zw = uv.xy;

    return scrollUV;
}

void ApplySaturate(inout float4 mainColor){
    mainColor.xyz = lerp(Gray(mainColor.xyz),mainColor.xyz,_MainTexSaturate);
}

half4 SampleMainTex(float2 uv){
    // #if defined(_SCREEN_TEX_ON)
    branch_if(_MainTexUseScreenColor)
    {
        return tex2D(_CameraOpaqueTexture,uv);
    }
    // #else
    else
    {
        return tex2D(_MainTex,uv);
    }
    // #endif
}

void SampleMainTexWithGlitch(inout float4 mainColor,float2 uv){
#if defined(_GLITCH_ON)
    #define _JitterBlockSize _JitterInfo.x
    #define _JitterIntensity _JitterInfo.y
    #define _JitterHorizontalIntensity _JitterInfo.z
    #define _JitterVerticalIntensity _JitterInfo.w

    float4 glitchUV = GlitchUV(uv,_SnowFlakeIntensity,_JitterBlockSize,_JitterIntensity,_VerticalJumpIntensity,
        _HorizontalShake,_ColorDriftSpeed,_ColorDriftIntensity,_HorizontalIntensity,_JitterHorizontalIntensity,_JitterVerticalIntensity);
    
    half4 c1 = SampleMainTex(glitchUV.xy);
    half4 c2 = SampleMainTex(glitchUV.zw);
    mainColor = half4(c1.x,c2.y,c1.z,c1.w*c2.w);
#else
    mainColor = SampleMainTex(uv);
#endif
}

half4 CalcVertexColor(half4 vertexColor,half vertexColorOn,half vertexColorChannelOn,half vertexColorChannel){
    half4 vc = lerp(vertexColor,vertexColor[vertexColorChannel],vertexColorChannelOn);
    return lerp(1,vc,vertexColorOn);
}

void SampleMainTex(inout float4 mainColor, inout float4 screenColor,float2 uv,float4 vertexColor,float faceId,SheetAnimBlendParams animBlendParams){
    float4 color = _BackFaceOn ? lerp(_BackFaceColor,_Color,faceId) : _Color;
    
    SampleMainTexWithGlitch(mainColor/**/,uv);
    branch_if(animBlendParams.isBlendOn)
    {
        float4 nextColor = 0;
        SampleMainTexWithGlitch(nextColor/**/,animBlendParams.blendUV);

        mainColor = lerp(mainColor,nextColor,animBlendParams.blendRate);
    }
    
    ApplySaturate(mainColor);

    //select a channel
    mainColor = lerp(mainColor, mainColor[_MainTexChannel] ,_MainTexSingleChannelOn);
    // multiply alpha
    mainColor.xyz *= lerp(1,mainColor.a * vertexColor.a * color.a,_MainTexMultiAlpha);
    // color tint (mainColor,colorScale,vertexColor)
    mainColor *= color * _ColorScale * CalcVertexColor(vertexColor,_PremultiVertexColor,_VertexColorChannelOn,_VertexColorChannel);
    // per channel tint
    mainColor.xyz = lerp(mainColor,mainColor.x * _ColorX + mainColor.y * _ColorY + mainColor.z * _ColorZ,_PerChannelColorOn).xyz;
    // for alpha
    mainColor.w *= _AlphaScale;
    mainColor.w = smoothstep(_AlphaMin,_AlphaMax,mainColor.w);
}

void ApplyMainTexMask(inout float4 mainColor,inout float4 mainTexMask,float2 uv,float2 maskOffsetCDATA){
    // float2 maskTexOffset = _MainTexMask_ST.zw * ( 1+ _Time.xx *(1-_MainTexMaskOffsetStop) );
    float2 maskTexOffset = UVOffset(_MainTexMask_ST.zw,_MainTexMaskOffsetStop);
    maskTexOffset = lerp(maskTexOffset,maskOffsetCDATA,_MainTexMaskOffsetCustomDataOn);
    
    mainTexMask = tex2D(_MainTexMask,uv*_MainTexMask_ST.xy + maskTexOffset);// fp opearate mask uv.
    mainColor.a *= mainTexMask[_MainTexMaskChannel];
}

half GetDistortionMask(float2 mainUV){
    float2 maskUV = mainUV * _DistortionMaskTex_ST.xy + _DistortionMaskTex_ST.zw;
    float4 maskTex = tex2D(_DistortionMaskTex,maskUV);
    return maskTex[_DistortionMaskChannel];
}

float2 GetDistortionUV(float2 mainUV,float4 distortUV,float customDataIntensity){
    float2 noise = (tex2D(_DistortionNoiseTex, distortUV.xy).xy -0.5) * 2;
    #if defined(DOUBLE_EFFECT_ON)
    // branch_if(_DoubleEffectOn)
    {
        noise += (tex2D(_DistortionNoiseTex, distortUV.zw).xy -0.5)*2;
        noise *= 0.5;
    }
    #endif
    
    half duvMask = 1;
    #if !defined(MIN_VERSION)
        duvMask = GetDistortionMask(mainUV);
    #endif

    float intensity = lerp(_DistortionIntensity,customDataIntensity,_DistortionCustomDataOn);
    float2 duv = noise * 0.2  * intensity * duvMask;
    return duv;
}

void ApplyPixelDissolve(inout float2 dissolveUV,half pixelWidth){
    dissolveUV = abs( dissolveUV - 0.5);
    dissolveUV = round(dissolveUV * pixelWidth)/max(0.0001,pixelWidth);
}
/**
    need external varables
    half _EdgeWidth
    half4 _EdgeColor1,_EdgeColor2
    half _DissolveEdgeWidthCustomDataOn
*/
void ApplyDissolveEdgeColor(inout float4 mainColor,float dissolve,float edgeWidthCDATA){
    float edgeWidth = lerp(_EdgeWidth,edgeWidthCDATA,_DissolveEdgeWidthCustomDataOn);

    // dissolve side's rate
    float edge = (smoothstep(edgeWidth-0.1,edgeWidth+0.1,dissolve));
    float4 edgeColor = lerp(_EdgeColor,_EdgeColor2,edge)*2;

    // not dissolve side's rate
    edge = (smoothstep(0.,.4,1-dissolve));

    mainColor.xyz = lerp(mainColor.xyz,edgeColor.xyz,edge);
}

void ApplyDissolve(inout float4 mainColor,float2 dissolveUV,float4 color,float dissolveCDATA,float edgeWidthCDATA){
    #if ! defined(MIN_VERSION)
    branch_if(_PixelDissolveOn)
    {
        // dissolveUV = abs( dissolveUV - 0.5);
        // dissolveUV = round(dissolveUV * _PixelWidth)/max(0.0001,_PixelWidth);
        ApplyPixelDissolve(dissolveUV/**/,_PixelWidth);
    }
    #endif

    float4 dissolveTex = tex2D(_DissolveTex,dissolveUV.xy);
    float refDissolve = dissolveTex[_DissolveTexChannel];
    // dissolveTex.a as mask
    refDissolve *= lerp(1,dissolveTex[_DissolveMaskChannel],_DissolveMaskFromTexOn);
    // refDissolve = _DissolveRevert > 0 ? refDissolve : 1 - refDissolve;

    // remap cutoff
    float cutoff = _Cutoff;

    // slider or vertex color
    cutoff = lerp(cutoff, 1 - color.a,_DissolveByVertexColor);

     // slider or particle's custom data
    cutoff = lerp(cutoff,1- dissolveCDATA,_DissolveCustomDataOn);
    
    cutoff = lerp(-0.15,1.01,cutoff);

    float dissolve = refDissolve - cutoff;
    dissolve = saturate(smoothstep(_DissolveFadingMin,_DissolveFadingMax,dissolve));

    #if defined(ALPHA_TEST)
    // branch_if(_DissolveClipOn)
        clip(dissolve-0.01);
    #endif
    
    mainColor.a *= dissolve;

    #if ! defined(MIN_VERSION)
    branch_if(_DissolveEdgeOn)
    {
        ApplyDissolveEdgeColor(mainColor/**/,dissolve,edgeWidthCDATA);
    }
    #endif
}

void ApplyOffset(inout float4 mainColor,float4 offsetUV,float2 maskUV,float parallaxWeight){
    float4 offsetColor = tex2D(_OffsetTex,offsetUV.xy) * _OffsetTexColorTint;
    #if defined(DOUBLE_EFFECT_ON)
        offsetColor += tex2D(_OffsetTex,offsetUV.zw) * _OffsetTexColorTint2;
    #endif

    float mask = tex2D(_OffsetMaskTex,maskUV)[_OffsetMaskChannel];

    offsetColor = offsetColor * _OffsetBlendIntensity * mask * 2 * parallaxWeight; //unity_ColorSpaceDouble
    
    /** offset blend mode
        0 : a*b
        1 : a+a*b
        2 : lerp(a,b,b.w)
    */
    // #if defined(_OFFSET_BLEND_REPLACE_MODE)
    branch_if(_OffsetBlendReplaceMode)
    {
        mainColor.rgb = lerp(mainColor.rgb,offsetColor.xyz,offsetColor[_OffsetBlendReplaceMode_Channel]);
    }
    // #else
    else
    {
        mainColor.rgb = mainColor.rgb * (_OffsetBlendMode + offsetColor.xyz);
    }
    // #endif
}

void ApplyFresnal(inout float4 mainColor,float fresnel,float4 screenColor){
    float f = smoothstep(_FresnelPowerMin,_FresnelPowerMax,fresnel);
    float4 fresnelColor = f * lerp(_FresnelColor,_FresnelColor2,f);
    mainColor.xyz += (_FresnelColorMode == FRESNEL_COLOR_MULTIPLY? mainColor.xyz : 1 ) * fresnelColor.xyz;
    mainColor.a *= fresnelColor.a;

    mainColor.xyz = lerp(mainColor,screenColor,_BlendScreenColor * f).xyz;
}

float3 SampleEnvMap(float3 dir){
    float4 c = SAMPLE_TEXTURECUBE(_EnvMap,sampler_EnvMap,dir);
    return DecodeHDREnvironment(c,_EnvMap_HDR);
}

void RotateReflectDir(inout float3 reflectDir,half3 axis,half rotateSpeed,bool autoStop){
    branch_if(!rotateSpeed)
        return;

    float rotSpeed = rotateSpeed * (autoStop ? 1 : _Time.y);
    half3x3 rotMat = AngleAxis3x3(rotSpeed,axis);
    reflectDir = mul(rotMat , reflectDir);
}


void ApplyEnv(inout float4 mainColor,float4 mainUV,float3 reflectDir,float3 refractDir,float envMask,float3 viewDirTS){
    float4 envColor = (float4)0;

    // #if defined(ENV_REFLECT_ON)
    branch_if(_EnvReflectOn)
    {
        envColor.xyz += SampleEnvMap(reflectDir) * _EnvReflectionColor.xyz;
    }
    // #endif
    
    // #if defined(ENV_REFRACTION_ON)        
    branch_if(_EnvRefractionOn)
    {
        // refract interiorMap
        branch_if(_RefractMode == 1)
        {
            refractDir = CalcInteriorMapReflectDir(viewDirTS,mainUV.xy);
            RotateReflectDir(refractDir/**/,_EnvRefractRotateInfo.xyz,_EnvRefractRotateInfo.w,_EnvRefractRotateAutoStop);
        }
        envColor.xyz += SampleEnvMap(refractDir) * _EnvRefractionColor.xyz;
    }
    // #endif
    
    envColor *= _EnvIntensity * envMask;
    mainColor.rgb += envColor.rgb;
}

void ApplyMatcap(inout float4 mainColor,float2 mainUV,float2 viewNormal){
    branch_if(_MatCapRotateOn)
    // #if defined(MATCAP_ROTATE_ON)
    {
        RotateUV(_MatCapAngle,float2(0,0),viewNormal);
    }
    // #endif
    float2 matUV = viewNormal.xy * 0.5 + 0.5;//[-1,1] -> [0,1]
    
    float4 matCapMap = tex2D(_MatCapTex,matUV) * _MatCapColor;
    matCapMap *= _MatCapIntensity;
    mainColor.rgb += matCapMap.xyz;
}

void ApplySoftParticle(inout float4 mainColor,float2 screenUV,float curZ){
    float sceneZ = tex2Dlod(_CameraDepthTexture, float4(screenUV,0,0)).x;
    sceneZ = IsOrthographicCamera() ? OrthographicDepthBufferToLinear(sceneZ) : LinearEyeDepth(sceneZ,_ZBufferParams);

    float delta = (sceneZ-curZ);
    float fade = (delta - _DepthFadingWidth)/_DepthFadingMax;
    mainColor.a *= saturate(fade);
}


/*
float Pow4(float a){return a*a*a*a;}

void ApplyPbrLighting_(inout float3 mainColor,float3 worldPos,float2 uv,float3 n,float3 v){
    float4 pbrMask = tex2D(_PbrMask,uv);
    float metallic = _Metallic * pbrMask.x;
    float smoothness = _Smoothness * pbrMask.y;
    float rough = 1-smoothness;
    float a = max(rough*rough,1e-4);
    float a2 = a*a;
    float occlusion = lerp(1, pbrMask.z,_Occlusion);

    float3 l = _MainLightPosition.xyz;
    float3 h = normalize(l+v);
    float nl = saturate(dot(n,l));
    float nv = saturate(dot(n,v));
    float nh = saturate(dot(n,h));
    float lh = saturate(dot(l,h));

    float3 diffColor = mainColor * (1-metallic);
    float3 specColor = lerp(0.04,mainColor,metallic);
    // gi
    float3 giDiff = diffColor * SampleSH(n);
    
    float mip = (1.7-0.7*rough)*rough*6;
    float3 reflectDir = reflect(-v,n);
    float4 envColor = SAMPLE_TEXTURECUBE_LOD(_EnvMap,sampler_EnvMap,reflectDir,mip);
    envColor.xyz = DecodeHDREnvironment(envColor,_EnvMap_HDR);
    float surfaceReducion = 1/(a2+1);
    float grazingTerm = saturate(metallic+smoothness);
    float fresnelTerm = Pow4(1-nv);
    float3 giSpec = envColor.xyz * lerp(specColor,grazingTerm,fresnelTerm) * surfaceReducion;
    mainColor = (giDiff + giSpec) * occlusion;

    // lighting
    float d = nh*nh*(a2-1)+1;
    float specTerm = a2/(d*d*max(0.0001,lh*lh) * (4*a+2));
    float3 radiance = nl * _MainLightColor.xyz;
    mainColor += (diffColor + specTerm * specColor) * radiance;
}
*/

void ApplyPbrLighting(inout float3 mainColor,float3 worldPos,float4 shadowCoord,float2 uv,float3 n,float3 v){
    float4 pbrMask = tex2D(_PbrMask,uv);
    float metallic = _Metallic * pbrMask.x;
    float smoothness = _Smoothness * pbrMask.y;
    float rough = 1-smoothness;
    float a = max(rough*rough,1e-4);
    float a2 = a*a;
    float occlusion = lerp(1, pbrMask.z,_Occlusion);

    float3 diffColor = mainColor * (1-metallic);
    float3 specColor = lerp(0.04,mainColor,metallic);

    float nv = saturate(dot(n,v));

    float3 reflectDirOffset = 0;
    float reflectIntensity = 1;
    float3 giDiff = CalcGIDiff(n,diffColor);
    float3 giSpec = CalcGISpec(_EnvMap,sampler_EnvMap,_EnvMap_HDR,specColor,worldPos,n,v,reflectDirOffset,reflectIntensity,nv,a,a2,smoothness,metallic);
    half3 giColor = (giDiff + giSpec)*occlusion;
    
    mainColor = giColor;

    Light mainLight = GetMainLight();
    mainLight.shadowAttenuation = CalcShadow(shadowCoord,worldPos,_MainLightSoftShadowScale);

    half3 lightColor = CalcLight(mainLight,diffColor,specColor,n,v,a,a2);
    mainColor += lightColor;

    #if defined(_ADDITIONAL_LIGHTS)
        float4 shadowMask = 0;
        mainColor += CalcAdditionalLights(worldPos,diffColor,specColor,n,v,a,a2,shadowMask,_AdditionalLightSoftShadowScale);
    #endif
}

float3 SampleNormalMap(float2 uv,float4 tSpace0,float4 tSpace1,float4 tSpace2){
    float3 tn = UnpackNormalScale(tex2D(_NormalMap,uv),_NormalMapScale);
    return TangentToWorld(tn,tSpace0,tSpace1,tSpace2);
}

void ApplyFog(inout float3 mainColor/**/,float3 worldPos,float2 fogCoord){
    #if defined(FOG_LINEAR)
        float fogNoise = 0;
        BlendFogSphereKeyword(mainColor.xyz,worldPos,fogCoord,_HeightFogOn,fogNoise,_DepthFogOn);
    #endif
}

// #if defined(_PARALLAX)
float ApplyParallax(inout float2 uv,float3 viewTS){
    float size = 1.0/_ParallaxIterate;
    float heightValue = 0;
    // branch_if(_ParallaxOn)
    UNITY_LOOP for(int i=0;i<_ParallaxIterate;i++)
    {
        float height = SAMPLE_TEXTURE2D(_ParallaxMap,sampler_ParallaxMap,uv)[_ParallaxMapChannel];
        uv += ParallaxMapOffset(_ParallaxHeight,viewTS,height) * height * size;
        heightValue = height;
    }
    return heightValue;
}
// #endif
#endif //POWER_VFX_CGINC