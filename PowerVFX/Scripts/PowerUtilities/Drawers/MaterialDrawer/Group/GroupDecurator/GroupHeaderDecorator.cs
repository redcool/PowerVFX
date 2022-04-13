#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace PowerUtilities
{

    public class GroupHeaderDecorator : MaterialPropertyDrawer
    {
        string groupName, header;
        public GroupHeaderDecorator(string groupName, string header)
        {
            this.groupName = groupName;
            this.header = $"--------{header}--------";
        }


        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            if(!MaterialGroupTools.IsGroupOn(groupName))
                return;

            var indentLevel = string.IsNullOrEmpty(groupName) ? 0 : 1;
            EditorGUI.indentLevel += indentLevel;

            //position.y += 8;
            position = EditorGUI.IndentedRect(position);
            EditorGUI.DropShadowLabel(position, header, EditorStyles.boldLabel);

            EditorGUI.indentLevel -= indentLevel;
        }
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return MaterialGroupTools.IsGroupOn(groupName) ? 24 : -1;
        }
    }
}
#endif