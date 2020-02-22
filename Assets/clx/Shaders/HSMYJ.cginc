struct appdata {
	float4 vertex : POSITION;
	float4 tangent : TANGENT;
	float3 normal : NORMAL;
	float4 texcoord : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
	float4 texcoord3 : TEXCOORD3;
	fixed4 color : COLOR;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
	float4 worldPos   : TEXCOORD1;
	half3 world_normal  : TEXCOORD2;
	half3 world_tangent : TEXCOORD3;
	half3 world_binormal : TEXCOORD4;
	UNITY_FOG_COORDS(5)
	LIGHTING_COORDS(6,7)
	#if defined(LIGHTMAP_ON)|| defined(UNITY_SHOULD_SAMPLE_SH)
		float4 ambientOrLightmapUV : TEXCOORD8;
	#endif

};

sampler2D _MainTex;
sampler2D _MixTex;
sampler2D _NormalTex;
sampler2D _SkinProfileTex;
sampler2D _ReflectTex;
float4 _MainTex_ST;

half4 EnvInfo;
half Metallic;
half Curvature;
half4 AmbientColor;
half4 ShadowColor;
half4 Paramter;
half AliasingFactor;
half EnvStrength;
half BaseMapBias;
half NormalMapBias;

v2f vert (appdata v)
{
	v2f o = (v2f)0;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
	o.worldPos = mul( unity_ObjectToWorld, v.vertex );

	half3 wNormal = UnityObjectToWorldNormal(v.normal);  
	half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
	half tangentSign = v.tangent.w * unity_WorldTransformParams.w;  
	half3 wBinormal = cross(wNormal, wTangent) * tangentSign;  
					
	o.world_normal =wNormal;
	o.world_tangent = wTangent; 
	o.world_binormal = wBinormal;
	
	TRANSFER_VERTEX_TO_FRAGMENT(o);
	UNITY_TRANSFER_FOG(o,o.pos);
	return o;
}
fixed4 frag_main (v2f i) : SV_Target
{

	fixed4 texBase = tex2Dbias (_MainTex, half4(i.uv, 0, BaseMapBias));
	fixed4 texM = tex2D (_MixTex, i.uv);
	fixed4 texN = tex2Dbias (_NormalTex, half4(i.uv, 0, NormalMapBias));
	
	half3 BaseColor = texBase.rgb * texBase.rgb;
	
	float rain = EnvInfo.x * 0.5;
	half tem0 = clamp (3.0 * i.world_normal.y + 0.2 + 0.1 * rain, 0.0, 1.0);
	rain = (1.0 - (rain * tem0));
	rain = clamp ((rain - (rain * texM.x)), 0.05, 1.0);

	half3 normalTex = half3(texN.rgb * 2.0 - 1.0);

	half3 normalVec = i.world_tangent * normalTex.x + i.world_binormal * normalTex.y + i.world_normal * normalTex.z;
	half normalLen = sqrt(dot(normalVec,normalVec));
	normalVec /= normalLen;
	half roughness = clamp (rain + min (0.4,AliasingFactor * 10.0 * clamp (1.0 - normalLen, 0.0, 1.0)), 0.0, 1.0);

float atten = LIGHT_ATTENUATION(i);	
half4 GILighting = 0;
	GILighting.xyz = AmbientColor.xyz;
	
	half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
	half3 reflectDir = reflect(viewDir,normalVec);
	fixed VdotN = clamp(dot(viewDir,normalVec),0,1);			
	half3 lightDir = normalize(_WorldSpaceLightPos0.www*(-i.worldPos) + _WorldSpaceLightPos0.xyz);
	half NdotL = dot(normalVec,lightDir);			
	
	half shadow = clamp (abs(NdotL)+2.0 * texM.z * texM.z - 1.0, 0.0, 1.0);
	half3 diffLighting = ShadowColor.xyz * texM.z;
	GILighting.w = dot(diffLighting,half3(0.3,0.59,0.11));
#ifdef SSS_ENABLE
	half metalic = Metallic;
	half2 sssuv;
	sssuv.x = NdotL * atten * 0.5 + 0.5;
	sssuv.y = Curvature * texM.y;
	half3 sss = tex2D (_SkinProfileTex, sssuv).xyz;
	
	diffLighting = diffLighting + sss * sss * _LightColor0.xyz * shadow;
#else
	half metalic = texM.y;
	NdotL = clamp(NdotL,0,1);
	diffLighting = diffLighting + NdotL * atten * _LightColor0.xyz * shadow;
#endif
	half3 diffuseColor = (BaseColor - BaseColor * metalic) / 3.141593;
	half3 specularColor = lerp(0.04,BaseColor,metalic);
	
	half lod = roughness / 0.17;
	tem0 = reflectDir.z > 0; 
	half2 reflectuv = reflectDir.xy / ((reflectDir.z * (tem0 * 2.0 - 1.0)) + 1.0);
	reflectuv = ((reflectuv * half2(0.25, -0.25)) + (0.25 + (0.5 * tem0)));
	reflectuv.x = 1-reflectuv.x;
	fixed4 srcColor = tex2Dlod (_ReflectTex, half4(reflectuv, 0, lod));
	half3 EnvSpecular = srcColor.xyz * srcColor.w * srcColor.w * 16.0 * EnvStrength;
	
	half4 tem1 = roughness * half4(-1.0, -0.0275, -0.572, 0.022) + half4(1.0, 0.0425, 1.04, -0.04);
	half2 ab = half2(-1.04, 1.04) * (min (tem1.x * tem1.x, exp2(-9.28 * VdotN)) * tem1.x + tem1.y) + tem1.zw;
	ab.y = ab.y * clamp(50 * specularColor.y,0,1);
	half3 Spec = (specularColor * ab.x + ab.y) * EnvSpecular * GILighting.w * EnvInfo.w * 10.0;
	
	fixed3 H = normalize(viewDir + lightDir);
	fixed VdotH = clamp(dot(viewDir,H),0,1);
	fixed NdotH = clamp(dot(normalVec,H),0,1);
	half rough = max(0.08,roughness);
	rough*=rough;
	half tem2 = rough * 0.5;
	rough*=rough;
	tem0 = (NdotH * rough - NdotH) * NdotH + 1.0;
	tem0 = rough / (tem0 * tem0 * 3.141593);//@1
	half G = 0.25 / ((VdotN * (1.0 - tem2) + tem2) * (NdotL * (1.0 - tem2) + tem2));
	
	tem2 = clamp(specularColor.g * 50, 0, 1);
	half F = specularColor + (tem2 - specularColor) * exp2((-5.55473 * VdotH - 6.98316) * VdotH);
	tem0 *= G * F;
	Spec = Spec + tem0 * shadow * _LightColor0.rgb * Paramter.w * clamp(3*NdotL,0,1) * atten;
	Spec = min(Spec,4);//@2
	

	fixed4 col = 1;
	
	col.rgb = Spec + diffLighting * diffuseColor;
	col.rgb = max(col.rgb,0);
	
	col.xyz = ((col.xyz / (col.xyz + 0.187)) * 1.035);
	
	UNITY_APPLY_FOG(i.fogCoord, col);
	return col;
}

