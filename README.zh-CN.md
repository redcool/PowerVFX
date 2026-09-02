# PowerVFX

[English](README.md) | [简体中文](README.zh-CN.md)

## 简介

PowerVFX 是一套面向 URP（通用渲染管线）的粒子/特效着色器（FX/PowerVFX），支持渲染到纹理（Render-to-Texture）能力，例如在透明物体渲染之后抓取屏幕、再将透明后的画面作为 `_CameraOpaqueTexture` 使用（URP 特效粒子着色器，支持透明后渲染与渲染到纹理 / 抓屏）。

文档: https://gamebox1.yuque.com/staff-nb8i9p/gqhkx4/dnribz

## 功能特性（Features）

### PowerVFXShader.shader —— `FX/PowerVFX`
一个功能全面的透明特效着色器，内置 3 个着色器 LOD（通过 `shader.maximumLOD` 设置）：
- **LOD 100** —— 完整版本，包含全部功能。
- **LOD 80** —— 简化版本（`SIMPLE_VERSION`）：不含 `_UVCircleDist2`、`_PerChannelColorOn`、扭曲遮罩。
- **LOD 50** —— 最小版本（`MIN_VERSION`）：面向大量小粒子渲染的最小功能集（uv offset、序列帧（sheet）、雾效、顶点色、alpha test 等）。
- 自定义 Inspector `PowerUtilities.PowerShaderInspector`，带分组、中文本地化属性（Profiles/）。

主贴图 / 颜色：
- MainTex 偏移（自动滚动 / 停止 / 由粒子 CustomData 驱动）、UV 旋转、饱和度、单通道模式、预乘 Alpha。
- 屏幕颜色 / 屏幕 UV 使用与全屏模式；序列帧（翻页书 flipbook）动画并支持动画混合（anim-blend）；Sprite UV。
- 顶点色（预乘、逐通道）、逐通道颜色染色、背面颜色、双重效果（扭曲/流光）。

Alpha 与渲染状态：
- Alpha 范围/缩放、Alpha 通道覆盖、按视角距离淡出、Alpha 测试。
- 混合源/目标模式、剔除（Cull）、ZWrite/ZTest、颜色遮罩、深度偏移、模板（Stencil）。

特效：
- **VertexWave** —— 基于渐变噪声或衰减遮罩的顶点波浪，由 CustomData 驱动强度/方向、UV 圆距离衰减、法线/距离限制衰减。
- **Distortion** —— 双层噪声扭曲，支持遮罩、CustomData 强度、径向（极坐标）UV；可作用于主贴图 / 流光 / 遮罩 / 溶解。
- **Dissolve** —— 按顶点色或贴图溶解、CustomData 进度、淡出范围、裁剪（clip）、像素溶解、双色溶解边缘。
- **Offset（流光）** —— 滚动流光贴图、CustomData 驱动偏移、混合模式（相乘 / 替换通道）、遮罩、径向 UV、颜色染色。
- **Fresnel** —— 边缘光（替换/相乘模式）、强度范围、Alpha 基底、屏幕颜色混合。
- **Env Reflection** —— 立方体贴图反射，支持旋转/自动停止与环境遮罩；**Env Refraction** —— 基于折射率（IOR）的折射，支持内景贴图（interior-map）模式。
- **MatCap**、**DepthFading**（软粒子）。
- **PBR 光照**（可选 `PBR_LIGHTING`）—— 法线贴图、PBR 遮罩（金属度/光滑度/环境光遮蔽（AO））、自定义光源方向/颜色、全局光照（GI）、主光源阴影（`MAIN_LIGHT_CALCULATE_SHADOWS`）、附加光源、雾效。
- **Glitch** —— 水平强度 + 雪花噪点。

粒子集成：
- 读取 Unity ParticleSystem CustomVertexStreams 的 **Custom1/Custom2**，打包进 uv 通道（参见 **PowerVFXData.hlsl** 中的 appdata）、序列帧 AnimBlend；支持 UGUI 裁剪矩形。

### Lib/ —— 着色器包含文件
- **CommonLib.hlsl**（基础 + 包含 PowerShaderLib）、**PowerVFXCore.hlsl**（顶点波浪 / 扭曲 / 溶解 / 流光 / MatCap / 雾效等）、**PowerVFXData.hlsl**（appdata/v2f、自定义数据打包）、**PowerVFXInput.hlsl**（属性）、**PowerVFXPass.hlsl**（主要顶点/片元着色器）、**PowerVFXPassVersion.hlsl**（MIN_VERSION 切换）、**PowerVFXPassMinVersion.hlsl**（最小 pass）。

