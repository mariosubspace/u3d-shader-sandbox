Shader "MAG/Demo/PixelSpiritDeck"
{
	Properties
	{
		_Index ("Index", Float) = 1
		_BackgroundColor ("Background", Color) = (0, 0, 0, 1)
		_ForegroundColor ("Background", Color) = (1, 1, 1, 1)
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

			uniform float _Index;
			uniform float4 _BackgroundColor;
			uniform float4 _ForegroundColor;

			float3 weird_hex_rotator(float2 uv)
			{
				float3 col;
				col.r = fill(polySDF(uv, 5, _Time.y), 0.5);
				col.g = fill(polySDF(uv, 5, cos(_Time.y + 0.1)), 0.5);
				col.b = fill(polySDF(uv, 5, sin(_Time.y + 0.5)), 0.5);
				return col;
			}

			float the_star(float2 uv)
			{
				float starIn = starSDF(uv, 6, 0.1);

				// Shift origin.
				uv -= float2(0.5, 0.5);

				// Get the angle around the origin, normalized to [0, 1].
				float fan = fanSDF(uv, 8);
				fan = stroke(fan, 0.5, 0.15);

				// Rotate.
				uv = rotate(uv, PI/6);
				
				// Shift origin back.
				uv += float2(0.5, 0.5);

				float starOut = starSDF(uv, 6, 0.1);

				float col = fan;
				col -= fill(starOut, 0.7);
				col = saturate(col); // Clamp cause next op will undo.
				col += fill(starOut, 0.5);
				col += stroke(starOut, 0.6, 0.05);
				col -= fill(starIn, 0.26);
				col += fill(starIn, 0.2);

				return col;
			}

			float judgement(float2 uv)
			{
				float f = fanSDF(uv - 0.5, 28);
				f = stroke(f, 0.5, 0.2);
				float h = step(uv.y, 0.5);
				float bg = flip(f, h);

				float sq = rectSDF(uv, float2(0.5, 0.5));
				float col = saturate(bg - fill(sq, 0.45));
				col += fill(sq, 0.37);

				return col;
			}

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float val = 0.;
				float4 col = _BackgroundColor;
				fixed4 strokeCol = _ForegroundColor;

				switch (floor(_Index))
				{
					case 0:
					{
						val = the_void(i.uv);
						break;
					}
					case 1:
					{
						val = justice(i.uv);
						break;
					}
					case 2:
					{
						val = strength(i.uv);
						break;
					}
					case 3:
					{
						val = death(i.uv);
						break;
					}
					case 4:
					{
						val = the_wall(i.uv);
						break;
					}
					case 5:
					{
						val = temperance(i.uv);
						break;
					}
					case 6:
					{
						val = branch(i.uv);
						break;
					}
					case 7:
					{
						val = the_hanged_man(i.uv);
						break;
					}
					case 8:
					{
						val = the_high_priestess(i.uv);
						break;
					}
					case 9:
					{
						val = the_moon(i.uv);
						break;
					}
					case 10:
					{
						val = the_emperor(i.uv);
						break;
					}
					case 11:
					{
						val = the_hierophant(i.uv); 
						break;
					}
					case 12:
					{
						val = the_tower(i.uv); 
						break;
					}
					case 13:
					{
						val = merge(i.uv);
						break;
					}
					case 14:
					{
						val = hope(i.uv);
						break;
					}
					case 15:
					{
						val = the_temple(i.uv);
						break;
					}
					case 16:
					{
						val = the_summit(i.uv);
						break;
					}
					case 17:
					{
						val = the_diamond(i.uv);
						break;
					}
					case 18:
					{
						val = the_hermit(i.uv);
						break;
					}
					case 19:
					{
						val = intuition(i.uv);
						break;
					}
					case 20:
					{
						val = the_stone(i.uv);
						break;
					}
					case 21:
					{
						val = the_mountain(i.uv);
						break;
					}
					case 22:
					{
						val = the_shadow(i.uv);
						break;
					}
					case 23:
					{
						val = opposite(i.uv);
						break;
					}
					case 24:
					{
						val = the_oak(i.uv);
						break;
					}
					case 25:
					{
						val = ripples(i.uv);
						break;
					}
					case 26:
					{
						val = the_empress(i.uv);
						break;
					}
					case 27:
					{
						val = bundle(i.uv);
						break;
					}
					case 28:
					{
						val = the_devil(i.uv);
						break;
					}
					case 29:
					{
						val = the_sun(i.uv);
						break;
					}
					case 30:
					{
						val = the_star(i.uv);
						break;
					}
					case 31:
					{
						val = judgement(i.uv);
						break;
					}
				}

				col = lerp(col, strokeCol, val);
				return col;
			}
			ENDCG
		}
	}
}

