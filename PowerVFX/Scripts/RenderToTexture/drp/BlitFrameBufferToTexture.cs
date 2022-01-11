using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class BlitFrameBufferToTexture : MonoBehaviour
{
    [Header("Buffer Textures")]
    [SerializeField] RenderTexture colorRT;
    [SerializeField] RenderTexture depthRT;
    [SerializeField] RenderTexture depthTex;

    [Header("Shader Variables Names")]
    public string _CameraOpaqueTexture = "_CameraOpaqueTexture";
    public string _CameraDepthTexture = "_CameraDepthTexture";

    [Header("Blit Options")]
    public bool isBlitColorTexture = true;
    public bool isBlitDepthTexture = true;
    CameraEvent blitEvent = CameraEvent.AfterSkybox;

    Camera cam;
    CommandBuffer cmd;

    // Start is called before the first frame update
    void Start()
    {
        cam = GetComponent<Camera>();
        if (!cam)
            return;

        

        cmd = new CommandBuffer { name = nameof(BlitFrameBufferToTexture) };
        if (isBlitColorTexture)
        {
            colorRT = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 0);
            cmd.Blit(BuiltinRenderTextureType.CurrentActive, colorRT);
            cmd.SetGlobalTexture(_CameraOpaqueTexture, colorRT);
        }

        if (isBlitDepthTexture)
        {
            depthTex = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 0);
            depthRT = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 24,RenderTextureFormat.Depth);
            //cmd.SetRenderTarget(BuiltinRenderTextureType.CameraTarget, depthRT);
            cmd.Blit(BuiltinRenderTextureType.Depth, depthRT.depth);


            cmd.Blit(depthRT.depthBuffer, depthTex.colorBuffer);
            cmd.SetGlobalTexture(_CameraDepthTexture, depthTex);
        }

        Graphics.ExecuteCommandBuffer(cmd);
        cam.AddCommandBuffer(blitEvent, cmd);
    }

    private void OnDestroy()
    {
        if (colorRT)
            colorRT.Release();
        if (depthRT)
            depthRT.Release();

        if (!cam || cmd == null)
            return;

        cam.RemoveCommandBuffer(blitEvent, cmd);

        //cmd.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
        //Graphics.ExecuteCommandBuffer(cmd);

        cmd.Release();
    }

}
