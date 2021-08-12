#if !defined(TANGENT_LIB_CGINC)
#define TANGENT_LIB_CGINC

/**
    construct tangent space transform
*/
#define TANGENT_SPACE_DECLARE(id0,id1,id2)\
    float4 tSpace0:TEXCOORD##id0;\
    float4 tSpace1:TEXCOORD##id1;\
    float4 tSpace2:TEXCOORD##id2

/**
    combine tangent,binormal,normal,worldPos to putput.tSpace[0..2]
*/
#define TANGENT_SPACE_COMBINE(vertex/*float3*/,normal/*float3*/,tangent/*float4*/,output/*{float4 tSpace[0..2]}*/)\
    float3 p = mul(unity_ObjectToWorld,vertex);\
    float3 n = normalize(UnityObjectToWorldNormal(normal));\
    float3 t = normalize(UnityObjectToWorldDir(tangent.xyz));\
    float3 b = normalize(cross(n,t) * tangent.w);\
    output.tSpace0 = float4(t.x,b.x,n.x,p.x);\
    output.tSpace1 = float4(t.y,b.y,n.y,p.y);\
    output.tSpace2 = float4(t.z,b.z,n.z,p.z)

/**
    split input.tSpace[0..2] to
    float3 tangent,binormal,normal,worldPos 
*/
#define TANGENT_SPACE_SPLIT(input/*tSpace[0..2]*/)\
    float3 tangent = normalize(float3(input.tSpace0.x,input.tSpace1.x,input.tSpace2.x));\
    float3 binormal = normalize(float3(input.tSpace0.y,input.tSpace1.y,input.tSpace2.y));\
    float3 normal = normalize(float3(input.tSpace0.z,input.tSpace1.z,input.tSpace2.z));\
    float3 worldPos = (float3(input.tSpace0.w,input.tSpace1.w,input.tSpace2.w))

float3 TangentToWorld(float3 tSpace0,float3 tSpace1,float3 tSpace2,float3 tn){
    return normalize(float3(dot(tSpace0,tn),dot(tSpace1,tn),dot(tSpace2,tn)));
}
#endif //TANGENT_LIB_CGINC