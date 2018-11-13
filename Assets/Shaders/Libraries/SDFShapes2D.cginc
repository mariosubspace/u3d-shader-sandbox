#ifndef SDF_SHAPES_2D_CGINC
#define SDF_SHAPES_2D_CGINC

#include "ConstantsMath.cginc"
#include "UtilGeneral.cginc"

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

float heartSDF(float2 uv)
{
	uv -= float2(0.5, 0.8);
	float r = length(uv)*5.;
	uv = normalize(uv);
	return r -
		((uv.y*pow(abs(uv.x), 0.67))/
		(uv.y+1.5)-(2.0)*uv.y+1.26);
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

float the_star(float2 uv)
{
	float starIn = starSDF(uv, 6, 0.1);

	// Shift origin.
	uv -= float2(0.5, 0.5);

	// Get the angle around the origin, normalized to [0, 1].
	float fan = fanSDF(uv, 8);
	fan = stroke(fan, 0.5, 0.15);

	// Rotate.
	uv = rotate(uv, PI/6);
	
	// Shift origin back.
	uv += float2(0.5, 0.5);

	float starOut = starSDF(uv, 6, 0.1);

	float col = fan;
	col -= fill(starOut, 0.7);
	col = saturate(col); // Clamp cause next op will undo.
	col += fill(starOut, 0.5);
	col += stroke(starOut, 0.6, 0.05);
	col -= fill(starIn, 0.26);
	col += fill(starIn, 0.2);

	return col;
}

float judgement(float2 uv)
{
	float f = fanSDF(uv - 0.5, 28);
	f = stroke(f, 0.5, 0.2);
	float h = step(uv.y, 0.5);
	float bg = flip(f, h);

	float sq = rectSDF(uv, float2(0.5, 0.5));
	float col = saturate(bg - fill(sq, 0.45));
	col += fill(sq, 0.37);

	return col;
}

float wheel_of_fortune(float2 uv)
{
	float octD = polySDF(uv, 8);
	float rays = stroke(fanSDF(uv - 0.5, 8), 0.5, 0.2);

	float s = stroke(octD, 0.6, 0.1);
	s += stroke(octD, 0.2, 0.05);
	s += rays * stroke(octD, 0.388, 0.23);

	return s;
}

float vision(float2 uv)
{
	// Background.
	float vv = vesicaSDF(uv, 0.4);
	vv = fill(vv, 0.96);
	float col = stroke(fanSDF(uv - 0.5, 50), 0.5, 0.17);
	col *= vv;

	// Eye outline.
	float2 uv2 = apply_mat(
		rotate_at_center_mat3x3(PI/2), uv);
	float hv = vesicaSDF(uv2, 0.5);
	float e = stroke(hv, 0.73, 0.035);
	float em = fill(hv, 0.74);
	col *= 1 - em;
	col += e;

	// Iris.
	float cd = circleSDF(uv - float2(0, 0.036));
	col += stroke(cd, 0.24, 0.038) * em;

	return col;
}

float the_lovers(float2 uv)
{
	float col = fill(heartSDF(uv), 0.5);
	col -= stroke(polySDF(uv, 3), .15, .05);
	return saturate(col);
}

float the_magician(float2 uv)
{
	// This first line is the magic,
	// it flips the x coords where 
	// y < 0.5.
	uv.x = flip(uv.x, step(0.5, uv.y));

	// The idea is to overlap one circle
	// over the other with a black border
	// for the overlapping one. The 'bridge'
	// function makes this easy.
	// Because the uv.x coords are flipped
	// halfway, one overlapping side will be
	// flipped making it appear that the
	// rings are interlinked.
	float2 offset = float2(.15, .0);
	float left = circleSDF(uv + offset);
	float right = circleSDF(uv - offset);
	float col = stroke(left, .4, .075);
	col = bridge(col, right, .4, .075);
	return saturate(col);
}

float the_link(float2 uv)
{
	float rtp = fill(rhombSDF(uv - float2(0,  0.35)), .07);
	float rbt = fill(rhombSDF(uv - float2(0, -0.35)), .07);
	uv.y = flip(uv.y, step(0.5, uv.x));
	float2 offset = float2(0, .07);

	float2 rotUVTop = uv - offset;
	rotUVTop -= .5;
	rotUVTop = rotate(rotUVTop, PI/4);
	rotUVTop += .5;

	float2 rotUVBot = uv + offset;
	rotUVBot -= .5;
	rotUVBot = rotate(rotUVBot, PI/4);
	rotUVBot += .5;

	float top = rectSDF(rotUVTop, float2(.5,.5));
	float bot = rectSDF(rotUVBot, float2(.5,.5));
	
	float col = stroke(top, .4, .12);
	col = bridge(col, bot, .4, .12);
	col += rtp + rbt;
	return col;
}

// Slightly different implementation than PSD but similar concept.
float holding_together(float2 uv)
{
	uv.x = flip(uv.x, step(0.5, uv.y));
	float2 off = float2(0.0635, 0);
	float right = rectSDF(rotate_at_center(uv - off, PI/4), float2(.5,.5));
	float left = rectSDF(rotate_at_center(uv + off, PI/4), float2(.5,.5));
	float col = fill(right, 0.48);
	col -= fill(left, 0.6);
	col = saturate(col);
	col += fill(left, 0.48);
	col -= fill(left, 0.23);
	col = saturate(col);
	col += fill(left, 0.13);
	return col;
}

#endif
