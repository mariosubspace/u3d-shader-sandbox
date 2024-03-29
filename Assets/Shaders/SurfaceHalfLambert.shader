Shader "mSubspace/Opaque/Half-Lambert"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf HalfLambert fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        #include "Libraries/Lighting.cginc"

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Alpha = c.a;
        }

        float4 LightingHalfLambert(SurfaceOutput s, float3 lightDir, float atten)
        {
            float3 col = 
                // Half-Lambert base intensity.
                HalfLambert(s.Normal, lightDir)
                // Point light attenuation (one website multiplies this by 2, why?)
                // Matches regular lambert intensity more just keeping it alone.
                * atten
                // Factor in light color.
                * _LightColor0.rgb
                // Factor in surface color.
                * s.Albedo;
            return float4(col, 1);
        }

        ENDCG
    }
    FallBack "Diffuse"
}
