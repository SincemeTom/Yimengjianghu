Shader "MJH/MJH_Standard"
{
    Properties
    {
        _MainTex ("Base Color", 2D) = "white" {}
		_NormalMap("Normal", 2D) = "white" {}
		_LightMap("Light map", 2D) = "white" {}
		_EnvMap("Env map", 2D) = "white" {}

        NormalMapBias("NormalMapBias", float) = -0.5

        Paramters("MJH_UnpackNormal", Vector) = (0,0,0,1)
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
                float2 texcoord1 : TEXCOORD0;
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


			//VS
			float4 LightmapUVTransform; //0.499023, 0.499023, 0.000488281 0.000488281

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

                o.worldPos = mul( unity_ObjectToWorld, v.vertex );
				float3 normal  = v.normal;
				half3 wNormal = UnityObjectToWorldNormal(normal);  
				half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;  
				half3 wBinormal = cross(wNormal, wTangent) * tangentSign;  
								
				o.world_normal.xyz = wNormal;
				o.world_tangent.xyz = wTangent; 
				o.world_binormal.xyz = wBinormal;
                o.texcoord1.xyz =  normalize(UnityObjectToWorldNormal(normal));//world space normal,MeshConverter.HSMYJ (normal * 2 - 1)
                o.texcoord1.w = 0;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }


            half4 MJH_UnpackNormal(in float4 normal)
            {
                return half4(normal.xy * 2.0 - 1.0, normal.zw);
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

                float normalBias = rain - rain * Normalmap.z;

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
                //实时阴影贴图绘制，主角单独绘制在1024的RT上，每帧都绘制；场景的阴影绘制在一张2048精度的RT上，隔帧绘制，然后场景是ScreenSpaceShadow.

                //Specular
                float3 SpecularColor = BaseColor * Metallic + 0.04;
                float3 DiffuseColor = (BaseColor - BaseColor * Metallic) / 3.141593;

                //Light & view
				half3 lightDir = normalize(_WorldSpaceLightPos0.www*(-i.worldPos) + _WorldSpaceLightPos0.xyz);
				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half3 SunColor = _LightColor0.rgb;
                half NdotL = dot(normalVec, lightDir);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return half4(DiffuseColor.xyz * NdotL * SunColor, col.a);
            }
            ENDCG
        }
    }
}
