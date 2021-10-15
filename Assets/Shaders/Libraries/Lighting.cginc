#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

// https://docs.unity3d.com/Manual/SL-SurfaceShaders.html
// https://docs.unity3d.com/Manual/SL-SurfaceShaderLighting.html

float Lambert(float3 normal, float3 lightDir)
{
    return saturate(dot(normal, lightDir));
}

// "Half Lambert" lighting is a technique first developed in the original Half-Life. 
// It is designed to prevent the rear of an object losing its shape and looking too flat. 
// Half Lambert is a completely non-physical technique and gives a purely percieved visual 
// enhancement and is an example of a forgiving lighting model.
//
// To soften the diffuse contribution from local lights, the dot product from the Lambertian model 
// is scaled by ½, add ½ and squared. The result is that this dot product, which normally lies in 
// the range of -1 to +1, is instead in the range of 0 to 1 and has a more pleasing falloff.
//
// https://developer.valvesoftware.com/wiki/Half_Lambert
// https://subscription.packtpub.com/book/game-development/9781849695084/1/ch01lvl1sec13/creating-a-half-lambert-lighting-model
//
float HalfLambert(float3 normal, float3 lightDir)
{
    float hL = dot(normal, lightDir) * 0.5 + 0.5;
    return hL * hL;
}

#endif