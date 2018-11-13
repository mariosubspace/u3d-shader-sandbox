#ifndef SDF_SHAPES_3D_CGINC
#define SDF_SHAPES_3D_CGINC

// Source: http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

float sphereSDF(float3 p, float3 center, float radius)
{
	return distance(center, p) - radius;
}

float boxUDF(float3 p, float3 dim)
{
	return length(max(abs(p)-dim, 0.0));
}

float roundBoxUDF(float3 p, float3 dim, float r)
{
	return length(max(abs(p)-dim, 0.0))-r;
}

float boxSDF(float3 p, float3 dim)
{
	float3 d = abs(p) - dim;
	return min(max(d.x, max(d.y, d.z)), 0) + length(max(d, 0));
}

float torusSDF(float3 p, float2 t)
{
	float2 q = float2(length(p.xz) - t.x, p.y);
	return length(q) - t.y;
}

float cylinderSDF(float3 p, float2 xzPos, float radius)
{
	return length(p.xz - xzPos) - radius;
}

float coneSDF(float3 p, float2 size)
{
	// size must be normalized.
	float q = length(p.xy);
	return dot(normalize(size), float2(q, p.z));
}

float planeSDF(float3 p, float4 n)
{
	// n must be normalized.
	return dot(p, n.xyz) + n.w;
}

float hexagonalPrismSDF(float3 p, float2 h)
{
	float3 q = abs(p);
	return max(q.z - h.y, max((q.x*0.866025 + q.y*0.5), q.y) - h.x);
}

float triangularPrismSDF(float3 p, float2 h)
{
	float3 q = abs(p);
	return max(q.z - h.y, max((q.x*0.866025 + p.y*0.5), -p.y) - h.x*0.5);
}

float capsuleSDF(float3 p, float3 a, float3 b, float r)
{
	float3 pa = p - a, ba = b - a;
	float h = clamp( dot(pa, ba) / dot(ba, ba), 0, 1);
	return length(pa - ba*h) - r;
}

#endif