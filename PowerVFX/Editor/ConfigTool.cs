#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace PowerVFX
{

    /// <summary>
    /// key=value,ÅäÖÃÎÄ¼þ²Ù×÷
    /// </summary>
    public static class ConfigTool
    {
        static string FindI18NPath(string configPath,string configFileName="i18n.txt",int maxFindCount=10)
        {
            var pathDir = Path.GetDirectoryName(configPath);
            var filePath = "";
            var findCount = 0;
            while (!pathDir.EndsWith("Assets"))
            {
                filePath = pathDir + "/"+ configFileName;
                pathDir = Path.GetDirectoryName(pathDir);
                if (File.Exists(filePath) || ++findCount > maxFindCount)
                    break;
            }
            return filePath;
        }

        public static Dictionary<string,string> ReadConfig(string configFilePath)
        {
            var splitRegex = new Regex(@"\s*=\s*");
            var dict = new Dictionary<string, string>();
            if (!string.IsNullOrEmpty(configFilePath))
            {
                var lines = File.ReadAllLines(configFilePath);
                foreach (var lineStr in lines)
                {
                    var line = lineStr.Trim();
                    if (string.IsNullOrEmpty(line) || line.StartsWith("//"))
                        continue;

                    var kv = splitRegex.Split(line);
                    if (kv.Length > 1)
                        dict[kv[0]] = kv[1];
                }
            }
            return dict;
        }

        public static Dictionary<string, string> ReadConfig(Shader shader)
        {
            var shaderFilePath = AssetDatabase.GetAssetPath(shader);
            var i18nFilePath = FindI18NPath(shaderFilePath);
            return ReadConfig(i18nFilePath);
        }

        public static Dictionary<string, MaterialProperty> CacheProperties(MaterialProperty[] properties)
        {
            var propDict = new Dictionary<string, MaterialProperty>();

            foreach (var prop in properties)
            {
                propDict[prop.name] = prop;
            }

            return propDict;
        }

        public static string Text(Dictionary<string,string> dict,string str)
        {
            string text = str;
            if (dict.ContainsKey(str))
                text = dict[str];

            return text;
        }

    }
}
#endif