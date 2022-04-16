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
    public class GroupItemDrawer : BaseGroupItemDrawer
    {

        public GroupItemDrawer(string groupName) : base(groupName) { }

        public override void DrawGroupUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            throw new System.NotImplementedException();
        }


        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            if (!MaterialGroupTools.IsGroupOn(GroupName))
                return;

            EditorGUI.indentLevel += MaterialGroupTools.GroupIndentLevel(GroupName);
            editor.DefaultShaderProperty(position, prop, label.text);
            EditorGUI.indentLevel -= MaterialGroupTools.GroupIndentLevel(GroupName);
        }

    }

}
#endif