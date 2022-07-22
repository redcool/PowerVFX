// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

#ifndef NODE_LIB_CGINC
#define NODE_LIB_CGINC

#define PI 3.14159

/**
	计算太阳斑点的衰减
	sunSize : 太阳亮斑,大小
	sunPos : 世界空间中太阳的方向
	worldPos:片段的世界坐标
*/
float sunAtten(float sunSize,float3 sunPos,float3 worldPos){
	float3 delta = normalize(worldPos.xyz) - sunPos.xyz;
	float dist = length(delta);
	float circle = 1 - smoothstep(0,sunSize,dist);
	return circle * circle;
}

/**
	col.rgb += sunAtten2(_SunSizeConvergence,_SunSize,_WorldSpaceLightPos0.xyz,worldPos);
*/
float sunAtten2(float sunPower,float sunSize,float3 sunPos,float3 worldPos){
	float atten = pow(saturate(dot(sunPos.xyz,normalize(worldPos))),sunPower);
	for(int i=0;i<3;i++)
		atten *= atten;
	return atten * sunSize;
}

float3 ComputeRipple(sampler2D rippleTex,float2 uv, float t)
{
	float4 ripple = tex2D(rippleTex, uv);
	ripple.yz = ripple.yz * 2.0 - 1.0;

	float drop = frac(ripple.a + t);
	float move = ripple.x + drop -1;
	float dropFactor = 1 - saturate(drop);

	float final = dropFactor * sin(clamp(move*9,0,4)*PI);
	return float3(ripple.yz * final,1);
}


float3 BlendNormal(float3 a, float3 b) {
	return normalize(float3(a.rb + b.rg, a.b*b.b));
}

float SimpleSubSurface(float3 l,float3 v,float3 n,float distortion,float power,float thick){
	float3 h = normalize(l+n * distortion);
	float scatter = pow(saturate(dot(v,h)),power) * thick;
	return scatter;
}

float SimpleFresnal(float3 v, float3 n, float power) {
	return pow(1 - saturate(dot(normalize(n), normalize(v))), power);
}

float SchlickFresnal2(float3 v, float h, float f0) {
	float base = 1 - dot(v, h);
	float power = pow(base, 5.0);
	return power + f0 * (1 - power);
}

float SchlickFresnal(float3 v, float3 n, float f0) {
	return f0 + (1 - f0) * pow(1 - dot(v, n), 5);
}

float Random(float s) {
	return frac(sin(s) * 100000);
}

float Random(float2 st){
	return frac(sin(dot(st,float2(12.123,78.789))) * 65432);
}

float Gray(float3 rgb){
	return dot(float3(0.07,0.7,0.2),rgb);
}

float2 PolarUV(float2 mainUV,float2 center,float lenScale,float lenOffset,float rotOffset){
	float2 uv = mainUV-center;

	float r = sqrt(uv.x*uv.x+uv.y*uv.y)*lenScale+lenOffset;
	float t = atan2(uv.y,uv.x) + rotOffset;
	return float2(t,r);
}

float2 Twirl(float2 uv,float2 center,float scale,float2 offset){
	float2 dir = uv - center;
	float len = length(dir) * scale;

	float2 nuv = float2(
		dot(float2(cos(len),-sin(len)),dir),
		dot(float2(sin(len),cos(len)),dir)
	);
	
	return nuv + center + offset;
}









//input

float3 _Camera_Position() { return _WorldSpaceCameraPos; }
//float3 _Camera_Direction() { return -1 * mul(UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V))[2].xyz); }
float _Camera_Orthographic() { return unity_OrthoParams.w; }
float _Camera_NearPlane() { return _ProjectionParams.y; }
float _Camera_FarPlane() { return _ProjectionParams.z; }
float _Camera_ZBufferSign() { return _ProjectionParams.x; }
float _Camera_Width() { return unity_OrthoParams.x; }
float _Camera_Height() { return unity_OrthoParams.y; }

//artistic
float3 NormalStrength(float3 n, float strength) {
	return float3(n.rg * strength, lerp(1, n.b, saturate(strength)));
}


void Unity_TilingAndOffset_half(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
	Out = UV * Tiling + Offset;
}


//   Procedural

void Unity_Checkerboard_half(float2 UV, float3 ColorA, float3 ColorB, float2 Frequency, out float3 Out)
{
    UV = (UV.xy + 0.5) * Frequency;
    float4 derivatives = float4(ddx(UV), ddy(UV));
    float2 duv_length = sqrt(float2(dot(derivatives.xz, derivatives.xz), dot(derivatives.yw, derivatives.yw)));
    float width = 1.0;
    float2 distance3 = 4.0 * abs(frac(UV + 0.25) - 0.5) - width;
    float2 scale = 0.35 / duv_length.xy;
    float freqLimiter = sqrt(clamp(1.1f - max(duv_length.x, duv_length.y), 0.0, 1.0));
    float2 vector_alpha = clamp(distance3 * scale.xy, -1.0, 1.0);
    float alpha = saturate(0.5f + 0.5f * vector_alpha.x * vector_alpha.y * freqLimiter);
    Out = lerp(ColorA, ColorB, alpha.xxx);
}

