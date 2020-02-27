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
uniform highp float cRoughnessX;
uniform highp float cRoughnessY;
uniform highp float cAnisotropicScale;
uniform highp float cGrayPencent;
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
  mediump float SunlightOffset_3;
  mediump vec3 diffLighting_4;
  highp vec3 R_5;
  mediump vec3 SpecularColor_6;
  mediump vec3 DiffuseColor_7;
  mediump vec2 inRange_8;
  mediump float shadow2_9;
  mediump float shadow_10;
  mediump vec4 GILighting_11;
  highp vec4 OUT_12;
  mediump vec3 BaseColor_13;
  mediump float Roughness_14;
  highp vec3 N_15;
  mediump vec4 Emission_16;
  mediump vec4 GILighting_17;
  mediump float Alpha_18;
  mediump float virtualAniso_19;
  mediump float directAniso_20;
  mediump vec3 virtualRadiance_21;
  mediump vec3 inputRadiance_22;
  mediump float VirtualLitNoL_23;
  mediump float NoL_24;
  mediump vec3 V_25;
  mediump float RoughnessY_26;
  mediump float RoughnessX_27;
  mediump vec3 tangentNormal_28;
  mediump vec4 color_29;
  color_29 = texture (sBaseSampler, xlv_TEXCOORD0.xy, cBaseMapBias);
  BaseColor_13 = (color_29.xyz * color_29.xyz);
  Alpha_18 = color_29.w;
  mediump vec3 color_30;
  color_30 = texture (sMixSampler, xlv_TEXCOORD0.xy).xyz;
  mediump float rr_31;
  highp float tmpvar_32;
  tmpvar_32 = (EnvInfo.x * 0.5);
  rr_31 = tmpvar_32;
  highp float tmpvar_33;
  tmpvar_33 = clamp (((
    (3.0 * xlv_TEXCOORD2.y)
   + 0.2) + (0.1 * rr_31)), 0.0, 1.0);
  rr_31 = (rr_31 * tmpvar_33);
  Roughness_14 = (((1.0 - rr_31) * (1.0 - color_30.x)) + (0.05 * color_30.x));
  tangentNormal_28 = ((2.0 * texture (sNormalSampler, xlv_TEXCOORD0.xy, cNormalMapBias).xyz) - 1.0);
  tangentNormal_28.xy = (tangentNormal_28.xy * (cParamter.w * cParamter.w));
  N_15 = (((tangentNormal_28.x * xlv_TEXCOORD4) + (tangentNormal_28.y * xlv_TEXCOORD5)) + (tangentNormal_28.z * xlv_TEXCOORD2.xyz));
  highp float tmpvar_34;
  tmpvar_34 = sqrt(dot (N_15, N_15));
  N_15 = (N_15 / tmpvar_34);
  highp float tmpvar_35;
  tmpvar_35 = clamp ((Roughness_14 + min (0.4, 
    ((cAliasingFactor * 10.0) * clamp ((1.0 - tmpvar_34), 0.0, 1.0))
  )), 0.0, 1.0);
  Roughness_14 = tmpvar_35;
  highp vec4 tmpvar_36;
  tmpvar_36.xyz = vec3(0.0, 0.0, 0.0);
  tmpvar_36.w = cEmissionScale.w;
  Emission_16.w = tmpvar_36.w;
  highp float tmpvar_37;
  tmpvar_37 = ((cRoughnessX * Roughness_14) + 1e-06);
  RoughnessX_27 = tmpvar_37;
  highp float tmpvar_38;
  tmpvar_38 = ((cRoughnessY * Roughness_14) + 1e-06);
  RoughnessY_26 = tmpvar_38;
  highp vec3 tmpvar_39;
  highp vec3 tmpvar_40;
  tmpvar_40 = -(xlv_TEXCOORD3.xyz);
  tmpvar_39 = normalize(tmpvar_40);
  V_25 = tmpvar_39;
  highp float tmpvar_41;
  tmpvar_41 = max (0.001, dot (N_15, SunDirection.xyz));
  NoL_24 = tmpvar_41;
  highp float tmpvar_42;
  tmpvar_42 = max (0.001, dot (N_15, V_25));
  VirtualLitNoL_23 = tmpvar_42;
  highp vec3 tmpvar_43;
  tmpvar_43 = (SunColor * NoL_24).xyz;
  inputRadiance_22 = tmpvar_43;
  inputRadiance_22 = (inputRadiance_22 * cPointCloud[0].w);
  highp vec3 tmpvar_44;
  tmpvar_44 = (((VirtualLitNoL_23 * cVirtualLitColor.xyz) * UserData[1].z) * 2.0);
  virtualRadiance_21 = tmpvar_44;
  mediump vec3 L_45;
  L_45 = SunDirection.xyz;
  mediump vec3 N_46;
  N_46 = N_15;
  mediump vec3 Tangent_47;
  Tangent_47 = xlv_TEXCOORD4;
  mediump vec3 Binormal_48;
  Binormal_48 = xlv_TEXCOORD5;
  mediump float aniso_49;
  highp vec2 beta_50;
  mediump vec3 x_51;
  x_51 = (L_45 + V_25);
  mediump vec3 tmpvar_52;
  tmpvar_52 = ((L_45 + V_25) / max (0.001, sqrt(
    dot (x_51, x_51)
  )));
  mediump vec2 tmpvar_53;
  tmpvar_53.x = (dot (tmpvar_52, Tangent_47) / RoughnessX_27);
  tmpvar_53.y = (dot (tmpvar_52, Binormal_48) / RoughnessY_26);
  beta_50 = tmpvar_53;
  beta_50 = (beta_50 * beta_50);
  mediump float tmpvar_54;
  tmpvar_54 = max (0.001, ((
    (314.1593 * RoughnessX_27)
   * RoughnessY_26) * sqrt(
    (NoL_24 * max (0.001, dot (V_25, N_46)))
  )));
  mediump float tmpvar_55;
  tmpvar_55 = max (0.01, (0.5 + (0.5 * 
    dot (tmpvar_52, N_46)
  )));
  highp float tmpvar_56;
  tmpvar_56 = (exp((
    -((beta_50.x + beta_50.y))
   / tmpvar_55)) / tmpvar_54);
  aniso_49 = tmpvar_56;
  highp float tmpvar_57;
  tmpvar_57 = (cAnisotropicScale * aniso_49);
  directAniso_20 = tmpvar_57;
  mediump vec3 N_58;
  N_58 = N_15;
  mediump vec3 Tangent_59;
  Tangent_59 = xlv_TEXCOORD4;
  mediump vec3 Binormal_60;
  Binormal_60 = xlv_TEXCOORD5;
  mediump float aniso_61;
  highp vec2 beta_62;
  mediump vec3 x_63;
  x_63 = (V_25 + V_25);
  mediump vec3 tmpvar_64;
  tmpvar_64 = ((V_25 + V_25) / max (0.001, sqrt(
    dot (x_63, x_63)
  )));
  mediump vec2 tmpvar_65;
  tmpvar_65.x = (dot (tmpvar_64, Tangent_59) / RoughnessX_27);
  tmpvar_65.y = (dot (tmpvar_64, Binormal_60) / RoughnessY_26);
  beta_62 = tmpvar_65;
  beta_62 = (beta_62 * beta_62);
  mediump float tmpvar_66;
  tmpvar_66 = max (0.001, ((
    (314.1593 * RoughnessX_27)
   * RoughnessY_26) * sqrt(
    (VirtualLitNoL_23 * max (0.001, dot (V_25, N_58)))
  )));
  mediump float tmpvar_67;
  tmpvar_67 = max (0.01, (0.5 + (0.5 * 
    dot (tmpvar_64, N_58)
  )));
  highp float tmpvar_68;
  tmpvar_68 = (exp((
    -((beta_62.x + beta_62.y))
   / tmpvar_67)) / tmpvar_66);
  aniso_61 = tmpvar_68;
  highp float tmpvar_69;
  tmpvar_69 = (cAnisotropicScale * aniso_61);
  virtualAniso_19 = tmpvar_69;
  Emission_16.xyz = (inputRadiance_22 * directAniso_20);
  BaseColor_13 = (BaseColor_13 + (virtualRadiance_21 * virtualAniso_19));
  BaseColor_13 = min (BaseColor_13, 10.0);
  Emission_16.xyz = (Emission_16.xyz * (color_30.z * color_29.w));
  Emission_16.xyz = min (Emission_16.xyz, 10.0);
  mediump vec4 linearColor_70;
  mediump vec3 nSquared_71;
  highp vec3 tmpvar_72;
  tmpvar_72 = (N_15 * N_15);
  nSquared_71 = tmpvar_72;
  highp ivec3 tmpvar_73;
  tmpvar_73 = ivec3(lessThan (N_15, vec3(0.0, 0.0, 0.0)));
  highp vec4 tmpvar_74;
  tmpvar_74 = (((nSquared_71.x * cPointCloud[tmpvar_73.x]) + (nSquared_71.y * cPointCloud[
    (tmpvar_73.y + 2)
  ])) + (nSquared_71.z * cPointCloud[(tmpvar_73.z + 4)]));
  linearColor_70 = tmpvar_74;
  linearColor_70.xyz = max (vec3(0.9, 0.9, 0.9), linearColor_70.xyz);
  highp vec3 tmpvar_75;
  tmpvar_75 = vec3((ShadowColor.x * (10.0 + (
    (cPointCloud[3].w * ShadowColor.z)
   * 100.0))));
  linearColor_70.xyz = (linearColor_70.xyz * tmpvar_75);
  GILighting_17.xyz = linearColor_70.xyz;
  GILighting_17.w = color_30.z;
  OUT_12.w = Alpha_18;
  highp vec3 tmpvar_76;
  tmpvar_76 = (xlv_TEXCOORD6.xyz / xlv_TEXCOORD6.w);
  highp float tmpvar_77;
  tmpvar_77 = min (0.99999, tmpvar_76.z);
  highp vec2 tmpvar_78;
  tmpvar_78 = vec2(lessThan (abs(
    (tmpvar_76.xy - 0.5)
  ), vec2(0.5, 0.5)));
  inRange_8 = tmpvar_78;
  inRange_8.x = (inRange_8.x * inRange_8.y);
  highp float inShadow_79;
  highp vec3 sampleDepth3_80;
  highp vec3 sampleDepth2_81;
  highp vec3 sampleDepth1_82;
  sampleDepth1_82.x = dot (texture (sShadowMapSampler, (tmpvar_76.xy - cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth1_82.y = dot (texture (sShadowMapSampler, (tmpvar_76.xy + (cShadowBias.ww * vec2(0.0, -1.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth1_82.z = dot (texture (sShadowMapSampler, (tmpvar_76.xy + (cShadowBias.ww * vec2(1.0, -1.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth2_81.x = dot (texture (sShadowMapSampler, (tmpvar_76.xy + (cShadowBias.ww * vec2(-1.0, 0.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth2_81.y = dot (texture (sShadowMapSampler, tmpvar_76.xy), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth2_81.z = dot (texture (sShadowMapSampler, (tmpvar_76.xy + (cShadowBias.ww * vec2(1.0, 0.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth3_80.x = dot (texture (sShadowMapSampler, (tmpvar_76.xy + (cShadowBias.ww * vec2(-1.0, 1.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth3_80.y = dot (texture (sShadowMapSampler, (tmpvar_76.xy + (cShadowBias.ww * vec2(0.0, 1.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth3_80.z = dot (texture (sShadowMapSampler, (tmpvar_76.xy + cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec3 tmpvar_83;
  tmpvar_83 = vec3(greaterThan (vec3(tmpvar_77), sampleDepth2_81));
  highp vec2 tmpvar_84;
  tmpvar_84 = fract((tmpvar_76.xy / cShadowBias.ww));
  highp vec4 tmpvar_85;
  tmpvar_85 = ((vec3(
    greaterThan (vec3(tmpvar_77), sampleDepth1_82)
  ).xyyz * (1.0 - tmpvar_84.y)) + (tmpvar_83.xyyz * tmpvar_84.y));
  highp vec4 tmpvar_86;
  tmpvar_86 = ((tmpvar_83.xyyz * (1.0 - tmpvar_84.y)) + (vec3(
    greaterThan (vec3(tmpvar_77), sampleDepth3_80)
  ).xyyz * tmpvar_84.y));
  inShadow_79 = ((tmpvar_85.x * (1.0 - tmpvar_84.x)) + (tmpvar_85.y * tmpvar_84.x));
  inShadow_79 = (inShadow_79 + ((tmpvar_85.z * 
    (1.0 - tmpvar_84.x)
  ) + (tmpvar_85.w * tmpvar_84.x)));
  inShadow_79 = (inShadow_79 + ((tmpvar_86.x * 
    (1.0 - tmpvar_84.x)
  ) + (tmpvar_86.y * tmpvar_84.x)));
  inShadow_79 = (inShadow_79 + ((tmpvar_86.z * 
    (1.0 - tmpvar_84.x)
  ) + (tmpvar_86.w * tmpvar_84.x)));
  inShadow_79 = (inShadow_79 * 0.25);
  shadow2_9 = inShadow_79;
  shadow2_9 = (shadow2_9 * inRange_8.x);
  shadow2_9 = (1.0 - shadow2_9);
  shadow_10 = min (1.0, shadow2_9);
  SpecularColor_6 = ((vec3(0.04, 0.04, 0.04) * (1.0 - color_30.yyy)) + (BaseColor_13 * color_30.yyy));
  DiffuseColor_7 = ((BaseColor_13 - (BaseColor_13 * color_30.y)) / 3.141593);
  highp vec3 tmpvar_87;
  tmpvar_87 = normalize(tmpvar_40);
  highp vec3 I_88;
  I_88 = -(tmpvar_87);
  R_5 = (I_88 - (2.0 * (
    dot (N_15, I_88)
   * N_15)));
  mediump float color_89;
  color_89 = clamp (dot (N_15, tmpvar_87), 0.0, 1.0);
  mediump float color_90;
  color_90 = dot (SunDirection.xyz, N_15);
  shadow_10 = (shadow_10 * clamp ((
    (abs(color_90) + ((2.0 * color_30.z) * color_30.z))
   - 1.0), 0.0, 1.0));
  highp float tmpvar_91;
  tmpvar_91 = ShadowColor.y;
  SunlightOffset_3 = tmpvar_91;
  shadow_10 = (shadow_10 * SunlightOffset_3);
  shadow_10 = (shadow_10 * cPointCloud[0].w);
  GILighting_11.xyz = GILighting_17.xyz;
  diffLighting_4 = (linearColor_70.xyz * color_30.z);
  GILighting_11.w = (color_30.z * clamp (dot (diffLighting_4, vec3(0.3, 0.59, 0.11)), 0.0, 1.0));
  mediump vec3 tmpvar_92;
  tmpvar_92 = ((clamp (color_90, 0.0, 1.0) * shadow_10) * SunColor.xyz);
  diffLighting_4 = (diffLighting_4 + tmpvar_92);
  mediump float G_93;
  highp float D_94;
  highp float m_95;
  mediump vec3 sunSpec_96;
  mediump vec3 Spec_97;
  mediump vec3 tmpvar_98;
  mediump vec4 tmpvar_99;
  tmpvar_99 = ((Roughness_14 * vec4(-1.0, -0.0275, -0.572, 0.022)) + vec4(1.0, 0.0425, 1.04, -0.04));
  mediump vec2 tmpvar_100;
  tmpvar_100 = ((vec2(-1.04, 1.04) * (
    (min ((tmpvar_99.x * tmpvar_99.x), exp2((-9.28 * color_89))) * tmpvar_99.x)
   + tmpvar_99.y)) + tmpvar_99.zw);
  tmpvar_98 = ((SpecularColor_6 * tmpvar_100.x) + tmpvar_100.y);
  highp vec3 R_101;
  R_101.z = R_5.z;
  mediump float fSign_102;
  mediump vec3 sampleEnvSpecular_103;
  highp float tmpvar_104;
  tmpvar_104 = float((R_5.z > 0.0));
  fSign_102 = tmpvar_104;
  mediump float tmpvar_105;
  tmpvar_105 = ((fSign_102 * 2.0) - 1.0);
  R_101.xy = (R_5.xy / ((R_5.z * tmpvar_105) + 1.0));
  R_101.xy = ((R_101.xy * vec2(0.25, -0.25)) + (0.25 + (0.5 * fSign_102)));
  mediump vec4 tmpvar_106;
  tmpvar_106 = textureLod (sEnvSampler, R_101.xy, (Roughness_14 / 0.17));
  sampleEnvSpecular_103 = (tmpvar_106.xyz * ((tmpvar_106.w * tmpvar_106.w) * 16.0));
  sampleEnvSpecular_103 = (sampleEnvSpecular_103 * ((cEnvStrength * GILighting_11.w) * (EnvInfo.w * 10.0)));
  highp vec3 tmpvar_107;
  tmpvar_107 = normalize((tmpvar_87 + SunDirection.xyz));
  highp float tmpvar_108;
  tmpvar_108 = clamp (dot (N_15, tmpvar_107), 0.0, 1.0);
  highp float tmpvar_109;
  tmpvar_109 = clamp (dot (tmpvar_87, tmpvar_107), 0.0, 1.0);
  mediump float tmpvar_110;
  tmpvar_110 = max (0.08, Roughness_14);
  mediump float tmpvar_111;
  tmpvar_111 = (tmpvar_110 * tmpvar_110);
  m_95 = tmpvar_111;
  highp float tmpvar_112;
  tmpvar_112 = (m_95 * m_95);
  highp float tmpvar_113;
  tmpvar_113 = (((
    (tmpvar_108 * tmpvar_112)
   - tmpvar_108) * tmpvar_108) + 1.0);
  D_94 = (tmpvar_112 / ((tmpvar_113 * tmpvar_113) * 3.141593));
  highp float tmpvar_114;
  tmpvar_114 = (m_95 * 0.5);
  mediump float tmpvar_115;
  tmpvar_115 = clamp (color_90, 0.0, 1.0);
  highp float tmpvar_116;
  tmpvar_116 = (0.25 / ((
    (color_89 * (1.0 - tmpvar_114))
   + tmpvar_114) * (
    (tmpvar_115 * (1.0 - tmpvar_114))
   + tmpvar_114)));
  G_93 = tmpvar_116;
  mediump float color_117;
  color_117 = exp2(((
    (-5.55473 * tmpvar_109)
   - 6.98316) * tmpvar_109));
  sunSpec_96 = ((D_94 * G_93) * (tmpvar_98 + (
    (clamp ((50.0 * tmpvar_98.y), 0.0, 1.0) - tmpvar_98)
   * color_117)));
  sunSpec_96 = (sunSpec_96 * (SunColor.xyz * clamp (
    (color_90 * shadow_10)
  , 0.0, 1.0)));
  Spec_97 = ((tmpvar_98 * sampleEnvSpecular_103) + sunSpec_96);
  SpecularColor_6 = tmpvar_98;
  OUT_12.xyz = Spec_97;
  highp vec3 tmpvar_118;
  tmpvar_118 = normalize(cVirtualLitDir.xyz);
  mediump float color_119;
  color_119 = clamp (dot (tmpvar_118, N_15), 0.0, 1.0);
  mediump vec3 color_120;
  color_120 = (cVirtualLitColor.xyz * (Emission_16.w * (0.444 + 
    (color_119 * 0.556)
  )));
  diffLighting_4 = (diffLighting_4 + color_120);
  highp float tmpvar_121;
  tmpvar_121 = clamp (dot (N_15, normalize(
    (tmpvar_87 + tmpvar_118)
  )), 0.0, 1.0);
  mediump float tmpvar_122;
  tmpvar_122 = ((Roughness_14 * Roughness_14) + 0.0002);
  m2_2 = tmpvar_122;
  m2_2 = (m2_2 * m2_2);
  highp float tmpvar_123;
  tmpvar_123 = (((
    (tmpvar_121 * m2_2)
   - tmpvar_121) * tmpvar_121) + 1.0);
  D_1 = ((tmpvar_123 * tmpvar_123) + 1e-06);
  D_1 = ((0.25 * m2_2) / D_1);
  OUT_12.xyz = (OUT_12.xyz + ((color_120 * tmpvar_98) * D_1));
  OUT_12.xyz = (OUT_12.xyz + (shadow_10 * Emission_16.xyz));
  OUT_12.xyz = (OUT_12.xyz + (diffLighting_4 * DiffuseColor_7));
  mediump float tmpvar_124;
  tmpvar_124 = max (0.5, clamp ((1.0 + 
    (shadow_10 * 0.5)
  ), 0.0, 1.0));
  OUT_12.xyz = (OUT_12.xyz * tmpvar_124);
  highp float tmpvar_125;
  tmpvar_125 = clamp (dot (-(tmpvar_87), SunDirection.xyz), 0.0, 1.0);
  highp float tmpvar_126;
  tmpvar_126 = (1.0 - xlv_TEXCOORD3.w);
  OUT_12.xyz = ((OUT_12.xyz * tmpvar_126) + ((
    (OUT_12.xyz * tmpvar_126)
   + 
    (((FogColor2.xyz * clamp (
      ((tmpvar_87.y * 5.0) + 1.0)
    , 0.0, 1.0)) + FogColor.xyz) + (FogColor3.xyz * (tmpvar_125 * tmpvar_125)))
  ) * xlv_TEXCOORD3.w));
  OUT_12.xyz = (OUT_12.xyz * EnvInfo.z);
  OUT_12.xyz = clamp (OUT_12.xyz, vec3(0.0, 0.0, 0.0), vec3(4.0, 4.0, 4.0));
  highp vec3 tmpvar_127;
  tmpvar_127.x = FogColor.w;
  tmpvar_127.y = FogColor2.w;
  tmpvar_127.z = FogColor3.w;
  OUT_12.xyz = (OUT_12.xyz * tmpvar_127);
  OUT_12.xyz = (OUT_12.xyz / ((OUT_12.xyz * 0.9661836) + 0.180676));
  highp float tmpvar_128;
  tmpvar_128 = float(((
    clamp (cGrayPencent, 0.0, 1.0)
   + UserData[2].x) >= 2.0));
  OUT_12.xyz = ((OUT_12.xyz * (1.0 - tmpvar_128)) + (tmpvar_128 * dot (OUT_12.xyz, vec3(0.3, 0.59, 0.11))));
  OUT_12.w = 1.0;
  SV_Target = OUT_12;
}

 