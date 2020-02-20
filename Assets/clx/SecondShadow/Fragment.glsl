#version 300 es
uniform highp vec4 EnvInfo;
uniform highp vec4 SunColor;
uniform highp vec4 SunDirection;
uniform highp vec4 FogColor;
uniform highp vec4 ScreenColor;
uniform highp vec4 ScreenInfoPS;
uniform highp vec4 FogColor2;
uniform highp vec4 FogColor3;
uniform highp vec4 UserData[3];
uniform highp vec4 cParamter;
uniform highp float cEnvStrength;
uniform highp vec4 cLightMapScale;
uniform highp float cBaseMapBias;
uniform highp float cNormalMapBias;
uniform highp vec4 cEmissionScale;
uniform highp vec4 cColorTransform0;
uniform highp vec4 cColorTransform1;
uniform highp vec4 cColorTransform2;
uniform highp float cGrayPencent;
uniform highp vec4 cColorTransform3;
uniform highp vec4 cColorTransform4;
uniform highp vec4 cColorTransform5;
uniform mediump sampler2D sBaseSampler;
uniform mediump sampler2D sNormalSampler;
uniform mediump sampler2D sEmissionMapSampler;
uniform mediump sampler2D sLightMapSampler;
uniform mediump sampler2D sEnvSampler;
uniform highp sampler2D sSecondShadowSampler;
in highp vec4 xlv_TEXCOORD0;
in highp vec4 xlv_TEXCOORD1;
in highp vec4 xlv_TEXCOORD2;
in highp vec4 xlv_TEXCOORD3;
in highp vec3 xlv_TEXCOORD4;
in highp vec3 xlv_TEXCOORD5;
out highp vec4 SV_Target;
void main ()
{
  highp vec3 R_1;
  mediump vec3 SpecularColor_2;
  mediump vec3 DiffuseColor_3;
  mediump vec2 shadow_and_ao_4;
  mediump float shadow_5;
  highp vec4 OUT_6;
  mediump vec3 BaseColor_7;
  mediump float Metallic_8;
  highp vec3 N_9;
  mediump vec4 Emission_10;
  mediump vec4 GILighting_11;
  mediump float Alpha_12;
  mediump float SSSmask_13;
  mediump vec4 tangentNormal_14;
  highp vec4 base_color_data_15;
  highp float mask_16;
  mediump vec4 tmpvar_17;
  tmpvar_17 = texture (sBaseSampler, xlv_TEXCOORD0.xy, cBaseMapBias);
  BaseColor_7 = (tmpvar_17.xyz * tmpvar_17.xyz);
  Alpha_12 = tmpvar_17.w;
  mask_16 = Alpha_12;
  mediump vec4 tmpvar_18;
  tmpvar_18.w = 1.0;
  tmpvar_18.xyz = BaseColor_7;
  base_color_data_15 = tmpvar_18;
  highp vec3 tmpvar_19;
  tmpvar_19.x = dot (cColorTransform0, base_color_data_15);
  tmpvar_19.y = dot (cColorTransform1, base_color_data_15);
  tmpvar_19.z = dot (cColorTransform2, base_color_data_15);
  highp vec3 tmpvar_20;
  tmpvar_20 = ((BaseColor_7 * (1.0 - mask_16)) + (clamp (tmpvar_19, 0.0, 1.0) * mask_16));
  BaseColor_7 = tmpvar_20;
  Emission_10.w = 0.0;
  Metallic_8 = clamp (((tmpvar_17.w * 2.0) - 1.0), 0.0, 1.0);
  mediump vec4 tmpvar_21;
  tmpvar_21 = texture (sNormalSampler, xlv_TEXCOORD0.xy, cNormalMapBias);
  tangentNormal_14.zw = tmpvar_21.zw;
  SSSmask_13 = (1.0 - tmpvar_21.w);
  mediump float tmpvar_22;
  mediump float rain_23;
  rain_23 = EnvInfo.x;
  highp float tmpvar_24;
  tmpvar_24 = clamp (((xlv_TEXCOORD2.y * 0.7) + (0.4 * rain_23)), 0.0, 1.0);
  rain_23 = (1.0 - (rain_23 * tmpvar_24));
  tmpvar_22 = (rain_23 - (rain_23 * tmpvar_21.z));
  tangentNormal_14.xy = ((tmpvar_21.xy * 2.0) - 1.0);
  tangentNormal_14.xy = (tangentNormal_14.xy * cParamter.w);
  mediump float tmpvar_25;
  tmpvar_25 = sqrt(clamp ((
    (1.0 - (tangentNormal_14.x * tangentNormal_14.x))
   - 
    (tangentNormal_14.y * tangentNormal_14.y)
  ), 0.0, 1.0));
  N_9 = (((xlv_TEXCOORD4 * tangentNormal_14.x) + (xlv_TEXCOORD5 * tangentNormal_14.y)) + (xlv_TEXCOORD2.xyz * tmpvar_25));
  highp vec3 tmpvar_26;
  tmpvar_26 = normalize(N_9);
  N_9 = tmpvar_26;
  highp vec3 tmpvar_27;
  tmpvar_27.x = dot (cColorTransform3, base_color_data_15);
  tmpvar_27.y = dot (cColorTransform4, base_color_data_15);
  tmpvar_27.z = dot (cColorTransform5, base_color_data_15);
  highp vec3 tmpvar_28;
  tmpvar_28 = ((BaseColor_7 * (1.0 - SSSmask_13)) + (clamp (tmpvar_27, 0.0, 1.0) * SSSmask_13));
  BaseColor_7 = tmpvar_28;
  highp vec2 tmpvar_29;
  tmpvar_29.x = xlv_TEXCOORD1.w;
  tmpvar_29.y = xlv_TEXCOORD2.w;
  Emission_10.xyz = texture (sEmissionMapSampler, tmpvar_29).xyz;
  Emission_10.xyz = (Emission_10.xyz * cEmissionScale.xyz);
  Emission_10.xyz = (Emission_10.xyz * UserData[0].xyz);
  Emission_10.xyz = (Emission_10.xyz * tmpvar_17.w);
  GILighting_11.xyz = vec3(0.0, 0.0, 0.0);
  GILighting_11.w = tmpvar_21.w;
  OUT_6.w = Alpha_12;
  highp vec2 tmpvar_30;
  tmpvar_30 = texture (sSecondShadowSampler, (gl_FragCoord.xy * ScreenInfoPS.zw)).xy;
  shadow_and_ao_4 = tmpvar_30;
  shadow_5 = (1.0 - shadow_and_ao_4.x);
  SpecularColor_2 = ((BaseColor_7 * Metallic_8) + 0.04);
  DiffuseColor_3 = ((BaseColor_7 - (BaseColor_7 * Metallic_8)) / 3.141593);
  highp vec3 tmpvar_31;
  tmpvar_31 = normalize(-(xlv_TEXCOORD3.xyz));
  highp vec3 I_32;
  I_32 = -(tmpvar_31);
  R_1 = (I_32 - (2.0 * (
    dot (tmpvar_26, I_32)
   * tmpvar_26)));
  mediump float color_33;
  color_33 = clamp (dot (tmpvar_26, tmpvar_31), 0.0, 1.0);
  mediump float color_34;
  color_34 = dot (SunDirection.xyz, tmpvar_26);
  shadow_5 = (shadow_5 * clamp ((
    (abs(color_34) + ((2.0 * tmpvar_21.w) * tmpvar_21.w))
   - 1.0), 0.0, 1.0));
  mediump vec4 GILighting_35;
  GILighting_35.xyz = GILighting_11.xyz;
  mediump float shadow_36;
  mediump vec3 bakeLighting_37;
  mediump vec4 lightMapRaw_38;
  mediump vec4 lightMapScale_39;
  lightMapScale_39 = cLightMapScale;
  mediump vec4 tmpvar_40;
  tmpvar_40 = texture (sLightMapSampler, xlv_TEXCOORD0.zw);
  lightMapRaw_38.w = tmpvar_40.w;
  lightMapRaw_38.xyz = ((tmpvar_40.xyz * lightMapScale_39.xxx) + lightMapScale_39.yyy);
  mediump float tmpvar_41;
  tmpvar_41 = (dot (lightMapRaw_38.xyz, vec3(0.0955, 0.1878, 0.035)) + 7.5e-05);
  mediump float tmpvar_42;
  tmpvar_42 = exp2(((tmpvar_41 * 50.27) - 8.737));
  shadow_36 = (shadow_5 * (tmpvar_40.w * tmpvar_40.w));
  GILighting_35.w = (tmpvar_21.w * clamp (tmpvar_42, 0.0, 1.0));
  bakeLighting_37 = ((lightMapRaw_38 * (
    (tmpvar_21.w * tmpvar_42)
   / tmpvar_41)).xyz + (SunColor.xyz * clamp (
    (color_34 * shadow_36)
  , 0.0, 1.0)));
  shadow_5 = shadow_36;
  highp float D_43;
  mediump vec3 sunSpec_44;
  mediump float m2_45;
  mediump vec3 Spec_46;
  mediump float tmpvar_47;
  tmpvar_47 = ((tmpvar_22 * tmpvar_22) + 0.0002);
  m2_45 = (tmpvar_47 * tmpvar_47);
  mediump vec3 tmpvar_48;
  mediump vec4 tmpvar_49;
  tmpvar_49 = ((tmpvar_22 * vec4(-1.0, -0.0275, -0.572, 0.022)) + vec4(1.0, 0.0425, 1.04, -0.04));
  mediump vec2 tmpvar_50;
  tmpvar_50 = ((vec2(-1.04, 1.04) * (
    (min ((tmpvar_49.x * tmpvar_49.x), exp2((-9.28 * color_33))) * tmpvar_49.x)
   + tmpvar_49.y)) + tmpvar_49.zw);
  tmpvar_48 = ((SpecularColor_2 * tmpvar_50.x) + tmpvar_50.y);
  highp vec3 R_51;
  R_51.z = R_1.z;
  mediump float fSign_52;
  mediump vec3 sampleEnvSpecular_53;
  highp float tmpvar_54;
  tmpvar_54 = float((R_1.z > 0.0));
  fSign_52 = tmpvar_54;
  mediump float tmpvar_55;
  tmpvar_55 = ((fSign_52 * 2.0) - 1.0);
  R_51.xy = (R_1.xy / ((R_1.z * tmpvar_55) + 1.0));
  R_51.xy = ((R_51.xy * vec2(0.25, -0.25)) + (0.25 + (0.5 * fSign_52)));
  mediump vec4 tmpvar_56;
  tmpvar_56 = textureLod (sEnvSampler, R_51.xy, (tmpvar_22 / 0.17));
  sampleEnvSpecular_53 = (tmpvar_56.xyz * ((tmpvar_56.w * tmpvar_56.w) * 16.0));
  sampleEnvSpecular_53 = (sampleEnvSpecular_53 * ((cEnvStrength * GILighting_35.w) * (EnvInfo.w * 10.0)));
  highp float tmpvar_57;
  tmpvar_57 = clamp (dot (tmpvar_26, normalize(
    (tmpvar_31 + SunDirection.xyz)
  )), 0.0, 1.0);
  highp float tmpvar_58;
  tmpvar_58 = (((
    (tmpvar_57 * m2_45)
   - tmpvar_57) * tmpvar_57) + 1.0);
  D_43 = ((tmpvar_58 * tmpvar_58) + 1e-06);
  D_43 = ((0.25 * m2_45) / D_43);
  sunSpec_44 = (tmpvar_48 * D_43);
  sunSpec_44 = (sunSpec_44 * (SunColor.xyz * clamp (
    (color_34 * shadow_36)
  , 0.0, 1.0)));
  Spec_46 = ((tmpvar_48 * sampleEnvSpecular_53) + sunSpec_44);
  SpecularColor_2 = tmpvar_48;
  OUT_6.xyz = Spec_46;
  OUT_6.xyz = (OUT_6.xyz + Emission_10.xyz);
  OUT_6.xyz = (OUT_6.xyz + (bakeLighting_37 * DiffuseColor_3));
  mediump float tmpvar_59;
  tmpvar_59 = clamp ((shadow_and_ao_4.y + (shadow_36 * 0.5)), 0.0, 1.0);
  OUT_6.xyz = (OUT_6.xyz * tmpvar_59);
  highp float tmpvar_60;
  tmpvar_60 = clamp (dot (-(tmpvar_31), SunDirection.xyz), 0.0, 1.0);
  highp float tmpvar_61;
  tmpvar_61 = (1.0 - xlv_TEXCOORD3.w);
  OUT_6.xyz = ((OUT_6.xyz * tmpvar_61) + ((
    (OUT_6.xyz * tmpvar_61)
   + 
    (((FogColor2.xyz * clamp (
      ((tmpvar_31.y * 5.0) + 1.0)
    , 0.0, 1.0)) + FogColor.xyz) + (FogColor3.xyz * (tmpvar_60 * tmpvar_60)))
  ) * xlv_TEXCOORD3.w));
  OUT_6.xyz = (OUT_6.xyz * EnvInfo.z);
  OUT_6.xyz = clamp (OUT_6.xyz, vec3(0.0, 0.0, 0.0), vec3(4.0, 4.0, 4.0));
  OUT_6.xyz = ((OUT_6.xyz * (1.0 - ScreenColor.w)) + (ScreenColor.xyz * ScreenColor.w));
  highp vec3 tmpvar_62;
  tmpvar_62.x = FogColor.w;
  tmpvar_62.y = FogColor2.w;
  tmpvar_62.z = FogColor3.w;
  OUT_6.xyz = (OUT_6.xyz * tmpvar_62);
  OUT_6.xyz = (OUT_6.xyz / ((OUT_6.xyz * 0.9661836) + 0.180676));
  highp float tmpvar_63;
  tmpvar_63 = float(((
    clamp (cGrayPencent, 0.0, 1.0)
   + UserData[2].x) >= 2.0));
  OUT_6.xyz = ((OUT_6.xyz * (1.0 - tmpvar_63)) + (tmpvar_63 * dot (OUT_6.xyz, vec3(0.3, 0.59, 0.11))));
  OUT_6.w = 1.0;
  SV_Target = OUT_6;
}

 