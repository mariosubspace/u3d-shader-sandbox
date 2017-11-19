Shader "MAG/Demo/RandomSquares"
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
				//return fixed4(map_hsb_polar(i.uv), 1) ;

//				float dx = ddx(i.uv.x) * 8;
//				float dy = ddy(i.uv.y) * 8;

				// Repeat coordinate space.
//				i.uv.x = fmod(i.uv.x * _Scale, _TileX);
//				i.uv.y = fmod(i.uv.y * _Scale, _TileY);
//
				// Expand coordinate space by scale.
//				i.uv *= _Scale;

				// Correct for aspect ratio.
//				float aspect = _ScreenResolution.x / _ScreenResolution.y;
//				i.uv.x = i.uv.x * aspect - (aspect - 1.0) * 0.5;

//				fixed4 texCol = tex2D(_MainTex, i.uv);
//				float2 pnt1 = fixed2(0.4, 0.4*sin(_Time.y) + 0.5);
//				float2 pnt2 = fixed2(0.6, 0.4*cos(_Time.y) + 0.5);
//				float val = exponential_in_out(sawtooth(i.uv.y + i.uv.x + _Time.y));
				 
				float4 col = float4(1, 1, 1, 1);
			
				int2 uvIdx = floor(i.uv*30.);
				float switchSpeed = 0.38;
				float rVal = step(0.45, rand_simple(uvIdx, floor(float2(_Time.y * switchSpeed, _Time.y * switchSpeed + 20.)), 2.)*.9);

				float4 tiled = tile_space(i.uv, 4.0);
				i.uv = tiled.xy;  

				float sdfRect = rectSDF(i.uv, float2(1, 1));
				float squareSpeed = 0.3;
				float r = rand_simple(floor(sdfRect*10. - _Time.y * squareSpeed));
				float g = rand_simple(floor(sdfRect*10. - _Time.y * squareSpeed + 10.));
				float b = rand_simple(floor(sdfRect*10. - _Time.y * squareSpeed + 20.));

				float4 randCol = float4(r, g, b, 1);

				col = lerp(1.0 - randCol, randCol, rVal);

				return col;

				//col = lerp(col, fixed4(1, 0, 0, 1), plot_line(val, 0.01, i.uv));
				// Add plot line.
//				float lineStrength = step(i.uv.y, val);
//				float stMod = clamp(pow(1.0 - saturate(circular_ease_in(1.0 - i.uv.y / val)), 3.3), 0.01, 1);
				// Modulate line strength.
				//float4 tmpCol = lerp(fixed4(0.1, 0.1, 0.1, 1), fixed4(0.8, 0.05, 0.25, 1), stMod);
				//col = lerp(col, tmpCol, stMod);
//				col = lerp(col, fixed4(0.01, 1, 0.73, 1), stMod);
//				// Add line segments.
//				float lineSegmentA = line_segment(i.uv, fixed2(0,0), pnt1, 0.002);
//				float lineSegmentB = line_segment(i.uv, fixed2(1,1), pnt2, 0.002);
//				float lineSegmentC = line_segment(i.uv, pnt1, pnt2, 0.002);
//				col = lerp(col, fixed4(0.3, 0.3, 0.3, 1), lineSegmentA + lineSegmentB + lineSegmentC);

//				// Add point 1.
//				float pointStrength1 = draw_point_smooth(pnt1, 0.012, i.uv);
//				col = lerp(col, fixed4(0.3, 0.1, 1, 1), pointStrength1);
//
//				// Add point 2.
//				float pointStrength2 = draw_point_smooth(pnt2, 0.012, i.uv);
//				col = lerp(col, fixed4(0.3, 0.1, 1, 1), pointStrength2);

				return col;
			}
			ENDCG
		}
	}
}

