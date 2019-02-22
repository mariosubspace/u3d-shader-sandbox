// Parallax Occlusion Mapping

// References - accessed Feb 21, 2019:
// Code primarily from: https://www.gamedev.net/articles/programming/graphics/a-closer-look-at-parallax-occlusion-mapping-r3262/
// How to extract the tangent and bitangent/binormal: https://docs.unity3d.com/Manual/SL-VertexFragmentShaderExamples.html
// https://en.wikibooks.org/wiki/Cg_Programming/Unity/Debugging_of_Shaders

Shader "mSubspace/Parallax Occlusion Mapping"
{
	Properties
	{
		_MainTex ("Main", 2D) = "white" {}
		_HeightMapScale ("Height Map Scale", Float) = 1
		_MinSamples ("Min Samples", Int) = 1
		_MaxSamples ("Max Samples", Int) = 8
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float _HeightMapScale;
			int _MinSamples;
			int _MaxSamples;

			struct appdata
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				float3 worldTangent : TEXCOORD3;
				float3 worldBitangent : TEXCOORD4;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.uv = v.uv;

				o.pos = UnityObjectToClipPos(v.pos);
				o.worldPos = mul(unity_ObjectToWorld, v.pos).xyz;

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				o.worldBitangent = cross(o.worldNormal, o.worldTangent) * tangentSign;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 worldPos = i.worldPos;
				float3 worldViewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

				float3 worldNormal = normalize(i.worldNormal);
				float3 worldTangent = normalize(i.worldTangent);
				float3 worldBitangent = normalize(i.worldBitangent);

				float3x3 tangentToWorldSpace;
				tangentToWorldSpace[0] = float3(worldTangent.x, worldBitangent.x, worldNormal.x);
				tangentToWorldSpace[1] = float3(worldTangent.y, worldBitangent.y, worldNormal.y);
				tangentToWorldSpace[2] = float3(worldTangent.z, worldBitangent.z, worldNormal.z);

				float3x3 worldToTangentSpace = transpose(tangentToWorldSpace);

				float3 tangentCameraPos = normalize(mul(worldToTangentSpace, worldViewDir));

				float2 dx = ddx(i.uv); // <- partial derivative of the specified value with respect to the screen-space x-coordinate.
				float2 dy = ddy(i.uv); // <- same but for y.

				// Essentially projects the camera to the surface.
				float2 offsetDir = -tangentCameraPos.xy;

				float parallaxLimit = 1;// length(offsetDir) / tangentCameraPos.z;
				parallaxLimit *= _HeightMapScale;

				float2 maxOffset = offsetDir * parallaxLimit;

				int numSamples = (int)lerp(_MaxSamples, _MinSamples, saturate(dot(worldNormal, worldViewDir)));
				float stepSize = 1.0 / (float)numSamples; // The height of the raymarching volume (1) divided by numSamples.

				float currentRayHeight = 1.0;
				float2 currentOffset = (float2)0;
				float2 lastOffset = (float2)0;
				float currentSampledHeight = 1.0;
				float lastSampledHeight = 1.0;

				for (int currentSample = 0; currentSample < numSamples; currentSample++)
				{
					// tex2Dgrad is used to sample a texture using the gradient to select the mip level.
					// https://docs.microsoft.com/en-us/windows/desktop/direct3dhlsl/dx-graphics-hlsl-tex2dgrad
					currentSampledHeight = tex2Dgrad(_MainTex, i.uv + currentOffset, dx, dy).r;

					if (currentSampledHeight >= currentRayHeight)
					{
						float delta1 = currentSampledHeight - currentRayHeight;
						float delta2 = (currentRayHeight + stepSize) - lastSampledHeight;
						float ratio = delta1 / (delta1 + delta2);
						currentOffset = (ratio) * lastOffset + (1.0 - ratio) * currentOffset;
						break;
					}
					else
					{
						currentRayHeight -= stepSize;

						lastOffset = currentOffset;
						currentOffset += stepSize * maxOffset;

						lastSampledHeight = currentSampledHeight;
					}
				}

				float2 finalCoords = i.uv + currentOffset;
				float4 finalColor = tex2D(_MainTex, finalCoords);
				return finalColor;
			}
			ENDCG
		}
	}
}