fixed4 frag_main_add (v2f i) : SV_Target
{

	fixed4 texBase = tex2Dbias (_MainTex, half4(i.uv, 0, BaseMapBias));
	fixed4 texM = tex2D (_MixTex, i.uv);
	fixed4 texN = tex2Dbias (_NormalTex, half4(i.uv, 0, NormalMapBias));
	
	half3 BaseColor = texBase.rgb * texBase.rgb;
	
	float rain = EnvInfo.x * 0.5;
	half tem0 = clamp (3.0 * i.world_normal.y + 0.2 + 0.1 * rain, 0.0, 1.0);
	rain = (1.0 - (rain * tem0));
	rain = clamp ((rain - (rain * texM.x)), 0.05, 1.0);

	half3 normalTex = half3(texN.rgb * 2.0 - 1.0);

	half3 normalVec = i.world_tangent * normalTex.x + i.world_binormal * normalTex.y + i.world_normal * normalTex.z;
	half normalLen = sqrt(dot(normalVec,normalVec));
	normalVec /= normalLen;
	half roughness = clamp (rain + min (0.4,AliasingFactor * 10.0 * clamp (1.0 - normalLen, 0.0, 1.0)), 0.0, 1.0);

float atten = LIGHT_ATTENUATION(i);	
	
	half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
	half3 reflectDir = reflect(viewDir,normalVec);
	fixed VdotN = clamp(dot(viewDir,normalVec),0,1);			
	half3 lightDir = normalize(_WorldSpaceLightPos0.www*(-i.worldPos) + _WorldSpaceLightPos0.xyz);
	half NdotL = dot(normalVec,lightDir);

	
#ifdef SSS_ENABLE
	half metalic = Metallic;
#else
	half metalic = texM.y;
#endif	
	
	NdotL = clamp(NdotL,0,1);
	half3 diffLighting = NdotL * atten * _LightColor0.xyz;

	half3 diffuseColor = (BaseColor - BaseColor * metalic) / 3.141593;
	half3 specularColor = lerp(0.04,BaseColor,metalic);
	half GILightingW = dot(diffLighting,half3(0.3,0.59,0.11));	
	
	
	fixed3 H = normalize(viewDir + lightDir);
	fixed VdotH = clamp(dot(viewDir,H),0,1);
	fixed NdotH = clamp(dot(normalVec,H),0,1);
half rough = max(0.08,roughness);
	rough*=rough;
	half tem2 = rough * 0.5;
	rough*=rough;
	tem0 = (NdotH * rough - NdotH) * NdotH + 1.0;
	tem0 = rough / (tem0 * tem0 * 3.141593);//@1
	half G = 0.25 / ((VdotN * (1.0 - tem2) + tem2) * (NdotL * (1.0 - tem2) + tem2));
	
	tem2 = clamp(specularColor.g * 50, 0, 1);
	half F = specularColor + (tem2 - specularColor) * exp2((-5.55473 * VdotH - 6.98316) * VdotH);
	tem0 *= G * F;
	half3 Spec = tem0 * atten * _LightColor0.rgb * Paramter.w * clamp(3*NdotL,0,1) * GILightingW;
	

	fixed4 col = 1;
	
	col.rgb = Spec + diffLighting * diffuseColor;
	col.rgb = max(col.rgb,0);

	col.xyz = ((col.xyz / (col.xyz + 0.187)) * 1.035);
	
	UNITY_APPLY_FOG(i.fogCoord, col);
	return col;
}

