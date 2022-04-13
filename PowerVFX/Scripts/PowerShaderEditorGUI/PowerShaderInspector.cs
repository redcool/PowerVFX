#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using System.Linq;
using System;

namespace PowerUtilities
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

    /// <summary>
    /// 管理材质上代码绘制的属性
    /// </summary>
    public class MaterialCodeProps {
        public const string _PresetBlendMode = "_PresetBlendMode",
            _RenderQueue = "_RenderQueue";

        public bool hasPresetBlendMode,
            hasRenderQueue;

        public void Clear()
        {
            hasPresetBlendMode = hasRenderQueue = false;
        }

        private MaterialCodeProps() { }
        private static MaterialCodeProps instance;

        public static MaterialCodeProps Instance
        {
            get
            {
                if (instance == null)
                    instance = new MaterialCodeProps();
                return instance;
            }
        }

        public void InitMaterialCodeVars(string propName)
        {
            switch (propName)
            {
                case _PresetBlendMode: instance.hasPresetBlendMode = true; break;
                case _RenderQueue: instance.hasRenderQueue = true; break;
            }
        }
    }


    public class PowerShaderInspector : ShaderGUI
    {
        // events
        public event Action<MaterialProperty, Material> OnDrawProperty;
        public event Action<Dictionary<string, MaterialProperty> ,Material> OnDrawPropertyFinish;

        // properties
        const string SRC_MODE = "_SrcMode", DST_MODE = "_DstMode";

        public string shaderName = ""; //子类来指定,用于EditorPrefs读写

        string[] tabNames;
        bool[] tabToggles;
        List<int> tabSelectedIds = new List<int>();

        List<string[]> propNameList = new List<string[]>();
        string materialSelectedId => shaderName + "_SeletectedId";
        string materialToolbarCount => shaderName + "_ToolbarCount";

        string GetMaterialSelectionIdKey(string matName)
        {
            return matName + shaderName + "_SeletectedId";
        }

        //int selectedTabId;
        bool showOriginalPage;

        Dictionary<PresetBlendMode, BlendMode[]> blendModeDict;
        Dictionary<string, MaterialProperty> propDict;
        Dictionary<string, string> propNameTextDict;
        Dictionary<string, string> colorTextDict;

        bool isFirstRunOnGUI = true;
        string helpStr;
        string[] tabNamesInConfig;

        Shader lastShader;

        MaterialEditor materialEditor;
        PresetBlendMode presetBlendMode;
        int toolbarCount = 5;

        Color defaultContentColor;


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

            var mat = materialEditor.target as Material;
            propDict = ConfigTool.CacheProperties(properties);

            if (isFirstRunOnGUI || lastShader != mat.shader)
            {
                lastShader = mat.shader;

                defaultContentColor = GUI.contentColor;
                isFirstRunOnGUI = false;
                OnInit(mat, properties);
            }

            // title
            if(!string.IsNullOrEmpty(helpStr))
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
                DrawPageDetails(materialEditor, mat);
                EditorGUILayout.EndVertical();
            }
            EditorGUILayout.EndVertical();
        }



        /// <summary>
        /// draw properties
        /// </summary>
        private void DrawPageDetail(MaterialEditor materialEditor, Material mat,string tabName,string[] propNames)
        {
            const string WARNING_NO_DETAIL = "No Details";
            if(propNames == null || propNames.Length == 0)
            {
                EditorGUILayout.HelpBox(WARNING_NO_DETAIL, MessageType.Warning, true);
                return;
            }

            // content's tab 
            EditorGUILayout.HelpBox(tabName, MessageType.Info, true);

            MaterialCodeProps.Instance.Clear();
            // contents

            foreach (var propName in propNames)
            {
                MaterialCodeProps.Instance.InitMaterialCodeVars(propName);

                if (!propDict.ContainsKey(propName))
                    continue;

                // found color
                var contentColor = defaultContentColor;
                string colorString;
                if (colorTextDict.TryGetValue(propName, out colorString))
                {
                    ColorUtility.TryParseHtmlString(colorString, out contentColor);
                }
                //show color
                GUI.contentColor = contentColor;
                var prop = propDict[propName];
                materialEditor.ShaderProperty(prop, ConfigTool.Text(propNameTextDict, prop.name));

                GUI.contentColor = defaultContentColor;

                if (OnDrawProperty != null)
                    OnDrawProperty(prop, mat);
            }
            // blend 
            if (IsTargetShader(mat))
            {
                if (MaterialCodeProps.Instance.hasPresetBlendMode)
                    DrawBlendMode(mat);

                if (MaterialCodeProps.Instance.hasRenderQueue)
                {
                    // render queue, instanced, double sided gi
                    DrawMaterialProps(mat);
                }
            }

            if (OnDrawPropertyFinish != null)
                OnDrawPropertyFinish(propDict, mat);
        }

        void DrawPageDetails(MaterialEditor materialEditor, Material mat)
        {
            if (tabSelectedIds.Count == 0) {
                EditorGUILayout.LabelField("No Selected");
            }
            foreach (var tabId in tabSelectedIds)
            {
                var tabName = tabNames[tabId];
                var propNames = propNameList[tabId];

                DrawPageDetail(materialEditor, mat, tabName, propNames);
            }
        }


        private bool IsTargetShader(Material mat)
        {
            return mat.shader.name.Contains(shaderName);
        }
        void ReadFromCache()
        {
            // read from cache
            tabSelectedIds.Clear();
            EditorPrefTools.GetList(GetMaterialSelectionIdKey(materialEditor.target.name), ref tabSelectedIds, ",", (idStr) => Convert.ToInt32(idStr));

            foreach (var selectedId in tabSelectedIds)
            {
                tabToggles[selectedId] = true;
            }

            toolbarCount = EditorPrefs.GetInt(materialToolbarCount, tabNamesInConfig.Length);
        }

        void SaveToCache()
        {
            //cache selectedId
            //EditorPrefs.SetInt(materialSelectedId, selectedTabId);
            EditorPrefTools.SetList(GetMaterialSelectionIdKey(materialEditor.target.name), tabSelectedIds, ",");
            EditorPrefs.SetInt(materialToolbarCount, toolbarCount);
        }

        private void DrawPageTabs()
        {
            ReadFromCache();

            // draw 
            GUILayout.BeginVertical("Box");
            toolbarCount = EditorGUILayout.IntSlider("ToolbarCount:", toolbarCount, 3, tabNamesInConfig.Length);
            //selectedTabId = GUILayout.SelectionGrid(selectedTabId, tabNamesInConfig, toolbarCount, EditorStyles.miniButton);
            EditorGUITools.MultiSelectionGrid(tabNamesInConfig, tabToggles, tabSelectedIds, toolbarCount);
            GUILayout.EndVertical();

            SaveToCache();
        }

        private void OnInit(Material mat, MaterialProperty[] properties)
        {
            if (IsTargetShader(mat))
                presetBlendMode = GetPresetBlendMode(mat);

            var shaderFilePath = AssetDatabase.GetAssetPath(mat.shader);
            SetupLayout(shaderFilePath);

            propNameTextDict = ConfigTool.ReadConfig(shaderFilePath, ConfigTool.I18N_PROFILE_PATH);

            helpStr = ConfigTool.Text(propNameTextDict, "Help").Replace('|', '\n');

            tabNamesInConfig = tabNames.Select(item => ConfigTool.Text(propNameTextDict, item)).ToArray();
            tabToggles = new bool[tabNamesInConfig.Length];

            colorTextDict = ConfigTool.ReadConfig(shaderFilePath, ConfigTool.COLOR_PROFILE_PATH);
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