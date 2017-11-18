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

			uniform float _Index;
			uniform float4 _BackgroundColor;
			uniform float4 _ForegroundColor;


			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
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
				}

				col = lerp(col, strokeCol, val);
				return col;
			}
			ENDCG
		}
	}
}

