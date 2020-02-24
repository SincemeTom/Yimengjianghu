Shader "GEffect/CLX_Water"
{
	Properties
	{
		_NormalTex ("Normal", 2D) = "normal" {}
		NormalMapBias ("NormalMapBias ", Range(-1,1)) = -0.5
		
		_ReflectTex ("Reflect", 2D) = "black" {}
		

		EnvStrength ("EnvStrength", Range(0,2)) = 1
		AmbientColor ("AmbientColor", Color) = (0.349351, 0.717623, 1, 1)
		cWaterColor("cWaterColor",Color) = (0.0008046586,0.001686915,0.001686915,1)
		EnvInfo ("EnvInfo", Vector) = (0,0.01,1,2.5)


		cMainWater ("cMainWater", Vector) = (60, 30, -6, 3)
		cSubWater ("cSubWater", Vector) = (120, 120 , -4, -2)
		cThirdWater ("cThirdWater", Vector) = (50, 50, -2, 4)
		cWaterMuddy("cWaterMuddy", Range(0,1)) = 0.3
		cSubWaterBump("cSubWaterBump", Range(-1,1)) = 0.13
		cDepthOffset("cDepthOffset", Range(0,1)) = 0.03300003
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



			sampler2D _NormalTex;
			sampler2D _ReflectTex;
			sampler2D _SkinProfileMapSampler;


			half4 EnvInfo;

			half Curvature;
			half4 AmbientColor;
			half4 cWaterColor;


			half EnvStrength;

			half NormalMapBias;
			half4 cMainWater;
			half4 cSubWater;
			half4 cThirdWater;
			float cVirtualColorScale;
			float cSkinCurvature;
			float cSubWaterBump;
			float cWaterMuddy;
			float cDepthOffset;

			
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
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy;
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
			
			half3 CalculateNormal(in half3 NormalTexture, in v2f i)
			{
				half3 normalTex = half3(NormalTexture.rgb * 2.0 - 1.0);
				half3 normalVec = i.world_tangent * normalTex.x + i.world_binormal * normalTex.y + i.world_normal * normalTex.z;
				half normalLen = sqrt(dot(normalVec,normalVec));
				return  normalVec / normalLen;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				
				half3 lightDir = normalize(_WorldSpaceLightPos0.www*(-i.worldPos) + _WorldSpaceLightPos0.xyz);
				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				half NdotV =  saturate(dot(i.world_normal.xyz, viewDir));
				half NdotL =  saturate(dot(i.world_normal.xyz, lightDir));
				
				
				float4 CameraPosVS = float4(-0.605874, 1.340176, 3.021125, 26.16459);
				CameraPosVS.w = length(_WorldSpaceCameraPos - i.worldPos);
				half2 time = fmod(_Time , 3).xx * 2;
				half2 MainWaterUV = i.uv * cMainWater.xy + CameraPosVS.w * cMainWater.zw * 0.01 * time.xy ;
				half2 SubWaterUV = i.uv * cSubWater.xy + CameraPosVS.w * cSubWater.zw * 0.01 * time.xy ;
				half2 ThirdWaterUV = i.uv * cThirdWater.xy + CameraPosVS.w * cThirdWater.zw * 0.01;

				half3 tangentNormal = half3(0,0,0);
				
				tangentNormal = tex2Dbias (_NormalTex, half4(MainWaterUV, 0, NormalMapBias)).xyz;
				
				tangentNormal += tex2Dbias (_NormalTex, half4(SubWaterUV, 0, NormalMapBias)).xyz;
				tangentNormal -=1.0;
				tangentNormal.xy *= cSubWaterBump;
				
				half3 normalVec = normalize(tangentNormal.xzy);

				half3 I = -viewDir;
				float3 R = reflect(-viewDir, normalVec);
				half isView = float(R.z > 0);
				R.xy = R.xy / (R.z *(isView * 2.0 - 1.0) + 1.0);

				R.xy =  R.xy * half2(0.25, -0.25) + 0.25 + 0.5 * isView;
				
				fixed4 srcColor = tex2Dlod (_ReflectTex, half4(R.xy, 0, 0));
				half3 EnvSpecular = srcColor.xyz * srcColor.w * srcColor.w * 16.0 * EnvStrength ;
				
				EnvSpecular = EnvSpecular * clamp (exp2(-15.0 * NdotV * NdotV) + 0.01, 0.0, 1.0) * EnvStrength * EnvInfo.w*10.0 * dot(AmbientColor , half3(0.3,0.59,0.11));

				half3 diffLighting = NdotL * _LightColor0.xyz + AmbientColor.xyz;
				half4 OutColor = half4(0,0,0,0);
				

				half temp28 = 1.0 - NdotV;
				EnvSpecular = EnvSpecular * clamp(1.04 -temp28 * temp28, 0.0, 1.0);

				half temp29 = dot(EnvSpecular , float3(0.3, 0.59, 0.11));

				half temp30 = clamp(temp29 * temp29, 0.0, 1.0);

				float PowerNdotV = pow(temp28, cWaterMuddy);

				float Alpha =  clamp (cDepthOffset + PowerNdotV + temp30, 0.0, 1.0);

				OutColor.w = Alpha;


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
				

				float3 Color = diffLighting * cWaterColor + EnvSpecular;

				//Color = Color * (1.0 - fog) + (Color.xyz * fog + fogColor) * fog;
				
				Color.xyz = Color.xyz / (Color.xyz * 0.9661836 + 0.180676);
				OutColor.xyz  = Color.xyz * Alpha;
				UNITY_APPLY_FOG(i.fogCoord, col);
				return OutColor;
			}
			
			ENDCG
		}
	}
}
