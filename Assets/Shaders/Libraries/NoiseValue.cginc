#ifndef NOISE_VALUE_CGINC
#define NOISE_VALUE_CGINC

#include "NoiseSimple.cginc"

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

/////////////////////////////////////
// The MIT License
// Copyright © 2017 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Value    Noise 2D, Derivatives: https://www.shadertoy.com/view/4dXBRH
// Value    Noise 3D, Derivatives: https://www.shadertoy.com/view/XsXfRH
// Value    Noise 2D             : https://www.shadertoy.com/view/lsf3WH
// Value    Noise 3D             : https://www.shadertoy.com/view/4sfGzS
/////////////////////////////////////

float hash_vn( in float2 p )  // replace this by something better [Inigo's comment]
{
    p  = 50.0*frac( p*0.3183099 + float2(0.71,0.113));
    return -1.0+2.0*frac( p.x*p.y*(p.x+p.y) );
}

float hash_vn(float3 p)  // replace this by something better
{
    p  = 50.0*frac( p*0.3183099 + float3(0.71,0.113,0.419));
    return -1.0+2.0*frac( p.x*p.y*p.z*(p.x+p.y+p.z) );
}

float hash_vn_2(float3 p)  // replace this by something better
{
    p  = frac( p*0.3183099+.1 );
	p *= 17.0;
    return frac( p.x*p.y*p.z*(p.x+p.y+p.z) );
}

// Noise - Value - 2D - Deriv
//
// Value noise (in x) and its derivatives (in yz)
// Computes the analytic derivatives of a 2D Value Noise. This can be used for example to compute normals to a
// terrain based on Value Noise without approximating the gradient by having to take central differences (see
// this shader: https://www.shadertoy.com/view/MdsSRs)
float3 vnoise_d( in float2 p )
{
    float2 i = floor( p );
    float2 f = frac( p );
	
#if 1
    // quintic interpolation
    float2 u = f*f*f*(f*(f*6.0-15.0)+10.0);
    float2 du = 30.0*f*f*(f*(f-2.0)+1.0);
#else
    // cubic interpolation
    float2 u = f*f*(3.0-2.0*f);
    float2 du = 6.0*f*(1.0-f);
#endif    
    
    float va = hash_vn( i + float2(0.0,0.0) );
    float vb = hash_vn( i + float2(1.0,0.0) );
    float vc = hash_vn( i + float2(0.0,1.0) );
    float vd = hash_vn( i + float2(1.0,1.0) );
    
    float k0 = va;
    float k1 = vb - va;
    float k2 = vc - va;
    float k4 = va - vb - vc + vd;

    return float3( va+(vb-va)*u.x+(vc-va)*u.y+(va-vb-vc+vd)*u.x*u.y, // value
                 du*(u.yx*(va-vb-vc+vd) + float2(vb,vc) - va) );     // derivative                
}

// Noise - Value - 3D - Deriv
//
// Computes the analytic derivatives of a 3D Value Noise. This can be used for example to compute normals to a
// 3d rocks based on Value Noise without approximating the gradient by haveing to take central differences (see
// this shader: https://www.shadertoy.com/view/XttSz2)
//
// return value noise (in x) and its derivatives (in yzw)
float4 vnoise_d( in float3 x )
{
    float3 p = floor(x);
    float3 w = frac(x);
    
#if 1
    // quintic interpolation
    float3 u = w*w*w*(w*(w*6.0-15.0)+10.0);
    float3 du = 30.0*w*w*(w*(w-2.0)+1.0);
#else
    // cubic interpolation
    float3 u = w*w*(3.0-2.0*w);
    float3 du = 6.0*w*(1.0-w);
#endif
    
    float a = hash_vn(p+float3(0.0,0.0,0.0));
    float b = hash_vn(p+float3(1.0,0.0,0.0));
    float c = hash_vn(p+float3(0.0,1.0,0.0));
    float d = hash_vn(p+float3(1.0,1.0,0.0));
    float e = hash_vn(p+float3(0.0,0.0,1.0));
	float f = hash_vn(p+float3(1.0,0.0,1.0));
    float g = hash_vn(p+float3(0.0,1.0,1.0));
    float h = hash_vn(p+float3(1.0,1.0,1.0));
	
    float k0 =   a;
    float k1 =   b - a;
    float k2 =   c - a;
    float k3 =   e - a;
    float k4 =   a - b - c + d;
    float k5 =   a - c - e + g;
    float k6 =   a - b - e + f;
    float k7 = - a + b + c - d + e - f - g + h;

    return float4( k0 + k1*u.x + k2*u.y + k3*u.z + k4*u.x*u.y + k5*u.y*u.z + k6*u.z*u.x + k7*u.x*u.y*u.z, 
                 du * float3( k1 + k4*u.y + k6*u.z + k7*u.y*u.z,
                            k2 + k5*u.z + k4*u.x + k7*u.z*u.x,
                            k3 + k6*u.x + k5*u.y + k7*u.x*u.y ) );
}

// Noise - value - 2D 
//
// Value Noise (http://en.wikipedia.org/wiki/Value_noise), not to be confused with Perlin's
// Noise, is probably the simplest way to generate noise (a random smooth signal with 
// mostly all its energy in the low frequencies) suitable for procedural texturing/shading,
// modeling and animation.
//
// It produces lowe quality noise than Gradient Noise (https://www.shadertoy.com/view/XdXGW8)
// but it is slightly faster to compute. When used in a fracal construction, the blockyness
// of Value Noise gets qcuikly hidden, making it a very popular alternative to Gradient Noise.
//
// The princpiple is to create a virtual grid/latice all over the plane, and assign one
// random value to every vertex in the grid. When querying/requesting a noise value at
// an arbitrary point in the plane, the grid cell in which the query is performed is
// determined (line 30), the four vertices of the grid are determined and their random
// value fetched (lines 35 to 38) and then bilinearly interpolated (lines 35 to 38 again)
// with a smooth interpolant (line 31 and 33).
float vnoise( in float2 p )
{
    float2 i = floor( p );
    float2 f = frac( p );
	
	float2 u = f*f*(3.0-2.0*f);

    return lerp( lerp( hash_vn( i + float2(0.0,0.0) ), 
                       hash_vn( i + float2(1.0,0.0) ), u.x),
                 lerp( hash_vn( i + float2(0.0,1.0) ), 
                       hash_vn( i + float2(1.0,1.0) ), u.x), u.y);
}

// Noise - value - 3D
// The version on Shadertoy uses a LUT to make it faster.
float vnoise( in float3 x )
{
    float3 p = floor(x);
    float3 f = frac(x);
    f = f*f*(3.0-2.0*f);
	
    return lerp(lerp(lerp( hash_vn_2(p+float3(0,0,0)), 
                           hash_vn_2(p+float3(1,0,0)),f.x),
                     lerp( hash_vn_2(p+float3(0,1,0)), 
                           hash_vn_2(p+float3(1,1,0)),f.x),f.y),
                lerp(lerp( hash_vn_2(p+float3(0,0,1)), 
                           hash_vn_2(p+float3(1,0,1)),f.x),
                     lerp( hash_vn_2(p+float3(0,1,1)), 
                           hash_vn_2(p+float3(1,1,1)),f.x),f.y),f.z);
}

#endif
