#version 300 es
uniform highp mat4 ViewProjVS;
uniform highp vec4 CameraPosVS;
uniform highp mat4 LightViewProjTex;
uniform highp vec4 FogInfo;
uniform highp vec4 SkeletonData[192];
uniform highp mat4 World;
in highp vec4 POSITION;
in highp vec4 NORMAL;
in highp vec2 TEXCOORD0;
in highp vec4 TANGENT;
in highp vec4 BINORMAL;
in highp vec4 BLENDWEIGHT;
in highp  vec4 BLENDINDICES;
out highp vec4 xlv_TEXCOORD0;
out highp vec4 xlv_TEXCOORD1;
out highp vec4 xlv_TEXCOORD2;
out highp vec4 xlv_TEXCOORD3;
out highp vec3 xlv_TEXCOORD4;
out highp vec3 xlv_TEXCOORD5;
out highp vec4 xlv_TEXCOORD6;
void main ()
{
  highp vec3 tmpvar_1;
  highp vec4 tmpvar_2;
  tmpvar_2.w = 1.0;
  tmpvar_2.xyz = POSITION.xyz;
  tmpvar_1 = ((NORMAL.xyz * 2.0) - 1.0);
  highp vec3 tmpvar_3;
  tmpvar_3 = normalize(TANGENT.xyz);
  highp vec3 tmpvar_4;
  tmpvar_4 = normalize(BINORMAL.xyz);
  highp vec4 tmpvar_5;
  tmpvar_5.w = tmpvar_2.w;
  highp int idx_6;
  idx_6 = int(BLENDINDICES.x);
  highp int idx_7;
  idx_7 = int(BLENDINDICES.y);
  highp int idx_8;
  idx_8 = int(BLENDINDICES.z);
  highp int idx_9;
  idx_9 = int(BLENDINDICES.w);
  highp vec4 tmpvar_10;
  tmpvar_10 = (((
    (BLENDWEIGHT.x * SkeletonData[(3 * idx_6)])
   + 
    (BLENDWEIGHT.y * SkeletonData[(3 * idx_7)])
  ) + (BLENDWEIGHT.z * SkeletonData[
    (3 * idx_8)
  ])) + (BLENDWEIGHT.w * SkeletonData[(3 * idx_9)]));
  highp vec4 tmpvar_11;
  tmpvar_11 = (((
    (BLENDWEIGHT.x * SkeletonData[((3 * idx_6) + 1)])
   + 
    (BLENDWEIGHT.y * SkeletonData[((3 * idx_7) + 1)])
  ) + (BLENDWEIGHT.z * SkeletonData[
    ((3 * idx_8) + 1)
  ])) + (BLENDWEIGHT.w * SkeletonData[(
    (3 * idx_9)
   + 1)]));
  highp vec4 tmpvar_12;
  tmpvar_12 = (((
    (BLENDWEIGHT.x * SkeletonData[((3 * idx_6) + 2)])
   + 
    (BLENDWEIGHT.y * SkeletonData[((3 * idx_7) + 2)])
  ) + (BLENDWEIGHT.z * SkeletonData[
    ((3 * idx_8) + 2)
  ])) + (BLENDWEIGHT.w * SkeletonData[(
    (3 * idx_9)
   + 2)]));
  highp vec3 tmpvar_13;
  tmpvar_13.x = dot (tmpvar_10.xyz, POSITION.xyz);
  tmpvar_13.y = dot (tmpvar_11.xyz, POSITION.xyz);
  tmpvar_13.z = dot (tmpvar_12.xyz, POSITION.xyz);
  highp vec3 tmpvar_14;
  tmpvar_14.x = tmpvar_10.w;
  tmpvar_14.y = tmpvar_11.w;
  tmpvar_14.z = tmpvar_12.w;
  tmpvar_5.xyz = (tmpvar_13 + tmpvar_14);
  highp vec3 tmpvar_15;
  tmpvar_15.x = dot (tmpvar_10.xyz, tmpvar_1);
  tmpvar_15.y = dot (tmpvar_11.xyz, tmpvar_1);
  tmpvar_15.z = dot (tmpvar_12.xyz, tmpvar_1);
  highp vec3 tmpvar_16;
  tmpvar_16.x = dot (tmpvar_10.xyz, tmpvar_3);
  tmpvar_16.y = dot (tmpvar_11.xyz, tmpvar_3);
  tmpvar_16.z = dot (tmpvar_12.xyz, tmpvar_3);
  highp vec3 tmpvar_17;
  tmpvar_17.x = dot (tmpvar_10.xyz, tmpvar_4);
  tmpvar_17.y = dot (tmpvar_11.xyz, tmpvar_4);
  tmpvar_17.z = dot (tmpvar_12.xyz, tmpvar_4);
  highp vec4 tmpvar_18;
  highp vec4 tmpvar_19;
  highp vec4 tmpvar_20;
  tmpvar_20.w = 1.0;
  tmpvar_20.xyz = tmpvar_5.xyz;
  highp vec4 tmpvar_21;
  tmpvar_21.w = 1.0;
  tmpvar_21.xyz = (tmpvar_20 * World).xyz;
  highp mat3 tmpvar_22;
  tmpvar_22[uint(0)] = World[uint(0)].xyz;
  tmpvar_22[1u] = World[1u].xyz;
  tmpvar_22[2u] = World[2u].xyz;
  tmpvar_18.xyz = normalize((tmpvar_15 * tmpvar_22));
  highp mat3 tmpvar_23;
  tmpvar_23[uint(0)] = World[uint(0)].xyz;
  tmpvar_23[1u] = World[1u].xyz;
  tmpvar_23[2u] = World[2u].xyz;
  highp mat3 tmpvar_24;
  tmpvar_24[uint(0)] = World[uint(0)].xyz;
  tmpvar_24[1u] = World[1u].xyz;
  tmpvar_24[2u] = World[2u].xyz;
  tmpvar_19.xyz = (tmpvar_21.xyz - CameraPosVS.xyz);
  highp float fHeightCoef_25;
  highp float tmpvar_26;
  tmpvar_26 = clamp (((tmpvar_21.y * FogInfo.z) + FogInfo.w), 0.0, 1.0);
  fHeightCoef_25 = (tmpvar_26 * tmpvar_26);
  fHeightCoef_25 = (fHeightCoef_25 * fHeightCoef_25);
  highp float tmpvar_27;
  tmpvar_27 = (1.0 - exp((
    -(max (0.0, (sqrt(
      dot (tmpvar_19.xyz, tmpvar_19.xyz)
    ) - FogInfo.x)))
   * 
    max ((FogInfo.y * fHeightCoef_25), (0.1 * FogInfo.y))
  )));
  tmpvar_19.w = (tmpvar_27 * tmpvar_27);
  highp vec4 tmpvar_28;
  tmpvar_28.w = 0.0;
  tmpvar_28.xyz = tmpvar_18.xyz;
  highp vec4 tmpvar_29;
  highp vec4 tmpvar_30;
  tmpvar_30.w = 1.0;
  tmpvar_30.xyz = tmpvar_21.xyz;
  tmpvar_29 = (tmpvar_30 * ViewProjVS);
  gl_Position.xyw = tmpvar_29.xyw;
  xlv_TEXCOORD0 = TEXCOORD0.xyxy;
  xlv_TEXCOORD1 = tmpvar_21;
  xlv_TEXCOORD2 = tmpvar_18;
  xlv_TEXCOORD3 = tmpvar_19;
  xlv_TEXCOORD4 = normalize(clamp ((tmpvar_16 * tmpvar_23), -2.0, 2.0));
  xlv_TEXCOORD5 = normalize(clamp ((tmpvar_17 * tmpvar_24), -2.0, 2.0));
  xlv_TEXCOORD6 = ((tmpvar_21 + (tmpvar_28 * 0.001)) * LightViewProjTex);
  gl_Position.z = ((tmpvar_29.z * 2.0) - tmpvar_29.w);
}

 