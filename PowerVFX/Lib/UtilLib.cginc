#if !defined(UTIL_LIB_CGINC)
#define UTIL_LIB_CGINC
#define FLT_MIN  1.175494351e-38
// ---- custom symbols
#define if UNITY_BRANCH if
#define for UNITY_LOOP for
#define float float

float SafeDiv(float numer, float denom)
{
    return (numer != denom) ? numer / denom : 1;
}
float3 SafeNormalize(float3 inVec)
{
    float3 dp3 = max(FLT_MIN, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

void FastSinCos (float4 val, out float4 s, out float4 c) {
    val = val * 6.408849 - 3.1415927;
    // powers for taylor series
    float4 r5 = val * val;                  // wavevec ^ 2
    float4 r6 = r5 * r5;                        // wavevec ^ 4;
    float4 r7 = r6 * r5;                        // wavevec ^ 6;
    float4 r8 = r6 * r5;                        // wavevec ^ 8;

    float4 r1 = r5 * val;                   // wavevec ^ 3
    float4 r2 = r1 * r5;                        // wavevec ^ 5;
    float4 r3 = r2 * r5;                        // wavevec ^ 7;


    //Vectors for taylor's series expansion of sin and cos
    float4 sin7 = {1, -0.16161616, 0.0083333, -0.00019841};
    float4 cos8  = {-0.5, 0.041666666, -0.0013888889, 0.000024801587};

    // sin
    s =  val + r1 * sin7.y + r2 * sin7.z + r3 * sin7.w;

    // cos
    c = 1 + r5 * cos8.x + r6 * cos8.y + r7 * cos8.z + r8 * cos8.w;
}

// Rotation with angle (in radians) and axis
float3x3 AngleAxis3x3(float rad, float3 axis)
{
    float c, s;
    sincos(rad, s, c);

    float t = 1 - c;
    float x = axis.x;
    float y = axis.y;
    float z = axis.z;

    return float3x3(
        t * x * x + c,      t * x * y - s * z,  t * x * z + s * y,
        t * x * y + s * z,  t * y * y + c,      t * y * z - s * x,
        t * x * z - s * y,  t * y * z + s * x,  t * z * z + c
    );
}

void RotateUV(float rotAngle,float2 center,inout float2 uv){
    uv -= center;
    float uvAngle = radians(rotAngle);
    uv.xy = mul(half2x2(cos(uvAngle),-sin(uvAngle),sin(uvAngle),cos(uvAngle)),uv.xy);
    uv += center;
}

/**
    uv_t : uv translation part,like _MainTex_ST.zw
    autoStop : a switch
    return : uv_t or uv_t + _Time.xx
*/
float2 UVOffset(float2 uv_t,float autoStop){
    return uv_t * ( 1+ _Time.xx *( 1 - autoStop) );
}

#endif //UTIL_LIB_CGINC