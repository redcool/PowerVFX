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
    /// Draw a group 
    /// </summary>
    public class GroupDecorator : MaterialPropertyDrawer
    {
        string groupName;

        public GroupDecorator(string groupName)
        {
            this.groupName = groupName;

            MaterialGroupTools.GroupDict[groupName] = EditorPrefs.GetBool(groupName, false);
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 18;
        }

        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            EditorGUI.BeginChangeCheck();  
            MaterialGroupTools.GroupDict[groupName] = EditorGUI.BeginFoldoutHeaderGroup(position, MaterialGroupTools.GroupDict[groupName], groupName);
            EditorGUI.EndFoldoutHeaderGroup();

            if (EditorGUI.EndChangeCheck())
            {
                // write to register
                EditorPrefs.SetBool(groupName, MaterialGroupTools.GroupDict[groupName]);
            }
        }
    }
}
#endif