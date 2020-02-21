Shader "MJH/MJH_Standard"
{
    Properties
    {
        _MainTex ("Base Color", 2D) = "white" {}
		_NormalMap("Normal", 2D) = "white" {}
		_LightMap("Light map", 2D) = "white" {}
		_EmissionMap("_Emission Map", 2D) = "black" {}
		_EnvMap("Env map", 2D) = "white" {}


        NormalMapBias("NormalMapBias", float) = -0.5

        Paramters("MJH_UnpackNormal", Vector) = (0,0,0,1)
        LightmapScale("LightmapScale", Vector) = (0.92951, 0.01, 0, 0)
        LightmapUVTransform("LightmapUVTransform", Vector) = (0.499023, 0.499023, 0.000488281, 0.000488281)
        EnvInfo("Env Info", Vector) = (0,0.5,1,0.4)
        EnvStrength("Env Strength", Range(0,1)) = 1

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
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
                //float4 binormal : BINORMAL;

                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };


            struct v2f
            {
                float4 uv : TEXCOORD0; //(uv.xy ,ux,zw)
				float4 worldPos   : TEXCOORD1;
				half4 world_normal  : TEXCOORD2;
				half4 world_tangent : TEXCOORD3;
				half4 world_binormal : TEXCOORD4;

				half4 texcoord1 : TEXCOORD5;//EnvInfo

                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;

			sampler2D _NormalMap;
			sampler2D _LightMap;
			sampler2D _EnvMap;
			sampler2D _ShadowMap;
			sampler2D _SecondShadow;
			sampler2D _EmissionMap;

			//VS
			float4 LightmapUVTransform; //0.499023, 0.499023, 0.000488281 0.000488281
            float4 FogInfo;
			//PS
			float4 EnvInfo; // (0,0.5,1,0.4)
			float4 SunColor; // (15, 11.32279, 6.843958, 0)
			float4 SunDirection; // ( -0.12117, 0.716302, 0.6871893, 1)
			float4 FogColor; // (0.2590002, 0.3290003, 0.623, 1.102886) 
			float4 ScreenColor;
			float4 ScreenInfoPS; //Screen
			float4 FogColor2; //(0,0,0,0.7713518)
			float4 FogColor3; //(0.5, 0.35, 0.09500044, 0.6937419 )
			float4 ShadowBias;// (0.00036, 0.036, 0.5, 0.0009765625)
			float4 Paramters; // (0,0,0,1 )
			float EnvStrength; // 1
			float4 LightmapScale;// (0.92954, 0.01, 0, 0)
			float BaseMapBias; // (-1)
			float NormalMapBias;// (-0.5)
			float4 ColorTransform0;// 
			float4 ColorTransform1;
			float4 ColorTransform2;
			float GrayPencent; // 1
			float4 ColorTransform3;
			float4 ColorTransform4;
			float4 ColorTransform5;

            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord0.xy, _MainTex);
                o.uv.zw = v.texcoord1.xy * LightmapUVTransform .xy + LightmapUVTransform.zw;
                float4 worldPos = mul( unity_ObjectToWorld, v.vertex );
                o.worldPos = worldPos;
				float3 normal  = v.normal;
				half3 wNormal = UnityObjectToWorldNormal(normal);  
				half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;  
				half3 wBinormal = cross(wNormal, wTangent) * tangentSign;  
								
				o.world_normal.xyz = wNormal;
				o.world_tangent.xyz = wTangent; 
				o.world_binormal.xyz = wBinormal;
                o.texcoord1.xyz =  normalize(UnityObjectToWorldNormal(normal));//world space normal,MeshConverter.HSMYJ (normal * 2 - 1)
                o.texcoord1.w = 0;//fog

                float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				float fogTmp = clamp ((worldPos.y * FogInfo.z + FogInfo.w), 0.0, 1.0);
				float fHeightCoef = fogTmp * fogTmp;
				fHeightCoef*=fHeightCoef;
				float fog = 1.0 - exp(-max (0.0, viewDir - FogInfo.x)* max (FogInfo.y * fHeightCoef, 0.1 * FogInfo.y));
				fog *= fog;
                o.texcoord1.w = fog;

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

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = tex2Dbias(_MainTex, float4(i.uv.xy, 0, BaseMapBias));
                half3 BaseColor = col.xyz * col.xyz;
                half mask = col.w;
                half Metallic = clamp(col.w * 2.0 - 1, 0, 1);// BaseColor w channel (0.5 - 1.0) save Metallic

                half4 Normalmap = tex2Dbias(_NormalMap, float4(i.uv.xy, 0, NormalMapBias));
                half4 unpackNormal = MJH_UnpackNormal(Normalmap);

                half SSSMask = 1 - Normalmap.w;

                //Rain
                half rain = EnvInfo.x;
                half raintmp = clamp(i.world_normal.y * 0.7 + 0.4 * rain, 0, 1);
                rain = 1 - rain * raintmp;

                float roughness = rain - rain * Normalmap.z; // NormalMap .z save roughness

                //Normal 
                float4 tangentNormal = float4(0,0,0,0);
                tangentNormal.xy = unpackNormal.xy * Paramters.w;
                half tangentNormalZ = sqrt(clamp(1 - (tangentNormal.x * tangentNormal.x + tangentNormal.y * tangentNormal.y) , 0, 1));
    			half3 normalVec = i.world_tangent * tangentNormal.x + i.world_binormal * tangentNormal.y + i.world_normal * tangentNormalZ;
                normalVec = normalize(normalVec);

                //Color
                //BaseColor = BaseColor * (1.0 - mask) + BaseColor * mask; // BaseColor * (1.0 - mask) + (BaseColor * M3x3(ColorTransform0,ColorTransform1,ColorTransform2)) * mask;
                //BaseColor = BaseColor * (1.0 - SSSMask) + BaseColor * SSSMask; //BaseColor * (1.0 - SSSMask) + (BaseColor * M3x3(ColorTransform3,ColorTransform4,ColorTransform5)) * SSSMask;
                
                //Shadow:
                //实时阴影贴图绘制，主角单独绘制在1024的RT上，每帧都绘制；场景的阴影绘制在两张1024精度的RT上，隔帧绘制，ScreenSpaceShadow.

                //Specular
                float3 SpecularColor = BaseColor * Metallic + 0.04;
                float3 DiffuseColor = (BaseColor - BaseColor * Metallic) / 3.141593;

                //Light & view
				half3 lightDir = normalize(_WorldSpaceLightPos0.www*(-i.worldPos) + _WorldSpaceLightPos0.xyz);
				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half3 I = -viewDir;

                half3 reflectDir = reflect(viewDir,normalVec);
				half NdotV = clamp(dot(viewDir,normalVec),0,1);
                half3 SunColor = _LightColor0.rgb;
                half NdotL = dot(normalVec, lightDir);

                half shadow = 1;/// Final Shadow
                shadow = shadow * clamp(abs(NdotL) + 2.0 * Normalmap.w * Normalmap.w, 0.0, 1.0); // Normalmap.w AO
                
                //GI :还原YMJH内置bakeLighting
                half4 GILighting = half4(0,0,0,Normalmap.w);
                half4 LightMap = tex2D(_LightMap, i.uv.zw);
                half4 lightMapRaw = half4(0,0,0,0);
                lightMapRaw.xyz = LightMap.xyz * LightmapScale.x + LightmapScale.y;
                lightMapRaw.w = LightMap.w;
                half lightmapTmp0 = dot(lightMapRaw.xyz, half3(0.0955, 0.1878, 0.035)) + 7.5e-05;
                half lightmapTmp1 =  exp2(lightmapTmp0 * 50.27 - 8.373);
				half runtimeShadow = shadow;
                shadow = shadow * LightMap.w * LightMap.w;

                GILighting.w = Normalmap.w * clamp(lightmapTmp1, 0,1);
                half3 bakeLighting = lightMapRaw.xyz * (Normalmap.w * lightmapTmp1 / lightmapTmp0) + SunColor.xyz * clamp(NdotL * shadow, 0.0, 1.0);

                //Sun Specular
                half3 ReflectColor = EnvBRDFApprox(SpecularColor, roughness, NdotV);

                float3 Reflect = viewDir - 2.0 * dot(normalVec , viewDir) * normalVec;
				half lod = roughness / 0.17;
				half fSign = half(reflectDir.z > 0);
				half temp =  fSign * 2.0 - 1.0;
				half2 reflectuv = reflectDir.xy / (reflectDir.z * temp + 1.0);
				reflectuv = reflectuv * half2(0.25, -0.25) + 0.25 + 0.5 * fSign;
				
				fixed4 srcColor = tex2Dlod (_EnvMap, half4(reflectuv.xy, 0, 0));

                half3 EnvSpecular = srcColor.xyz * srcColor.w * srcColor.w * 16.0 * EnvStrength ;
				EnvSpecular = EnvSpecular * GILighting.w * EnvInfo.w * 10.0;

                fixed3 H = normalize(viewDir + lightDir);
				fixed VdotH = clamp(dot(viewDir,H),0,1);
				fixed NdotH = clamp(dot(normalVec,H),0,1);
                float m = roughness * roughness + 0.0002;
                float m2 = m *m;

                float DTmp = (NdotH * m2 - NdotH) * NdotH + 1.0;
                float D = DTmp * DTmp + 1e-06;
                D = 0.25 * m2 / D;

                float3 sunSpec = ReflectColor * D;
                sunSpec = sunSpec * SunColor.xyz * clamp(NdotL * shadow, 0, 1);
                float3 SpecColor = ReflectColor * EnvSpecular + sunSpec;                
                float3 DiffColor = bakeLighting * DiffuseColor;
                float3 OutColor = SpecColor + DiffColor;


				// _EmissionMap
				half3 EmissionMap =  tex2D(_EmissionMap, i.uv.xy).xyz;
				half3 EmissionColor = EmissionMap * EmissionMap;

				EmissionColor *= col.w;
				OutColor += EmissionColor;
                //AO :PC平台下，AO绘制在Forward之前，场景ScreenSpaceShadow之后，存在ScreenSpaceShadow纹理Y通道中
                float AO = 1.0;
                float a = clamp(AO + shadow * 0.5, 0.0, 1.0);//Blend AO;
                OutColor *= a;

                // apply fog
                float fog = i.texcoord1.w;
                half3 fogColor = (FogColor2.xyz * clamp (viewDir.y * 5.0 + 1.0, 0.0, 1.0)) + FogColor.xyz;
				half VdotL =  clamp (dot (-viewDir, lightDir), 0.0, 1.0);
				fogColor =   fogColor + (FogColor3 * VdotL  * VdotL).xyz;

                OutColor = OutColor * (1.0 - fog) + (OutColor.xyz * (1 - fog) + fogColor) * fog;
				OutColor = OutColor * EnvInfo.z;
                OutColor *= FogColor.w * FogColor2.w * FogColor3.w;


                //Linear to Gamma
				OutColor.xyz = OutColor.xyz / (OutColor.xyz * 0.9661836 + 0.180676);

				
                return half4(LightMap.www , col.a);
            }
            ENDCG
        }
    }
}
