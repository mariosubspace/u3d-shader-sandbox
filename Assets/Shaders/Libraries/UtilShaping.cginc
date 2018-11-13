#ifndef UTIL_SHAPING_CGINC
#define UTIL_SHAPING_CGINC

/////////////////////////////////////////////////////////////////////////////////////////////////
//
// Inigo's Shaping functions
//
// http://www.iquilezles.org/www/articles/functions/functions.htm
//
/////////////////////////////////////////////////////////////////////////////////////////////////

// Almost Identity

// Say you don't want to change a value unless it's too small and screws some of your computations up.
// Then, rather than doing a sharp conditional branch, you can blend your value with your threshold,
// and do it smoothly (say, with a cubic polynomial). Set m to be your threshold (anything above m stays unchanged),
// and n the value things will take when your value is zero. Then set
//
// p(0) = n
// p(m) = m
// p'(0) = 0
// p'(m) = 1
//
// therefore, if p(x) is a cubic, then p(x) = (2n-m)(x/m)^3 + (2m-3n)(x/m)^2 + n

// Notes:
//   At x=0, n is returned.
//   While x <= m, use the cubic to interpolate smoothly.
//   If x > m, x is returned.

float almost_identity(float x, float m, float n)
{
	if (x > m) return x;

	float a = 2.0*n - m;
	float b = 2.0*m - 3.0*n;
	float t = x/m;

	return (a*t + b)*t*t + n;
}

// Impulse

// Great for triggering behaviours or making envelopes for music or animation,
// and for anything that grows fast and then slowly decays. Use k to control
// the stretching of the function. Btw, it's maximum, which is 1.0, happens at exactly x = 1/k.

// Notes: Rises to 1 fast, then slowly decays to 0.

float impulse(float x, float k)
{
	float h = k*x;
	return h*exp(1.0 - h);
}

// Cubic Pulse

// Of course you found yourself doing smoothstep(c-w,c,x)-smoothstep(c,c+w,x) very often,
// probably cause you were trying to isolate some features. Then this cubicPulse() is your friend.
// Also, why not, you can use it as a cheap replacement for a gaussian.

// Notes: Very Gaussian-like, high point is at x=c, radius is w.

float cubic_pulse(float x, float c, float w)
{
	x = abs(x - c);
	if (x > w) return 0.0;
	x /= w;
	return 1.0 - x*x*(3.0 - 2.0*x);
}

// Exponential Step

// A natural attenuation is an exponential of a linearly decaying quantity: yellow curve, exp(-x).
// A gaussian, is an exponential of a quadratically decaying quantity: light green curve, exp(-x²).
// You can go on increasing powers, and get a sharper and sharper smoothstep(), until you get a step() in the limit.

// Notes: n is sharpness, k is the x-scale???

float exp_step(float x, float k, float n)
{
	return exp(-k*pow(x, n));
}

// Slightly faster, no k.
// Add +0.5 to x to shift it into the unit-square.
float exp_step(float x, float n)
{
	return exp(-pow(x, n));
}

// Gain

// Remapping the unit interval into the unit interval by expanding the sides and compressing the center,
// and keeping 1/2 mapped to 1/2, that can be done with the gain() function. 
// This was a common function in RSL tutorials (the Renderman Shading Language).
// k=1 is the identity curve, k<1 produces the classic gain() shape, and k>1 produces "s" shaped curves.
// The curves are symmetric (and inverse) for k=a and k=1/a.

// Notes: k < 1 more "seat"-like, k > 1 more "sigmoid"-like.

float gain(float x, float k)
{
	float a = 0.5*pow(2.0*((x < 0.5) ? x : 1.0 - x), k);
	return (x < 0.5) ? a : 1.0 - a;
}

// Parabola

// A nice choice to remap the 0..1 interval into 0..1, such that the corners are remapped to 0 and the center to 1.
// In other words, parabola(0) = parabola(1) = 0, and parabola(1/2) = 1.

