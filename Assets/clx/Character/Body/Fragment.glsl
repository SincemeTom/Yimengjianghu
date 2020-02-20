#version 300 es
uniform highp vec4 EnvInfo;
uniform highp vec4 SunColor;
uniform highp vec4 SunDirection;
uniform highp vec4 FogColor;
uniform highp vec4 ShadowColor;
uniform highp vec4 FogColor2;
uniform highp vec4 FogColor3;
uniform highp vec4 UserData[3];
uniform highp vec4 cShadowBias;
uniform highp vec4 cPointCloud[6];
uniform highp vec4 cParamter;
uniform highp vec4 cVirtualLitDir;
uniform highp vec4 cVirtualLitColor;
uniform highp float cAliasingFactor;
uniform highp float cEnvStrength;
uniform highp float cBaseMapBias;
uniform highp float cNormalMapBias;
uniform highp vec4 cEmissionScale;
uniform highp vec4 cColorTransform0;
uniform highp vec4 cColorTransform1;
uniform highp vec4 cColorTransform2;
uniform highp float cGrayPencent;
uniform highp float cShadowFilterScale;
uniform highp vec4 cColorTransform3;
uniform highp vec4 cColorTransform4;
uniform highp vec4 cColorTransform5;
uniform mediump sampler2D sBaseSampler;
uniform mediump sampler2D sMixSampler;
uniform mediump sampler2D sNormalSampler;
uniform mediump sampler2D sEnvSampler;
uniform highp sampler2D sShadowMapSampler;
uniform mediump sampler2D sMaskSampler;
in highp vec4 xlv_TEXCOORD0;
in highp vec4 xlv_TEXCOORD1;
in highp vec4 xlv_TEXCOORD2;
in highp vec4 xlv_TEXCOORD3;
in highp vec3 xlv_TEXCOORD4;
in highp vec3 xlv_TEXCOORD5;
in highp vec4 xlv_TEXCOORD6;
out highp vec4 SV_Target;
void main ()
{
  highp float D_1;
  highp float m2_2;
  mediump vec3 virtualLit_3;
  mediump float SunlightOffset_4;
  mediump vec3 diffLighting_5;
  highp vec3 R_6;
  mediump vec3 SpecularColor_7;
  mediump vec3 DiffuseColor_8;
  mediump vec2 inRange_9;
  mediump float shadow2_10;
  mediump float shadow_11;
  mediump vec4 GILighting_12;
  highp vec4 OUT_13;
  mediump vec3 BaseColor_14;
  mediump float Roughness_15;
  highp vec3 N_16;
  mediump vec4 Emission_17;
  mediump vec4 GILighting_18;
  mediump float Alpha_19;
  mediump float SSSmask_20;
  mediump vec4 tangentNormal_21;
  highp vec4 base_color_data_22;
  highp float mask_23;
  mediump vec4 tmpvar_24;
  tmpvar_24 = texture (sBaseSampler, xlv_TEXCOORD0.xy, cBaseMapBias);
  BaseColor_14 = (tmpvar_24.xyz * tmpvar_24.xyz);
  Alpha_19 = tmpvar_24.w;
  mediump vec4 tmpvar_25;
  tmpvar_25 = texture (sMaskSampler, xlv_TEXCOORD0.xy);
  mask_23 = tmpvar_25.x;
  mediump vec4 tmpvar_26;
  tmpvar_26.w = 1.0;
  tmpvar_26.xyz = BaseColor_14;
  base_color_data_22 = tmpvar_26;
  highp vec3 tmpvar_27;
  tmpvar_27.x = dot (cColorTransform0, base_color_data_22);
  tmpvar_27.y = dot (cColorTransform1, base_color_data_22);
  tmpvar_27.z = dot (cColorTransform2, base_color_data_22);
  highp vec3 tmpvar_28;
  tmpvar_28 = ((BaseColor_14 * (1.0 - mask_23)) + (clamp (tmpvar_27, 0.0, 1.0) * mask_23));
  BaseColor_14 = tmpvar_28;
  Emission_17.xyz = vec3(0.0, 0.0, 0.0);
  mediump vec3 tmpvar_29;
  tmpvar_29 = texture (sMixSampler, xlv_TEXCOORD0.xy).xyz;
  mediump float rain_30;
  rain_30 = (EnvInfo.x * 0.5);
  highp float tmpvar_31;
  tmpvar_31 = clamp (((
    (3.0 * xlv_TEXCOORD2.y)
   + 0.2) + (0.1 * rain_30)), 0.0, 1.0);
  rain_30 = (1.0 - (rain_30 * tmpvar_31));
  mediump float tmpvar_32;
  tmpvar_32 = clamp ((rain_30 - (rain_30 * tmpvar_29.x)), 0.05, 1.0);
  mediump vec4 tmpvar_33;
  tmpvar_33 = texture (sNormalSampler, xlv_TEXCOORD0.xy, cNormalMapBias);
  tangentNormal_21.w = tmpvar_33.w;
  SSSmask_20 = (1.0 - tmpvar_33.w);
  tangentNormal_21.xyz = ((tmpvar_33.xyz * 2.0) - 1.0);
  tangentNormal_21.xy = (tangentNormal_21.xy * cParamter.w);
  N_16 = (((xlv_TEXCOORD4 * tangentNormal_21.x) + (xlv_TEXCOORD5 * tangentNormal_21.y)) + (xlv_TEXCOORD2.xyz * tangentNormal_21.z));
  highp float tmpvar_34;
  tmpvar_34 = sqrt(dot (N_16, N_16));
  N_16 = (N_16 / tmpvar_34);
  highp float tmpvar_35;
  tmpvar_35 = clamp ((tmpvar_32 + min (0.4, 
    ((cAliasingFactor * 10.0) * clamp ((1.0 - tmpvar_34), 0.0, 1.0))
  )), 0.0, 1.0);
  Roughness_15 = tmpvar_35;
  highp vec3 tmpvar_36;
  tmpvar_36.x = dot (cColorTransform3, base_color_data_22);
  tmpvar_36.y = dot (cColorTransform4, base_color_data_22);
  tmpvar_36.z = dot (cColorTransform5, base_color_data_22);
  highp vec3 tmpvar_37;
  tmpvar_37 = ((BaseColor_14 * (1.0 - SSSmask_20)) + (clamp (tmpvar_36, 0.0, 1.0) * SSSmask_20));
  BaseColor_14 = tmpvar_37;
  Emission_17.w = cEmissionScale.w;
  mediump vec4 linearColor_38;
  mediump vec3 nSquared_39;
  highp vec3 tmpvar_40;
  tmpvar_40 = (N_16 * N_16);
  nSquared_39 = tmpvar_40;
  highp ivec3 tmpvar_41;
  tmpvar_41 = ivec3(lessThan (N_16, vec3(0.0, 0.0, 0.0)));
  highp vec4 tmpvar_42;
  tmpvar_42 = (((nSquared_39.x * cPointCloud[tmpvar_41.x]) + (nSquared_39.y * cPointCloud[
    (tmpvar_41.y + 2)
  ])) + (nSquared_39.z * cPointCloud[(tmpvar_41.z + 4)]));
  linearColor_38 = tmpvar_42;
  linearColor_38.xyz = max (vec3(0.9, 0.9, 0.9), linearColor_38.xyz);
  highp vec3 tmpvar_43;
  tmpvar_43 = vec3((ShadowColor.x * (10.0 + (
    (cPointCloud[3].w * ShadowColor.z)
   * 100.0))));
  linearColor_38.xyz = (linearColor_38.xyz * tmpvar_43);
  GILighting_18.xyz = linearColor_38.xyz;
  GILighting_18.w = tmpvar_29.z;
  GILighting_12.w = GILighting_18.w;
  OUT_13.w = Alpha_19;
  highp vec3 tmpvar_44;
  tmpvar_44 = (xlv_TEXCOORD6.xyz / xlv_TEXCOORD6.w);
  highp float tmpvar_45;
  tmpvar_45 = min (0.99999, tmpvar_44.z);
  highp vec2 tmpvar_46;
  tmpvar_46 = vec2(lessThan (abs(
    (tmpvar_44.xy - 0.5)
  ), vec2(0.5, 0.5)));
  inRange_9 = tmpvar_46;
  inRange_9.x = (inRange_9.x * inRange_9.y);
  highp float inShadow_47;
  highp vec3 sampleDepth3_48;
  highp vec3 sampleDepth2_49;
  highp vec3 sampleDepth1_50;
  highp float tmpvar_51;
  tmpvar_51 = -(cShadowFilterScale);
  sampleDepth1_50.x = dot (texture (sShadowMapSampler, (tmpvar_44.xy + (cShadowBias.ww * vec2(tmpvar_51)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_52;
  tmpvar_52.x = 0.0;
  tmpvar_52.y = tmpvar_51;
  sampleDepth1_50.y = dot (texture (sShadowMapSampler, (tmpvar_44.xy + (cShadowBias.ww * tmpvar_52))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_53;
  tmpvar_53.x = cShadowFilterScale;
  tmpvar_53.y = tmpvar_51;
  sampleDepth1_50.z = dot (texture (sShadowMapSampler, (tmpvar_44.xy + (cShadowBias.ww * tmpvar_53))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_54;
  tmpvar_54.y = 0.0;
  tmpvar_54.x = tmpvar_51;
  sampleDepth2_49.x = dot (texture (sShadowMapSampler, (tmpvar_44.xy + (cShadowBias.ww * tmpvar_54))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth2_49.y = dot (texture (sShadowMapSampler, tmpvar_44.xy), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_55;
  tmpvar_55.y = 0.0;
  tmpvar_55.x = cShadowFilterScale;
  sampleDepth2_49.z = dot (texture (sShadowMapSampler, (tmpvar_44.xy + (cShadowBias.ww * tmpvar_55))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_56;
  tmpvar_56.x = tmpvar_51;
  tmpvar_56.y = cShadowFilterScale;
  sampleDepth3_48.x = dot (texture (sShadowMapSampler, (tmpvar_44.xy + (cShadowBias.ww * tmpvar_56))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_57;
  tmpvar_57.x = 0.0;
  tmpvar_57.y = cShadowFilterScale;
  sampleDepth3_48.y = dot (texture (sShadowMapSampler, (tmpvar_44.xy + (cShadowBias.ww * tmpvar_57))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth3_48.z = dot (texture (sShadowMapSampler, (tmpvar_44.xy + (cShadowBias.ww * vec2(cShadowFilterScale)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec3 tmpvar_58;
  tmpvar_58 = vec3(greaterThan (vec3(tmpvar_45), sampleDepth2_49));
  highp vec2 tmpvar_59;
  tmpvar_59 = fract((tmpvar_44.xy / cShadowBias.ww));
  highp vec4 tmpvar_60;
  tmpvar_60 = ((vec3(
    greaterThan (vec3(tmpvar_45), sampleDepth1_50)
  ).xyyz * (1.0 - tmpvar_59.y)) + (tmpvar_58.xyyz * tmpvar_59.y));
  highp vec4 tmpvar_61;
  tmpvar_61 = ((tmpvar_58.xyyz * (1.0 - tmpvar_59.y)) + (vec3(
    greaterThan (vec3(tmpvar_45), sampleDepth3_48)
  ).xyyz * tmpvar_59.y));
  inShadow_47 = ((tmpvar_60.x * (1.0 - tmpvar_59.x)) + (tmpvar_60.y * tmpvar_59.x));
  inShadow_47 = (inShadow_47 + ((tmpvar_60.z * 
    (1.0 - tmpvar_59.x)
  ) + (tmpvar_60.w * tmpvar_59.x)));
  inShadow_47 = (inShadow_47 + ((tmpvar_61.x * 
    (1.0 - tmpvar_59.x)
  ) + (tmpvar_61.y * tmpvar_59.x)));
  inShadow_47 = (inShadow_47 + ((tmpvar_61.z * 
    (1.0 - tmpvar_59.x)
  ) + (tmpvar_61.w * tmpvar_59.x)));
  inShadow_47 = (inShadow_47 * 0.25);
  shadow2_10 = inShadow_47;
  shadow2_10 = (shadow2_10 * inRange_9.x);
  shadow2_10 = (1.0 - shadow2_10);
  shadow_11 = min (1.0, shadow2_10);
  SpecularColor_7 = ((vec3(0.04, 0.04, 0.04) * (1.0 - tmpvar_29.yyy)) + (BaseColor_14 * tmpvar_29.yyy));
  DiffuseColor_8 = ((BaseColor_14 - (BaseColor_14 * tmpvar_29.y)) / 3.141593);
  highp vec3 tmpvar_62;
  tmpvar_62 = normalize(-(xlv_TEXCOORD3.xyz));
  highp vec3 I_63;
  I_63 = -(tmpvar_62);
  R_6 = (I_63 - (2.0 * (
    dot (N_16, I_63)
   * N_16)));
  mediump float color_64;
  color_64 = clamp (dot (N_16, tmpvar_62), 0.0, 1.0);
  mediump float color_65;
  color_65 = dot (SunDirection.xyz, N_16);
  shadow_11 = (shadow_11 * clamp ((
    (abs(color_65) + ((2.0 * tmpvar_29.z) * tmpvar_29.z))
   - 1.0), 0.0, 1.0));
  highp float tmpvar_66;
  tmpvar_66 = (((1.0 - SSSmask_20) + (
    (UserData[1].x * 2.0)
   * SSSmask_20)) * ShadowColor.y);
  SunlightOffset_4 = tmpvar_66;
  shadow_11 = (shadow_11 * SunlightOffset_4);
  shadow_11 = (shadow_11 * cPointCloud[0].w);
  GILighting_12.xyz = ((linearColor_38.xyz * (1.0 - SSSmask_20)) + ((
    (linearColor_38.xyz * UserData[1].y)
   * 2.0) * SSSmask_20));
  diffLighting_5 = (GILighting_12.xyz * tmpvar_29.z);
  GILighting_12.w = (tmpvar_29.z * clamp (dot (diffLighting_5, vec3(0.3, 0.59, 0.11)), 0.0, 1.0));
  mediump vec3 tmpvar_67;
  tmpvar_67 = ((clamp (color_65, 0.0, 1.0) * shadow_11) * SunColor.xyz);
  diffLighting_5 = (diffLighting_5 + tmpvar_67);
  mediump float G_68;
  highp float D_69;
  highp float m_70;
  mediump vec3 sunSpec_71;
  mediump vec3 Spec_72;
  mediump vec3 tmpvar_73;
  mediump vec4 tmpvar_74;
  tmpvar_74 = ((Roughness_15 * vec4(-1.0, -0.0275, -0.572, 0.022)) + vec4(1.0, 0.0425, 1.04, -0.04));
  mediump vec2 tmpvar_75;
  tmpvar_75 = ((vec2(-1.04, 1.04) * (
    (min ((tmpvar_74.x * tmpvar_74.x), exp2((-9.28 * color_64))) * tmpvar_74.x)
   + tmpvar_74.y)) + tmpvar_74.zw);
  tmpvar_73 = ((SpecularColor_7 * tmpvar_75.x) + tmpvar_75.y);
  highp vec3 R_76;
  R_76.z = R_6.z;
  mediump float fSign_77;
  mediump vec3 sampleEnvSpecular_78;
  highp float tmpvar_79;
  tmpvar_79 = float((R_6.z > 0.0));
  fSign_77 = tmpvar_79;
  mediump float tmpvar_80;
  tmpvar_80 = ((fSign_77 * 2.0) - 1.0);
  R_76.xy = (R_6.xy / ((R_6.z * tmpvar_80) + 1.0));
  R_76.xy = ((R_76.xy * vec2(0.25, -0.25)) + (0.25 + (0.5 * fSign_77)));
  mediump vec4 tmpvar_81;
  tmpvar_81 = textureLod (sEnvSampler, R_76.xy, (Roughness_15 / 0.17));
  sampleEnvSpecular_78 = (tmpvar_81.xyz * ((tmpvar_81.w * tmpvar_81.w) * 16.0));
  sampleEnvSpecular_78 = (sampleEnvSpecular_78 * ((cEnvStrength * GILighting_12.w) * (EnvInfo.w * 10.0)));
  highp vec3 tmpvar_82;
  tmpvar_82 = normalize((tmpvar_62 + SunDirection.xyz));
  highp float tmpvar_83;
  tmpvar_83 = clamp (dot (N_16, tmpvar_82), 0.0, 1.0);
  highp float tmpvar_84;
  tmpvar_84 = clamp (dot (tmpvar_62, tmpvar_82), 0.0, 1.0);
  mediump float tmpvar_85;
  tmpvar_85 = max (0.08, Roughness_15);
  mediump float tmpvar_86;
  tmpvar_86 = (tmpvar_85 * tmpvar_85);
  m_70 = tmpvar_86;
  highp float tmpvar_87;
  tmpvar_87 = (m_70 * m_70);
  highp float tmpvar_88;
  tmpvar_88 = (((
    (tmpvar_83 * tmpvar_87)
   - tmpvar_83) * tmpvar_83) + 1.0);
  D_69 = (tmpvar_87 / ((tmpvar_88 * tmpvar_88) * 3.141593));
  highp float tmpvar_89;
  tmpvar_89 = (m_70 * 0.5);
  mediump float tmpvar_90;
  tmpvar_90 = clamp (color_65, 0.0, 1.0);
  highp float tmpvar_91;
  tmpvar_91 = (0.25 / ((
    (color_64 * (1.0 - tmpvar_89))
   + tmpvar_89) * (
    (tmpvar_90 * (1.0 - tmpvar_89))
   + tmpvar_89)));
  G_68 = tmpvar_91;
  mediump float color_92;
  color_92 = exp2(((
    (-5.55473 * tmpvar_84)
   - 6.98316) * tmpvar_84));
  sunSpec_71 = ((D_69 * G_68) * (tmpvar_73 + (
    (clamp ((50.0 * tmpvar_73.y), 0.0, 1.0) - tmpvar_73)
   * color_92)));
  sunSpec_71 = (sunSpec_71 * (SunColor.xyz * clamp (
    (color_65 * shadow_11)
  , 0.0, 1.0)));
  Spec_72 = ((tmpvar_73 * sampleEnvSpecular_78) + sunSpec_71);
  SpecularColor_7 = tmpvar_73;
  OUT_13.xyz = Spec_72;
  highp vec3 tmpvar_93;
  tmpvar_93 = normalize(cVirtualLitDir.xyz);
  mediump float color_94;
  color_94 = clamp (dot (tmpvar_93, N_16), 0.0, 1.0);
  mediump vec3 color_95;
  color_95 = (cVirtualLitColor.xyz * (Emission_17.w * (0.444 + 
    (color_94 * 0.556)
  )));
  virtualLit_3 = ((color_95 * (1.0 - SSSmask_20)) + ((
    (color_95 * UserData[1].z)
   * 2.0) * SSSmask_20));
  diffLighting_5 = (diffLighting_5 + virtualLit_3);
  highp float tmpvar_96;
  tmpvar_96 = clamp (dot (N_16, normalize(
    (tmpvar_62 + tmpvar_93)
  )), 0.0, 1.0);
  mediump float tmpvar_97;
  tmpvar_97 = ((Roughness_15 * Roughness_15) + 0.0002);
  m2_2 = tmpvar_97;
  m2_2 = (m2_2 * m2_2);
  highp float tmpvar_98;
  tmpvar_98 = (((
    (tmpvar_96 * m2_2)
   - tmpvar_96) * tmpvar_96) + 1.0);
  D_1 = ((tmpvar_98 * tmpvar_98) + 1e-06);
  D_1 = ((0.25 * m2_2) / D_1);
  OUT_13.xyz = (OUT_13.xyz + ((virtualLit_3 * tmpvar_73) * D_1));
  OUT_13.xyz = OUT_13.xyz;
  OUT_13.xyz = (OUT_13.xyz + (diffLighting_5 * DiffuseColor_8));
  mediump float tmpvar_99;
  tmpvar_99 = max (0.5, clamp ((1.0 + 
    (shadow_11 * 0.5)
  ), 0.0, 1.0));
  OUT_13.xyz = (OUT_13.xyz * tmpvar_99);
  highp float tmpvar_100;
  tmpvar_100 = clamp (dot (-(tmpvar_62), SunDirection.xyz), 0.0, 1.0);
  highp float tmpvar_101;
  tmpvar_101 = (1.0 - xlv_TEXCOORD3.w);
  OUT_13.xyz = ((OUT_13.xyz * tmpvar_101) + ((
    (OUT_13.xyz * tmpvar_101)
   + 
    (((FogColor2.xyz * clamp (
      ((tmpvar_62.y * 5.0) + 1.0)
    , 0.0, 1.0)) + FogColor.xyz) + (FogColor3.xyz * (tmpvar_100 * tmpvar_100)))
  ) * xlv_TEXCOORD3.w));
  OUT_13.xyz = (OUT_13.xyz * EnvInfo.z);
  OUT_13.xyz = clamp (OUT_13.xyz, vec3(0.0, 0.0, 0.0), vec3(4.0, 4.0, 4.0));
  highp vec3 tmpvar_102;
  tmpvar_102.x = FogColor.w;
  tmpvar_102.y = FogColor2.w;
  tmpvar_102.z = FogColor3.w;
  OUT_13.xyz = (OUT_13.xyz * tmpvar_102);
  OUT_13.xyz = (OUT_13.xyz / ((OUT_13.xyz * 0.9661836) + 0.180676));
  highp float tmpvar_103;
  tmpvar_103 = float(((
    clamp (cGrayPencent, 0.0, 1.0)
   + UserData[2].x) >= 2.0));
  OUT_13.xyz = ((OUT_13.xyz * (1.0 - tmpvar_103)) + (tmpvar_103 * dot (OUT_13.xyz, vec3(0.3, 0.59, 0.11))));
  OUT_13.w = 1.0;
  SV_Target = OUT_13;
}

 