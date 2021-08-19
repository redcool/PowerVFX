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
    public CameraEvent blitColorEvent = CameraEvent.AfterForwardOpaque;

    [Header("Depth Texture")]
    [Tooltip("mobile need depth mode at least")]
    public bool isBlitDepthTexture = true;
    public CameraEvent blitDepthEvent = CameraEvent.AfterForwardOpaque;


    //public DepthTextureMode camDepthTextureMode;

    Camera cam;
    CommandBuffer blitColorBuf, blitDepthBuf;

    // Start is called before the first frame update
    void Start()
    {
        cam = GetComponent<Camera>();
        //cam.depthTextureMode = camDepthTextureMode;

        if (isBlitColorTexture)
        {
            colorRT = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 0);

            blitColorBuf = CreateBlitBuffer("Blit Color", BuiltinRenderTextureType.CurrentActive, colorRT, colorTextureName, cam, blitColorEvent);
        }

        if (isBlitDepthTexture)
        {
            depthRT = new RenderTexture(cam.pixelWidth, cam.pixelHeight, 0);

            blitDepthBuf = CreateBlitBuffer("Blit Depth", BuiltinRenderTextureType.Depth, depthRT, depthTextureName, cam, blitDepthEvent);
        }
    }



    private void OnDestroy()
    {
        ReleaseCommandBuffer(cam, blitColorEvent, blitColorBuf);
        ReleaseCommandBuffer(cam, blitDepthEvent, blitDepthBuf);
    }

    public static CommandBuffer CreateBlitBuffer(string bufferName, RenderTargetIdentifier srcId, RenderTargetIdentifier dstId, string globalShaderName, Camera cam, CameraEvent cameraEvent)
    {
        if (!cam)
            return null;

        var cmd = new CommandBuffer { name = bufferName };
        cmd.Blit(srcId, dstId);
        cmd.SetGlobalTexture(globalShaderName, dstId);
        cam.AddCommandBuffer(cameraEvent, cmd);
        return cmd;
    }
    public static void ReleaseCommandBuffer(Camera cam,CameraEvent cameraEvent,CommandBuffer buf)
    {
        if (buf == null || !cam)
            return;
        cam.RemoveCommandBuffer(cameraEvent, buf);
        buf.Dispose();
    }
#endif
}
