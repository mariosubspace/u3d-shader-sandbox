#ifndef UTIL_EASINGS_CGINC
#define UTIL_EASINGS_CGINC

#include "ConstantsMath.cginc"

// Robert Penner's easing functions in GLSL
// https://github.com/stackgl/glsl-easings
// http://easings.net/

float exponential_in(float t)
{
	return t == 0.0 ? t : pow(2.0, 10.0 * (t - 1.0));
}

float exponential_out(float t)
{
 	return t == 1.0 ? t : 1.0 - pow(2.0, -10.0 * t);
}

float exponential_in_out(float t)
{
	return (t == 0.0 || t == 1.0)
		? t
		: ( (t < 0.5)
			? +0.5 * pow(2.0, (20.0 * t) - 10.0)
			: -0.5 * pow(2.0, 10.0 - (t * 20.0)) + 1.0);
}

float sine_in(float t)
{
	return sin((t - 1.0) * HALF_PI) + 1.0;
}

float sine_out(float t)
{
	return sin(t * HALF_PI);
}

float sine_in_out(float t)
{
	return -0.5 * (cos(PI * t) - 1.0);
}

float qintic_in(float t)
{
	return pow(t, 5.0);
}

float qintic_out(float t)
{
	return 1.0 - pow(t - 1.0, 5.0);
}

float qintic_in_out(float t)
{
	return (t < 0.5)
		? +16.0 * pow(t, 5.0)
		: -0.5 * pow(2.0 * t - 2.0, 5.0) + 1.0;
}

float quartic_in(float t)
{
	return pow(t, 4.0);
}

float quartic_out(float t)
{
	return pow(t - 1.0, 3.0) * (1.0 - t) + 1.0;
}

float quartic_in_out(float t)
{
	return (t < 0.5)
		? +8.0 * pow(t, 4.0)
		: -8.0 * pow(t - 1.0, 4.0) + 1.0;
}

float quadratic_in_out(float t)
{
	float p = 2.0 * t * t;
	return t < 0.5 ? p : -p + (4.0 * t) - 1.0;
}

float quadratic_in(float t)
{
	return t * t;
}

float quadratic_out(float t)
{
	return -t * (t - 2.0);
}

float cubic_in(float t)
{
	return t * t * t;
}

float cubic_out(float t)
{
	float f = t - 1.0;
	return f * f * f + 1.0;
}

float cubic_in_out(float t)
{
	return (t < 0.5)
		? 4.0 * t * t * t
		: 0.5 * pow(2.0 * t - 2.0, 3.0) + 1.0;
}

float elastic_in(float t)
{
	return sin(13.0 * t * HALF_PI) * pow(2.0, 10.0 * (t - 1.0));
}

float elastic_out(float t)
{
	return sin(-13.0 * (t + 1.0) * HALF_PI) * pow(2.0, -10.0 * t) + 1.0;
}

float elastic_in_out(float t)
{
	return t < 0.5
		? 0.5 * sin(+13.0 * HALF_PI * 2.0 * t) * pow(2.0, 10.0 * (2.0 * t - 1.0))
		: 0.5 * sin(-13.0 * HALF_PI * ((2.0 * t - 1.0) + 1.0)) * pow(2.0, -10.0 * (2.0 * t - 1.0)) + 1.0;
}

float circular_in(float t)
{
	return 1.0 - sqrt(1.0 - t * t);
}

float circular_out(float t)
{
	return sqrt((2.0 - t) * t);
}

float circular_in_out(float t)
{
	return (t < 0.5)
		? 0.5 * (1.0 - sqrt(1.0 - 4.0 * t * t))
		: 0.5 * (sqrt((3.0 - 2.0 * t) * (2.0 * t - 1.0)) + 1.0);
}

float bounce_out(float t)
{
	const float a = 4.0 / 11.0;
	const float b = 8.0 / 11.0;
	const float c = 9.0 / 10.0;

	const float ca = 4356.0 / 361.0;
	const float cb = 35442.0 / 1805.0;
	const float cc = 16061.0 / 1805.0;

	float t2 = t * t;

	return (t < a)
		? 7.5625 * t2
		: ( (t < b)
			? 9.075 * t2 - 9.9 * t + 3.4
			: ( (t < c)
				? ca * t2 - cb * t + cc
				: 10.8 * t * t - 20.52 * t + 10.72 ));
}

float bounce_in(float t)
{
	return 1.0 - bounce_out(1.0 - t);
}

float bounce_in_out(float t)
{
	return (t < 0.5)
		? 0.5 * (1.0 - bounce_out(1.0 - t * 2.0))
		: 0.5 * bounce_out(t * 2.0 - 1.0) + 0.5;
}

float back_in(float t)
{
	return pow(t, 3.0) - t * sin(t * PI);
}

float back_out(float t)
{
	float f = 1.0 - t;
	return 1.0 - (pow(f, 3.0) - f * sin(f * PI));
}

float back_in_out(float t)
{
	float f = t < 0.5
		? 2.0 * t
		: 1.0 - (2.0 * t - 1.0);

	float g = pow(f, 3.0) - f * sin(f * PI);

	return t < 0.5
		? 0.5 * g
		: 0.5 * (1.0 - g) + 0.5;
}

#endif
