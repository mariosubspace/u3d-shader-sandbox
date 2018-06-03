#ifndef PIXEL_SPIRIT_CGINC
#define PIXEL_SPIRIT_CGINC

#include "MathConstants.cginc"

/////////////////////////////////////
///// From: The Book of Shaders
/////////////////////////////////////

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

float rhombSDF(float2 uv)
{
	float v = triSDF(uv);
	uv.y = 1 - uv.y;
	v = max(v, triSDF(uv));
	return v;
}

float polySDF(float2 uv, int n)
{
	uv = 2.0 * uv - 1.0;
	uv = rotate(uv, -HALF_PI);
	float r = length(uv);
	float a = atan2(uv.y, uv.x) + PI;
	float v = TAU / float(n);
	return cos(floor(.5 + a/v)*v - a)*r;
	return a / TAU;
}

// Rotate by -HALF_PI to align to y axis.
// Scale to -1, 1 to get canonical effect.
float polySDF_plain(float2 uv, int n)
{
	float r = length(uv);
	float a = atan2(uv.y, uv.x) + PI;
	float v = TAU / float(n);
	return cos(floor(.5 + a/v)*v - a)*r;
	return a / TAU;
}

float polySDF(float2 uv, int n, float cosOffset)
{
	uv = 2.0 * uv - 1.0;
	float r = length(uv);
	float a = atan2(uv.y, uv.x) + PI;
	float v = TAU / float(n);
	return cos(floor(a/v)*v - a + cosOffset)*r;
	return a / TAU;
}

float hexSDF(float2 uv)
{
	uv = abs(2*uv - 1);
	return max(abs(uv.y), uv.x * 0.866025 + uv.y * 0.5);
}

float starSDF(float2 uv, int n, float s)
{
	uv = 4*uv - 2;
	float a = atan2(uv.y, uv.x) / TAU;
	float seg = a * float(n);
	a = ((floor(seg) + 0.5) / float(n) +
		lerp(s, -s, step(.5, frac(seg))))
		* TAU;
	return abs(dot(float2(cos(a), sin(a)), uv));
}

// A fan-type SDF. You must shift the origin to the
// center if you want the fan to come from the center.
// 'n' is the number of blades. Normalized to [0, 1]
// values by default.
float fanSDF(float2 uv, int n)
{
	float a = (atan2(uv.y, uv.x) + PI) / TAU;
	a = frac(a*n);
	return a;
}

