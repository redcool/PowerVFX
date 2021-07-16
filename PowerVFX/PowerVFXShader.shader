// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
Shader "FX/PowerVFX"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		[Toggle]_MainTexOffsetStop("禁用MainTex自动滚动?",int)=0
		[Toggle]_MainTexOffsetUseCustomData_XY("_MainTexOffsetUseCustomData_XY -> uv.zw",int)=0
		[HDR]_Color("Main Color",Color) = (1,1,1,1)
		_ColorScale("ColorScale",range(1,3)) = 1
		[Header(MaskTexMask)]
		_MainTexMask("Main Texture Mask(R)", 2D) = "white" {}
		[Toggle]_MainTexMaskOffsetStop("_MainTexMaskOffsetStop",int)=0
		[Toggle]_MainTexMaskUseR("_MainTexMaskUseR",int) = 1
		[Toggle]_MainTexUseScreenColor("_MainTexUseScreenColor",int) = 0

		[Header(BlendMode)]
		[Enum(UnityEngine.Rendering.BlendMode)]_SrcMode("Src Mode",int) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_DstMode("Dst Mode",int) = 10

		[Header(DoubleEffect)]
		[Toggle(_DoubleEffectOn)]_DoubleEffectOn("双重效果?",int)=0
		
		[Header(CullMode)]
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode",float) = 0
		[Toggle]_ZWriteMode("ZWriteMode",int) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",float) = 4
//// ======================================
		[Toggle]_VertexWaveOn("_VertexWaveOn ?",int) = 0
		_VertexWaveSpeed("_VertexWaveSpeed",float) = 1
		_VertexWaveIntensity("_VertexWaveIntensity",float) = 1

		[Header(Vertex Wava Atten)]
		[Toggle]_VertexWaveAtten_VertexColor("_VertexWaveAtten_VertexColor",float) = 0
		_VertexWaveDirAtten("_VertexWaveDirAtten",vector) = (1,1,1,0)
		[Header(Forward Dir Atten)]
		[Toggle]_VertexWaveAtten_ForwardAtten("_VertexWaveAtten_ForwardAtten",float) = 0
		_VertexWaveForawdLength("_VertexWaveForawdLength",float) = 1
//// ======================================
		[Header(Distortion)]
		[Toggle(DISTORTION_ON)]_DistortionOn("Distortion On?",int)=0
		[noscaleoffset]_NoiseTex("Noise Texture",2D) = "white" {}
		[noscaleoffset]_NoiseTex2("Noise Texture2",2D) = "white" {}

		[noscaleoffset]_DistortionMaskTex("Distortion Mask Tex(R)",2d) = "white"{}
		[Toggle]_DistortionMaskUseR("DistortionMaskUseR",int)=1
		_DistortionIntensity("Distortion Intensity",Range(0,10)) = 0.5

		_DistortTile("Distort Tile",vector) = (1,1,1,1)
		_DistortDir("Distort Dir",vector) = (0,1,0,-1)


		[Header(Dissolve)]
		[Toggle(DISSOLVE_ON)]_DissolveOn("Dissolve On?",int)=0
		[Toggle]_DissolveRevert("_DissolveRevert",int) = 0
		_DissolveTex("Dissolve Tex",2d)=""{}
		[Toggle]_DissolveTexOffsetStop("_DissolveTexOffsetStop ?",int) = 0
		[Toggle]_DissolveTexUseR("_DisolveTexUse R(uncheck use A)?",int)=0
		
		[Header(DissolveType)]
		[Toggle]_DissolveByVertexColor("Dissolve By Vertex Color ?",int)=0
		[Toggle]_DissolveByCustomData("Dissolve By customData.z -> uv1.x ?",int)=0

		[Header(DissolveFading)]
		[Toggle]_DissolveFadingOn("_DissolveFadingOn",int) = 0
		_DissolveFading("_DissolveFading",range(0,0.5)) = 0.01
		_DissolveFadingWidth("_DissolveFadingWidth",range(0,0.5)) = 0.2

		[Header(Dissolve Clip)]
		[Toggle]_DissolveClipOn("_DissolveClipOn",int) = 1
		_Cutoff ("AlphaTest cutoff", Range(0,1)) = 0.5

		[Header(PixelDissolve)]
		[Toggle]_PixelDissolveOn("_PixelDissolveOn",float) = 0
		_PixelWidth("_PixelWidth",float) = 10


		[Header(DissolveEdge)]
		[Toggle(DISSOLVE_EDGE_ON)]_DissolveEdgeOn("Dissolve Edge On?",int)=0
		_EdgeWidth("EdgeWidth",range(0,0.3)) = 0.1
		[Toggle]_DissolveEdgeWidthBy_Custom1("_DissolveEdgeWidthBy_Custom1.w -> uv1.y",int) = 0
		[HDR]_EdgeColor("EdgeColor",color) = (1,0,0,1)
		[HDR]_EdgeColor2("EdgeColor2",color) = (0,1,0,1)

		[Header(Offset)]
		[Toggle(OFFSET_ON)] _OffsetOn("Offset On?",int) = 0
		[NoScaleOffset]_OffsetTex("Offset Tex",2d) = ""{}
		[NoScaleOffset]_OffsetMaskTex("Offset Mask (R)",2d) = "white"{}
		[Toggle]_OffsetMaskTexUseR("_OffsetMaskTexUseR",int) = 1
		[HDR]_OffsetTexColorTint("OffsetTex Color",color) = (1,1,1,1)
		[HDR]_OffsetTexColorTint2("OffsetTex Color 2",color) = (1,1,1,1)
		_OffsetTile("Offset Tile",vector) = (1,1,1,1)
		_OffsetDir("Offset Dir",vector) = (1,1,0,0)
		_BlendIntensity("Blend Intensity",range(0,10)) = 0.5

		[Header(Fresnal)]
		[Toggle(FRESNAL_ON)]_FresnelOn("_FresnelOn?",int)=0
		[HDR]_FresnelColor("_FresnelColor",color) = (1,1,1,1)
		_FresnelPower("_FresnelPower",range(0,1)) = 0.5
		[Toggle]_FresnelTransparentOn("_FresnelTransparentOn",range(0,1)) = 0
		_FresnelTransparent("_FresnelTransparent",range(0,1)) = 0
		
		[Header(EnvReflection)]
		[Toggle(ENV_REFLECT)]_EnvReflectOn("EnvReflect On?",int)=0
		[NoScaleOffset]_EnvMap("Env Map",Cube) = ""{}
		[NoScaleOffset]_EnvMapMask("Env Map Mask",2d) = ""{}
		[Toggle]_EnvMapMaskUseR("EnvMapMaskUseR",int)=1
		_EnvIntensity("Env intensity",float) = 1
		_EnvOffset("EnvOffset",vector) = (0,0,0,0)

		[Header(MatCap)]
		[noscaleoffset]_MatCapTex("_MapCapTex",2d)=""{}
		_MatCapIntensity("_MatCapIntensity",float) = 0
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }

		Pass
		{
			ZWrite[_ZWriteMode]
			Blend [_SrcMode][_DstMode]
			Cull[_CullMode]
			ztest[_ZTestMode]
			CGPROGRAM
            #pragma multi_compile_instancing

			#pragma vertex vert
			#pragma fragment frag
			
			#include "PowerVFXPass.cginc"

			ENDCG
		}
	}

	CustomEditor "PowerVFX.PowerVFXInspector"
}