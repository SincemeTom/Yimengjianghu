#version 300 es
uniform mediump sampler2D SourceLinear0_Sampler;
in highp vec2 xlv_TEXCOORD0;
out highp vec4 SV_Target;
void main ()
{
highp vec4 tmpvar_1;
mediump vec4 tmpvar_2;
tmpvar_2 = texture (SourceLinear0_Sampler, xlv_TEXCOORD0);
tmpvar_1 = tmpvar_2;
SV_Target = tmpvar_1;
}
 
 