// From the PSD, same as fan but shifts the
// space by default.
float raysSDF(float2 uv, int n)
{
	uv -= .5;
	float a = fanSDF(uv, n);
	uv += .5;
	return a;
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

float the_diamond(float2 uv)
{
	float v = rhombSDF(uv);
	float col = stroke(v, 0.6, 0.03);
	col += stroke(v, 0.5, 0.05);
	col += fill(v, 0.425);
	return col;
}

float the_summit(float2 uv)
{
	float col;
	col = stroke(circleSDF(uv - float2(0, 0.1)), 0.45, 0.1);
	float tri = triSDF(uv + float2(0, 0.1));
	col *= step(0.55, tri);
	col += step(tri, 0.45);
	return col;
}

float the_hermit(float2 uv)
{
	float v = triSDF(uv);
	float col = fill(v, 0.5);
	v = rhombSDF(uv);
	col -= fill(v, 0.4);
	return col;
}

float intuition(float2 uv)
{
	uv -= float2(0.5, 0.5);
	uv = rotate(uv, -25);
	uv += float2(0.5, 0.5);
	float v = triSDF(uv);
	v /= triSDF(uv + float2(0, 0.2));
	float col = fill(v, 0.56);
	return col;
}

float the_stone(float2 uv)
{
	uv -= float2(0.5, 0.5);
	uv = rotate(uv, 3.14159 / 4);
	uv += float2(0.5, 0.5);

	float square = fill(rectSDF(uv, float2(1, 1)), 0.4);
	float strokeForward = stroke(uv.y, 0.5, 0.02);
	float strokeBack = stroke(uv.x, 0.5, 0.02);
	float col = square * (1 - max(strokeBack, strokeForward));

	return col;
}

float the_mountain(float2 uv)
{
	float col = 0; 

	uv -= float2(0.5, 0.5);
	uv = rotate(uv, 3.14159 / 4);
	uv += float2(0.5, 0.5);

	float2 ost = float2(0.12, 0.12);
	float2 s = float2(1, 1);
	col = fill(rectSDF(uv + ost, s), 0.2);
	col += fill(rectSDF(uv - ost, s), 0.2);
	float r = rectSDF(uv, s);
	col *= step(0.33, r);
	col += fill(r, 0.3);

	return col;
}

float the_shadow(float2 uv)
{
	float col = 0;
	float2 s = float2(1, 1);
	float2 ost = float2(-0.025, 0.025);

	uv -= float2(0.5, 0.5);
	uv = rotate(uv, 3.14159 / 4);
	uv += float2(0.5, 0.5);

	float rTop = rectSDF(uv - ost, s);
	float rBot = rectSDF(uv + ost, s);

	col = max(fill(rTop, 0.4), fill(rBot, 0.4)) - fill(rTop, 0.38);

	return col;
}

float opposite(float2 uv)
{
	float col = 0;

	uv -= float2(0.5, 0.5);
	uv = rotate(uv, 3.14159 / 4);
	uv += float2(0.5, 0.5);

	float2 ost = float2(0.05, 0.05);
	float2 s = float2(1, 1);

	float left  = fill(rectSDF(uv + ost, s), 0.4);
	float right = fill(rectSDF(uv - ost, s), 0.4);

	col = flip(left, right);

	return col;
}

float the_oak(float2 uv)
{
	float col;
	float2 s = float2(1, 1);

	uv -= float2(0.5, 0.5);
	uv = rotate(uv, 3.14159 / 4);
	uv += float2(0.5, 0.5);

	float r1 = rectSDF(uv, s);
	float r2 = rectSDF(uv + float2(-0.155, 0.155), s);

	const float MAIN_SIZE = 0.5;
	const float BOT_SIZE = 0.325;
	const float STROKE = 0.05;
	const float HALF_STROKE = STROKE / 2;

	// Main square:
	// Draw main square (full) outline.
	col = stroke(r1, MAIN_SIZE, STROKE);
	// Mask out bottom section.
	col *= step(BOT_SIZE + HALF_STROKE, r2);
	// Stroke the bottom square outer size.
	col += stroke(r2, BOT_SIZE, STROKE)
		* fill(r1, MAIN_SIZE + HALF_STROKE); // Mask out only the part over the main square.

	// Bottom square:
	col += stroke(r2, BOT_SIZE * 0.585, STROKE);

	return col;
}

float ripples(float2 uv)
{
	float col = 0;

	uv -= float2(0.5, 0.5);
	uv = rotate(uv, 3.14159 / 4);
	uv += float2(0.5, 0.5);

	float2 s = float2(1, 1);
	const float COUNT = 4;
	const float OFST = 0.08;
	const float SIZE = 0.3;
	const float STROKE = 0.045;

	float len = (COUNT - 1) * OFST;
	float pos = -(len / 2);

	for (int i = 0; i < COUNT; ++i)
	{
		col = max(col, stroke(rectSDF(uv + float2(pos, pos), s), SIZE, STROKE));
		pos += OFST;
	}

	return col;
}

float the_empress(float2 uv)
{
	float d1 = polySDF(uv, 5);
	float col = fill(d1, .75) * fill(frac(d1*5), 0.5);

	uv = float2(uv.x, 1.0 - uv.y);
	float d2 = polySDF(uv, 5);
	col -= fill(d1, .5) * fill(frac(d2*4.9), 0.45);
	col = saturate(col); // clamp the negative values.

	return col;
}

float bundle(float2 uv)
{
	uv = 2*uv - 1;

	float d = fill(
		polySDF_plain(uv - float2(-.16, -0.096), 6),
		0.12);

	d += fill(
		polySDF_plain(uv - float2( .16, -0.096), 6),
		0.12);

	d += fill(
		polySDF_plain(uv - float2(0, .176), 6),
		0.12);

	d += stroke(polySDF_plain(uv, 6), .5, .1);

	return d;
}

float the_devil(float2 uv)
{
	float col = stroke(circleSDF(uv), .8, .05);
	uv.y = 1 - uv.y;
	float s = starSDF(uv.yx, 5, .1);
	col *= step(.7, s);
	col += stroke(s, .4, .1);
	return col;
}

float the_sun(float2 uv)
{
	uv -= float2(0.5, 0.5);
	uv *= 1.5;
	uv += float2(0.5, 0.5);

	float col = 0;
	float bg = starSDF(uv, 16, .1);
	col += fill(bg, 1.3);
	float L = 0;
	for (float i = 0; i < 8; ++i)
	{
		float2 xy = uv;
		xy -= float2(0.5, 0.5);
		xy = rotate(xy, QTR_PI*i);
		xy += float2(0.5, 0.5); 
		xy.y -= .3;
		float tri = polySDF(xy, 3);
		col += fill(tri, .3);
		col = saturate(col);
		L += stroke(tri, .3, .03);
	}
	col *= 1 - L;

	float c = polySDF(uv, 8);
	col -= stroke(c, .15, .04);
	col = saturate(col);
	
	return col;
}

#endif
