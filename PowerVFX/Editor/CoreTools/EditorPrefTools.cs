#if UNITY_EDITOR
namespace PowerUtilities
{
    using UnityEditor;
    using UnityEngine;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Threading.Tasks;

    public static class EditorPrefTools
    {
        public static void SetList<T>(string key,List<T> list,string separator)
        {
            var q = list.Select(item => item.ToString());
            var line = string.Join(separator, q);
            EditorPrefs.SetString(key, line);
        }
        public static void GetList<T>(string key,ref List<T> list,string separator,Func<string,T> onTransferType)
        {
            var line = EditorPrefs.GetString(key);
            var items = line.Split(new[] { separator }, StringSplitOptions.RemoveEmptyEntries)
                .Select(str=>str.Trim());
            foreach (var item in items)
            {
                list.Add(onTransferType(item));
            }
        }
    }
#endif
}
