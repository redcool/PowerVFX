#if UNITY_EDITOR
using PowerUtilities;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

public class PowerVFXMinVersionChecker
{
    static HashSet<string> keywordSet = new HashSet<string>{
            "PBR_LIGHTING",
			// "_RECEIVE_SHADOWS_ON",
			"_ADDITIONAL_LIGHT_SHADOWS_SOFT",
            "VERTEX_WAVE_ON",
            "FRESNEL_ON",
            //"ALPHA_TEST",
            "DISTORTION_ON",
            "DISSOLVE_ON",
            "OFFSET_ON",
            "ENV_REFLECT_ON",
            "ENV_REFRACTION_ON",
            "MATCAP_ON",
            "MATCAP_ROTATE_ON",
            "DEPTH_FADING_ON",
            "DOUBLE_EFFECT_ON",
            "_OFFSET_BLEND_REPLACE_MODE",
            "SHEET_ANIM_BLEND_ON"
    };

    static bool IsKeywordsValid(string[] keywords)
    {
        foreach (var item in keywords)
        {
            if (keywordSet.Contains(item))
                return false;
        }
        return true;
    }

    static bool IsValidMinVersion(Material m)
    {
        var isPropValid = (m.GetFloat("_MainTexOffset_CustomData_On") == 0 && m.GetFloat("_MainTexMaskOffsetCustomDataOn") == 0);

        return isPropValid && IsKeywordsValid(m.shaderKeywords);
    }

    [MenuItem("PowerUtilities/PowerVFX/Check MinVersion")]
    static void CheckMinVersion()
    {
        var folders = AssetDatabaseTools.GetSelectedFolders();
        var list = AssetDatabaseTools.FindAssetsInProject<Material>("t:material", folders);
        var q = list.Where(m => m.shader.name.Contains("PowerVFX"));
        var count = 0;
        q.ForEach(m =>
        {
            if(IsValidMinVersion(m))
            {
                //m.SetFloat("_MinVersion",1);
                m.EnableKeyword("MIN_VERSION");
                count++;
            }
        });
        Debug.Log("PowerVFX MinVersion count: "+count);
    }

}
#endif