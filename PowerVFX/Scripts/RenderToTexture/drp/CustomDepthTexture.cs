using UnityEngine;
using UnityEngine.Rendering;

public class CustomDepthTexture : MonoBehaviour
{
    public RenderTexture depthRT;
    public RenderTexture colorRT;
    public RenderTexture depthTex;

    private CommandBuffer cmd = null;

    private Camera cam = null;

    private void Awake()
    {
        cam = GetComponent<Camera>();

        depthRT = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 24,RenderTextureFormat.Depth);
        depthRT.name = "MainDepthBuffer";
        colorRT = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 0);
        colorRT.name = "MainColorBuffer";

        int Width = cam.pixelWidth;
        int Height = cam.pixelHeight;

        depthTex = new RenderTexture(Width, Height, 0, RenderTextureFormat.RHalf);
        depthTex.name = "SceneDepthTex";

        cmd = new CommandBuffer();
        cmd.name = "CommandBuffer_DepthBuffer";
        cmd.SetRenderTarget(BuiltinRenderTextureType.CameraTarget, depthRT.depthBuffer);
        cmd.Blit(BuiltinRenderTextureType.CurrentActive, colorRT);
        cmd.Blit(depthRT.depthBuffer, depthTex.colorBuffer);
        cmd.SetGlobalTexture("_CameraDepthTexture", depthTex);
        cam.AddCommandBuffer(CameraEvent.AfterSkybox, cmd);

    }

    private void OnDisable()
    {
        if (cam && cmd != null)
            cam.RemoveCommandBuffer(CameraEvent.AfterSkybox, cmd);
    }
}