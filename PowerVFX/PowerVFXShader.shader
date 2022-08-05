// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
Shader "FX/PowerVFX"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_MainUVAngle("_MainUVAngle",float) = 0
		[GroupToggle]_MainTexOffsetStop("_MainTexOffsetStop",int)=0
		[GroupToggle]_MainTexOffsetUseCustomData_XY("_MainTexOffsetUseCustomData_XY -> uv.zw",int)=0

		[Header(Saturate)]
		_MainTexSaturate("_MainTexSaturate",float) = 1
		[Header(Main Color)]
		[HDR]_Color("Main Color",Color) = (1,1,1,1)
		_ColorScale("ColorScale",range(1,3)) = 1
		[GroupToggle]_MainTexMultiAlpha("_MainTexMultiAlpha",int) = 0


		[Header(Single Channel MainTex)]
		[GroupToggle]_MainTexSingleChannelOn("_MainTexSingleChannelOn?",int) = 0
		[Enum(R,0,G,1,B,2,A,3)]_MainTexChannel("_MainTexChannel",int)=0

		[Header(Back Face)]
		[GroupToggle]_BackFaceOn("_BackFaceOn",int) = 0
		[HDR]_BackFaceColor("BackFace Color",Color) = (0.5,0.5,.5,1)

		[Header(MaskTexMask)]
		_MainTexMask("Main Texture Mask(R)", 2D) = "white" {}
		[GroupToggle]_MainTexMaskOffsetStop("_MainTexMaskOffsetStop",int)=0
		[Enum(R,0,G,1,B,2,A,3)]_MainTexMaskChannel("_MainTexMaskChannel",int) = 0

		[Header(ScreenOpaqueTexture)]
		[GroupToggle(_)]_MainTexUseScreenColor("_MainTexUseScreenColor",int) = 0

// ==================================================		Alpha
		[Header(Alpha Range)]
		_AlphaMin("_AlphaMin",range(0,1)) = 0
		_AlphaMax("_AlphaMax",range(0,1)) = 1

		[Header(Alpha Scale)]
		_AlphaScale("_AlphaScale",float) = 1
// ==================================================BlendMode
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
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("_ZTestMode",float) = 4
// ==================================================_VertexWaveOn
		[GroupToggle(_,VERTEX_WAVE_ON)]_VertexWaveOn("_VertexWaveOn ?",int) = 0
		[Header(Noise Map)]
		[GroupToggle]_NoiseUseAttenMaskMap("_NoiseUseAttenMaskMap",float)=0
		[Header(Noise Params)]
		_VertexWaveSpeed("_VertexWaveSpeed",float) = 1
		[GroupToggle]_VertexWaveSpeedManual("_VertexWaveSpeedManual",int) = 0
		_VertexWaveIntensity("_VertexWaveIntensity",float) = 1
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
		[GroupToggle]_VertexWaveAttenMaskOffsetScale_UseCustomeData2_X("_VertexWaveAttenMaskOffsetScale_UseCustomeData2_X",int) = 0
// ==================================================Distortion
		[Header(Distortion)]
		[GroupToggle(_,DISTORTION_ON)]_DistortionOn("Distortion On?",int)=0
		[noscaleoffset]_DistortionNoiseTex("Noise Texture(xy:layer1,zw:layer2)",2D) = "white" {}
		
		[Header(DistortionMask)]
		_DistortionMaskTex("Distortion Mask Tex(R)",2d) = "white"{}
		[Enum(R,0,G,1,B,2,A,3)]_DistortionMaskChannel("_DistortionMaskChannel",int)=0

		[Header(Distortion Intensity)]
		_DistortionIntensity("Distortion Intensity",Range(0,2)) = 0.5
		[GroupToggle]_DistortionByCustomData_Vector2_X("_DistortionByCustomData_Vector2_X",int) = 0

		[Header(DistortionParams)]
		_DistortTile("Distort Tile",vector) = (1,1,1,1)
		_DistortDir("Distort Dir",vector) = (0,1,0,-1)

		[Header(Radial UV)]
		[GroupToggle]_DistortionRadialUVOn("_DistortionRadialUVOn",int) = 0
		_DistortionRadialCenter_LenScale_LenOffset("_DistortionRadialCenter_LenScale_LenOffset",vector) = (.5,.5,1,0)
		_DistortionRadialRot("_DistortionRadialRot",float) = 0

		[Header(Distortion Where)]
		[GroupToggle]_DistortionApplyToOffset("_DistortionApplyToOffset",int) = 0
		[GroupToggle]_DistortionApplyToMainTexMask("_DistortionApplyToMainTexMask",int) = 0
		[GroupToggle]_DistortionApplyToDissolve("_DistortionApplyToDissolve",int) = 0
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
		[GroupToggle]_DissolveByCustomData_Z("Dissolve By customData.z -> uv1.x ?",int)=0

		[Header(DissolveFading)]
		_DissolveFadingMin("_DissolveFadingMin",range(0,.2)) = 0
		_DissolveFadingMax("_DissolveFadingMax",range(0,.2)) = .2

		[Header(Dissolve Progress)]
		_Cutoff ("_Cutoff", Range(0,1)) = 0.5
		[Header(Dissolve Clip)]
		[Toggle(ALPHA_TEST)]_DissolveClipOn("_DissolveClipOn",int) = 1

		[Header(PixelDissolve)]
		[GroupToggle]_PixelDissolveOn("_PixelDissolveOn",float) = 0
		_PixelWidth("_PixelWidth",float) = 10

		[Header(DissolveEdge)]
		[GroupToggle]_DissolveEdgeOn("Dissolve Edge On?",int)=0
		_EdgeWidth("EdgeWidth",range(0,0.3)) = 0.1
		[GroupToggle]_DissolveEdgeWidthByCustomData_W("_DissolveEdgeWidthByCustomData_W.w -> uv1.y",int) = 0
		[HDR]_EdgeColor("EdgeColor",color) = (1,0,0,1)
		[HDR]_EdgeColor2("EdgeColor2",color) = (0,1,0,1)
