#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace PowerUtilities
{

    public class GroupHeaderDecorator : BaseGroupItemDrawer
    {
        string header;
        public GroupHeaderDecorator(string header):this("",header) { }
        public GroupHeaderDecorator(string groupName, string header):base(groupName)
        {
            this.header = $"--------{header}--------";
        }

        public override void DrawGroupUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            position = EditorGUI.IndentedRect(position);
            EditorGUI.DropShadowLabel(position, header, EditorStyles.boldLabel);
        }
    }
}
#endif