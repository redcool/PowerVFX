// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

#if !defined(POWER_VFX_CGINC)
    #define POWER_VFX_CGINC

    #include "PowerVFXInput.cginc"
    #include "PowerVFXData.cginc"
    #include "NodeLib.cginc"

    void ApplyVertexWaveWorldSpace(inout float3 worldPos,float3 normal,float3 dirAtten){
        float2 uv = worldPos.xz + _Time.y * _VertexWaveSpeed;
        float noise = Unity_GradientNoise(uv,_VertexWaveIntensity);

        float forwardAtten = 1;
        if(_VertexWaveAtten_ForwardAtten){
            forwardAtten = saturate(dot(normal,dirAtten));
        }
        worldPos.xyz += dirAtten * noise * forwardAtten;
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
        return mainTex * _Color * vertexColor * _ColorScale;
    }

    void ApplyMainTexMask(inout float4 mainColor,float2 uv){
        float2 maskTexOffset = _MainTexMaskOffsetStop ? _MainTexMask_ST.zw : _MainTexMask_ST.zw * _Time.xx;
        float4 maskTex = tex2D(_MainTexMask,uv*_MainTexMask_ST.xy + maskTexOffset);// fp opearate mask uv.
        float mask = _MainTexMaskUseR > 0 ? maskTex.r : maskTex.a;
        mainColor.a *= mask;
    }

    void ApplyDistortion(inout float4 mainColor,float4 mainUV,float4 distortUV,float4 color){
        half3 noise = (tex2D(_NoiseTex, distortUV.xy) -0.5) * 2;
        if(_DoubleEffectOn)
            noise += (tex2D(_NoiseTex2, distortUV.zw).rgb -0.5)*2;
        
        float2 maskUV = _MainTexUseScreenColor == 0 ? mainUV.xy : mainUV.zw;

        float4 maskTex = tex2D(_DistortionMaskTex,maskUV);
        float mask = _DistortionMaskUseR > 0? maskTex.r : maskTex.a;

        half2 uv = mainUV.xy + noise * 0.2  * _DistortionIntensity * mask;
        mainColor = SampleMainTex(uv,color);
    }

    void ApplyDissolve(inout float4 mainColor,float2 dissolveUV,float4 color,float dissolveCDATA,float edgeWidthCDATA){
        
        if(_PixelDissolveOn){
            dissolveUV = abs( dissolveUV - 0.5);
            dissolveUV = round(dissolveUV * _PixelWidth)/max(0.0001,_PixelWidth);
        }

        half4 dissolveTex = tex2D(_DissolveTex,dissolveUV.xy);
        half dissolve = lerp(dissolveTex.a,dissolveTex.r,_DissolveTexUseR);
        dissolve = _DissolveRevert > 0 ? dissolve : 1 - dissolve;

        // remap cutoff
        half cutoff = _DissolveByVertexColor > 0 ? 1 - color.a : _Cutoff; // slider or vertex color
        cutoff = _DissolveByCustomData >0 ? 1- dissolveCDATA :cutoff; // slider or particle's custom data
        cutoff = lerp(-0.1,1.01,cutoff);

        half a = dissolve - cutoff;
        clip(a);

        // transparent outer edge
        mainColor.a *= smoothstep(0.05,0.12,a+0.05);

        if(_DissolveEdgeOn){
            half4 edgeColor = (half4)0;
            half edgeWidth = _DissolveEdgeWidthBy_Custom1 > 0? edgeWidthCDATA : _EdgeWidth;
            half edgeRate = cutoff + edgeWidth;
            
            half edge = step(dissolve,edgeRate);

            // lerp edge colors 
            half smoothEdge = smoothstep(0.000001,edge*0.1,saturate(edgeRate - dissolve));
            edgeColor = lerp(_EdgeColor,_EdgeColor2,saturate(1 - smoothEdge));

            // edge color fadeout by cutoff.
            edgeColor.a *= smoothstep(1,0.8,cutoff);

            // apply mainTex alpha
            edgeColor.a *= mainColor.a;
            mainColor = lerp(mainColor,edgeColor,edge);
        }
        
    }

    void ApplyOffset(inout float4 color,float4 offsetUV,float2 mainUV){
        half4 offsetColor = tex2D(_OffsetTex,offsetUV.xy) * _OffsetTexColorTint;
        offsetColor += _DoubleEffectOn > 0 ? tex2D(_OffsetTex,offsetUV.zw) * _OffsetTexColorTint2 : 0;

        half4 offsetMask = tex2D(_OffsetMaskTex,mainUV);
        float mask = _OffsetMaskTexUseR > 0? offsetMask.r : offsetMask.a;

        offsetColor = offsetColor * _BlendIntensity * mask;
        color.rgb *= lerp(1,offsetColor,mask);
    }

    void ApplyFresnal(inout float4 mainColor,float fresnal){
        float f =  saturate(smoothstep(fresnal,0,_FresnelPower));
        float fMask  =1-f;
        
        float4 fresnalColor = _FresnelColor *f * _FresnelColor.a;
        mainColor.rgb =lerp(mainColor.rgb,fresnalColor.rgb,f*2);
        mainColor.a = saturate( lerp((_FresnelTransparent + f*2) ,mainColor.a,step(_FresnelTransparentOn,0)));
    }

    void ApplyEnvReflection(inout float4 mainColor,float2 mainUV,float3 reflectDir){
        float4 maskMap = tex2D(_EnvMapMask,mainUV);
        float mask = _EnvMapMaskUseR > 0?maskMap.r:maskMap.a;

        float4 envMap = texCUBE(_EnvMap,reflectDir);
        envMap *= _EnvIntensity * mask;
        mainColor.rgb += envMap.rgb;
    }

    void ApplyMatcap(inout float4 mainColor,float2 mainUV,float2 viewNormal){
        float4 matCapMap = tex2D(_MatCapTex,viewNormal.xy);
        matCapMap *= _MatCapIntensity;
        mainColor.rgb += matCapMap;
    }

#endif //POWER_VFX_CGINC