#ifndef NOISE_GRADIENT_CGINC
#define NOISE_GRADIENT_CGINC

// The MIT License
// Copyright © 2017 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Gradient Noise 2D, Derivatives: https://www.shadertoy.com/view/XdXBRH
// Gradient Noise 3D, Derivatives: https://www.shadertoy.com/view/4dffRH
// Gradient Noise 2D             : https://www.shadertoy.com/view/XdXGW8
// Gradient Noise 3D             : https://www.shadertoy.com/view/Xsl3Dl

/////////////////////////////////////
///// GRADIENT NOISE
/////////////////////////////////////

float2 hash_gn( float2 x )  // replace this by something better [Inigo's comment]
{
    float2 k = float2( 0.3183099, 0.3678794 );
    x = x*k + k.yx;
    return -1.0 + 2.0*frac( 16.0 * k*frac( x.x*x.y*(x.x+x.y)) );
}

float3 hash_gn( float3 p ) // replace this by something better. really. do [Inigo's comment]
{
	p = float3( dot(p,float3(127.1,311.7, 74.7)),
			    dot(p,float3(269.5,183.3,246.1)),
			    dot(p,float3(113.5,271.9,124.6)));

	return -1.0 + 2.0*frac(sin(p)*43758.5453123);
}

// Noise - Gradient - 2D - Deriv 
//
// Computes the analytic derivatives of a 2D Gradient Noise
//
// return gradient noise (in x) and its derivatives (in yz)
float3 gnoise_d( in float2 p )
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
    
    float2 ga = hash_gn( i + float2(0.0,0.0) );
    float2 gb = hash_gn( i + float2(1.0,0.0) );
    float2 gc = hash_gn( i + float2(0.0,1.0) );
    float2 gd = hash_gn( i + float2(1.0,1.0) );
    
    float va = dot( ga, f - float2(0.0,0.0) );
    float vb = dot( gb, f - float2(1.0,0.0) );
    float vc = dot( gc, f - float2(0.0,1.0) );
    float vd = dot( gd, f - float2(1.0,1.0) );

    return float3( va + u.x*(vb-va) + u.y*(vc-va) + u.x*u.y*(va-vb-vc+vd),   // value
                 ga + u.x*(gb-ga) + u.y*(gc-ga) + u.x*u.y*(ga-gb-gc+gd) +  // derivatives
                 du * (u.yx*(va-vb-vc+vd) + float2(vb,vc) - va));
}

// Noise - Gradient - 3D - Deriv
//
// Computes the analytic derivatives of a 3D Gradient Noise. This can be used for example to compute normals to a
// 3d rocks based on Gradient Noise without approximating the gradient by having to take central differences. More
// info here: http://iquilezles.org/www/articles/gradientnoise/gradientnoise.htm
//
// return value noise (in x) and its derivatives (in yzw)
float4 gnoise_d( in float3 x )
{
    // grid
    float3 p = floor(x);
    float3 w = frac(x);
    
    #if 1
    // quintic interpolant
    float3 u = w*w*w*(w*(w*6.0-15.0)+10.0);
    float3 du = 30.0*w*w*(w*(w-2.0)+1.0);
    #else
    // cubic interpolant
    float3 u = w*w*(3.0-2.0*w);
    float3 du = 6.0*w*(1.0-w);
    #endif    
    
    // gradients
    float3 ga = hash_gn( p+float3(0.0,0.0,0.0) );
    float3 gb = hash_gn( p+float3(1.0,0.0,0.0) );
    float3 gc = hash_gn( p+float3(0.0,1.0,0.0) );
    float3 gd = hash_gn( p+float3(1.0,1.0,0.0) );
    float3 ge = hash_gn( p+float3(0.0,0.0,1.0) );
	float3 gf = hash_gn( p+float3(1.0,0.0,1.0) );
    float3 gg = hash_gn( p+float3(0.0,1.0,1.0) );
    float3 gh = hash_gn( p+float3(1.0,1.0,1.0) );
    
    // projections
    float va = dot( ga, w-float3(0.0,0.0,0.0) );
    float vb = dot( gb, w-float3(1.0,0.0,0.0) );
    float vc = dot( gc, w-float3(0.0,1.0,0.0) );
    float vd = dot( gd, w-float3(1.0,1.0,0.0) );
    float ve = dot( ge, w-float3(0.0,0.0,1.0) );
    float vf = dot( gf, w-float3(1.0,0.0,1.0) );
    float vg = dot( gg, w-float3(0.0,1.0,1.0) );
    float vh = dot( gh, w-float3(1.0,1.0,1.0) );
	
    // interpolations
    return float4( va + u.x*(vb-va) + u.y*(vc-va) + u.z*(ve-va) + u.x*u.y*(va-vb-vc+vd) + u.y*u.z*(va-vc-ve+vg) + u.z*u.x*(va-vb-ve+vf) + (-va+vb+vc-vd+ve-vf-vg+vh)*u.x*u.y*u.z,    // value
                 ga + u.x*(gb-ga) + u.y*(gc-ga) + u.z*(ge-ga) + u.x*u.y*(ga-gb-gc+gd) + u.y*u.z*(ga-gc-ge+gg) + u.z*u.x*(ga-gb-ge+gf) + (-ga+gb+gc-gd+ge-gf-gg+gh)*u.x*u.y*u.z +   // derivatives
                 du * (float3(vb,vc,ve) - va + u.yzx*float3(va-vb-vc+vd,va-vc-ve+vg,va-vb-ve+vf) + u.zxy*float3(va-vb-ve+vf,va-vb-vc+vd,va-vc-ve+vg) + u.yzx*u.zxy*(-va+vb+vc-vd+ve-vf-vg+vh) ));
}

