#ifndef MASTER_CG
#define MASTER_CG

#include "FlongFunctionsCG.cginc"
#include "InigoFunctionsCG.cginc"
#include "PixelSpiritCG.cginc"
#include "EasingsCG.cginc"
#include "ColorSpaceCG.cginc"

///// From: The Book of Shaders

float plot_line(float y, float width, float2 uv)
{
	return smoothstep(y - width, y, uv.y) - smoothstep(y, y + width, uv.y);
}

float line_segment(float2 uv, float2 a, float2 b, float width, float fuzziness)
{
	float2 uva = uv - a;
	float2 ba = b - a;
	// Partial calculation for projection of A->UV to A->B.
	float h = clamp(dot(uva, ba)/dot(ba, ba), 0.0, 1.0);

	// This is the perpendicular distance from the current UV point to the line.
	//    ba*h is the projected line A->UV onto A->B. Subtracting this from A->UV
	//    leaves the perpendicular component.
	float d = length(uva - ba*h);
	// Use smoothstep to threshold this, the inversion gives the final line.
	return 1.0 - smoothstep(width - fuzziness, width + fuzziness, d);
}

// Auto-smoothed with gradient trick.
float line_segment(float2 uv, float2 a, float2 b, float width)
{
	float2 uva = uv - a;
	float2 ba = b - a;
	// Partial calculation for projection of A->UV to A->B.
	float h = clamp(dot(uva, ba)/dot(ba, ba), 0.0, 1.0);

	// This is the perpendicular distance from the current UV point to the line.
	//    ba*h is the projected line A->UV onto A->B. Subtracting this from A->UV
	//    leaves the perpendicular component.
	float d = length(uva - ba*h);
	float grad = length(float2(ddx(d), ddy(d)));
	// Use smoothstep to threshold this, the inversion gives the final line.
	return 1.0 - smoothstep(width - grad, width + grad, d);
}

// http://thebookofshaders.com/07/
float circle_fast(float2 uv, float radius)
{
	float2 dist = uv - float2(0.5, 0.5);
	return 1.0 - smoothstep(radius - (radius*0.01), radius + (radius*0.01), dot(dist, dist)*4.0);
}

float2 as_polar(float2 uv, float2 center)
{
	float2 pos = center - uv;
    float r = length(pos)*2.0;
    float a = atan2(pos.y, pos.x);
    return float2(r, a);
}

// Rotates the space. It will rotate around the origin, so make sure
// you move what you want to rotate to the center then move back after. 
float2x2 rotate_mat(float angle)
{
	return float2x2(
		cos(angle), -sin(angle),
		sin(angle),  cos(angle)
	);
}

float2x2 scale_mat(float2 s)
{
	return float2x2(
		s.x, 0.0,
		0.0, s.y
	);
}

float2 rotate(float2 uv, float angle)
{
	return float2(
		uv.x*cos(angle) - uv.y*sin(angle),
		uv.x*sin(angle) + uv.y*cos(angle)
	);
}

float2 scale(float2 uv, float2 s)
{
	return float2(uv.x*s.x, uv.y*s.y);
}

float2 scale(float2 uv, float s)
{
	return uv*s;
}

// Returns scaled UVs (xy) and x,y tile index (zw).
float4 tile_space(float2 uv, float times)
{
	float2 scaledUV = uv * times;
	return float4(frac(scaledUV), floor(scaledUV));
}



// Gaussian-ish.
float rand_simple(float t, float noisyness)
{
	return frac(sin(t) * 1000000. * noisyness);
}

// Gaussian-ish.
float rand_simple(float t)
{
	// 1,000,000 is a good default frequency for the noise.
	// lower and you still might get some of the pattern of the sine.
	return rand_simple(t, 1.);
}

// 2D noise version.
float rand_simple(float2 uv)
{
	// These magic numbers don't mean much, they're random.
	return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453123);
}

float rand_simple(float2 uv, float2 seed)
{
	// These magic numbers don't mean much, they're random.
	return frac(sin(dot(uv, seed))*43758.5453123);
}

float rand_simple(float2 uv, float noisyness)
{
	// These magic numbers don't mean much, they're random.
	return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453123*noisyness);
}

float rand_simple(float2 uv, float2 seed, float noisyness)
{
	// These magic numbers don't mean much, they're random.
	return frac(sin(dot(uv, seed))*43758.5453123*noisyness);
}

// Skewed toward 0.
float rand_simple_sq(float t)
{
	float v = rand_simple(t);
	return v*v;
}

///// Personal Functions

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
