Shader "GEffect/CLX_Shadow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "QUEUE"="Geometry+100" }
		LOD 100

		Pass
		{
			Name "FORWARD"
			Tags { "LIGHTMODE"="ForwardBase"}
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				LIGHTING_COORDS(2,3)
				float4 worldPos   : TEXCOORD4;
				float4 pos : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.worldPos = mul( unity_ObjectToWorld, v.vertex );
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float atten = LIGHT_ATTENUATION(i);
				half4 col = half4(0.03,0.08,0.15,saturate((0.5 - atten)*1.7));
				return half4(col.xyz, col.w);
			}
			ENDCG
		}
	}
	//FallBack "Diffuse"
}
