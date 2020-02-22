Shader "GEffect/HSMYJ_Body"
{
	Properties
	{
		[Toggle (SSS_ENABLE)] sss_enable("sss_enable",float) = 0
		_MainTex ("Base", 2D) = "white" {}
		BaseMapBias ("BaseMapBias ", Range(-1,1)) = -1
		_MixTex ("Mix", 2D) = "white" {}
		_NormalTex ("Normal", 2D) = "normal" {}
		NormalMapBias ("NormalMapBias ", Range(-1,1)) = -0.5
		_SkinProfileTex ("SkinProfile", 2D) = "white" {}
		Curvature ("Curvature ", Range(0,1)) = 0.5
		_ReflectTex ("Reflect", 2D) = "black" {}
		Metallic ("Metallic", Range(0,1)) = 0
		AliasingFactor ("AliasingFactor", Range(0,1)) = 0.2
		EnvStrength ("EnvStrength", Range(0,2)) = 1
		ShadowColor ("AmbientColor", Color) = (0.7,0.7,0.7,0.5)
		//AmbientColor ("AmbientColor", Color) = (0,0,0,0)
		EnvInfo ("EnvInfo", Vector) = (0,100,1,0.3)
		Paramter ("Paramter", Vector) = (0,0,0,1)
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
			#pragma multi_compile __ SSS_ENABLE
			#pragma vertex vert
			#pragma fragment frag_main
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			#include "HSMYJ.cginc"
			ENDCG
		}
		Pass
		{
			Tags { "LIGHTMODE"="ForwardAdd"}
			Blend One One
			CGPROGRAM
			#pragma multi_compile_fwdadd
			#pragma multi_compile __ SSS_ENABLE
			#pragma vertex vert
			#pragma fragment frag_main_add
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			#include "HSMYJ.cginc"
			ENDCG
		}
	}
	FallBack "Diffuse"
}
