using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ShaderTesting : MonoBehaviour
{
    public Material mat;

    void Update()
    {
        if (mat != null)
        {
            mat.SetVector("_Scale", new Vector4(transform.localScale.x, transform.localScale.y, 0f, 0f));
        }
    }
}
