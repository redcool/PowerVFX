#if UNITY_EDITOR
namespace PowerUtilities
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using UnityEditor;
    using UnityEngine;
    using System.Linq;
    /// <summary>
    /// Material's vector property ui
    /// 
    /// </summary>
    public class GroupVectorSliderDrawer : BaseGroupItemDrawer
    {
        const char ITEM_SPLITTER = ' ';
        const char RANGE_SPLITTER = '_';
        readonly string[] strings_XYZ = new string[] { "X","Y","Z"};

        float LINE_HEIGHT => MaterialGroupTools.BASE_LINE_HEIGHT;

        string[] headers;
        Vector2[] ranges;

        //public GroupVectorSliderDrawer(string headerString) : this("",headerString, "") { }
        public GroupVectorSliderDrawer(string headerString,string rangeString) : this("", headerString, rangeString) { }
        /// <summary>
        /// headerString 
        ///     4slider : a b c d, [space] is splitter
        ///     vector3 slider1 : VectorSlider(vname sname ,0_1)
        /// rangeString like 0_1 0_1 ,[space][_] is splitter
        /// 
        /// sliders 4 : [GroupVectorSlider(group1, a b c d, 0_1 1_2 0_1 0_2)] _Vector("_Vector", vector) = (1,1,1,1)
        /// vector3 slider 1 :[GroupVectorSlider(group1,Dir(xyz) intensity, 0_1)] _Vector("_Vector2", vector) = (1,0.1,0,1)
        /// </summary>
        /// <param name="headerString"></param>
        public GroupVectorSliderDrawer(string groupName,string headerString,string rangeString) : base(groupName)
        {
            if (!string.IsNullOrEmpty(headerString))
            {
                headers = headerString.Split(ITEM_SPLITTER);
            }
            if (!string.IsNullOrEmpty(rangeString))
            {
                var rangeItems = rangeString.Split(new[] {ITEM_SPLITTER, RANGE_SPLITTER }, StringSplitOptions.RemoveEmptyEntries);
                if (rangeItems.Length > 1)
                {
                    var halfLen = rangeItems.Length / 2;
                    ranges = new Vector2[halfLen];
                    for (int i = 0; i < halfLen; i++)
                    {
                        ranges[i] = new Vector2(Convert.ToSingle(rangeItems[i * 2]), Convert.ToSingle(rangeItems[i * 2 + 1]));
                    }
                }
                else
                    ranges[0] = new Vector2(Convert.ToSingle(rangeItems[0]),0);
            }
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            if (MaterialGroupTools.IsGroupOn(GroupName))
                return (headers.Length + 1) * LINE_HEIGHT;
            return -1;
        }

        public override void DrawGroupUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
        {
            if (prop.type != MaterialProperty.PropType.Vector || headers == null)
            {
                editor.DrawDefaultInspector();
                return;
            }
            // restore width
            EditorGUIUtility.labelWidth = MaterialGroupTools.BASE_LABLE_WIDTH;

            EditorGUI.BeginChangeCheck();
            var value = prop.vectorValue;

            // property label
            EditorGUI.LabelField(new Rect(position.x, position.y, position.width, LINE_HEIGHT), label);

            EditorGUI.indentLevel++;

            position.y += LINE_HEIGHT;
            position.height -= LINE_HEIGHT;

            if (ranges.Length == 1) // draw vector and float
                DrawVector3Slider1(position, ref value);
            else // draw 4 float
                Draw4Sliders(position, ref value);

            EditorGUI.indentLevel--;

            if (EditorGUI.EndChangeCheck())
            {
                prop.vectorValue = value;
            }
        }



        private void DrawVector3Slider1(Rect position, ref Vector4 value)
        {
            var vectorHeader = headers[0];
            var sliderHeader = headers[1];


            var itemWidth = position.width / 4;
            var pos = position;
            pos.height = LINE_HEIGHT;
            pos.width = itemWidth;

            EditorGUI.LabelField(pos, vectorHeader);

            EditorGUIUtility.labelWidth = 30;// EditorStyles.label.CalcSize(new GUIContent("X")).x;
            for (int i = 0; i < 3; i++)
            {
                pos.x += itemWidth;

                value[i] = EditorGUI.FloatField(pos, strings_XYZ[i], value[i]);
            }
            // slider
            pos.x = position.x ;
            pos.y += LINE_HEIGHT;
            pos.width = position.width;
            EditorGUIUtility.labelWidth = MaterialGroupTools.BASE_LABLE_WIDTH;
            value[3] = MaterialPropertyDrawerTools.DrawRemapSlider(pos, ranges[0],sliderHeader, value[3]);
        }

        private void Draw4Sliders(Rect position, ref Vector4 value)
        {
            var pos = new Rect(position.x, position.y, position.width, 18);
            for (int i = 0; i < headers.Length; i++)
            {
                value[i] = MaterialPropertyDrawerTools.DrawRemapSlider(pos,ranges[i],headers[i], value[i]);
                pos.y += LINE_HEIGHT;

            }
        }
    }
}
#endif