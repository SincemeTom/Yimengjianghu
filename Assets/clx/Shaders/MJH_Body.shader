Shader "MJH/Body"
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
		EnvStrength ("EnvStrength", Range(0,2)) = 1
		ShadowColor ("ShadowColor", Vector) = (0.1122132,0.3493512,0.00003981071,0.5)

		EnvInfo ("EnvInfo", Vector) = (0,0.01,1,2.5)
		
		cEmissionScale ("cEmissionScale", Vector) = (1,1,1,1)
		[HDR]cVirtualLitColor ("cVirtualLitColor", Color) = (1, 0.72, 0.65, 0)
		cVirtualLitDir ("cVirtualLitDir", Vector) = (-0.5, 0.114 , 0.8576, 0.106)

		_ColorTransform0("ColorTransform0", Vector) = (0.897 ,0,	0,	0)
		_ColorTransform1("ColorTransform1", Vector) = (0.897 ,0,	0,	0)
		_ColorTransform2("ColorTransform2", Vector) = (0.897 ,0,	0,	0)

		_ColorTransform3("ColorTransform3", Vector) = (1, 0, 0, 0)
		_ColorTransform4("ColorTransform4", Vector) = (0, 1, 0, 0)
		_ColorTransform5("ColorTransform5", Vector) = (-0.001,-0.001,1,0)

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
				//User Data
				 // X : Sunlight Y：GI Z：VirtualLight				
				half3 userData1 = half3(0.5,0.5,0.5);

				// sample the texture
				fixed4 texBase = tex2Dbias (_MainTex, half4(i.uv.xy, 0, BaseMapBias));
				fixed4 texM = tex2D (_MixTex, i.uv.xy);				
				fixed4 texN = tex2Dbias (_NormalTex, half4(i.uv.xy, 0, NormalMapBias));
				half texMask = tex2D(_MaskMap, i.uv.xy);
				texN.y = 1 - texN.y;


				half mask = texMask.x;
				half AO = texM.z;

				//BaseColor 
                half SSSMask = 1 - texN.w;
				half3 BaseColor = texBase.rgb * texBase.rgb;

				BaseColor = ApplyColorTransform(BaseColor, SSSMask, mask);



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
				half3 SunColor = _LightColor0.rgb;

				half metallic = texM.y;//MixMap .y metalic
				half3 reflectDir = reflect(-viewDir,normalVec);
				fixed NdotV = clamp(dot(viewDir,normalVec),0,1);
				half NdotL = dot(normalVec,lightDir);

				//Apply Metallic
				half3 SpecularColor = lerp(0.04,BaseColor,metallic);
  				half3 DiffuseColor = (BaseColor - BaseColor * metallic) / 3.141593;



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
				GILighting.xyz = linearColor.xyz ;

				GILighting.w = AO;//MixMap .z ao

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
				float3 EnvBRDF = EnvBRDFApprox(SpecularColor, roughness, NdotV);
 				half3 EnvSpecular = GetIBLIrradiance(roughness, reflectDir) * EnvInfo.w * 10.0 * EnvBRDF;
				EnvSpecular = EnvSpecular * GILighting.w ;

				half3 sunSpec = Sun_Specular(lightDir, normalVec, viewDir, roughness, reflectDir, NdotV, NdotL, EnvBRDF);
				sunSpec = sunSpec * SunColor.xyz * saturate(NdotL * shadow);
				half3 Spec = EnvSpecular + sunSpec;

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
				float3 Color = Spec + VirtualSpecColor + diffLighting * DiffuseColor;

				//Apply Fog
				float VdotL = saturate(dot(-viewDir, lightDir));
				Color = ApplyFogColor(Color, i.worldPos.xyz, viewDir.xyz, VdotL, EnvInfo.z);

				//Liner to Gamma

				Color.xyz = Color.xyz / (Color.xyz * 0.9661836 + 0.180676);


				return half4 (Color.xyz, 1);
			}
			
			ENDCG
		}
		UsePass "MJH/Shadow/ShadowCaster"
	}
}
