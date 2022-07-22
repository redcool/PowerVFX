#if !defined(BLUR_LIB_HLSL)
#define BLUR_LIB_HLSL


const static float WEIGHTS_3[3] = {0.147761,0.118318,0.0947416};
const static float WEIGHTS_7[4] = {0.3,0.2,0.1,0.05};

float3 Gaussian7(sampler2D tex,float2 uv,float2 uvOffset){
    float3 c = tex2D(tex,uv+0) * WEIGHTS_7[0];
    for(int i=1;i<4;i++){
        c += tex2D(tex,uv + uvOffset * i) * WEIGHTS_7[i];
        c += tex2D(tex,uv - uvOffset * i) * WEIGHTS_7[i];
    }
    return c;
}

float3 BoxBlur(sampler2D tex,float2 uv,float2 uvOffset){
    float3 c = tex2D(tex,uv);
    c += tex2D(tex,uv + uvOffset);
    c += tex2D(tex,uv - uvOffset);
    return c*0.33;
}



#define BOX_SAMPLES 10
#define BOX_SAMPLES_F 10.0
#define BOX_SAMPLE_COUNT 9.0
float3 BoxBlur10(sampler2D tex,float2 uv,float2 blurScale){
    float3 c = 0 ;
    for(int i=0;i<BOX_SAMPLES;i++){
        float2 blurUV = uv + (i/ BOX_SAMPLE_COUNT - 0.5) * blurScale;
        // float2 blurUV = uv + i * texelSize * scale;
        c += tex2D(tex,blurUV);
    }
    return c / BOX_SAMPLES_F;
}

//0.2,0.15,0.1,0.05,0.025
const static float WEIGHTS_10[10] = {0.025,0.05,0.1,0.15,0.2,0.2,0.15,0.1,0.05,0.025};
float3 GaussianBlur10(sampler2D tex,float2 uv,float2 blurScale){
    float3 c = 0 ;
    for(int i=0;i<BOX_SAMPLES;i++){
        float2 blurUV = uv + (i/ BOX_SAMPLE_COUNT - 0.5) * blurScale;
        // float2 blurUV = uv + i * texelSize * scale;
        c += tex2D(tex,blurUV) * WEIGHTS_10[i];
    }
    return c;
}

#endif //BLUR_LIB_HLSL