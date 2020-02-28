Shader "MJH/MJH_Hair_Mask"
{
	Properties
	{
		[Toggle (PointCloudEnable)] PointCloudEnable("PointCloudEnable",float) = 0
		_MainTex ("Base", 2D) = "white" {}
		BaseMapBias ("BaseMapBias ", Range(-1,1)) = -1
		_MixTex ("Mix", 2D) = "white" {}
		_NormalTex ("Normal", 2D) = "normal" {}
		NormalMapBias ("NormalMapBias ", Range(-1,1)) = -0.5

		_EnvMap ("_EnvMap", 2D) = "black" {}

		AliasingFactor ("AliasingFactor", Range(0,1)) = 0.2
		EnvStrength ("EnvStrength", Range(0,2)) = 1
		ShadowColor ("ShadowColor", Vector) = (0.1122132,0.3493512,0.00003981071,0.5)

		EnvInfo ("EnvInfo", Vector) = (0,0.01,1,2.5)

		cEmissionScale ("cEmissionScale", Vector) = (1,1,1,1)
		[HDR]cVirtualLitColor ("cVirtualLitColor", Color) = (1, 0.72, 0.65, 0)
		cVirtualLitDir ("cVirtualLitDir", Vector) = (-0.5, 0.114 , 0.8576, 0.106)

		cRoughnessX("cRoughnessX", Range(0,1)) = 0.1
		cRoughnessY("cRoughnessY", Range(0,1)) = 1
		cAnisotropicScale("cAnisotropicScale", Range(0,10)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent"  "QUEUE"="Transparent"}
		LOD 100

		Pass
		{
			Tags { "LIGHTMODE"="ForwardBase"}
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest On
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma multi_compile __ SSS_ENABLE
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
			sampler2D _ReflectTex;



			half _Metallic;

			half AliasingFactor;

			half BaseMapBias;
			half NormalMapBias;
			half4 cVirtualLitDir;
			half4 cVirtualLitColor;
			half4 cEmissionScale;

			float cRoughnessX;
			float cRoughnessY;
			float cAnisotropicScale;

			

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

				half3 userData1 = half3(0.3,0.3,1.1);

				// sample the texture
				fixed4 texBase = tex2Dbias (_MainTex, half4(i.uv, 0, BaseMapBias));
				fixed4 texM = tex2D (_MixTex, i.uv);//X: smooth, Y : Metallic, Z: 
				fixed4 texN = tex2Dbias (_NormalTex, half4(i.uv, 0, NormalMapBias));
				texN.y = 1 - texN.y;
				half Alpha = texBase.w;

				
				half AO = texM.z;
				half SSSMask=0.0;
				half3 BaseColor = texBase.rgb * texBase.rgb;
				

				//Normal
				half3 normalTex = half3(texN.rgb * 2.0 - 1.0);
				half3 normalVec = i.world_tangent * normalTex.x + i.world_binormal * normalTex.y + i.world_normal * normalTex.z;
				half normalLen = sqrt(dot(normalVec,normalVec));
				normalVec /= normalLen;

				//Roughness
				half Smoothness= texM.r;

				half roughness = GetRoughnessFromSmoothness(Smoothness, i.world_normal.xyz);
				roughness = clamp (roughness + min (0.4, AliasingFactor * 10.0 * clamp (1.0 - normalLen, 0.0, 1.0)), 0.0, 1.0);

				half Roughness_X = roughness * cRoughnessX + (1e-06);
				half Roughness_Y = roughness * cRoughnessY + (1e-06);



				//Light & View Vector
				half3 lightDir = normalize(_WorldSpaceLightPos0.www*(-i.worldPos) + _WorldSpaceLightPos0.xyz);
				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				half3 SunColor = _LightColor0.rgb;


				half metalic = texM.y;//MixMap .y metalic
				half3 reflectDir = reflect(-viewDir,normalVec);
				fixed NdotV = clamp(dot(viewDir,normalVec),0,1);
				half NdotL = dot(normalVec,lightDir);



				half3 inputRadiance= SunColor.xyz * max(0.001,NdotL);
				inputRadiance*= cPointCloudm[0].a;

				//Emission: Sun各向异性高光,BaseColor 叠加摄像机方向的虚拟各向异性高光

				half VirtualLitNoL=max(0.001,dot(normalVec,viewDir));//摄像机方向虚拟光
				half3 virtualRadiance = VirtualLitNoL * cVirtualLitColor.xyz * userData1.z * 2;
				float directAniso = cAnisotropicScale * AnisoSpec(viewDir, lightDir, normalVec, max(0.001,NdotL),         i.world_tangent.xyz, i.world_binormal.xyz,Roughness_X, Roughness_Y );
				float virtualAniso = cAnisotropicScale * AnisoSpec(viewDir, viewDir, normalVec, VirtualLitNoL, i.world_tangent.xyz, i.world_binormal.xyz,Roughness_X, Roughness_Y );
				
				half4 Emission = half4(0,0,0,0);
				Emission.w = cEmissionScale.w;
				Emission.xyz = inputRadiance * directAniso.xxx;

				BaseColor.rgb += virtualRadiance * virtualAniso;
				BaseColor.rgb = min(BaseColor.rgb, 10);
				
  				Emission.xyz = Emission.xyz * (AO * Alpha);
  				Emission.xyz = min(Emission.xyz, 10.0);

				//Apply Metallic
				half3 SpecularColor = lerp(0.04,BaseColor,metalic);
  				half3 DiffuseColor = (BaseColor - BaseColor * metalic) / 3.141593;

				//shadow
				half shadow = 1;
				float atten = LIGHT_ATTENUATION(i);	
				shadow = atten;



				//GI :Messiah引擎GI数据还原
				half4 linearColor = half4(0,0,0,0);

			#ifdef PointCloudEnable			

				linearColor.xyz = DynamicGILight(normalVec);

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
				GILighting.w = AO;//

				half ssao = 1;
				half microshadow = shadow * clamp (abs(NdotL) + 2.0 * GILighting.w * GILighting.w - 1.0, 0.0, 1.0);
				shadow *= microshadow;

				//Sun light Offset
				half SunlightOffset = lerp(1,userData1.x * 2,SSSMask) * ShadowColor.g;
				shadow *= SunlightOffset;
				shadow *= cPointCloudm[0].w;
				
				//Diff lighting
				half3 diffLighting = half3(0,0,0);
				GILighting.rgb = lerp(GILighting.rgb,  GILighting.rgb * userData1.y *2 , SSSMask);
				diffLighting += GILighting.rgb * GILighting.w;

				GILighting.a *= saturate(dot(diffLighting.rgb,half3(0.3,0.59,0.11)));
				half3 SunLighting = saturate(NdotL) * SunColor * shadow;
				diffLighting =  diffLighting + SunLighting;
				GILighting.a = min(GILighting.a, ssao);

				//Sun Specular & Env Specular
				half3 EnvBRDF = EnvBRDFApprox(SpecularColor, roughness, NdotV);
				half3 EnvSpecular = GetIBLIrradiance(roughness, reflectDir) * EnvInfo.w * 10.0 * EnvBRDF;
				EnvSpecular = EnvSpecular * GILighting.w ;


				half3 sunSpec = Sun_Specular(lightDir, normalVec, viewDir, roughness, reflectDir, NdotV, NdotL, EnvBRDF);
				sunSpec = sunSpec * SunColor.xyz * saturate(NdotL * shadow);
				half3 Spec = EnvBRDF * EnvSpecular + sunSpec;

				//Virtual Light

				half3 VirtualLitDir = normalize(cVirtualLitDir.xyz);
				float VirtualNdotL = clamp (dot (VirtualLitDir, normalVec), 0.0, 1.0);
				VirtualNdotL = 0.444 + VirtualNdotL * 0.556;
				float3 virtualLit = cVirtualLitColor.xyz * cEmissionScale.w * VirtualNdotL;
				virtualLit = lerp(virtualLit, virtualLit * userData1.z * 2, SSSMask);
				diffLighting +=virtualLit;

				//Virtual Spec
				float3 virtualH = normalize(viewDir + VirtualLitDir);
				float VirtualNdotH = clamp (dot (normalVec, virtualH), 0.0, 1.0); 
				float m2= roughness*roughness+0.0002;
 				m2*=m2;
				float d = (VirtualNdotH * m2 - VirtualNdotH) * VirtualNdotH + 1.0;
				d = d * d +  1e-06;
				half3 virtualSpec = 0.25 * m2 / d;

				half3 VirtualSpecColor = virtualSpec * virtualLit * EnvBRDF;
				
				/*half4 FogInfo = half4(30, 0.0326,0.00672, 31.05);
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
				fogColor =   fogColor + (FogColor3 * VdotL  * VdotL).xyz;*/
				
				//float3 Color = Emission.xyz;
				float3 Color = Spec + VirtualSpecColor + diffLighting * DiffuseColor + Emission.xyz;
 
				/*Color = Color * EnvInfo.z;
				Color = clamp(Color.xyz, float3(0.0, 0.0, 0.0), float3(4.0, 4.0, 4.0));
				Color = Color * (1.0 - fog) + (Color.xyz * fog + fogColor) * fog;*/
				Color.xyz = Color.xyz / (Color.xyz * 0.9661836 + 0.180676);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return half4 (Color,texBase.w);
			}
			
			ENDCG
		}
		UsePass "MJH/Shadow/ShadowCaster"
	}
}
