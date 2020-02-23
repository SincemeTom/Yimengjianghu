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
		_ReflectTex ("Reflect", 2D) = "black" {}


		AliasingFactor ("AliasingFactor", Range(0,1)) = 0.2
		EnvStrength ("EnvStrength", Range(0,2)) = 1
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
			sampler2D _MaskMap;
			float4 _MainTex_ST;

			half4 EnvInfo;
			
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
			
			float4 ColorScale;
			float4 ColorBias;
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

				// sample the texture
				fixed4 texBase = tex2Dbias (_MainTex, half4(i.uv, 0, BaseMapBias));
				fixed4 texN = tex2Dbias (_NormalTex, half4(i.uv, 0, NormalMapBias));
                half4 unpackNormal = MJH_UnpackNormal(texN);
				half texMask = tex2D(_MaskMap, i.uv);
				half mask = texMask.x;
				fixed4 texM = tex2D (_MixTex, i.uv);

				//Color 
                half SSSMask = 1 - unpackNormal.w;
				half3 BaseColor = texBase.rgb * texBase.rgb;
				half3 baseColorData = BaseColor;
				half3 scaleBaseColor = baseColorData * ColorScale.xyz;//Color Transform0,1,2
				BaseColor = BaseColor * (1.0 - mask) + clamp(scaleBaseColor, 0, 1) * mask;
				half3 biasColor = baseColorData + ColorBias.xyz;//Color Transform 3,4,5
				BaseColor = BaseColor * (1 - SSSMask) + clamp(biasColor, 0, 1) * SSSMask;

				//Normal
				half3 normalTex = half3(texN.rgb * 2.0 - 1.0);
				half3 normalVec = i.world_tangent * normalTex.x + i.world_binormal * normalTex.y + i.world_normal * normalTex.z;
				half normalLen = sqrt(dot(normalVec,normalVec));
				normalVec /= normalLen;

				//Rain
				float rain = EnvInfo.x * 0.5;
				half tem0 = clamp (3.0 * i.world_normal.y + 0.2 + 0.1 * rain, 0.0, 1.0);
				rain = 1.0 - rain * tem0;
				half roughness = clamp (rain - rain * texM.x, 0.05, 1.0);
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
				half3 SpecularColor = lerp(0.04,BaseColor,metalic);
  				half3 DiffuseColor = (BaseColor - BaseColor * metalic) / 3.141593;

				half3 reflectDir = reflect(viewDir,normalVec);
				fixed NdotV = clamp(dot(viewDir,normalVec),0,1);

				half NdotL = dot(normalVec,lightDir);
				//
				half shadow = clamp (abs(NdotL) + 2.0 * texM.z * texM.z - 1.0, 0.0, 1.0);


				
				float atten = LIGHT_ATTENUATION(i);	

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
				
				fixed4 srcColor = tex2Dlod (_ReflectTex, half4(reflectuv.xy, 0, 0));
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

				//Color = half3(0,0,0);
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return half4 (Color.xyz, texBase.w);
			}
			
			ENDCG
		}
			
	}
}
