#version 300 es
uniform highp vec4 BloomParam;
uniform highp sampler2D BaseMapPoint_Sampler;
in highp vec4 xlv_TEXCOORD0;
in highp vec4 xlv_TEXCOORD1;
out highp vec4 SV_Target;
void main ()
{
highp vec4 sum_1;
sum_1 = (texture (BaseMapPoint_Sampler, xlv_TEXCOORD0.xy) + (2.0 * texture (BaseMapPoint_Sampler, xlv_TEXCOORD0.zw)));
sum_1 = (sum_1 + texture (BaseMapPoint_Sampler, xlv_TEXCOORD1.xy));
sum_1 = (sum_1 / 4.0);
sum_1.xyz = (sum_1.xyz * (max (0.0001,
dot (sum_1.xyz, vec3(0.34, 0.33, 0.33))
) * sum_1.xyz));
sum_1.xyz = max (((4.0 * sum_1.xyz) - BloomParam.x), 0.0);
highp vec4 tmpvar_2;
tmpvar_2.w = 1.0;
tmpvar_2.xyz = sqrt((sum_1.xyz / 4.0));
SV_Target = tmpvar_2;
}
 
 