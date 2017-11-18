Shader "MAG/Demo/BezierPendulum"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "RenderType"="Opaque"}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Libraries/MasterCG.cginc"

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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 pnt1 = fixed2(0.4*cos(_Time.y) + 0.5, 0.4*sin(_Time.y) + 0.5);
				float val = quadratic_bezier(i.uv.x, pnt1);

				// Start with background color.
				float4 col = fixed4(0.1, 0.1, 0.1, 1);

				// Add plot line.
				float lineStrength = step(val, i.uv.y);
				col = lerp(col, fixed4(1, 1, 1, 1), lineStrength);

				// Add line segments.
				float lineSegmentA = line_segment(i.uv, fixed2(0,0), pnt1, 0.002);
				float lineSegmentB = line_segment(i.uv, fixed2(1,1), pnt1, 0.002);
				col = lerp(col, fixed4(0.3, 0.3, 0.3, 1), lineSegmentA + lineSegmentB);

				// Add point.
				float pointStrength = draw_point_smooth(pnt1, 0.012, i.uv);
				col = lerp(col, fixed4(1, 0, 0, 1), pointStrength);

				return col;
			}
			ENDCG
		}
	}
}

