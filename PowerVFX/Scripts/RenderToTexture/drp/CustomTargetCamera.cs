namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using System.IO;
    using UnityEngine;
    using UnityEngine.Rendering;
#if UNITY_EDITOR
    using UnityEditor;

    [CustomEditor(typeof(CustomTargetCamera))]
    public class CustomTargetCameraEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            var inst = target as CustomTargetCamera;

            GUILayout.BeginHorizontal("Box");

            if (GUILayout.Button("Save DepthTex"))
            {
                inst.OutputBuffer(inst.depthTex, "DepthTex");
            }
            if (GUILayout.Button("Save ColorTex"))
            {
                inst.OutputBuffer(inst.colorTex, "ColorTex");
            }
            GUILayout.EndHorizontal();
        }
    }
#endif

    public class CustomTargetCamera : MonoBehaviour
    {
        [Header("Texture")]
        public RenderTexture colorTex;
        public RenderTexture depthTex;

        [Header("RenderTarget")]
        public RenderTexture depthRT;
        public RenderTexture colorRT;

        [Header("Shader Names")]
        public string _CameraDepthTexture = nameof(_CameraDepthTexture);
        public string _CameraOpaqueTexture = nameof(_CameraOpaqueTexture);

        [Header("Options")]
        public bool runOneTime;

        CommandBuffer cmd;
        Camera cam;

        int startCount = 0;
        int renderFrameCount = 0, lastRenderFrameCount;

        void OnEnable()
        {
            if (startCount > 0)
            {
                ReleaseBuffers();
                ReleaseCmd();
            }

            cam=GetComponent<Camera>();
            var w = cam.pixelWidth;
            var h = cam.pixelHeight;

            colorTex = new RenderTexture(w, h, 0, RenderTextureFormat.RGB111110Float);
            depthTex = new RenderTexture(w, h, 0, RenderTextureFormat.RHalf);

            depthRT = new RenderTexture(w, h, 24, RenderTextureFormat.Depth);
            colorRT = new RenderTexture(w, h, 0, RenderTextureFormat.RGB111110Float);

            cmd = new CommandBuffer { name="blit frame buffer" };
            cmd.BeginSample(cmd.name);
            cmd.Blit(colorRT.colorBuffer, colorTex.colorBuffer);
            cmd.Blit(depthRT.depthBuffer, depthTex.colorBuffer);
            cmd.SetGlobalTexture(_CameraDepthTexture, depthTex);
            cmd.SetGlobalTexture(_CameraOpaqueTexture, colorTex);

            cmd.EndSample(cmd.name);

            cam.AddCommandBuffer(CameraEvent.AfterSkybox, cmd);

            startCount++;
        }

        public void OutputBuffer(RenderTexture rt, string fileName)
        {
            var lastRT = RenderTexture.active;
            RenderTexture.active = rt;
            var tex = new Texture2D(rt.width, rt.height, TextureFormat.ARGB32, false);
            tex.ReadPixels(new Rect(0, 0, tex.width, tex.height), 0, 0);
            RenderTexture.active = lastRT;
            tex.Apply();
            var bytes = tex.EncodeToJPG();

            var path = "Assets/OutputFrames";
#if UNITY_EDITOR
            if (!AssetDatabase.IsValidFolder(path))
            {
                AssetDatabase.CreateFolder("Assets", "OutputFrames");
            }
#endif

            path = $"{Application.dataPath}/OutputFrames/{fileName}.png";
            File.WriteAllBytes(path, bytes);
        }

        private void Update()
        {
            Shader.SetGlobalTexture(_CameraDepthTexture, depthTex);
            Shader.SetGlobalTexture(_CameraOpaqueTexture, colorTex);

        }

        private void OnPreRender()
        {
            cam.SetTargetBuffers(colorRT.colorBuffer, depthRT.depthBuffer);
        }

        private void OnPostRender()
        {
            Graphics.Blit(colorRT, (RenderTexture)null);

            if (runOneTime && renderFrameCount - lastRenderFrameCount > 1)
            {
                lastRenderFrameCount = renderFrameCount;
                runOneTime = false;

                ReleaseCmd();
                ReleaseBuffers(false);
                //cam.SetTargetBuffers(lastColorBuffer, lastDepthBuffer);
            }
            renderFrameCount++;
        }


        private void OnDestroy()
        {
            ReleaseCmd();
            ReleaseBuffers();
        }

        private void ReleaseBuffers(bool releaseTexs = true)
        {
            if (colorRT) colorRT.Release();
            if (depthRT) depthRT.Release();

            if (releaseTexs)
            {
                if (colorTex) colorTex.Release();
                if (depthTex) depthTex.Release();
            }
        }

        private void ReleaseCmd()
        {
            if (cmd != null)
            {
                cam.RemoveCommandBuffer(CameraEvent.AfterSkybox, cmd);
            }
        }
    }
}