cbuffer GlobalPS :register(b3)
{
 float4 CameraPosPS:packoffset(c0);
 float4 CameraInfoPS:packoffset(c1);
 float4 EnvInfo:packoffset(c2);
 float4 SunColor:packoffset(c3);
 float4 SunDirection:packoffset(c4);
 float4 AmbientColor:packoffset(c5);
 float4 FogColor:packoffset(c6);
 float4 ShadowColor:packoffset(c7);
 float4 ScreenColor:packoffset(c8);
 float4 ReflectionPos:packoffset(c9);
 float4 ScreenInfoPS:packoffset(c10);
 float4 FogColor2:packoffset(c11);
 float4 FogColor3:packoffset(c12);
 float4x4 ViewProjPS:packoffset(c13);
};
cbuffer LightGroup :register(b4)
{
 float4 Lights0[4]:packoffset(c0);
 float4 Lights1[4]:packoffset(c4);
 float4 Lights2[4]:packoffset(c8);
};
cbuffer UserBuffer :register(b6)
{
 float4 UserData[3]:packoffset(c0);
};
float DecodeDepth(in float4 rgba)
{
 return rgba.x;
}
float Hash(in float2 p)
{
 return frac(((sin(dot(p,float2(127.1,311.7))))*(43758.5453)));
}
float Noise(in float2 p)
{
 float2 i=floor(p);
 float2 f=frac(p);
 float2 u=((((f)*(f)))*(((3.0)-(((2.0)*(f))))));
 return (((-(1.0)))+(((2.0)*(lerp(lerp(Hash(((i)+(float2(0.0,0.0)))),Hash(((i)+(float2(1.0,0.0)))),u.x),lerp(Hash(((i)+(float2(0.0,1.0)))),Hash(((i)+(float2(1.0,1.0)))),u.x),u.y)))));
}
float SeaOctave(float2 uv)
{
 (uv)+=(Noise(uv));
 float2 wv=((1.0)-(abs(sin(uv))));
 float2 swv=abs(cos(uv));
 (wv)=(lerp(wv,swv,wv));
 return ((1.0)-(pow(((wv.x)*(wv.y)),0.65)));
}
float3 RippleNormal(in float3 N,in float2 uv)
{
 float4 jitterUV;
 half worldscale=5;
 (jitterUV)=(((((uv.xyxy)*(float4(1.5,5,5,1.5))))*(worldscale)));
 float4 seed=((((clamp(((N.xzxz)*(10000)),(-(1)),1))*(float4(20,20,6,6))))*(CameraPosPS.w));
 float R1=((SeaOctave(((((jitterUV.yx)*(10)))-(seed.x))))+(SeaOctave(float2(((((jitterUV.z)*(3)))-(seed.z)),((jitterUV.w)*(3))))));
 float R3=((SeaOctave(float2(((((jitterUV.xy)*(4)))-(seed.w)))))+(SeaOctave(((((jitterUV.zw)*(8)))-(seed.y)))));
 (R3)*=(0.5);
 float R_D=((((((((((((R1)*(N.x)))*(N.x)))+(((((R3)*(N.z)))*(N.z)))))*(5)))+(((((R1)+(R3)))*(0.1)))))-(0.212));
 (R_D)*=(((((step(0.5,EnvInfo.x))*(EnvInfo.x)))*(1.3)));
 return normalize(lerp(((N)+(float3(0,0,R_D))),N,((1)-(((0.2)*(saturate(N.y)))))));
}
half CastHalf(in half color)
{
 return color;
 return color;
}
half2 CastHalf(in half2 color)
{
 return color;
 return color;
}
half3 CastHalf(in half3 color)
{
 return color;
 return color;
}
half4 CastHalf(in half4 color)
{
 return color;
 return color;
}
float3 GetFinalGrayColor(in float3 rgb,in float gray)
{
 float weight=0;
 (weight)=(step(2,((saturate(gray))+(UserData[2].x))));
 return ((((rgb)*(((1)-(weight)))))+(((weight)*(dot(rgb,half3(0.3,0.59,0.11))))));
}
cbuffer Batch :register(b0)
{
 float4x3 World:packoffset(c0);
 float4 cTintColor1:packoffset(c3);
 float4 cTintColor2:packoffset(c4);
 float4 cTintColor3:packoffset(c5);
 float4 cShadowBias:packoffset(c6);
 float4 cPointCloud[6]:packoffset(c7);
 float4 cParamter:packoffset(c13);
 float4 cParamter2:packoffset(c14);
 float4 cVirtualLitDir:packoffset(c15);
 float4 cVirtualLitColor:packoffset(c16);
};
cbuffer Shader :register(b1)
{
 float3 cBaseColor:packoffset(c0.x);
 float cFogDistance:packoffset(c0.w);
 float cAliasingFactor:packoffset(c1.x);
 float cEnvStrength:packoffset(c1.y);
 float cRoughnessLow:packoffset(c1.z);
 float cRoughnessHigh:packoffset(c1.w);
 float4 cLightMapScale:packoffset(c2);
 float4 cLightMapUVTransform:packoffset(c3);
 float cSmoothness:packoffset(c4.x);
 float cBloomScale:packoffset(c4.y);
 float cBaseMapBias:packoffset(c4.z);
 float cNormalMapBias:packoffset(c4.w);
 float4 cEmissionScale:packoffset(c5);
 float4 cEmissionScrolling:packoffset(c6);
 float4 cColorTransform0:packoffset(c7);
 float4 cColorTransform1:packoffset(c8);
 float4 cColorTransform2:packoffset(c9);
 float4 cLocalEnvMapCenter:packoffset(c10);
 float4 cLocalEnvMapScale:packoffset(c11);
 float4 clightColor:packoffset(c12);
 float cGrayPencent:packoffset(c13.x);
 float3 cMarkColor:packoffset(c13.y);
 float4 cMarkScaleOffset:packoffset(c14);
 float4 cMarkRegion:packoffset(c15);
 float cMarkIntensity:packoffset(c16.x);
 float cShadowFilterScale:packoffset(c16.y);
 float cLocalEnvMapStartTime:packoffset(c16.z);
 float cLocalEnvMapBlendTime:packoffset(c16.w);
 float4 cColorTransform3:packoffset(c17);
 float4 cColorTransform4:packoffset(c18);
 float4 cColorTransform5:packoffset(c19);
};
Texture2D<half4> tBaseMap:register(t0);
sampler sBaseSampler:register(s0);
Texture2D<half4> tMixMap:register(t1);
sampler sMixSampler:register(s1);
Texture2D<half4> tNormalMap:register(t2);
sampler sNormalSampler:register(s2);
Texture2D<half4> tEnvMap:EnvMap:register(t5);
sampler sEnvSampler:register(s5);
Texture2D tShadowMap:ShadowMap:register(t6);
sampler sShadowMapSampler:register(s6);
Texture2D<half4> tMaskMap:register(t8);
sampler sMaskSampler:register(s8);
struct VertexShadingOutput
{
 float4 HPosition:SV_Position;
 float4 TexCoord:TEXCOORD0;
 float4 WorldPosition:TEXCOORD1;
 float4 WorldNormal:TEXCOORD2;
 float4 ViewDirection:TEXCOORD3;
 float4 DiffLighting:TEXCOORD4;
 float3 WorldTangent:TEXCOORD5;
 float3 WorldBinormal:TEXCOORD6;
 float4 LitUVZ:TEXCOORD7;
};
void pcf_skin(float2 pInLitTC,float litZ,float2 vInvShadowMapWH,float filterScale,out float inShadow)
{
 {
 (inShadow)=(0);
 float2 filterRange=vInvShadowMapWH;
 float3 sampleDepth1;
 float3 sampleDepth2;
 float3 sampleDepth3;
 (sampleDepth1.x)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((pInLitTC)+(((filterRange)*(float2((-(filterScale)),(-(filterScale))))))))));
 (sampleDepth1.y)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((pInLitTC)+(((filterRange)*(float2(0,(-(filterScale))))))))));
 (sampleDepth1.z)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((pInLitTC)+(((filterRange)*(float2(filterScale,(-(filterScale))))))))));
 (sampleDepth2.x)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((pInLitTC)+(((filterRange)*(float2((-(filterScale)),0))))))));
 (sampleDepth2.y)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((pInLitTC)+(((filterRange)*(float2(0,0))))))));
 (sampleDepth2.z)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((pInLitTC)+(((filterRange)*(float2(filterScale,0))))))));
 (sampleDepth3.x)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((pInLitTC)+(((filterRange)*(float2((-(filterScale)),filterScale))))))));
 (sampleDepth3.y)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((pInLitTC)+(((filterRange)*(float2(0,filterScale))))))));
 (sampleDepth3.z)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((pInLitTC)+(((filterRange)*(float2(filterScale,filterScale))))))));
 float3 InShadow1=((litZ.xxx)>(sampleDepth1));
 float3 InShadow2=((litZ.xxx)>(sampleDepth2));
 float3 InShadow3=((litZ.xxx)>(sampleDepth3));
 float2 v2Coef=frac(((pInLitTC.xy)/(filterRange)));
 float4 v2Y1=lerp(InShadow1.xyyz,InShadow2.xyyz,v2Coef.y);
 float4 v2Y2=lerp(InShadow2.xyyz,InShadow3.xyyz,v2Coef.y);
 (inShadow)+=(lerp(v2Y1.x,v2Y1.y,v2Coef.x));
 (inShadow)+=(lerp(v2Y1.z,v2Y1.w,v2Coef.x));
 (inShadow)+=(lerp(v2Y2.x,v2Y2.y,v2Coef.x));
 (inShadow)+=(lerp(v2Y2.z,v2Y2.w,v2Coef.x));
 (inShadow)=(((inShadow)*(0.25)));
 }
}
half3 DynamicGILight(in float3 worldNormal)
{
 {
 half3 nSquared=(half3)((worldNormal)*(worldNormal));
 int3 isNegative=((worldNormal)<(0.0));
 half4 linearColor=(half4)((((((nSquared.x)*(cPointCloud[isNegative.x])))+(((nSquared.y)*(cPointCloud[((isNegative.y)+(2))])))))+(((nSquared.z)*(cPointCloud[((isNegative.z)+(4))]))));
 (linearColor.rgb)=((half3)max(half3(0.9,0.9,0.9),linearColor.rgb));
 (linearColor.rgb)*=((half3)((ShadowColor.r)*(((10)+(((((cPointCloud[3].a)*(ShadowColor.b)))*(100)))))));
 return linearColor.rgb;
 }
}
half3 LightingPS_SPEC(in float3 P,in float3 N,in float3 V,in half NoV,in half3 SpecularColor,in half Roughness,inout half3 DiffLit)
{
 half3 lighting=half3(0,0,0);
 if (((Lights0[3].w)>(0)))
 {
 float3 L=((Lights0[0].xyz)-(P));
 float dist=length(L);
 (L)/=(dist);
 float NoL=saturate(dot(N,L));
 float Atten=saturate(((((dist)*(Lights0[1].w)))+(Lights0[0].w)));
 (Atten)*=(Atten);
 (DiffLit)+=(((Lights0[1].rgb)*(((NoL)*(Atten)))));
 
 {
 float m2=((((Roughness)*(Roughness)))+(0.0002));
 (m2)*=(m2);
 float3 H=normalize(((V)+(L)));
 float NoH=saturate(dot(N,H));
 float D=((((((((NoH)*(m2)))-(NoH)))*(NoH)))+(1));
 (D)=(((((D)*(D)))+(1e-06)));
 (D)=(((((0.25)*(m2)))/(D)));
 (lighting)=(((((Lights0[1].rgb)*(SpecularColor)))*(((((Atten)*(NoL)))*(D)))));
 }
 }
 if (((((Lights1[3].w)>(0)))&&(((Lights1[2].w)<=(0)))))
 {
 float4 LightPosRange=Lights1[0];
 float4 LightColorAtten=Lights1[1];
 float3 LightDir=Lights1[2].xyz;
 float3 FallOffCosHalfThetaPHi=Lights1[3].xyz;
 half3 L=((LightPosRange.xyz)-(P));
 half D=length(L);
 (L)/=(D);
 half NoL=saturate(dot(N,L));
 half DoL=dot(LightDir,(-(L)));
 half Atten=saturate(((((D)*(LightColorAtten.w)))+(LightPosRange.w)));
 (Atten)*=(Atten);
 half spot=pow(saturate(((((DoL)*(FallOffCosHalfThetaPHi.y)))+(FallOffCosHalfThetaPHi.z))),FallOffCosHalfThetaPHi.x);
 
 {
 float m2=((((Roughness)*(Roughness)))+(0.0002));
 (m2)*=(m2);
 float3 H=normalize(((V)+(L)));
 float NoH=saturate(dot(N,H));
 float D=((((((((NoH)*(m2)))-(NoH)))*(NoH)))+(1));
 (D)=(((((D)*(D)))+(1e-06)));
 (D)=(((((0.25)*(m2)))/(D)));
 (lighting)+=(((((((Lights1[1].rgb)*(SpecularColor)))*(((((Atten)*(NoL)))*(D)))))*(spot)));
 }
 (DiffLit)+=(((LightColorAtten.rgb)*(((((NoL)*(Atten)))*(spot)))));
 }
 return lighting;
}
half GetRoughness(in half Smoothness,in float3 N)
{
 {
 half rain=0;
 
 {
 (rain)=((((half)EnvInfo.x)*(0.5)));
 (rain)=(((1)-(((rain)*((half)saturate(((((((3)*(N.y)))+(0.2)))+(((0.1)*(rain))))))))));
 return clamp(((rain)-(((rain)*(Smoothness)))),0.05,1);
 }
 }
 return ((1)-(Smoothness));
}
void PS_GetParameters(in VertexShadingOutput IN,out half3 BaseColor,out half Metallic,out half Roughness,out float3 N,out half4 Emission,out half4 GILighting,out half Alpha,out half SSSmask)
{
 half4 samplerBase;
 (samplerBase)=(tBaseMap.SampleBias(sBaseSampler,IN.TexCoord.xy,cBaseMapBias));
 (BaseColor)=(((samplerBase.rgb)*(samplerBase.rgb)));
 (Alpha)=(samplerBase.a);
 (SSSmask)=(0.0);
 float mask;
 (mask)=(tMaskMap.Sample(sMaskSampler,IN.TexCoord.xy).r);
 float4 base_color_data=float4(BaseColor,1);
 (BaseColor)=((half3)lerp(BaseColor,saturate(half3(dot(cColorTransform0,base_color_data),dot(cColorTransform1,base_color_data),dot(cColorTransform2,base_color_data))),mask));
 half AO=1.0;
 (Roughness)=(1.0);
 (Metallic)=(0);
 (Emission)=(half4(0,0,0,0));
 {
 half3 samplerMis=tMixMap.Sample(sMixSampler,IN.TexCoord.xy).rgb;
 half Smoothness=samplerMis.r;
 (Metallic)=(samplerMis.g);
 (AO)=(samplerMis.b);
 (Roughness)=(GetRoughness(Smoothness,IN.WorldNormal.xyz));
 }
 {
 half4 tangentNormal=tNormalMap.SampleBias(sNormalSampler,IN.TexCoord.xy,cNormalMapBias);
 (SSSmask)=(((1)-(tangentNormal.a)));
 
 {
 (tangentNormal.xyz)=(((((tangentNormal.xyz)*(2)))-(1)));
 (tangentNormal.xy)*=((half)cParamter.w);
 (N)=(((((((IN.WorldTangent.xyz)*(tangentNormal.x)))+(((IN.WorldBinormal.xyz)*(tangentNormal.y)))))+(((IN.WorldNormal.xyz)*(tangentNormal.z)))));
 }
 
 {
 float k=length(N);
 (N)/=(k);
 (Roughness)=(saturate(((Roughness)+((half)min(0.4,((((cAliasingFactor)*(10)))*(saturate(((1)-(k))))))))));
 }
 }
 (BaseColor)=((half3)lerp(BaseColor,saturate(half3(dot(cColorTransform3,base_color_data),dot(cColorTransform4,base_color_data),dot(cColorTransform5,base_color_data))),SSSmask));
 (N)=(RippleNormal(N,IN.WorldPosition.xz));
 (Emission.w)=(cEmissionScale.a);
 (GILighting.rgb)=(DynamicGILight(N));
 (GILighting.a)=(AO);
}
half3 EnvBRDFApprox(half3 SpecularColor,half Roughness,half NoV)
{
 half4 c0={(-(1)),(-(0.0275)),(-(0.572)),0.022};
 half4 c1={1,0.0425,1.04,(-(0.04))};
 half4 r=((((Roughness)*(c0)))+(c1));
 half a004=((((min(((r.x)*(r.x)),(half)exp2((((-(9.28)))*(NoV)))))*(r.x)))+(r.y));
 half2 AB=((((half2((-(1.04)),1.04))*(a004)))+(r.zw));
 return ((((SpecularColor)*(AB.x)))+(AB.y));
}
half3 GetDiffuseLightingPbr(in half NoL,in half shadow,in half4 GILighting,in half Alpha)
{
 return ((((saturate(NoL))*(shadow)))*(SunColor.rgb));
}
half3 IBL_Specular(in half Roughness,in float3 R,in float3 LocalR,in half NoV,in half3 SpecularColor,in half4 GILighting)
{
 {
 half3 sampleEnvSpecular=half3(0,0,0);
 half MIP_ROUGHNESS=0.17;
 half level=((Roughness)/(MIP_ROUGHNESS));
 
 {
 half fSign=((R.z)>(0));
 half fSign2=((((fSign)*(2)))-(1));
 (R.xy)/=(((((R.z)*(fSign2)))+(1)));
 (R.xy)=(((((R.xy)*(half2(0.25,(-(0.25))))))+(((0.25)+(((0.5)*(fSign)))))));
 half4 srcColor;
 (srcColor)=(tEnvMap.SampleLevel(sEnvSampler,R.xy,level));
 (sampleEnvSpecular)=(((srcColor.rgb)*(((((srcColor.a)*(srcColor.a)))*(16.0)))));
 }
 (sampleEnvSpecular)*=((half)((((((cEnvStrength)*(GILighting.a)))*(EnvInfo.w)))*(10)));
 return ((SpecularColor)*(sampleEnvSpecular));
 }
 return half3(0,0,0);
}
half3 SpecularLightingPbr(in float3 P,in float3 L,in float3 N,in float3 V,in half Roughness,in float3 R,in half NoV,in half NoL,inout half3 SpecularColor,in half4 GILighting,in half shadow)
{
 half3 Spec=half3(0,0,0);
 {
 half m=((((Roughness)*(Roughness)))+(0.0002));
 half m2=((m)*(m));
 
 {
 (SpecularColor)=(EnvBRDFApprox(SpecularColor,Roughness,NoV));
 
 (Spec)=(IBL_Specular(Roughness,R,R,NoV,SpecularColor,GILighting));
 }
 
 {
 half3 sunSpec=half3(0,0,0);
 
 {
 float3 H=normalize(((V)+(L)));
 float NoH=saturate(dot(N,H));
 float VoH=saturate(dot(V,H));
 (Roughness)=(max(0.08,Roughness));
 float m=((Roughness)*(Roughness));
 float m2=((m)*(m));
 float d=((((((((NoH)*(m2)))-(NoH)))*(NoH)))+(1));
 float D=((m2)/(((((d)*(d)))*(3.14159265))));
 float k=((m)*(0.5));
 float G_SchlickV=((((NoV)*(((1)-(k)))))+(k));
 float G_SchlickL=((((saturate(NoL))*(((1)-(k)))))+(k));
 half G=((0.25)/(((G_SchlickV)*(G_SchlickL))));
 half3 F=((SpecularColor)+(((((saturate(((50.0)*(SpecularColor.g))))-(SpecularColor)))*(CastHalf(exp2((((((((-(5.55473)))*(VoH)))-(6.98316)))*(VoH))))))));
 (sunSpec)=(((((D)*(G)))*(F)));
 }
 (sunSpec)*=(((SunColor.rgb)*(saturate(((NoL)*(shadow))))));
 (Spec)+=(sunSpec);
 }
 }
 return Spec;
}
float4 PbrPixelShadingHigh(in VertexShadingOutput IN):SV_Target
{
 float4 OUT=float4(0,0,0,0);
 half3 SPEC=0;
 half3 BaseColor=half3(1,1,1);
 half Metallic=0;
 half Roughness=0.3;
 float3 N=float3(0,1,0);
 half4 Emission=half4(0,0,0,1);
 half4 GILighting=half4(0,0,0,1);
 half Alpha=1.0;
 half SSSmask=0.0;
 PS_GetParameters(IN,BaseColor,Metallic,Roughness,N,Emission,GILighting,Alpha,SSSmask);
 (OUT.a)=(Alpha);
 float4 bentNormal=float4(N,1);
 half shadow=1;
 half ssao=1;
 {
 float3 LitUVZ=((IN.LitUVZ.xyz)/(IN.LitUVZ.w));
 float litZ=min(((1.0)-(((10)*(1e-06)))),LitUVZ.z);
 float2 vInvShadowMapWH=float2(cShadowBias.w,cShadowBias.w);
 {
 half2 inRange=((abs(((LitUVZ.xy)-(0.5))))<(0.5));
 (inRange.x)*=(inRange.y);
 
 pcf_skin(LitUVZ.xy,litZ,vInvShadowMapWH,cShadowFilterScale,shadow);
 (shadow)*=(inRange.x);
 (shadow)=(((1)-(shadow)));
 }
 }
 half3 DiffuseColor;
 half3 SpecularColor;
 {
 (SpecularColor)=(lerp(half3(0.04,0.04,0.04),BaseColor,Metallic.xxx));
 (DiffuseColor)=(((((BaseColor)-(((BaseColor)*(Metallic)))))/(3.14159265)));
 }
 float3 V=normalize((-(IN.ViewDirection.xyz)));
 float3 R=reflect((-(V)),N);
 half NoV=CastHalf(saturate(dot(N,V)));
 half NoL=CastHalf(dot(SunDirection.xyz,N));
 {
 half microshadow=saturate(((((abs(NoL))+(((((2)*(GILighting.a)))*(GILighting.a)))))-(1)));
 (shadow)*=(microshadow);
 }
 half3 diffLighting=half3(0,0,0);
 (diffLighting)=(IN.DiffLighting.xyz);
 {
 
 half SunlightOffset=((lerp(1,((UserData[1].x)*(2)),SSSmask))*(ShadowColor.g));
 (shadow)*=(SunlightOffset);
 
 (shadow)*=(cPointCloud[0].a);
 (GILighting.rgb)=(lerp(GILighting.rgb,((((GILighting.rgb)*(UserData[1].y)))*(2)),SSSmask));
 (diffLighting)+=(((GILighting.rgb)*(GILighting.a)));
 (GILighting.a)*=(saturate(dot(diffLighting.rgb,half3(0.3,0.59,0.11))));
 (diffLighting)+=(GetDiffuseLightingPbr(NoL,shadow,GILighting,Alpha));
 }
 (OUT.rgb)=(SpecularLightingPbr(IN.WorldPosition.xyz,SunDirection.xyz,N,V,Roughness,R,NoV,NoL,SpecularColor,GILighting,shadow));
 {
 float3 virtualNormalize=normalize(cVirtualLitDir.xyz);
 half NoL=CastHalf(saturate(dot(virtualNormalize,N)));
 (NoL)=(((0.444)+(((NoL)*(0.556)))));
 half3 virtualLit=CastHalf(((cVirtualLitColor.rgb)*(((Emission.a)*(NoL)))));
 (virtualLit)=(lerp(virtualLit,((((virtualLit)*(UserData[1].z)))*(2)),SSSmask));
 (diffLighting)+=(virtualLit);
 
 {
 float3 H=normalize(((V)+(virtualNormalize)));
 float NoH=saturate(dot(N,H));
 float m2=((((Roughness)*(Roughness)))+(0.0002));
 (m2)*=(m2);
 float D=((((((((NoH)*(m2)))-(NoH)))*(NoH)))+(1));
 (D)=(((((D)*(D)))+(1e-06)));
 (D)=(((((0.25)*(m2)))/(D)));
 (OUT.rgb)+=(((((virtualLit)*(SpecularColor)))*(D)));
 }
 }
 (OUT.rgb)+=(Emission.rgb);
 (OUT.rgb)+=(LightingPS_SPEC(IN.WorldPosition.xyz,N,V,NoV,SpecularColor,Roughness,diffLighting));
 (OUT.rgb)+=(((diffLighting)*(DiffuseColor)));
 {
 (ssao)=(saturate(((ssao)+(((shadow)*(0.5))))));
 
 (ssao)=(max(0.5,ssao));
 (OUT.rgb)*=(ssao);
 }
 float3 fogColor=((((FogColor2.rgb)*(saturate(((((V.y)*(5)))+(1))))))+(FogColor.rgb));
 float VoL=saturate(dot((-(V)),SunDirection.xyz));
 (fogColor)+=(((FogColor3.rgb)*(((VoL)*(VoL)))));
 (OUT.rgb)=(lerp(OUT.rgb,((((OUT.rgb)*(((1)-(IN.ViewDirection.w)))))+(fogColor.rgb)),IN.ViewDirection.w));
 (OUT.rgb)*=(EnvInfo.z);
 (OUT.rgb)=(clamp(OUT.rgb,float3(0,0,0),float3(4,4,4)));
 {
 (OUT.rgb)=(((OUT.rgb)*(half3(FogColor.w,FogColor2.w,FogColor3.w))));
 (OUT.rgb)/=(((((OUT.rgb)*(0.9661836)))+(0.180676)));
 }
 (OUT.rgb)=(GetFinalGrayColor(OUT.rgb,cGrayPencent));
 (OUT.a)=(1);
 return OUT;
}
float4 PbrPixelShading(in VertexShadingOutput IN):SV_Target
{
 return PbrPixelShadingHigh(IN);
}