half RoughnessX;
half RoughnessY;
half AnisotropicScale;
fixed4 cBaseColor;

fixed4 frag_hair (v2f i) : SV_Target
{

	fixed4 texBase = tex2Dbias (_MainTex, half4(i.uv, 0, BaseMapBias));
	fixed4 texM = tex2D (_MixTex, i.uv);
	fixed4 texN = tex2Dbias (_NormalTex, half4(i.uv, 0, NormalMapBias));
	
	half3 BaseColor = texBase.rgb * texBase.rgb;
	
	float rain = EnvInfo.x * 0.5;
	half tem0 = clamp (3.0 * i.world_normal.y + 0.2 + 0.1 * rain, 0.0, 1.0);
	rain = (1.0 - (rain * tem0));
	rain = clamp ((rain - (rain * texM.x)), 0.05, 1.0);

	half3 normalTex = half3(texN.rgb * 2.0 - 1.0);

	half3 normalVec = i.world_tangent * normalTex.x + i.world_binormal * normalTex.y + i.world_normal * normalTex.z;
	half normalLen = sqrt(dot(normalVec,normalVec));
	normalVec /= normalLen;
	half roughness = clamp (rain + min (0.4,AliasingFactor * 10.0 * clamp (1.0 - normalLen, 0.0, 1.0)), 0.0, 1.0);
	half roughX = RoughnessX * roughness + 1e-06;
	half roughY = RoughnessY * roughness + 1e-06;
	
	half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
	half3 lightDir = normalize(_WorldSpaceLightPos0.www*(-i.worldPos) + _WorldSpaceLightPos0.xyz);
	half NdotL = dot(normalVec,lightDir);
float atten = LIGHT_ATTENUATION(i);
NdotL *= atten;	
	half NdotLc = max(NdotL,0.001);
	fixed VdotN = clamp(dot(viewDir,normalVec),0,1);
	half3 inputRadiance = _LightColor0.rgb * NdotLc;
	fixed3 H = normalize(viewDir + lightDir);
	half HoT = dot(H,i.world_tangent) / roughX;
	half HoB = dot(H,i.world_binormal) / roughY;
	
	half3 Emission =  AnisotropicScale * lerp (0.04, BaseColor, texM.y) * inputRadiance * exp(-2.0 * (HoT * HoT + HoB * HoB) / (1.0 + dot (H, normalVec))) / max (0.001, 12.56637 * roughX * roughY * sqrt(NdotL * VdotN));
	Emission = Emission * texM.z * texBase.w;
	Emission.xyz = min (Emission.xyz, 10.0);
	
	BaseColor *= cBaseColor;
	
half4 GILighting = 0;
	GILighting.xyz = AmbientColor.xyz;

	half3 diffuseColor = (BaseColor - BaseColor * texM.y) / 3.141593;
	half3 specularColor = lerp(0.04,BaseColor,texM.y);
	half3 reflectDir = reflect(viewDir,normalVec);
	
	half3 diffLighting = ShadowColor.xyz;
	GILighting.w = dot(diffLighting,half3(0.3,0.59,0.11));
	half shadow = clamp (abs(NdotL)+1.0, 0.0, 1.0);
	diffLighting = diffLighting + NdotLc * _LightColor0.xyz * shadow;
	
	half lod = roughness / 0.17;
	tem0 = reflectDir.z > 0; 
	half2 reflectuv = reflectDir.xy / ((reflectDir.z * (tem0 * 2.0 - 1.0)) + 1.0);
	reflectuv = ((reflectuv * half2(0.25, -0.25)) + (0.25 + (0.5 * tem0)));
	reflectuv.x = 1-reflectuv.x;
	fixed4 srcColor = tex2Dlod (_ReflectTex, half4(reflectuv, 0, lod));
	half3 EnvSpecular = srcColor.xyz * srcColor.w * srcColor.w * 16.0 * EnvStrength;
	
	half4 tem1 = roughness * half4(-1.0, -0.0275, -0.572, 0.022) + half4(1.0, 0.0425, 1.04, -0.04);
	half2 ab = half2(-1.04, 1.04) * (min (tem1.x * tem1.x, exp2(-9.28 * VdotN)) * tem1.x + tem1.y) + tem1.zw;
	ab.y = ab.y * clamp(50 * specularColor.y,0,1);
	half3 Spec = (specularColor * ab.x + ab.y) * EnvSpecular * GILighting.w * EnvInfo.w * 10.0;
	Spec = min(Spec,4);

	fixed4 col = 1;
	col.w = texBase.a;
	col.rgb = Spec + Emission + diffLighting * diffuseColor;

	col.xyz = ((col.xyz / (col.xyz + 0.187)) * 1.035);
	
	UNITY_APPLY_FOG(i.fogCoord, col);
	return col;
}
						