Shader "MJH/MJH_Standard"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _Metallic("Metallic", Range(0,1)) = 0
        _Roughness("Roughness", Range(0,1)) = 1
        _AO("Ambient Occulusion", Range(0,1)) = 1
        [Toggle (_BaseColorMapEnable)] _BaseColorMapEnable("BaseColorMap Enable",float) = 1       
        _MainTex ("Base Color, w channel (0.5 - 1.0) save Metallic", 2D) = "white" {}
        [Toggle (_NormalMapEnable)] _NormalMapEnable("NormalMap Enable",float) = 1
		_NormalMap("Normal, z for roughtness,w for ao", 2D) = "black" {}
        [Toggle (_LightMapEnable)] _LightMapEnable("LightMap Enable",float) = 1
		_LightMap("Light map", 2D) = "black"{}
		_EmissionMap("_Emission Map", 2D) = "black" {}
		_EnvMap("Env map", 2D) = "black" {}


        NormalMapBias("NormalMapBias", float) = -0.5

        Paramters("Paramters", Vector) = (0,0,0,1)
        LightmapScale("LightmapScale", Vector) = (0.92951, 0.01, 0, 0)
        LightmapUVTransform("LightmapUVTransform", Vector) = (0.499023, 0.499023, 0.000488281, 0.000488281)
        EnvInfo("Env Info", Vector) = (0,0.5,1,0.4)
        EnvStrength("Env Strength", Range(0,1)) = 1
        _ColorTransform0("ColorTransform0", Vector) = (1 ,0, 0,	0)
		_ColorTransform1("ColorTransform1", Vector) = (0 ,1, 0,	0)
		_ColorTransform2("ColorTransform2", Vector) = (0 ,0, 1,	0)

		_ColorTransform3("ColorTransform3", Vector) = (1, 0, 0, 0)
		_ColorTransform4("ColorTransform4", Vector) = (0, 1, 0, 0)
		_ColorTransform5("ColorTransform5", Vector) = (0, 0, 1, 0)

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
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile __ _BaseColorMapEnable
            #pragma multi_compile __ _NormalMapEnable
            #pragma multi_compile __ _LightMapEnable
            

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
            #include "MJH_Common.cginc"



			sampler2D _NormalMap;
			sampler2D _LightMap;

			sampler2D _ShadowMap;
			sampler2D _SecondShadow;
			sampler2D _EmissionMap;

            float _Roughness;
            float _Metallic;
            float _AO;
            float4 _BaseColor;

			//PS

			float4 ScreenColor;
			float4 ScreenInfoPS; //Screen

			float4 ShadowBias;// (0.00036, 0.036, 0.5, 0.0009765625)
			float4 Paramters; // (0,0,0,1 )

			float4 LightmapScale;// (0.92954, 0.01, 0, 0)
			float BaseMapBias; // (-1)
			float NormalMapBias;// (-0.5)




            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = tex2Dbias(_MainTex, float4(i.uv.xy, 0, BaseMapBias));
            


            #ifdef _BaseColorMapEnable
                half3 BaseColor = col.xyz * col.xyz * _BaseColor.xyz * _BaseColor.xyz;
                half Metallic = clamp(col.w * 2.0 - 1, 0, 1) * _Metallic;// BaseColor w channel (0.5 - 1.0) save Metallic
                half mask = col.w;
            #else
                half Metallic = _Metallic;
                half3 BaseColor = _BaseColor.xyz * _BaseColor.xyz;
                half mask = 1;
            #endif




                 //Rain
                half rain = EnvInfo.x;
                half raintmp = clamp(i.world_normal.y * 0.7 + 0.4 * rain, 0, 1);
                rain = 1 - rain * raintmp;

            #ifdef _NormalMapEnable
                half4 Normalmap = tex2Dbias(_NormalMap, float4(i.uv.xy, 0, NormalMapBias));
                half4 unpackNormal = MJH_UnpackNormal(Normalmap);
                float roughness = (rain - rain * Normalmap.z) * _Roughness; // NormalMap .z save roughness
                half SSSMask = 1 - Normalmap.w;
                half AO = _AO * Normalmap.w;
            #else
                half4 Normalmap = half4(0,0,1,1);
                half4 unpackNormal = half4(0,0,1,1);
                float roughness = _Roughness;
                 half SSSMask = 0;
                 half AO = _AO;
            #endif


               

                //Normal 
                float4 tangentNormal = float4(0,0,0,0);
                tangentNormal.xy = unpackNormal.xy * Paramters.w;
                half tangentNormalZ = sqrt(clamp(1 - (tangentNormal.x * tangentNormal.x + tangentNormal.y * tangentNormal.y) , 0, 1));
    			half3 normalVec = i.world_tangent * tangentNormal.x + i.world_binormal * tangentNormal.y + i.world_normal * tangentNormalZ;
                normalVec = normalize(normalVec);

                //Color
                BaseColor = ApplyColorTransform(BaseColor, SSSMask, mask);
                
                //Shadow:
                //实时阴影贴图绘制，主角单独绘制在1024的RT上，每帧都绘制；场景的阴影绘制在两张1024精度的RT上，隔帧绘制，ScreenSpaceShadow.
                half shadow = 1;
                float atten = LIGHT_ATTENUATION(i);	
				shadow = atten; 

                //Specular
                float3 SpecularColor = BaseColor * Metallic + 0.04;
                float3 DiffuseColor = (BaseColor - BaseColor * Metallic) / 3.141593;

                //Light & view
				half3 lightDir = normalize(_WorldSpaceLightPos0.www*(-i.worldPos) + _WorldSpaceLightPos0.xyz);
				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half3 I = -viewDir;

                half3 reflectDir = reflect(-viewDir,normalVec);
				half NdotV = clamp(dot(viewDir,normalVec),0,1);
                half3 SunColor = _LightColor0.rgb;
                half NdotL = dot(normalVec, lightDir);


				half ao = AO;

                half microshadow = shadow * clamp(abs(NdotL) + 2.0 * ao * ao - 1, 0.0, 1.0); // Normalmap.w AO
				shadow = microshadow;

                //GI :还原YMJH内置bakeLighting
                half4 GILighting = half4(0,0,0,AO);
                half4 LightMap = tex2D(_LightMap, i.uv.zw);
                
                half4 lightMapRaw = half4(0,0,0,0);
            #ifdef _LightMapEnable
                lightMapRaw.xyz = LightMap.xyz * LightmapScale.x + LightmapScale.y;
                lightMapRaw.w = LightMap.w;
                
            #else
                lightMapRaw = half4(0,0,0,1);
            #endif
                 
                half LogL = dot(lightMapRaw.xyz, half3(0.0955, 0.1878, 0.035)) + 7.5e-05;
                half Luma =  exp2(LogL * 50.27 - 8.373);
				half runtimeShadow = shadow;

                shadow = shadow * lightMapRaw.w * lightMapRaw.w;

            #ifdef _LightMapEnable
                GILighting.xyz = lightMapRaw.xyz;
                GILighting.w = AO * clamp(Luma, 0,1);
            #else
                GILighting.xyz = lightMapRaw.xyz;
                GILighting.w = AO;
            #endif


                half3 bakeLighting = lightMapRaw.xyz * (AO * Luma / LogL) + SunColor.xyz * clamp(NdotL * shadow, 0.0, 1.0);

                //Sun Specular
                half3 EnvBRDF = EnvBRDFApprox(SpecularColor, roughness, NdotV);

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

                float3 sunSpec = EnvBRDF * D;
                sunSpec = sunSpec * SunColor.xyz * clamp(NdotL * shadow, 0, 1);
                float3 SpecColor = EnvBRDF * EnvSpecular + sunSpec;                
                float3 DiffColor = bakeLighting * DiffuseColor;
                float3 OutColor = SpecColor + DiffColor;


				// _EmissionMap
				half3 EmissionMap =  tex2D(_EmissionMap, i.uv.xy).xyz;
				half3 EmissionColor = EmissionMap * EmissionMap;

				EmissionColor *= col.w;
				OutColor += EmissionColor;
                //AO :PC平台下，AO绘制在Forward之前，场景ScreenSpaceShadow之后，存在ScreenSpaceShadow纹理Y通道中
                float SSAO = 1.0;
                float a = clamp(SSAO + shadow * 0.5, 0.0, 1.0);//Blend AO;
                OutColor *= a;

                
                //Apply Fog
				float VdotL = saturate(dot(-viewDir, lightDir));
				OutColor = ApplyFogColor(OutColor, i.worldPos.xyz, viewDir.xyz, VdotL, EnvInfo.z);

                //Linear to Gamma
				OutColor.xyz = OutColor.xyz / (OutColor.xyz * 0.9661836 + 0.180676);

				
                return half4(OutColor.xyz , col.a);
            }
            ENDCG
        }
        UsePass "MJH/Shadow/ShadowCaster"
    }
}
