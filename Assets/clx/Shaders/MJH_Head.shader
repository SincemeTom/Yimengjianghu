Shader "MJH/Head"
{
	Properties
	{
		[Toggle (PointCloudEnable)] PointCloudEnable("PointCloudEnable",float) = 0
		_MainTex ("Base", 2D) = "white" {}
		BaseMapBias ("BaseMapBias ", Range(-1,1)) = -1
		_MixTex ("Mix", 2D) = "white" {}
		_NormalTex ("Normal", 2D) = "normal" {}
		NormalMapBias ("NormalMapBias ", Range(-1,1)) = -0.5
		_DetailNormalTex("Detail Normal Map", 2D) = "black"
		_DeailUVScale("Deail UV Scale", float) = 1
		maokong_intensity("maokong intensity", float) = 1
		_ReflectTex ("Reflect", 2D) = "black" {}
		_LutMap("Lut Map ", 2D) = "black" {}
		_CrystalMapTex("Crystal Map", 2D) = "black"{}
		_CrystalMask("Crystal Map Mask", 2D) = "black"{}

		cSkinCurvature("cSkinCurvature", Range(0,1)) = 0.5
		AliasingFactor ("AliasingFactor", Range(0,1)) = 0.2
		EnvStrength ("EnvStrength", Range(0,2)) = 1
		ShadowColor ("ShadowColor", Vector) = (0.1122132,0.3493512,0.00003981071,0.5)
		//AmbientColor ("AmbientColor", Color) = (0,0,0,0)
		EnvInfo ("EnvInfo", Vector) = (0,0.01,1,2.5)

		cEmissionScale ("cEmissionScale", Vector) = (1,1,1,1)
		cVirtualLitColor ("cVirtualLitColor", Color) = (1, 0.72, 0.65, 0)
		cVirtualLitDir ("cVirtualLitDir", Vector) = (-0.5, 0.114 , 0.8576, 0.106)
		cVirtualColorScale ("VirtualColorScale", Range(0,10)) = 4
		_SSSIntensity("SSS Intensity", Range(0,3)) = 1
		_RoughnessOffset("Roughness Offset", Range(0,1)) = 0.3
		_CrystalRange("Crystal Range", Range(0,1)) = 0.3
		_CrystalColor("Crystal Color", Color) = (1,1,1,1)
		_CrystalIntensity("Crystal Intensity",Range(0,2)) = 1
		_CrystalUVTile("Crystal UVTile", float) = 3
		_CrystalVirtualLit("Crystal Virtual Lit", Range(0,1)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags { "LIGHTMODE"="ForwardBase"}
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma multi_compile __ PointCloudEnable
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

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
			sampler2D _ReflectTex;
			sampler2D _LutMap;
			sampler2D _CrystalMapTex;
			sampler2D _CrystalMask;
			sampler2D _DetailNormalTex;
			float4 _MainTex_ST;

			half4 EnvInfo;
			half Curvature;
			half4 AmbientColor;
			half4 ShadowColor;

			half AliasingFactor;
			half EnvStrength;
			half BaseMapBias;
			half NormalMapBias;
			half4 cVirtualLitDir;
			half4 cVirtualLitColor;
			half4 cEmissionScale;
			float cVirtualColorScale;
			float cSkinCurvature;
			float _DeailUVScale;
			float maokong_intensity;
			float _SSSIntensity;
			float _RoughnessOffset;
			float _CrystalIntensity;
			float _CrystalRange;
			float _CrystalUVTile;
			float _CrystalVirtualLit;
			float4 _CrystalColor;
/*
User Data
0	0	0	2
0.3	0.3	1.1	0
0	0	0	0
*/
			
			fixed3 lessThan(float3 a, float3 b)
			{
				fixed3 r = fixed3(1,1,1);
				r.x = a.x < b.x ? 0 : 1;
				r.y = a.y < b.y ? 0 : 1;
				r.z = a.z < b.z ? 0 : 1;
				return r;
			}
			v2f vert (appdata v)
			{
				v2f o = (v2f)0;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
				o.worldPos = mul( unity_ObjectToWorld, v.vertex );
				float3 normal  = v.normal/* * 2.0 - 1*/;
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
			half4 MJH_UnpackNormal(in float4 normal)
            {
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

			fixed4 frag (v2f i) : SV_Target
			{
				
				//Sample Textures
				fixed4 texBase = tex2Dbias (_MainTex, half4(i.uv, 0, BaseMapBias));//BaseColor.w save Roughness
				fixed4 texM = tex2D (_MixTex, i.uv);//Z :AO, W: vertex ColorW
				fixed4 texN = tex2Dbias (_NormalTex, half4(i.uv, 0, NormalMapBias));//W 毛孔
				
				float Alpha = texM.y * cSkinCurvature + 1.0;

				
				half3 BaseColor = texBase.rgb * texBase.rgb;

				//Apply Rain Roughness
				half Roughness = max(1.0 - texBase.w, 0.03);
				float rainRough = EnvInfo.x * 0.5;
				half tem0 = clamp (3.0 * i.world_normal.y + 0.2 + 0.1 * rainRough, 0.0, 1.0);
				rainRough = 1.0 - (rainRough * tem0);
				rainRough = clamp (rainRough - rainRough * Roughness, 0.05, 1.0);
				Roughness = rainRough;
				half roughness = Roughness;

				half vertexColorw = 1.0 - texM.w;
				
				//AO
				float AO = texM.z;
				//Normal 
				half3 normalTex = half3(texN.rgb * 2.0 - 1.0);
				half3 normalVec = i.world_tangent * normalTex.x + i.world_binormal * normalTex.y + i.world_normal * normalTex.z;
				half normalLen = sqrt(dot(normalVec,normalVec));
				normalVec /= normalLen;
				
				//Detail Normal
				half4 detialNormalMap = tex2D(_DetailNormalTex, i.uv * _DeailUVScale);

				half3 detailValue = half3(0,0,0);
				detailValue.x = detialNormalMap.z * 2.0 - 1.0;
				detailValue.y = detialNormalMap.w * 2.0 - 1.0;

				half3 detailNormal = normalize(normalTex + detailValue * 0.2 * maokong_intensity * texN.w);

				half3 detailNormalVec =  i.world_tangent * detailNormal.x + i.world_binormal * detailNormal.y + i.world_normal * detailNormal.z;

				//half roughness = clamp (rainRough + min (0.4,AliasingFactor * 10.0 * clamp (1.0 - normalLen, 0.0, 1.0)), 0.0, 1.0);


				float3 SpecularMask = float3(0.5,0.5,0.5) * (1.0 - texN.w) + detialNormalMap.xxx * texN.w;

				half3 lightDir = normalize(_WorldSpaceLightPos0.www*(-i.worldPos) + _WorldSpaceLightPos0.xyz);
				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));


				//GI
				half4 linearColor = half4(0,0,0,0);
				#ifdef PointCloudEnable
				
				float4 cPointCloudm[6] = 
				{
					float4 (0.4153285,	0.3727325,	0.3066995,	1),
					float4 (0.6216756,	0.6451226,	0.6716674,	1),
					float4 (0.5540166,	0.7015119,	0.8980855,	1),
					float4 (0.3778813,	0.2398499,	0.05358088,	1),
					float4 (0.3423186,	0.4456023,	0.4700097,	1),
					float4 (0.6410592,	0.5083932,	0.4235953,	1)
				};
				
				half3 nSquared = normalVec * normalVec;
				fixed3 isNegative = fixed3(lessThan(normalVec, fixed3(0.0,0.0,0.0))) ;

				linearColor += nSquared.x * cPointCloudm[isNegative.x] + nSquared.y * cPointCloudm[isNegative.y + 2] + nSquared.z * cPointCloudm[isNegative.z + 4];
				linearColor.xyz = max(half3(0.9,0.9,0.9),linearColor);

				half3 shadowColorTmp = (ShadowColor.x * (10.0 + cPointCloudm[3].w * ShadowColor.z * 100)).xxx;

				linearColor.xyz = shadowColorTmp * linearColor;

				#else

				//GI 
				UnityLight light;
				#ifdef LIGHTMAP_OFF
					light.color = _LightColor0.rgb;
					light.dir = lightDir;
					light.ndotl = LambertTerm(normalVec, light.dir);
				#else
					light.color = half3(0,0,0);
					light.dir = 0.0;
					light.ndotl = half3(0,0,0);
				#endif
				UnityGIInput giinput;
				giinput.light = light;
				giinput.worldPos = i.worldPos.xyz;
				giinput.worldViewDir = viewDir;
				giinput.atten = 1;

				#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
					giinput.ambient = 0;
					giinput.lightmapUV = i.ambientOrLightmapUV;
				#else
					giinput.ambient = i.ambientOrLightmapUV;
				#endif

				UnityGI gi = UnityGlobalIllumination(giinput, 1, normalVec);
				
				linearColor.xyz += gi.indirect.diffuse;
				

				#endif



				half4 GILighting = half4(0,0,0,0);
				GILighting.xyz = linearColor.xyz * ShadowColor.x * (10.0 + 0.9036196 * ShadowColor.z * 100.0);
				GILighting.w = texM.z;

				half3 SunColor = half3(0,0,0);
				SunColor = _LightColor0.rgb;

				//Shadow = 1.0;
				half Shadow = 1.0;

				half3 UseData1 = half3(0.3,0.3,1.1);
				half3 SunIrradiance = SunColor.xyz * UseData1.x * 2.0 * ShadowColor.y /** cPointCloudm[0].w*/;
				half3 ScatterAO = half3(0,0,0);
				ScatterAO.x = texM.z * (1.0 - texM.x) + 1.5 * texM.x;
				ScatterAO.y = AO;
				ScatterAO.z = AO;


				float3 giLight = linearColor.xyz * ScatterAO * UseData1.y * 2.0;

  				half3 DiffuseColor = BaseColor / 3.141593;
				
				
				half3 reflectDir = reflect(viewDir,normalVec);
				fixed NdotV = clamp(dot(viewDir,normalVec),0,1);

				half NdotL = dot(normalVec,lightDir);
				half shadow = clamp (abs(NdotL) + 2.0 * texM.z * texM.z - 1.0, 0.0, 1.0);

				#ifdef PointCloudEnable
				shadow = shadow * cPointCloudm[0].w * ShadowColor.y;
				#else
				shadow = shadow * 1 * ShadowColor.y;
				#endif


				
				float atten = LIGHT_ATTENUATION(i);	

				half3 diffLight = half3(0,0,0);
				//half3 diffLight = NdotL * _LightColor0.rgb * atten;
				half3 diffLighting =  diffLight + GILighting.xyz * texM.z;
				GILighting.w = texM.y * dot(diffLighting,half3(0.3,0.59,0.11));

				half3 SunLighting = clamp (NdotL * shadow, 0,1) * SunColor.xyz;
				diffLighting = diffLighting + SunLighting;

				//skin profile
				half2 skin_uv = half2(NdotL * 0.5 + 0.5 , clamp (Alpha - 1, 0.0, 1.0));
				
				fixed4 tex_Skin = tex2D(_LutMap, skin_uv);
		//((diffuse_42 * diffuse_42) * (SunColor.xyz * shadow_11));
				half3 skinDiffuse = tex_Skin.xyz * tex_Skin.xyz * SunColor.xyz * shadow;

				diffLighting += skinDiffuse;

				half4 r = roughness * float4(-1.0, -0.0275, -0.572, 0.022) + float4(1.0, 0.0425, 1.04, -0.04); 
				half2 ab = half2(-1.04, 1.04) * (min (r.x * r.x, exp2(-9.28 * NdotV)) * r.x + r.y) + r.zw;
				float3 EnvBRDF = float3(0.4,0.4,0.4) * ab.x + ab.y;

				float3 Reflect = viewDir - 2.0 * dot(normalVec , viewDir) * normalVec;
				
				half lod = roughness / 0.17;
				bool fSign = reflectDir.z > 0;
				half temp =  fSign * 2 - 1;
				half2 reflectuv = reflectDir.xy / (reflectDir.z * temp + 1.0);
				reflectuv = reflectuv * half2(0.25, -0.25) + 0.25 + 0.5 * fSign;
				
				fixed4 srcColor = tex2Dlod (_ReflectTex, half4(reflectuv, 0, lod));
				half3 EnvSpecular = srcColor.xyz * srcColor.w * srcColor.w * 16.0 * EnvStrength ;
				EnvSpecular = EnvSpecular * GILighting.w * EnvInfo.w * 10.0;

				fixed3 H = normalize(viewDir + lightDir);
				fixed VdotH = clamp(dot(viewDir,H),0,1);
				fixed NdotH = clamp(dot(normalVec,H),0,1);
				half rough = max(0.08,roughness);
				float a = rough * rough;
				float a2 = a * a;
				float d = (NdotH * a2 - NdotH) * NdotH + 1.0;
				float D_GGX = rough / (d * d * 3.141593);

				float half_a = a * 0.5;
				float ClampNdotL = clamp (NdotL, 0.0, 1.0);
				float G = 0.25 / ((NdotV * (1.0 - half_a)+ half_a) * (ClampNdotL * (1.0 - half_a)+ half_a));
				
				float temp70 = clamp(EnvBRDF.g * 50, 0, 1);

				float3 F = EnvBRDF + (temp70 - EnvBRDF) * exp2((-5.55473 * VdotH - 6.98316) * VdotH);

				half3 sunSpec = D_GGX * G * F;
				sunSpec = sunSpec * SunColor.xyz * clamp (NdotL * shadow, 0.0, 1.0);

				half3 Spec = EnvBRDF * EnvSpecular + sunSpec;


				//cVirtualLitColor *= cVirtualColorScale;
				half3 norVirtualLitDir = normalize(cVirtualLitDir.xyz);
				float ndotlVir = clamp (dot (norVirtualLitDir, normalVec), 0.0, 1.0);
				float VirtualLitNoL = 0.444 + 0.556 * clamp(dot(normalize(detailNormalVec * (1.0 - texM.x) + normalVec * texM.x), norVirtualLitDir), 0, 1);
				half3 VirtualLitIrradiance = cVirtualLitColor.xyz * UseData1.z * 2.0 * texM.z * (0.444 + 0.556 * clamp(dot(normalize(detailNormalVec * (1.0 - texM.x) + normalVec * texM.x), norVirtualLitDir), 0, 1)).xxx;

				float RefractionNoL = clamp(0.6 + dot(normalVec,lightDir), 0, 1);
				//SSS Lut
				float2 LutUV = float2(dot(normalVec,lightDir) * 0.5 + 0.5, texM.y * _SSSIntensity);

				float4 LutMap = tex2D(_LutMap, LutUV);

				float3 SSSLut = LutMap.xyz * LutMap.xyz;

				float virtualshadow = shadow +  (clamp(dot(detailNormalVec, lightDir), 0.0, 1.0) - NdotL) * shadow;

				float NSSSIntensity = 1.0 - _SSSIntensity;

				float3 SSSLight;
				SSSLight.x = sqrt(virtualshadow) * (1 - NSSSIntensity) + virtualshadow * NSSSIntensity;
				SSSLight.yz = virtualshadow.xx;


				float roughnessOffset = roughness * _RoughnessOffset;

				float SunLight = (SunIrradiance * NdotL * 2.0 * SpecularMask * shadow).x;


//SpecRadiance

				//Crystal

				half3 CrystalSpecBRDF = CrystalBRDF(_CrystalRange, lightDir, viewDir, detailNormalVec, SpecularColor);

				return half4(CrystalSpecBRDF.xyz , 1);


				float3 virtualLit = cVirtualLitColor.xyz * cEmissionScale.w * ndotlVir;
				diffLighting +=virtualLit;
				float NdotHVir = clamp (dot (normalVec, normalize(viewDir + norVirtualLitDir)), 0.0, 1.0); 
				float roughVir = roughness * roughness + 0.0002;
				float aVir = roughVir;
				float aVir2 = roughVir * roughVir;
				float dVir = (NdotHVir * aVir2- NdotHVir) * NdotHVir + 1.0;
				float abVir = dVir * dVir +  1e-06;
				float D_Vir = 0.25 * aVir2 / abVir;
				half3 VirtualSpec = virtualLit * EnvBRDF * D_Vir;
				
				half4 FogInfo = half4(30, 0.0326,0.00672, 31.05);
				float temp31 = clamp ((i.worldPos.y * FogInfo.z + FogInfo.w), 0.0, 1.0);
				float fHeightCoef = temp31*temp31;
				fHeightCoef*=fHeightCoef;
				float fog = 1.0 - exp(-max (0.0, viewDir - FogInfo.x)* max (FogInfo.y * fHeightCoef, 0.1 * FogInfo.y));
				fog *= fog;
				

				half4 FogColor = half4(0.224,0.2949,0.54588,0.36);
				half4 FogColor2 = half4(0,0,0,0.36);
				half4 FogColor3 = half4(4,1.45,0,0.36);

				half3 fogColor = (FogColor2.xyz * clamp (viewDir.y * 5.0 + 1.0, 0.0, 1.0)) + FogColor.xyz;
				half VdotL =  clamp (dot (-viewDir, lightDir), 0.0, 1.0);
				fogColor =   fogColor + (FogColor3 * VdotL  * VdotL).xyz;
				

				float3 Color = Spec + VirtualSpec + diffLighting * DiffuseColor;

				Color = Color * EnvInfo.z;
				Color = clamp(Color.xyz, float3(0.0, 0.0, 0.0), float3(4.0, 4.0, 4.0));
				Color = Color * (1.0 - fog) + (Color.xyz * fog + fogColor) * fog;
				Color.xyz = Color.xyz / (Color.xyz * 0.9661836 + 0.180676);
				//Color = half3(0,0,0);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return half4 (Color, 1);
			}
			
			ENDCG
		}
	}
}
