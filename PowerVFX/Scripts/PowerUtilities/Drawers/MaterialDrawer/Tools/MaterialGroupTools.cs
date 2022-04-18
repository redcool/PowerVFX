#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PowerUtilities
{
    public static class MaterialGroupTools
    {
        public const string DEFAULT_GROUP_NAME = "_";
        public const float BASE_LINE_HEIGHT = 18;
        public const float BASE_LABLE_WIDTH = 162.5f;

        static Dictionary<string, bool> groupDict = new Dictionary<string, bool>();
        public static Dictionary<string, bool> GroupDict => groupDict;

        public static bool IsGroupOn(string groupName)
        {
            // default Group or not Group open always
            if (IsDefaultGroup(groupName))
                return true;

            return GroupDict[groupName];
        }

        public static bool IsDefaultGroup(string groupName) => string.IsNullOrEmpty(groupName) || groupName == DEFAULT_GROUP_NAME || !GroupDict.ContainsKey(groupName);

        public static int GroupIndentLevel(string groupName) => IsDefaultGroup(groupName) ? 0 : 1;
    }
}
#endif