// Noise - gradient - 2D 
//
// Gradient Noise (http://en.wikipedia.org/wiki/Gradient_noise), not to be confused with
// Value Noise, and neither with Perlin's Noise (which is one form of Gradient Noise)
// is probably the most convenient way to generate noise (a random smooth signal with 
// mostly all its energy in the low frequencies) suitable for procedural texturing/shading,
// modeling and animation.
//
// It produces smoother and higher quality than Value Noise, but it's of course slighty more
// expensive.
//
// The princpiple is to create a virtual grid/latice all over the plane, and assign one
// random vector to every vertex in the grid. When querying/requesting a noise value at
// an arbitrary point in the plane, the grid cell in which the query is performed is
// determined (line 32), the four vertices of the grid are determined and their random
// vectors fetched (lines 37 to 40). Then, the position of the current point under 
// evaluation relative to each vertex is doted (projected) with that vertex' random
// vector, and the result is bilinearly interpolated (lines 37 to 40 again) with a 
// smooth interpolant (line 33 and 35).
float gnoise( in float2 p )
{
    float2 i = floor( p );
    float2 f = frac( p );
	
	float2 u = f*f*(3.0-2.0*f);

    return lerp( lerp( dot( hash_gn( i + float2(0.0,0.0) ), f - float2(0.0,0.0) ), 
                       dot( hash_gn( i + float2(1.0,0.0) ), f - float2(1.0,0.0) ), u.x),
                 lerp( dot( hash_gn( i + float2(0.0,1.0) ), f - float2(0.0,1.0) ), 
                       dot( hash_gn( i + float2(1.0,1.0) ), f - float2(1.0,1.0) ), u.x), u.y);
}

// Noise - gradient - 3D 
float gnoise( in float3 p )
{
    float3 i = floor( p );
    float3 f = frac( p );
	
	float3 u = f*f*(3.0-2.0*f);

    return lerp( lerp( lerp( dot( hash_gn( i + float3(0.0,0.0,0.0) ), f - float3(0.0,0.0,0.0) ), 
                             dot( hash_gn( i + float3(1.0,0.0,0.0) ), f - float3(1.0,0.0,0.0) ), u.x),
                       lerp( dot( hash_gn( i + float3(0.0,1.0,0.0) ), f - float3(0.0,1.0,0.0) ), 
                             dot( hash_gn( i + float3(1.0,1.0,0.0) ), f - float3(1.0,1.0,0.0) ), u.x), u.y),
                 lerp( lerp( dot( hash_gn( i + float3(0.0,0.0,1.0) ), f - float3(0.0,0.0,1.0) ), 
                             dot( hash_gn( i + float3(1.0,0.0,1.0) ), f - float3(1.0,0.0,1.0) ), u.x),
                       lerp( dot( hash_gn( i + float3(0.0,1.0,1.0) ), f - float3(0.0,1.0,1.0) ), 
                             dot( hash_gn( i + float3(1.0,1.0,1.0) ), f - float3(1.0,1.0,1.0) ), u.x), u.y), u.z );
}

#endif