#if UNITY_EDITOR
namespace PowerUtilities
{
    using UnityEditor;
    using UnityEngine;

    public class LineHeaderDecorator : MaterialPropertyDrawer
    {
        string header;
        string groupName;

        public LineHeaderDecorator():this("",""){}
        public LineHeaderDecorator(string header):this("",header){}
        public LineHeaderDecorator(string groupName, string header)
        {
            this.groupName = groupName;
            this.header = $"---------------- {header} --------------------------------";
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {

            var indentLevel = string.IsNullOrEmpty(groupName) ? 0: 1;
            EditorGUI.indentLevel += indentLevel;

            position.y += 8;
            position = EditorGUI.IndentedRect(position);
            EditorGUI.DropShadowLabel(position, header, EditorStyles.boldLabel);

            EditorGUI.indentLevel -= indentLevel;
        }
        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return 24;
            //return string.IsNullOrEmpty(groupName) || MaterialGroupTools.IsGroupOn(groupName) ? 24 : 0;
        }
    }
}
#endif