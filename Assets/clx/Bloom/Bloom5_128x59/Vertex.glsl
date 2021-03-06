#version 300 es
uniform highp vec4 ScreenInfoVS;
in highp vec4 POSITION;
in highp vec2 TEXCOORD0;
out highp vec4 xlv_TEXCOORD0;
out highp vec4 xlv_TEXCOORD1;
void main ()
{
highp vec3 vPos_1;
highp vec4 tmpvar_2;
highp vec4 tmpvar_3;
vPos_1.xz = POSITION.xz;
vPos_1.y = (1.0 - POSITION.y);
highp vec4 tmpvar_4;
tmpvar_4.zw = vec2(1e-6, 1.0);
tmpvar_4.xy = ((vPos_1.xy * 2.0) - 1.0);
tmpvar_2.xy = (TEXCOORD0 + (vec2(-1.5, -0.5) * ScreenInfoVS.zw));
tmpvar_2.zw = (TEXCOORD0 + (vec2(0.5, -1.5) * ScreenInfoVS.zw));
tmpvar_3.xy = (TEXCOORD0 + (vec2(1.5, 0.5) * ScreenInfoVS.zw));
tmpvar_3.zw = (TEXCOORD0 + (vec2(-0.5, 1.5) * ScreenInfoVS.zw));
gl_Position.xyw = tmpvar_4.xyw;
xlv_TEXCOORD0 = tmpvar_2;
xlv_TEXCOORD1 = tmpvar_3;
gl_Position.z = -0.999998;
}
 
 