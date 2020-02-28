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
 float cSmoothness:packoffset(c4.x);
 float cBloomScale:packoffset(c4.y);
 float cBaseMapBias:packoffset(c4.z);
 float cNormalMapBias:packoffset(c4.w);
 float4 cEmissionScale:packoffset(c5);
 float4 cEmissionScrolling:packoffset(c6);
 float cRoughnessX:packoffset(c7.x);
 float cRoughnessY:packoffset(c7.y);
 float cAnisotropicScale:packoffset(c7.z);
 float cFogDistance:packoffset(c7.w);
 float4 cLocalEnvMapCenter:packoffset(c8);
 float4 cLocalEnvMapScale:packoffset(c9);
 float cRenderDepthOffset:packoffset(c10.x);
 float cGrayPencent:packoffset(c10.y);
 float cLocalEnvMapStartTime:packoffset(c10.z);
 float cLocalEnvMapBlendTime:packoffset(c10.w);
};
Texture2D<half4> tBaseMap:register(t0);
sampler sBaseSampler:register(s0);
Texture2D<half4> tMixMap:register(t1);
sampler sMixSampler:register(s1);
Texture2D<half4> tNormalMap:register(t2);
sampler sNormalSampler:register(s2);
Texture2D<half4> tEnvMap:EnvMap:register(t6);
sampler sEnvSampler:register(s6);
Texture2D tShadowMap:ShadowMap:register(t7);
sampler sShadowMapSampler:register(s7);
struct VertexShadingOutput
{
 float4 HPosition:SV_Position;
 float4 TexCoord:TEXCOORD0;
 float4 WorldPosition:TEXCOORD1;
 float4 WorldNormal:TEXCOORD2;
 float4 ViewDirection:TEXCOORD3;
 float3 WorldTangent:TEXCOORD4;
 float3 WorldBinormal:TEXCOORD5;
 float4 LitUVZ:TEXCOORD6;
};
half anisoSpec(in half3 V,in half3 L,in half3 N,in half NoL,in half3 Tangent,in half3 Binormal,in half RoughnessX,in half RoughnessY)
{
 half len=max(0.001,length(((L)+(V))));
 half3 H=((((L)+(V)))/(len));
 half VoN=max(0.001,dot(V,N));
 half HoN=dot(H,N);
 half HoT=dot(H,Tangent);
 half HoB=dot(H,Binormal);
 float2 beta=float2(((HoT)/(RoughnessX)),((HoB)/(RoughnessY)));
 (beta)*=(beta);
 half s_den=max(0.001,((((((314.15926)*(RoughnessX)))*(RoughnessY)))*(sqrt(((NoL)*(VoN))))));
 half aniso=((exp((((-(((beta.x)+(beta.y)))))/(max(0.01,((0.5)+(((0.5)*(HoN)))))))))/(s_den));
 return aniso;
}
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
half GetRoughness(half Smoothness,float3 n)
{
 half rr=((EnvInfo.x)*(0.5));
 (rr)*=(saturate(((((((3)*(n.y)))+(0.2)))+(((0.1)*(rr))))));
 return lerp(((1)-(rr)),0.05,Smoothness);
}
void PS_GetParameters(in VertexShadingOutput IN,out half3 BaseColor,out half Metallic,out half Roughness,out float3 N,out half4 Emission,out half4 GILighting,out half Alpha)
{
 half4 samplerBase=CastHalf(tBaseMap.SampleBias(sBaseSampler,IN.TexCoord.xy,cBaseMapBias));
 (BaseColor)=(((samplerBase.rgb)*(samplerBase.rgb)));
 (Alpha)=(samplerBase.a);
 half AO=1.0;
 (Metallic)=(cMetallic);
 (Roughness)=(lerp(cRoughnessHigh,cRoughnessLow,cSmoothness));
 {
 half3 samplerMis=CastHalf(tMixMap.Sample(sMixSampler,IN.TexCoord.xy).rgb);
 half Smoothness=samplerMis.r;
 (Metallic)=(samplerMis.g);
 (AO)=(samplerMis.b);
 (Roughness)=(GetRoughness(Smoothness,IN.WorldNormal.xyz));
 }
 {
 half3 tangentNormal=0;
 (tangentNormal)=(CastHalf(tNormalMap.SampleBias(sNormalSampler,IN.TexCoord.xy,cNormalMapBias).xyz));
 (tangentNormal)=(((((2)*(tangentNormal)))-(1)));
 (tangentNormal.xy)*=(((cParamter.w)*(cParamter.w)));
 (N)=(((((((tangentNormal.x)*(IN.WorldTangent)))+(((tangentNormal.y)*(IN.WorldBinormal)))))+(((tangentNormal.z)*(IN.WorldNormal.xyz)))));
 
 {
 float k=length(N);
 (N)/=(k);
 (Roughness)=(saturate(((Roughness)+(min(0.4,((((cAliasingFactor)*(10)))*(saturate(((1)-(k))))))))));
 }
 }
 (Emission)=(half4(0,0,0,cEmissionScale.a));
 {
 half RoughnessX=((((cRoughnessX)*(Roughness)))+(1e-06));
 half RoughnessY=((((cRoughnessY)*(Roughness)))+(1e-06));
 half3 V=normalize((-(IN.ViewDirection.xyz)));
 half NoL=max(0.001,dot(N,SunDirection.xyz));
 half VirtualLitNoL=max(0.001,dot(N,V));
 half3 inputRadiance=((SunColor)*(NoL));
 
 (inputRadiance)*=(cPointCloud[0].a);
 half3 virtualRadiance=((((((VirtualLitNoL)*(cVirtualLitColor.rgb)))*(UserData[1].z)))*(2));
 
 half directAniso=((cAnisotropicScale)*(anisoSpec(V,SunDirection.xyz,N,NoL,IN.WorldTangent.xyz,IN.WorldBinormal.xyz,RoughnessX,RoughnessY)));
 half virtualAniso=((cAnisotropicScale)*(anisoSpec(V,V,N,VirtualLitNoL,IN.WorldTangent.xyz,IN.WorldBinormal.xyz,RoughnessX,RoughnessY)));
 (Emission.rgb)=(((inputRadiance)*(directAniso)));
 (BaseColor.rgb)+=(((virtualRadiance)*(virtualAniso)));
 (BaseColor.rgb)=(min(BaseColor.rgb,10));
 
 (Emission.rgb)*=(((AO)*(Alpha)));
 (Emission.rgb)=(min(Emission.rgb,10));
 }
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
 PS_GetParameters(IN,BaseColor,Metallic,Roughness,N,Emission,GILighting,Alpha);
 (OUT.a)=(Alpha);
 float4 bentNormal=float4(N,1);
 half shadow=1;
 half ssao=1;
 {
 
 
 {
 half shadow2=1;
 float3 LitUVZ=((IN.LitUVZ.xyz)/(IN.LitUVZ.w));
 float litZ=min(((1.0)-(((10)*(1e-06)))),LitUVZ.z);
 float2 vInvShadowMapWH=float2(cShadowBias.w,cShadowBias.w);
 {
 half2 inRange=((abs(((LitUVZ.xy)-(0.5))))<(0.5));
 (inRange.x)*=(inRange.y);
 
 pcf_skin(LitUVZ.xy,litZ,vInvShadowMapWH,1,shadow2);
 (shadow2)*=(inRange.x);
 (shadow2)=(((1)-(shadow2)));
 }
 (shadow)=(min(shadow,shadow2));
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
 {
 
 half SunlightOffset=((lerp(1,((UserData[1].x)*(2)),SSSmask))*(ShadowColor.g));
 (shadow)*=(SunlightOffset);
 
 (shadow)*=(cPointCloud[0].a);
 (GILighting.rgb)=(lerp(GILighting.rgb,((((GILighting.rgb)*(UserData[1].y)))*(2)),SSSmask));
 (diffLighting)+=(((GILighting.rgb)*(GILighting.a)));
 (GILighting.a)*=(saturate(dot(diffLighting.rgb,half3(0.3,0.59,0.11))));
 (diffLighting)+=(GetDiffuseLightingPbr(NoL,shadow,GILighting,Alpha));
 }
 (GILighting.a)=(min(GILighting.a,ssao));
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
 (OUT.rgb)=(((OUT.rgb)+(((shadow)*(Emission.rgb)))));
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
 (OUT.rgb)=(min(OUT.rgb,20.0));
 (OUT.rgb)=(GetFinalGrayColor(OUT.rgb,cGrayPencent));
 (OUT.rgb)=(((OUT.rgb)*(OUT.a)));
 return OUT;
}
float4 PbrPixelShading(in VertexShadingOutput IN):SV_Target
{
 return PbrPixelShadingHigh(IN);
}

