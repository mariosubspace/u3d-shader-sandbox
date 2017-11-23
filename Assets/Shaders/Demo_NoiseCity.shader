Shader "MAG/Demo/NoiseCity"
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
			#include "Libraries/Master.cginc"
			#include "Libraries/Noise/SimplexNoise2D.cginc"
			#include "Libraries/Noise/ClassicNoise2D.cginc"

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

				i.uv -= float2(0.5, 0.5);
				i.uv = rotate(i.uv, snoise((_Time.y*0.04).xx)*2 - 1.); 
				i.uv += float2(0.5, 0.5);
				float4 col = 1. - stroke(vnoise_simple_linear(i.uv*80.), sin(_Time.y)*0.2 + 0.7, 0.15);

				//float4 col = float4(cnoise(i.uv*20.).xxx, 1 );    
				return col;
			}
			ENDCG
		}
	}
}

