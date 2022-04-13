#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using System.Linq;

namespace PowerUtilities
{

    /// <summary>
    /// key=value,配置文件操作
    /// </summary>
    public static class ConfigTool
    {
        /// <summary>
        /// * = *
        /// </summary>
        static Regex kvRegex = new Regex(@"\s*=\s*");
        public const string I18N_PROFILE_PATH = "Profiles/i18n.txt";
        public const string LAYOUT_PROFILE_PATH = "Profiles/Layout.txt";
        public const string COLOR_PROFILE_PATH = "Profiles/Colors.txt";

        /// <summary>
        /// 从configPath开始找configFileName文件,一直找到Assets目录
        /// </summary>
        /// <param name="configPath"></param>
        /// <param name="configFileName"></param>
        /// <param name="maxFindCount"></param>
        /// <returns></returns>
        public static string FindPathRecursive(string configPath,string configFileName="i18n.txt",int maxFindCount=10)
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

        /// <summary>
        /// key=value的配置文件读入到内存.
        /// 
        /// dict 结构为
        /// {
        ///     key1 = *1,*2
        /// }
        /// </summary>
        /// <param name="configFilePath"></param>
        /// <returns></returns>
        public static Dictionary<string,string> ReadKeyValueConfig(string configFilePath)
        {
            var dict = new Dictionary<string, string>();
            if (!string.IsNullOrEmpty(configFilePath) && File.Exists(configFilePath))
            {
                var lines = File.ReadAllLines(configFilePath);
                foreach (var lineStr in lines)
                {
                    var line = lineStr.Trim();
                    if (string.IsNullOrEmpty(line) || line.StartsWith("//"))
                        continue;

                    var kv = kvRegex.Split(line);
                    if (kv.Length > 1)
                        dict[kv[0]] = kv[1];
                }
            }
            return dict;
        }

        public static string[] SplitBy(string line,char splitChar=',')
        {
            var vs = line.Split(splitChar);
            return vs.Select(v => v.Trim()).ToArray();
        }


        public static Dictionary<string,string> ReadConfig(string shaderFilePath,string profileFilePath)
        {
            var path = FindPathRecursive(shaderFilePath, profileFilePath);
            return ReadKeyValueConfig(path);
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