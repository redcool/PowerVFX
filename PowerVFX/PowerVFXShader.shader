Shader "FX/PowerVFX"
{
	Properties
	{
		[GroupHeader(,MainTex)]
		_MainTex("Main Texture", 2D) = "white" {}
		[Group(MainTex Options)]
		[GroupItem(MainTex Options)]_MainUVAngle("_MainUVAngle",float) = 0
		[GroupToggle(MainTex Options)]_MainTexOffsetStop("_MainTexOffsetStop",int)=0
		[GroupHeader(MainTex Options,MainTex Custom Data)]
		[GroupToggle(MainTex Options)]_MainTexOffset_CustomData_On("_MainTexOffset_CustomData_On",int)=0
		[GroupEnum(MainTex Options,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_MainTexOffset_CustomData_X("_MainTexOffset_CustomData_X",int) = 0
		[GroupEnum(MainTex Options,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_MainTexOffset_CustomData_Y("_MainTexOffset_CustomData_Y",int) = 1

		[GroupHeader(MainTex Options,Saturate)]
		[GroupItem(MainTex Options)]_MainTexSaturate("_MainTexSaturate",float) = 1
		
		[GroupHeader(MainTex Options,Single Channel MainTex)]
		[GroupToggle(MainTex Options)]_MainTexSingleChannelOn("_MainTexSingleChannelOn?",int) = 0
		[GroupEnum(MainTex Options,R 0 G 1 B 2 A 3)]_MainTexChannel("_MainTexChannel",int)=0

		[GroupHeader(MainTex Options,Premulti Alpha)]
		[GroupToggle(MainTex Options)]_MainTexMultiAlpha("_MainTexMultiAlpha",int) = 0

		// mainTex Color
		[Group(MainColorOptions)]
		[GroupHeader(MainColorOptions,Main Color)]
		[GroupItem(MainColorOptions)][HDR]_Color("Main Color",Color) = (1,1,1,1)
		[GroupItem(MainColorOptions)]_ColorScale("ColorScale",range(1,3)) = 1

		[GroupHeader(MainColorOptions,Vertex Color)]
		[GroupToggle(MainColorOptions)]_PremultiVertexColor("_PremultiVertexColor",int) = 1
		[GroupHeader(MainColorOptions,Vertex Color Channel)]
		[GroupToggle(MainColorOptions)]_VertexColorChannelOn("_VertexColorChannelOn",int) = 0
		[GroupEnum(MainColorOptions,R 0 G 1 B 2 A 3)]_VertexColorChannel("_VertexColorChannel",int) = 0

		// mainTex channel
		[GroupHeader(MainColorOptions,Per Channel Color)]
		[GroupToggle(MainColorOptions)]_PerChannelColorOn("_PerChannelColorOn",float) = 0
		[GroupItem(MainColorOptions)][HDR]_ColorX("Color_X",Color) = (1,1,1,1)
		[GroupItem(MainColorOptions)][HDR]_ColorY("Color_Y",Color) = (1,1,1,1)
		[GroupItem(MainColorOptions)][HDR]_ColorZ("Color_Z",Color) = (1,1,1,1)

		// back face
		[Group(Back Face)]
		[GroupToggle(Back Face)]_BackFaceOn("_BackFaceOn",int) = 0
		[GroupItem(Back Face)][HDR]_BackFaceColor("BackFace Color",Color) = (0.5,0.5,.5,1)

		[Space(10)]
		[GroupHeader(MainTex Mask)]
		_MainTexMask("Main Texture Mask(R)", 2D) = "white" {}
		[Group(MainTex Mask Options)]
		[GroupToggle(MainTex Mask Options)]_MainTexMaskOffsetStop("_MainTexMaskOffsetStop",int)=0
		[GroupEnum(MainTex Mask Options,R 0 G 1 B 2 A 3)]_MainTexMaskChannel("_MainTexMaskChannel",int) = 0

		[GroupHeader(MainTex Mask Options,MainTexMask Custom Data)]
		[GroupToggle(MainTex Mask Options)]_MainTexMaskOffsetCustomDataOn("_MainTexMaskOffsetCustomDataOn",int)=0
		[GroupEnum(MainTex Mask Options,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_MainTexMaskOffsetCustomDataX("_MainTexMaskOffsetCustomDataX",int) = 6
		[GroupEnum(MainTex Mask Options,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_MainTexMaskOffsetCustomDataY("_MainTexMaskOffsetCustomDataY",int) = 7

		[Space(10)]
		[GroupHeader(_,ScreenTexture)]
		[GroupToggle(_,)]_MainTexUseScreenColor("_MainTexUseScreenColor",int) = 0
		[GroupToggle()]_MainTexUseScreenUV("_MainTexUseScreenUV",int) = 0
		[GroupToggle()]_FullScreenMode("_FullScreenMode",int) = 0

		[Space(10)]
		[Group(SheetAnimation)]
		[GroupVectorSlider(SheetAnimation,RowCount ColumnCount,1_16 1_16,,int)]_MainTexSheet("_MainTexSheet",vector)=(1,1,1,1)
		[GroupItem(SheetAnimation)]_MainTexSheetAnimSpeed("_MainTexSheetAnimSpeed",float) = 1
		[GroupToggle(SheetAnimation)]_MainTexSheetAnimBlendOn("_MainTexSheetAnimBlendOn",int) = 0 //SHEET_ANIM_BLEND_ON
		// [GroupToggle(_)]_MainTexSheetPlayOnce("_MainTexSheetPlayOnce",int) = 0
// ==================================================		Alpha
		[Header(Alpha Range)]
		_AlphaMin("_AlphaMin",range(0,1)) = 0
		_AlphaMax("_AlphaMax",range(0,1)) = 1

		[Header(Alpha Scale)]
		_AlphaScale("_AlphaScale",float) = 1
// ================================================== States Settings
		[Header(BlendMode)]
		[Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("Src Mode",int) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_DstMode("Dst Mode",int) = 10
		// [Header(BlendOp)]
		// [Enum(UnityEngine.Rendering.BlendOp)]_BlendOp("_BlendOp",int) = 0

		[Header(DoubleEffect)]
		[GroupToggle(_,DOUBLE_EFFECT_ON)]_DoubleEffectOn("双重效果?",int)=0
		
		[Header(CullMode)]
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode",float) = 0
		[GroupToggle]_ZWriteMode("ZWriteMode",int) = 0
		/*
		Disabled,Never,Less,Equal,LessEqual,Greater,NotEqual,GreaterEqual,Always
		*/
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",float) = 4

		[Header(Color Mask)]
		[GroupEnum(_,RGBA 16 RGB 15 RG 12 GB 6 RB 10 R 8 G 4 B 2 A 1 None 0)]
		_ColorMask("_ColorMask",int) = 15

		[Header(Versions)]
		// [GroupToggle(_,MIN_VERSION)]_MinVersion("_MinVersion",int) = 0
// ==================================================_VertexWaveOn
		[GroupToggle(_,VERTEX_WAVE_ON)]_VertexWaveOn("_VertexWaveOn ?",int) = 0
		[Header(Noise Map)]
		[GroupToggle]_NoiseUseAttenMaskMap("_NoiseUseAttenMaskMap",float)=0
		
		[Header(Noise Params)]
		_VertexWaveSpeed("_VertexWaveSpeed",float) = 1
		[GroupToggle]_VertexWaveSpeedManual("_VertexWaveSpeedManual",int) = 0
		_VertexWaveIntensity("_VertexWaveIntensity",float) = 1
		
		[Header(VertexWaveIntensity CustomDataOn)]
		[GroupToggle]_VertexWaveIntensityCustomDataOn("_VertexWaveIntensityCustomDataOn",int) = 0
		[GroupEnum(_,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_VertexWaveIntensityCustomData("_VertexWaveIntensityCustomData",int) = 7

		[Header(Vertex Color Atten)]
		[GroupToggle]_VertexWaveAtten_VertexColor("_VertexWaveAtten_VertexColor(rgb)",float) = 0
		[Header(Vertex Wave Direction)]
		_VertexWaveDirAtten("_VertexWaveDirAtten(xyz:dir,w:len)",vector) = (1,1,1,1)
		[GroupToggle]_VertexWaveDirAlongNormalOn("_VertexWaveDirAlongNormalOn?",int) = 0
		[GroupToggle]_VertexWaveDirAtten_LocalSpaceOn("_VertexWaveDirAtten_LocalSpaceOn",int) = 0
		[GroupToggle]_VertexWaveAtten_NormalAttenOn("_VertexWaveAtten_NormalAttenOn",float) = 0

		[Header(Vertex Wava Atten Map)]
		[GroupToggle]_VertexWaveAtten_MaskMapOn("_VertexWaveAtten_MaskMapOn",int) = 0
		_VertexWaveAtten_MaskMap("_VertexWaveAtten_MaskMap",2d) = "white"{}
		[Enum(R,0,G,1,B,2,A,3)]_VertexWaveAtten_MaskMapChannel("_VertexWaveAtten_MaskMapChannel",int) = 0
		[GroupToggle]_VertexWaveAtten_MaskMapOffsetStopOn("_VertexWaveAtten_MaskMapOffsetStopOn",int) = 0

		[Header(VertexWaveAttenMaskOffset Custom Data)]
		[GroupToggle]_VertexWaveAttenMaskOffsetCustomDataOn("_VertexWaveAttenMaskOffsetCustomDataOn",int) = 0
		[GroupEnum(_,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_VertexWaveAttenMaskOffsetCustomData("_VertexWaveAttenMaskOffsetCustomData",int) = 4
// ==================================================Distortion
		[Header(Distortion)]
		[GroupToggle(_,DISTORTION_ON)]_DistortionOn("Distortion On?",int)=0
		[noscaleoffset]_DistortionNoiseTex("Noise Texture(xy:layer1,zw:layer2)",2D) = "white" {}
		
		[Header(DistortionMask)]
		_DistortionMaskTex("Distortion Mask Tex(R)",2d) = "white"{}
		[Enum(R,0,G,1,B,2,A,3)]_DistortionMaskChannel("_DistortionMaskChannel",int)=0

		[Header(Distortion Intensity)]
		_DistortionIntensity("Distortion Intensity",Range(0,2)) = 0.5
		[Header(Distortion Custom Data)]
		[GroupToggle]_DistortionCustomDataOn("_DistortionCustomDataOn",int) = 0
		[GroupEnum(_,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_DistortionCustomData("_DistortionCustomData",int) = 5

		[Header(DistortionParams)]
		_DistortTile("Distort Tile",vector) = (1,1,1,1)
		_DistortDir("Distort Dir",vector) = (0,1,0,-1)

		[Group(RadialUV)]
		[GroupHeader(RadialUV,RadialUV)]
		[GroupToggle(RadialUV)]_DistortionRadialUVOn("_DistortionRadialUVOn",int) = 0
		[GroupVectorSlider(RadialUV,CenterX CenterY ScaleX ScaleY,0_1 0_1 0_1 0_1,,float float field field)]_DistortionRadialCenter_Scale("_DistortionRadialCenter_Scale",vector) = (.5,.5,1,1)
		[GroupItem(RadialUV)]_DistortionRadialRot("_DistortionRadialRot",float) = 0
		[GroupItem(RadialUV)]_DistortionRadialUVOffset("_DistortionRadialUVOffset",float) = 0

		[Group(DistortionWhere)]
		[GroupToggle(DistortionWhere)]_DistortionApplyToOffset("_DistortionApplyToOffset",int) = 0
		[GroupToggle(DistortionWhere)]_DistortionApplyToMainTexMask("_DistortionApplyToMainTexMask",int) = 0
		[GroupToggle(DistortionWhere)]_DistortionApplyToDissolve("_DistortionApplyToDissolve",int) = 0
// ==================================================Dissolve
		[Header(Dissolve)]
		[GroupToggle(_,DISSOLVE_ON)]_DissolveOn("Dissolve On?",int)=0
		_DissolveTex("Dissolve Tex",2d)=""{}
		[GroupToggle]_DissolveTexOffsetStop("_DissolveTexOffsetStop ?",int) = 0
		[Enum(R,0,G,1,B,2,A,3)]_DissolveTexChannel("_DissolveTexChannel",int) = 0

		[Header(DissolveMask)]
		[GroupToggle]_DissolveMaskFromTexOn("_DissolveMaskFromTexOn",int) = 0
		[Enum(R,0,G,1,B,2,A,3)]_DissolveMaskChannel("_DissolveMaskChannel",int)=3
		
		[Header(DissolveType)]
		[GroupToggle]_DissolveByVertexColor("Dissolve By Vertex Color ?",int)=0

		[Header(Dissolve Custom Data)]
		[GroupToggle]_DissolveCustomDataOn("Dissolve By customData.z -> uv1.x ?",int)=0
		//default custom1.z
		[GroupEnum(_,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_DissolveCustomData("_DissolveCustomData",int) = 2

		[Header(DissolveFading)]
		_DissolveFadingMin("_DissolveFadingMin",range(0,1)) = 0
		_DissolveFadingMax("_DissolveFadingMax",range(0,1)) = .2

		[Header(Dissolve Progress)]
		_Cutoff ("_Cutoff", Range(0,1)) = 0.5
		[Header(Dissolve Clip)]
		[GroupToggle(,ALPHA_TEST)]_DissolveClipOn("_DissolveClipOn",int) = 0

		[Header(PixelDissolve)]
		[GroupToggle]_PixelDissolveOn("_PixelDissolveOn",float) = 0
		_PixelWidth("_PixelWidth",float) = 10

// ================================================== dissolve edge
		[Group(DissolveEdge)]
		[GroupHeader(DissolveEdge,Dissolve Edge)]
		[GroupToggle(DissolveEdge)]_DissolveEdgeOn("Dissolve Edge On?",int)=0
		[GroupItem(DissolveEdge)]_EdgeWidth("EdgeWidth",range(0,1)) = 0.1

		[GroupHeader(DissolveEdge, Custom Data)]
		[GroupToggle(DissolveEdge)]_DissolveEdgeWidthCustomDataOn("_DissolveEdgeWidthCustomDataOn.w -> uv1.y",int) = 0
		//default custom1.w
		[GroupEnum(DissolveEdge,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_DissolveEdgeWidthCustomData("_DissolveEdgeWidthCustomData",int) = 3

		[GroupItem(DissolveEdge)][HDR]_EdgeColor("EdgeColor",color) = (1,0,0,1)
		[GroupItem(DissolveEdge)][HDR]_EdgeColor2("EdgeColor2",color) = (0,1,0,1)
// ==================================================Offset
		[Header(Offset)] 
		[GroupToggle(_,OFFSET_ON)] _OffsetOn("Offset On?",int) = 0
		[NoScaleOffset]_OffsetTex("Offset Tex",2d) = ""{}
		_OffsetTile("Offset Tile",vector) = (1,1,1,1)
		_OffsetDir("Offset Dir",vector) = (1,1,0,0)
		[GroupToggle]_StopAutoOffset("_StopAutoOffset",int) = 0 //停止自动流动
		
		[Header(Offset CustomData)]
		[GroupToggle]_OffsetCustomDataOn("_OffsetCustomDataOn",int) = 1
		[GroupEnum(_,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_OffsetLayer1_CustomData_X("_OffsetLayer1_CustomData_X",int) = 0
		[GroupEnum(_,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_OffsetLayer1_CustomData_Y("_OffsetLayer1_CustomData_Y",int) = 1


		[Header(Offset Color)]
		[HDR]_OffsetTexColorTint("OffsetTex Color",color) = (1,1,1,1)
		[HDR]_OffsetTexColorTint2("OffsetTex Color 2",color) = (1,1,1,1)
		//==================================== offset blend
		[Group(OffsetBlendMode)]
		[GroupHeader(OffsetBlendMode,Blend Ops)]
		[GroupItem(OffsetBlendMode)]_OffsetBlendIntensity("Blend Intensity",range(0,10)) = 0.5
		// left : multiply(blend), mainColor * (1+offsetColor)
		[GroupItem(OffsetBlendMode)]_OffsetBlendMode("_OffsetBlendMode",range(0,1)) = 1
		// replace mode
		[GroupHeader(OffsetBlendMode,Replace Blend Mode)]
		[GroupToggle(OffsetBlendMode)]_OffsetBlendReplaceMode("_OffsetBlendReplaceMode",int)=0
		[GroupEnum(OffsetBlendMode,R 0 G 1 B 2 A 3)]_OffsetBlendReplaceMode_Channel("_OffsetBlendReplaceMode_Channel",int) = 3
		
		[Header(Offset Mask)]
		_OffsetMaskTex("Offset Mask (R)",2d) = "white"{}
		[GroupToggle]_OffsetMaskPanStop("_OffsetMaskPanStop",float) = 0
		[Enum(R,0,G,1,B,2,A,3)]_OffsetMaskChannel("_OffsetMaskChannel",int) = 0
		//==================================== offset polar
		[Group(OffsetRadial)]
		[GroupHeader(OffsetRadial,Radial UV)]
		[GroupToggle(OffsetRadial)]_OffsetRadialUVOn("_OffsetRadialUVOn",int) = 0
		[GroupVectorSlider(OffsetRadial,CenterX CenterY ScaleX ScaleY,0_1 0_1 0_1 0_1,,float float field field)]_OffsetRadialCenter_Scale("_OffsetRadialCenter_Scale",vector) = (.5,.5,1,1)
		[GroupItem(OffsetRadial)]_OffsetRadialRot("_OffsetRadialRot",float) = 0
		[GroupItem(OffsetRadial)]_OffsetRadialUVOffset("_OffsetRadialUVOffset",float) = 0
// ==================================================Fresnal
		[Header(Fresnal)]
		[GroupToggle(_,FRESNEL_ON)]_FresnelOn("_FresnelOn?",int)=0
		[Enum(Replace,0,Multiply,1)]_FresnelColorMode("_FresnelColorMode",int) = 0
		[HDR]_FresnelColor("_FresnelColor",color) = (1,1,1,1)
		[HDR]_FresnelColor2("_FresnelColor2",color) = (1,1,1,1)
		[Header(Range)]
		_FresnelPowerMin("_FresnelPowerMin",range(0,1)) = 0.4
		_FresnelPowerMax("_FresnelPowerMax",range(0,1)) = 0.5
		[Header(BlendScreenColor)]
		_BlendScreenColor("_BlendScreenColor",range(0,1)) = 0
// ==================================================	EnvReflection
		[GroupHeader(,Reflect)]
		[GroupToggle()]_EnvReflectOn("EnvReflect On?",int)=0

		[Group(EnvReflection)]
		[GroupItem(EnvReflection)][hdr]_EnvReflectionColor("_EnvReflectionColor",color) = (.5,.5,.5,.5)

		[GroupHeader(EnvReflection,Env Rotate)]
		[GroupVectorSlider(EnvReflection,Axis Speed,m10_10,,float)]_EnvRotateInfo("_EnvRotateInfo",vector) = (0,1,0,0) // (axis, speed)
		[GroupToggle(EnvReflection)]_EnvRotateAutoStop("_EnvRotateAutoStop",float) = 0
		
// ==================================================	EnvRefraction		
		[GroupHeader(,Refraction)]
		[GroupToggle()]_EnvRefractionOn("_EnvRefractionOn",int) = 0

		[Group(EnvRefraction)]
		[GroupItem(EnvRefraction)]_EnvRefractionIOR("_EnvRefractionIOR",range(1,5)) = 1.33
		[GroupItem(EnvRefraction)][hdr]_EnvRefractionColor("_EnvRefractionColor",color) = (.5,.5,.5,.5)

		[GroupHeader(EnvRefraction,Env Refract Rotate)]
		[GroupVectorSlider(EnvRefraction,Axis Speed,m10_10,,float)]_EnvRefractRotateInfo("_EnvRefractRotateInfo",vector) = (0,1,0,0) // (axis, speed)
		[GroupToggle(EnvRefraction)]_EnvRefractRotateAutoStop("_EnvRefractRotateAutoStop",float) = 0

		[GroupHeader(EnvRefraction,Mode)]
		[GroupEnum(EnvRefraction,Refract InteriorMap,0 1)]_RefractMode("_RefractMode",int) = 0
// ==================================================	Env params
		[GroupHeader(,EnvOptions)]
		[GroupItem()][NoScaleOffset]_EnvMap("Env Map",Cube) = ""{}

		[Group(EnvOptions)]
		[GroupItem(EnvOptions)]_EnvIntensity("Env intensity",float) = 1
		[GroupVectorSlider(EnvOptions,X Y Z,m1_1 m1_1 m1_1,,float)]_EnvOffset("EnvOffset",vector) = (0,0,0,0)

		[GroupHeader(EnvOptions,Env Mask)]
		[GroupToggle(EnvOptions)]_EnvMaskUseMainTexMask("_EnvMaskUseMainTexMask",int)=3
		[GroupEnum(EnvOptions,R G B A,0 1 2 3)]_EnvMapMaskChannel("_EnvMapMaskChannel",int)=0

// ==================================================MatCap
		[Header(MatCap)]
		[GroupToggle(_,MATCAP_ON)]_MatCapOn("_MatCapOn",int) = 0
		[noscaleoffset]_MatCapTex("_MapCapTex",2d)=""{}
		[hdr]_MatCapColor("_MatCapColor",color) = (1,1,1,1)
		_MatCapIntensity("_MatCapIntensity",float) = 1

		[Header(Matcap UV Rotate)]
		[GroupToggle(_)]_MatCapRotateOn("_MatCapRotateOn",float) = 0
		_MatCapAngle("_MapCatAngle",float) = 0
// ==================================================_DepthFading
		[Header(_DepthFading)]
		[GroupToggle(_,DEPTH_FADING_ON)]_DepthFadingOn("_DepthFadingOn",int) = 0
		_DepthFadingWidth("_DepthFadingWidth",range(0.01,3)) = 0.33
		_DepthFadingMax("_DepthFadingMax",range(0.01,3)) = 1

// ================================================== Light
		[Header(Light)]
		[GroupToggle(_,PBR_LIGHTING)]_PbrLightOn("_PbrLightOn",int) = 0
		[NoScaleOffset]_NormalMap("_NormalMap",2d)="bump"{}
		_NormalMapScale("_NormalMapScale",range(0,5)) = 1
		_PbrMask("_PbrMask(Metal,Smooth,Occ)",2d)="white"{}
		_Metallic("_Metallic",range(0,1))=0.5
		_Smoothness("_Smoothness",range(0,1))=0.5
		_Occlusion("_Occlusion",range(0,1)) = 0

		[Header(Shadow)]
		[GroupToggle(_,MAIN_LIGHT_CALCULATE_SHADOWS)]_ReceiveShadowOn("_ReceiveShadowOn",int) = 0
		[GroupToggle(_,_SHADOWS_SOFT)]_ShadowsSoft("_ShadowsSoft",int) = 0 
		_MainLightSoftShadowScale("_MainLightSoftShadowScale",range(0,1))=0

		// [GroupHeader(Shadow,custom bias)]
        // [GroupSlider(Shadow)]_CustomShadowNormalBias("_CustomShadowNormalBias",range(-1,1)) = 0.5
        // [GroupSlider(Shadow)]_CustomShadowDepthBias("_CustomShadowDepthBias",range(-1,1)) = 0.5

		[Header(Additional Lights)]
		[GroupToggle(_,_ADDITIONAL_LIGHTS)]_AdditionalLightOn("_AdditionalLightOn",int)=0
		[GroupToggle(_,_ADDITIONAL_LIGHT_SHADOWS)]_AdditionalLightShadowsOn("_AdditionalLightShadowsOn",int)=0
		[GroupToggle(_,_ADDITIONAL_LIGHT_SHADOWS_SOFT)]_AdditionalLightShadowsSoftOn("_AdditionalLightShadowsSoftOn",int)=0
		_AdditionalLightSoftShadowScale("_AdditionalLightSoftShadowScale",range(1,10)) = 1
// ================================================== Glitch
		[GroupToggle(_,_GLITCH_ON)]_GlitchOn("_GlitchOn",int) = 0
        _HorizontalIntensity("_HorizontalIntensity",range(0,1)) = 0.2
		
		[Header(Snow)]
        _SnowFlakeIntensity("_SnowFlakeIntensity",range(0,9)) = 0.1
		
		[Header(Jitter)]
        _JitterBlockSize("_JitterBlockSize",range(0,3)) = 0.1
        _JitterIntensity("_JitterIntensity",range(0,1)) = 0.1

		[Header(VerticalJump)]
        _VerticalJumpIntensity("_VerticalJumpIntensity",range(0,1)) = 0.1
		[Header(HorizontalShake)]
        _HorizontalShake("_HorizontalShake",range(0,10)) = 0.1
        [Header(ColorDrift)]
        _ColorDriftSpeed("_ColorDriftSpeed",range(0,1000)) = 1
        _ColorDriftIntensity("_ColorDriftIntensity",range(0,1)) = 0.1

// ================================================== stencil settings
		[Group(Stencil)]
		[GroupEnum(Stencil,UnityEngine.Rendering.CompareFunction)]_StencilComp ("Stencil Comparison", Float) = 0
        [GroupItem(Stencil)]_Stencil ("Stencil ID", int) = 0
        [GroupEnum(Stencil,UnityEngine.Rendering.StencilOp)]_StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

// ================================================== fog
        [Header(Fog)]
        [GroupToggle(_,FOG_LINEAR)]_FogOn("_FogOn",int) = 0
        // [GroupToggle(_,_DEPTH_FOG_NOISE_ON)]_FogNoiseOn("_FogNoiseOn",int) = 0
        [GroupToggle(_)]_DepthFogOn("_DepthFogOn",int) = 1
        [GroupToggle(_)]_HeightFogOn("_HeightFogOn",int) = 1
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}
		Pass
		{
			name "PowerVFX"
			ZWrite[_ZWriteMode]
			Blend [_SrcMode][_DstMode]
			// BlendOp[_BlendOp]
			Cull[_CullMode]
			ztest[_ZTestMode]
			ColorMask [_ColorMask]
			

			HLSLPROGRAM
            #pragma multi_compile_instancing
            #pragma instancing_options forcemaxcount:40
            // -------------------------------------
            // Material Keywords
			#pragma shader_feature_local  PBR_LIGHTING
			// #pragma shader_feature_local _RECEIVE_SHADOWS_ON

			#pragma shader_feature_local_vertex  VERTEX_WAVE_ON
			#pragma shader_feature_local_fragment  FRESNEL_ON
			#pragma shader_feature_local_fragment  ALPHA_TEST
			#pragma shader_feature_local_fragment  DISTORTION_ON
			#pragma shader_feature_local_fragment  DISSOLVE_ON
			#pragma shader_feature_local_fragment  OFFSET_ON

			// #pragma shader_feature_local  ENV_REFLECT_ON
			// #pragma shader_feature_local  ENV_REFRACTION_ON
			#pragma shader_feature_local_fragment  MATCAP_ON
			#pragma shader_feature_local_fragment  DEPTH_FADING_ON
			// #pragma shader_feature_local_fragment  DOUBLE_EFFECT_ON // low frequency
			#pragma shader_feature_local MIN_VERSION
			#pragma shader_feature_local _GLITCH_ON

			// -------------------------------------
            // Universal Pipeline keywords
            #pragma shader_feature_local MAIN_LIGHT_CALCULATE_SHADOWS // _MAIN_LIGHT_SHADOWS //_MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN

			/**
			 	if object not show, 
					can comment  _ADDITIONAL_LIGHTS _ADDITIONAL_LIGHT_SHADOWS
					change shader_feature to multi_compile
			*/

            #pragma shader_feature_local _ADDITIONAL_LIGHTS //_ADDITIONAL_LIGHTS_VERTEX
            // #pragma shader_feature_local_fragment _ADDITIONAL_LIGHT_SHADOWS  //low frequency
			// #pragma shader_feature_local_fragment _ADDITIONAL_LIGHT_SHADOWS_SOFT // low frequency

            // #pragma multi_compile _ _REFLECTION_PROBE_BLENDING
            // #pragma multi_compile _ _REFLECTION_PROBE_BOX_PROJECTION
            // #pragma shader_feature_local_fragment _ _SHADOWS_SOFT

            // -------------------------------------
            // Unity defined keywords
            // #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            // #pragma multi_compile _ SHADOWS_SHADOWMASK
            // #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            // #pragma multi_compile _ LIGHTMAP_ON
            // #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            // #pragma multi_compile_fog
			#pragma multi_compile_local FOG_LINEAR
            // #pragma multi_compile _ DEBUG_DISPLAY
			
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "Lib/PowerVFXPassVersion.hlsl"

			ENDHLSL
		}
		
		Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite [_ZWriteMode]
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment ALPHA_TEST

			#include "../../PowerShaderLib/Lib/UnityLib.hlsl"
			#include "Lib/PowerVFXInput.hlsl"
			#define USE_SAMPLER2D
			#include "../../PowerShaderLib/UrpLib/ShadowCasterPass.hlsl"

            ENDHLSL
        }
		Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite [_ZWriteMode]
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW			
            // Material Keywords
            #pragma shader_feature_local_fragment ALPHA_TEST

			#include "../../PowerShaderLib/Lib/UnityLib.hlsl"
			#include "Lib/PowerVFXInput.hlsl"
			#define SHADOW_PASS
			#define USE_SAMPLER2D
			#define _MainTex _DissolveTex

			#undef _MainTexChannel
			#define _MainTexChannel _DissolveTexChannel
			#include "../../PowerShaderLib/UrpLib/ShadowCasterPass.hlsl"

            ENDHLSL
        }
	}

	CustomEditor "PowerUtilities.PowerVFXInspector"
}