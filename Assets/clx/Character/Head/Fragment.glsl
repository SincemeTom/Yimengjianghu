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
uniform highp vec4 cVirtualLitDir;
uniform highp vec4 cVirtualLitColor;
uniform highp float maokong_intensity;
uniform highp float cEnvStrength;
uniform highp float RoughnessOffset2;
uniform highp float cDetailUVScale;
uniform highp float cSSSIntensity;
uniform highp float cBaseMapBias;
uniform highp float cNormalMapBias;
uniform highp vec4 cSSSColor;
uniform highp float cGrayPencent;
uniform highp vec3 cCrystalColor03;
uniform highp float cCrystalIntensity03;
uniform highp float cCrystalUVTile03;
uniform highp float cCrystalRange;
uniform highp float cCrystalVirtualLit;
uniform mediump sampler2D sBaseSampler;
uniform mediump sampler2D sMixSampler;
uniform mediump sampler2D sNormalSampler;
uniform mediump sampler2D sDetailNormalSampler;
uniform mediump sampler2D sLutMapSampler;
uniform mediump sampler2D sEnvSampler;
uniform highp sampler2D sShadowMapSampler;
uniform highp sampler2D sCrystalMap03Sampler;
uniform highp sampler2D sCrystalMaskMapSampler;
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
  highp vec3 userData_1;
  userData_1 = UserData[1].xyz;
  highp vec4 OUT_2;
  mediump vec3 CrystalVirtualSpec_3;
  mediump vec3 CrystalSunSpec_4;
  mediump vec3 CrystalSpecBRDF_5;
  mediump vec3 crystalMask_6;
  mediump vec3 crystalMap03_7;
  mediump vec3 crystalMaskMap_8;
  highp vec3 EnvBRDF_9;
  highp vec3 SpecRadiance_10;
  highp vec3 SSS_Lut1_11;
  mediump vec3 ScatterAO_12;
  highp vec3 SunIrradiance_13;
  mediump vec2 inRange_14;
  mediump float shadow_15;
  mediump float NoL_16;
  mediump float NoV_17;
  highp vec4 DetailValue_18;
  mediump vec4 tangentNormal_19;
  mediump float vertexColorW_20;
  highp vec3 SpecularMask_21;
  highp float AO_22;
  highp vec4 MixTex_23;
  highp float Roughness_24;
  highp vec4 BaseColor_25;
  mediump vec4 tmpvar_26;
  tmpvar_26 = texture (sBaseSampler, xlv_TEXCOORD0.xy, cBaseMapBias);
  BaseColor_25 = tmpvar_26;
  BaseColor_25.xyz = (BaseColor_25.xyz * BaseColor_25.xyz);
  mediump float Roughness_27;
  Roughness_27 = max ((1.0 - BaseColor_25.w), 0.03);
  mediump float rain_28;
  highp float tmpvar_29;
  tmpvar_29 = (EnvInfo.x * 0.5);
  rain_28 = tmpvar_29;
  highp float tmpvar_30;
  tmpvar_30 = clamp (((
    (3.0 * xlv_TEXCOORD2.y)
   + 0.2) + (0.1 * rain_28)), 0.0, 1.0);
  rain_28 = (1.0 - (rain_28 * tmpvar_30));
  mediump float tmpvar_31;
  tmpvar_31 = clamp ((rain_28 * Roughness_27), 0.05, 1.0);
  Roughness_24 = tmpvar_31;
  mediump vec4 tmpvar_32;
  tmpvar_32 = texture (sMixSampler, xlv_TEXCOORD0.xy);
  MixTex_23 = tmpvar_32;
  AO_22 = MixTex_23.z;
  highp float tmpvar_33;
  tmpvar_33 = (1.0 - MixTex_23.w);
  vertexColorW_20 = tmpvar_33;
  mediump vec4 color_34;
  color_34 = texture (sNormalSampler, xlv_TEXCOORD0.xy, cNormalMapBias);
  tangentNormal_19.w = color_34.w;
  tangentNormal_19.xyz = ((color_34.xyz * 2.0) - 1.0);
  highp vec3 tmpvar_35;
  tmpvar_35 = normalize(((
    (normalize(xlv_TEXCOORD4) * tangentNormal_19.x)
   + 
    (normalize(xlv_TEXCOORD5) * tangentNormal_19.y)
  ) + (
    normalize(xlv_TEXCOORD2.xyz)
   * tangentNormal_19.z)));
  mediump vec4 tmpvar_36;
  highp vec2 P_37;
  P_37 = (xlv_TEXCOORD0.xy * cDetailUVScale);
  tmpvar_36 = texture (sDetailNormalSampler, P_37);
  DetailValue_18 = tmpvar_36;
  highp vec3 tmpvar_38;
  tmpvar_38.z = 0.0;
  tmpvar_38.x = ((DetailValue_18.z * 2.0) - 1.0);
  tmpvar_38.y = ((DetailValue_18.w * 2.0) - 1.0);
  highp vec3 tmpvar_39;
  tmpvar_39 = normalize((tangentNormal_19.xyz + (
    (tmpvar_38 * 0.2)
   * 
    (maokong_intensity * color_34.w)
  )));
  highp vec3 tmpvar_40;
  tmpvar_40 = normalize(((
    (xlv_TEXCOORD4 * tmpvar_39.x)
   + 
    (xlv_TEXCOORD5 * tmpvar_39.y)
  ) + (xlv_TEXCOORD2.xyz * tmpvar_39.z)));
  SpecularMask_21 = ((vec3(0.5, 0.5, 0.5) * (1.0 - color_34.w)) + (DetailValue_18.xxx * color_34.w));
  highp vec3 tmpvar_41;
  tmpvar_41 = normalize(-(xlv_TEXCOORD3.xyz));
  highp vec3 I_42;
  I_42 = -(tmpvar_41);
  highp float tmpvar_43;
  tmpvar_43 = clamp (dot (tmpvar_35, tmpvar_41), 0.0, 1.0);
  NoV_17 = tmpvar_43;
  highp float tmpvar_44;
  tmpvar_44 = clamp (dot (tmpvar_35, SunDirection.xyz), 0.0, 1.0);
  NoL_16 = tmpvar_44;
  highp vec3 tmpvar_45;
  tmpvar_45 = (xlv_TEXCOORD6.xyz / xlv_TEXCOORD6.w);
  highp float tmpvar_46;
  tmpvar_46 = min (0.99999, tmpvar_45.z);
  highp vec2 tmpvar_47;
  tmpvar_47 = vec2(lessThan (abs(
    (tmpvar_45.xy - 0.5)
  ), vec2(0.5, 0.5)));
  inRange_14 = tmpvar_47;
  inRange_14.x = (inRange_14.x * inRange_14.y);
  highp float inShadow_48;
  highp vec4 Values3_49;
  highp vec4 Values2_50;
  highp vec4 Values1_51;
  highp vec4 Values0_52;
  highp vec2 tmpvar_53;
  tmpvar_53 = ((tmpvar_45.xy / cShadowBias.ww) - 0.5);
  highp vec2 tmpvar_54;
  tmpvar_54 = fract(tmpvar_53);
  highp vec2 tmpvar_55;
  tmpvar_55 = ((floor(tmpvar_53) + 0.5) - vec2(1.0, 1.0));
  Values0_52.x = dot (texture (sShadowMapSampler, (tmpvar_55 * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values0_52.y = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(1.0, 0.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values0_52.z = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(2.0, 0.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values0_52.w = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(3.0, 0.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec4 tmpvar_56;
  tmpvar_56 = clamp (((
    (Values0_52 - vec4(tmpvar_46))
   * 8000.0) + 1.0), 0.0, 1.0);
  Values0_52 = tmpvar_56;
  Values1_51.x = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(0.0, 1.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values1_51.y = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(1.0, 1.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values1_51.z = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(2.0, 1.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values1_51.w = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(3.0, 1.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec4 tmpvar_57;
  tmpvar_57 = clamp (((
    (Values1_51 - vec4(tmpvar_46))
   * 8000.0) + 1.0), 0.0, 1.0);
  Values1_51 = tmpvar_57;
  Values2_50.x = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(0.0, 2.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values2_50.y = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(1.0, 2.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values2_50.z = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(2.0, 2.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values2_50.w = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(3.0, 2.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec4 tmpvar_58;
  tmpvar_58 = clamp (((
    (Values2_50 - vec4(tmpvar_46))
   * 8000.0) + 1.0), 0.0, 1.0);
  Values2_50 = tmpvar_58;
  Values3_49.x = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(0.0, 3.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values3_49.y = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(1.0, 3.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values3_49.z = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(2.0, 3.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values3_49.w = dot (texture (sShadowMapSampler, ((tmpvar_55 + vec2(3.0, 3.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec4 tmpvar_59;
  tmpvar_59 = clamp (((
    (Values3_49 - vec4(tmpvar_46))
   * 8000.0) + 1.0), 0.0, 1.0);
  Values3_49 = tmpvar_59;
  highp vec2 tmpvar_60;
  tmpvar_60.x = tmpvar_56.x;
  tmpvar_60.y = tmpvar_57.x;
  highp vec2 tmpvar_61;
  tmpvar_61.x = tmpvar_56.y;
  tmpvar_61.y = tmpvar_57.y;
  highp vec2 tmpvar_62;
  tmpvar_62 = ((tmpvar_60 * (1.0 - tmpvar_54.xx)) + (tmpvar_61 * tmpvar_54.xx));
  highp vec2 tmpvar_63;
  tmpvar_63.x = tmpvar_56.y;
  tmpvar_63.y = tmpvar_57.y;
  highp vec2 tmpvar_64;
  tmpvar_64.x = tmpvar_56.z;
  tmpvar_64.y = tmpvar_57.z;
  highp vec2 tmpvar_65;
  tmpvar_65 = ((tmpvar_63 * (1.0 - tmpvar_54.xx)) + (tmpvar_64 * tmpvar_54.xx));
  highp vec2 tmpvar_66;
  tmpvar_66.x = tmpvar_56.z;
  tmpvar_66.y = tmpvar_57.z;
  highp vec2 tmpvar_67;
  tmpvar_67.x = tmpvar_56.w;
  tmpvar_67.y = tmpvar_57.w;
  highp vec2 tmpvar_68;
  tmpvar_68 = ((tmpvar_66 * (1.0 - tmpvar_54.xx)) + (tmpvar_67 * tmpvar_54.xx));
  highp vec2 tmpvar_69;
  tmpvar_69.x = tmpvar_57.x;
  tmpvar_69.y = tmpvar_58.x;
  highp vec2 tmpvar_70;
  tmpvar_70.x = tmpvar_57.y;
  tmpvar_70.y = tmpvar_58.y;
  highp vec2 tmpvar_71;
  tmpvar_71 = ((tmpvar_69 * (1.0 - tmpvar_54.xx)) + (tmpvar_70 * tmpvar_54.xx));
  highp vec2 tmpvar_72;
  tmpvar_72.x = tmpvar_57.y;
  tmpvar_72.y = tmpvar_58.y;
  highp vec2 tmpvar_73;
  tmpvar_73.x = tmpvar_57.z;
  tmpvar_73.y = tmpvar_58.z;
  highp vec2 tmpvar_74;
  tmpvar_74 = ((tmpvar_72 * (1.0 - tmpvar_54.xx)) + (tmpvar_73 * tmpvar_54.xx));
  highp vec2 tmpvar_75;
  tmpvar_75.x = tmpvar_57.z;
  tmpvar_75.y = tmpvar_58.z;
  highp vec2 tmpvar_76;
  tmpvar_76.x = tmpvar_57.w;
  tmpvar_76.y = tmpvar_58.w;
  highp vec2 tmpvar_77;
  tmpvar_77 = ((tmpvar_75 * (1.0 - tmpvar_54.xx)) + (tmpvar_76 * tmpvar_54.xx));
  highp vec2 tmpvar_78;
  tmpvar_78.x = tmpvar_58.x;
  tmpvar_78.y = tmpvar_59.x;
  highp vec2 tmpvar_79;
  tmpvar_79.x = tmpvar_58.y;
  tmpvar_79.y = tmpvar_59.y;
  highp vec2 tmpvar_80;
  tmpvar_80 = ((tmpvar_78 * (1.0 - tmpvar_54.xx)) + (tmpvar_79 * tmpvar_54.xx));
  highp vec2 tmpvar_81;
  tmpvar_81.x = tmpvar_58.y;
  tmpvar_81.y = tmpvar_59.y;
  highp vec2 tmpvar_82;
  tmpvar_82.x = tmpvar_58.z;
  tmpvar_82.y = tmpvar_59.z;
  highp vec2 tmpvar_83;
  tmpvar_83 = ((tmpvar_81 * (1.0 - tmpvar_54.xx)) + (tmpvar_82 * tmpvar_54.xx));
  highp vec2 tmpvar_84;
  tmpvar_84.x = tmpvar_58.z;
  tmpvar_84.y = tmpvar_59.z;
  highp vec2 tmpvar_85;
  tmpvar_85.x = tmpvar_58.w;
  tmpvar_85.y = tmpvar_59.w;
  highp vec2 tmpvar_86;
  tmpvar_86 = ((tmpvar_84 * (1.0 - tmpvar_54.xx)) + (tmpvar_85 * tmpvar_54.xx));
  inShadow_48 = (((
    ((((
      ((((tmpvar_62.x * 
        (1.0 - tmpvar_54.y)
      ) + (tmpvar_62.y * tmpvar_54.y)) + ((tmpvar_65.x * 
        (1.0 - tmpvar_54.y)
      ) + (tmpvar_65.y * tmpvar_54.y))) + ((tmpvar_68.x * (1.0 - tmpvar_54.y)) + (tmpvar_68.y * tmpvar_54.y)))
     + 
      ((tmpvar_71.x * (1.0 - tmpvar_54.y)) + (tmpvar_71.y * tmpvar_54.y))
    ) + (
      (tmpvar_74.x * (1.0 - tmpvar_54.y))
     + 
      (tmpvar_74.y * tmpvar_54.y)
    )) + ((tmpvar_77.x * 
      (1.0 - tmpvar_54.y)
    ) + (tmpvar_77.y * tmpvar_54.y))) + ((tmpvar_80.x * (1.0 - tmpvar_54.y)) + (tmpvar_80.y * tmpvar_54.y)))
   + 
    ((tmpvar_83.x * (1.0 - tmpvar_54.y)) + (tmpvar_83.y * tmpvar_54.y))
  ) + (
    (tmpvar_86.x * (1.0 - tmpvar_54.y))
   + 
    (tmpvar_86.y * tmpvar_54.y)
  )) * 0.11111);
  inShadow_48 = (1.0 - inShadow_48);
  shadow_15 = inShadow_48;
  shadow_15 = (shadow_15 * inRange_14.x);
  shadow_15 = (1.0 - shadow_15);
  SunIrradiance_13 = (((SunColor.xyz * userData_1.x) * (2.0 * ShadowColor.y)) * cPointCloud[0].w);
  highp vec3 tmpvar_87;
  tmpvar_87.x = ((MixTex_23.z * (1.0 - MixTex_23.x)) + (1.5 * MixTex_23.x));
  tmpvar_87.y = AO_22;
  tmpvar_87.z = AO_22;
  ScatterAO_12 = tmpvar_87;
  mediump vec4 linearColor_88;
  mediump vec3 nSquared_89;
  highp vec3 tmpvar_90;
  tmpvar_90 = (tmpvar_35 * tmpvar_35);
  nSquared_89 = tmpvar_90;
  highp ivec3 tmpvar_91;
  tmpvar_91 = ivec3(lessThan (tmpvar_35, vec3(0.0, 0.0, 0.0)));
  highp vec4 tmpvar_92;
  tmpvar_92 = (((nSquared_89.x * cPointCloud[tmpvar_91.x]) + (nSquared_89.y * cPointCloud[
    (tmpvar_91.y + 2)
  ])) + (nSquared_89.z * cPointCloud[(tmpvar_91.z + 4)]));
  linearColor_88 = tmpvar_92;
  linearColor_88.xyz = max (vec3(0.9, 0.9, 0.9), linearColor_88.xyz);
  highp vec3 tmpvar_93;
  tmpvar_93 = vec3((ShadowColor.x * (10.0 + (
    (cPointCloud[3].w * ShadowColor.z)
   * 100.0))));
  linearColor_88.xyz = (linearColor_88.xyz * tmpvar_93);
  highp vec3 tmpvar_94;
  tmpvar_94 = ((linearColor_88.xyz * ScatterAO_12) * (userData_1.y * 2.0));
  highp vec3 tmpvar_95;
  tmpvar_95 = normalize(cVirtualLitDir.xyz);
  highp vec3 tmpvar_96;
  tmpvar_96 = (((cVirtualLitColor.xyz * userData_1.z) * (2.0 * MixTex_23.z)) * vec3((0.444 + (0.556 * 
    clamp (dot (normalize((
      (tmpvar_40 * (1.0 - MixTex_23.x))
     + 
      (tmpvar_35 * MixTex_23.x)
    )), tmpvar_95), 0.0, 1.0)
  ))));
  highp float tmpvar_97;
  tmpvar_97 = clamp ((0.6 + dot (tmpvar_35, SunDirection.xyz)), 0.0, 1.0);
  highp vec2 tmpvar_98;
  tmpvar_98.x = ((0.5 * dot (tmpvar_35, SunDirection.xyz)) + 0.5);
  tmpvar_98.y = (cSSSIntensity * MixTex_23.y);
  mediump vec3 tmpvar_99;
  tmpvar_99 = texture (sLutMapSampler, tmpvar_98).xyz;
  SSS_Lut1_11 = tmpvar_99;
  SSS_Lut1_11 = (SSS_Lut1_11 * SSS_Lut1_11);
  highp float tmpvar_100;
  tmpvar_100 = (shadow_15 + ((
    clamp (dot (tmpvar_40, SunDirection.xyz), 0.0, 1.0)
   - NoL_16) * shadow_15));
  highp vec3 tmpvar_101;
  highp float tmpvar_102;
  tmpvar_102 = (1.0 - cSSSIntensity);
  tmpvar_101.x = ((sqrt(tmpvar_100) * (1.0 - tmpvar_102)) + (tmpvar_100 * tmpvar_102));
  tmpvar_101.yz = vec2(tmpvar_100);
  highp float tmpvar_103;
  tmpvar_103 = (Roughness_24 * RoughnessOffset2);
  highp float tmpvar_104;
  tmpvar_104 = ((SunIrradiance_13 * NoL_16) * ((2.0 * SpecularMask_21) * shadow_15)).x;
  highp float d_105;
  highp float m2_106;
  highp float m_107;
  highp vec3 tmpvar_108;
  tmpvar_108 = normalize((SunDirection.xyz + tmpvar_41));
  highp float tmpvar_109;
  tmpvar_109 = clamp (dot (tmpvar_40, tmpvar_108), 0.0, 1.0);
  highp float tmpvar_110;
  tmpvar_110 = clamp (dot (tmpvar_41, tmpvar_108), 0.0, 1.0);
  highp float tmpvar_111;
  tmpvar_111 = (Roughness_24 * Roughness_24);
  highp float tmpvar_112;
  tmpvar_112 = (tmpvar_111 * tmpvar_111);
  highp float tmpvar_113;
  tmpvar_113 = (((
    (tmpvar_109 * tmpvar_112)
   - tmpvar_109) * tmpvar_109) + 1.0);
  m_107 = (tmpvar_103 * tmpvar_103);
  m2_106 = (m_107 * m_107);
  d_105 = (((
    (tmpvar_109 * m2_106)
   - tmpvar_109) * tmpvar_109) + 1.0);
  highp float tmpvar_114;
  tmpvar_114 = (m_107 * 0.5);
  highp float d_115;
  highp float m2_116;
  highp float m_117;
  highp vec3 tmpvar_118;
  tmpvar_118 = normalize((tmpvar_95 + tmpvar_41));
  highp float tmpvar_119;
  tmpvar_119 = clamp (dot (tmpvar_40, tmpvar_118), 0.0, 1.0);
  highp float tmpvar_120;
  tmpvar_120 = clamp (dot (tmpvar_41, tmpvar_118), 0.0, 1.0);
  highp float tmpvar_121;
  tmpvar_121 = (Roughness_24 * Roughness_24);
  highp float tmpvar_122;
  tmpvar_122 = (tmpvar_121 * tmpvar_121);
  highp float tmpvar_123;
  tmpvar_123 = (((
    (tmpvar_119 * tmpvar_122)
   - tmpvar_119) * tmpvar_119) + 1.0);
  m_117 = (tmpvar_103 * tmpvar_103);
  m2_116 = (m_117 * m_117);
  d_115 = (((
    (tmpvar_119 * m2_116)
   - tmpvar_119) * tmpvar_119) + 1.0);
  highp float tmpvar_124;
  tmpvar_124 = (m_117 * 0.5);
  mediump vec3 tmpvar_125;
  mediump float Roughness_126;
  Roughness_126 = Roughness_24;
  mediump vec4 tmpvar_127;
  tmpvar_127 = ((Roughness_126 * vec4(-1.0, -0.0275, -0.572, 0.022)) + vec4(1.0, 0.0425, 1.04, -0.04));
  mediump vec2 tmpvar_128;
  tmpvar_128 = ((vec2(-1.04, 1.04) * (
    (min ((tmpvar_127.x * tmpvar_127.x), exp2((-9.28 * NoV_17))) * tmpvar_127.x)
   + tmpvar_127.y)) + tmpvar_127.zw);
  tmpvar_125 = ((vec3(0.04, 0.04, 0.04) * tmpvar_128.x) + tmpvar_128.y);
  EnvBRDF_9 = tmpvar_125;
  mediump float Roughness_129;
  Roughness_129 = Roughness_24;
  highp vec3 R_130;
  R_130 = (I_42 - (2.0 * (
    dot (tmpvar_35, I_42)
   * tmpvar_35)));
  mediump float fSign_131;
  mediump vec3 sampleEnvSpecular_132;
  highp float tmpvar_133;
  tmpvar_133 = float((R_130.z > 0.0));
  fSign_131 = tmpvar_133;
  mediump float tmpvar_134;
  tmpvar_134 = ((fSign_131 * 2.0) - 1.0);
  R_130.xy = (R_130.xy / ((R_130.z * tmpvar_134) + 1.0));
  R_130.xy = ((R_130.xy * vec2(0.25, -0.25)) + (0.25 + (0.5 * fSign_131)));
  mediump vec4 color_135;
  color_135 = textureLod (sEnvSampler, R_130.xy, (Roughness_129 / 0.17));
  sampleEnvSpecular_132 = (color_135.xyz * ((color_135.w * color_135.w) * 16.0));
  sampleEnvSpecular_132 = (sampleEnvSpecular_132 * ((cEnvStrength * EnvInfo.w) * 10.0));
  SpecRadiance_10 = (((
    ((((tmpvar_112 / 
      ((tmpvar_113 * tmpvar_113) * 3.141593)
    ) * 1.5) + ((m2_106 / 
      ((d_105 * d_105) * 3.141593)
    ) * 0.5)) * (vec3(0.04, 0.04, 0.04) + (vec3(0.96, 0.96, 0.96) * exp2(
      (((-5.55473 * tmpvar_110) - 6.98316) * tmpvar_110)
    ))))
   * 
    (0.25 / (((
      clamp (dot (tmpvar_40, tmpvar_41), 0.0, 1.0)
     * 
      (1.0 - tmpvar_114)
    ) + tmpvar_114) * ((
      clamp (dot (tmpvar_40, SunDirection.xyz), 0.0, 1.0)
     * 
      (1.0 - tmpvar_114)
    ) + tmpvar_114)))
  ) * tmpvar_104) + ((tmpvar_96 * 
    ((((
      (tmpvar_122 / ((tmpvar_123 * tmpvar_123) * 3.141593))
     * 1.5) + (
      (m2_116 / ((d_115 * d_115) * 3.141593))
     * 0.5)) * (vec3(0.04, 0.04, 0.04) + (vec3(0.96, 0.96, 0.96) * 
      exp2((((-5.55473 * tmpvar_120) - 6.98316) * tmpvar_120))
    ))) * (0.25 / ((
      (clamp (dot (tmpvar_40, tmpvar_41), 0.0, 1.0) * (1.0 - tmpvar_124))
     + tmpvar_124) * (
      (clamp (dot (tmpvar_40, tmpvar_95), 0.0, 1.0) * (1.0 - tmpvar_124))
     + tmpvar_124))))
  ) * SpecularMask_21));
  SpecRadiance_10 = (SpecRadiance_10 + ((
    (EnvBRDF_9 * tmpvar_94)
   * 
    ((SpecularMask_21 * EnvInfo.w) * cEnvStrength)
  ) + (
    (sampleEnvSpecular_132 * EnvBRDF_9)
   * 
    ((MixTex_23.z * MixTex_23.z) * dot (tmpvar_94, vec3(0.3, 0.59, 0.11)))
  )));
  highp vec3 tmpvar_136;
  tmpvar_136 = texture (sCrystalMaskMapSampler, xlv_TEXCOORD0.xy).xyz;
  crystalMaskMap_8 = tmpvar_136;
  highp vec4 tmpvar_137;
  tmpvar_137 = texture (sCrystalMap03Sampler, ((5.0 * cCrystalUVTile03) * xlv_TEXCOORD0.xy));
  crystalMap03_7 = tmpvar_137.xyz;
  highp vec3 tmpvar_138;
  tmpvar_138 = (((crystalMaskMap_8.z * cCrystalIntensity03) * cCrystalColor03) * crystalMap03_7);
  crystalMask_6 = tmpvar_138;
  highp vec3 SpecularColor_139;
  SpecularColor_139 = (10.0 * crystalMask_6);
  highp vec3 CrystalSpecBRDF_140;
  highp float d_141;
  highp float m2_142;
  highp float m_143;
  highp vec3 tmpvar_144;
  tmpvar_144 = normalize((SunDirection.xyz + tmpvar_41));
  highp float tmpvar_145;
  tmpvar_145 = clamp (dot (tmpvar_40, tmpvar_144), 0.0, 1.0);
  highp float tmpvar_146;
  tmpvar_146 = clamp (dot (tmpvar_41, tmpvar_144), 0.0, 1.0);
  highp float tmpvar_147;
  tmpvar_147 = (cCrystalRange * cCrystalRange);
  highp float tmpvar_148;
  tmpvar_148 = (tmpvar_147 * tmpvar_147);
  highp float tmpvar_149;
  tmpvar_149 = (((
    (tmpvar_145 * tmpvar_148)
   - tmpvar_145) * tmpvar_145) + 1.0);
  m_143 = (tmpvar_147 * 0.5);
  m2_142 = (m_143 * m_143);
  d_141 = (((
    (tmpvar_145 * m2_142)
   - tmpvar_145) * tmpvar_145) + 1.0);
  highp float tmpvar_150;
  tmpvar_150 = (m_143 * 0.5);
  CrystalSpecBRDF_140 = (((
    (tmpvar_148 / ((tmpvar_149 * tmpvar_149) * 3.141593))
   + 
    (m2_142 / ((d_141 * d_141) * 3.141593))
  ) * (SpecularColor_139 + 
    ((clamp ((50.0 * SpecularColor_139.y), 0.0, 1.0) - SpecularColor_139) * exp2(((
      (-5.55473 * tmpvar_146)
     - 6.98316) * tmpvar_146)))
  )) * (0.25 / (
    ((clamp (dot (tmpvar_40, tmpvar_41), 0.0, 1.0) * (1.0 - tmpvar_150)) + tmpvar_150)
   * 
    ((clamp (dot (tmpvar_40, SunDirection.xyz), 0.0, 1.0) * (1.0 - tmpvar_150)) + tmpvar_150)
  )));
  CrystalSpecBRDF_5 = CrystalSpecBRDF_140;
  highp vec3 tmpvar_151;
  tmpvar_151 = ((tmpvar_104 * CrystalSpecBRDF_5) * MixTex_23.z);
  CrystalSunSpec_4 = tmpvar_151;
  SpecRadiance_10 = (SpecRadiance_10 + CrystalSunSpec_4);
  highp vec3 SpecularColor_152;
  SpecularColor_152 = (cCrystalVirtualLit * crystalMask_6);
  highp vec3 CrystalSpecBRDF_153;
  highp float d_154;
  highp float m2_155;
  highp float m_156;
  highp vec3 tmpvar_157;
  tmpvar_157 = normalize((tmpvar_95 + tmpvar_41));
  highp float tmpvar_158;
  tmpvar_158 = clamp (dot (tmpvar_40, tmpvar_157), 0.0, 1.0);
  highp float tmpvar_159;
  tmpvar_159 = clamp (dot (tmpvar_41, tmpvar_157), 0.0, 1.0);
  highp float tmpvar_160;
  tmpvar_160 = (tmpvar_147 * tmpvar_147);
  highp float tmpvar_161;
  tmpvar_161 = (((
    (tmpvar_158 * tmpvar_160)
   - tmpvar_158) * tmpvar_158) + 1.0);
  m_156 = (tmpvar_147 * 0.5);
  m2_155 = (m_156 * m_156);
  d_154 = (((
    (tmpvar_158 * m2_155)
   - tmpvar_158) * tmpvar_158) + 1.0);
  highp float tmpvar_162;
  tmpvar_162 = (m_156 * 0.5);
  CrystalSpecBRDF_153 = (((
    (tmpvar_160 / ((tmpvar_161 * tmpvar_161) * 3.141593))
   + 
    (m2_155 / ((d_154 * d_154) * 3.141593))
  ) * (SpecularColor_152 + 
    ((clamp ((50.0 * SpecularColor_152.y), 0.0, 1.0) - SpecularColor_152) * exp2(((
      (-5.55473 * tmpvar_159)
     - 6.98316) * tmpvar_159)))
  )) * (0.25 / (
    ((clamp (dot (tmpvar_40, tmpvar_41), 0.0, 1.0) * (1.0 - tmpvar_162)) + tmpvar_162)
   * 
    ((clamp (dot (tmpvar_40, tmpvar_95), 0.0, 1.0) * (1.0 - tmpvar_162)) + tmpvar_162)
  )));
  CrystalSpecBRDF_5 = CrystalSpecBRDF_153;
  highp vec3 tmpvar_163;
  tmpvar_163 = (tmpvar_96 * CrystalSpecBRDF_5);
  CrystalVirtualSpec_3 = tmpvar_163;
  SpecRadiance_10 = (SpecRadiance_10 + CrystalVirtualSpec_3);
  highp vec4 tmpvar_164;
  tmpvar_164.w = 1.0;
  tmpvar_164.xyz = (SpecRadiance_10 + ((
    (((tmpvar_94 + (
      ((((
        (SunIrradiance_13 + tmpvar_94)
       * MixTex_23.x) * cSSSColor.xyz) * vec3(tmpvar_97)) * vec3(tmpvar_97))
     * shadow_15)) + tmpvar_96) + (((
      (((tmpvar_101 * tmpvar_101) * SSS_Lut1_11) * (1.0 - vertexColorW_20))
     + 
      ((NoL_16 * shadow_15) * vertexColorW_20)
    ) * SunIrradiance_13) * MixTex_23.z))
   * BaseColor_25.xyz) / 3.141593));
  OUT_2.w = tmpvar_164.w;
  highp float tmpvar_165;
  tmpvar_165 = clamp (dot (-(tmpvar_41), SunDirection.xyz), 0.0, 1.0);
  highp float tmpvar_166;
  tmpvar_166 = (1.0 - xlv_TEXCOORD3.w);
  OUT_2.xyz = ((tmpvar_164.xyz * tmpvar_166) + ((
    (tmpvar_164.xyz * tmpvar_166)
   + 
    (((FogColor2.xyz * clamp (
      ((tmpvar_41.y * 5.0) + 1.0)
    , 0.0, 1.0)) + FogColor.xyz) + (FogColor3.xyz * (tmpvar_165 * tmpvar_165)))
  ) * xlv_TEXCOORD3.w));
  OUT_2.xyz = (EnvInfo.z * OUT_2.xyz);
  OUT_2.xyz = clamp (OUT_2.xyz, vec3(0.0, 0.0, 0.0), vec3(4.0, 4.0, 4.0));
  highp vec3 tmpvar_167;
  tmpvar_167.x = FogColor.w;
  tmpvar_167.y = FogColor2.w;
  tmpvar_167.z = FogColor3.w;
  OUT_2.xyz = (OUT_2.xyz * tmpvar_167);
  OUT_2.xyz = (OUT_2.xyz / ((OUT_2.xyz * 0.9661836) + 0.180676));
  highp float tmpvar_168;
  tmpvar_168 = float(((
    clamp (cGrayPencent, 0.0, 1.0)
   + UserData[2].x) >= 2.0));
  OUT_2.xyz = ((OUT_2.xyz * (1.0 - tmpvar_168)) + (tmpvar_168 * dot (OUT_2.xyz, vec3(0.3, 0.59, 0.11))));
  OUT_2.w = 1.0;
  SV_Target = OUT_2;
}

 