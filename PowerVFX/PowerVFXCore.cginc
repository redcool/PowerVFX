// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

#if !defined(POWER_VFX_CGINC)
    #define POWER_VFX_CGINC

    #include "PowerVFXInput.cginc"

    struct appdata
    {
        float4 vertex : POSITION;
        float3 normal:NORMAL;
        float4 color : COLOR;
        half4 uv : TEXCOORD0; // xy:main uv,zw : particle's customData(mainTex scroll)
        half4 uv1:TEXCOORD1; //particle's customData(x:dissolve,y:dissolveEdgeWidth)
    };

    struct v2f
    {
        float4 vertex : SV_POSITION;
        float4 color : COLOR;
        float3 reflectDir:COLOR1;
        float2 viewNormal:COLOR2;

        float4 uv : TEXCOORD0;
        float4 fresnal_customDataZ:TEXCOORD1;// x:fresnal,y:customData.x
        float4 grabPos:TEXCOORD2;
    };

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
        float4 mainTex = _MainTexUseScreenColor ==0 ? tex2D(_MainTex,uv) : tex2D(_ScreenColorTexture,uv);
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
        noise += _DoubleEffectOn > 0 ? (tex2D(_NoiseTex2, distortUV.zw).rgb -0.5)*2 : 0;
        
        float2 maskUV = _MainTexUseScreenColor == 0 ? mainUV.xy : mainUV.zw;

        float4 maskTex = tex2D(_DistortionMaskTex,maskUV);
        float mask = _DistortionMaskUseR > 0? maskTex.r : maskTex.a;

        half2 uv = mainUV.xy + noise * 0.2  * _DistortionIntensity * mask;
        mainColor = SampleMainTex(uv,color);
    }

    void ApplyDissolve(inout float4 mainColor,float2 dissolveUV,float4 color,float dissolveCDATA,float edgeWidthCDATA){
        half4 edgeColor = (half4)0;

        if(_PixelDissolveOn){
            dissolveUV = abs( dissolveUV - 0.5);
            dissolveUV = round(dissolveUV * _PixelWidth)/_PixelWidth;
        }

        half4 dissolveTex = tex2D(_DissolveTex,dissolveUV.xy);
        half dissolve = lerp(dissolveTex.a,dissolveTex.r,_DissolveTexUseR);
        half gray = _DissolveRevert > 0 ? dissolve : 1 - dissolve;

        // select cutoff
        half cutoff = _DissolveByVertexColor > 0 ? 1 - color.a : _Cutoff; // slider or vertex color
        cutoff = _DissolveByCustomData >0 ? 1- dissolveCDATA :cutoff; // slider or particle's custom data
        cutoff = lerp(-0.1,1.01,cutoff);

        half a = gray - cutoff;
        clip(a);

        if(_DissolveEdgeOn){
            half edgeWidth = _DissolveEdgeWidthBy_Custom1 > 0? edgeWidthCDATA : _EdgeWidth;
            half edgeRate = cutoff + edgeWidth;
            half edge = step(gray,edgeRate);
            edgeColor = edge * _EdgeColor * _EdgeColorIntensity;

            // edge color fadeout.
            edgeColor.a *= cutoff < 0.6 ? 1 : exp(-cutoff);
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

    v2f vert(appdata v)
    {
        v2f o = (v2f)0;
        o.color = v.color;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv; // uv.xy : main uv, zw : custom data.xy
        o.uv.xy = v.uv;
        o.grabPos = ComputeGrabScreenPos(o.vertex);

        float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
        float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
        float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));

        if(_EnvReflectOn)
            o.reflectDir = reflect(- viewDir,worldNormal + _EnvOffset.xyz);

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
        float fresnal = i.fresnal_customDataZ.x;
        float dissolveCustomData = i.fresnal_customDataZ.y;
        float dissolveEdgeWidth = i.fresnal_customDataZ.z;

        //use _ScreenColorTexture
        mainUV.xy = _MainTexUseScreenColor == 0 ? mainUV.xy : i.grabPos.xy/i.grabPos.w;

        if(_DistortionOn){
            float4 distortUV = mainUV.zwzw * _DistortTile + frac(_DistortDir * _Time.xxxx);
            ApplyDistortion(mainColor,mainUV,distortUV,i.color);
        }else{
            mainColor = SampleMainTex(mainUV.xy,i.color);
        }

        ApplyMainTexMask(mainColor,mainUV.zw);

        if(_EnvReflectOn)
            ApplyEnvReflection(mainColor,mainUV.zw,i.reflectDir);

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

        if(_FresnelOn)
            ApplyFresnal(mainColor,fresnal);
        
        ApplyMatcap(mainColor,mainUV.zw,i.viewNormal);

        return mainColor;
    }

#endif //POWER_VFX_CGINC