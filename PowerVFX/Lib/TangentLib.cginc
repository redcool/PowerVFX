#if !defined(TANGENT_LIB_CGINC)
#define TANGENT_LIB_CGINC

/**
    construct tangent space transform
*/
#define TANGENT_SPACE_DECLARE(id0,id1,id2)\
    half4 tSpace0:TEXCOORD##id0;\
    half4 tSpace1:TEXCOORD##id1;\
    half4 tSpace2:TEXCOORD##id2

/**
    combine tangent,binormal,normal,worldPos to putput.tSpace[0..2]
*/
#define TANGENT_SPACE_COMBINE_LOCAL(vertex/*half3*/,normal/*half3*/,tangent/*half4*/,output/*{half4 tSpace[0..2]}*/)\
    half3 p = mul(unity_ObjectToWorld,vertex);\
    half3 n = normalize(UnityObjectToWorldNormal(normal));\
    half3 t = normalize(UnityObjectToWorldDir(tangent.xyz));\
    half3 b = normalize(cross(n,t) * tangent.w);\
    output.tSpace0 = half4(t.x,b.x,n.x,p.x);\
    output.tSpace1 = half4(t.y,b.y,n.y,p.y);\
    output.tSpace2 = half4(t.z,b.z,n.z,p.z)

#define TANGENT_SPACE_COMBINE(vertex/*half3*/,normal/*half3*/,tangent/*half4*/,output/*{half4 tSpace[0..2]}*/)\
    half3 p = vertex;\
    half3 n = normal;\
    half3 t = tangent.xyz;\
    half3 b = normalize(cross(n,t) * tangent.w);\
    output.tSpace0 = half4(t.x,b.x,n.x,p.x);\
    output.tSpace1 = half4(t.y,b.y,n.y,p.y);\
    output.tSpace2 = half4(t.z,b.z,n.z,p.z)
/**
    split input.tSpace[0..2] to
    half3 tangent,binormal,normal,worldPos 
*/
#define TANGENT_SPACE_SPLIT(input/*tSpace[0..2]*/)\
    half3 tangent = normalize(half3(input.tSpace0.x,input.tSpace1.x,input.tSpace2.x));\
    half3 binormal = normalize(half3(input.tSpace0.y,input.tSpace1.y,input.tSpace2.y));\
    half3 normal = normalize(half3(input.tSpace0.z,input.tSpace1.z,input.tSpace2.z));\
    half3 worldPos = (half3(input.tSpace0.w,input.tSpace1.w,input.tSpace2.w))

half3 TangentToWorld(half3 tSpace0,half3 tSpace1,half3 tSpace2,half3 tn){
    return normalize(half3(dot(tSpace0,tn),dot(tSpace1,tn),dot(tSpace2,tn)));
}
#endif //TANGENT_LIB_CGINC