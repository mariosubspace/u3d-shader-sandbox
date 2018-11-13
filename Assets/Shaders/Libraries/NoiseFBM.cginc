#ifndef NOISE_FBM_CGINC
#define NOISE_FBM_CGINC

// FBM - Fractal Brownian Motion

#include "NoiseValue.cginc"
#include "NoiseSimplex2D.cginc"

// 2D fBm (using linear value noise).
// octaves (how many times to repeat)
// lacunarity (the step size, how far apart each octave is)
// gain (how much each octave's amplitude is diminished for each step)
// amplitude (the major amplitude)
// frequency (the major frequency)
float vlfbm(in float2 uv, int octaves, float lacunarity, float gain, float amplitude, float2 frequency)
{
    float y = 0.0;

    for (int i = 0; i < octaves; ++i)
    {
        y += amplitude * vnoise_simple_linear(uv * frequency);
        frequency *= lacunarity;
        amplitude *= gain;
    }
    return y;
}

// 2D fBm (using smooth value noise).
// octaves (how many times to repeat)
// lacunarity (the step size, how far apart each octave is)
// gain (how much each octave's amplitude is diminished for each step)
// amplitude (the major amplitude)
// frequency (the major frequency)
float vsfbm(in float2 uv, int octaves, float lacunarity, float gain, float amplitude, float2 frequency)
{
    float y = 0.0;

    for (int i = 0; i < octaves; ++i)
    {
        y += amplitude * vnoise_simple_smooth(uv * frequency);
        frequency *= lacunarity;
        amplitude *= gain;
    }
    return y;
}

// 2D turbulence fBm (using smooth value noise).
// octaves (how many times to repeat)
// lacunarity (the step size, how far apart each octave is)
// gain (how much each octave's amplitude is diminished for each step)
// amplitude (the major amplitude)
// frequency (the major frequency)
float vstfbm(in float2 uv, int octaves, float lacunarity, float gain, float amplitude, float2 frequency)
{
    float y = 0.0;

    for (int i = 0; i < octaves; ++i)
    {
        y += amplitude * abs(2*vnoise_simple_smooth(uv * frequency) - 1);
        frequency *= lacunarity;
        amplitude *= gain;
    }
    return y;
}

// 2D ridge fBm (using smooth value noise).
// octaves (how many times to repeat)
// lacunarity (the step size, how far apart each octave is)
// gain (how much each octave's amplitude is diminished for each step)
// amplitude (the major amplitude)
// frequency (the major frequency)
// ridge sharpness
float vsrfbm(in float2 uv, int octaves, float lacunarity, float gain, float amplitude, float2 frequency, float sharpness)
{
    float y = 0.0;

    for (int i = 0; i < octaves; ++i)
    {
    	float n = abs(2*vnoise_simple_smooth(uv * frequency) - 1);
    	n = 1. - n;
    	n = pow(n, sharpness);
        y += amplitude * n;
        frequency *= lacunarity;
        amplitude *= gain;
    }

    return y;
}

// 2D fBm (using simplex noise).
// octaves (how many times to repeat)
// lacunarity (the step size, how far apart each octave is)
// gain (how much each octave's amplitude is diminished for each step)
// amplitude (the major amplitude)
// frequency (the major frequency)
float sfbm(in float2 uv, int octaves, float lacunarity, float gain, float amplitude, float2 frequency)
{
    float y = 0.0;

    for (int i = 0; i < octaves; ++i)
    {
        y += amplitude * snoise(uv * frequency);
        frequency *= lacunarity;
        amplitude *= gain;
    }
    return y;
}

#endif
