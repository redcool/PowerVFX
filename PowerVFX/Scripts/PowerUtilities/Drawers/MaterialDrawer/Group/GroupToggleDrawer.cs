#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

namespace PowerUtilities
{
    /// <summary>
    /// Material's Toggle in group
    /// 
    /// [GroupToggle(ShadowGroup,_Ker)]_ReceiveShadow("_ReceiveShadow",int) = 1
    /// </summary>
    public class GroupToggleDrawer : MaterialPropertyDrawer
    {
        string groupName;
        string keyword;
        public GroupToggleDrawer() : this(MaterialGroupTools.DEFAULT_GROUP_NAME, "") { }
        public GroupToggleDrawer(string groupName):this(groupName,""){}
        public GroupToggleDrawer(string groupName, string keyword)
        {
            this.groupName = groupName;
            this.keyword = keyword;
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return MaterialGroupTools.IsGroupOn(groupName) ? MaterialGroupTools.BASE_LINE_HEIGHT : -4;
        }
        public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            if (!MaterialGroupTools.IsGroupOn(groupName))
                return;


            EditorGUI.BeginChangeCheck();
            EditorGUI.indentLevel++;
            bool isOn = Mathf.Abs(prop.floatValue) > 0.001f;
            isOn = EditorGUI.Toggle(position, label,isOn);
            EditorGUI.indentLevel--;

            if (EditorGUI.EndChangeCheck())
            {
                prop.floatValue = isOn ? 1 : 0;

                if (!string.IsNullOrEmpty(keyword))
                {
                    MaterialPropertyDrawerTools.SetKeyword(prop, keyword, isOn);
                }
            }
        }
    }
}
#endif