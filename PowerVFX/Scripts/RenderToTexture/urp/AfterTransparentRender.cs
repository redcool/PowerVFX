using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
namespace PowerUtilities
{
    public class AfterTransparentRender : ScriptableRendererFeature
    {
        [Serializable]
        public class Settings
        {
            [Header("Grab Pass")]
            public bool enableGrabPass = true;
            public RenderPassEvent grabPassEvent = RenderPassEvent.AfterRenderingTransparents;
            public int grabPassEventOffset = 0;

            [Header("CameraOpaqueTexture")]
            public string opaqueTextureName = "_CameraOpaqueTexture";
            [Range(0, 4)] public int opaqueTextureDownSample = 3;

            public bool applyBlur;
            [Range(0.01f, 1f)] public float blurScale = 0.5f;

            [Header("Render Pass")]
            public bool enableRenderPass = true;
            public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
            public int renderPassEventOffset = 1;
            public string[] additionalLightModes;

            public LayerMask layer = 0;
        }

        [SerializeField] Settings settings = new Settings();
        AfterTransparentRenderPass renderAfterTransparentPass;
        GrabTransparentPass grabTransparentPass;
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            grabTransparentPass.cameraColorTarget = renderer.cameraColorTarget;

            if (settings.enableGrabPass)
                renderer.EnqueuePass(grabTransparentPass);

            if (settings.enableRenderPass)
                renderer.EnqueuePass(renderAfterTransparentPass);
        }

        public override void Create()
        {
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

            public AfterTransparentRenderPass(Settings settings)
            {
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
                // create draw settings.
                var sortingSettings = new SortingSettings { criteria = SortingCriteria.CommonTransparent };
                var drawingSettings = new DrawingSettings();
                drawingSettings.sortingSettings = sortingSettings;
                drawingSettings.perObjectData = renderingData.perObjectData;
                drawingSettings.mainLightIndex = renderingData.lightData.mainLightIndex;

                for (int i = 0; i < shaderTags.Count; i++)
                {
                    drawingSettings.SetShaderPassName(i, shaderTags[i]);
                }

                // or call CreateDrawingSettings
                //var drawingSettings = CreateDrawingSettings(ShaderTagId.none, ref renderingData, SortingCriteria.CommonTransparent);
                context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filterSettings);
            }

        }

        public class GrabTransparentPass : ScriptableRenderPass
        {
            Settings settings;
            RenderTargetHandle targetTextureHandle;

            int _BlurTex = Shader.PropertyToID("_BlurTex");
            Material blurMat;


            public RenderTargetIdentifier cameraColorTarget;

            public GrabTransparentPass(Settings settings)
            {
                this.settings = settings;
                //renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
                renderPassEvent = settings.grabPassEvent + settings.grabPassEventOffset;
                targetTextureHandle.Init(settings.opaqueTextureName);
            }
            public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
            {
                if (!blurMat)
                {
                    var s = Shader.Find("Hidden/GaussianBlur");
                    if (s)
                        blurMat = new Material(s);
                }

                var w = Mathf.Max(1, cameraTextureDescriptor.width >> settings.opaqueTextureDownSample);
                var h = Mathf.Max(1, cameraTextureDescriptor.height >> settings.opaqueTextureDownSample);

                cmd.GetTemporaryRT(targetTextureHandle.id, w, h, cameraTextureDescriptor.depthBufferBits, FilterMode.Bilinear);
                cmd.SetGlobalTexture(targetTextureHandle.id, targetTextureHandle.Identifier());

                cmd.GetTemporaryRT(_BlurTex, w, h);
            }
            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                var cmd = CommandBufferPool.Get();

                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                cmd.BeginSample(nameof(GrabTransparentPass));

                Blit(cmd, cameraColorTarget, targetTextureHandle.id);

                // execute blur pass
                if (settings.applyBlur && blurMat)
                {
                    blurMat.SetFloat("_Scale", settings.blurScale);
                    Blit(cmd, targetTextureHandle.id, _BlurTex, blurMat, 1);

                    //blurMat.SetFloat("_Scale", settings.blurRadius*1.2f);
                    Blit(cmd, _BlurTex, targetTextureHandle.id, blurMat, 2);
                }

                cmd.EndSample(nameof(GrabTransparentPass));
                context.ExecuteCommandBuffer(cmd);

                CommandBufferPool.Release(cmd);
                cmd.Clear();
            }
            public override void FrameCleanup(CommandBuffer cmd)
            {
                cmd.ReleaseTemporaryRT(targetTextureHandle.id);
                cmd.ReleaseTemporaryRT(_BlurTex);
            }
        }
    }
}