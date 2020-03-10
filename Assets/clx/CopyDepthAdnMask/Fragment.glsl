#version 300 es
uniform highp vec4 CameraInfoPS;
uniform highp sampler2D DepthBuffer_Sampler;
in highp vec2 xlv_TEXCOORD0;
out highp vec4 SV_Target;
void main ()
{
highp vec4 rgba_1;
rgba_1 = (vec4(1.0, 255.0, 65025.0, 1.658138e+7) * min ((CameraInfoPS.x /
((texture (DepthBuffer_Sampler, xlv_TEXCOORD0).x * (CameraInfoPS.x - CameraInfoPS.y)) + CameraInfoPS.y)
), 0.9999999));
highp vec4 tmpvar_2;
tmpvar_2 = fract(rgba_1);
rgba_1 = (tmpvar_2 - (tmpvar_2.yzww * vec4(0.003921569, 0.003921569, 0.003921569, 0.0)));
SV_Target = rgba_1;
}
 
 