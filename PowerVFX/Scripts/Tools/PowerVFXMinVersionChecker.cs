#if UNITY_EDITOR
using PowerUtilities;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using UnityEditor;
using UnityEngine;

public class PowerVFXMinVersionChecker
{
    /// <summary>
    /// MIN_VERSION, this keywords not to be used
    /// </summary>
    static readonly string[] keywords = new []
    {
        "PBR_LIGHTING",
		// "_RECEIVE_SHADOWS_ON",
		"_ADDITIONAL_LIGHT_SHADOWS_SOFT",
        "VERTEX_WAVE_ON",
        "FRESNEL_ON",
        //"ALPHA_TEST",
        //"DISTORTION_ON",
        //"DISSOLVE_ON",
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

    /// <summary>
    /// MIN_VERSION this properties not to be used
    /// </summary>
    static readonly string[] props = new[]
    {
        "_MainTexOffset_CustomData_On",
        "_MainTexMaskOffsetCustomDataOn",
        // dissvole
        "_PixelDissolveOn",
        "_DissolveEdgeOn",
        // distortion
        "_DistortionRadialUVOn",
    };

    static bool IsKeywordsValid(string[] materialKeywords)
        => IsValid(materialKeywords, materialKeyword => keywords.Contains(materialKeyword));

    private static bool IsPropValid(Material m) => 
        IsValid(props, propName => m.GetFloat(propName) != 0);
    

    static bool IsValid(IEnumerable<string> keys,Func<string,bool> onCheck)
    {
        foreach (var name in keys)
        {
            if(onCheck(name)) return false;
        }
        return true;
    }

    static bool IsValidMinVersion(Material m)
    {
        return IsPropValid(m) && IsKeywordsValid(m.shaderKeywords);
    }

    [MenuItem("PowerUtilities/PowerVFX/Check MinVersion (selected folder)")]
    static void CheckMinVersion()
    {
        var folders = SelectionTools.GetSelectedFolders();
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