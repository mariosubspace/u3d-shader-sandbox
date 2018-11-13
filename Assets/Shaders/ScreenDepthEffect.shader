Shader "Mario/Screen/Depth Effect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

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

			float stroke(float x, float s, float w)
			{
				float half_w = 0.5*w;
				float d = step(s, x + half_w) -
				          step(s, x - half_w);
				return saturate(d);
			}
			
			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;

			fixed4 frag (v2f i) : SV_Target
			{
				float rawDepth = DecodeFloatRG(tex2D(_CameraDepthTexture, i.uv));
				float linearDepth = Linear01Depth(rawDepth);
				float maskOutFarPlane = step(0.1, 1 - linearDepth);
				float effectVal = (stroke(sin(linearDepth*3.14159*60 - _Time.y)*0.15 + 0.85, 0.85, 0.25)) * (1 - linearDepth*0.25);
				effectVal *= maskOutFarPlane;
				// just invert the colors
				fixed4 col = fixed4(step(0.99, 1 - effectVal) + effectVal.xxx, 1);
				return col;
			}
			ENDCG
		}
	}
}
