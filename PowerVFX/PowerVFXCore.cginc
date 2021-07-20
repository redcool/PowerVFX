// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

#if !defined(POWER_VFX_CGINC)
    #define POWER_VFX_CGINC

    #include "PowerVFXInput.cginc"
    #include "PowerVFXData.cginc"
    #include "NodeLib.cginc"
    #include "UtilLib.cginc"

    void ApplyVertexWaveWorldSpace(inout float3 worldPos,float3 normal,float3 vertexColor,float2 mainUV){
        float2 worldUV = worldPos.xz + _Time.y * _VertexWaveSpeed;
        float noise = Unity_GradientNoise(worldUV,_VertexWaveIntensity);

        //1 vertex color atten
        //2 uniform dir atten
        float3 dir = SafeNormalize(_VertexWaveDirAtten.xyz) * _VertexWaveDirAtten.w;
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
            float offsetScale = _Time.y * !_VertexWaveAtten_MaskMapOffsetStopOn;
            float4 attenMapUV = float4(mainUV * _VertexWaveAtten_MaskMap_ST.xy + _VertexWaveAtten_MaskMap_ST.zw * offsetScale,0,0);
            atten *= tex2Dlod(_VertexWaveAtten_MaskMap,attenMapUV)[_VertexWaveAtten_MaskMapChannel];
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

    float4 SampleMainTex(float2 uv,float4 vertexColor){
        float4 mainTex = _MainTexUseScreenColor ==0 ? tex2D(_MainTex,uv) : tex2D(_CameraOpaqueTexture,uv);
        mainTex.xyz *= lerp(1,mainTex.a,_MainTexMultiAlpha);
        return mainTex * _Color * vertexColor;
    }

    void ApplyMainTexMask(inout float4 mainColor,float2 uv){
        float2 maskTexOffset = _MainTexMaskOffsetStop ? _MainTexMask_ST.zw : _MainTexMask_ST.zw * _Time.xx;
        float4 maskTex = tex2D(_MainTexMask,uv*_MainTexMask_ST.xy + maskTexOffset);// fp opearate mask uv.
        mainColor.a *= maskTex[_MainTexMaskChannel];
    }

    void ApplyDistortion(inout float4 mainColor,float4 mainUV,float4 distortUV,float4 color){
        half2 noise = (tex2D(_DistortionNoiseTex, distortUV.xy).xy -0.5) * 2;
        if(_DoubleEffectOn)
            noise += (tex2D(_DistortionNoiseTex, distortUV.zw).zw -0.5)*2;
        
        float2 maskUV = _MainTexUseScreenColor == 0 ? mainUV.xy : mainUV.zw;

        float4 maskTex = tex2D(_DistortionMaskTex,maskUV);

        half2 uv = mainUV.xy + noise * 0.2  * _DistortionIntensity * maskTex[_DistortionMaskChannel];
        mainColor = SampleMainTex(uv,color);
    }

    void ApplyDissolve(inout float4 mainColor,float2 dissolveUV,float4 color,float dissolveCDATA,float edgeWidthCDATA){
        
        if(_PixelDissolveOn){
            dissolveUV = abs( dissolveUV - 0.5);
            dissolveUV = round(dissolveUV * _PixelWidth)/max(0.0001,_PixelWidth);
        }

        half4 dissolveTex = tex2D(_DissolveTex,dissolveUV.xy);
        half refDissolve = dissolveTex[_DissolveTexChannel];
        refDissolve = _DissolveRevert > 0 ? refDissolve : 1 - refDissolve;

        // remap cutoff
        half cutoff = _Cutoff;
        if(_DissolveByVertexColor)
            cutoff =  1 - color.a; // slider or vertex color

        if(_DissolveByCustomData)
            cutoff = 1- dissolveCDATA; // slider or particle's custom data
        
        cutoff = lerp(-0.15,1.01,cutoff);

        half dissolve = refDissolve - cutoff;

        if(_DissolveClipOn)
            clip(dissolve);

        // transparent outer edge
        if(_DissolveFadingOn)
            mainColor.a *= (smoothstep(0.0,_DissolveFadingWidth,saturate(dissolve + _DissolveFading)));

        if(_DissolveEdgeOn){
            half4 edgeColor = (half4)0;
            half edgeWidth = _DissolveEdgeWidthBy_Custom1 > 0? edgeWidthCDATA : _EdgeWidth;
            half edgeRate = cutoff + edgeWidth;
            
            half edge = step(refDissolve,edgeRate);

            // lerp edge colors 
            half smoothEdge = smoothstep(0.000001,edge*0.1,saturate(edgeRate - refDissolve));
            edgeColor = lerp(_EdgeColor,_EdgeColor2,saturate(1 - smoothEdge));

            // edge color fadeout by cutoff.
            edgeColor.a *= smoothstep(1,0.8,cutoff);

            // apply mainTex alpha
            edgeColor.a *= mainColor.a;
            mainColor = lerp(mainColor,edgeColor,edge);
        }
        
    }

    void ApplyOffset(inout float4 color,float4 offsetUV,float2 mainUV){
        half3 offsetColor = tex2D(_OffsetTex,offsetUV.xy) * _OffsetTexColorTint;
        offsetColor += _DoubleEffectOn > 0 ? tex2D(_OffsetTex,offsetUV.zw) * _OffsetTexColorTint2 : 0;

        half mask = tex2D(_OffsetMaskTex,mainUV)[_OffsetMaskChannel];

        offsetColor = color.rgb * offsetColor * _OffsetBlendIntensity * unity_ColorSpaceDouble;
        color.rgb += lerp(0,offsetColor,mask);
    }

    void ApplyFresnal(inout float4 mainColor,float fresnal){
        float f =  saturate(smoothstep(fresnal,0,_FresnelPower));
        if(_FresnelInvertOn)
            f = 1-f;
        
        float4 fresnalColor = _FresnelColor *f * _FresnelColor.a;
        mainColor.rgb =lerp(mainColor.rgb,fresnalColor.rgb,f*2);
        mainColor.a = saturate( lerp((_FresnelTransparent + f*2) ,mainColor.a,step(_FresnelTransparentOn,0)));
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
        float4 matCapMap = tex2D(_MatCapTex,viewNormal.xy);
        matCapMap *= _MatCapIntensity;
        mainColor.rgb += matCapMap;
    }

    void ApplySoftParticle(inout float4 mainColor,float4 projPos){
        float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(projPos)));
        float partZ = projPos.z;
        float fade = saturate (_DepthFadingWidth * (sceneZ-partZ));
        mainColor *= smoothstep(0.1,0.4,fade);
    }
#endif //POWER_VFX_CGINC