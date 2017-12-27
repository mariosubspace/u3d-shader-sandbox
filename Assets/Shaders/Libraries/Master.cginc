#ifndef MASTER_CGINC
#define MASTER_CGINC

#include "FlongFunctions.cginc"
#include "InigoFunctions.cginc"
#include "PixelSpirit.cginc"
#include "Easings.cginc"
#include "ColorSpace.cginc"
#include "Noise/Noise.cginc"
#include "Noise/InigoNoise.cginc"

/////////////////////////////////////
///// Personal Functions
/////////////////////////////////////

float is_odd(float n)
{
	return step(1.0, fmod(n, 2.0));
}

float is_even(float n)
{
	return floor(fmod(n, 2.0));
}

float checkerboard(float2 uv, float size)
{
	float4 tiled = tile_space(uv, size);
	uv = tiled.xy; 

	float eo = is_even(tiled.w) + is_even((size - 1) - tiled.z);
	eo = (1.0 - step(1.001, eo)) * eo;
	return eo;
}

// A sawtooth pattern.
// Outputs 0 -> 1 from inputs 0 -> 0.5, then 1 -> 0 from inputs 0.5 -> 1, repeats outside that range.
// Input [0, 1] repeating, output [0, 1] repeating
float sawtooth(float x)
{
	return 1.0 - abs(2.0 * fmod(x, 1.0) - 1.0);
}

// Modification of Blinn-Wyvill Approximation.
// Input [0, 1] repeating, output [0, 1] repeating
float cos_approx(float x)
{
	// See: sawtooth.
	x = 1.0 - abs(2.0 * fmod(x, 1.0) - 1.0);

	float x2 = x*x;
	float x4 = x2*x2;
	float x6 = x4*x2;

	float fa = ( 4.0/9.0);
	float fb = (17.0/9.0);
	float fc = (22.0/9.0);

	return fa*x6 - fb*x4 + fc*x2;
}

float draw_point(float2 p, float width, float2 uv)
{
	return 1.0 - step(width, distance(uv, p));
}

float draw_point_smooth(float2 p, float width, float2 uv)
{
	float d = distance(uv, p);
	float gradD = length(float2(ddx(d), ddy(d)));
	float z = 1.0 - smoothstep(width - gradD, width + gradD, d);
	return z;
}

#endif
