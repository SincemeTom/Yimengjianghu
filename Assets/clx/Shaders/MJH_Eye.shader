Shader "MJH/Eye"
{
	Properties
	{
		[Toggle (PointCloudEnable)] PointCloudEnable("PointCloudEnable",float) = 0
		_MainTex ("Base", 2D) = "white" {}
		BaseMapBias ("BaseMapBias ", Range(-1,1)) = -1
		_MixTex ("Mix", 2D) = "white" {}
		_MaskMap("Mask", 2D) = "black"{}
		_NormalTex ("Normal", 2D) = "normal" {}
		NormalMapBias ("NormalMapBias ", Range(-1,1)) = -0.5
		_EnvMap ("Reflect", 2D) = "black" {}


		AliasingFactor ("AliasingFactor", Range(0,1)) = 0.2
		EnvStrength ("EnvStrength", Range(0,10)) = 1
		ShadowColor ("ShadowColor", Vector) = (0.1122132,0.3493512,0.00003981071,0.5)

		EnvInfo ("EnvInfo", Vector) = (0,0.01,1,2.5)
		
		cEmissionScale ("cEmissionScale", Vector) = (1,1,1,1)
		[HDR]cVirtualLitColor ("cVirtualLitColor", Color) = (1, 0.72, 0.65, 0)
		cVirtualLitDir ("cVirtualLitDir", Vector) = (-0.5, 0.114 , 0.8576, 0.106)

		ColorScale("Color Scale", Vector) = (0.89, 0.89, 0.89, 0)
		ColorBias("Color Bias", Vector) = (-0.001, -0.001, 0, 0)
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
			sampler2D _MaskMap;



			half AliasingFactor;

			half BaseMapBias;
			half NormalMapBias;
			half4 cVirtualLitDir;
			half4 cVirtualLitColor;
			half4 cEmissionScale;
			float cVirtualColorScale;
			
			float4 ColorScale;
			float4 ColorBias;



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
				
				// sample the texture
				fixed4 texBase = tex2Dbias (_MainTex, half4(i.uv, 0, BaseMapBias));
				fixed4 texN = tex2Dbias (_NormalTex, half4(i.uv, 0, NormalMapBias));
                half4 unpackNormal = MJH_UnpackNormal(texN);
				half4 texMask = tex2D(_MaskMap, i.uv);
				half3 refMask = texMask.xyz;

				half mask = refMask.b;
				fixed4 texM = tex2D (_MixTex, i.uv);

				//Color 
                half SSSMask = 1 - unpackNormal.w;

				half3 BaseColor = texBase.rgb * texBase.rgb;
				half3 baseColorData = BaseColor;
				half3 scaleBaseColor = baseColorData * ColorScale.xyz;//Color Transform0,1,2
				BaseColor = BaseColor * (1.0 - mask) + clamp(scaleBaseColor, 0, 1) * mask;
				half3 biasColor = baseColorData + ColorBias.xyz;//Color Transform 3,4,5
				BaseColor = BaseColor * (1 - SSSMask) + clamp(biasColor, 0, 1) * SSSMask;

				float3 SpecularColor=float3(0.04,0.04,0.04);
				return half4(BaseColor.xyz,1);
				//Normal
				half3 normalTex = half3(texN.rgb * 2.0 - 1.0);
				half3 normalVec = i.world_tangent * normalTex.x + i.world_binormal * normalTex.y + i.world_normal * normalTex.z;
				half normalLen = sqrt(dot(normalVec,normalVec));
				normalVec /= normalLen;

				//Roughness
				half Smoothness= texM.r;

				half roughness = GetRoughnessFromSmoothness(Smoothness, i.world_normal.xyz);

				roughness = clamp (roughness + min (0.4, AliasingFactor * 10.0 * clamp (1.0 - normalLen, 0.0, 1.0)), 0.0, 1.0);

				//Light & View Vector
				half3 lightDir = normalize(_WorldSpaceLightPos0.www*(-i.worldPos) + _WorldSpaceLightPos0.xyz);
				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));


				//GI :Messiah引擎GI数据还原
				half4 linearColor = half4(0,0,0,0);

			#ifdef PointCloudEnable			
				half3 nSquared = normalVec * normalVec;
				fixed3 isNegative = fixed3(lessThan(normalVec, fixed3(0.0,0.0,0.0))) ;

				linearColor += nSquared.x * cPointCloudm[isNegative.x] + nSquared.y * cPointCloudm[isNegative.y + 2] + nSquared.z * cPointCloudm[isNegative.z + 4];

				linearColor.xyz = max(half3(0.9,0.9,0.9),linearColor);

				half3 shadowColorTmp = ShadowColor.x * (10.0 + cPointCloudm[3].w * ShadowColor.z * 100);
				linearColor.xyz = shadowColorTmp * linearColor;

			#else

				//GI : Unity LightProbe
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
				GILighting.xyz = linearColor.xyz;
				GILighting.w = texM.z;//MixMap .z ao


				half metalic = texM.y;//MixMap .y metalic
				//half3 SpecularColor = lerp(0.04,BaseColor,metalic);
				half3 DiffuseColor = BaseColor / 3.141593;
  				//half3 DiffuseColor = (BaseColor - BaseColor * metalic) / 3.141593;

				half3 reflectDir = reflect(-viewDir,normalVec);
				fixed NdotV = clamp(dot(viewDir,normalVec),0,1);

				half NdotL = dot(normalVec,lightDir);
				//
				half shadow = 1;
				float atten = LIGHT_ATTENUATION(i);	
				shadow = atten;
				shadow = shadow * clamp (abs(NdotL) + 2.0 * texM.z * texM.z - 1.0, 0.0, 1.0);

				half3 diffLighting = half3(0,0,0);
				//diffLighting += diffLight;
				diffLighting =  diffLighting + GILighting.xyz * texM.z;
				GILighting.w = texM.z * dot(diffLighting,half3(0.3,0.59,0.11));
				half3 SunColor = half3(0,0,0);
				SunColor = _LightColor0.rgb;
				half3 SunLighting = clamp (NdotL * shadow, 0,1) * SunColor.xyz;
				diffLighting = diffLighting + SunLighting;

                //Sun Specular

				float3 EnvBRDF = EnvBRDFApprox(SpecularColor, roughness, NdotV);
				float3 Reflect = viewDir - 2.0 * dot(normalVec , viewDir) * normalVec;
				

				half lod = roughness / 0.17;
				half fSign = half(reflectDir.z > 0);
				half temp =  fSign * 2.0 - 1.0;
				half2 reflectuv = reflectDir.xy / (reflectDir.z * temp + 1.0);
				reflectuv = reflectuv * half2(0.25, -0.25) + 0.25 + 0.5 * fSign;
				
				fixed4 srcColor = tex2Dlod (_EnvMap, half4(reflectuv.xy, 0, 0));
				//fixed4 srcColor = fixed4(0,0,0,0);
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

				//Virtual Light
				half3 norVirtualLitDir = normalize(cVirtualLitDir.xyz);
				float ndotlVir = clamp (dot (norVirtualLitDir, normalVec), 0.0, 1.0);
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

				//Apply Fog
				float temp31 = clamp ((i.worldPos.y * FogInfo.z + FogInfo.w), 0.0, 1.0);
				float fHeightCoef = temp31*temp31;
				fHeightCoef*=fHeightCoef;
				float fog = 1.0 - exp(-max (0.0, viewDir - FogInfo.x)* max (FogInfo.y * fHeightCoef, 0.1 * FogInfo.y));
				fog *= fog;
				


				half3 fogColor = (FogColor2.xyz * clamp (viewDir.y * 5.0 + 1.0, 0.0, 1.0)) + FogColor.xyz;
				half VdotL =  clamp (dot (-viewDir, lightDir), 0.0, 1.0);
				fogColor =   fogColor + (FogColor3 * VdotL  * VdotL).xyz;
				
				float3 Color = Spec + VirtualSpec + diffLighting * DiffuseColor;

				Color = Color * (1.0 - fog) + (Color.xyz * fog + fogColor) * fog;
				Color = Color* EnvInfo.z;
				Color =  clamp (Color.xyz, float3(0.0, 0.0, 0.0), float3(4.0, 4.0, 4.0));

				//Liner to Gamma
				Color.xyz = Color.xyz / (Color.xyz * 0.9661836 + 0.180676);

				return half4 (Color.xyz, texBase.w);
			}
			
			ENDCG
		}
		UsePass "MJH/Shadow/ShadowCaster"
	}
}