### RenderToTexture（渲染到纹理）
- **URP**：`Scripts/RenderToTexture/urp/AfterTransparentRender.cs` —— `ScriptableRendererFeature`（可脚本化渲染特性），包含：
  - `AfterTransparentRenderPass` —— 在透明物体渲染之后，重新渲染带指定 ShaderTag 的对象（`SRPDefaultUnlit`/`UniversalForward` 等）（可选清除深度）。
  - `GrabTransparentPass` —— 将摄像机颜色 blit 到 `_CameraOpaqueTexture`（可选降采样高斯模糊）；`AfterTransparentRenderSettingSO.cs` 设置（事件、模糊、图层遮罩）。
- **DRP（内置渲染管线）**：`Scripts/RenderToTexture/drp/CustomTargetCamera.cs` —— 通过 CommandBuffer 将颜色/深度 blit 到全局 `_CameraOpaqueTexture`/`_CameraDepthTexture`。
- 着色器：**GaussianBlur.shader**（`Hidden/PowerVFX/GaussianBlur`）、**BlurBackground.shader**、**ShowCameraTexture.shader**、**BlurLib.hlsl**。

### 工具 / 测试 / 美术资源
- **PowerVFXMinVersionChecker.cs** —— 菜单 `PowerUtilities/PowerVFX/Check MinVersion`，可为兼容材质启用 `MIN_VERSION`（Logs/Version.log：v2.1.10）。
- **Scenes/** —— `TestPowerVFX.unity`、`AfterTransparent.unity`、`SampleScene`；URP 资源 `urp_powervfx.asset` + `urp_powervfx_Renderer.asset`（渲染特性：AfterTransparentRender、GrabScreen、RenderGammaUI 等）。
- **Arts/** —— 粒子精灵、`Matcap/`、`NoiseTex/`（tex1-4、ExampleNoise2D/23D）。
- **Test/** —— 材质球（test 1/2、particle distortion、testSprite、testUI、BlurImage 等）、**TestSheet** 序列帧 UV 测试、MinVersion 材质球。

## 目录结构（Folder structure）

```
PowerVFX/
└─ PowerVFX/
   ├─ PowerVFXShader.shader     # FX/PowerVFX（3 个 LOD）
   ├─ Lib/                      # input / data / core / pass(min) hlsl
   ├─ Scripts/
   │  ├─ RenderToTexture/       # urp（AfterTransparentRender）+ drp（CustomTargetCamera）+ 着色器
   │  └─ Tools/                 # PowerVFXMinVersionChecker
   ├─ Arts/                     # 精灵、MatCap、噪声贴图
   ├─ Test/                     # 测试材质球 + TestSheet
   ├─ Scenes/                   # 示例场景 + URP 管线/渲染器资源
   ├─ Profiles/                 # Inspector 布局 / 国际化（中文）
   ├─ Logs/Version.log
   └─ PowerVFX.asmdef
```

## 使用说明（Usage）

- 需要 **PowerShaderLib** + **PowerUtilities**（参见「参考仓库 / 依赖」）—— 本包通过 `../../PowerShaderLib/...` 包含文件；请将它们放在同一目录下。
- 将 `urp_powervfx.asset` 指定为 URP 管线资源（RequireDepthTexture、HDR）。
- 透明后抓屏：添加 **AfterTransparentRender** 渲染特性并配置 `AfterTransparentRenderSettingSO`（gameCameraTag、抓屏/渲染 pass 事件、模糊选项、图层）。
- 使用 CustomData 驱动的功能时，请在 ParticleSystem 的 Renderer → CustomVertexStreams 中设置 Custom1/Custom2（+ UV/UV2/AnimBlend）。
- 通过 `Material.shader.maximumLOD`（100 / 80 / 50）控制质量。

## 参考仓库 / 依赖（Reference Gits）

https://github.com/redcool/PowerUtilities.git
https://github.com/redcool/PowerShaderLib.git

将它们放在同一目录下。

## 备注 / 更新记录（Notes / Changelog）

- 中文文档：https://gamebox1.yuque.com/staff-nb8i9p/gqhkx4/dnribz