// small k is wider, bigger k is narrower/sharper.
// k=0 is practically a flat line at y=1, use values larger than 0 for k.

float parabola(float x, float k)
{
	return pow(4.0*x*(1.0 - x), k);
}

// Power Curve

// A nice choice to remap the 0..1 interval into 0..1, such that the corners are remapped to 0.
// Very useful to skew the shape one side or the other in order to make leaves, eyes, and many other interesting shapes.

// Note that k is chosen such that pcurve() reaches exactly 1 at its maximum for illustration purposes,
// but in many applications the curve needs to be scaled anyways so the slow computation of k can be simply avoided.

// 'a' and 'b' both work to skew the curve.
// At a = b = 0.5, it's exactly the parabola with k = 0.5
// Increasing 'a' skews to right.
// Increasing 'b' skews to left.
// At large skew numbers (> 1), it starts to resemble the impulse curves.

float pcurve(float x, float a, float b)
{
	float k = pow(a + b, a + b)/(pow(a, a)*pow(b, b));
	return k*pow(x, a)*pow(1.0 - x, b);
}



/////////////////////////////////////////////////////////////////////////////////////////////////
// Shaping functions from flong.com.
//
// There are:
// (1) Polynomial Shaping Functions
//     http://www.flong.com/texts/code/shapers_poly/
//
// (2) Exponential Shaping Functions
//     http://www.flong.com/texts/code/shapers_exp/
//
// (3) Circular & Elliptical Shaping Functions
//     http://www.flong.com/texts/code/shapers_circ/
//
// (4) Bezier and Other Parametric Shaping Functions
//     http://www.flong.com/texts/code/shapers_bez/
//
// In 1-3 it's mostly "seat" and "sigmoid" type functions where the seat ones have a horizontal
// section in the center and sigmoid ones are vertical at the center.
//
// (4) Is probably the most useful with some Bezier functions, many of the other functions can
// be approximated with the Bezier curves.
/////////////////////////////////////////////////////////////////////////////////////////////////

///// Polynomial Shaping Functions
///// From: http://www.flong.com/texts/code/shapers_poly/

// Blinn-Wyvill Approximation to the Raised Inverted Cosine

// A fast approximation of cosine, diverges by the authentic (scaled) cosine by less than 0.1%.

// Input [0, 1], output [0, 1]

float blinn_wyvill_cosine_approximation(float x) {
	float x2 = x*x;
	float x4 = x2*x2;
	float x6 = x4*x2;

	float fa = ( 4.0/9.0);
	float fb = (17.0/9.0);
	float fc = (22.0/9.0);

	return fa*x6 - fb*x4 + fc*x2;
}

// Double-Cubic Seat

// This seat-shaped function is formed by joining two 3rd-order polynomial (cubic) curves.
// The curves meet with a horizontal inflection point at the control coordinate (a,b) in the unit square.

// Input [0, 1], output [0, 1]

float double_cubic_seat(float x, float2 control_point)
{
	float epsilon = 0.00001;
	float min_param_a = 0.0 + epsilon;
	float max_param_a = 1.0 - epsilon;
	float min_param_b = 0.0;
	float max_param_b = 1.0;
	float a = min(max_param_a, max(min_param_a, control_point.x));
	float b = min(max_param_b, max(min_param_b, control_point.y));

	float y = 0;
	if (x <= a)
	{
		y = b - b*pow(1-x/a, 3.0);
	}
	else
	{
		y = b + (1-b)*pow((x-a)/(1-a), 3.0);
	}
	return y;
}

// Double-Cubic Seat with Linear Blend

// This modified version of the Double-Cubic Seat function uses a single variable to control
// the location of its inflection point along the diagonal of the unit square. A second parameter
// is used to blend this curve with the Identity Function (y=x). Here, we use the variable 'smoothness' to control
// the amount of this blend, which has the effect of tilting the slope of the curve's plateau in the
// vicinity of its inflection point. The adjustable flattening around the inflection point makes this a
// useful shaping function for lensing or magnifying evenly-spaced data.

