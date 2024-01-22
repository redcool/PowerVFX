namespace PowerUtilities
{
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
#if UNITY_2020
    using UniversalRenderer = UnityEngine.Rendering.Universal.ForwardRenderer;
#endif
#if UNITY_EDITOR
    using UnityEditor;
    using System;

    [CustomEditor(typeof(AfterTransparentRender))]
    public class AfterTransparentRenderEditor : SettingSOEditor
    {
        public override string SettingSOFieldName => "settings";
        public override Type SettingSOType => typeof(AfterTransparentRenderSettingSO);
    }
#endif

    public class AfterTransparentRender : ScriptableRendererFeature
    {

        [SerializeField] AfterTransparentRenderSettingSO settings;
        AfterTransparentRenderPass renderAfterTransparentPass;
        GrabTransparentPass grabTransparentPass;

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (!settings)
                return;

            ref var cameraData = ref renderingData.cameraData;

            if(!string.IsNullOrEmpty(settings.gameCameraTag) && !cameraData.camera.CompareTag(settings.gameCameraTag))
            {
                return;
            }

            if (settings.enableGrabPass)
                renderer.EnqueuePass(grabTransparentPass);

            if (settings.enableRenderPass)
                renderer.EnqueuePass(renderAfterTransparentPass);
        }

        public override void Create()
        {
            if (!settings)
                return;

            renderAfterTransparentPass = new AfterTransparentRenderPass(settings);
            grabTransparentPass = new GrabTransparentPass(settings);
        }


        public class AfterTransparentRenderPass : ScriptableRenderPass
        {
            FilteringSettings filterSettings;
            List<ShaderTagId> shaderTags = new List<ShaderTagId> {
                new ShaderTagId("SRPDefaultUnlit"),
                new ShaderTagId("UniversalForward"),
                new ShaderTagId("UniversalForwardOnly"),
            };

            AfterTransparentRenderSettingSO settings;

            public AfterTransparentRenderPass(AfterTransparentRenderSettingSO settings)
            {
                this.settings = settings;
                //renderPassEvent = RenderPassEvent.AfterRenderingTransparents + 1;
                renderPassEvent = settings.renderPassEvent + settings.renderPassEventOffset;
                filterSettings = new FilteringSettings(RenderQueueRange.all, settings.layer);

                if (settings.additionalLightModes != null)
                {
                    for (int i = 0; i < settings.additionalLightModes.Length; i++)
                    {
                        shaderTags.Add(new ShaderTagId(settings.additionalLightModes[i]));
                    }
                }
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                ref var cameraData = ref renderingData.cameraData;
                var renderer = cameraData.renderer;

                var cmd = CommandBufferPool.Get();
                cmd.BeginSampleExecute(nameof(AfterTransparentRender),ref context);
                //------
#if UNITY_2022_1_OR_NEWER
                //if (renderer.cameraColorTargetHandle == renderer.cameraDepthTargetHandle)
                    cmd.SetRenderTarget(renderer.cameraColorTargetHandle, renderer.cameraDepthTargetHandle);
#else
                //if (renderer.cameraColorTarget == renderer.cameraDepthTarget)
                cmd.SetRenderTarget(renderer.cameraColorTarget, renderer.cameraDepthTarget);
#endif

                if (settings.isClearDepth)
                {
                    cmd.ClearRenderTarget(true, false, Color.clear);
                    cmd.Execute(ref context);
                }

                // create draw settingSO.
                var sortingSettings = new SortingSettings { criteria = SortingCriteria.CommonTransparent };
                var drawingSettings = new DrawingSettings();
                drawingSettings.sortingSettings = sortingSettings;
                drawingSettings.perObjectData = renderingData.perObjectData;
                drawingSettings.mainLightIndex = renderingData.lightData.mainLightIndex;

                for (int i = 0; i < shaderTags.Count; i++)
                {
                    drawingSettings.SetShaderPassName(i, shaderTags[i]);
                }

                context.DrawRenderers(cmd,renderingData.cullResults, ref drawingSettings, ref filterSettings);

                cmd.EndSampleExecute(nameof(AfterTransparentRender), ref context);
                CommandBufferPool.Release(cmd);
            }

        }

        public class GrabTransparentPass : ScriptableRenderPass
        {
            int _BlurTex = Shader.PropertyToID(nameof(_BlurTex));
            RenderTargetIdentifier currentActiveId,opaqueTextureId;

            AfterTransparentRenderSettingSO settings;
            Material blurMat;

            public GrabTransparentPass(AfterTransparentRenderSettingSO settings)
            {
                this.settings = settings;
                //renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
                renderPassEvent = settings.grabPassEvent + settings.grabPassEventOffset;
            }
            public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
            {
                if (settings.applyBlur)
                {
                    SetupBlurTarget(cmd, cameraTextureDescriptor);
                }
            }

            private void SetupBlurTarget(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
            {
                if (!blurMat)
                {
                    var s = Shader.Find("Hidden/PowerVFX/GaussianBlur");
                    if (s)
                        blurMat = new Material(s);
                }

                var w = Mathf.Max(1, cameraTextureDescriptor.width >> settings.opaqueTextureDownSample);
                var h = Mathf.Max(1, cameraTextureDescriptor.height >> settings.opaqueTextureDownSample);

                cmd.GetTemporaryRT(_BlurTex, w, h);
            }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                ref var cameraData = ref renderingData.cameraData;
                var renderer = (UniversalRenderer)cameraData.renderer;
                currentActiveId = renderer.GetRenderTargetId(URPRTHandleNames.m_ActiveCameraColorAttachment);
                opaqueTextureId = renderer.GetRenderTargetId(URPRTHandleNames.m_OpaqueColor);


                var cmd = CommandBufferPool.Get();

                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                cmd.BeginSample(nameof(GrabTransparentPass));

                // execute blur pass
                if (settings.applyBlur && blurMat)
                {
                    blurMat.SetFloat("_Scale", settings.blurScale);
                    cmd.Blit(currentActiveId, _BlurTex, blurMat, 1);

                    //blurMat.SetFloat("_Scale", settingSO.blurRadius*1.2f);
                    cmd.Blit(_BlurTex, opaqueTextureId, blurMat, 2);
                }
                else
                {
                    cmd.Blit(currentActiveId, opaqueTextureId);
                }

                cmd.EndSample(nameof(GrabTransparentPass));
                context.ExecuteCommandBuffer(cmd);

                CommandBufferPool.Release(cmd);
                cmd.Clear();
            }
            public override void FrameCleanup(CommandBuffer cmd)
            {
                cmd.ReleaseTemporaryRT(_BlurTex);
            }
        }
    }
}