using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class MaterialValuePropertyInfo
{
    public string name;
    public float value;
    public float speed;

    [Header("Enabled?")]
    public bool enabled=true;

    [Header("Range")]
    public float minValue = 0;
    public float maxValue = 1;

    public void UpdateValue(float deltaTime)
    {
        value += speed * deltaTime;
        value = Mathf.Clamp01(value);
    }

    public bool CanUpdate()
    {
        return enabled && !string.IsNullOrEmpty(name);
    }
}

public class MaterialValuePropertyDriver : MonoBehaviour
{
    public MaterialValuePropertyInfo[] infos;

    Renderer render;
    static MaterialPropertyBlock block;

    // Start is called before the first frame update
    void Start()
    {
        render = GetComponent<Renderer>();

        if(block == null)
            block = new MaterialPropertyBlock();
    }

    // Update is called once per frame
    void Update()
    {
        if (infos == null || infos.Length == 0 || !render)
            return;

        foreach (var info in infos)
        {
            if (!info.CanUpdate())
                continue;

            info.UpdateValue(Time.deltaTime);

            block.SetFloat(info.name, info.value);
            render.SetPropertyBlock(block);
        }
    }
}
