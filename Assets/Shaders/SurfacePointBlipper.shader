Shader "Mario/Surface/Point Blipper"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Frequency ("Frequency", Float) = 3
		_Speed ("Speed", Float) = 5
		_EmissionColor ("Emission Color", Color) = (1, 1, 1, 1)
		_EmissionBoost ("Emission Boost", Float) = 3
	}

	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows alpha
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
		};


		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		uniform float4 hitPosition;
		uniform float hitStrength;
		float _Frequency;
		float _Speed;
		float4 _EmissionColor;
		float _EmissionBoost;

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

			fixed d = 1;
			fixed s = 0;

			d = clamp(distance(IN.worldPos, hitPosition.xyz), 0, 1);

			s = sin((1 - d*d) *(_Frequency*(1 - d)) + _Time.y * _Speed) * 0.5 + 0.5;
			s = smoothstep(0.5 - 0.01, 0.5 + 0.01, s); 

			o.Emission = _EmissionColor * s * hitStrength * (1 - d) * _EmissionBoost;
			o.Albedo = fixed3(0, 0, 0);
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