// ==================================================Offset
		[Header(Offset)] 
		[GroupToggle(_,OFFSET_ON)] _OffsetOn("Offset On?",int) = 0
		[NoScaleOffset]_OffsetTex("Offset Tex",2d) = ""{}
		_OffsetTile("Offset Tile",vector) = (1,1,1,1)
		_OffsetDir("Offset Dir",vector) = (1,1,0,0)
		[HDR]_OffsetTexColorTint("OffsetTex Color",color) = (1,1,1,1)
		[HDR]_OffsetTexColorTint2("OffsetTex Color 2",color) = (1,1,1,1)

		[Header(Blend Ops)]
		_OffsetBlendIntensity("Blend Intensity",range(0,10)) = 0.5
		_OffsetBlendMode("_OffsetBlendMode",range(0,1)) = 1

		[Header(Offset Mask)]
		_OffsetMaskTex("Offset Mask (R)",2d) = "white"{}
		[GroupToggle]_OffsetMaskPanStop("_OffsetMaskPanStop",float) = 0
		[Enum(R,0,G,1,B,2,A,3)]_OffsetMaskChannel("_OffsetMaskChannel",int) = 0

		[Header(Radial UV)]
		[GroupToggle]_OffsetRadialUVOn("_OffsetRadialUVOn",int) = 0
		_OffsetRadialCenter_LenScale_LenOffset("_OffsetRadialCenter_LenScale_LenOffset",vector) = (.5,.5,1,0)
		_OffsetRadialRot("_OffsetRadialRot",float) = 0
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
		[Header(EnvReflection)]
		[GroupToggle(_,ENV_REFLECT_ON)]_EnvReflectOn("EnvReflect On?",int)=0
		_EnvReflectionColor("_EnvReflectionColor",color) = (.5,.5,.5,.5)

		[Header(EnvRefraction)]
		[GroupToggle(_,ENV_REFRACTION_ON)]_EnvRefractionOn("_EnvRefractionOn",int) = 0
		_EnvRefractionIOR("_EnvRefractionIOR",range(1,5)) = 1.33
		_EnvRefractionColor("_EnvRefractionColor",color) = (.5,.5,.5,.5)

		[Header(Env Params)]
		[NoScaleOffset]_EnvMap("Env Map",Cube) = ""{}
		_EnvIntensity("Env intensity",float) = 1
		_EnvOffset("EnvOffset",vector) = (0,0,0,0)

		[Header(Env Mask)]
		[GroupToggle]_EnvMaskUseMainTexMask("_EnvMaskUseMainTexMask",int)=3
		[Enum(R,0,G,1,B,2,A,3)]_EnvMapMaskChannel("_EnvMapMaskChannel",int)=0

// ==================================================MatCap
		[Header(MatCap)]
		[GroupToggle(_,MATCAP_ON)]_MatCapOn("_MatCapOn",int) = 0
		[noscaleoffset]_MatCapTex("_MapCapTex",2d)=""{}
		[hdr]_MatCapColor("_MatCapColor",color) = (1,1,1,1)
		_MatCapIntensity("_MatCapIntensity",float) = 1
		[GroupToggle]_MatCapRotateOn("_MatCapRotateOn",float) = 0
		_MatCapAngle("_MapCatAngle",float) = 0
// ==================================================_DepthFading
		[Header(_DepthFading)]
		[GroupToggle(_,DEPTH_FADING_ON)]_DepthFadingOn("_DepthFadingOn",int) = 0
		_DepthFadingWidth("_DepthFadingWidth",range(0.01,3)) = 1

// ================================================== Light		
		[Header(Light)]
		[GroupToggle(_,PBR_LIGHTING)]_PbrLightOn("_PbrLightOn",float) = 0
		_NormalMap("_NormalMap",2d)="bump"{}
		_NormalMapScale("_NormalMapScale",range(0,5)) = 1
		_PbrMask("_PbrMask(Metal,Smooth,Occ)",2d)="white"{}
		_Metallic("_Metallic",range(0,1))=0.5
		_Smoothness("_Smoothness",range(0,1))=0.5
		_Occlusion("_Occlusion",range(0,1)) = 0
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
			#pragma multi_compile_fog
            #pragma multi_compile_instancing
			#pragma multi_compile_local_fragment _ ALPHA_TEST
			#pragma multi_compile _ PBR_LIGHTING
			#pragma multi_compile_local_vertex _ VERTEX_WAVE_ON
			#pragma multi_compile_local_fragment _ DISTORTION_ON
			#pragma multi_compile_local_fragment _ DISSOLVE_ON
			#pragma multi_compile_local_fragment _ OFFSET_ON
			#pragma multi_compile _ FRESNEL_ON
			#pragma multi_compile_local_fragment _ ENV_REFLECT_ON
			#pragma multi_compile_local_fragment _ ENV_REFRACTION_ON
			#pragma multi_compile_local_fragment _ MATCAP_ON
			#pragma multi_compile_local_fragment _ DEPTH_FADING_ON
			#pragma multi_compile_local_fragment _ DOUBLE_EFFECT_ON
			// #pragma multi_compile_local_fragment _ MAIN_TEX_USE_SCREEN_COLOR // unused yet

			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lib/PowerVFXPass.cginc"

			ENDCG
		}
	}

	CustomEditor "PowerUtilities.PowerVFXInspector"
}