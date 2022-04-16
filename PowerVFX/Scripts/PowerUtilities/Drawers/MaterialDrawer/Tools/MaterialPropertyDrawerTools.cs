#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEditor;
using UnityEngine;

namespace PowerUtilities
{
    /// <summary>
    /// editor MaterialPropertyDrawer's Tools
    /// </summary>
    public static class MaterialPropertyDrawerTools
    {
        
        public static void SetKeyword(MaterialProperty prop, string keyword, bool isKeywordOn)
        {
            var mats = prop.targets.Select(t => (Material)t);
            foreach (var mat in mats)
            {
                if (isKeywordOn)
                    mat.EnableKeyword(keyword);
                else
                    mat.DisableKeyword(keyword);
            }
        }

        public static float DrawRemapSlider(Rect position, Vector2 range, string label, float value)
        {
            float v = EditorGUI.Slider(position, label, Mathf.InverseLerp(range.x, range.y, value), 0, 1);
            return Mathf.Lerp(range.x, range.y, v);
        }
    }
}
#endif