#version 300 es
uniform highp sampler2D SourcePoint0_Sampler;
in highp vec2 xlv_TEXCOORD0;
out highp vec4 SV_Target;
void main ()
{
SV_Target = texture (SourcePoint0_Sampler, xlv_TEXCOORD0);
}
 
 