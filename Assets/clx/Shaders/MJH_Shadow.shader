Shader "MJH/Shadow"
{
	Properties
	{

	}
	SubShader
	{
		Tags{ "LightMode" = "ShadowCaster" }

		Pass
		{
			Tags{ "LightMode" = "ShadowCaster" }
			Name "ShadowCaster"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 pos:SV_POSITION;
			};

			v2f vert(appdata_full v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag(v2f o) :SV_Target
			{
				SHADOW_CASTER_FRAGMENT(o)
			}

			ENDCG
		}
	}
	//FallBack "Diffuse"
}