// Input [0, 1], output [0, 1]

float double_cubic_seat_with_linear_blend(float x, float position, float smoothness)
{
	float epsilon = 0.00001;
	float min_param_a = 0.0 + epsilon;
	float max_param_a = 1.0 - epsilon;
	float min_param_b = 0.0;
	float max_param_b = 1.0;
	float a = min(max_param_a, max(min_param_a, position));
	float b = min(max_param_b, max(min_param_b, smoothness));
	b = 1.0 - b; //reverse for intelligibility.

	float y = 0;
	if (x <= a)
	{
		y = b*x + (1-b)*a*(1-pow(1-x/a, 3.0));
	}
	else
	{
		y = b*x + (1-b)*(a + (1-a)*pow((x-a)/(1-a), 3.0));
	}
	return y;
}

// Double-Odd-Polynomial Seat

// The previous Double-Cubic Seat function can be generalized to a form which
// uses any odd integer exponent. In the code below, the parameter n controls the flatness
// or breadth of the plateau region in the vicinity of the point (a,b). A good working range
// for n is the set of whole numbers from 1 to about 20.

// Input [0, 1], output [0, 1]

float double_odd_polynomial_seat(float x, float2 control_point, int n)
{
	float epsilon = 0.00001;
	float min_param_a = 0.0 + epsilon;
	float max_param_a = 1.0 - epsilon;
	float min_param_b = 0.0;
	float max_param_b = 1.0;
	float a = min(max_param_a, max(min_param_a, control_point.x));
	float b = min(max_param_b, max(min_param_b, control_point.y));

	int p = 2*n + 1;
	float y = 0;
	if (x <= a)
	{
		y = b - b*pow(1-x/a, p);
	}
	else
	{
		y = b + (1-b)*pow((x-a)/(1-a), p);
	}
	return y;
}

// Quadratic Through a Given Point

// This function defines an axis-aligned quadratic (parabola) which passes through a user-supplied point (a,b)
// in the unit square. Caution: Not all points in the unit square will produce curves which pass through
// the locations (0,0) and (1,1).

float quadratic_through_point(float x, float2 control_point)
{
	float epsilon = 0.00001;
	float min_param_a = 0.0 + epsilon;
	float max_param_a = 1.0 - epsilon;
	float min_param_b = 0.0;
	float max_param_b = 1.0;
	float a = min(max_param_a, max(min_param_a, control_point.x));
	float b = min(max_param_b, max(min_param_b, control_point.y));

	float A = (1.0 - b)/(1.0 - a) - (b/a);
	float B = (A*(a*a) - b) / a;
	float y = A*(x*x) - B*x;
	y = min(1.0, max(0.0, y));

	return y;
}



///// Exponential Shaping Functions
///// From: http://www.flong.com/texts/code/shapers_exp/

// Exponential Ease-In / Ease-Out

// In this implementation of an exponential shaping function, the control parameter a
// permits the designer to vary the function from an ease-out form to an ease-in form.

float exponential_easing(float x, float a)
{
	float epsilon = 0.00001;
	float min_param_a = 0.0 + epsilon;
	float max_param_a = 1.0 - epsilon;
	a = max(min_param_a, min(max_param_a, a));

	if (a < 0.5)
	{
		// emphasis
		a = 2.0*(a);
		float y = pow(x, a);
		return y;
	}
	else
	{
		// de-emphasis
		a = 2.0*(a-0.5);
		float y = pow(x, 1.0/(1.0 - a));
		return y;
	}
}

// Double-Exponential Seat

// A seat-shaped function can be created with a coupling of two exponential functions.
// This has nicer derivatives than the cubic function, and more continuous control in some respects,
// at the expense of greater CPU cycles. The recommended range for the control parameter a is from 0 to 1.
// Note that these equations are very similar to the Double-Exponential Sigmoid described below.

