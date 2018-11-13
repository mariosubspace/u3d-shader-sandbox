#ifndef NOISE_SIMPLE_CGINC
#define NOISE_SIMPLE_CGINC

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

uint wang_hash(uint seed)
{
	seed = (seed ^ 61) ^ (seed >> 16);
	seed *= 9;
	seed = seed ^ (seed >> 4);
	seed *= 0x27d4eb2d;
	seed = seed ^ (seed >> 15);
	return seed;
}

#endif
