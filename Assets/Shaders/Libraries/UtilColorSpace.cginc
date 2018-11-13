#ifndef UTIL_COLOR_SPACE_CGINC
#define UTIL_COLOR_SPACE_CGINC

#include "ConstantsMath.cginc"

// Found at http://thebookofshaders.com/06/

float3 rgb_to_hsb(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 0.0000000001;
    return float3(
    	abs(q.z + (q.w - q.y) / (6.0 * d + e)),
    	d / (q.x + e),
    	q.x );
}

//  Function from Iñigo Quiles 
//  https://www.shadertoy.com/view/MsS3Wc
float3 hsb_to_rgb(float3 c)
{
	float3 rgbCol = saturate(abs(fmod(c.x*6.0 + float3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0);
	rgbCol = rgbCol*rgbCol*(3.0 - 2.0*rgbCol);
	return c.z * lerp(float3(1, 1, 1), rgbCol, c.y);
}

// Test with this code.
// i.uv = i.uv - 0.5;
// return float4(yuv_to_rgb(float3(0.5, i.uv.x, i.uv.y)), 1);
float3 yuv_to_rgb(float3 yuvCol)
{
	return float3(
		yuvCol.x +                    1.13983*yuvCol.z,
		yuvCol.x - 0.39465*yuvCol.y - 0.58060*yuvCol.z,
		yuvCol.x + 2.03211*yuvCol.y
	);
}

// Values from http://thebookofshaders.com/08/
float3 rgb_to_yuv(float3 rgbCol)
{
	return float3(
		 0.21260*rgbCol.x + 0.71520*rgbCol.y + 0.07220*rgbCol.z,
		-0.09991*rgbCol.x - 0.33609*rgbCol.y + 0.43600*rgbCol.z,
		 0.61500*rgbCol.x - 0.55860*rgbCol.y - 0.05639*rgbCol.z
	);
}

// We map x (0.0 - 1.0) to the hue (0.0 - 1.0)
// And the y (0.0 - 1.0) to the brightness
float3 map_hsb(float2 uv)
{
	return hsb_to_rgb(float3(uv.x, 1.0, uv.y));
}

float3 map_hsb_polar(float2 uv)
{
	// Use polar coordinates instead of cartesian
	float2 toCenter = float2(0.5, 0.5) - uv;
	float angle = atan2(toCenter.y, toCenter.x);
	float radius = length(toCenter)*2.0;

	// Map the angle (-PI to PI) to the Hue (from 0 to 1)
	// and the Saturation to the radius
	return hsb_to_rgb(float3((angle/TWO_PI) + 0.5, radius, 1.0));
}

#endif
