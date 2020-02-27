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
 float cGrayPencent:packoffset(c12.x);
 float cAlpha:packoffset(c12.y);
 float cLocalEnvMapStartTime:packoffset(c12.z);
 float cLocalEnvMapBlendTime:packoffset(c12.w);
};
Texture2D<half4> tBaseMap:register(t0);
sampler sBaseSampler:register(s0);
struct VertexShadingOutput
{
 float4 HPosition:SV_Position;
 float4 TexCoord:TEXCOORD0;
 float4 WorldPosition:TEXCOORD1;
 float4 WorldNormal:TEXCOORD2;
 float4 ViewDirection:TEXCOORD3;
 float3 WorldTangent:TEXCOORD4;
 float3 WorldBinormal:TEXCOORD5;
};
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
void PS_GetParameters(in VertexShadingOutput IN,out half3 BaseColor,out half Metallic,out half Roughness,out float3 N,out half4 Emission,out half4 GILighting,out half Alpha)
{
 half4 samplerBase;
 (samplerBase)=(CastHalf(tBaseMap.SampleBias(sBaseSampler,IN.TexCoord.xy,cBaseMapBias)));
 (BaseColor)=(((samplerBase.rgb)*(samplerBase.rgb)));
 (Alpha)=(((samplerBase.a)*(cAlpha)));
 half mask;
 (mask)=(Alpha);
 float4 base_color_data=float4(BaseColor,1);
 (BaseColor)=(lerp(BaseColor,saturate(half3(dot(cColorTransform0,base_color_data),dot(cColorTransform1,base_color_data),dot(cColorTransform2,base_color_data))),mask));
 float3 NextColor=((((step(cColorTransform0.w,0.99))*(BaseColor)))+(((step(0.99,cColorTransform0.w))*(cBaseColor))));
 (BaseColor)=(lerp(BaseColor,NextColor,mask));
 half AO=1.0;
 (Roughness)=(1.0);
 (Metallic)=(0);
 (Emission)=(half4(0,0,0,0));
 (N)=(normalize(IN.WorldNormal.xyz));
 (GILighting.rgb)=(DynamicGILight(N));
 (GILighting.a)=(AO);
}
half3 GetDiffuseLightingPbr(in half NoL,in half shadow,in half4 GILighting,in half Alpha)
{
 return ((((saturate(NoL))*(shadow)))*(SunColor.rgb));
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
 (OUT.rgb)+=(Emission.rgb);
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

