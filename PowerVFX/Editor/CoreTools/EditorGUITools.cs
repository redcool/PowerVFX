#if UNITY_EDITOR
namespace PowerUtilities
{
    using System;
    using System.Linq;
    using System.Collections;
    using System.Collections.Generic;
    using UnityEditor;
    using UnityEditorInternal;
    using UnityEngine;

    public static class EditorGUITools
    {
        public static Color darkGray = new Color(0.2f, 0.3f, 0.4f);
        public static void DrawPreview(Texture tex)
        {
            var rect = GUILayoutUtility.GetRect(100, 100, "Box");
            EditorGUI.DrawPreviewTexture(rect, tex);
        }

        public static void DrawSplitter(float w, float h)
        {
            GUILayout.Box("", GUILayout.Height(h), GUILayout.Width(w));
        }

        public static void DrawFixedWidthLabel(float width, Action drawAction)
        {
            if (drawAction == null)
                return;

            var lastLabelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = width;
            drawAction();
            EditorGUIUtility.labelWidth = lastLabelWidth;
        }

        public static void BeginVerticalBox(Action drawAction, string style = "Box")
        {
            EditorGUILayout.BeginVertical(style);
            if (drawAction != null)
                drawAction();
            EditorGUILayout.EndVertical();
        }
        public static void BeginHorizontalBox(Action drawAction, string style = "Box")
        {
            EditorGUILayout.BeginHorizontal(style);
            if (drawAction != null)
                drawAction();
            EditorGUILayout.EndHorizontal();
        }

        public static int LayerMaskField(string label, int layers)
        {
            var tempLayers = InternalEditorUtility.LayerMaskToConcatenatedLayersMask(layers);
            tempLayers = EditorGUILayout.MaskField(label, tempLayers, InternalEditorUtility.layers);
            return InternalEditorUtility.ConcatenatedLayersMaskToLayerMask(tempLayers);
        }

        public static void DrawFoldContent(ref (string title, bool fold) foldInfo, Action drawContentAction)
        {
            DrawFoldContent(ref foldInfo, drawContentAction, GUI.contentColor);
        }

        public static void DrawFoldContent(ref (string title, bool fold) foldInfo, Action drawContentAction, Color titleColor, float space = 1)
        {
            var lastColor = GUI.contentColor;
            GUI.contentColor = titleColor;

            var lastBg = GUI.backgroundColor;
            GUI.backgroundColor = Color.gray;

            // draw title button bar
            EditorGUILayout.BeginVertical("Button");
            foldInfo.fold = EditorGUILayout.Foldout(foldInfo.fold, foldInfo.title, true);
            EditorGUILayout.Space(space);
            EditorGUILayout.EndVertical();

            GUI.backgroundColor = lastBg;
            GUI.contentColor = lastColor;

            //draw content
            if (foldInfo.fold)
            {
                ++EditorGUI.indentLevel;
                drawContentAction();
                --EditorGUI.indentLevel;
            }
        }

        public static void DrawColorUI(Action drawAction, Color contentColor, Color color)
        {
            if (drawAction == null)
                return;

            var lastContentColor = GUI.contentColor;
            var lastColor = GUI.color;

            GUI.contentColor = contentColor;
            GUI.color = color;
            drawAction();

            GUI.contentColor = lastContentColor;
            GUI.color = lastColor;
        }

        /// <summary>
        /// 
        /// Hold control select multi buttons.
        /// </summary>
        /// <param name="contents"></param>
        /// <param name="toggles"></param>
        /// <param name="selectedIds"></param>
        /// <param name="xCount"></param>
        /// <param name="rowStyle"></param>
        /// <param name="columnStyle"></param>
        /// <returns></returns>
        public static bool MultiSelectionGrid(GUIContent[] contents, bool[] toggles, List<int> selectedIds, int xCount, GUIStyle rowStyle = null, GUIStyle columnStyle = null)
        {
            var e = Event.current;
            // check styles
            rowStyle = rowStyle == null ? GUIStyle.none : rowStyle;
            columnStyle = columnStyle == null ? GUIStyle.none : columnStyle;

            //calc rows
            var rows = contents.Length / xCount;
            if (contents.Length % xCount != 0)
                rows++;

            // item
            var itemIndex = 0;
            var itemWidth = (EditorGUIUtility.currentViewWidth - 40 - xCount * 4) / xCount ; // guess inspector's width
            var hasChanged = false;

            GUILayout.BeginVertical(columnStyle);
            for (int x = 0; x < rows; x++)
            {
                GUILayout.BeginHorizontal(rowStyle);
                for (int y = 0; y < xCount; y++)
                {
                    itemIndex = y + x * xCount;
                    if (itemIndex >= toggles.Length)
                        break;

                    var lastToggle = toggles[itemIndex];
                    toggles[itemIndex] = GUILayout.Toggle(lastToggle, contents[itemIndex], "Button", GUILayout.Width(itemWidth));


                    if(lastToggle != toggles[itemIndex])
                    {
                        SelectionControl(toggles, selectedIds, e, itemIndex);
                    }
                }
                GUILayout.EndHorizontal();

            }
            GUILayout.EndVertical();

            return hasChanged;

            // inner method
            void SelectionControl(bool[] toggles, List<int> selectedIds, Event e, int itemIndex)
            {
                // multiple selection
                if (e.control)
                {
                    var isSelected = toggles[itemIndex];
                    var isContained = selectedIds.Contains(itemIndex);

                    if (isSelected && !isContained)
                        selectedIds.Add(itemIndex);

                    if (!isSelected && isContained)
                        selectedIds.Remove(itemIndex);
                }
                else
                {
                    // single selection
                    for (int i = 0; i < toggles.Length; i++)
                    {
                        if (i != itemIndex)
                            toggles[i] = false;
                    }

                    selectedIds.Clear();
                    selectedIds.Add(itemIndex);
                }
            }
        }



        public static bool MultiSelectionGrid(string[] contents, bool[] toggles, List<int> selectedIds, int xCount, GUIStyle rowStyle = null, GUIStyle columnStyle = null)
        {
            var guiContents = contents.Select(str => new GUIContent(str)).ToArray();
            return MultiSelectionGrid(guiContents, toggles, selectedIds, xCount, rowStyle, columnStyle);
        }
    }
}
#endif