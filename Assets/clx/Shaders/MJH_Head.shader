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
		_EnvMap ("Reflect", 2D) = "black" {}
		_LutMap("Lut Map ", 2D) = "black" {}
		_CrystalMapTex("Crystal Map", 2D) = "black"{}
		_CrystalMask("Crystal Map Mask", 2D) = "black"{}

		EnvStrength ("EnvStrength", Range(0,2)) = 1
		_SSSColor("_SSSColor", Color) = (0.7,0.2,0.5,1)
		ShadowColor ("ShadowColor", Vector) = (0.1122132,0.3493512,0.00003981071,0.5)

		EnvInfo ("EnvInfo", Vector) = (0,0.01,1,2.5)

		[HDR]cVirtualLitColor ("cVirtualLitColor", Color) = (1, 0.72, 0.65, 0)
		cVirtualLitDir ("cVirtualLitDir", Vector) = (-0.5, 0.114 , 0.8576, 0.106)
		cVirtualColorScale ("VirtualColorScale", Range(0,10)) = 4
		_SSSIntensity("SSS Intensity", Range(0,3)) = 1
		_RoughnessOffset("Roughness Offset", Range(0,1)) = 0.3
		_CrystalRange("Crystal Range", Range(0,1)) = 0.3
		_CrystalColor("Crystal Color", Color) = (1,1,1,1)
		_CrystalIntensity("Crystal Intensity",Range(0,2)) = 1
		_CrystalUVTile("Crystal UVTile", float) = 3
		_CrystalVirtualLit("Crystal Virtual Lit", Range(0,1)) = 0

				FogInfo("Fog Info", Vector) = (70,0.008,-0.003160504,0.3555721)

        FogColor("FogInfo", Color) = (0.2590002, 0.3290003, 0.623, 1.102886) 
        FogColor2("FogInfo2", Color) = (0,0,0,0.7713518)
        FogColor3("FogInfo3", Color) = (0.5, 0.35, 0.09500044, 0.6937419 )
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



			#include "MJH_Common.cginc"

			sampler2D _MixTex;
			sampler2D _NormalTex;

			sampler2D _LutMap;
			sampler2D _CrystalMapTex;
			sampler2D _CrystalMask;
			sampler2D _DetailNormalTex;






			
			half BaseMapBias;
			half NormalMapBias;
			half4 cVirtualLitDir;
			half4 cVirtualLitColor;

			float cVirtualColorScale;

			float _DeailUVScale;
			float maokong_intensity;
			float _SSSIntensity;
			float _RoughnessOffset;
			float _CrystalIntensity;
			float _CrystalRange;
			float _CrystalUVTile;
			float _CrystalVirtualLit;
			float4 _CrystalColor;
			float4 _SSSColor;


			fixed4 frag (v2f i) : SV_Target
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
				
				//Sample Textures
				fixed4 texBase = tex2Dbias (_MainTex, half4(i.uv, 0, BaseMapBias));//BaseColor.w save Roughness
				fixed4 texM = tex2D (_MixTex, i.uv);//Z :AO, W: vertex ColorW
				fixed4 texN = tex2Dbias (_NormalTex, half4(i.uv, 0, NormalMapBias));//W 毛孔
				
				texN.g = 1 - texN.g;
				float Curvature = texM.g;
				float Thickness = texM.r;	
				
				half3 BaseColor = texBase.rgb * texBase.rgb;

				//Apply Rain Roughness
				half Roughness = max(1.0 - texBase.w, 0.03);
			

				Roughness = GetRoughnessFromRoughness(Roughness, i.world_normal.xyz);

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
				detialNormalMap.g = 1 - detialNormalMap.g;
				half3 detailValue = half3(0,0,0);
				detailValue.x = detialNormalMap.z * 2.0 - 1.0;
				detailValue.y = detialNormalMap.w * 2.0 - 1.0;

				half3 detailNormal = normalize(normalTex + detailValue * 0.2 * maokong_intensity * texN.w);//temp

				half3 detailNormalVec =  i.world_tangent * detailNormal.x + i.world_binormal * detailNormal.y + i.world_normal * detailNormal.z;

				half3 bentNormal = normalize(lerp(detailNormalVec, normalVec, Thickness));

				float3 SpecularMask = float3(0.5,0.5,0.5) * (1.0 - texN.w) + detialNormalMap.xxx * texN.w;

				half3 lightDir = normalize(_WorldSpaceLightPos0.www*(-i.worldPos) + _WorldSpaceLightPos0.xyz);
				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				half3 reflectDir = reflect( -viewDir,normalVec);
				half3 SunColor = _LightColor0.xyz;

				half NdotV = saturate(dot(viewDir,normalVec));
				half NdotL = saturate(dot(normalVec,lightDir));
				//return half4(NdotL.xxx,1);
				// TODO: Shadow ,pcf_3x3, 
				half shadow = 1;
				float atten = LIGHT_ATTENUATION(i);	
				shadow = atten;
				half3 userData1 = half3(0.3,0.3,1.1);
				half3 SunIrradiance = SunColor.xyz * userData1.x * 2.0 * ShadowColor.y /** cPointCloudm[0].w*/;
				
				half3 ScatterAO = half3(0,0,0);
				ScatterAO.x = AO * (1.0 - Thickness) + 1.5 * Thickness;
				ScatterAO.y = AO;
				ScatterAO.z = AO;

				//PointCloud 
				half3 PointCloudIrradiance = DynamicGILightUseBentNormal(i, normalVec, bentNormal) * ScatterAO * userData1.y * 2;
				float PointCloudIlluminace=dot(PointCloudIrradiance,float3(0.3,0.59,0.11));

				//Virtual light 
				float3 VirtualLitDir = normalize(cVirtualLitDir);
				float3 VirtualLitColor = cVirtualLitColor.xyz;
				float3 VirtualLitNoL = 0.444 + 0.556 * saturate(dot(bentNormal, VirtualLitDir));

				half3 VirtualLitIrradiance = VirtualLitColor * userData1.z * 2.0 * AO * VirtualLitNoL;


				//Refraction
				float3 RefractionNoL = saturate(0.6 + dot(normalVec,lightDir)).xxx;
				float3 RefractionIrradiance = (SunIrradiance + PointCloudIrradiance) * Thickness * _SSSColor.rgb * RefractionNoL * RefractionNoL * shadow;

				//SSS LUT
				float LutU = 0.5 * dot(normalVec, lightDir) + 0.5;
				float2 LutUV1 = float2(LutU, _SSSIntensity * Curvature);
				float3 SSS_Lut1 = tex2D(_LutMap, LutUV1);
				SSS_Lut1.xyz *= SSS_Lut1.xyz;
				float DdotL = saturate(dot(detailNormalVec, lightDir));
				DdotL = DdotL - NdotL;
				float LutUV2 = shadow + DdotL * shadow;
				float3 SSS_Lut2 = float3(lerp(sqrt(LutUV2.r), LutUV2.r, 1 - _SSSIntensity), LutUV2.rr);
				SSS_Lut2.xyz *=SSS_Lut2.xyz;


				//Diffuse
				float3 SSS_SunIrradiance = lerp(SSS_Lut2.xyz * SSS_Lut1.xyz, NdotL * shadow, vertexColorw) * SunIrradiance * AO;

				float3 DiffuseIrradiance = PointCloudIrradiance + RefractionIrradiance + VirtualLitIrradiance + SSS_SunIrradiance;

				//Specular
				float RoughnessLayer1 = Roughness;
				float RoughnessLayer2 = Roughness * _RoughnessOffset;

				float3 SpecRadiance = float3(0,0,0);
				float3 EnvBRDF = float3(0,0,0);
				float brdfParam = SunIrradiance * NdotL * 2 * SpecularMask * shadow;
				float3 BRDF = float3(0,0,0);

				float3 SpecularColor=float3(0.04,0.04,0.04);

				BRDF = SpecBRDFPbr(RoughnessLayer1,RoughnessLayer2, lightDir, viewDir, detailNormalVec, SpecularColor);
				float3 SunSpecRadiance = BRDF * brdfParam;

				BRDF = SpecBRDFPbr(RoughnessLayer1,RoughnessLayer2, VirtualLitDir, viewDir, detailNormalVec, SpecularColor);

				float3 VirtualSpecRadiance = VirtualLitIrradiance * BRDF * SpecularMask;

				EnvBRDF = EnvBRDFApprox(SpecularColor, Roughness, NdotV);

				float3 PointCloudSpecRadiance = PointCloudIrradiance * EnvBRDF * SpecularMask * EnvInfo.w * EnvStrength;

				float3 IBLSpecRadiance = GetIBLIrradiance(Roughness, reflectDir) * EnvBRDF * AO * AO;

				SpecRadiance = SunSpecRadiance + VirtualSpecRadiance + PointCloudSpecRadiance + IBLSpecRadiance;

				//Crystal
				half3 crystalMaskmap = tex2D(_CrystalMask, i.uv);	
				half3 crystalmap = tex2D(_CrystalMapTex, 5 * _CrystalUVTile * i.uv);

				half3 crystalmask = crystalMaskmap.z * _CrystalIntensity * _CrystalColor * crystalmap;//Only mouth 

				half3 CrystalSpecBRDF = CrystalBRDF(_CrystalRange, lightDir, viewDir, detailNormalVec, crystalmask * 10);
				half3 CrystalSunSpec = brdfParam * CrystalSpecBRDF * AO;
				SpecRadiance += CrystalSunSpec;

				CrystalSpecBRDF = CrystalBRDF(_CrystalRange, VirtualLitDir, viewDir, detailNormalVec, crystalmask * _CrystalVirtualLit);
				half3 CrystalVirtualSpec = VirtualLitIrradiance * CrystalSpecBRDF;
				SpecRadiance += CrystalVirtualSpec;		

				//Final
				half3 DiffuseColor = BaseColor / 3.141593;
				float3 Diffuse = DiffuseColor * DiffuseIrradiance;
				float3 Out = Diffuse + SpecRadiance;

				//Apply Fog
				float temp31 = clamp ((i.worldPos.y * FogInfo.z + FogInfo.w), 0.0, 1.0);
				float fHeightCoef = temp31*temp31;
				fHeightCoef*=fHeightCoef;
				float fog = 1.0 - exp(-max (0.0, viewDir - FogInfo.x)* max (FogInfo.y * fHeightCoef, 0.1 * FogInfo.y));
				fog *= fog;
				

	/*			half3 fogColor = (FogColor2.xyz * clamp (viewDir.y * 5.0 + 1.0, 0.0, 1.0)) + FogColor.xyz;
				half VdotL =  clamp (dot (-viewDir, lightDir), 0.0, 1.0);
				fogColor =   fogColor + (FogColor3 * VdotL  * VdotL).xyz;*/
				
				float3 Color = Out;
			/*	Color = Color * (1.0 - fog) + (Color.xyz * fog + fogColor) * fog;
				Color = Color * EnvInfo.z;
				Color =  clamp (Color.xyz, float3(0.0, 0.0, 0.0), float3(4.0, 4.0, 4.0));*/

				//Liner to Gamma
				Color.xyz = Color.xyz / (Color.xyz * 0.9661836 + 0.180676);
				//Color = half3(0,0,0);

				return half4 (Color, 1);
			}
			
			ENDCG
		}

		UsePass "MJH/Shadow/ShadowCaster"

	}
}
