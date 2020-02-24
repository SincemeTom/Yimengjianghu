Shader "GEffect/CLX_Character_Hair_Opaque"
{
	Properties
	{
		[Toggle (PointCloudEnable)] PointCloudEnable("PointCloudEnable",float) = 0
		_MainTex ("Base", 2D) = "white" {}
		BaseMapBias ("BaseMapBias ", Range(-1,1)) = -1
		_MixTex ("Mix", 2D) = "white" {}
		_NormalTex ("Normal", 2D) = "normal" {}
		NormalMapBias ("NormalMapBias ", Range(-1,1)) = -0.5
		Curvature ("Curvature ", Range(0,1)) = 0.5
		_ReflectTex ("Reflect", 2D) = "black" {}
		_SkinProfileMapSampler("SkinProfileMapSampler", 2D) = "black" {}
		cSkinCurvature("cSkinCurvature", Range(0,1)) = 0.5
		Metallic ("Metallic", Range(0,1)) = 0
		AliasingFactor ("AliasingFactor", Range(0,1)) = 0.2
		EnvStrength ("EnvStrength", Range(0,2)) = 1
		ShadowColor ("ShadowColor", Vector) = (0.1122132,0.3493512,0.00003981071,0.5)

		EnvInfo ("EnvInfo", Vector) = (0,0.01,1,2.5)

		cEmissionScale ("cEmissionScale", Vector) = (1,1,1,1)
		cVirtualLitColor ("cVirtualLitColor", Color) = (1, 0.72, 0.65, 0)
		cVirtualLitDir ("cVirtualLitDir", Vector) = (-0.5, 0.114 , 0.8576, 0.106)
		cVirtualColorScale ("VirtualColorScale", Range(0,10)) = 4
		cRoughnessX("cRoughnessX", Range(0,1)) = 0.1
		cRoughnessY("cRoughnessY", Range(0,1)) = 1
		cAnisotropicScale("cAnisotropicScale", Range(0,10)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque"  }
		LOD 100

		Pass
		{
			Tags { "LIGHTMODE"="ForwardBase"}
			//Name "depth"
			//ColorMask off
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
			sampler2D _SkinProfileMapSampler;
			float4 _MainTex_ST;

			half4 EnvInfo;
			half Metallic;
			half Curvature;

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
			float cRoughnessX;
			float cRoughnessY;
			float cAnisotropicScale;

			
			int3 lessThan(float3 a, float3 b)
			{
				int3 r = int3(1,1,1);
				r.x = a.x < b.x ? 0 : 1;
				r.y = a.y < b.y ? 0 : 1;
				r.z = a.z < b.z ? 0 : 1;
				return r;
			}
			v2f vert (appdata v)
			{
				v2f o = (v2f)0;
				float4 pos = UnityObjectToClipPos(v.vertex);
				//pos.z = pos.z * 2 - pos.w;
				o.pos = pos;
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
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 cPointCloudm[6] = 
				{
					float4 (0.1408782,	0.3330483,	0.577573,	0.9036196),
					float4 (0.1291504,	0.1995587,	0.4305936,	0.9036196),
					float4 (0.1134923,	0.201387,	0.4179451,	0.9036196),
					float4 (0.07244644,	0.1162795,	0.211704,	0.9036196),
					float4 (0.1901786,	0.3295815,	0.6168326,	0.9036196),
					float4 (0.1106259,	0.1672236,	0.3718346,	0.9036196)
				};
				fixed4 texBase = tex2Dbias (_MainTex, half4(i.uv, 0, BaseMapBias));
				fixed4 texM = tex2D (_MixTex, i.uv);
				fixed4 texN = tex2Dbias (_NormalTex, half4(i.uv, 0, NormalMapBias));
				

				half rr = EnvInfo.x * 0.5;
				float tem40 = clamp (3.0 * i.world_normal.y + 0.2 + 0.1 * rr, 0.0, 1.0);
				float Alpha = texM.y * cSkinCurvature + 1.0;

				
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
				half Roughness_X = roughness * cRoughnessX + (1e-06);
				half Roughness_Y = roughness * cRoughnessY + (1e-06);

				
				half3 lightDir = normalize(_WorldSpaceLightPos0.www*(-i.worldPos) + _WorldSpaceLightPos0.xyz);
				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				half NdotL = max(0.001, dot(normalVec,lightDir));
				half shadow = clamp (abs(NdotL) + 2.0 * texM.z * texM.z - 1.0, 0.0, 1.0);

				half3 inputRadiance = (_LightColor0 * NdotL * 0.9036196 * ShadowColor.y).xyz;
				half4 linearColor = half4(0,0,0,0);
				#ifdef PointCloudEnable
				

				
				half3 nSquared = normalVec * normalVec;
				int3 isNegative = int3(lessThan(normalVec, float3(0.0,0.0,0.0)));
				//half4 linearColor = (((nSquared.x * cPointCloud[tmpvar_35.x]) + (nSquared_33.y * cPointCloud[(tmpvar_35.y + 2)])) + (nSquared_33.z * cPointCloud[(tmpvar_35.z + 4)]));
				linearColor += nSquared.x * cPointCloudm[isNegative.x] + nSquared.y * cPointCloudm[isNegative.y + 2] + nSquared.z * cPointCloudm[isNegative.z + 4];
				//linearColor.xyz+=gi.indirect.diffuse;
				//linearColor.xyz *= 3.0;
				//linearColor.xyz = gi.indirect.diffuse;
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


				
				
				half3 reflectDir = reflect(viewDir,normalVec);
				fixed NdotV = clamp(dot(viewDir,normalVec),0,1);

				
				
				//half NdotL = dot(normalVec,lightDir);
				//half shadow = clamp (abs(NdotL) + 2.0 * texM.z * texM.z - 1.0, 0.0, 1.0);

				#ifdef PointCloudEnable
				shadow = shadow * cPointCloudm[0].w * ShadowColor.y;
				#else
				shadow = shadow * 1 * ShadowColor.y;
				#endif

				

				half metalic = texM.y;
				half3 SpecularColor = lerp(0.04,BaseColor,metalic);
  				half3 DiffuseColor = (BaseColor - BaseColor * metalic) / 3.141593;

					
				float atten = LIGHT_ATTENUATION(i);	

				half3 diffLight = half3(0,0,0);
				half3 diffLighting =  diffLight + GILighting.xyz * texM.z;
				GILighting.w = texM.y * dot(diffLighting,half3(0.3,0.59,0.11));
				half3 SunColor = half3(0,0,0);
				SunColor = _LightColor0.rgb;
				half3 SunLighting = clamp (NdotL * shadow, 0,1) * SunColor.xyz;
				diffLighting = diffLighting + SunLighting;


				half4 r = roughness * float4(-1.0, -0.0275, -0.572, 0.022) + float4(1.0, 0.0425, 1.04, -0.04); 
				half2 ab = half2(-1.04, 1.04) * (min (r.x * r.x, exp2(-9.28 * NdotV)) * r.x + r.y) + r.zw;
				float3 EnvBRDF = SpecularColor * ab.x + ab.y;

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

				half HdotT = dot(H, normalize(i.world_tangent));
				half HdotB = dot(H, normalize(i.world_binormal));
				half2 beta = half2(HdotT / Roughness_X, HdotB / Roughness_Y);
				beta *= beta;

				half s_den = max (0.1, 31.1593 * Roughness_X * Roughness_Y * sqrt(NdotL * NdotV));
				float aniso = cAnisotropicScale * exp(-2.0 * (beta.x + beta.y) / (1 +  NdotH)) / s_den;
				
				half4 Emission = half4(0,0,0,0);
				Emission.w = cEmissionScale.w;
				Emission.xyz = inputRadiance * aniso;
  				Emission.xyz = Emission.xyz * (texM.z * texBase.w);
  				Emission.xyz = min (Emission.xyz, 10.0);

				
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


				cVirtualLitColor *= cVirtualColorScale;
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
				

				float3 Color = Spec + VirtualSpec + diffLighting * DiffuseColor + Emission.xyz;

				Color = Color * EnvInfo.z;
				Color = clamp(Color.xyz, float3(0.0, 0.0, 0.0), float3(4.0, 4.0, 4.0));
				Color = Color * (1.0 - fog) + (Color.xyz * fog + fogColor) * fog;
				Color.xyz = Color.xyz / (Color.xyz * 0.9661836 + 0.180676);

				//Color = half3(0,0,0);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return half4 (aniso.xxx,texBase.a);
			}
			
			ENDCG
		}
		Pass
		{
			Name "FORWARD_DELTA"
			Tags {"LIGHTMODE"="ForwardAdd" "QUEUE"="Geometry" "SHADOWSUPPORT"="true" "RenderType"="Qpaque"}
			Blend SrcAlpha One
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
			struct appdata 
			{
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
			float4 _MainTex_ST;

			half4 EnvInfo;
			half Metallic;
			half Curvature;

			half4 ShadowColor;

			half AliasingFactor;
			half EnvStrength;
			half BaseMapBias;
			half NormalMapBias;
			half4 cVirtualLitDir;
			half4 cVirtualLitColor;
			half4 cEmissionScale;
			float cVirtualColorScale;


			int3 lessThan(float3 a, float3 b)
			{
				int3 r = int3(1,1,1);
				r.x = a.x < b.x ? 0 : 1;
				r.y = a.y < b.y ? 0 : 1;
				r.z = a.z < b.z ? 0 : 1;
				return r;
			}
			half3 LightingPS_SPEC(in float3 worldPos, in float3 N, in float3 V, in half NoV, in half3 SpecularColor, in half Roughness,in half4 LightDir,in half4 LightColor, in float LightAtten, inout half3 DiffLit)
			{
				float3 L = LightDir.xyz;
				float NoL = saturate(dot(N, L));

				DiffLit += LightColor.rgb * NoL * LightAtten;
				{
					float m2 = Roughness * Roughness + 0.0002;
					m2 *= m2;
					float3 H = normalize(V + L);
					float NoH = saturate(dot(N, H));
					float D = (NoH*m2 - NoH) * NoH + 1;
					D = D * D + (1e-06);
					D = 0.25 * m2 / D;
					return LightColor.rgb * SpecularColor * LightAtten * NoL * D;
				}
			}
			v2f vert(appdata v)
			{
				v2f o = (v2f)0;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				float3 normal = v.normal/* * 2.0 - 1*/;
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

			fixed4 frag(v2f i) : SV_Target
			{


				fixed4 texBase = tex2Dbias(_MainTex, half4(i.uv, 0, BaseMapBias));
				fixed4 texM = tex2D(_MixTex, i.uv);
				fixed4 texN = tex2Dbias(_NormalTex, half4(i.uv, 0, NormalMapBias));

				half3 BaseColor = texBase.rgb * texBase.rgb;

				float rain = EnvInfo.x * 0.5;
				half tem0 = clamp(3.0 * i.world_normal.y + 0.2 + 0.1 * rain, 0.0, 1.0);
				rain = (1.0 - (rain * tem0));
				rain = clamp((rain - (rain * texM.x)), 0.05, 1.0);

				half3 normalTex = half3(texN.rgb * 2.0 - 1.0);
				half3 normalVec = i.world_tangent * normalTex.x + i.world_binormal * normalTex.y + i.world_normal * normalTex.z;
				half normalLen = sqrt(dot(normalVec,normalVec));
				normalVec /= normalLen;

				half roughness = clamp(rain + min(0.4,AliasingFactor * 10.0 * clamp(1.0 - normalLen, 0.0, 1.0)), 0.0, 1.0);

				half3 lightDir = normalize(_WorldSpaceLightPos0.www*(-i.worldPos) + _WorldSpaceLightPos0.xyz);
				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				half metalic = texM.y;
				half3 SpecularColor = lerp(0.04,BaseColor,metalic);
				half3 DiffuseColor = (BaseColor - BaseColor * metalic) / 3.141593;

				fixed NdotV = clamp(dot(viewDir,normalVec),0,1);

				half NdotL = dot(normalVec,lightDir);

				float atten = LIGHT_ATTENUATION(i);

				half3 diffLight;
				half3 diffLighting; 
				
				diffLighting = half3 (0,0,0);
				half4 PointLightDir = half4(lightDir, 2.333);
				half4 PointLightColor = half4(_LightColor0.rgb, -3.3333);
				half3 Spec = LightingPS_SPEC(i.worldPos, normalVec, viewDir, NdotV, SpecularColor,roughness, PointLightDir, PointLightColor, atten , diffLighting );

				

				half4 FogInfo = half4(30, 0.0326,0.00672, 31.05);
				float temp31 = clamp((i.worldPos.y * FogInfo.z + FogInfo.w), 0.0, 1.0);
				float fHeightCoef = temp31 * temp31;
				fHeightCoef *= fHeightCoef;
				float fog = 1.0 - exp(-max(0.0, viewDir - FogInfo.x)* max(FogInfo.y * fHeightCoef, 0.1 * FogInfo.y));
				fog *= fog;


				half4 FogColor = half4(0.224,0.2949,0.54588,0.36);
				half4 FogColor2 = half4(0,0,0,0.36);
				half4 FogColor3 = half4(4,1.45,0,0.36);

				half3 fogColor = (FogColor2.xyz * clamp(viewDir.y * 5.0 + 1.0, 0.0, 1.0)) + FogColor.xyz;
				half VdotL = clamp(dot(-viewDir, lightDir), 0.0, 1.0);
				fogColor = fogColor + (FogColor3 * VdotL  * VdotL).xyz;


				float3 Color = Spec  + diffLighting * DiffuseColor;

				Color = Color * (1.0 - fog) + (Color.xyz * fog + fogColor) * fog;
				Color = Color * EnvInfo.z;
				Color = clamp(Color.xyz, float3(0.0, 0.0, 0.0), float3(4.0, 4.0, 4.0));
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return half4 (Color, 1);
			}
			
			
			ENDCG
		}
	}
}