float double_exponential_seat(float x, float a)
{
	float epsilon = 0.00001;
	float min_param_a = 0.0 + epsilon;
	float max_param_a = 1.0 - epsilon;
	a = max(min_param_a, min(max_param_a, a));

	float y = 0;
	if (x <= 0.5)
	{
		y = pow(2.0*x, 1.0 - a)/2.0;
	}
	else
	{
		y = 1.0 - pow(2.0*(1.0 - x), 1.0 - a)/2.0;
	}
	return y;
}



///// Circular & Elliptical Shaping Functions
///// From: http://www.flong.com/texts/code/shapers_circ/

// Circular Interpolation: Ease-In and Ease-Out

// A circular arc offers a quick and easy-to-code method for easing in or out of the unit square.
// The computational efficiency of the function is diminished by its use of a square root, however.

float circular_ease_in(float x)
{
	return 1.0 - sqrt(1.0 - x*x);
}

float circular_ease_out(float x)
{
	float omx = 1.0 - x;
	return sqrt(1.0 - omx*omx);
}

// Double-Circle Seat

// This shaping function is formed by the meeting of two circular arcs, which join with a horizontal tangent.
// The parameter a, in the range [0...1], governs the location of the curve's inflection point along the diagonal of the unit square.

float double_circle_seat(float x, float a)
{
	float min_param_a = 0.0;
	float max_param_a = 1.0;
	a = max(min_param_a, min(max_param_a, a));

	float y = 0.0;
	float xma = x - a;
	if (x <= a)
	{
		y = sqrt(a*a - xma*xma);
	}
	else
	{
		float oma = 1.0 - a;
		y = 1.0 - sqrt(oma*oma - xma*xma);
	}
	return y;
}

// Double-Circle Sigmoid

// This sigmoidal shaping function is formed by the meeting of two circular arcs, which join with a vertical tangent.
// The parameter a, in the range [0...1], governs the location of the curve's inflection point along the diagonal of the unit square.

float double_circle_sigmoid(float x, float a)
{
	float min_param_a = 0.0;
	float max_param_a = 1.0;
	a = max(min_param_a, min(max_param_a, a));

	float y = 0;
	if (x <= a)
	{
		y = a - sqrt(a*a - x*x);
	}
	else
	{
		float oma = 1.0 - a;
		float xmo = x - 1.0;
		y = a + sqrt(oma*oma - xmo*xmo);
	}
	return y;
}

// Double-Elliptic Seat

// This seat-shaped function is created by the joining of two elliptical arcs, and is a generalization of the Double-Circle Seat.
// The two arcs meet at the control_point with a horizontal tangent.

float double_elliptic_seat(float x, float2 control_point)
{
	float epsilon = 0.00001;
	float min_param_a = 0.0 + epsilon;
	float max_param_a = 1.0 - epsilon;
	float min_param_b = 0.0;
	float max_param_b = 1.0;
	float a = max(min_param_a, min(max_param_a, control_point.x));
	float b = max(min_param_b, min(max_param_b, control_point.y));

	float y = 0;
	float xma = x - a;
	if (x <= a)
	{
		y = (b/a) * sqrt(a*a - xma*xma);
	}
	else
	{
		float oma = 1.0 - a;
		y = 1.0 - ((1.0 - b)/(1.0 - a))*sqrt(oma*oma - xma*xma);
	}
	return y;
}


// Double-Elliptic Sigmoid

// This sigmoid-shaped function is created by the joining of two elliptical arcs, and is a generalization of the Double-Circle Sigmoid.
// The arcs meet at the coordinate control_point in the unit square with a vertical tangent.

