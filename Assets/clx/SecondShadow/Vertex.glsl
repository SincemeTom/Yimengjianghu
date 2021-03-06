#version 300 es
uniform highp mat4 ViewProjVS;
uniform highp vec4 CameraPosVS;
uniform highp vec4 FogInfo;
uniform highp mat4 World;
uniform highp vec4 cLightMapUVTransform;
uniform highp vec4 cEmissionScrolling;
in highp vec4 POSITION;
in highp vec4 NORMAL;
in highp vec2 TEXCOORD0;
in highp vec2 TEXCOORD1;
in highp vec4 TANGENT;
in highp vec4 BINORMAL;
out highp vec4 xlv_TEXCOORD0;
out highp vec4 xlv_TEXCOORD1;
out highp vec4 xlv_TEXCOORD2;
out highp vec4 xlv_TEXCOORD3;
out highp vec3 xlv_TEXCOORD4;
out highp vec3 xlv_TEXCOORD5;
void main ()
{
highp vec4 tmpvar_1;
tmpvar_1.w = 1.0;
tmpvar_1.xyz = POSITION.xyz;
highp vec4 tmpvar_2;
highp vec4 tmpvar_3;
highp vec4 tmpvar_4;
highp vec4 tmpvar_5;
tmpvar_5.w = 1.0;
tmpvar_5.xyz = tmpvar_1.xyz;
highp vec4 tmpvar_6;
tmpvar_6.w = 1.0;
tmpvar_6.xyz = (tmpvar_5 * World).xyz;
tmpvar_2.xy = TEXCOORD0;
tmpvar_2.zw = ((TEXCOORD1 * cLightMapUVTransform.xy) + cLightMapUVTransform.zw);
highp mat3 tmpvar_7;
tmpvar_7[uint(0)] = World[uint(0)].xyz;
tmpvar_7[1u] = World[1u].xyz;
tmpvar_7[2u] = World[2u].xyz;
tmpvar_3.xyz = normalize(((
(NORMAL.xyz * 2.0)
- 1.0) * tmpvar_7));
highp mat3 tmpvar_8;
tmpvar_8[uint(0)] = World[uint(0)].xyz;
tmpvar_8[1u] = World[1u].xyz;
tmpvar_8[2u] = World[2u].xyz;
highp mat3 tmpvar_9;
tmpvar_9[uint(0)] = World[uint(0)].xyz;
tmpvar_9[1u] = World[1u].xyz;
tmpvar_9[2u] = World[2u].xyz;
tmpvar_4.xyz = (tmpvar_6.xyz - CameraPosVS.xyz);
highp float fHeightCoef_10;
highp float tmpvar_11;
tmpvar_11 = clamp (((tmpvar_6.y * FogInfo.z) + FogInfo.w), 0.0, 1.0);
fHeightCoef_10 = (tmpvar_11 * tmpvar_11);
fHeightCoef_10 = (fHeightCoef_10 * fHeightCoef_10);
highp float tmpvar_12;
tmpvar_12 = (1.0 - exp((
-(max (0.0, (sqrt(
dot (tmpvar_4.xyz, tmpvar_4.xyz)
) - FogInfo.x)))
*
max ((FogInfo.y * fHeightCoef_10), (0.1 * FogInfo.y))
)));
tmpvar_4.w = (tmpvar_12 * tmpvar_12);
highp vec4 tmpvar_13;
highp vec4 tmpvar_14;
highp vec4 tmpvar_15;
tmpvar_14.xyz = tmpvar_6.xyz;
tmpvar_15.xyz = tmpvar_3.xyz;
highp vec4 tmpvar_16;
tmpvar_16.w = 1.0;
tmpvar_16.xyz = tmpvar_6.xyz;
tmpvar_13 = (tmpvar_16 * ViewProjVS);
highp vec2 tmpvar_17;
tmpvar_17 = ((TEXCOORD0 * cEmissionScrolling.xy) + (CameraPosVS.w * cEmissionScrolling.zw));
tmpvar_14.w = tmpvar_17.x;
tmpvar_15.w = tmpvar_17.y;
tmpvar_3 = tmpvar_15;
gl_Position.xyw = tmpvar_13.xyw;
xlv_TEXCOORD0 = tmpvar_2;
xlv_TEXCOORD1 = tmpvar_14;
xlv_TEXCOORD2 = tmpvar_15;
xlv_TEXCOORD3 = tmpvar_4;
xlv_TEXCOORD4 = normalize(clamp ((
normalize(TANGENT.xyz)
* tmpvar_8), -2.0, 2.0));
xlv_TEXCOORD5 = normalize(clamp ((
normalize(BINORMAL.xyz)
* tmpvar_9), -2.0, 2.0));
gl_Position.z = ((tmpvar_13.z * 2.0) - tmpvar_13.w);
}
 
 