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
 float maokong_intensity:packoffset(c0.w);
 float cAliasingFactor:packoffset(c1.x);
 float cEnvStrength:packoffset(c1.y);
 float __padding1__:packoffset(c1.z);
 float RoughnessOffset2:packoffset(c1.w);
 float4 cLightMapScale:packoffset(c2);
 float4 cLightMapUVTransform:packoffset(c3);
 float cDetailUVScale:packoffset(c4.x);
 float cSSSIntensity:packoffset(c4.y);
 float cBaseMapBias:packoffset(c4.z);
 float cNormalMapBias:packoffset(c4.w);
 float4 cEmissionScale:packoffset(c5);
 float4 cSSSColor:packoffset(c6);
 float cGrayPencent:packoffset(c7.x);
 float3 cCrystalColor01:packoffset(c7.y);
 float cCrystalIntensity01:packoffset(c8.x);
 float3 cCrystalColor02:packoffset(c8.y);
 float cCrystalIntensity02:packoffset(c9.x);
 float3 cCrystalColor03:packoffset(c9.y);
 float cCrystalIntensity03:packoffset(c10.x);
 float cCrystalUVTile01:packoffset(c10.y);
 float cCrystalUVTile02:packoffset(c10.z);
 float cCrystalUVTile03:packoffset(c10.w);
 float cCrystalRange:packoffset(c11.x);
 float cCrystalVirtualLit:packoffset(c11.y);
};
Texture2D<half4> tBaseMap:register(t0);
sampler sBaseSampler:register(s0);
Texture2D<half4> tMixMap:register(t1);
sampler sMixSampler:register(s1);
Texture2D<half4> tNormalMap:register(t2);
sampler sNormalSampler:register(s2);
Texture2D<half4> tDetailNormalMap:register(t3);
sampler sDetailNormalSampler:register(s3);
Texture2D<half4> tLutMap:register(t4);
sampler sLutMapSampler:register(s4);
Texture2D<half4> tEnvMap:EnvMap:register(t6);
sampler sEnvSampler:register(s6);
Texture2D tShadowMap:ShadowMap:register(t7);
sampler sShadowMapSampler:register(s7);
Texture2D tCrystalMap03:register(t13);
sampler sCrystalMap03Sampler:register(s13);
Texture2D tCrystalMaskMap:register(t14);
sampler sCrystalMaskMapSampler:register(s14);
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
float4 CalculateOcclusion(float4 ShadowmapDepth,float4 SceneDepth)
{
 float TransitionScale=8000;
 return saturate(((((((ShadowmapDepth)-(SceneDepth)))*(TransitionScale)))+(1)));
}
void pcf_3x3(float2 pInLitTC,float litZ,float2 vInvShadowMapWH,out float inShadow)
{
 float2 TexelPos=((((pInLitTC)/(vInvShadowMapWH)))-(0.5));
 float2 Fraction=frac(TexelPos);
 float2 TexelCenter=((floor(TexelPos))+(0.5));
 float2 Sample00TexelCenter=((TexelCenter)-(float2(1,1)));
 float4 Values0;
 float4 Values1;
 float4 Values2;
 float4 Values3;
 (Values0.x)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(0,0))))*(vInvShadowMapWH)))));
 (Values0.y)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(1,0))))*(vInvShadowMapWH)))));
 (Values0.z)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(2,0))))*(vInvShadowMapWH)))));
 (Values0.w)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(3,0))))*(vInvShadowMapWH)))));
 (Values0)=(CalculateOcclusion(Values0,litZ.rrrr));
 (Values1.x)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(0,1))))*(vInvShadowMapWH)))));
 (Values1.y)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(1,1))))*(vInvShadowMapWH)))));
 (Values1.z)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(2,1))))*(vInvShadowMapWH)))));
 (Values1.w)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(3,1))))*(vInvShadowMapWH)))));
 (Values1)=(CalculateOcclusion(Values1,litZ.rrrr));
 (Values2.x)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(0,2))))*(vInvShadowMapWH)))));
 (Values2.y)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(1,2))))*(vInvShadowMapWH)))));
 (Values2.z)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(2,2))))*(vInvShadowMapWH)))));
 (Values2.w)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(3,2))))*(vInvShadowMapWH)))));
 (Values2)=(CalculateOcclusion(Values2,litZ.rrrr));
 (Values3.x)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(0,3))))*(vInvShadowMapWH)))));
 (Values3.y)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(1,3))))*(vInvShadowMapWH)))));
 (Values3.z)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(2,3))))*(vInvShadowMapWH)))));
 (Values3.w)=(DecodeDepth(tShadowMap.Sample(sShadowMapSampler,((((Sample00TexelCenter)+(float2(3,3))))*(vInvShadowMapWH)))));
 (Values3)=(CalculateOcclusion(Values3,litZ.rrrr));
 float2 VerticalLerp00=lerp(float2(Values0.x,Values1.x),float2(Values0.y,Values1.y),Fraction.xx);
 float PCFResult00=lerp(VerticalLerp00.x,VerticalLerp00.y,Fraction.y);
 float2 VerticalLerp10=lerp(float2(Values0.y,Values1.y),float2(Values0.z,Values1.z),Fraction.xx);
 float PCFResult10=lerp(VerticalLerp10.x,VerticalLerp10.y,Fraction.y);
 float2 VerticalLerp20=lerp(float2(Values0.z,Values1.z),float2(Values0.w,Values1.w),Fraction.xx);
 float PCFResult20=lerp(VerticalLerp20.x,VerticalLerp20.y,Fraction.y);
 float2 VerticalLerp01=lerp(float2(Values1.x,Values2.x),float2(Values1.y,Values2.y),Fraction.xx);
 float PCFResult01=lerp(VerticalLerp01.x,VerticalLerp01.y,Fraction.y);
 float2 VerticalLerp11=lerp(float2(Values1.y,Values2.y),float2(Values1.z,Values2.z),Fraction.xx);
 float PCFResult11=lerp(VerticalLerp11.x,VerticalLerp11.y,Fraction.y);
 float2 VerticalLerp21=lerp(float2(Values1.z,Values2.z),float2(Values1.w,Values2.w),Fraction.xx);
 float PCFResult21=lerp(VerticalLerp21.x,VerticalLerp21.y,Fraction.y);
 float2 VerticalLerp02=lerp(float2(Values2.x,Values3.x),float2(Values2.y,Values3.y),Fraction.xx);
 float PCFResult02=lerp(VerticalLerp02.x,VerticalLerp02.y,Fraction.y);
 float2 VerticalLerp12=lerp(float2(Values2.y,Values3.y),float2(Values2.z,Values3.z),Fraction.xx);
 float PCFResult12=lerp(VerticalLerp12.x,VerticalLerp12.y,Fraction.y);
 float2 VerticalLerp22=lerp(float2(Values2.z,Values3.z),float2(Values2.w,Values3.w),Fraction.xx);
 float PCFResult22=lerp(VerticalLerp22.x,VerticalLerp22.y,Fraction.y);
 (inShadow)=(((((((((((((((((((PCFResult00)+(PCFResult10)))+(PCFResult20)))+(PCFResult01)))+(PCFResult11)))+(PCFResult21)))+(PCFResult02)))+(PCFResult12)))+(PCFResult22)))*(0.11111)));
 (inShadow)=(((1.0)-(inShadow)));
}
void pcf_skin(float2 pInLitTC,float litZ,float2 vInvShadowMapWH,float filterScale,out float inShadow)
{
 pcf_3x3(pInLitTC,litZ,vInvShadowMapWH,inShadow);
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
half3 GetIBLIrradiance(in half Roughness,in float3 R)
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
 (srcColor)=(CastHalf(tEnvMap.SampleLevel(sEnvSampler,R.xy,level)));
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
float SpecBRDFPbr(in float Roughness1,in float Roughness2,in float3 L,in float3 V,in float3 N,in float3 SpecularColor,out float3 BRDF)
{
 float3 H=normalize(((L)+(V)));
 float NoH=saturate(dot(N,H));
 float NoL=saturate(dot(N,L));
 float NoV=saturate(dot(N,V));
 float VoH=saturate(dot(V,H));
 float m=((Roughness1)*(Roughness1));
 float m2=((m)*(m));
 float d=((((((((NoH)*(m2)))-(NoH)))*(NoH)))+(1));
 float D1=((m2)/(((((d)*(d)))*(3.14159265))));
 (m)=(((Roughness2)*(Roughness2)));
 (m2)=(((m)*(m)));
 (d)=(((((((((NoH)*(m2)))-(NoH)))*(NoH)))+(1)));
 float D2=((m2)/(((((d)*(d)))*(3.14159265))));
 float k=((m)*(0.5));
 float G_SchlickV=((((NoV)*(((1)-(k)))))+(k));
 float G_SchlickL=((((NoL)*(((1)-(k)))))+(k));
 float G=((0.25)/(((G_SchlickV)*(G_SchlickL))));
 float3 F=((SpecularColor)+(((((saturate(((50.0)*(SpecularColor.g))))-(SpecularColor)))*(exp2((((((((-(5.55473)))*(VoH)))-(6.98316)))*(VoH)))))));
 (BRDF)=(((((((((D1)*(1.5)))+(((D2)*(0.5)))))*(F)))*(G)));
 return 1;
}
float CrystalBRDF(in float Roughness,in float3 L,in float3 V,in float3 N,in float3 SpecularColor,out float3 CrystalSpecBRDF)
{
 float3 H=normalize(((L)+(V)));
 float NoH=saturate(dot(N,H));
 float NoL=saturate(dot(N,L));
 float NoV=saturate(dot(N,V));
 float VoH=saturate(dot(V,H));
 float m=((Roughness)*(Roughness));
 float m2=((m)*(m));
 float d=((((((((NoH)*(m2)))-(NoH)))*(NoH)))+(1));
 float D1=((m2)/(((((d)*(d)))*(3.14159265))));
 (m)=(((((Roughness)*(Roughness)))*(0.5)));
 (m2)=(((m)*(m)));
 (d)=(((((((((NoH)*(m2)))-(NoH)))*(NoH)))+(1)));
 float D2=((m2)/(((((d)*(d)))*(3.14159265))));
 float k=((m)*(0.5));
 float G_SchlickV=((((NoV)*(((1)-(k)))))+(k));
 float G_SchlickL=((((NoL)*(((1)-(k)))))+(k));
 float G=((0.25)/(((G_SchlickV)*(G_SchlickL))));
 float3 F=((SpecularColor)+(((((saturate(((50.0)*(SpecularColor.g))))-(SpecularColor)))*(exp2((((((((-(5.55473)))*(VoH)))-(6.98316)))*(VoH)))))));
 (CrystalSpecBRDF)=(((((((D1)+(D2)))*(F)))*(G)));
 return 1;
}
half GetRoughness(in half Roughness,in float3 N)
{
 {
 half rain=((EnvInfo.x)*(0.5));
 (rain)=(((1)-(((rain)*(saturate(((((((3)*(N.y)))+(0.2)))+(((0.1)*(rain))))))))));
 return clamp(((rain)*(Roughness)),0.05,1);
 }
 return Roughness;
}
half3 DynamicGILightUseBentNormal(in VertexShadingOutput IN,in float3 N,in float3 bentNormal)
{
 return DynamicGILight(N);
}
float4 SSSNewShading(in VertexShadingOutput IN,float3 userData)
{
 float3 SpecularColor=float3(0.04,0.04,0.04);
 float4 BaseColor=tBaseMap.SampleBias(sBaseSampler,IN.TexCoord.xy,cBaseMapBias);
 (BaseColor.rgb)*=(BaseColor.rgb);
 float Roughness=GetRoughness(max(((1)-(BaseColor.a)),0.03),IN.WorldNormal.xyz);
 float4 MixTex=tMixMap.Sample(sMixSampler,IN.TexCoord.xy);
 float AO=MixTex.b;
 float Curvature=MixTex.g;
 float Thickness=MixTex.r;
 float3 N=normalize(IN.WorldNormal.xyz);
 float3 DetailNormal=N;
 float3 SpecularMask=float3(0,0,0);
 half vertexColorW=((1)-(MixTex.a));
 {
 half4 tangentNormal=CastHalf(tNormalMap.SampleBias(sNormalSampler,IN.TexCoord.xy,cNormalMapBias));
 (tangentNormal.xyz)=(((((tangentNormal.xyz)*(2)))-(1)));
 (N)=(normalize(((((((normalize(IN.WorldTangent.xyz))*(tangentNormal.x)))+(((normalize(IN.WorldBinormal.xyz))*(tangentNormal.y)))))+(((normalize(IN.WorldNormal.xyz))*(tangentNormal.z))))));
 
 {
 float4 DetailValue=tDetailNormalMap.Sample(sDetailNormalSampler,((IN.TexCoord.xy)*(cDetailUVScale)));
 float3 temp=float3(((((DetailValue.b)*(2)))-(1)),((((DetailValue.a)*(2)))-(1)),0);
 (temp)=(normalize(((tangentNormal.xyz)+(((((((temp)*(0.2)))*(maokong_intensity)))*(tangentNormal.w))))));
 (DetailNormal)=(normalize(((((((IN.WorldTangent.xyz)*(temp.x)))+(((IN.WorldBinormal.xyz)*(temp.y)))))+(((IN.WorldNormal.xyz)*(temp.z))))));
 (SpecularMask)=(lerp(half3(0.5,0.5,0.5),DetailValue.rrr,tangentNormal.w));
 }
 }
 float3 BentNormal=N;
 float3 bentN=normalize(lerp(DetailNormal,BentNormal,Thickness));
 float3 L=SunDirection.xyz;
 float3 V=normalize((-(IN.ViewDirection.xyz)));
 float3 R=reflect((-(V)),N);
 float3 H=normalize(((V)+(L)));
 half NoV=saturate(dot(N,V));
 half NoL=saturate(dot(N,L));
 half shadow=1;
 {
 half shadow2=1;
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
 float3 SunIrradiance=((((((SunColor.rgb)*(userData.x)))*(2)))*(ShadowColor.g));
 (SunIrradiance)*=(cPointCloud[0].a);
 half3 ScatterAO=half3(lerp(AO,1.5,Thickness),AO,AO);
 float3 PointCloudIrradiance=((((((DynamicGILightUseBentNormal(IN,N,bentN))*(ScatterAO)))*(userData.y)))*(2));
 float PointCloudIlluminace=dot(PointCloudIrradiance,float3(0.3,0.59,0.11));
 float3 VirtualLitDir=normalize(cVirtualLitDir.xyz);
 float3 VirtualLitNoL=((0.444)+(((0.556)*(saturate(dot(bentN,VirtualLitDir))))));
 float3 VirtualLitIrradiance=((((((((cVirtualLitColor.rgb)*(userData.z)))*(2)))*(AO)))*(VirtualLitNoL));
 float3 RefractionNoL=saturate(((0.6)+(dot(BentNormal,L))));
 float3 RefractionIrradiance=((((((((((((SunIrradiance)+(PointCloudIrradiance)))*(Thickness)))*(cSSSColor.rgb)))*(RefractionNoL)))*(RefractionNoL)))*(shadow));
 float LutU=((((0.5)*(dot(N,L))))+(0.5))
 float2 LutUV1=float2(LutU,((cSSSIntensity)*(Curvature)));
 float3 SSS_Lut1=tLutMap.Sample(sLutMapSampler,LutUV1);
 (SSS_Lut1.rgb)*=(SSS_Lut1.rgb);
 float DoL=saturate(dot(DetailNormal,L));
 (DoL)=(((DoL)-(NoL)));
 float LutUV2=((shadow)+(((DoL)*(shadow))));
 float3 SSS_Lut2=float3(lerp(sqrt(LutUV2.r),LutUV2.r,((1)-(cSSSIntensity))),LutUV2.rr);
 (SSS_Lut2.rgb)*=(SSS_Lut2.rgb);
 float3 SSS_SunIrradiance=((((lerp(((SSS_Lut2.rgb)*(SSS_Lut1.rgb)),((NoL)*(shadow)),vertexColorW))*(SunIrradiance)))*(AO));
 float3 DiffuseIrradiance=((((((PointCloudIrradiance)+(RefractionIrradiance)))+(VirtualLitIrradiance)))+(SSS_SunIrradiance));
 float RoughnessLayer1=Roughness;
 float RoughnessLayer2=((Roughness)*(RoughnessOffset2));
 float3 SpecRadiance=float3(0,0,0);
 float3 EnvBRDF=float3(0,0,0);
 float brdfParam=((((((((SunIrradiance)*(NoL)))*(2)))*(SpecularMask)))*(shadow));
 {
 float3 BRDF;
 SpecBRDFPbr(RoughnessLayer1,RoughnessLayer2,L,V,DetailNormal,SpecularColor,BRDF);
 float3 SunSpecRadiance=((BRDF)*(brdfParam));
 SpecBRDFPbr(RoughnessLayer1,RoughnessLayer2,VirtualLitDir,V,DetailNormal,SpecularColor,BRDF);
 float3 VirtualSpecRadiance=((((VirtualLitIrradiance)*(BRDF)))*(SpecularMask));
 (EnvBRDF)=(EnvBRDFApprox(SpecularColor,Roughness,NoV));
 float3 PointCloudSpecRadiance=((((((((EnvBRDF)*(PointCloudIrradiance)))*(SpecularMask)))*(EnvInfo.w)))*(cEnvStrength));
 float3 IBLSpecRadiance=((((((GetIBLIrradiance(Roughness,R))*(EnvBRDF)))*(AO)))*(AO));
 (SpecRadiance)=(((SunSpecRadiance)+(VirtualSpecRadiance)));
 (SpecRadiance)+=(((PointCloudSpecRadiance)+(((IBLSpecRadiance)*(PointCloudIlluminace)))));
 }
 {
 half3 crystalMaskMap=tCrystalMaskMap.Sample(sCrystalMaskMapSampler,IN.TexCoord.xy);
 half3 crystalMap01=0;
 half3 crystalMap02=0;
 half3 crystalMap03=0;
 
 
 
 (crystalMap03)=(tCrystalMap03.Sample(sCrystalMap03Sampler,((((5)*(cCrystalUVTile03)))*(IN.TexCoord.xy))));
 half3 crystalMask=((((((((((crystalMaskMap.r)*(cCrystalIntensity01)))*(cCrystalColor01)))*(crystalMap01)))+(((((((crystalMaskMap.g)*(cCrystalIntensity02)))*(cCrystalColor02)))*(crystalMap02)))))+(((((((crystalMaskMap.b)*(cCrystalIntensity03)))*(cCrystalColor03)))*(crystalMap03))));
 half3 CrystalSpecBRDF;
 CrystalBRDF(cCrystalRange,L,V,DetailNormal,((10)*(crystalMask)),CrystalSpecBRDF);
 half3 CrystalSunSpec=((((brdfParam)*(CrystalSpecBRDF)))*(AO));
 (SpecRadiance)+=(CrystalSunSpec);
 CrystalBRDF(cCrystalRange,VirtualLitDir,V,DetailNormal,((cCrystalVirtualLit)*(crystalMask)),CrystalSpecBRDF);
 half3 CrystalVirtualSpec=((VirtualLitIrradiance)*(CrystalSpecBRDF));
 (SpecRadiance)+=(CrystalVirtualSpec);
 }
 float4 OUT=float4(((SpecRadiance)+(((((DiffuseIrradiance)*(BaseColor.rgb)))/(3.14159265)))),1);
 float3 fogColor=((((FogColor2.rgb)*(saturate(((((V.y)*(5)))+(1))))))+(FogColor.rgb));
 float VoL=saturate(dot((-(V)),SunDirection.xyz));
 (fogColor)+=(((FogColor3.rgb)*(((VoL)*(VoL)))));
 (OUT.rgb)=(lerp(OUT.rgb,((((OUT.rgb)*(((1)-(IN.ViewDirection.w)))))+(fogColor.rgb)),IN.ViewDirection.w));
 (OUT.rgb)=(((EnvInfo.z)*(OUT.rgb)));
 (OUT.rgb)=(clamp(OUT.rgb,float3(0,0,0),float3(4,4,4)));
 (OUT.rgb)=(min(OUT.rgb,20.0));
 (OUT.rgb)=(GetFinalGrayColor(OUT.rgb,cGrayPencent));
 (OUT.a)=(1);
 return OUT;
}
float4 PbrPixelShading(in VertexShadingOutput IN):SV_Target
{
 return SSSNewShading(IN,UserData[1].xyz);
}

