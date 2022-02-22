#if !defined(BLUR_LIB_HLSL)
#define BLUR_LIB_HLSL


const static half WEIGHTS_3[3] = {0.147761,0.118318,0.0947416};
const static half WEIGHTS_7[4] = {0.3,0.2,0.1,0.05};

half3 Gaussian7(sampler2D tex,half2 uv,half2 uvOffset){
    half3 c = tex2D(tex,uv+0) * WEIGHTS_7[0];
    for(int i=1;i<4;i++){
        c += tex2D(tex,uv + uvOffset * i) * WEIGHTS_7[i];
        c += tex2D(tex,uv - uvOffset * i) * WEIGHTS_7[i];
    }
    return c;
}

half3 BoxBlur(sampler2D tex,half2 uv,half2 uvOffset){
    half3 c = tex2D(tex,uv);
    c += tex2D(tex,uv + uvOffset);
    c += tex2D(tex,uv - uvOffset);
    return c*0.33;
}

#endif //BLUR_LIB_HLSL