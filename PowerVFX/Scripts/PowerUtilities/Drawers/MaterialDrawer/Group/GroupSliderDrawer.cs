#if UNITY_EDITOR
namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using UnityEditor;
    using System.Linq;
    using System;

    /// <summary>
    /// Draw a ramap slider in (or not in) group .
    /// 
    /// material ui slider range is [0,1]
    /// </summary>
    public class GroupSliderDrawer : BaseGroupItemDrawer
    {
        public GroupSliderDrawer(string groupName) : base(groupName) { }

        public override void DrawGroupUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            if(prop.type != MaterialProperty.PropType.Range)
            {
                EditorGUI.LabelField(position, $"{label} not range");
                return;
            }
            EditorGUIUtility.labelWidth = MaterialGroupTools.BASE_LABLE_WIDTH;

            EditorGUI.BeginChangeCheck();
            var value = prop.floatValue;
            value = MaterialPropertyDrawerTools.DrawRemapSlider(position, prop.rangeLimits, label.text, value);
            if (EditorGUI.EndChangeCheck())
            {
                prop.floatValue = value;
            }
        }
    }
}
#endif