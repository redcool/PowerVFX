// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

#if !defined(POWER_VFX_CGINC)
    #define POWER_VFX_CGINC

    fixed4 _Color;
    float _ColorScale;
    sampler2D _MainTex;
    half4 _MainTex_ST;
    int _MainTexOffsetStop;
    int _MainTexOffsetUseCustomData_XY;

    int _DoubleEffectOn; //2层效果,
    sampler2D _MainTexMask;
    float4 _MainTexMask_ST;
    int _MainTexMaskOffsetStop; //
    int _MainTexMaskUseR;
    int _MainTexUseScreenColor;

    #if defined(DISTORTION_ON)
        sampler2D _NoiseTex;
        sampler2D _NoiseTex2;
        int _DistortionNoiseTex2On;
        sampler2D _DistortionMaskTex;
        int _DistortionMaskUseR;
        float _DistortionIntensity;
        float4 _DistortTile,_DistortDir;
    #endif

    #if defined(DISSOLVE_ON)
        int _DissolveRevert;
        sampler2D _DissolveTex;
        int _DissolveByVertexColor;
        int _DissolveByCustomData;
        int _DissolveTexUseR;
        float4 _DissolveTex_ST;
        int _DissolveTexOffsetStop;
        float _Cutoff;
        int _DissolveEdgeWidthBy_Custom1;
        float _EdgeWidth;
        float4 _EdgeColor;
        float _EdgeColorIntensity;
        float _DissolveClipOn;
    #endif

    #if defined(OFFSET_ON)
        sampler2D _OffsetTex;
        sampler2D _OffsetMaskTex;
        int _OffsetMaskTexUseR;
        float4 _OffsetTexColorTint,_OffsetTexColorTint2;
        float4 _OffsetTile,_OffsetDir;
        float _BlendIntensity;
    #endif

    sampler2D _ScreenColorTexture;

    #if defined(FRESNAL_ON)
    float4 _FresnalColor;
    float _FresnalPower;
    int _FresnalTransparentOn;
    float _FresnalTransparent;
    #endif

    #if defined(ENV_REFLECT)
    samplerCUBE _EnvMap;
    sampler2D _EnvMapMask;
    int _EnvMapMaskUseR;
    float _EnvIntensity;
    float4 _EnvOffset;
    #endif

    sampler2D _MatCapTex;
    float _MatCapIntensity;

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
        #if defined(DISTORTION_ON)
            half3 noise = (tex2D(_NoiseTex, distortUV.xy) -0.5) * 2;
            noise += _DoubleEffectOn > 0 ? (tex2D(_NoiseTex2, distortUV.zw).rgb -0.5)*2 : 0;
            
            float2 maskUV = _MainTexUseScreenColor == 0 ? mainUV.xy : mainUV.zw;

            float4 maskTex = tex2D(_DistortionMaskTex,maskUV);
            float mask = _DistortionMaskUseR > 0? maskTex.r : maskTex.a;

            half2 uv = mainUV.xy + noise * 0.2  * _DistortionIntensity * mask;
            mainColor = SampleMainTex(uv,color);
        #endif
    }

    void ApplyDissolve(inout float4 mainColor,float2 dissolveUV,float4 color,float dissolveCDATA,float edgeWidthCDATA){
        #if defined(DISSOLVE_ON)
            half4 edgeColor = (half4)0;

            half4 dissolveTex = tex2D(_DissolveTex,dissolveUV.xy);
            half dissolve = lerp(dissolveTex.a,dissolveTex.r,_DissolveTexUseR);
            half gray = _DissolveRevert > 0 ? dissolve : 1 - dissolve;

            // select cutoff
            half cutoff = _DissolveByVertexColor > 0 ? 1 - color.a : _Cutoff; // slider or vertex color
            cutoff = _DissolveByCustomData >0 ? 1- dissolveCDATA :cutoff; // slider or particle's custom data
            cutoff = lerp(-0.1,1.01,cutoff);

            half a = gray - cutoff;

            if(_DissolveClipOn)
                clip(a);

            #if defined(DISSOLVE_EDGE_ON)
                half edgeWidth = _DissolveEdgeWidthBy_Custom1 > 0? edgeWidthCDATA : _EdgeWidth;
                half edgeRate = cutoff + edgeWidth;
                half edge = step(gray,edgeRate);
                edgeColor = edge * _EdgeColor * _EdgeColorIntensity;

                // edge color fadeout.
                edgeColor.a *= cutoff < 0.6 ? 1 : exp(-cutoff);
                // apply mainTex alpha
                edgeColor.a *= mainColor.a;
                mainColor = lerp(mainColor,edgeColor,edge);
            #endif
        #endif

    }

    void ApplyOffset(inout float4 color,float4 offsetUV,float2 mainUV){
        #if defined(OFFSET_ON)
            half4 offsetColor = tex2D(_OffsetTex,offsetUV.xy) * _OffsetTexColorTint;
            offsetColor += _DoubleEffectOn > 0 ? tex2D(_OffsetTex,offsetUV.zw) * _OffsetTexColorTint2 : 0;

            half4 offsetMask = tex2D(_OffsetMaskTex,mainUV);
            float mask = _OffsetMaskTexUseR > 0? offsetMask.r : offsetMask.a;

            offsetColor = offsetColor * _BlendIntensity * mask;
            color.rgb *= lerp(1,offsetColor,mask);
            
        #endif
    }

    void ApplyFresnal(inout float4 mainColor,float fresnal){
        #if defined(FRESNAL_ON)
        float f =  saturate(smoothstep(fresnal,0,_FresnalPower));
        float fMask  =1-f;
        
        float4 fresnalColor = _FresnalColor *f * _FresnalColor.a;
        mainColor.rgb =lerp(mainColor.rgb,fresnalColor.rgb,f*2);
        mainColor.a = saturate( lerp((_FresnalTransparent + f*2) ,mainColor.a,step(_FresnalTransparentOn,0)));
        #endif
    }

    void ApplyEnvReflection(inout float4 mainColor,float2 mainUV,float3 reflectDir){
        #if defined(ENV_REFLECT)
        float4 maskMap = tex2D(_EnvMapMask,mainUV);
        float mask = _EnvMapMaskUseR > 0?maskMap.r:maskMap.a;

        float4 envMap = texCUBE(_EnvMap,reflectDir);
        envMap *= _EnvIntensity * mask;
        mainColor.rgb += envMap.rgb;
        #endif
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

        #if defined(ENV_REFLECT)
        o.reflectDir = reflect(- viewDir,worldNormal + _EnvOffset.xyz);
        #endif

        float3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_MV,v.normal));
        o.viewNormal = viewNormal.xy * 0.5 + 0.5;

        #if defined(FRESNAL_ON)
            o.fresnal_customDataZ.x = 1 - dot(worldNormal,viewDir) ;
        #endif

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

        #if defined(DISTORTION_ON)
            float4 distortUV = mainUV.zwzw * _DistortTile + frac(_DistortDir * _Time.xxxx);
            ApplyDistortion(mainColor,mainUV,distortUV,i.color);
        #else
            mainColor = SampleMainTex(mainUV.xy,i.color);
        #endif

        ApplyMainTexMask(mainColor,mainUV.zw);

        #if defined(ENV_REFLECT)
        ApplyEnvReflection(mainColor,mainUV.zw,i.reflectDir);
        #endif

        #if defined(OFFSET_ON)
            float4 offsetUV = mainUV.zwzw * _OffsetTile + (_Time.xxxx * _OffsetDir); //暂时去除 frac
            ApplyOffset(mainColor,offsetUV,mainUV.zw);
        #endif

        //dissolve
        #if defined(DISSOLVE_ON)
            float2 dissolveUVOffsetScale = lerp(_Time.xx,1,_DissolveTexOffsetStop);
            float2 dissolveUV = mainUV.zw * _DissolveTex_ST.xy + _DissolveTex_ST.zw * dissolveUVOffsetScale;
            ApplyDissolve(mainColor,dissolveUV,i.color,dissolveCustomData,dissolveEdgeWidth);
        #endif
        #if defined(FRESNAL_ON)
        ApplyFresnal(mainColor,fresnal);
        #endif
        ApplyMatcap(mainColor,mainUV.zw,i.viewNormal);

        return mainColor;
    }

#endif //POWER_VFX_CGINC