float3 Checkerboard(float2 uv,float3 color1,float3 color2,float2 frequency){
	float2 c = floor(uv * frequency)/2;
	float checker = frac(c.x+c.y)*2;
	return lerp(color1,color2,checker);
}

// Interleaved gradient function from Jimenez 2014
// http://www.iryoku.com/next-generation-post-processing-in-call-of-duty-advanced-warfare
float GradientNoise(float2 uv)
{
    uv = floor(uv * _ScreenParams.xy);
    float f = dot(float2(0.06711056, 0.00583715), uv);
    return frac(52.9829189 * frac(f));
}

//------------- ShaderGraph
float2 unity_gradientNoise_dir(float2 p)
{
    p = p % 289;
    float x = (34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

float unity_gradientNoise(float2 p)
{
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(unity_gradientNoise_dir(ip), fp);
    float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}

void Unity_GradientNoise_half(float2 UV, float Scale, out float Out)
{
    Out = unity_gradientNoise(UV * Scale) + 0.5;
}

float Unity_GradientNoise(float2 uv,float scale){
	return  unity_gradientNoise(uv * scale) + 0.5;
}

//---------------------------

inline float unity_noise_randomValue(float2 uv)
{
	return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
}

inline float unity_noise_interpolate(float a, float b, float t)
{
	return (1.0 - t)*a + (t*b);
}

inline float unity_valueNoise(float2 uv)
{
	float2 i = floor(uv);
	float2 f = frac(uv);
	f = f * f * (3.0 - 2.0 * f);

	uv = abs(frac(uv) - 0.5);
	float2 c0 = i + float2(0.0, 0.0);
	float2 c1 = i + float2(1.0, 0.0);
	float2 c2 = i + float2(0.0, 1.0);
	float2 c3 = i + float2(1.0, 1.0);
	float r0 = unity_noise_randomValue(c0);
	float r1 = unity_noise_randomValue(c1);
	float r2 = unity_noise_randomValue(c2);
	float r3 = unity_noise_randomValue(c3);

	float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
	float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
	float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
	return t;
}

void Unity_SimpleNoise_half(float2 UV, float Scale, out float Out)
{
	float t = 0.0;

	float freq = pow(2.0, float(0));
	float amp = pow(0.5, float(3 - 0));
	t += unity_valueNoise(float2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

	freq = pow(2.0, float(1));
	amp = pow(0.5, float(3 - 1));
	t += unity_valueNoise(float2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

	freq = pow(2.0, float(2));
	amp = pow(0.5, float(3 - 2));
	t += unity_valueNoise(float2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

	Out = t;
}

void Unity_Dither_half4(float4 In, float4 ScreenPosition, out float4 Out)
{
    float2 uv = ScreenPosition.xy * _ScreenParams.xy;
    float DITHER_THRESHOLDS[16] =
    {
        1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
    };
    uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
    Out = In - DITHER_THRESHOLDS[index];
}

void Unity_WhiteBalance_float(float3 In, float Temperature, float Tint, out float3 Out)
{
    // Range ~[-1.67;1.67] works best
    float t1 = Temperature * 10 / 6;
    float t2 = Tint * 10 / 6;

    // Get the CIE xy chromaticity of the reference white point.
    // Note: 0.31271 = x value on the D65 white point
    float x = 0.31271 - t1 * (t1 < 0 ? 0.1 : 0.05);
    float standardIlluminantY = 2.87 * x - 3 * x * x - 0.27509507;
    float y = standardIlluminantY + t2 * 0.05;

    // Calculate the coefficients in the LMS space.
    float3 w1 = float3(0.949237, 1.03542, 1.08728); // D65 white point

    // CIExyToLMS
    float Y = 1;
    float X = Y * x / y;
    float Z = Y * (1 - x - y) / y;
    float L = 0.7328 * X + 0.4296 * Y - 0.1624 * Z;
    float M = -0.7036 * X + 1.6975 * Y + 0.0061 * Z;
    float S = 0.0030 * X + 0.0136 * Y + 0.9834 * Z;
    float3 w2 = float3(L, M, S);

    float3 balance = float3(w1.x / w2.x, w1.y / w2.y, w1.z / w2.z);

    float3x3 LIN_2_LMS_MAT = {
        3.90405e-1, 5.49941e-1, 8.92632e-3,
        7.08416e-2, 9.63172e-1, 1.35775e-3,
        2.31082e-2, 1.28021e-1, 9.36245e-1
    };

    float3x3 LMS_2_LIN_MAT = {
        2.85847e+0, -1.62879e+0, -2.48910e-2,
        -2.10182e-1,  1.15820e+0,  3.24281e-4,
        -4.18120e-2, -1.18169e-1,  1.06867e+0
    };

    float3 lms = mul(LIN_2_LMS_MAT, In);
    lms *= balance;
    Out = mul(LMS_2_LIN_MAT, lms);
}
#endif