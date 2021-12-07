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
half sunAtten(half sunSize,half3 sunPos,half3 worldPos){
	half3 delta = normalize(worldPos.xyz) - sunPos.xyz;
	half dist = length(delta);
	half circle = 1 - smoothstep(0,sunSize,dist);
	return circle * circle;
}

/**
	col.rgb += sunAtten2(_SunSizeConvergence,_SunSize,_WorldSpaceLightPos0.xyz,worldPos);
*/
half sunAtten2(half sunPower,half sunSize,half3 sunPos,half3 worldPos){
	half atten = pow(saturate(dot(sunPos.xyz,normalize(worldPos))),sunPower);
	for(int i=0;i<3;i++)
		atten *= atten;
	return atten * sunSize;
}

half3 ComputeRipple(sampler2D rippleTex,half2 uv, half t)
{
	half4 ripple = tex2D(rippleTex, uv);
	ripple.yz = ripple.yz * 2.0 - 1.0;

	half drop = frac(ripple.a + t);
	half move = ripple.x + drop -1;
	half dropFactor = 1 - saturate(drop);

	half final = dropFactor * sin(clamp(move*9,0,4)*PI);
	return half3(ripple.yz * final,1);
}


half3 BlendNormal(half3 a, half3 b) {
	return normalize(half3(a.rb + b.rg, a.b*b.b));
}

half SimpleSubSurface(half3 l,half3 v,half3 n,half distortion,half power,half thick){
	half3 h = normalize(l+n * distortion);
	half scatter = pow(saturate(dot(v,h)),power) * thick;
	return scatter;
}

half SimpleFresnal(half3 v, half3 n, half power) {
	return pow(1 - saturate(dot(normalize(n), normalize(v))), power);
}

half SchlickFresnal2(half3 v, half h, half f0) {
	half base = 1 - dot(v, h);
	half power = pow(base, 5.0);
	return power + f0 * (1 - power);
}

half SchlickFresnal(half3 v, half3 n, half f0) {
	return f0 + (1 - f0) * pow(1 - dot(v, n), 5);
}

half Random(half s) {
	return frac(sin(s) * 100000);
}

half Random(half2 st){
	return frac(sin(dot(st,half2(12.123,78.789))) * 65432);
}

half Gray(half3 rgb){
	return dot(half3(0.07,0.7,0.2),rgb);
}

half2 PolarUV(half2 mainUV,half2 center,half lenScale,half lenOffset,half rotOffset){
	half2 uv = mainUV-center;

	half r = sqrt(uv.x*uv.x+uv.y*uv.y)*lenScale+lenOffset;
	half t = atan2(uv.y,uv.x) + rotOffset;
	return half2(t,r);
}

half2 Twirl(half2 uv,half2 center,half scale,half2 offset){
	half2 dir = uv - center;
	half len = length(dir) * scale;

	half2 nuv = half2(
		dot(half2(cos(len),-sin(len)),dir),
		dot(half2(sin(len),cos(len)),dir)
	);
	
	return nuv + center + offset;
}









//input

half3 _Camera_Position() { return _WorldSpaceCameraPos; }
//half3 _Camera_Direction() { return -1 * mul(UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V))[2].xyz); }
half _Camera_Orthographic() { return unity_OrthoParams.w; }
half _Camera_NearPlane() { return _ProjectionParams.y; }
half _Camera_FarPlane() { return _ProjectionParams.z; }
half _Camera_ZBufferSign() { return _ProjectionParams.x; }
half _Camera_Width() { return unity_OrthoParams.x; }
half _Camera_Height() { return unity_OrthoParams.y; }

//artistic
half3 NormalStrength(half3 n, half strength) {
	return half3(n.rg * strength, lerp(1, n.b, saturate(strength)));
}


void Unity_TilingAndOffset_half(half2 UV, half2 Tiling, half2 Offset, out half2 Out)
{
	Out = UV * Tiling + Offset;
}


//   Procedural

