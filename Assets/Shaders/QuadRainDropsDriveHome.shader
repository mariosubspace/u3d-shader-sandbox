Shader "Hidden/QuadRainDropsDriveHome"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off// ZWrite Off ZTest Always

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

			fixed2 Rain(fixed2 uv, fixed t)
			{
				fixed2 aspect0 = fixed2(4., 1.);
				fixed2 st0 = uv * aspect0;
				fixed2 id0 = floor(st0);
				fixed n0 = frac(sin(id0.x * 1345.4) * 345.3);
				st0 = st0 + fixed2(0, t*0.45 + n0);
				id0 = floor(st0); // recalulate id for pixel after moving uv.
				st0 = frac(st0) - 0.5; // center individual coordinate system.
				
				fixed n1 = frac(sin(id0.x * 1445.4 + id0.y * 245.1) * 2345.3) * 6.28;
				fixed t0 = t + n1;
				fixed y = -sin(t0 + sin(t0 + sin(t0))) * .42;
				fixed2 dropUV0 = (st0 - fixed2(0., y)) / aspect0;
				fixed d0 = length(dropUV0);
				
				fixed mask0 = smoothstep(.08, 0, d0);

				//fixed edges0 = max(
				//	step(0.45, st0.x),
				//	step(0.48, st0.y)
				//);

				fixed2 aspect1 = aspect0 * fixed2(1, 6);
				fixed2 st1 = uv * aspect1;
				st1 = frac(st1 + fixed2(0, n0)) - 0.5;
				fixed2 dropUV1 = st1 / aspect1;
				fixed d1 = length(dropUV1);

				fixed mask1 = smoothstep(.1 * (0.5 - st0.y), 0, d1) * smoothstep(y, y + 0.1, st0.y);
				
				return max(mask0 * dropUV0, dropUV1 * mask1);
			}

			fixed2 RainDist(fixed2 uv, fixed t)
			{
				fixed2 aspect0 = fixed2(4., 1.);
				fixed2 st0 = uv * aspect0;
				fixed2 id0 = floor(st0);
				fixed n0 = frac(sin(id0.x * 1345.4) * 345.3);
				st0 = st0 + fixed2(0, t*0.45 + n0);
				id0 = floor(st0); // recalulate id for pixel after moving uv.
				st0 = frac(st0) - 0.5; // center individual coordinate system.

				fixed n1 = frac(sin(id0.x * 1445.4 + id0.y * 245.1) * 2345.3) * 6.28;
				fixed t0 = t + n1;
				fixed y = -sin(t0 + sin(t0 + sin(t0))) * .42;
				fixed2 dropUV0 = (st0 - fixed2(0., y)) / aspect0;
				fixed d0 = length(dropUV0);

				fixed mask0 = smoothstep(.08, 0, d0);

				fixed2 aspect1 = aspect0 * fixed2(1, 6);
				fixed2 st1 = uv * aspect1;
				st1 = frac(st1 + fixed2(0, n0)) - 0.5;
				fixed2 dropUV1 = st1 / aspect1;
				fixed d1 = length(dropUV1);

				fixed mask1 = smoothstep(.1 * (0.5 - st0.y), 0, d1) * smoothstep(y, y + 0.1, st0.y);

				return max(mask0, mask1);
			}

            fixed4 frag (v2f i) : SV_Target
            {
				fixed2 rain = Rain(i.uv * 4., _Time.y * 3);
				fixed rainDist = RainDist(i.uv * 4., _Time.y * 3);
				fixed a = min(step(rainDist, 0.1), step(0.0001, rainDist));
				return fixed4(a, a, a, 1);
				return fixed4(rain*20, 0, 1);
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = 1 - col.rgb;
                return col;
            }
            ENDCG
        }
    }
}
