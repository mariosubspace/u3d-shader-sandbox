// This script adapted from Claire Blackshaw's tutorial on Unity Compute Shaders:
// https://www.youtube.com/watch?v=qDk-WIOYUSY

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Renderer))]
public class SimpleReplaceTextureWithNoise : MonoBehaviour
{
	public ComputeShader shader;
	public int textureResolution = 256;

	new Renderer renderer;
	RenderTexture renderTexture;

	void Start()
	{
		renderTexture = new RenderTexture(textureResolution, textureResolution, 0);
		renderTexture.enableRandomWrite = true;
		renderTexture.Create();

		renderer = GetComponent<Renderer>();
		renderer.enabled = true;

		UpdateTextureFromCompute();
	}

	void UpdateTextureFromCompute()
	{
		int kernelHandle = shader.FindKernel("CSMain");
		shader.SetInt("RandOffset", (int)(Time.timeSinceLevelLoad * 100));

		shader.SetTexture(kernelHandle, "Result", renderTexture);

		// It's unclear from the documentation because they confound Work Groups with Thread Groups,
		// but in Dispatch you pass in how many groups of Thread Groups will be run in each dimension.
		// If your texture is 256 across X, and you have 8 threads across X per warp, you need to run
		// 256 / 8 = 32 warps (with 8 threads in the X dimension per warp).
		// At least this is what I assume from seeing how this actually behaves.
		// In this case numthreads(8, 8, 1) = 64 threads per warp, Dispatch(32, 32, 1) = 1024 warps, 64 threads * 1024 warps = 65536 = 256px*256px.
		shader.Dispatch(kernelHandle, textureResolution / 8, textureResolution / 8, 1);

		renderer.material.SetTexture("_MainTex", renderTexture);
	}

	void Update()
	{
		if (Input.GetKeyUp(KeyCode.Alpha1))
		{
			UpdateTextureFromCompute();
		}
	}
}