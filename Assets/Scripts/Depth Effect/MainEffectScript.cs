using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class MainEffectScript : MonoBehaviour
{
    public Material matDepthEffect;

    Camera mainCamera;

    void OnEnable()
    {
        mainCamera = GetComponent<Camera>();
        mainCamera.depthTextureMode = DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        if (matDepthEffect)
        {
            Graphics.Blit(src, dst, matDepthEffect);
        }
    }
}
