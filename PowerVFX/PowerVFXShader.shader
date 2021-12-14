// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
Shader "FX/PowerVFX"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		[LiteToggle]_MainTexOffsetStop("禁用MainTex自动滚动?",int)=0
		[LiteToggle]_MainTexOffsetUseCustomData_XY("_MainTexOffsetUseCustomData_XY -> uv.zw",int)=0

		[Header(Saturate)]
		_MainTexSaturate("_MainTexSaturate",float) = 1
		[Header(Main Color)]
		[HDR]_Color("Main Color",Color) = (1,1,1,1)
		_ColorScale("ColorScale",range(1,3)) = 1
		[LiteToggle]_MainTexMultiAlpha("_MainTexMultiAlpha",int) = 0

		[Header(Alpha Range)]
		_AlphaMin("_AlphaMin",range(0,1)) = 0
		_AlphaMax("_AlphaMax",range(0,1)) = 1

		[Header(Single Channel MainTex)]
		[LiteToggle]_MainTexSingleChannelOn("_MainTexSingleChannelOn?",int) = 0
		[Enum(R,0,G,1,B,2,A,3)]_MainTexChannel("_MainTexChannel",int)=0

		[Header(Back Face)]
		[LiteToggle]_BackFaceOn("_BackFaceOn",int) = 0
		[HDR]_BackFaceColor("BackFace Color",Color) = (0.5,0.5,.5,1)

		[Header(MaskTexMask)]
		_MainTexMask("Main Texture Mask(R)", 2D) = "white" {}
		[LiteToggle]_MainTexMaskOffsetStop("_MainTexMaskOffsetStop",int)=0
		[Enum(R,0,G,1,B,2,A,3)]_MainTexMaskChannel("_MainTexMaskChannel",int) = 0

		[Header(ScreenOpaqueTexture)]
		[LiteToggle]_MainTexUseScreenColor("_MainTexUseScreenColor",int) = 0
