Shader "mSubspace/DitheredLambert"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Quantization ("Quantization", Range(1, 255)) = 8
        _Tightness ("Tightness", Range(0.01, 8)) = 0.5
        //_NoiseSmallness ("Noise Smallness", Range(0.01, 500)) = 100
        [Toggle(_ENABLE)] _Enable ("Enable", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf DitheredLambert fullforwardshadows
        #pragma vertex vert 
        #pragma shader_feature _ENABLE

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        #include "Libraries/Lighting.cginc"
        #include "Libraries/NoisePerlin3D.cginc"

        sampler2D _MainTex;

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Quantization;
        float _Tightness;
        //float _NoiseSmallness;
        float _Enable;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        struct Input
        {
            float2 uv_MainTex : TEXCOORD0;
            float3 worldPos   : TEXCOORD1;
        };
 
         struct SurfaceOutputCustom
         {
             fixed3 Albedo;
             fixed3 Normal;
             fixed3 Emission;
             half Specular;
             fixed Gloss;
             fixed Alpha;
             fixed3 worldPos;
         };
 
         void vert(inout appdata_full v, out Input o)
         {
             UNITY_INITIALIZE_OUTPUT(Input,o);
             o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
         }

        void surf (Input IN, inout SurfaceOutputCustom o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.worldPos = IN.worldPos;
            // Metallic and smoothness come from slider variables
            o.Alpha = c.a;
        }

        #define MOD3 float3(443.8975,397.2973, 491.1871)
        float hash13(float3 p)
        {
            float3 p3  = frac(p * MOD3);
            p3 += dot(p3, p3.yzx + 19.19);
            return frac(p3.x * p3.z * p3.y);
        }

        float3 quantize(float3 val, int steps)
        {
            // saturate val to make sure it's in 0-1 range.
            // another way to look at this is:
            // floor(val / (1/steps)) * (1/steps)
            return floor(saturate(val) * steps) / steps;
        }

        float4 LightingDitheredLambert(SurfaceOutputCustom s, float3 lightDir, float atten)
        {
            float3 v = s.worldPos + frac(_Time.y);

            float rnd = hash13( -v * 7.11 ) + hash13( v + 3.1337 ) - 0.5;
            rnd = clamp(rnd, 0, 1);

            #if _ENABLE
                float qrnd = rnd / (_Quantization * _Tightness);
            #else
                float qrnd = 0;
            #endif

            float3 c = HalfLambert(s.Normal, lightDir) * s.Albedo * atten * _LightColor0;
            //c = quantize(c + n, _Quantization); // weird effect
            c = quantize(c + qrnd, _Quantization);
            return float4(c, 1);
        }

        ENDCG
    }
    FallBack "Diffuse"
}
