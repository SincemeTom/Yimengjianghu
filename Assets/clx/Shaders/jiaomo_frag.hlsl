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
 float cMetallic:packoffset(c0.w);
 float cAliasingFactor:packoffset(c1.x);
 float cEnvStrength:packoffset(c1.y);
 float cRoughnessLow:packoffset(c1.z);
 float cRoughnessHigh:packoffset(c1.w);
 float4 cLightMapScale:packoffset(c2);
 float4 cLightMapUVTransform:packoffset(c3);
 float cRoughness:packoffset(c4.x);
 float cBloomScale:packoffset(c4.y);
 float cBaseMapBias:packoffset(c4.z);
 float cNormalMapBias:packoffset(c4.w);
 float4 cEmissionScale:packoffset(c5);
 float cGrayPencent:packoffset(c6.x);
};
Texture2D<half4> tBaseMap:register(t0);
sampler sBaseSampler:register(s0);
Texture2D<half4> tAOMap:register(t2);
sampler sAOSampler:register(s2);
Texture2D ScreenTexture:SceneColorOpaque:register(t3);
sampler ScreenTexture_Sampler:register(s3);
Texture2D<half4> tModelEnvMap:register(t5);
sampler sModelEnvSampler:register(s5);
Texture2D tShadowMap:ShadowMap:register(t6);
sampler sShadowMapSampler:register(s6);
struct VertexShadingOutput
{
 float4 HPosition:SV_Position;
 float4 TexCoord:TEXCOORD0;
 float4 WorldPosition:TEXCOORD1;
 float4 WorldNormal:TEXCOORD2;
 float4 ViewDirection:TEXCOORD3;
 float4 LitUVZ:TEXCOORD4;
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
half3 getIBL(in half Roughness,in float3 R)
{
 {
 half3 sampleEnvSpecular=half3(0,0,0);
 half MIP_ROUGHNESS=0.17;
 half level=((Roughness)/(MIP_ROUGHNESS));
 half fSign=((R.z)>(0));
 half fSign2=((((fSign)*(2)))-(1));
 (R.xy)/=(((((R.z)*(fSign2)))+(1)));
 (R.xy)=(((((R.xy)*(half2(0.25,(-(0.25))))))+(((0.25)+(((0.5)*(fSign)))))));
 {
 half4 srcColor;
 (srcColor)=(CastHalf(tModelEnvMap.SampleLevel(sModelEnvSampler,R.xy,level)));
 (sampleEnvSpecular)=(((srcColor.rgb)*(((((srcColor.a)*(srcColor.a)))*(16.0)))));
 }
 (sampleEnvSpecular)*=(((((cEnvStrength)*(EnvInfo.w)))*(10)));
 return sampleEnvSpecular;
 }
 return half3(0,0,0);
}
half3 EnvBRDFApprox(half3 SpecularColor,half Roughness,half NoV)
{
 half4 c0={(-(1)),(-(0.0275)),(-(0.572)),0.022};
 half4 c1={1,0.0425,1.04,(-(0.04))};
 half4 r=((((Roughness)*(c0)))+(c1));
 half a004=((((min(((r.x)*(r.x)),exp2((((-(9.28)))*(NoV)))))*(r.x)))+(r.y));
 half2 AB=((((half2((-(1.04)),1.04))*(a004)))+(r.zw));
 return ((((SpecularColor)*(AB.x)))+(AB.y));
}
float3 getDirectSPEC(float Roughness,float3 L,float3 V,float3 N,float3 SpecularColor)
{
 float NoL=saturate(dot(N,L));
 float NoL4=((((((NoL)*(NoL)))*(NoL)))*(NoL));
 float3 H=normalize(((V)+(L)));
 float NoH=saturate(dot(N,H));
 float m=((Roughness)*(Roughness));
 float m2=((m)*(m));
 float d=((((((((NoH)*(m2)))-(NoH)))*(NoH)))+(1));
 float D=((((m2)/(((d)*(d)))))*(0.25));
 return ((((D)*(SpecularColor)))*(NoL4));
}
float4 PbrPixelShading(in VertexShadingOutput IN):SV_Target
{
 float3 SpecularColor=float3(0.04,0.04,0.04);
 float4 mixVal=tAOMap.Sample(sAOSampler,IN.TexCoord.xy);
 float4 Diffuse=tBaseMap.SampleBias(sBaseSampler,IN.TexCoord.xy,cBaseMapBias);
 (Diffuse.rgb)*=(((Diffuse.rgb)*(Diffuse.a)));
 float refAlpha=mixVal.a;
 float AO=mixVal.r;
 float refmask=mixVal.g;
 float Roughness=cRoughness;
 float3 N=normalize(IN.WorldNormal.xyz);
 float4 GILighting;
 (GILighting.rgb)=(DynamicGILight(N));
 (GILighting.rgb)*=(((UserData[1].y)*(2)));
 (GILighting.a)=(1);
 half shadow=1;
 half ssao=1;
 {
 float3 LitUVZ=((IN.LitUVZ.xyz)/(IN.LitUVZ.w));
 float litZ=min(((1.0)-(((10)*(1e-06)))),LitUVZ.z);
 float2 vInvShadowMapWH=float2(cShadowBias.w,cShadowBias.w);
 {
 half2 inRange=((abs(((LitUVZ.xy)-(0.5))))<(0.5));
 (inRange.x)*=(inRange.y);
 
 pcf_skin(LitUVZ.xy,litZ,vInvShadowMapWH,1,shadow);
 (shadow)*=(inRange.x);
 (shadow)=(((1)-(shadow)));
 }
 }
 float3 L=SunDirection.xyz;
 float3 V=normalize((-(IN.ViewDirection.xyz)));
 float3 R=reflect((-(V)),N);
 half NoV=CastHalf(saturate(dot(N,V)));
 half NoL=CastHalf(saturate(dot(N,L)));
 (GILighting.a)=(min(GILighting.a,ssao));
 float3 SunColor2=SunColor.rgb;
 (SunColor2)*=(((((UserData[1].x)*(2)))*(ShadowColor.g)));
 (SunColor2)*=(cPointCloud[0].a);
 float2 spos=IN.HPosition.xy;
 float2 sceneUVs=((spos)*(ScreenInfoPS.zw));
 float4 sceneColor=ScreenTexture.Sample(ScreenTexture_Sampler,sceneUVs);
 (SpecularColor)=(EnvBRDFApprox(SpecularColor,Roughness,NoV));
 float3 virtualNormalize=normalize(cVirtualLitDir.xyz);
 float3 VirtualNoL=saturate(dot(N,virtualNormalize));
 float3 vitrualLight=((((((VirtualNoL)*(cVirtualLitColor.rgb)))*(UserData[1].z)))*(2));
 float3 Lighting=((((((((NoL)*(SunColor2.rgb)))*(shadow)))+(GILighting.rgb)))+(vitrualLight));
 float3 DirectSpecular1=((((((getDirectSPEC(Roughness,L,V,N,SpecularColor))*(SunColor2.rgb)))*(NoL)))*(shadow));
 float3 virtualSpecular1=((((getDirectSPEC(Roughness,virtualNormalize,V,N,SpecularColor))*(VirtualNoL)))*(cVirtualLitColor.rgb));
 (virtualSpecular1)*=(((UserData[1].z)*(2)));
 float3 env_ref=((((((((getIBL(Roughness,R))*(SpecularColor)))*(AO)))*(mixVal.a)))*(refmask));
 float3 Specular=((((((env_ref)*(dot(GILighting.rgb,float3(0.3,0.59,0.11)))))+(DirectSpecular1)))+(virtualSpecular1));
 float3 sceneColor2=sceneColor;
 (sceneColor.rgb)*=(((1)-(Diffuse.a)));
 (Specular)+=(LightingPS_SPEC(IN.WorldPosition.xyz,N,V,NoV,((SpecularColor)*(2)),saturate(Roughness),Lighting.rgb));
 (sceneColor.rgb)+=(((((Lighting)*(Diffuse.rgb)))/(3.14)));
 (sceneColor.rgb)+=(Specular);
 (sceneColor.rgb)*=(((AO)*(EnvInfo.z)));
 float3 sceneColorNoFog=sceneColor.rgb;
 float3 fogColor=((((FogColor2.rgb)*(saturate(((((V.y)*(5)))+(1))))))+(FogColor.rgb));
 float VoL=saturate(dot((-(V)),SunDirection.xyz));
 (fogColor)+=(((FogColor3.rgb)*(((VoL)*(VoL)))));
 (sceneColor.rgb)=(lerp(sceneColor.rgb,((((sceneColor.rgb)*(((1)-(IN.ViewDirection.w)))))+(fogColor.rgb)),IN.ViewDirection.w));
 (sceneColor.rgb)=(lerp(sceneColorNoFog.rgb,sceneColor.rgb,Diffuse.a));
 (sceneColor.rgb)=(lerp(sceneColor2.rgb,sceneColor.rgb,sqrt(mixVal.a)));
 float4 OUT=float4(sceneColor.rgb,1);
 (OUT.rgb)=(min(OUT.rgb,20.0));
 (OUT.rgb)=(GetFinalGrayColor(OUT.rgb,cGrayPencent));
 return OUT;
}