void Unity_Checkerboard_half(half2 UV, half3 ColorA, half3 ColorB, half2 Frequency, out half3 Out)
{
    UV = (UV.xy + 0.5) * Frequency;
    half4 derivatives = half4(ddx(UV), ddy(UV));
    half2 duv_length = sqrt(half2(dot(derivatives.xz, derivatives.xz), dot(derivatives.yw, derivatives.yw)));
    half width = 1.0;
    half2 distance3 = 4.0 * abs(frac(UV + 0.25) - 0.5) - width;
    half2 scale = 0.35 / duv_length.xy;
    half freqLimiter = sqrt(clamp(1.1f - max(duv_length.x, duv_length.y), 0.0, 1.0));
    half2 vector_alpha = clamp(distance3 * scale.xy, -1.0, 1.0);
    half alpha = saturate(0.5f + 0.5f * vector_alpha.x * vector_alpha.y * freqLimiter);
    Out = lerp(ColorA, ColorB, alpha.xxx);
}

half3 Checkerboard(half2 uv,half3 color1,half3 color2,half2 frequency){
	half2 c = floor(uv * frequency)/2;
	half checker = frac(c.x+c.y)*2;
	return lerp(color1,color2,checker);
}

// Interleaved gradient function from Jimenez 2014
// http://www.iryoku.com/next-generation-post-processing-in-call-of-duty-advanced-warfare
half GradientNoise(half2 uv)
{
    uv = floor(uv * _ScreenParams.xy);
    half f = dot(half2(0.06711056, 0.00583715), uv);
    return frac(52.9829189 * frac(f));
}

//------------- ShaderGraph
half2 unity_gradientNoise_dir(half2 p)
{
    p = p % 289;
    half x = (34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(half2(x - floor(x + 0.5), abs(x) - 0.5));
}

half unity_gradientNoise(half2 p)
{
    half2 ip = floor(p);
    half2 fp = frac(p);
    half d00 = dot(unity_gradientNoise_dir(ip), fp);
    half d01 = dot(unity_gradientNoise_dir(ip + half2(0, 1)), fp - half2(0, 1));
    half d10 = dot(unity_gradientNoise_dir(ip + half2(1, 0)), fp - half2(1, 0));
    half d11 = dot(unity_gradientNoise_dir(ip + half2(1, 1)), fp - half2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}

void Unity_GradientNoise_half(half2 UV, half Scale, out half Out)
{
    Out = unity_gradientNoise(UV * Scale) + 0.5;
}

half Unity_GradientNoise(half2 uv,half scale){
	return  unity_gradientNoise(uv * scale) + 0.5;
}

//---------------------------

inline half unity_noise_randomValue(half2 uv)
{
	return frac(sin(dot(uv, half2(12.9898, 78.233)))*43758.5453);
}

inline half unity_noise_interpolate(half a, half b, half t)
{
	return (1.0 - t)*a + (t*b);
}

inline half unity_valueNoise(half2 uv)
{
	half2 i = floor(uv);
	half2 f = frac(uv);
	f = f * f * (3.0 - 2.0 * f);

	uv = abs(frac(uv) - 0.5);
	half2 c0 = i + half2(0.0, 0.0);
	half2 c1 = i + half2(1.0, 0.0);
	half2 c2 = i + half2(0.0, 1.0);
	half2 c3 = i + half2(1.0, 1.0);
	half r0 = unity_noise_randomValue(c0);
	half r1 = unity_noise_randomValue(c1);
	half r2 = unity_noise_randomValue(c2);
	half r3 = unity_noise_randomValue(c3);

	half bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
	half topOfGrid = unity_noise_interpolate(r2, r3, f.x);
	half t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
	return t;
}

void Unity_SimpleNoise_half(half2 UV, half Scale, out half Out)
{
	half t = 0.0;

	half freq = pow(2.0, half(0));
	half amp = pow(0.5, half(3 - 0));
	t += unity_valueNoise(half2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

	freq = pow(2.0, half(1));
	amp = pow(0.5, half(3 - 1));
	t += unity_valueNoise(half2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

	freq = pow(2.0, half(2));
	amp = pow(0.5, half(3 - 2));
	t += unity_valueNoise(half2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

	Out = t;
}

void Unity_Dither_half4(half4 In, half4 ScreenPosition, out half4 Out)
{
    half2 uv = ScreenPosition.xy * _ScreenParams.xy;
    half DITHER_THRESHOLDS[16] =
    {
        1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
    };
    uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
    Out = In - DITHER_THRESHOLDS[index];
}

#endif