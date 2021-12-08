#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using System.Linq;
using System;

namespace PowerVFX
{
    //UnityEngine.Rendering.BlendMode
    public enum PresetBlendMode
    {
        Normal,
        AlphaBlend,
        SoftAdd,
        Add,
        PremultiTransparent,
        MultiColor,
        MultiColor_2X
    }

    public class PowerShaderInspector : ShaderGUI
    {
        // events
        public event Action<MaterialProperty, Material> OnDrawProperty;
        public event Action<Dictionary<string, MaterialProperty> ,Material> OnDrawPropertyFinish;

        // properties
        const string SRC_MODE = "_SrcMode", DST_MODE = "_DstMode";
        public string shaderName = ""; //子类来指定,用于EditorPrefs读写
        public int AlphaTabId = 0;  // preset blend mode 显示在 号tab页
        public int RenderQueueTabId = 0; // render Queue显示的tab页码

        string[] tabNames;
        List<string[]> propNameList = new List<string[]>();
        string materialSelectedId => shaderName + "_SeletectedId";
        string materialToolbarCount => shaderName + "_ToolbarCount";

        int selectedTabId;
        bool showOriginalPage;

        Dictionary<PresetBlendMode, BlendMode[]> blendModeDict;
        Dictionary<string, MaterialProperty> propDict;
        Dictionary<string, string> propNameTextDict;

        bool isFirstRunOnGUI = true;
        string helpStr;
        string[] tabNamesInConfig;

        Shader lastShader;

        MaterialEditor materialEditor;
        MaterialProperty[] materialProperties;
        PresetBlendMode presetBlendMode;
        int languageId;
        int renderQueue = 2000;
        int toolbarCount = 5;

        public PowerShaderInspector()
        {
            blendModeDict = new Dictionary<PresetBlendMode, BlendMode[]> {
                {PresetBlendMode.Normal,new []{ BlendMode.One,BlendMode.Zero} },
                {PresetBlendMode.AlphaBlend,new []{ BlendMode.SrcAlpha,BlendMode.OneMinusSrcAlpha} },
                {PresetBlendMode.SoftAdd,new []{ BlendMode.SrcAlpha, BlendMode.One} }, //OneMinusDstColor
                {PresetBlendMode.Add,new []{ BlendMode.One,BlendMode.One} },
                {PresetBlendMode.PremultiTransparent,new []{BlendMode.One,BlendMode.OneMinusSrcAlpha } },
                {PresetBlendMode.MultiColor,new []{ BlendMode.DstColor,BlendMode.Zero} },
                {PresetBlendMode.MultiColor_2X,new []{ BlendMode.DstColor,BlendMode.SrcColor} },
            };
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            this.materialEditor = materialEditor;
            materialProperties = properties;

            var mat = materialEditor.target as Material;
            propDict = ConfigTool.CacheProperties(properties);

            if (isFirstRunOnGUI || lastShader != mat.shader)
            {
                lastShader = mat.shader;

                isFirstRunOnGUI = false;
                OnInit(mat, properties);
            }
            // title
            EditorGUILayout.HelpBox(helpStr, MessageType.Info);

            //show original
            showOriginalPage = GUILayout.Toggle(showOriginalPage, ConfigTool.Text(propNameTextDict, "ShowOriginalPage"));
            if (showOriginalPage)
            {
                base.OnGUI(materialEditor, properties);
                return;
            }

            EditorGUILayout.BeginVertical("Box");
            {
                DrawPageTabs();

                EditorGUILayout.BeginVertical("Box");
                DrawPageDetail(materialEditor, mat);
                EditorGUILayout.EndVertical();
            }
            EditorGUILayout.EndVertical();
        }

        /// <summary>
        /// draw properties
        /// </summary>
        private void DrawPageDetail(MaterialEditor materialEditor, Material mat)
        {
            const string WARNING_NO_DETAIL = "No Details";
            if(selectedTabId >= propNameList.Count)
            {
                EditorGUILayout.HelpBox(WARNING_NO_DETAIL, MessageType.Warning, true);
                return;
            }

            // content's tab 
            EditorGUILayout.HelpBox(tabNames[selectedTabId], MessageType.Warning,true);

            // contents
            var propNames = propNameList[selectedTabId];
            foreach (var propName in propNames)
            {
                if (!propDict.ContainsKey(propName))
                    continue;

                var prop = propDict[propName];
                materialEditor.ShaderProperty(prop, ConfigTool.Text(propNameTextDict, prop.name));

                if (OnDrawProperty != null)
                    OnDrawProperty(prop, mat);
            }
            // blend 
            if (IsTargetShader(mat))
            {
                if (selectedTabId == AlphaTabId)
                    DrawBlendMode(mat);
                if (selectedTabId == RenderQueueTabId)
                {
                    // render queue, instanced, double sided gi
                    DrawMaterialProps(mat);
                }
            }

            if (OnDrawPropertyFinish != null)
                OnDrawPropertyFinish(propDict, mat);
        }


