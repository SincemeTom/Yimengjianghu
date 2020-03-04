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
				float4 vec:TEXCOORD0;
			};

			v2f vert(appdata_full v) 
			{
				v2f o;
				float4 opos;
				TRANSFER_SHADOW_CASTER_NOPOS(o,opos)
				o.pos = opos;
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
