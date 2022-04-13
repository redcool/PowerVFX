#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace PowerPBS{
    /// <summary>
    /// Toggle, no Keyword
    /// </summary>
    public class LiteToggle : MaterialPropertyDrawer
    {
        const char SEPARATOR = ',';
        string[] keywords;
        public LiteToggle()
        {

        }
        public LiteToggle(string keywordsLine)
        {
            if (string.IsNullOrWhiteSpace(keywordsLine))
                return;

            keywords = keywordsLine.
                Split(SEPARATOR).
                Select(item=> item.Trim()).
                Where(item => !string.IsNullOrWhiteSpace(item)).
                ToArray();
        }
        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            bool value = prop.floatValue != 0;
            EditorGUI.BeginChangeCheck();

            EditorGUI.showMixedValue = prop.hasMixedValue;
            value = EditorGUI.Toggle(position, label, value);
            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck())
            {
                prop.floatValue = value ? 1 : 0;

                EnableKeywords(prop, keywords, value);
            }
        }

        void EnableKeywords(MaterialProperty prop,string[] keywords,bool enabled)
        {
            if (keywords == null || keywords.Length == 0)
                return;

            foreach (var item in prop.targets)
            {
                var mat = item as Material;
                foreach (var keyword in keywords)
                {
                    if(mat.IsKeywordEnabled(keyword) != enabled)
                    {
                        if (enabled)
                        {
                            mat.EnableKeyword(keyword);
                        }
                        else
                        {
                            mat.DisableKeyword(keyword);
                        }
                    }
                }
            }
        }
    }
}
#endif