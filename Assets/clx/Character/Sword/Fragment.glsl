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
  mask_23 = Alpha_19;
  mediump vec4 tmpvar_25;
  tmpvar_25.w = 1.0;
  tmpvar_25.xyz = BaseColor_14;
  base_color_data_22 = tmpvar_25;
  highp vec3 tmpvar_26;
  tmpvar_26.x = dot (cColorTransform0, base_color_data_22);
  tmpvar_26.y = dot (cColorTransform1, base_color_data_22);
  tmpvar_26.z = dot (cColorTransform2, base_color_data_22);
  highp vec3 tmpvar_27;
  tmpvar_27 = ((BaseColor_14 * (1.0 - mask_23)) + (clamp (tmpvar_26, 0.0, 1.0) * mask_23));
  BaseColor_14 = tmpvar_27;
  Emission_17.xyz = vec3(0.0, 0.0, 0.0);
  mediump vec3 tmpvar_28;
  tmpvar_28 = texture (sMixSampler, xlv_TEXCOORD0.xy).xyz;
  mediump float rain_29;
  rain_29 = (EnvInfo.x * 0.5);
  highp float tmpvar_30;
  tmpvar_30 = clamp (((
    (3.0 * xlv_TEXCOORD2.y)
   + 0.2) + (0.1 * rain_29)), 0.0, 1.0);
  rain_29 = (1.0 - (rain_29 * tmpvar_30));
  mediump float tmpvar_31;
  tmpvar_31 = clamp ((rain_29 - (rain_29 * tmpvar_28.x)), 0.05, 1.0);
  mediump vec4 tmpvar_32;
  tmpvar_32 = texture (sNormalSampler, xlv_TEXCOORD0.xy, cNormalMapBias);
  tangentNormal_21.w = tmpvar_32.w;
  SSSmask_20 = (1.0 - tmpvar_32.w);
  tangentNormal_21.xyz = ((tmpvar_32.xyz * 2.0) - 1.0);
  tangentNormal_21.xy = (tangentNormal_21.xy * cParamter.w);
  N_16 = (((xlv_TEXCOORD4 * tangentNormal_21.x) + (xlv_TEXCOORD5 * tangentNormal_21.y)) + (xlv_TEXCOORD2.xyz * tangentNormal_21.z));
  highp float tmpvar_33;
  tmpvar_33 = sqrt(dot (N_16, N_16));
  N_16 = (N_16 / tmpvar_33);
  highp float tmpvar_34;
  tmpvar_34 = clamp ((tmpvar_31 + min (0.4, 
    ((cAliasingFactor * 10.0) * clamp ((1.0 - tmpvar_33), 0.0, 1.0))
  )), 0.0, 1.0);
  Roughness_15 = tmpvar_34;
  highp vec3 tmpvar_35;
  tmpvar_35.x = dot (cColorTransform3, base_color_data_22);
  tmpvar_35.y = dot (cColorTransform4, base_color_data_22);
  tmpvar_35.z = dot (cColorTransform5, base_color_data_22);
  highp vec3 tmpvar_36;
  tmpvar_36 = ((BaseColor_14 * (1.0 - SSSmask_20)) + (clamp (tmpvar_35, 0.0, 1.0) * SSSmask_20));
  BaseColor_14 = tmpvar_36;
  Emission_17.w = cEmissionScale.w;
  mediump vec4 linearColor_37;
  mediump vec3 nSquared_38;
  highp vec3 tmpvar_39;
  tmpvar_39 = (N_16 * N_16);
  nSquared_38 = tmpvar_39;
  highp ivec3 tmpvar_40;
  tmpvar_40 = ivec3(lessThan (N_16, vec3(0.0, 0.0, 0.0)));
  highp vec4 tmpvar_41;
  tmpvar_41 = (((nSquared_38.x * cPointCloud[tmpvar_40.x]) + (nSquared_38.y * cPointCloud[
    (tmpvar_40.y + 2)
  ])) + (nSquared_38.z * cPointCloud[(tmpvar_40.z + 4)]));
  linearColor_37 = tmpvar_41;
  linearColor_37.xyz = max (vec3(0.9, 0.9, 0.9), linearColor_37.xyz);
  highp vec3 tmpvar_42;
  tmpvar_42 = vec3((ShadowColor.x * (10.0 + (
    (cPointCloud[3].w * ShadowColor.z)
   * 100.0))));
  linearColor_37.xyz = (linearColor_37.xyz * tmpvar_42);
  GILighting_18.xyz = linearColor_37.xyz;
  GILighting_18.w = tmpvar_28.z;
  GILighting_12.w = GILighting_18.w;
  OUT_13.w = Alpha_19;
  highp vec3 tmpvar_43;
  tmpvar_43 = (xlv_TEXCOORD6.xyz / xlv_TEXCOORD6.w);
  highp float tmpvar_44;
  tmpvar_44 = min (0.99999, tmpvar_43.z);
  highp vec2 tmpvar_45;
  tmpvar_45 = vec2(lessThan (abs(
    (tmpvar_43.xy - 0.5)
  ), vec2(0.5, 0.5)));
  inRange_9 = tmpvar_45;
  inRange_9.x = (inRange_9.x * inRange_9.y);
  highp float inShadow_46;
  highp vec3 sampleDepth3_47;
  highp vec3 sampleDepth2_48;
  highp vec3 sampleDepth1_49;
  highp float tmpvar_50;
  tmpvar_50 = -(cShadowFilterScale);
  sampleDepth1_49.x = dot (texture (sShadowMapSampler, (tmpvar_43.xy + (cShadowBias.ww * vec2(tmpvar_50)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_51;
  tmpvar_51.x = 0.0;
  tmpvar_51.y = tmpvar_50;
  sampleDepth1_49.y = dot (texture (sShadowMapSampler, (tmpvar_43.xy + (cShadowBias.ww * tmpvar_51))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_52;
  tmpvar_52.x = cShadowFilterScale;
  tmpvar_52.y = tmpvar_50;
  sampleDepth1_49.z = dot (texture (sShadowMapSampler, (tmpvar_43.xy + (cShadowBias.ww * tmpvar_52))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_53;
  tmpvar_53.y = 0.0;
  tmpvar_53.x = tmpvar_50;
  sampleDepth2_48.x = dot (texture (sShadowMapSampler, (tmpvar_43.xy + (cShadowBias.ww * tmpvar_53))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth2_48.y = dot (texture (sShadowMapSampler, tmpvar_43.xy), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_54;
  tmpvar_54.y = 0.0;
  tmpvar_54.x = cShadowFilterScale;
  sampleDepth2_48.z = dot (texture (sShadowMapSampler, (tmpvar_43.xy + (cShadowBias.ww * tmpvar_54))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_55;
  tmpvar_55.x = tmpvar_50;
  tmpvar_55.y = cShadowFilterScale;
  sampleDepth3_47.x = dot (texture (sShadowMapSampler, (tmpvar_43.xy + (cShadowBias.ww * tmpvar_55))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_56;
  tmpvar_56.x = 0.0;
  tmpvar_56.y = cShadowFilterScale;
  sampleDepth3_47.y = dot (texture (sShadowMapSampler, (tmpvar_43.xy + (cShadowBias.ww * tmpvar_56))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth3_47.z = dot (texture (sShadowMapSampler, (tmpvar_43.xy + (cShadowBias.ww * vec2(cShadowFilterScale)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec3 tmpvar_57;
  tmpvar_57 = vec3(greaterThan (vec3(tmpvar_44), sampleDepth2_48));
  highp vec2 tmpvar_58;
  tmpvar_58 = fract((tmpvar_43.xy / cShadowBias.ww));
  highp vec4 tmpvar_59;
  tmpvar_59 = ((vec3(
    greaterThan (vec3(tmpvar_44), sampleDepth1_49)
  ).xyyz * (1.0 - tmpvar_58.y)) + (tmpvar_57.xyyz * tmpvar_58.y));
  highp vec4 tmpvar_60;
  tmpvar_60 = ((tmpvar_57.xyyz * (1.0 - tmpvar_58.y)) + (vec3(
    greaterThan (vec3(tmpvar_44), sampleDepth3_47)
  ).xyyz * tmpvar_58.y));
  inShadow_46 = ((tmpvar_59.x * (1.0 - tmpvar_58.x)) + (tmpvar_59.y * tmpvar_58.x));
  inShadow_46 = (inShadow_46 + ((tmpvar_59.z * 
    (1.0 - tmpvar_58.x)
  ) + (tmpvar_59.w * tmpvar_58.x)));
  inShadow_46 = (inShadow_46 + ((tmpvar_60.x * 
    (1.0 - tmpvar_58.x)
  ) + (tmpvar_60.y * tmpvar_58.x)));
  inShadow_46 = (inShadow_46 + ((tmpvar_60.z * 
    (1.0 - tmpvar_58.x)
  ) + (tmpvar_60.w * tmpvar_58.x)));
  inShadow_46 = (inShadow_46 * 0.25);
  shadow2_10 = inShadow_46;
  shadow2_10 = (shadow2_10 * inRange_9.x);
  shadow2_10 = (1.0 - shadow2_10);
  shadow_11 = min (1.0, shadow2_10);
  SpecularColor_7 = ((vec3(0.04, 0.04, 0.04) * (1.0 - tmpvar_28.yyy)) + (BaseColor_14 * tmpvar_28.yyy));
  DiffuseColor_8 = ((BaseColor_14 - (BaseColor_14 * tmpvar_28.y)) / 3.141593);
  highp vec3 tmpvar_61;
  tmpvar_61 = normalize(-(xlv_TEXCOORD3.xyz));
  highp vec3 I_62;
  I_62 = -(tmpvar_61);
  R_6 = (I_62 - (2.0 * (
    dot (N_16, I_62)
   * N_16)));
  mediump float color_63;
  color_63 = clamp (dot (N_16, tmpvar_61), 0.0, 1.0);
  mediump float color_64;
  color_64 = dot (SunDirection.xyz, N_16);
  shadow_11 = (shadow_11 * clamp ((
    (abs(color_64) + ((2.0 * tmpvar_28.z) * tmpvar_28.z))
   - 1.0), 0.0, 1.0));
  highp float tmpvar_65;
  tmpvar_65 = (((1.0 - SSSmask_20) + (
    (UserData[1].x * 2.0)
   * SSSmask_20)) * ShadowColor.y);
  SunlightOffset_4 = tmpvar_65;
  shadow_11 = (shadow_11 * SunlightOffset_4);
  shadow_11 = (shadow_11 * cPointCloud[0].w);
  GILighting_12.xyz = ((linearColor_37.xyz * (1.0 - SSSmask_20)) + ((
    (linearColor_37.xyz * UserData[1].y)
   * 2.0) * SSSmask_20));
  diffLighting_5 = (GILighting_12.xyz * tmpvar_28.z);
  GILighting_12.w = (tmpvar_28.z * clamp (dot (diffLighting_5, vec3(0.3, 0.59, 0.11)), 0.0, 1.0));
  mediump vec3 tmpvar_66;
  tmpvar_66 = ((clamp (color_64, 0.0, 1.0) * shadow_11) * SunColor.xyz);
  diffLighting_5 = (diffLighting_5 + tmpvar_66);
  mediump float G_67;
  highp float D_68;
  highp float m_69;
  mediump vec3 sunSpec_70;
  mediump vec3 Spec_71;
  mediump vec3 tmpvar_72;
  mediump vec4 tmpvar_73;
  tmpvar_73 = ((Roughness_15 * vec4(-1.0, -0.0275, -0.572, 0.022)) + vec4(1.0, 0.0425, 1.04, -0.04));
  mediump vec2 tmpvar_74;
  tmpvar_74 = ((vec2(-1.04, 1.04) * (
    (min ((tmpvar_73.x * tmpvar_73.x), exp2((-9.28 * color_63))) * tmpvar_73.x)
   + tmpvar_73.y)) + tmpvar_73.zw);
  tmpvar_72 = ((SpecularColor_7 * tmpvar_74.x) + tmpvar_74.y);
  highp vec3 R_75;
  R_75.z = R_6.z;
  mediump float fSign_76;
  mediump vec3 sampleEnvSpecular_77;
  highp float tmpvar_78;
  tmpvar_78 = float((R_6.z > 0.0));
  fSign_76 = tmpvar_78;
  mediump float tmpvar_79;
  tmpvar_79 = ((fSign_76 * 2.0) - 1.0);
  R_75.xy = (R_6.xy / ((R_6.z * tmpvar_79) + 1.0));
  R_75.xy = ((R_75.xy * vec2(0.25, -0.25)) + (0.25 + (0.5 * fSign_76)));
  mediump vec4 tmpvar_80;
  tmpvar_80 = textureLod (sEnvSampler, R_75.xy, (Roughness_15 / 0.17));
  sampleEnvSpecular_77 = (tmpvar_80.xyz * ((tmpvar_80.w * tmpvar_80.w) * 16.0));
  sampleEnvSpecular_77 = (sampleEnvSpecular_77 * ((cEnvStrength * GILighting_12.w) * (EnvInfo.w * 10.0)));
  highp vec3 tmpvar_81;
  tmpvar_81 = normalize((tmpvar_61 + SunDirection.xyz));
  highp float tmpvar_82;
  tmpvar_82 = clamp (dot (N_16, tmpvar_81), 0.0, 1.0);
  highp float tmpvar_83;
  tmpvar_83 = clamp (dot (tmpvar_61, tmpvar_81), 0.0, 1.0);
  mediump float tmpvar_84;
  tmpvar_84 = max (0.08, Roughness_15);
  mediump float tmpvar_85;
  tmpvar_85 = (tmpvar_84 * tmpvar_84);
  m_69 = tmpvar_85;
  highp float tmpvar_86;
  tmpvar_86 = (m_69 * m_69);
  highp float tmpvar_87;
  tmpvar_87 = (((
    (tmpvar_82 * tmpvar_86)
   - tmpvar_82) * tmpvar_82) + 1.0);
  D_68 = (tmpvar_86 / ((tmpvar_87 * tmpvar_87) * 3.141593));
  highp float tmpvar_88;
  tmpvar_88 = (m_69 * 0.5);
  mediump float tmpvar_89;
  tmpvar_89 = clamp (color_64, 0.0, 1.0);
  highp float tmpvar_90;
  tmpvar_90 = (0.25 / ((
    (color_63 * (1.0 - tmpvar_88))
   + tmpvar_88) * (
    (tmpvar_89 * (1.0 - tmpvar_88))
   + tmpvar_88)));
  G_67 = tmpvar_90;
  mediump float color_91;
  color_91 = exp2(((
    (-5.55473 * tmpvar_83)
   - 6.98316) * tmpvar_83));
  sunSpec_70 = ((D_68 * G_67) * (tmpvar_72 + (
    (clamp ((50.0 * tmpvar_72.y), 0.0, 1.0) - tmpvar_72)
   * color_91)));
  sunSpec_70 = (sunSpec_70 * (SunColor.xyz * clamp (
    (color_64 * shadow_11)
  , 0.0, 1.0)));
  Spec_71 = ((tmpvar_72 * sampleEnvSpecular_77) + sunSpec_70);
  SpecularColor_7 = tmpvar_72;
  OUT_13.xyz = Spec_71;
  highp vec3 tmpvar_92;
  tmpvar_92 = normalize(cVirtualLitDir.xyz);
  mediump float color_93;
  color_93 = clamp (dot (tmpvar_92, N_16), 0.0, 1.0);
  mediump vec3 color_94;
  color_94 = (cVirtualLitColor.xyz * (Emission_17.w * (0.444 + 
    (color_93 * 0.556)
  )));
  virtualLit_3 = ((color_94 * (1.0 - SSSmask_20)) + ((
    (color_94 * UserData[1].z)
   * 2.0) * SSSmask_20));
  diffLighting_5 = (diffLighting_5 + virtualLit_3);
  highp float tmpvar_95;
  tmpvar_95 = clamp (dot (N_16, normalize(
    (tmpvar_61 + tmpvar_92)
  )), 0.0, 1.0);
  mediump float tmpvar_96;
  tmpvar_96 = ((Roughness_15 * Roughness_15) + 0.0002);
  m2_2 = tmpvar_96;
  m2_2 = (m2_2 * m2_2);
  highp float tmpvar_97;
  tmpvar_97 = (((
    (tmpvar_95 * m2_2)
   - tmpvar_95) * tmpvar_95) + 1.0);
  D_1 = ((tmpvar_97 * tmpvar_97) + 1e-06);
  D_1 = ((0.25 * m2_2) / D_1);
  OUT_13.xyz = (OUT_13.xyz + ((virtualLit_3 * tmpvar_72) * D_1));
  OUT_13.xyz = OUT_13.xyz;
  OUT_13.xyz = (OUT_13.xyz + (diffLighting_5 * DiffuseColor_8));
  mediump float tmpvar_98;
  tmpvar_98 = max (0.5, clamp ((1.0 + 
    (shadow_11 * 0.5)
  ), 0.0, 1.0));
  OUT_13.xyz = (OUT_13.xyz * tmpvar_98);
  highp float tmpvar_99;
  tmpvar_99 = clamp (dot (-(tmpvar_61), SunDirection.xyz), 0.0, 1.0);
  highp float tmpvar_100;
  tmpvar_100 = (1.0 - xlv_TEXCOORD3.w);
  OUT_13.xyz = ((OUT_13.xyz * tmpvar_100) + ((
    (OUT_13.xyz * tmpvar_100)
   + 
    (((FogColor2.xyz * clamp (
      ((tmpvar_61.y * 5.0) + 1.0)
    , 0.0, 1.0)) + FogColor.xyz) + (FogColor3.xyz * (tmpvar_99 * tmpvar_99)))
  ) * xlv_TEXCOORD3.w));
  OUT_13.xyz = (OUT_13.xyz * EnvInfo.z);
  OUT_13.xyz = clamp (OUT_13.xyz, vec3(0.0, 0.0, 0.0), vec3(4.0, 4.0, 4.0));
  highp vec3 tmpvar_101;
  tmpvar_101.x = FogColor.w;
  tmpvar_101.y = FogColor2.w;
  tmpvar_101.z = FogColor3.w;
  OUT_13.xyz = (OUT_13.xyz * tmpvar_101);
  OUT_13.xyz = (OUT_13.xyz / ((OUT_13.xyz * 0.9661836) + 0.180676));
  highp float tmpvar_102;
  tmpvar_102 = float(((
    clamp (cGrayPencent, 0.0, 1.0)
   + UserData[2].x) >= 2.0));
  OUT_13.xyz = ((OUT_13.xyz * (1.0 - tmpvar_102)) + (tmpvar_102 * dot (OUT_13.xyz, vec3(0.3, 0.59, 0.11))));
  OUT_13.w = 1.0;
  SV_Target = OUT_13;
}

 