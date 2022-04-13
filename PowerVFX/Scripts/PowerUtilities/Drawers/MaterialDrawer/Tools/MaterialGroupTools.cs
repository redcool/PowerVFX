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
        public const string DEFAULT_GROUP_NAME = "DefaultGroup";
        public const float BASE_LINE_HEIGHT = 18;

        static Dictionary<string, bool> groupDict = new Dictionary<string, bool>();
        public static Dictionary<string, bool> GroupDict => groupDict;

        public static bool IsGroupOn(string groupName)
        {
            if (string.IsNullOrEmpty(groupName) || !GroupDict.ContainsKey(groupName))
                return false;
            return GroupDict[groupName];
        }
    }
}
#endif