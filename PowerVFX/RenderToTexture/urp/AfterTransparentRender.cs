using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class AfterTransparentRender : ScriptableRendererFeature
{
    [Serializable]
    public class Settings
    {
        public LayerMask layer;
        public string opaqueTextureName = "_CameraOpaqueTexture";
    }

    [SerializeField]Settings settings;
    AfterTransparentRenderPass renderAfterTransparentPass;
    GrabTransparentPass grabTransparentPass;
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        grabTransparentPass.cameraColorTarget = renderer.cameraColorTarget;

        renderer.EnqueuePass(grabTransparentPass);
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
            renderPassEvent = RenderPassEvent.AfterRenderingTransparents + 1;
            filterSettings = new FilteringSettings(RenderQueueRange.all, settings.layer);
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
        public RenderTargetIdentifier cameraColorTarget;

        public GrabTransparentPass(Settings settings)
        {
            this.settings = settings;
            renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
            targetTextureHandle.Init(settings.opaqueTextureName);
        }
        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            cmd.GetTemporaryRT(targetTextureHandle.id, cameraTextureDescriptor);
            cmd.SetGlobalTexture(targetTextureHandle.id, targetTextureHandle.Identifier());
        }
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var cmd = CommandBufferPool.Get();
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            Blit(cmd, cameraColorTarget, targetTextureHandle.id);
            context.ExecuteCommandBuffer(cmd);

            CommandBufferPool.Release(cmd);
            cmd.Clear();
        }
        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(targetTextureHandle.id);
        }
    }
}
