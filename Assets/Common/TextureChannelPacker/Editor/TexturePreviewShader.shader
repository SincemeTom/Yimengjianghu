Shader "GEffect/TextureViewShader"
{
	Properties
	{
		_RTex ("_RTex", 2D) = "black" {}
		_GTex ("_GTex", 2D) = "black" {}
		_BTex ("_BTex", 2D) = "black" {}
		_ATex ("_ATex", 2D) = "black" {}
		_Tex ("_Tex", 2D) = "black" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Name "Combine"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			sampler2D _RTex;
			sampler2D _GTex;
			sampler2D _BTex;
			sampler2D _ATex;
			half4 Mask_R;
			half4 Mask_G;
			half4 Mask_B;
			half4 Mask_A;
			half4 Ref_RGBA;
			
			#include "UnityCG.cginc"
			float4 _RTex_ST;
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _RTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			half4 frag (v2f i) : SV_Target
			{
				// sample the texture
				half4 colR = tex2D(_RTex, i.uv);
				half4 colG = tex2D(_GTex, i.uv);
				half4 colB = tex2D(_BTex, i.uv);
				half4 colA = tex2D(_ATex, i.uv);
				half4 col;
				col.r = Ref_RGBA.r + dot(colR,Mask_R);
				col.g = Ref_RGBA.g + dot(colG,Mask_G);
				col.b = Ref_RGBA.b + dot(colB,Mask_B);
				col.a = Ref_RGBA.a + dot(colA,Mask_A);
				return col;
			}
			ENDCG
		}
		Pass
		{
			Name "Preview"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ _SINGLE_CHANNEL
			sampler2D _Tex;
			float4 _Tex_ST;
			half4 Mask;
			half4 Ref;
			
			#include "UnityCG.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _Tex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				// sample the texture
				half4 col = tex2D(_Tex, i.uv);
				half4 color;
			#if _SINGLE_CHANNEL
				color.rgb = dot(Mask,Ref) + dot(col,Mask);
				color.a = 1;
			#else
				color = Ref + col * Mask;
			#endif
				return color;
			}
			ENDCG
		}
	}
}
