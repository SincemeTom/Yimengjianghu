#version 300 es
in highp vec4 POSITION;
in highp vec2 TEXCOORD0;
out highp vec2 xlv_TEXCOORD0;
void main ()
{
highp vec3 vPos_1;
vPos_1.xz = POSITION.xz;
vPos_1.y = (1.0 - POSITION.y);
highp vec4 tmpvar_2;
tmpvar_2.w = 1.0;
tmpvar_2.xy = ((vPos_1.xy * 2.0) - 1.0);
tmpvar_2.z = vPos_1.z;
gl_Position.xyw = tmpvar_2.xyw;
xlv_TEXCOORD0 = TEXCOORD0;
gl_Position.z = ((POSITION.z * 2.0) - 1.0);
}
 
 