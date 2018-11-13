Shader "Mario/Quad/Cool Grid"
{
	Properties
	{
		_TileX ("Tile Size X", Float) = 1.0
		_TileY ("Tile Size Y", Float) = 1.0
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

			uniform float _TileX;
			uniform float _TileY;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// Re-map space depending to tiling factors.
				float x = i.uv.x * _TileX;
				float y = i.uv.y * _TileY;

				// Get the derivatives to smooth the edges.
				float dx = ddx(x);
				float dy = ddy(y);

				// Repeat coordinate space.
				// modding messes up the derivate, so it's done after that.
				i.uv.x = fmod(x, 1);
				i.uv.y = fmod(y, 1);

				float val;
				float4 col = fixed4(1, 1, 1, 1);
				fixed4 strokeCol = fixed4(0.3, 0.3, 0.5, 1);

				val = 1 - smoothstep(0.1 - dx, 0.1 + dx, i.uv.x);
				col = lerp(col, strokeCol, val);

				val = smoothstep(0.9 - dx, 0.9 + dx, i.uv.x);
				col = lerp(col, strokeCol, val);

				val = 1 - smoothstep(0.1 - dy, 0.1 + dy, i.uv.y);
				col = lerp(col, strokeCol, val);

				val = smoothstep(0.9 - dy, 0.9 + dy, i.uv.y);
				col = lerp(col, strokeCol, val);

				return col;
			}
			ENDCG
		}
	}
}

