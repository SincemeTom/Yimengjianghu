struct appdata {
    float4 vertex : POSITION;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
    float4 texcoord1 : TEXCOORD1;
    float4 texcoord2 : TEXCOORD2;
    float4 texcoord3 : TEXCOORD3;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 worldPos   : TEXCOORD1;
    half3 world_normal  : TEXCOORD2;
    half3 world_tangent : TEXCOORD3;
    half3 world_binormal : TEXCOORD4;

    LIGHTING_COORDS(6,7)
    #if defined(LIGHTMAP_ON)|| defined(UNITY_SHOULD_SAMPLE_SH)
        float4 ambientOrLightmapUV : TEXCOORD8;
    #endif

};

sampler2D _MainTex;
float4 _MainTex_ST;

v2f vert (appdata v)
{
    v2f o = (v2f)0;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
    o.worldPos = mul( unity_ObjectToWorld, v.vertex );
    float3 normal  = v.normal;
    half3 wNormal = UnityObjectToWorldNormal(normal);  
    half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
    half tangentSign = v.tangent.w * unity_WorldTransformParams.w;  
    half3 wBinormal = cross(wNormal, wTangent) * tangentSign;  
                    
    o.world_normal = wNormal;
    o.world_tangent = wTangent; 
    o.world_binormal = wBinormal;
    
    TRANSFER_VERTEX_TO_FRAGMENT(o);
    UNITY_TRANSFER_FOG(o,o.pos);
    return o;
}


sampler2D _EnvMap;
half EnvStrength;
float4 EnvInfo;
float4 ShadowColor;
float4 FogInfo;

float4 FogColor; // (0.2590002, 0.3290003, 0.623, 1.102886) 
float4 FogColor2; //(0,0,0,0.7713518)
float4 FogColor3; //(0.5, 0.35, 0.09500044, 0.6937419 )
fixed3 lessThan(float3 a, float3 b)
{
    fixed3 r = fixed3(1,1,1);
    r.x = a.x < b.x ? 0 : 1;
    r.y = a.y < b.y ? 0 : 1;
    r.z = a.z < b.z ? 0 : 1;
    return r;
}

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
half4 MJH_UnpackNormal(in float4 normal)
{
    normal.g = 1 - normal.g;//G 通道反向
    return half4(normal.xy * 2.0 - 1.0, normal.zw);
}
half3 EnvBRDFApprox( half3 SpecularColor, half Roughness, half NoV )
{
    const half4 c0 = { -1, -0.0275, -0.572, 0.022 };
    const half4 c1 = { 1, 0.0425, 1.04, -0.04 };
    half4 r = Roughness * c0 + c1;
    half a004 = min( r.x * r.x, exp2( -9.28 * NoV ) ) * r.x + r.y;
    half2 AB = half2( -1.04, 1.04 ) * a004 + r.zw;
    return SpecularColor * AB.x + AB.y;
}

float SpecBRDFPbr(in float Roughness1,in float Roughness2,in float3 L,in float3 V,in float3 N,in float3 SpecularColor)
{
    float3 H = normalize(L+V);
    float NoH = saturate(dot(N,H));
    float NoL = saturate(dot(N,L));
    float NoV = saturate(dot(N,V));
    float VoH = saturate(dot(V,H));
    float m = Roughness1 * Roughness1;
    float m2 = m * m;
    float d = (NoH * m2 - NoH ) * NoH + 1;
    float D1 = m2 / ( d * d * 3.14159265);

    m = Roughness2 * Roughness2;
    m2 = m * m;
    d = (NoH * m2 - NoH ) * NoH + 1;

    float D2 = m2 / ( d * d * 3.14159265);
    
    float k= m * 0.5;

    float G_SchlickV= NoV * ( 1 - k) + k;
    float G_SchlickL= NoL * ( 1 - k) + k;
    float G = 0.25 / ( G_SchlickV * G_SchlickL);
    float3 F = SpecularColor + (saturate(50 * SpecularColor.g) - SpecularColor) * exp2((-5.55473 * VoH - 6.98316) * VoH);

    float3 BRDF = (D1 * 1.5 + D2 * 0.5) * F * G;			
    return BRDF;
}