// ==================================================
		[Header(BlendMode)]
		[Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("Src Mode",int) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_DstMode("Dst Mode",int) = 10
		// [Header(BlendOp)]
		// [Enum(UnityEngine.Rendering.BlendOp)]_BlendOp("_BlendOp",int) = 0

		[Header(DoubleEffect)]
		[LiteToggle]_DoubleEffectOn("双重效果?",int)=0
		
		[Header(CullMode)]
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode",float) = 0
		[LiteToggle]_ZWriteMode("ZWriteMode",int) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",float) = 4
// ==================================================
		[LiteToggle]_VertexWaveOn("_VertexWaveOn ?",int) = 0
		[Header(Noise Map)]
		[LiteToggle]_NoiseUseAttenMaskMap("_NoiseUseAttenMaskMap",float)=0
		[Header(Noise Params)]
		_VertexWaveSpeed("_VertexWaveSpeed",float) = 1
		[LiteToggle]_VertexWaveSpeedManual("_VertexWaveSpeedManual",int) = 0
		_VertexWaveIntensity("_VertexWaveIntensity",float) = 1
		[Header(Vertex Color Atten)]
		[LiteToggle]_VertexWaveAtten_VertexColor("_VertexWaveAtten_VertexColor(rgb)",float) = 0
		[Header(Vertex Wave Direction)]
		_VertexWaveDirAtten("_VertexWaveDirAtten(xyz:dir,w:len)",vector) = (1,1,1,1)
		[LiteToggle]_VertexWaveDirAlongNormalOn("_VertexWaveDirAlongNormalOn?",int) = 0
		[LiteToggle]_VertexWaveDirAtten_LocalSpaceOn("_VertexWaveDirAtten_LocalSpaceOn",int) = 0
		[LiteToggle]_VertexWaveAtten_NormalAttenOn("_VertexWaveAtten_NormalAttenOn",float) = 0

		[Header(Vertex Wava Atten Map)]
		[LiteToggle]_VertexWaveAtten_MaskMapOn("_VertexWaveAtten_MaskMapOn",int) = 0
		_VertexWaveAtten_MaskMap("_VertexWaveAtten_MaskMap",2d) = "white"{}
		[Enum(R,0,G,1,B,2,A,3)]_VertexWaveAtten_MaskMapChannel("_VertexWaveAtten_MaskMapChannel",int) = 0
		[LiteToggle]_VertexWaveAtten_MaskMapOffsetStopOn("_VertexWaveAtten_MaskMapOffsetStopOn",int) = 0
		[LiteToggle]_VertexWaveAttenMaskOffsetScale_UseCustomeData2_X("_VertexWaveAttenMaskOffsetScale_UseCustomeData2_X",int) = 0
// ==================================================
		[Header(Distortion)]
		[LiteToggle]_DistortionOn("Distortion On?",int)=0
		[noscaleoffset]_DistortionNoiseTex("Noise Texture(xy:layer1,zw:layer2)",2D) = "white" {}
		
		[Header(DistortionMask)]
		_DistortionMaskTex("Distortion Mask Tex(R)",2d) = "white"{}
		[Enum(R,0,G,1,B,2,A,3)]_DistortionMaskChannel("_DistortionMaskChannel",int)=0

		[Header(DistortionParams)]
		_DistortionIntensity("Distortion Intensity",Range(0,2)) = 0.5
		_DistortTile("Distort Tile",vector) = (1,1,1,1)
		_DistortDir("Distort Dir",vector) = (0,1,0,-1)

		[Header(Radial UV)]
		[LiteToggle]_DistortionRadialUVOn("_DistortionRadialUVOn",int) = 0
		_DistortionRadialCenter_LenScale_LenOffset("_DistortionRadialCenter_LenScale_LenOffset",vector) = (.5,.5,1,0)
		_DistortionRadialRot("_DistortionRadialRot",float) = 0

		[Header(Distortion Where)]
		[LiteToggle]_ApplyToOffset("_ApplyToOffset",int) = 0
// ==================================================
		[Header(Dissolve)]
		[LiteToggle]_DissolveOn("Dissolve On?",int)=0
		_DissolveTex("Dissolve Tex",2d)=""{}
		[LiteToggle]_DissolveTexOffsetStop("_DissolveTexOffsetStop ?",int) = 0
		[Enum(R,0,G,1,B,2,A,3)]_DissolveTexChannel("_DissolveTexChannel",int) = 0
		
		[Header(DissolveType)]
		[LiteToggle]_DissolveByVertexColor("Dissolve By Vertex Color ?",int)=0
		[LiteToggle]_DissolveByCustomData_Z("Dissolve By customData.z -> uv1.x ?",int)=0

		[Header(DissolveFading)]
		_DissolveFadingMin("_DissolveFadingMin",range(0,.2)) = 0
		_DissolveFadingMax("_DissolveFadingMax",range(0,.2)) = .2

		[Header(Dissolve Clip)]
		[LiteToggle]_DissolveClipOn("_DissolveClipOn",int) = 1
		_Cutoff ("AlphaTest cutoff", Range(0,1)) = 0.5

		[Header(PixelDissolve)]
		[LiteToggle]_PixelDissolveOn("_PixelDissolveOn",float) = 0
		_PixelWidth("_PixelWidth",float) = 10

		[Header(DissolveEdge)]
		[LiteToggle]_DissolveEdgeOn("Dissolve Edge On?",int)=0
		_EdgeWidth("EdgeWidth",range(0,0.3)) = 0.1
		[LiteToggle]_DissolveEdgeWidthByCustomData_W("_DissolveEdgeWidthByCustomData_W.w -> uv1.y",int) = 0
		[HDR]_EdgeColor("EdgeColor",color) = (1,0,0,1)
		[HDR]_EdgeColor2("EdgeColor2",color) = (0,1,0,1)
// ==================================================
		[Header(Offset)] 
		[LiteToggle] _OffsetOn("Offset On?",int) = 0
		[NoScaleOffset]_OffsetTex("Offset Tex",2d) = ""{}
		_OffsetMaskTex("Offset Mask (R)",2d) = "white"{}
		[Enum(R,0,G,1,B,2,A,3)]_OffsetMaskChannel("_OffsetMaskChannel",int) = 0
		[HDR]_OffsetTexColorTint("OffsetTex Color",color) = (1,1,1,1)
		[HDR]_OffsetTexColorTint2("OffsetTex Color 2",color) = (1,1,1,1)
		_OffsetTile("Offset Tile",vector) = (1,1,1,1)
		_OffsetDir("Offset Dir",vector) = (1,1,0,0)
		_OffsetBlendIntensity("Blend Intensity",range(0,10)) = 0.5
		[Header(Radial UV)]
		[LiteToggle]_OffsetRadialUVOn("_OffsetRadialUVOn",int) = 0
		_OffsetRadialCenter_LenScale_LenOffset("_OffsetRadialCenter_LenScale_LenOffset",vector) = (.5,.5,1,0)
		_OffsetRadialRot("_OffsetRadialRot",float) = 0
// ==================================================
		[Header(Fresnal)]
		[LiteToggle]_FresnelOn("_FresnelOn?",int)=0
		[Enum(Replace,0,Multiply,1)]_FresnelColorMode("_FresnelColorMode",int) = 0
		[HDR]_FresnelColor("_FresnelColor",color) = (1,1,1,1)
		[HDR]_FresnelColor2("_FresnelColor2",color) = (1,1,1,1)
		[Header(Range)]
		_FresnelPowerMin("_FresnelPowerMin",range(0,1)) = 0.4
		_FresnelPowerMax("_FresnelPowerMax",range(0,1)) = 0.5
// ==================================================		
		[Header(EnvReflection)]
		[LiteToggle]_EnvReflectOn("EnvReflect On?",int)=0
		_EnvReflectionColor("_EnvReflectionColor",color) = (.5,.5,.5,.5)

		[Header(EnvRefraction)]
		[LiteToggle]_EnvRefractionOn("_EnvRefractionOn",int) = 0
		_EnvRefractionIOR("_EnvRefractionIOR",range(1,5)) = 1.33
		_EnvRefractionColor("_EnvRefractionColor",color) = (.5,.5,.5,.5)

		[Header(Env Params)]
		[NoScaleOffset]_EnvMap("Env Map",Cube) = ""{}
		_EnvMapMask("Env Map Mask",2d) = ""{}
		[Enum(R,0,G,1,B,2,A,3)]_EnvMapMaskChannel("_EnvMapMaskChannel",int)=0
		_EnvIntensity("Env intensity",float) = 1
		_EnvOffset("EnvOffset",vector) = (0,0,0,0)

// ==================================================
		[Header(MatCap)]
		[LiteToggle]_MatCapOn("_MatCapOn",int) = 0
		[noscaleoffset]_MatCapTex("_MapCapTex",2d)=""{}
		[hdr]_MatCapColor("_MatCapColor",color) = (1,1,1,1)
		_MatCapIntensity("_MatCapIntensity",float) = 1
		[LiteToggle]_MatCapRotateOn("_MatCapRotateOn",float) = 0
		_MatCapAngle("_MapCatAngle",float) = 0
// ==================================================
		[Header(_DepthFading)]
		[LiteToggle]_DepthFadingOn("_DepthFadingOn",int) = 0
		_DepthFadingWidth("_DepthFadingWidth",range(0.01,3)) = 1
		[Header(Light)]
		[LiteToggle]_LightOn("_LightOn",float) = 0
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }

		Pass
		{
			ZWrite[_ZWriteMode]
			Blend [_SrcMode][_DstMode]
			// BlendOp[_BlendOp]
			Cull[_CullMode]
			ztest[_ZTestMode]
			CGPROGRAM
            #pragma multi_compile_instancing

			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lib/PowerVFXPass.cginc"

			ENDCG
		}
	}

	CustomEditor "PowerVFX.PowerVFXInspector"
}