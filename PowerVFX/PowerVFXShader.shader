/**
	Control PowerVFX's ShaderLod
		shader.maxmiumLOD = ?

	LOD 100
		standard version, full features
	LOD 80
		simple version, parts features
		define SIMPLE_VERSION
		disabled features:

		1 _UVCircleDist2
		2 _PerChannelColorOn
		3 GetDistortionMask
	LOD 50
		min version, little features

*/

Shader "FX/PowerVFX"
{
	Properties
	{
		[Group(MainTex Options)]
		[GroupHeader(MainTex Options,MainTex)]
		[GroupItem(MainTex Options)] _MainTex("Main Texture", 2D) = "white" {}
		[GroupItem(MainTex Options)] _MainUVAngle("_MainUVAngle",float) = 0
		[GroupToggle(MainTex Options)]_MainTexOffsetStop("_MainTexOffsetStop",int)=0

		[GroupHeader(MainTex Options,MainTex Custom Data)]
		[GroupToggle(MainTex Options)]_MainTexOffset_CustomData_On("_MainTexOffset_CustomData_On",int)=0

		[DisableGroup(_MainTexOffset_CustomData_On)]
		[GroupEnum(MainTex Options,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_MainTexOffset_CustomData_X("_MainTexOffset_CustomData_X",int) = 0
		[DisableGroup(_MainTexOffset_CustomData_On)]
		[GroupEnum(MainTex Options,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_MainTexOffset_CustomData_Y("_MainTexOffset_CustomData_Y",int) = 1

		[GroupHeader(MainTex Options,Saturate)]
		[GroupItem(MainTex Options)]_MainTexSaturate("_MainTexSaturate",float) = 1
		
		[GroupHeader(MainTex Options,Single Channel MainTex)]
		[GroupToggle(MainTex Options)]_MainTexSingleChannelOn("_MainTexSingleChannelOn?",int) = 0

		[DisableGroup(_MainTexSingleChannelOn)]
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

		[DisableGroup(_VertexColorChannelOn)]
		[GroupEnum(MainColorOptions,R 0 G 1 B 2 A 3)]_VertexColorChannel("_VertexColorChannel",int) = 0

		// mainTex channel
		[GroupHeader(MainColorOptions,Per Channel Color)]
		[GroupToggle(MainColorOptions)]_PerChannelColorOn("_PerChannelColorOn",float) = 0
		[DisableGroup(_PerChannelColorOn)]
		[GroupItem(MainColorOptions)][HDR]_ColorX("Color_X",Color) = (1,1,1,1)
		[DisableGroup(_PerChannelColorOn)]
		[GroupItem(MainColorOptions)][HDR]_ColorY("Color_Y",Color) = (1,1,1,1)
		[DisableGroup(_PerChannelColorOn)]
		[GroupItem(MainColorOptions)][HDR]_ColorZ("Color_Z",Color) = (1,1,1,1)

		// back face
		[Group(Back Face)]
		[GroupToggle(Back Face)]_BackFaceOn("_BackFaceOn",int) = 0
		[DisableGroup(_BackFaceOn)]
		[GroupItem(Back Face)][HDR]_BackFaceColor("BackFace Color",Color) = (0.5,0.5,.5,1)

		[Space(2)]
		[Group(MainTex Mask Options)]
		[GroupHeader(MainTex Mask Options,MainTex Mask)]
		[GroupItem(MainTex Mask Options,Mask)] _MainTexMask("Main Texture Mask(R)", 2D) = "white" {}
		[GroupToggle(MainTex Mask Options)]_MainTexMaskOffsetStop("_MainTexMaskOffsetStop",int)=0
		[GroupEnum(MainTex Mask Options,R 0 G 1 B 2 A 3)]_MainTexMaskChannel("_MainTexMaskChannel",int) = 0

		[GroupHeader(MainTex Mask Options,MainTexMask Custom Data)]
		[GroupToggle(MainTex Mask Options)]_MainTexMaskOffsetCustomDataOn("_MainTexMaskOffsetCustomDataOn",int)=0
		
		[DisableGroup(_MainTexMaskOffsetCustomDataOn)]
		[GroupEnum(MainTex Mask Options,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_MainTexMaskOffsetCustomDataX("_MainTexMaskOffsetCustomDataX",int) = 6
		[DisableGroup(_MainTexMaskOffsetCustomDataOn)]
		[GroupEnum(MainTex Mask Options,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_MainTexMaskOffsetCustomDataY("_MainTexMaskOffsetCustomDataY",int) = 7

		[Space(2)]
		[Group(ScreenTextures)]
		[GroupHeader(ScreenTextures,ScreenTexture)]
		[GroupToggle(ScreenTextures,)]_MainTexUseScreenColor("_MainTexUseScreenColor",int) = 0
		[GroupToggle(ScreenTextures)]_MainTexUseScreenUV("_MainTexUseScreenUV",int) = 0
		[GroupToggle(ScreenTextures)]_FullScreenMode("_FullScreenMode",int) = 0

		[Space(2)]
		[Group(SheetAnimation)]
		[GroupVectorSlider(SheetAnimation,RowCount ColumnCount,1_16 1_16,,int)]_MainTexSheet("_MainTexSheet",vector)=(1,1,1,1)
		[GroupItem(SheetAnimation)]_MainTexSheetAnimSpeed("_MainTexSheetAnimSpeed",float) = 1
		[GroupToggle(SheetAnimation)]_MainTexSheetAnimBlendOn("_MainTexSheetAnimBlendOn",int) = 0 //SHEET_ANIM_BLEND_ON

		[Space(2)]
		[Group(Sprite)]
		[GroupVectorSlider(Sprite,x y z,0_1 0_1 0_1,,field)]_SpriteUVStart("_SpriteUVStart",vector) = (0,0,0,0)
		// [GroupToggle(_)]_MainTexSheetPlayOnce("_MainTexSheetPlayOnce",int) = 0
// ==================================================		Alpha
		[Header(Alpha Range)]
		_AlphaMin("_AlphaMin",range(0,1)) = 0
		_AlphaMax("_AlphaMax",range(0,1)) = 1

		[Header(Alpha Scale)]
		_AlphaScale("_AlphaScale",float) = 1
		
		[Header(Alpha Channel)]
		[GroupEnum(,R 0 G 1 B 2 A 3)] _OverrideAlphaChannel("_OverrideAlphaChannel",float) = 3
// ================================================== States Settings
		[Header(BlendMode)]
		[Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("Src Mode",int) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_DstMode("Dst Mode",int) = 10
		// [Header(BlendOp)]
		// [Enum(UnityEngine.Rendering.BlendOp)]_BlendOp("_BlendOp",int) = 0

		[Header(DoubleEffect)]
		[GroupToggle(_,DOUBLE_EFFECT_ON)]_DoubleEffectOn("双重效果?",int)=0
		
		[Header(CullMode)]
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode",float) = 2
		[GroupToggle]_ZWriteMode("ZWriteMode",int) = 0
		/*
		Disabled,Never,Less,Equal,LessEqual,Greater,NotEqual,GreaterEqual,Always
		*/
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",float) = 4

		[Header(Color Mask)]
		[GroupEnum(_,RGBA 16 RGB 15 RG 12 GB 6 RB 10 R 8 G 4 B 2 A 1 None 0)]
		_ColorMask("_ColorMask",int) = 15

// ==================================================_VertexWaveOn
		[Header(VertexWave)]
		[GroupToggle(_)]_VertexWaveOn("_VertexWaveOn",int) = 0
		[GroupHeader(Noise From Map)]
		[GroupToggle]_NoiseUseAttenMaskMap("_NoiseUseAttenMaskMap",float)=0
		
		[Header(Noise From Params)]
		_VertexWaveSpeed("_VertexWaveSpeed",float) = 1
		[GroupToggle]_VertexWaveSpeedManual("_VertexWaveSpeedManual",int) = 0
		_VertexWaveIntensity("_VertexWaveIntensity",float) = 1
		
		[Header(VertexWaveIntensity CustomDataOn)]
		[GroupToggle]_VertexWaveIntensityCustomDataOn("_VertexWaveIntensityCustomDataOn",int) = 0
		[DisableGroup(_VertexWaveIntensityCustomDataOn)]
		[GroupEnum(_,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_VertexWaveIntensityCustomData("_VertexWaveIntensityCustomData",int) = 7

		[GroupHeader(VertexColor Atten)]
		[GroupToggle]_VertexWaveAtten_VertexColor("_VertexWaveAtten_VertexColor(rgb)",float) = 0

		[GroupHeader(VertexWave Direction)]
		[GroupVectorSlider(,dir len,0_1,_VertexWaveDir and atten,field)]_VertexWaveDirAtten("_VertexWaveDirAtten(xyz:dir,w:len)",vector) = (1,1,1,1)

		[Header(VertexWaveDir CustomData)]
		[GroupToggle]_VertexWaveDirAttenCustomDataOn("_VertexWaveDirAttenCustomDataOn",int) = 0
		[DisableGroup(_VertexWaveDirAttenCustomDataOn)]
		[GroupEnum(_,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_VertexWaveDirAttenCustomData("_VertexWaveDirAttenCustomData",int) = 0

		[GroupHeader(Atten Options)]
		[GroupToggle]_VertexWaveDirAlongNormalOn("_VertexWaveDirAlongNormalOn?",int) = 0
		[GroupToggle]_VertexWaveDirAtten_LocalSpaceOn("_VertexWaveDirAtten_LocalSpaceOn",int) = 0
		[GroupToggle]_VertexWaveAtten_NormalAttenOn("_VertexWaveAtten_NormalAttenOn",float) = 0

		[GroupHeader(VertexWave Dist Atten)]
		[gamma]_UVCircleDist2("_UVCircleDist2",range(0,2)) = 0

		[GroupHeader(VertexWava Atten Map)]
		[GroupToggle]_VertexWaveAtten_MaskMapOn("_VertexWaveAtten_MaskMapOn",int) = 0
		_VertexWaveAtten_MaskMap("_VertexWaveAtten_MaskMap",2d) = "white"{}
		[Enum(R,0,G,1,B,2,A,3)]_VertexWaveAtten_MaskMapChannel("_VertexWaveAtten_MaskMapChannel",int) = 0
		[GroupToggle]_VertexWaveAtten_MaskMapOffsetStopOn("_VertexWaveAtten_MaskMapOffsetStopOn",int) = 0

		[Header(VertexWaveAttenMaskOffset Custom Data)]
		[GroupToggle]_VertexWaveAttenMaskOffsetCustomDataOn("_VertexWaveAttenMaskOffsetCustomDataOn",int) = 0
		[DisableGroup(_VertexWaveAttenMaskOffsetCustomDataOn)]
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
		[DisableGroup(_DistortionCustomDataOn)]
		[GroupEnum(_,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_DistortionCustomData("_DistortionCustomData",int) = 5

		[Header(DistortionParams)]
		_DistortTile("Distort Tile",vector) = (1,1,1,1)
		_DistortDir("Distort Dir",vector) = (0,1,0,-1)

		[Group(RadialUV)]
		[GroupHeader(RadialUV,RadialUV)]
		[GroupToggle(RadialUV)]_DistortionRadialUVOn("_DistortionRadialUVOn",int) = 0
		
		[DisableGroup(_DistortionRadialUVOn)]
		[GroupVectorSlider(RadialUV,CenterX CenterY ScaleX ScaleY,0_1 0_1 0_1 0_1,,float float field field)]_DistortionRadialCenter_Scale("_DistortionRadialCenter_Scale",vector) = (.5,.5,1,1)
		
		[DisableGroup(_DistortionRadialUVOn)]
		[GroupItem(RadialUV)]_DistortionRadialRot("_DistortionRadialRot",float) = 0

		[DisableGroup(_DistortionRadialUVOn)]
		[GroupItem(RadialUV)]_DistortionRadialUVOffset("_DistortionRadialUVOffset",float) = 0

		[Group(DistortionWhere)]
		[GroupToggle(DistortionWhere)]_DistortionApplyToMainTex("_DistortionApplyToMainTex",int) = 1
		[GroupToggle(DistortionWhere)]_DistortionApplyToOffset("_DistortionApplyToOffset",int) = 0
		[GroupToggle(DistortionWhere)]_DistortionApplyToMainTexMask("_DistortionApplyToMainTexMask",int) = 0
		[GroupToggle(DistortionWhere)]_DistortionApplyToDissolve("_DistortionApplyToDissolve",int) = 0
// ==================================================Dissolve
		[Header(Dissolve)]
		[GroupToggle(_,DISSOLVE_ON)]_DissolveOn("Dissolve On?",int)=0

		[GroupHeader(,DissolveType)]
		[GroupToggle(,)]_DissolveByVertexColor("Dissolve By Vertex Color ?",int)=0

		[Header(DissolveTexture)]
		_DissolveTex("Dissolve Tex",2d)=""{}
		[GroupToggle]_DissolveTexOffsetStop("_DissolveTexOffsetStop ?",int) = 0
		[Enum(R,0,G,1,B,2,A,3)]_DissolveTexChannel("_DissolveTexChannel",int) = 0
		[GroupEnum(,UV 0 UV1 1)]_DissolveUVType("_DissolveUVType",int) = 0


		[Header(DissolveMask)]
		[GroupToggle]_DissolveMaskFromTexOn("_DissolveMaskFromTexOn",int) = 0
		
		[DisableGroup(_DissolveMaskFromTexOn)]
		[GroupToggle]_DissolveMaskResampleOn("_DissolveMaskResampleOn",int) = 0

		[DisableGroup(_DissolveMaskResampleOn)]
		[GroupItem()]_DissolveMask_ST("_DissolveMask_ST",vector) = (1,1,0,0)
		[DisableGroup(_DissolveMaskFromTexOn)]
		[GroupEnum(,R 0 G 1 B 2 A 3)]_DissolveMaskChannel("_DissolveMaskChannel",int)=3
		

		[Header(Dissolve Custom Data)]
		[GroupToggle]_DissolveCustomDataOn("Dissolve By customData.z -> uv1.x ?",int)=0
		//default custom1.z
		[DisableGroup(_DissolveCustomDataOn)]
		[GroupEnum(_,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_DissolveCustomData("_DissolveCustomData",int) = 2

		[Header(DissolveFading)]
		_DissolveFadingMin("_DissolveFadingMin",range(0,1)) = 0
		_DissolveFadingMax("_DissolveFadingMax",range(0,1)) = .2

		[Header(Dissolve Clip)]
		[DisableGroup(_DissolveOn)]
		[GroupToggle(,ALPHA_TEST)]_DissolveClipOn("_DissolveClipOn",int) = 0

		[Header(Dissolve Progress)]
		// [DisableGroup(_DissolveClipOn)]
		[GroupItem]_Cutoff ("_Cutoff", Range(0,1)) = 0.5

		[Header(PixelDissolve)]
		[GroupToggle]_PixelDissolveOn("_PixelDissolveOn",float) = 0
		[DisableGroup(_PixelDissolveOn)]
		[GroupItem]_PixelWidth("_PixelWidth",float) = 10

// ================================================== dissolve edge
		[Group(DissolveEdge)]
		[GroupHeader(DissolveEdge,Dissolve Edge)]
		[GroupToggle(DissolveEdge)]_DissolveEdgeOn("Dissolve Edge On?",int)=0
		[DisableGroup(_DissolveEdgeOn)]
		[GroupItem(DissolveEdge)]_EdgeWidth("EdgeWidth",range(0,1)) = 0.1

		[GroupHeader(DissolveEdge, Custom Data)]
		[DisableGroup(_DissolveEdgeOn)]
		[GroupToggle(DissolveEdge)]_DissolveEdgeWidthCustomDataOn("_DissolveEdgeWidthCustomDataOn.w -> uv1.y",int) = 0
		//default custom1.w
		[DisableGroup(_DissolveEdgeWidthCustomDataOn)]
		[GroupEnum(DissolveEdge,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_DissolveEdgeWidthCustomData("_DissolveEdgeWidthCustomData",int) = 3

		[DisableGroup(_DissolveEdgeOn)]
		[GroupItem(DissolveEdge)][HDR]_EdgeColor("EdgeColor",color) = (1,0,0,1)

		[DisableGroup(_DissolveEdgeOn)]
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

		[DisableGroup(_OffsetCustomDataOn)]
		[GroupEnum(_,c1_x 0 c1_y 1 c1_z 2 c1_w 3 c2_x 4 c2_y 5 c2_z 6 c2_w 7)]_OffsetLayer1_CustomData_X("_OffsetLayer1_CustomData_X",int) = 0

		[DisableGroup(_OffsetCustomDataOn)]
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

		[GroupToggle()]_OffsetMaskApplyMainTexAlpha("_OffsetMaskApplyMainTexAlpha",int) = 0
		//==================================== offset polar
		[Group(OffsetRadial)]
		[GroupHeader(OffsetRadial,Radial UV)]
		[GroupToggle(OffsetRadial)]_OffsetRadialUVOn("_OffsetRadialUVOn",int) = 0

		[DisableGroup(_OffsetRadialUVOn)]
		[GroupVectorSlider(OffsetRadial,CenterX CenterY ScaleX ScaleY,0_1 0_1 0_1 0_1,,float float field field)]_OffsetRadialCenter_Scale("_OffsetRadialCenter_Scale",vector) = (.5,.5,1,1)

		[DisableGroup(_OffsetRadialUVOn)]
		[GroupItem(OffsetRadial)]_OffsetRadialRot("_OffsetRadialRot",float) = 0

		[DisableGroup(_OffsetRadialUVOn)]
		[GroupItem(OffsetRadial)]_OffsetRadialUVOffset("_OffsetRadialUVOffset",float) = 0
// ==================================================Fresnal
		[Header(Fresnal)]
		[GroupToggle(_,)]_FresnelOn("_FresnelOn?",int)=0 //FRESNEL_ON
		[Enum(Replace,0,Multiply,1)]_FresnelColorMode("_FresnelColorMode",int) = 0
		[HDR]_FresnelColor("_FresnelColor",color) = (1,1,1,1)
		[HDR]_FresnelColor2("_FresnelColor2",color) = (1,1,1,1)
		[Header(FresnelRange)]
		_FresnelPowerMin("_FresnelPowerMin",range(0,1)) = 0.4
		_FresnelPowerMax("_FresnelPowerMax",range(0,1)) = 0.5
		[Header(FresnelAlpha)]
		_FresnelAlphaBase("_FresnelAlphaBase",range(0,1)) = 0
		[Header(BlendScreenColor)]
		_BlendScreenColor("_BlendScreenColor",range(0,1)) = 0
// ==================================================	EnvReflection
		[GroupHeader(,Reflect)]
		[GroupToggle(,ENV_REFLECT_ON)]_EnvReflectOn("EnvReflect On?",int)=0

		[Group(EnvReflection)]
		[DisableGroup(_EnvReflectOn)]
		[GroupItem(EnvReflection)][hdr]_EnvReflectionColor("_EnvReflectionColor",color) = (.5,.5,.5,.5)

		[GroupHeader(EnvReflection,Env Rotate)]
		[DisableGroup(_EnvReflectOn)]
		[GroupVectorSlider(EnvReflection,Axis Speed,m10_10,,float)]_EnvRotateInfo("_EnvRotateInfo",vector) = (0,1,0,0) // (axis, speed)

		[DisableGroup(_EnvReflectOn)]
		[GroupToggle(EnvReflection)]_EnvRotateAutoStop("_EnvRotateAutoStop",float) = 0
		
// ==================================================	EnvRefraction		
		[GroupHeader(,Refraction)]
		[GroupToggle(,ENV_REFRACTION_ON)]_EnvRefractionOn("_EnvRefractionOn",int) = 0

		[Group(EnvRefraction)]
		[DisableGroup(_EnvRefractionOn)]
		[GroupItem(EnvRefraction)]_EnvRefractionIOR("_EnvRefractionIOR",range(1,5)) = 1.33

		[DisableGroup(_EnvRefractionOn)]
		[GroupItem(EnvRefraction)][hdr]_EnvRefractionColor("_EnvRefractionColor",color) = (.5,.5,.5,.5)

		[GroupHeader(EnvRefraction,Env Refract Rotate)]
		[DisableGroup(_EnvRefractionOn)]
		[GroupVectorSlider(EnvRefraction,Axis Speed,m10_10,,float)]_EnvRefractRotateInfo("_EnvRefractRotateInfo",vector) = (0,1,0,0) // (axis, speed)

		[DisableGroup(_EnvRefractionOn)]
		[GroupToggle(EnvRefraction)]_EnvRefractRotateAutoStop("_EnvRefractRotateAutoStop",float) = 0

		[GroupHeader(EnvRefraction,Mode)]
		[DisableGroup(_EnvRefractionOn)]
		[GroupEnum(EnvRefraction,Refract InteriorMap,0 1)]_RefractMode("_RefractMode",int) = 0
// ==================================================	Env params
		[GroupHeader(,EnvOptions)]
		[GroupItem()][NoScaleOffset]_EnvMap("Env Map",Cube) = ""{}

		[Group(EnvOptions)]
		[GroupItem(EnvOptions)]_EnvIntensity("Env intensity",float) = 1
		[GroupVectorSlider(EnvOptions,X Y Z,m1_1 m1_1 m1_1,,float)]_EnvOffset("EnvOffset",vector) = (0,0,0,0)

		[GroupHeader(EnvOptions,Env Mask)]
		[GroupToggle(EnvOptions)]_EnvMaskUseMainTexMask("_EnvMaskUseMainTexMask",int)=3

		[DisableGroup(_EnvMaskUseMainTexMask)]
		[GroupEnum(EnvOptions,R G B A,0 1 2 3)]_EnvMapMaskChannel("_EnvMapMaskChannel",int)=0

// ==================================================MatCap
		[Header(MatCap)]
		[GroupToggle(_,MATCAP_ON)]_MatCapOn("_MatCapOn",int) = 0

		[DisableGroup(_MatCapOn)]
		[GroupItem][noscaleoffset]_MatCapTex("_MapCapTex",2d)=""{}

		[DisableGroup(_MatCapOn)]
		[GroupItem][hdr]_MatCapColor("_MatCapColor",color) = (1,1,1,1)

		[DisableGroup(_MatCapOn)]
		[GroupItem]_MatCapIntensity("_MatCapIntensity",float) = 1

		[Header(Matcap UV Rotate)]
		[DisableGroup(_MatCapOn)]
		[GroupToggle()]_MatCapRotateOn("_MatCapRotateOn",float) = 0

		[DisableGroup(_MatCapRotateOn)]
		[GroupItem]_MatCapAngle("_MapCatAngle",float) = 0
// ==================================================_DepthFading
		[Group(DepthFading)]
		[GroupHeader(DepthFading,_DepthFading)]
		[GroupToggle(DepthFading,DEPTH_FADING_ON)]_DepthFadingOn("_DepthFadingOn",int) = 0

		[DisableGroup(_DepthFadingOn)]
		[GroupItem(DepthFading)] _DepthFadingWidth("_DepthFadingWidth",range(0.01,3)) = 0.33

		[DisableGroup(_DepthFadingOn)]
		[GroupItem(DepthFading)] _DepthFadingMax("_DepthFadingMax",range(0.01,3)) = 1

		[DisableGroup(_DepthFadingOn)]
		[GroupItem(DepthFading)][hdr] _DepthFadingColor("_DepthFadingColor",color) = (1,1,1,1)

// ================================================== Light
		[Header(Light)]
		[GroupToggle(,PBR_LIGHTING)]_PbrLightOn("_PbrLightOn",int) = 0

		[GroupHeader(,Surface Info)]
		[GroupToggle]_NormalMapOn("_NormalMapOn",float) = 0
		_NormalMap("_NormalMap",2d)="bump"{}
		_NormalMapScale("_NormalMapScale",range(0,5)) = 1
		_PbrMask("_PbrMask(Metal,Smooth,Occ)",2d)="white"{}
		_Metallic("_Metallic",range(0,1))=0.5
		_Smoothness("_Smoothness",range(0,1))=0.5
		_Occlusion("_Occlusion",range(0,1)) = 0
		
		[Group(Env)]
		[GroupHeader(Env,Custom Light)]
        [GroupToggle(Env)]_CustomLightOn("_CustomLightOn",float) = 0
        [GroupItem(Env)][LightInfo(Env,direction)]_CustomLightDir("_CustomLightDir",vector) = (0,1,0,0)
        [GroupItem(Env)][hdr][LightInfo(Env,Color)]_CustomLightColor("_CustomLightColor",color) = (0,0,0,0)
        [GroupEnum(Env,LightColor 0 SpecularColor 1)]_CustomLightColorUsage("_CustomLightColorUsage",int) = 0

		[GroupHeader(Env,Custom GI)]
		[GroupToggle(Env)]_GIDiffuseOn("_GIDiffuseOn",float)=0
		[GroupItem(Env)][hdr]_GIColorColor("_GIColorColor",color) = (0,0,0,0)

		[Header(Shadow)]
		[GroupToggle(_,MAIN_LIGHT_CALCULATE_SHADOWS)]_ReceiveShadowOn("_ReceiveShadowOn",int) = 0
		/**
			Disable match with keyword,uncomments keyword and this
		*/
		// [DisableGroup(_ReceiveShadowOn)]
		// [GroupToggle(_,_SHADOWS_SOFT)]_ShadowsSoft("_ShadowsSoft",int) = 0 

		[DisableGroup(_ReceiveShadowOn)]
		[GroupItem]_MainLightSoftShadowScale("_MainLightSoftShadowScale",range(0,1))=0

		// [GroupHeader(Shadow,custom bias)]
        // [GroupSlider(Shadow)]_CustomShadowNormalBias("_CustomShadowNormalBias",range(-1,1)) = 0.5
        // [GroupSlider(Shadow)]_CustomShadowDepthBias("_CustomShadowDepthBias",range(-1,1)) = 0.5

		[Header(Additional Lights)]
		[GroupToggle(_,_ADDITIONAL_LIGHTS)]_AdditionalLightOn("_AdditionalLightOn",int)=0
		/**
			Disable match with keyword,uncomments keyword and this
		*/
		// [DisableGroup(_AdditionalLightOn)]
		// [GroupToggle(_,_ADDITIONAL_LIGHT_SHADOWS)]_AdditionalLightShadowsOn("_AdditionalLightShadowsOn",int)=0
		// [DisableGroup(_AdditionalLightOn)]
		// [GroupToggle(_,_ADDITIONAL_LIGHT_SHADOWS_SOFT)]_AdditionalLightShadowsSoftOn("_AdditionalLightShadowsSoftOn",int)=0
		// [DisableGroup(_AdditionalLightShadowsSoftOn)]
		// [GroupItem]_AdditionalLightSoftShadowScale("_AdditionalLightSoftShadowScale",range(1,10)) = 1
// ================================================== Glitch
		[GroupToggle(_,_GLITCH_ON)]_GlitchOn("_GlitchOn",int) = 0
        _HorizontalIntensity("_HorizontalIntensity",range(0,1)) = 0.2
		
		[Header(Snow)]
        _SnowFlakeIntensity("_SnowFlakeIntensity",range(0,9)) = 0.1
		
		[Header(Jitter)]
		[GroupVectorSlider(,blockSize intensity horizontalIntensity verticalIntensity,0.0001_200 m0_1 m0_1 m0_1,)]
		_JitterInfo("_JitterInfo",vector) = (.1,.1,1,0)

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
        [GroupToggle(_,)]_FogOn("_FogOn",int) = 0	//FOG_LINEAR
        // [GroupToggle(_,_DEPTH_FOG_NOISE_ON)]_FogNoiseOn("_FogNoiseOn",int) = 0
        [GroupToggle(_)]_DepthFogOn("_DepthFogOn",int) = 1
        [GroupToggle(_)]_HeightFogOn("_HeightFogOn",int) = 1
//================================================= Parallax
        [Group(Parallax)]
        [GroupToggle(Parallax,_PARALLAX)]_ParallaxOn("_ParallaxOn",int) = 0
        [GroupSlider(Parallax,iterate count,int)]_ParallaxIterate("_ParallaxIterate",range(1,3)) = 1
        // [GroupToggle(Parallax,run in vertex shader)]_ParallaxInVSOn("_ParallaxInVSOn",int) = 0
        [noscaleoffset]
        [GroupItem(Parallax)]_ParallaxMap("_ParallaxMap",2d) = "white"{}
        [GroupEnum(Parallax,R 0 G 1 B 2 A 3)]_ParallaxMapChannel("_ParallaxMapChannel",int) = 3
        [GroupSlider(Parallax)]_ParallaxHeight("_ParallaxHeight",range(0.005,0.3)) = 0.01
		[GroupHeader(Parallax,Offset)]
		[GroupSlider(Parallax)]_ParallaxWeightOffset("_ParallaxWeightOffset",range(0,1)) = 0
//================================================= future function variables,dont use these when dont know
        // [HideInInpector]_Reserve0("_Reserve0",vector)=(0,0,0,0)

        // [HideInInpector]_ReserveTex0("_ReserveTex0",2d)="white"{}

		// [HideInInpector]_ReserveTexArr0("_ReserveTexArr0",2darray)="white"{}

		// [HideInInpector]_ReserveTex3D0("_ReserveTex3D0",3d)="white"{}

		// [HideInInpector]_ReserveTexCube0("_ReserveTexCube0",cube)="white"{}

		// [HideInInpector]_ReserveTexCubeArr0("_ReserveTexCubeArr0",cubearray)="white"{}

	}
	SubShader
	{
		LOD 100
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
			// --------- Enable UnityInstancing, uncomments two lines below
            // #pragma multi_compile_instancing
            // #pragma instancing_options forcemaxcount:40

            // -------------------------------------
            // Material Keywords
			#pragma shader_feature_local  PBR_LIGHTING
			// #pragma shader_feature_local _RECEIVE_SHADOWS_ON
			#define VERTEX_WAVE_ON
			// #pragma shader_feature_local_vertex  VERTEX_WAVE_ON
			#define FRESNEL_ON // #pragma shader_feature_local_fragment  FRESNEL_ON
			#pragma shader_feature_local_fragment  ALPHA_TEST
			#pragma shader_feature_local_fragment  DISTORTION_ON
			#pragma shader_feature_local_fragment  DISSOLVE_ON
			#pragma shader_feature_local_fragment  OFFSET_ON
			#pragma shader_feature_local_fragment  _PARALLAX
			

			#pragma shader_feature_local  ENV_REFLECT_ON
			#pragma shader_feature_local  ENV_REFRACTION_ON
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
			#define FOG_LINEAR //#pragma multi_compile_local FOG_LINEAR
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
			// --------- Enable UnityInstancing, uncomments two lines below
            // #pragma multi_compile_instancing
            // #pragma instancing_options forcemaxcount:40

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
			// --------- Enable UnityInstancing, uncomments two lines below
            // #pragma multi_compile_instancing
            // #pragma instancing_options forcemaxcount:40

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

	// ============= simple version
	SubShader
	{
		LOD 80
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
			// --------- Enable UnityInstancing, uncomments two lines below
            // #pragma multi_compile_instancing
            // #pragma instancing_options forcemaxcount:40

            // -------------------------------------
            // Material Keywords
			#pragma shader_feature_local  PBR_LIGHTING
			// #pragma shader_feature_local _RECEIVE_SHADOWS_ON
			#define VERTEX_WAVE_ON
			// #pragma shader_feature_local_vertex  VERTEX_WAVE_ON
			#define FRESNEL_ON // #pragma shader_feature_local_fragment  FRESNEL_ON
			#pragma shader_feature_local_fragment  ALPHA_TEST
			#pragma shader_feature_local_fragment  DISTORTION_ON
			#pragma shader_feature_local_fragment  DISSOLVE_ON
			#pragma shader_feature_local_fragment  OFFSET_ON
			#pragma shader_feature_local_fragment  _PARALLAX
			

			#pragma shader_feature_local  ENV_REFLECT_ON
			#pragma shader_feature_local  ENV_REFRACTION_ON
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
			#define FOG_LINEAR //#pragma multi_compile_local FOG_LINEAR
            // #pragma multi_compile _ DEBUG_DISPLAY
			
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			#define SIMPLE_VERSION
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
			// --------- Enable UnityInstancing, uncomments two lines below
            // #pragma multi_compile_instancing
            // #pragma instancing_options forcemaxcount:40

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
			// --------- Enable UnityInstancing, uncomments two lines below
            // #pragma multi_compile_instancing
            // #pragma instancing_options forcemaxcount:40

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


	SubShader
	{
		LOD 50 // MIN_VERSION
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
			// --------- Enable UnityInstancing, uncomments two lines below
            // #pragma multi_compile_instancing
            // #pragma instancing_options forcemaxcount:40

            // -------------------------------------
            // Material Keywords
			// #pragma shader_feature_local  PBR_LIGHTING
			// #pragma shader_feature_local _RECEIVE_SHADOWS_ON
			// #define VERTEX_WAVE_ON
			// #pragma shader_feature_local_vertex  VERTEX_WAVE_ON
			// #define FRESNEL_ON // #pragma shader_feature_local_fragment  FRESNEL_ON
			#pragma shader_feature_local_fragment  ALPHA_TEST
			#pragma shader_feature_local_fragment  DISTORTION_ON
			#pragma shader_feature_local_fragment  DISSOLVE_ON
			// #pragma shader_feature_local_fragment  OFFSET_ON
			// #pragma shader_feature_local_fragment  _PARALLAX
			

			// #pragma shader_feature_local  ENV_REFLECT_ON
			// #pragma shader_feature_local  ENV_REFRACTION_ON
			// #pragma shader_feature_local_fragment  MATCAP_ON
			// #pragma shader_feature_local_fragment  DEPTH_FADING_ON
			// #pragma shader_feature_local_fragment  DOUBLE_EFFECT_ON // low frequency

			// lod <=100, enable MIN_VERSION
			#define MIN_VERSION 
			// #pragma shader_feature_local MIN_VERSION
			// #pragma shader_feature_local _GLITCH_ON

			// -------------------------------------
            // Universal Pipeline keywords
            // #pragma shader_feature_local MAIN_LIGHT_CALCULATE_SHADOWS // _MAIN_LIGHT_SHADOWS //_MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN

			/**
			 	if object not show, 
					can comment  _ADDITIONAL_LIGHTS _ADDITIONAL_LIGHT_SHADOWS
					change shader_feature to multi_compile
			*/

            // #pragma shader_feature_local _ADDITIONAL_LIGHTS //_ADDITIONAL_LIGHTS_VERTEX
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
			#define FOG_LINEAR //#pragma multi_compile_local FOG_LINEAR
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
			// --------- Enable UnityInstancing, uncomments two lines below
            // #pragma multi_compile_instancing
            // #pragma instancing_options forcemaxcount:40

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
			// --------- Enable UnityInstancing, uncomments two lines below
            // #pragma multi_compile_instancing
            // #pragma instancing_options forcemaxcount:40

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
	CustomEditor "PowerUtilities.PowerShaderInspector"
}