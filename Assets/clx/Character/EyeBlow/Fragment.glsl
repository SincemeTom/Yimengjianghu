#version 300 es
uniform highp vec4 EnvInfo;
uniform highp vec4 SunColor;
uniform highp vec4 SunDirection;
uniform highp vec4 FogColor;
uniform highp vec4 ShadowColor;
uniform highp vec4 FogColor2;
uniform highp vec4 FogColor3;
uniform highp vec4 UserData[3];
uniform highp vec4 cPointCloud[6];
uniform highp vec3 cBaseColor;
uniform highp float cBaseMapBias;
uniform highp vec4 cColorTransform0;
uniform highp vec4 cColorTransform1;
uniform highp vec4 cColorTransform2;
uniform highp float cGrayPencent;
uniform highp float cAlpha;
uniform mediump sampler2D sBaseSampler;
in highp vec4 xlv_TEXCOORD0;
in highp vec4 xlv_TEXCOORD1;
in highp vec4 xlv_TEXCOORD2;
in highp vec4 xlv_TEXCOORD3;
in highp vec3 xlv_TEXCOORD4;
in highp vec3 xlv_TEXCOORD5;
out highp vec4 SV_Target;
void main ()
{
  mediump float SunlightOffset_1;
  mediump vec3 diffLighting_2;
  mediump vec3 DiffuseColor_3;
  mediump float shadow_4;
  highp vec4 OUT_5;
  OUT_5.xyz = vec3(0.0, 0.0, 0.0);
  mediump vec3 BaseColor_6;
  mediump float Alpha_7;
  highp vec4 base_color_data_8;
  mediump vec4 color_9;
  color_9 = texture (sBaseSampler, xlv_TEXCOORD0.xy, cBaseMapBias);
  BaseColor_6 = (color_9.xyz * color_9.xyz);
  Alpha_7 = (color_9.w * cAlpha);
  mediump vec4 tmpvar_10;
  tmpvar_10.w = 1.0;
  tmpvar_10.xyz = BaseColor_6;
  base_color_data_8 = tmpvar_10;
  highp vec3 tmpvar_11;
  tmpvar_11.x = dot (cColorTransform0, base_color_data_8);
  tmpvar_11.y = dot (cColorTransform1, base_color_data_8);
  tmpvar_11.z = dot (cColorTransform2, base_color_data_8);
  highp vec3 tmpvar_12;
  tmpvar_12 = clamp (tmpvar_11, 0.0, 1.0);
  BaseColor_6 = ((BaseColor_6 * (1.0 - Alpha_7)) + (tmpvar_12 * Alpha_7));
  highp vec3 tmpvar_13;
  tmpvar_13 = ((float(
    (0.99 >= cColorTransform0.w)
  ) * BaseColor_6) + (float(
    (cColorTransform0.w >= 0.99)
  ) * cBaseColor));
  BaseColor_6 = ((BaseColor_6 * (1.0 - Alpha_7)) + (tmpvar_13 * Alpha_7));
  highp vec3 tmpvar_14;
  tmpvar_14 = normalize(xlv_TEXCOORD2.xyz);
  mediump vec4 linearColor_15;
  mediump vec3 nSquared_16;
  highp vec3 tmpvar_17;
  tmpvar_17 = (tmpvar_14 * tmpvar_14);
  nSquared_16 = tmpvar_17;
  highp ivec3 tmpvar_18;
  tmpvar_18 = ivec3(lessThan (tmpvar_14, vec3(0.0, 0.0, 0.0)));
  highp vec4 tmpvar_19;
  tmpvar_19 = (((nSquared_16.x * cPointCloud[tmpvar_18.x]) + (nSquared_16.y * cPointCloud[
    (tmpvar_18.y + 2)
  ])) + (nSquared_16.z * cPointCloud[(tmpvar_18.z + 4)]));
  linearColor_15 = tmpvar_19;
  linearColor_15.xyz = max (vec3(0.9, 0.9, 0.9), linearColor_15.xyz);
  highp vec3 tmpvar_20;
  tmpvar_20 = vec3((ShadowColor.x * (10.0 + (
    (cPointCloud[3].w * ShadowColor.z)
   * 100.0))));
  linearColor_15.xyz = (linearColor_15.xyz * tmpvar_20);
  OUT_5.w = Alpha_7;
  DiffuseColor_3 = (BaseColor_6 / 3.141593);
  highp vec3 tmpvar_21;
  tmpvar_21 = normalize(-(xlv_TEXCOORD3.xyz));
  mediump float color_22;
  color_22 = dot (SunDirection.xyz, tmpvar_14);
  highp float tmpvar_23;
  tmpvar_23 = ShadowColor.y;
  SunlightOffset_1 = tmpvar_23;
  shadow_4 = (SunlightOffset_1 * cPointCloud[0].w);
  mediump vec3 tmpvar_24;
  tmpvar_24 = ((clamp (color_22, 0.0, 1.0) * shadow_4) * SunColor.xyz);
  diffLighting_2 = (linearColor_15.xyz + tmpvar_24);
  OUT_5.xyz = OUT_5.xyz;
  OUT_5.xyz = (OUT_5.xyz + (diffLighting_2 * DiffuseColor_3));
  mediump float tmpvar_25;
  tmpvar_25 = max (0.5, clamp ((1.0 + 
    (shadow_4 * 0.5)
  ), 0.0, 1.0));
  OUT_5.xyz = (OUT_5.xyz * tmpvar_25);
  highp float tmpvar_26;
  tmpvar_26 = clamp (dot (-(tmpvar_21), SunDirection.xyz), 0.0, 1.0);
  highp float tmpvar_27;
  tmpvar_27 = (1.0 - xlv_TEXCOORD3.w);
  OUT_5.xyz = ((OUT_5.xyz * tmpvar_27) + ((
    (OUT_5.xyz * tmpvar_27)
   + 
    (((FogColor2.xyz * clamp (
      ((tmpvar_21.y * 5.0) + 1.0)
    , 0.0, 1.0)) + FogColor.xyz) + (FogColor3.xyz * (tmpvar_26 * tmpvar_26)))
  ) * xlv_TEXCOORD3.w));
  OUT_5.xyz = (OUT_5.xyz * EnvInfo.z);
  OUT_5.xyz = clamp (OUT_5.xyz, vec3(0.0, 0.0, 0.0), vec3(4.0, 4.0, 4.0));
  highp vec3 tmpvar_28;
  tmpvar_28.x = FogColor.w;
  tmpvar_28.y = FogColor2.w;
  tmpvar_28.z = FogColor3.w;
  OUT_5.xyz = (OUT_5.xyz * tmpvar_28);
  OUT_5.xyz = (OUT_5.xyz / ((OUT_5.xyz * 0.9661836) + 0.180676));
  highp float tmpvar_29;
  tmpvar_29 = float(((
    clamp (cGrayPencent, 0.0, 1.0)
   + UserData[2].x) >= 2.0));
  OUT_5.xyz = ((OUT_5.xyz * (1.0 - tmpvar_29)) + (tmpvar_29 * dot (OUT_5.xyz, vec3(0.3, 0.59, 0.11))));
  OUT_5.xyz = (OUT_5.xyz * OUT_5.w);
  SV_Target = OUT_5;
}

 