        private bool IsTargetShader(Material mat)
        {
            return mat.shader.name.Contains(shaderName);
        }

        private void DrawPageTabs()
        {
            // read from cache
            selectedTabId = EditorPrefs.GetInt(materialSelectedId, selectedTabId);
            if (selectedTabId >= tabNamesInConfig.Length)
                selectedTabId = 0;

            toolbarCount = EditorPrefs.GetInt(materialToolbarCount, tabNamesInConfig.Length);
            
            // draw 
            GUILayout.BeginVertical("Box");
            toolbarCount = EditorGUILayout.IntSlider("ToolbarCount:",toolbarCount, 3, tabNamesInConfig.Length);
            selectedTabId = GUILayout.SelectionGrid(selectedTabId, tabNamesInConfig, toolbarCount, EditorStyles.miniButton);
            GUILayout.EndVertical();

            //cache selectedId
            EditorPrefs.SetInt(materialSelectedId, selectedTabId);
            EditorPrefs.SetInt(materialToolbarCount, toolbarCount);
        }

        private void OnInit(Material mat, MaterialProperty[] properties)
        {
            if (IsTargetShader(mat))
                presetBlendMode = GetPresetBlendMode(mat);

            var shaderFilePath = AssetDatabase.GetAssetPath(mat.shader);
            SetupLayout(shaderFilePath);

            propNameTextDict = ConfigTool.ReadI18NConfig(shaderFilePath);

            helpStr = ConfigTool.Text(propNameTextDict, "Help").Replace('|', '\n');

            tabNamesInConfig = tabNames.Select(item => ConfigTool.Text(propNameTextDict, item)).ToArray();
        }

        private void SetupLayout(string shaderFilePath)
        {
            var layoutConfigPath = ConfigTool.FindPathRecursive(shaderFilePath, ConfigTool.LAYOUT_PROFILE_PATH);
            var dict = ConfigTool.ReadKeyValueConfig(layoutConfigPath);

            if (!dict.TryGetValue("tabNames", out var tabNamesLine))
                return;

            // for tabNames
            tabNames = ConfigTool.SplitBy(tabNamesLine);

            // for tab contents
            propNameList.Clear();
            for (int i = 0; i < tabNames.Length; i++)
            {
                var tabName = tabNames[i];
                if (!dict.ContainsKey(tabName))
                    continue;

                var propNamesLine = dict[tabName];
                var propNames = ConfigTool.SplitBy(propNamesLine);
                propNameList.Add(propNames);
            }
        }

        void DrawBlendMode(Material mat)
        {
            EditorGUI.BeginChangeCheck();
            GUILayout.BeginVertical();
            EditorGUILayout.Space(10);
            GUILayout.Label("Alpha Blend", EditorStyles.boldLabel);
            presetBlendMode = (PresetBlendMode)EditorGUILayout.EnumPopup(ConfigTool.Text(propNameTextDict, "PresetBlendMode"), presetBlendMode);
            GUILayout.EndVertical();
            if (EditorGUI.EndChangeCheck())
            {
                var blendModes = blendModeDict[presetBlendMode];

                mat.SetFloat(SRC_MODE, (int)blendModes[0]);
                mat.SetFloat(DST_MODE, (int)blendModes[1]);
            }
        }

        void DrawMaterialProps(Material mat)
        {
            GUILayout.BeginVertical();
            EditorGUILayout.Space(10);

            GUILayout.Label("Material Props",EditorStyles.boldLabel);
            //mat.renderQueue = EditorGUILayout.IntField(ConfigTool.Text(propNameTextDict, "RenderQueue"), mat.renderQueue);
            materialEditor.RenderQueueField();
            materialEditor.EnableInstancingField();
            materialEditor.DoubleSidedGIField();

            GUILayout.EndVertical();
        }

        PresetBlendMode GetPresetBlendMode(BlendMode srcMode, BlendMode dstMode)
        {
            return blendModeDict.Where(kv => kv.Value[0] == srcMode && kv.Value[1] == dstMode).FirstOrDefault().Key;
        }

        PresetBlendMode GetPresetBlendMode(Material mat)
        {
            var srcMode = mat.GetInt(SRC_MODE);
            var dstMode = mat.GetInt(DST_MODE);
            return GetPresetBlendMode((BlendMode)srcMode, (BlendMode)dstMode);
        }
    }
}


#endif