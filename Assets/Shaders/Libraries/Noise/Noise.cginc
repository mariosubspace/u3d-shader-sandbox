#ifndef NOISE_CGINC
#define NOISE_CGINC

/////////////////////////////////////
///// RANDOMNESS
/////////////////////////////////////

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

/////////////////////////////////////
///// NOISE (Value noise)
///// This is interpolation between random values, leads to a blocky look.
/////////////////////////////////////

float vnoise_simple_linear(float x)
{
	float i = floor(x);
	float f = frac(x);

	// Interpolate linearly between one discreet integer value to the next.
	return lerp(rand_simple(i), rand_simple(i + 1.), f);
}

float vnoise_simple_smooth(float x)
{
	float i = floor(x);
	float f = frac(x);

	// Interpolate linearly between one discreet integer value to the next.
	return lerp(rand_simple(i), rand_simple(i + 1.), smoothstep(0., 1., f));
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float vnoise_simple_smooth(float2 uv)
{
	float2 i = floor(uv);
	float2 f = frac(uv);

	// Sample random at four corners of unit square
	float a = rand_simple(i);     // (0, 0) BL
	float b = rand_simple(i + float2(1, 0)); // (1, 0) BR
	float c = rand_simple(i + float2(0, 1)); // (0, 1) TL
	float d = rand_simple(i + float2(1, 1)); // (1, 1) TR

	// Cubic Hermine Curve.  Same as SmoothStep()
    //float2 u = f*f*(3.0-2.0*f);
	float2 u = smoothstep(0., 1., f);

	// Interpolate value at given point.
	return lerp(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float vnoise_simple_linear(float2 uv)
{
	float2 i = floor(uv);
	float2 f = frac(uv);

	// Sample random at four corners of unit square
	float a = rand_simple(i);     // (0, 0) BL
	float b = rand_simple(i + float2(1, 0)); // (1, 0) BR
	float c = rand_simple(i + float2(0, 1)); // (0, 1) TL
	float d = rand_simple(i + float2(1, 1)); // (1, 1) TR

	float2 u = lerp(0., 1., f);

	// Interpolate value at given point.
	return lerp(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

#endif
