using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class BlitFrameBufferToTexture : MonoBehaviour
{
    #if UNITY_2018_3_OR_NEWER
    [Header("Buffer Textures")]
    [SerializeField] RenderTexture colorRT;
    [SerializeField] RenderTexture depthRT;

    [Header("Shader Names")]
    public string colorTextureName = "_CameraOpaqueTexture";
    public string depthTextureName = "_CameraDepthTexture";

    [Header("Color Texture")]
    public bool isBlitColorTexture = true;
    CameraEvent blitEvent = CameraEvent.AfterSkybox;

    [Header("Depth Texture")]
    public bool isBlitDepthTexture = true;

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
            cmd.SetGlobalTexture(colorTextureName, colorRT);
        }

        if (isBlitDepthTexture)
        {
            depthRT = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 0);
            cmd.Blit(BuiltinRenderTextureType.Depth, depthRT);
            cmd.SetGlobalTexture(depthTextureName, depthRT);
        }


        cam.AddCommandBuffer(blitEvent, cmd);
    }

    private void OnDestroy()
    {
        if(colorRT)
            colorRT.Release();
        if (depthRT)
            depthRT.Release();

        if (!cam || cmd == null)
            return;

        cam.RemoveCommandBuffer(blitEvent, cmd);
        cmd.Release();
    }

#endif
}
