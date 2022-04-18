using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace PowerUtilities
{
#if UNITY_EDITOR
    using UnityEditor;

    [CustomPropertyDrawer(typeof(DisplayName))]
    public class DisplayNameDrawer : PropertyDrawer
    {
        public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
        {
            //base.OnGUI(position, property, label);
            var attr = attribute as DisplayName;
            var ranges = fieldInfo.GetCustomAttributes(typeof(RangeAttribute), true);

            label.text = attr.Value;
            if (ranges.Length > 0)
            {
                var range = ranges[0] as RangeAttribute;
                EditorGUI.Slider(position, property, range.min, range.max, label);
            }
            else
            {
                EditorGUI.PropertyField(position, property, label);
            }
        }
    }
#endif
    public class DisplayName : PropertyAttribute
    {
        public string Value;

        public DisplayName(string value)
        {
            this.Value = value;
        }

        public override string ToString()
        {
            return Value;
        }
    }

}
