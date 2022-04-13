#if UNITY_EDITOR
namespace PowerUtilities
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEditor;
    using UnityEngine;
    using System.Linq;

    /// <summary>
    /// Material's Group Item Attribute
    /// </summary>
    public class GroupItemDrawer : MaterialPropertyDrawer
    {
        string groupName;

        public GroupItemDrawer(string groupName)
        {
            this.groupName = groupName;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            if (MaterialGroupTools.IsGroupOn(groupName))
            {
                var baseHeight = MaterialGroupTools.BASE_LINE_HEIGHT;
                if (prop.type == MaterialProperty.PropType.Texture)
                {
                    baseHeight *= 4;
                }
                return baseHeight;
            }

            return -1;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            if (MaterialGroupTools.IsGroupOn(groupName))
            {
                EditorGUI.indentLevel++;
                editor.DefaultShaderProperty(position, prop, label.text);
                EditorGUI.indentLevel--;
            }
        }

    }

}
#endif