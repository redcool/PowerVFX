using System;
using UnityEngine;
using UnityEngine.Rendering.Universal;
namespace PowerUtilities
{
    [Serializable]
    public class AfterTransparentRenderSettingSO : ScriptableObject
    {
        [Header("Options")]
        public string gameCameraTag = "MainCamera";

        [Header("Grab Pass")]
        [Tooltip("Blit CameraColorTarget to _CameraOpaqueTexture,can holding transparent objects")]
        public bool enableGrabPass = true;
        public RenderPassEvent grabPassEvent = RenderPassEvent.AfterRenderingTransparents;
        public int grabPassEventOffset = 0;

        [Header("Grab Pass Blur")]
        public bool applyBlur;
        [Range(0, 4)] public int opaqueTextureDownSample = 3;
        [Range(0.01f, 1f)] public float blurScale = 0.5f;

        [Header("Render Pass")]
        [Tooltip("render objects after grabpass, then can use new _CameraOpaqueTexture")]
        public bool enableRenderPass = true;
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
        public int renderPassEventOffset = 1;
        public bool isClearDepth;
        public string[] additionalLightModes;

        public LayerMask layer = 0;
    }
}