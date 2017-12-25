#ifndef PIXEL_SPIRIT_CGINC
#define PIXEL_SPIRIT_CGINC

#include "MathConstants.cginc"

/////////////////////////////////////////////////////////////////////////////////////////////////
// Useful functions from the Pixel Spirit Deck @PixelSpiritDeck
/////////////////////////////////////////////////////////////////////////////////////////////////

// s ~ threshold/split value (x == s)
// w ~ width
float stroke(float x, float s, float w)
{
	float half_w = 0.5*w;
	float d = step(s, x + half_w) -
	          step(s, x - half_w);
	return saturate(d);
}

float fill(float x, float size)
{
	return 1.0 - step(size, x);
}

// Flip 0->1 to 1->0 interpolated by t.
float flip(float x, float t)
{
	return lerp(x, 1.0 - x, t);
}

// Circle SDF centered at origin with radius 0.5.
float circleSDF(float2 uv)
{
	return length(uv-.5)*2.;
}

float rectSDF(float2 uv, float2 size)
{
	uv = uv * 2. - 1;
	return max(
		abs(uv.x/size.x),
		abs(uv.y/size.y)
	);
}

float crossSDF(float2 uv, float s)
{
	float2 size = float2(.25, s);
	return min(
		rectSDF(uv, size.xy),
		rectSDF(uv, size.yx)
	);
}

// Modified.
float crossSDF(float2 uv, float s, float thick)
{
	return min(
		rectSDF(uv, float2(s, thick)),
		rectSDF(uv, float2(thick, s))
	);
}

float vesicaSDF(float2 uv, float w)
{
	float2 offst = float2(.5 * w, 0);
	return max(circleSDF(uv - offst), circleSDF(uv + offst));
}

float triSDF(float2 uv)
{
	uv = (uv * 2 - 1) * 2;
	return max(
		abs(uv.x) * 0.866025 + uv.y * 0.5,
		-uv.y * 0.5 );
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// General functions inspired from deck.
/////////////////////////////////////////////////////////////////////////////////////////////////

// Threshold is perpendicular to (y=x) line based on 'a'.
float step_perpendicular_to_identity(float2 uv, float a)
{
	return step(a, (uv.x + uv.y) / 2.0);
}


/////////////////////////////////////////////////////////////////////////////////////////////////
// Card functions from the Pixel Spirit Deck @PixelSpiritDeck
/////////////////////////////////////////////////////////////////////////////////////////////////

float the_void(float2 uv)
{
	return 0.0;
}

float justice(float2 uv)
{
	return step(0.5, uv.x);
}

float strength(float2 uv)
{
	return step(0.5 + cos(uv.y * PI) * 0.25, uv.x);
}

float death(float2 uv)
{
	return step_perpendicular_to_identity(uv, 0.5);
}

float the_wall(float2 uv)
{
	return stroke(uv.x, 0.5, 0.15);
}

float temperance(float2 uv)
{
	float centerX = 0.5;
	float width = 0.06;
	float gap = 0.06;
	float wave = 0.07*sin(uv.y*TWO_PI);
	float result;
	return stroke(uv.x, centerX + wave, width)
	     + stroke(uv.x, centerX-(width+gap) + wave, width)
	     + stroke(uv.x, centerX+(width+gap) + wave, width);
}

float branch(float2 uv)
{
	float sdf = .5+(uv.x-uv.y)*.5;
	return stroke(sdf,.5,.1);
}

float the_hanged_man(float2 uv)
{
	float result = branch(uv);
	uv.x = 1.0 - uv.x;
	result += branch(uv);
	return saturate(result);
}

float the_high_priestess(float2 uv)
{
	return stroke(circleSDF(uv), .5, .05);
}

float the_moon(float2 uv)
{
	float result = fill(circleSDF(uv), .65);
	uv -= float2(.1, .05);
	result -= fill(circleSDF(uv), .5);
	return saturate(result);
}

float the_emperor(float2 uv)
{
	float sdf = rectSDF(uv, float2(1., 1.));
	float result = stroke(sdf, 0.5, 0.125);
	result += fill(sdf, 0.1);
	return saturate(result);

}

float the_hierophant(float2 uv)
{
	float rctSDF = rectSDF(uv, float2(1., 1.));
	float col = fill(rctSDF, .5);
	float crsSDF = crossSDF(uv, 1.);
	col *= step(.5, frac(crsSDF*4.));
	col *= step(1., crsSDF);
	col += fill(crsSDF, 0.5);
	col += stroke(rctSDF, .65, .05);
	col += stroke(rctSDF, .75, .025);
	return col;
}

float the_tower(float2 uv)
{
	float rct = rectSDF(uv, float2(0.5, 1.));
	float lne = (uv.y+uv.x)*.5;
	return flip(fill(rct, .6), stroke(lne, .5, .01));
}

float merge(float2 uv)
{
	float col = 0;
	float2 sep = float2(0.15, 0);

	// Right circle.
	col = fill(circleSDF(uv - sep), 0.525);

	// Left circle.
	col = flip(col, stroke(circleSDF(uv + sep), 0.5, 0.05));

	return col;
}

float hope(float2 uv)
{
	float col = fill(vesicaSDF(uv, 0.2), 0.5);
	return flip(col, step((uv.x + uv.y) * 0.5, 0.5));
}

float the_temple(float2 uv)
{
	float col;
	uv.y = 1.0 - uv.y;
	float2 uv2 = float2(uv.x, 0.825 - uv.y);
	col = fill(triSDF(uv), 0.7);
	col -= fill(triSDF(uv2), 0.36);
	return col;
}

#endif
