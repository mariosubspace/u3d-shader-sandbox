Shader "Mario/Raymarching/Slicer"
{
	Properties
	{
		_SurfaceColor ("Surface Color", Color) = (1, 1, 1, 1)
		_InsideColor ("Inside Color", Color) = (1, 1, 1, 1)
		_SkinThickness ("Skin Thickness", Range(-0.2, 0)) = -0.01
		_SkinInnerColor ("Skin Inner Color", Color) = (1, 1, 1, 1)
		_AmbientColor ("Ambient Color", Color) = (0, 0, 0, 0)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }

		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "Libraries/SDFShapes3D.cginc" 

			#define MAX_STEPS 128
			#define MIN_DISTANCE 0.0007
			#define TAU 6.28318530718
			#define PI 3.14159265359

			fixed4 _SurfaceColor;
			fixed4 _InsideColor;
			float _SkinThickness;
			fixed4 _SkinInnerColor;
			fixed4 _AmbientColor;

			fixed3 hitPoint = fixed3(1, 0, 0);
			fixed3 hitNormal = fixed3(1, 0, 0);

			struct appdata
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			fixed simpleLambert(fixed3 normal)
			{
				fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				fixed NdotL = max(dot(normal, lightDir), 0);
				return NdotL;
			}

			float opUnion(float d1, float d2)
			{
				return min(d1, d2);
			}

			float opDifference(float d1, float d2)
			{
				return max(-d1, d2);
			}

			float opIntersection(float d1, float d2)
			{
				return max(d1, d2);
			}

			float sdf(float3 p)
			{
				const float eps = 0.001;
				float s;

				//float o  = sphereSDF(p, float3(0.0, 0.0, 0.0), 0.5);
				float o  = sphereSDF(p, float3(0.0, 0.0, -0.2), 0.4);
				float h1 = sphereSDF(p, float3(-0.3, 0.0, 0.1), 0.3);
				float h2 = sphereSDF(p, float3(0.3, 0.0, 0.1), 0.3);

				s = o;
				s = opUnion(s, h1);
				s = opUnion(s, h2);

				float frequency = TAU * 5;
				float speed = _Time.y * 5;
				float amplitude = PI / (2.0 * frequency);
				float sne = amplitude * sin(frequency * p.x + speed);

				s = opIntersection(s, sne);

				return s;
			}

			float3 sdfNormal(float3 p)
			{
				const float eps = 0.003;
				return normalize(
					float3(
						sdf(p + float3(eps, 0, 0)) - sdf(p - float3(eps, 0, 0)),
						sdf(p + float3(0, eps, 0)) - sdf(p - float3(0, eps, 0)),
						sdf(p + float3(0, 0, eps)) - sdf(p - float3(0, 0, eps))
					));
			}

			fixed4 renderSurface(float3 p, float sdfSample)
			{
				if (sdfSample < _SkinThickness)
				{
					return _InsideColor;
				}
				else if (sdfSample < 0)
				{
					return _SkinInnerColor;
				}

				float3 N = sdfNormal(p);
				fixed lightAmt = saturate(simpleLambert(N) + _AmbientColor.a);
				fixed4 col;
				col.rgb = (_SurfaceColor.rgb * _LightColor0.rgb * _AmbientColor.rgb) * lightAmt;
				col.a = 1;
				return col;
			}

			fixed4 raymarch(float3 position, float3 direction)
			{
				for (int i = 0; i < MAX_STEPS; ++i)
				{
					float sdfSample = sdf(position);
					if (sdfSample < MIN_DISTANCE)
					{
						return renderSurface(position, sdfSample);
					}

					// The end value is to cut back the ray marching a bit to not accidentally go
					// into a surface prematurely. Value is arbitrary/trial-and-error. Must be
					// a value between 0 (no propagation) and 1 (full propagation).
					position += direction * sdfSample * 0.6;
				}
				return fixed4(0, 0, 0, 0);
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.pos);
				o.uv = v.uv;
				o.worldPos = mul(unity_ObjectToWorld, v.pos).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldPos = i.worldPos;
				float3 viewDir = normalize(i.worldPos - _WorldSpaceCameraPos);
				fixed4 col = raymarch(worldPos, viewDir);
				return col;
			}
			ENDCG
		}
	}
}
