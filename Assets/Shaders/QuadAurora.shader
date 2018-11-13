Shader "Mario/Quad/Aurora"
{
	Properties
	{
		_Scale ("Scale", Vector) = (1, 1, 0, 0)
		_A ("A", Float) = 0.5
		_B ("B", Float) = 0.5
		_C ("C", Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque"}

		Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Libraries/UtilShaping.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			uniform float2 _Scale;
			uniform float _A;
			uniform float _B;
			uniform float _C;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// Expand coordinate space by scale.
				i.uv *= _Scale;

				float2 pnt1 = fixed2(0.4, 0.4*sin(_Time.y) + 0.5);
				float2 pnt2 = fixed2(0.6, 0.4*cos(_Time.y) + 0.5);
				float val = cubic_bezier_through_two_points(i.uv.x, pnt1, pnt2);
				val += sin(i.uv.x * _A + _Time.y * _C) * _B; // Perturb a bit, wavy.

				// Start with background color.
				float4 col = lerp(fixed4(0, 0, 0, 1), fixed4(0.15, 0.1, 0.3, 1), circular_ease_out(i.uv.y));

				// Add plot line.
				float lineStrength = step(i.uv.y, val);
				float stMod = clamp(pow(1.0 - saturate(circular_ease_in(1.0 - i.uv.y / val)), 3.3), 0.01, 1);
				col = lerp(col, fixed4(0.01, 1, 0.73, 1), stMod);

				return col;
			}
			ENDCG
		}
	}
}

