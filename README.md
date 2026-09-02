# PowerVFX

[English](README.md) | [简体中文](README.zh-CN.md)


A particle / special-effect shader (FX/PowerVFX) for URP with render-to-texture support

Docs: https://gamebox1.yuque.com/staff-nb8i9p/gqhkx4/dnribz

## Features

### PowerVFXShader.shader — `FX/PowerVFX`
One versatile transparent FX shader with 3 shader LODs (set via `shader.maximumLOD`):
- **LOD 100** — full version, all features.
- **LOD 80** — simple version (`SIMPLE_VERSION`): no `_UVCircleDist2`, `_PerChannelColorOn`, distortion mask.
- **LOD 50** — min version (`MIN_VERSION`): minimal feature set for massive small particles (uv offset, sheet, fog, vertex color, alpha test...).
- Custom inspector `PowerUtilities.PowerShaderInspector` with grouped, Chinese-localized properties (Profiles/).

Main texture / color:
- MainTex offset (auto-scroll / stop / particle-CustomData driven), UV rotation, saturation, single-channel mode, premultiplied alpha.
- Screen-color / screen-UV usage and fullscreen mode; sheet (flipbook) animation with anim-blend; sprite UV.
- Vertex color (premultiplied, per-channel), per-channel color tint, back-face color, double effect (distortion/streak).

Alpha & states:
- Alpha range/scale, alpha channel override, view-distance fading, alpha test.
- Blend src/dst modes, cull, ZWrite/ZTest, color mask, depth offset, stencil.

Effects:
- **VertexWave** — vertex wave via gradient noise or attenuation mask, CustomData-driven intensity/dir, UV-circle distance attenuation, normal/distance-limit attenuation.
- **Distortion** — 2-layer noise distortion with mask, CustomData intensity, radial (polar) UV; applies to mainTex / offset / mask / dissolve.
- **Dissolve** — by vertex color or texture, CustomData progress, fade range, clip, pixel dissolve, dissolve edge with two colors.
- **Offset (flow-light streaks)** — scrolling flow texture, CustomData-driven offset, blend modes (multiply / replace-channel), mask, radial UV, color tint.
- **Fresnel** — edge color (replace/multiply), power range, alpha base, screen-color blend.
- **Env Reflection** — cubemap reflection with rotation/auto-stop and env mask; **Env Refraction** — IOR-based refraction with interior-map mode.
- **MatCap**, **DepthFading** (soft particles).
- **PBR lighting** (optional `PBR_LIGHTING`) — normal map, PBR mask (metallic/smoothness/occlusion), custom light dir/color, GI, main-light shadows (`MAIN_LIGHT_CALCULATE_SHADOWS`), additional lights, fog.
- **Glitch** — horizontal intensity + snowflake.

Particle integration:
- Reads Unity ParticleSystem CustomVertexStreams **Custom1/Custom2** packed into uv channels (see appdata in **PowerVFXData.hlsl**), sheet AnimBlend; UGUI clip-rect support.

### Lib/ — shader includes
- **CommonLib.hlsl** (basics + includes PowerShaderLib), **PowerVFXCore.hlsl** (vertex wave / distortion / dissolve / offset / matcap / fog...), **PowerVFXData.hlsl** (appdata/v2f, custom-data packing), **PowerVFXInput.hlsl** (properties), **PowerVFXPass.hlsl** (main vert/frag), **PowerVFXPassVersion.hlsl** (MIN_VERSION switch), **PowerVFXPassMinVersion.hlsl** (minimal pass).

### RenderToTexture
- **URP**: `Scripts/RenderToTexture/urp/AfterTransparentRender.cs` — `ScriptableRendererFeature` with:
  - `AfterTransparentRenderPass` — re-renders shader-tagged objects (`SRPDefaultUnlit`/`UniversalForward`...) after transparents (optional clear depth).
  - `GrabTransparentPass` — blits camera color to `_CameraOpaqueTexture` (optional Gaussian blur at downsample); `AfterTransparentRenderSettingSO.cs` settings (events, blur, layer mask).
- **DRP (built-in)**: `Scripts/RenderToTexture/drp/CustomTargetCamera.cs` — CommandBuffer blits color/depth to global `_CameraOpaqueTexture`/`_CameraDepthTexture`.
- Shaders: **GaussianBlur.shader** (`Hidden/PowerVFX/GaussianBlur`), **BlurBackground.shader**, **ShowCameraTexture.shader**, **BlurLib.hlsl**.

### Tools / Test / Arts
- **PowerVFXMinVersionChecker.cs** — menu `PowerUtilities/PowerVFX/Check MinVersion` enables `MIN_VERSION` on compatible materials (Logs/Version.log: v2.1.10).
- **Scenes/** — `TestPowerVFX.unity`, `AfterTransparent.unity`, `SampleScene`; URP assets `urp_powervfx.asset` + `urp_powervfx_Renderer.asset` (features: AfterTransparentRender, GrabScreen, RenderGammaUI...).
- **Arts/** — particle sprites, `Matcap/`, `NoiseTex/` (tex1-4, ExampleNoise2D/23D).
- **Test/** — materials (test 1/2, particle distortion, testSprite, testUI, BlurImage...), **TestSheet** sheet-UV test, MinVersion materials.

## Folder structure

```
PowerVFX/
└─ PowerVFX/
   ├─ PowerVFXShader.shader     # FX/PowerVFX (3 LODs)
   ├─ Lib/                      # input / data / core / pass(min) hlsl
   ├─ Scripts/
   │  ├─ RenderToTexture/       # urp (AfterTransparentRender) + drp (CustomTargetCamera) + shaders
   │  └─ Tools/                 # PowerVFXMinVersionChecker
   ├─ Arts/                     # sprites, matcap, noise textures
   ├─ Test/                     # test materials + TestSheet
   ├─ Scenes/                   # demo scenes + URP pipeline/renderer assets
   ├─ Profiles/                 # inspector layouts / i18n
   ├─ Logs/Version.log
   └─ PowerVFX.asmdef
```

## Usage / Setup

- Requires **PowerShaderLib** + **PowerUtilities** (see Reference Gits) — the package includes files via `../../PowerShaderLib/...`; keep them in the same folder.
- Assign `urp_powervfx.asset` as the URP pipeline asset (RequireDepthTexture, HDR).
- After-transparent grab: add the **AfterTransparentRender** renderer feature and configure `AfterTransparentRenderSettingSO` (gameCameraTag, grab/render pass events, blur options, layer).
- For CustomData-driven features, set the ParticleSystem Renderer → CustomVertexStreams → Custom1/Custom2 (+ UV/UV2/AnimBlend).
- Control quality via `Material.shader.maximumLOD` (100 / 80 / 50).

## Reference Gits

https://github.com/redcool/PowerUtilities.git
https://github.com/redcool/PowerShaderLib.git

put them into same folder.

## Notes

- CN Docs: https://gamebox1.yuque.com/staff-nb8i9p/gqhkx4/dnribz