half3 DynamicGILight(in float3 worldNormal)
{
    float4 cPointCloudm[6] = 
    {
        float4 (0.4153285,	0.3727325,	0.3066995,	1),
        float4 (0.6216756,	0.6451226,	0.6716674,	1),
        float4 (0.5540166,	0.7015119,	0.8980855,	1),
        float4 (0.3778813,	0.2398499,	0.05358088,	1),
        float4 (0.3423186,	0.4456023,	0.4700097,	1),
        float4 (0.6410592,	0.5083932,	0.4235953,	1)
    };
    half3 nSquared= worldNormal * worldNormal;
    //int3 isNegative=((worldNormal)<(0.0));
    fixed3 isNegative = fixed3(lessThan(worldNormal, fixed3(0.0,0.0,0.0))) ;
    half4 linearColor = nSquared.x * cPointCloudm[isNegative.x] + nSquared.y * cPointCloudm[isNegative.y + 2] + nSquared.z * cPointCloudm[isNegative.z + 4];

    linearColor.rgb = ((half3)max(half3(0.9,0.9,0.9),linearColor.rgb));

    linearColor.rgb *= (ShadowColor.x * (10.0 + cPointCloudm[3].w * ShadowColor.z * 100)).xxx;
    return linearColor.xyz;
}
half3 DynamicGILightUseBentNormal(in v2f IN,in float3 N,in float3 bentNormal)
{
    return DynamicGILight(N);
}
half3 GetIBLIrradiance(in half Roughness,in float3 R)
{			
    half3 sampleEnvSpecular=half3(0,0,0);
    half MIP_ROUGHNESS=0.17;
    half level=Roughness / MIP_ROUGHNESS;
    half fSign= R.z > 0;
    half fSign2 = fSign * 2 - 1;
    R.xy /= (R.z * fSign2 + 1);
    R.xy = R.xy * half2(0.25,-0.25) + 0.25 + 0.5 * fSign;				
    half4 srcColor;								
    srcColor = CastHalf(tex2Dlod (_EnvMap, half4(R.xy, 0, level)));
    sampleEnvSpecular= srcColor.rgb * (srcColor.a * srcColor.a * 16.0);				
    sampleEnvSpecular *= EnvStrength * EnvInfo.w * 10;
    return sampleEnvSpecular;

}
half3 IBL_Specular(in half Roughness,in float3 R, in half3 SpecularColor, in half4 GILighting)
{
    half3 IBLSpecular = GetIBLIrradiance(Roughness, R);

    IBLSpecular*= GILighting.w;
    return SpecularColor * IBLSpecular;
}
half3 Sun_Specular(in float3 L,in float3 N, in float3 V, in half Roughness,in float3 R,in half NoV,in half NoL,in half3 SpecularColor)
{
    fixed3 H = normalize(V + L);
    fixed VdotH = clamp(dot(V,H),0,1);
    fixed NdotH = clamp(dot(N,H),0,1);
    half rough = max(0.08,Roughness);
    float a = rough * rough;
    float a2 = a * a;
    float d = (NdotH * a2 - NdotH) * NdotH + 1.0;
    float D_GGX = rough / (d * d * 3.141593);

    float k = a * 0.5;
    
 
    float G_SchlickV= NoV * (1-k) + k;
    float G_SchlickL= saturate(NoL)*(1-k)+k;

    float G = 0.25 / (G_SchlickV * G_SchlickL);
    
    float3 F = SpecularColor + (saturate(SpecularColor.g * 50) - SpecularColor) * exp2((-5.55473 * VdotH - 6.98316) * VdotH);

    half3 sunSpec = D_GGX * G * F;
    return sunSpec;
}

