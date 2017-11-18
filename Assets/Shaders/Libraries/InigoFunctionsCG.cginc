#ifndef INIGO_FUNCTIONS_CG
#define INIGO_FUNCTIONS_CG

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

#endif