float double_elliptic_sigmoid(float x, float2 control_point)
{
	float epsilon = 0.00001;
	float min_param_a = 0.0 + epsilon;
	float max_param_a = 1.0 - epsilon;
	float min_param_b = 0.0;
	float max_param_b = 1.0;
	float a = max(min_param_a, min(max_param_a, control_point.x));
	float b = max(min_param_b, min(max_param_b, control_point.y));

	float y = 0;
	if (x <= a)
	{
		y = b * (1.0 - (sqrt(a*a - x*x)/a));
	}
	else
	{
		float oma = 1.0 - a;
		float xmo = x - 1.0;
		y = b + ((1.0 - b)/(1.0 - a))*sqrt(oma*oma - xmo*xmo);
	}
	return y;
}



///// Bezier and Other Parametric Shaping Functions
///// From: http://www.flong.com/texts/code/shapers_bez/

// Quadratic Bezier

// This function defines a 2nd-order (quadratic) Bezier curve with a single user-specified spline
// control point (at the coordinate control_point) in the unit square. This function is guaranteed to have
// the same entering and exiting slopes as the Double-Linear Interpolator. Put another way, this
// curve allows the user to precisely specify its rate of change at its endpoints in the unit square.

float quadratic_bezier(float x, float2 control_point)
{
	// adapted from BEZMATH.PS (1993)
	// by Don Lancaster, SYNERGETICS Inc. 
	// http://www.tinaja.com/text/bezmath.html

	float epsilon = 0.00001;
	float a = max(0.0, min(1.0, control_point.x));
	float b = max(0.0, min(1.0, control_point.y));
	if (a == 0.5)
	{
		a += epsilon;
	}

	// solve t from x (an inverse operation)
	float om2a = 1.0 - 2.0*a;
	float t = (sqrt(a*a + om2a*x) - a)/om2a;
	float y = (1.0 - 2.0*b)*t*t + 2.0*b*t;
	return y;
}

// Cubic Bezier

// The Cubic Bezier is a workhorse of computer graphics; most designers will recognize it from Adobe Illustrator and other popular vector-based drawing programs.
// Here, this extremely flexible curve is used in as a signal-shaping function, which requires the user to specify two locations in the unit square
// (at the coordinates pnt1 and pnt2) as its control points. By setting the two control points to various locations, the Bezier curve can be used to produce sigmoids,
// seat-shaped functions, ease-ins and ease-outs.

// Bezier curves are customarily defined in such a way that y and x are both functions of another variable t. In order to obtain y as a function of x,
// it is necessary to first solve for t using successive approximation, making the code longer than one might first expect.
// The implementation here is adapted from the Bezmath Postscript library by Don Lancaster.

// Mario's Note: The anchor points are hard-coded to (0, 0) and (1, 1).

// First, some helper functions:
float cb01h_slope_from_t(float t, float A, float B, float C)
{
	float dtdx = 1.0/(3.0*A*t*t + 2.0*B*t + C);
	return dtdx;
}

float cb01h_x_from_t(float t, float A, float B, float C, float D)
{
	float x = A*t*t*t + B*t*t + C*t + D;
	return x;
}

float cb01h_y_from_t(float t, float E, float F, float G, float H)
{
	float y = E*t*t*t + F*t*t + G*t + H;
	return y; 
}

float cubic_bezier_01(float x, float2 pnt1, float2 pnt2)
{
	float y0a = 0.00; // initial y
	float x0a = 0.00; // initial x
	float y1a = pnt1.y; // 1st influence y
	float x1a = pnt1.x; // 1st influence x
	float y2a = pnt2.y; // 2nd influence y
	float x2a = pnt2.x; // 2nd influence x
	float y3a = 1.00; // final y 
	float x3a = 1.00; // final x

	float A =     x3a - 3.0*x2a + 3.0*x1a - x0a;
	float B = 3.0*x2a - 6.0*x1a + 3.0*x0a;
	float C = 3.0*x1a - 3.0*x0a;
	float D =     x0a;

	float E =     y3a - 3.0*y2a + 3.0*y1a - y0a;
	float F = 3.0*y2a - 6.0*y1a + 3.0*y0a;
	float G = 3.0*y1a - 3.0*y0a;
	float H =     y0a;

	// Solve for t given x (using Newton-Raphelson), then solve for y given t.
	// Assume for the first guess that t = x.
	float currentt = x;
	int nRefinementIterations = 5;
	for (int i = 0; i < nRefinementIterations; i++)
	{
		float currentx = cb01h_x_from_t(currentt, A, B, C, D); 
		float currentslope = cb01h_slope_from_t(currentt, A, B, C);
		currentt -= (currentx - x)*(currentslope);
		currentt = saturate(currentt);
	}

	float y = cb01h_y_from_t(currentt, E, F, G, H);
	return y;
}