float CrystalBRDF(in float Roughness,in float3 L,in float3 V,in float3 N,in float3 SpecularColor )
{
    float3 H = normalize(L+V);
    float NoH = saturate(dot(N,H));
    float NoL = saturate(dot(N,L));
    float NoV = saturate(dot(N,V));
    float VoH = saturate(dot(V,H));
    float m = Roughness * Roughness;
    float m2= m * m;
    float d = (NoH * m2 - NoH ) * NoH + 1;
    float D1 = m2 / ( d * d * 3.14159265);
    m = Roughness * Roughness * 0.5;
    m2= m * m;
    d = (NoH * m2 - NoH ) * NoH + 1;
    float D2 = m2 / ( d * d * 3.14159265);
    float k = m * 0.5;
    float G_SchlickV = NoV * ( 1 - k) + k;
    float G_SchlickL = NoL * ( 1 - k) + k;
    float G = 0.25 / ( G_SchlickV * G_SchlickL);
    float3 F = SpecularColor + (saturate(50 * SpecularColor.g) - SpecularColor) * exp2((-5.55473 * VoH - 6.98316) * VoH);
    float3 CrystalSpecBRDF = (D1 + D2) * F * G;	
    return CrystalSpecBRDF;
}
half GetRoughnessFromRoughness(in half Roughness,in float3 N)
{
    
    half rain= EnvInfo.x * 0.5;
    rain = 1 - rain * saturate(3 * N.y + 0.2 + 0.1 * rain);
    return clamp( rain * Roughness ,0.05,1);
    return Roughness;
}
half GetRoughnessFromSmoothness(in half Smoothness,in float3 N)
{
    
    half rain= EnvInfo.x * 0.5;
    rain = 1 - rain * saturate(3 * N.y + 0.2 + 0.1 * rain);
    return clamp( rain - rain * Smoothness ,0.05,1);
}


//Light0,1,2

float4 Lights00 = float4(0,	0.6600003,	1	,0.5);
float4 Lights01 = float4(13.51172,	11.5179	,9.20715,	0);
float4 Lights02 = float4(-0.11366,	0.7181236,	0.6865711,	1);
float4 Lights03 = float4(0.9999999,	0.9999999,	0.9999999,	0);

float4 Lights10 = float4(0.05,	0.2142958,	0.4285888,	0.6811707);
float4 Lights11 = float4(0.04736615,	0.6120656,	0.006309574,	0.5);
float4 Lights12 = float4(1,	1,	1,	0);
float4 Lights13 = float4(1180.298,	47.48998,	1032.886,	0);

float4 Lights20 = float4(1805,	1015,	0.0005540166,	0.0009852217);
float4 Lights21 = float4(0.5773502,	0.5773502,	0.5773502,	0.6515582);
float4 Lights22 = float4(0,	0,	0,	0.6515584);
float4 Lights23 = float4(-0.9832486,	0,	-0.4468413,	0);

half3 LightingPS_SPEC(in float3 P,in float3 N,in float3 V,in half NoV,in half3 SpecularColor,in half Roughness,inout half3 DiffLit)
{
 half3 lighting=half3(0,0,0);
 if (((Lights03.w)>(0)))
 {
 float3 L=((Lights00.xyz)-(P));
 float dist=length(L);
 (L)/=(dist);
 float NoL=saturate(dot(N,L));
 float Atten=saturate(((((dist)*(Lights01.w)))+(Lights00.w)));
 (Atten)*=(Atten);
 (DiffLit)+=(((Lights01.rgb)*(((NoL)*(Atten)))));
 
 {
 float m2=((((Roughness)*(Roughness)))+(0.0002));
 (m2)*=(m2);
 float3 H=normalize(((V)+(L)));
 float NoH=saturate(dot(N,H));
 float D=((((((((NoH)*(m2)))-(NoH)))*(NoH)))+(1));
 (D)=(((((D)*(D)))+(1e-06)));
 (D)=(((((0.25)*(m2)))/(D)));
 (lighting)=(((((Lights01.rgb)*(SpecularColor)))*(((((Atten)*(NoL)))*(D)))));
 }
 }
 if (((((Lights13.w)>(0)))&&(((Lights12.w)<=(0)))))
 {
 float4 LightPosRange=Lights10;
 float4 LightColorAtten=Lights11;
 float3 LightDir=Lights12.xyz;
 float3 FallOffCosHalfThetaPHi=Lights13.xyz;
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
 (lighting)+=(((((((Lights11.rgb)*(SpecularColor)))*(((((Atten)*(NoL)))*(D)))))*(spot)));
 }
 (DiffLit)+=(((LightColorAtten.rgb)*(((((NoL)*(Atten)))*(spot)))));
 }
 return lighting;
}