// Cubic Bezier (Nearly) Through Two Given Points

// This shaping function asks the user to specify two points in the unit square.
// The algorithm then attempts to generate a curve which passes through these points as closely as possible.
// The curves are not guaranteed to pass through the two points, but come quite close in most instances.
// The method is adapted from Don Lancaster.

// Helper functions. 
float cbtph_B0(float t)
{
	float omt = 1 - t;
	return omt*omt*omt;
}

float cbtph_B1(float t)
{
	float omt = 1 - t;
	return 3*t*omt*omt;
}

float cbtph_B2(float t)
{
	return 3*t*t*(1-t);
}

float cbtph_B3(float t)
{
	return t*t*t;
}

float cbtph_find_x(float t, float x0, float x1, float x2, float x3)
{
	return x0*cbtph_B0(t) + x1*cbtph_B1(t) + x2*cbtph_B2(t) + x3*cbtph_B3(t);
}

float cbtph_find_y(float t, float y0, float y1, float y2, float y3)
{
	return y0*cbtph_B0(t) + y1*cbtph_B1(t) + y2*cbtph_B2(t) + y3*cbtph_B3(t);
}

float cubic_bezier_through_two_points(float x, float2 pnt1, float2 pnt2)
{
	float y = 0;
	float epsilon = 0.00001;
	float min_param = 0.0 + epsilon;
	float max_param = 1.0 - epsilon;
	float a = max(min_param, min(max_param, pnt1.x));
	float b = max(min_param, min(max_param, pnt1.y));
	float c = max(min_param, min(max_param, pnt2.x));
	float d = max(min_param, min(max_param, pnt2.y));

	float x0 = 0;
	float y0 = 0;
	float x4 = a;
	float y4 = b;
	float x5 = c;
	float y5 = d;
	float x3 = 1;
	float y3 = 1;
	float x1,y1,x2,y2; // to be solved.

	// arbitrary but reasonable
	// t-values for interior control points
	float t1 = 0.3;
	float t2 = 0.7;

	float B0t1 = cbtph_B0(t1);
	float B1t1 = cbtph_B1(t1);
	float B2t1 = cbtph_B2(t1);
	float B3t1 = cbtph_B3(t1);
	float B0t2 = cbtph_B0(t2);
	float B1t2 = cbtph_B1(t2);
	float B2t2 = cbtph_B2(t2);
	float B3t2 = cbtph_B3(t2);

	float ccx = x4 - x0*B0t1 - x3*B3t1;
	float ccy = y4 - y0*B0t1 - y3*B3t1;
	float ffx = x5 - x0*B0t2 - x3*B3t2;
	float ffy = y5 - y0*B0t2 - y3*B3t2;

	x2 = (ccx - (ffx*B1t1)/B1t2) / (B2t1 - (B1t1*B2t2)/B1t2);
	y2 = (ccy - (ffy*B1t1)/B1t2) / (B2t1 - (B1t1*B2t2)/B1t2);
	x1 = (ccx - x2*B2t1) / B1t1;
	y1 = (ccy - y2*B2t1) / B1t1;

	x1 = max(0+epsilon, min(1-epsilon, x1));
	x2 = max(0+epsilon, min(1-epsilon, x2));

	// Note that this function also requires cubicBezier()!
	y = cubic_bezier_01(x, float2(x1, y1), float2(x2, y2));
	return saturate(y);
}

#endif
