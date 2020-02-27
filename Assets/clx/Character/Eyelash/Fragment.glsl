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
uniform highp float cEnvStrength;
uniform highp float cBaseMapBias;
uniform highp vec4 cEmissionScale;
uniform highp vec4 cColorTransform0;
uniform highp vec4 cColorTransform1;
uniform highp vec4 cColorTransform2;
uniform highp float cGrayPencent;
uniform highp float cShadowFilterScale;
uniform mediump sampler2D sBaseSampler;
uniform mediump sampler2D sMixSampler;
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
  mediump vec4 Emission_14;
  mediump float Alpha_15;
  highp vec4 base_color_data_16;
  highp float mask_17;
  mediump vec4 tmpvar_18;
  tmpvar_18 = texture (sBaseSampler, xlv_TEXCOORD0.xy, cBaseMapBias);
  BaseColor_13 = (tmpvar_18.xyz * tmpvar_18.xyz);
  Alpha_15 = tmpvar_18.w;
  mask_17 = Alpha_15;
  mediump vec4 tmpvar_19;
  tmpvar_19.w = 1.0;
  tmpvar_19.xyz = BaseColor_13;
  base_color_data_16 = tmpvar_19;
  highp vec3 tmpvar_20;
  tmpvar_20.x = dot (cColorTransform0, base_color_data_16);
  tmpvar_20.y = dot (cColorTransform1, base_color_data_16);
  tmpvar_20.z = dot (cColorTransform2, base_color_data_16);
  highp vec3 tmpvar_21;
  tmpvar_21 = ((BaseColor_13 * (1.0 - mask_17)) + (clamp (tmpvar_20, 0.0, 1.0) * mask_17));
  BaseColor_13 = tmpvar_21;
  Emission_14.xyz = vec3(0.0, 0.0, 0.0);
  mediump vec3 tmpvar_22;
  tmpvar_22 = texture (sMixSampler, xlv_TEXCOORD0.xy).xyz;
  mediump float rain_23;
  rain_23 = (EnvInfo.x * 0.5);
  highp float tmpvar_24;
  tmpvar_24 = clamp (((
    (3.0 * xlv_TEXCOORD2.y)
   + 0.2) + (0.1 * rain_23)), 0.0, 1.0);
  rain_23 = (1.0 - (rain_23 * tmpvar_24));
  mediump float tmpvar_25;
  tmpvar_25 = clamp ((rain_23 - (rain_23 * tmpvar_22.x)), 0.05, 1.0);
  highp vec3 tmpvar_26;
  tmpvar_26 = normalize(xlv_TEXCOORD2.xyz);
  highp vec3 tmpvar_27;
  tmpvar_27 = BaseColor_13;
  BaseColor_13 = tmpvar_27;
  Emission_14.w = cEmissionScale.w;
  mediump vec4 linearColor_28;
  mediump vec3 nSquared_29;
  highp vec3 tmpvar_30;
  tmpvar_30 = (tmpvar_26 * tmpvar_26);
  nSquared_29 = tmpvar_30;
  highp ivec3 tmpvar_31;
  tmpvar_31 = ivec3(lessThan (tmpvar_26, vec3(0.0, 0.0, 0.0)));
  highp vec4 tmpvar_32;
  tmpvar_32 = (((nSquared_29.x * cPointCloud[tmpvar_31.x]) + (nSquared_29.y * cPointCloud[
    (tmpvar_31.y + 2)
  ])) + (nSquared_29.z * cPointCloud[(tmpvar_31.z + 4)]));
  linearColor_28 = tmpvar_32;
  linearColor_28.xyz = max (vec3(0.9, 0.9, 0.9), linearColor_28.xyz);
  highp vec3 tmpvar_33;
  tmpvar_33 = vec3((ShadowColor.x * (10.0 + (
    (cPointCloud[3].w * ShadowColor.z)
   * 100.0))));
  linearColor_28.xyz = (linearColor_28.xyz * tmpvar_33);
  OUT_12.w = Alpha_15;
  highp vec3 tmpvar_34;
  tmpvar_34 = (xlv_TEXCOORD6.xyz / xlv_TEXCOORD6.w);
  highp float tmpvar_35;
  tmpvar_35 = min (0.99999, tmpvar_34.z);
  highp vec2 tmpvar_36;
  tmpvar_36 = vec2(lessThan (abs(
    (tmpvar_34.xy - 0.5)
  ), vec2(0.5, 0.5)));
  inRange_8 = tmpvar_36;
  inRange_8.x = (inRange_8.x * inRange_8.y);
  highp float inShadow_37;
  highp vec3 sampleDepth3_38;
  highp vec3 sampleDepth2_39;
  highp vec3 sampleDepth1_40;
  highp float tmpvar_41;
  tmpvar_41 = -(cShadowFilterScale);
  sampleDepth1_40.x = dot (texture (sShadowMapSampler, (tmpvar_34.xy + (cShadowBias.ww * vec2(tmpvar_41)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_42;
  tmpvar_42.x = 0.0;
  tmpvar_42.y = tmpvar_41;
  sampleDepth1_40.y = dot (texture (sShadowMapSampler, (tmpvar_34.xy + (cShadowBias.ww * tmpvar_42))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_43;
  tmpvar_43.x = cShadowFilterScale;
  tmpvar_43.y = tmpvar_41;
  sampleDepth1_40.z = dot (texture (sShadowMapSampler, (tmpvar_34.xy + (cShadowBias.ww * tmpvar_43))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_44;
  tmpvar_44.y = 0.0;
  tmpvar_44.x = tmpvar_41;
  sampleDepth2_39.x = dot (texture (sShadowMapSampler, (tmpvar_34.xy + (cShadowBias.ww * tmpvar_44))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth2_39.y = dot (texture (sShadowMapSampler, tmpvar_34.xy), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_45;
  tmpvar_45.y = 0.0;
  tmpvar_45.x = cShadowFilterScale;
  sampleDepth2_39.z = dot (texture (sShadowMapSampler, (tmpvar_34.xy + (cShadowBias.ww * tmpvar_45))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_46;
  tmpvar_46.x = tmpvar_41;
  tmpvar_46.y = cShadowFilterScale;
  sampleDepth3_38.x = dot (texture (sShadowMapSampler, (tmpvar_34.xy + (cShadowBias.ww * tmpvar_46))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec2 tmpvar_47;
  tmpvar_47.x = 0.0;
  tmpvar_47.y = cShadowFilterScale;
  sampleDepth3_38.y = dot (texture (sShadowMapSampler, (tmpvar_34.xy + (cShadowBias.ww * tmpvar_47))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth3_38.z = dot (texture (sShadowMapSampler, (tmpvar_34.xy + (cShadowBias.ww * vec2(cShadowFilterScale)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec3 tmpvar_48;
  tmpvar_48 = vec3(greaterThan (vec3(tmpvar_35), sampleDepth2_39));
  highp vec2 tmpvar_49;
  tmpvar_49 = fract((tmpvar_34.xy / cShadowBias.ww));
  highp vec4 tmpvar_50;
  tmpvar_50 = ((vec3(
    greaterThan (vec3(tmpvar_35), sampleDepth1_40)
  ).xyyz * (1.0 - tmpvar_49.y)) + (tmpvar_48.xyyz * tmpvar_49.y));
  highp vec4 tmpvar_51;
  tmpvar_51 = ((tmpvar_48.xyyz * (1.0 - tmpvar_49.y)) + (vec3(
    greaterThan (vec3(tmpvar_35), sampleDepth3_38)
  ).xyyz * tmpvar_49.y));
  inShadow_37 = ((tmpvar_50.x * (1.0 - tmpvar_49.x)) + (tmpvar_50.y * tmpvar_49.x));
  inShadow_37 = (inShadow_37 + ((tmpvar_50.z * 
    (1.0 - tmpvar_49.x)
  ) + (tmpvar_50.w * tmpvar_49.x)));
  inShadow_37 = (inShadow_37 + ((tmpvar_51.x * 
    (1.0 - tmpvar_49.x)
  ) + (tmpvar_51.y * tmpvar_49.x)));
  inShadow_37 = (inShadow_37 + ((tmpvar_51.z * 
    (1.0 - tmpvar_49.x)
  ) + (tmpvar_51.w * tmpvar_49.x)));
  inShadow_37 = (inShadow_37 * 0.25);
  shadow2_9 = inShadow_37;
  shadow2_9 = (shadow2_9 * inRange_8.x);
  shadow2_9 = (1.0 - shadow2_9);
  shadow_10 = min (1.0, shadow2_9);
  SpecularColor_6 = ((vec3(0.04, 0.04, 0.04) * (1.0 - tmpvar_22.yyy)) + (BaseColor_13 * tmpvar_22.yyy));
  DiffuseColor_7 = ((BaseColor_13 - (BaseColor_13 * tmpvar_22.y)) / 3.141593);
  highp vec3 tmpvar_52;
  tmpvar_52 = normalize(-(xlv_TEXCOORD3.xyz));
  highp vec3 I_53;
  I_53 = -(tmpvar_52);
  R_5 = (I_53 - (2.0 * (
    dot (tmpvar_26, I_53)
   * tmpvar_26)));
  mediump float color_54;
  color_54 = clamp (dot (tmpvar_26, tmpvar_52), 0.0, 1.0);
  mediump float color_55;
  color_55 = dot (SunDirection.xyz, tmpvar_26);
  highp float tmpvar_56;
  tmpvar_56 = ShadowColor.y;
  SunlightOffset_3 = tmpvar_56;
  shadow_10 = (shadow_10 * SunlightOffset_3);
  shadow_10 = (shadow_10 * cPointCloud[0].w);
  GILighting_11.xyz = linearColor_28.xyz;
  diffLighting_4 = (linearColor_28.xyz * tmpvar_22.z);
  GILighting_11.w = (tmpvar_22.z * clamp (dot (diffLighting_4, vec3(0.3, 0.59, 0.11)), 0.0, 1.0));
  mediump vec3 tmpvar_57;
  tmpvar_57 = ((clamp (color_55, 0.0, 1.0) * shadow_10) * SunColor.xyz);
  diffLighting_4 = (diffLighting_4 + tmpvar_57);
  mediump float G_58;
  highp float D_59;
  highp float m_60;
  mediump vec3 sunSpec_61;
  mediump vec3 Spec_62;
  mediump vec3 tmpvar_63;
  mediump vec4 tmpvar_64;
  tmpvar_64 = ((tmpvar_25 * vec4(-1.0, -0.0275, -0.572, 0.022)) + vec4(1.0, 0.0425, 1.04, -0.04));
  mediump vec2 tmpvar_65;
  tmpvar_65 = ((vec2(-1.04, 1.04) * (
    (min ((tmpvar_64.x * tmpvar_64.x), exp2((-9.28 * color_54))) * tmpvar_64.x)
   + tmpvar_64.y)) + tmpvar_64.zw);
  tmpvar_63 = ((SpecularColor_6 * tmpvar_65.x) + tmpvar_65.y);
  highp vec3 R_66;
  R_66.z = R_5.z;
  mediump float fSign_67;
  mediump vec3 sampleEnvSpecular_68;
  highp float tmpvar_69;
  tmpvar_69 = float((R_5.z > 0.0));
  fSign_67 = tmpvar_69;
  mediump float tmpvar_70;
  tmpvar_70 = ((fSign_67 * 2.0) - 1.0);
  R_66.xy = (R_5.xy / ((R_5.z * tmpvar_70) + 1.0));
  R_66.xy = ((R_66.xy * vec2(0.25, -0.25)) + (0.25 + (0.5 * fSign_67)));
  mediump vec4 tmpvar_71;
  tmpvar_71 = textureLod (sEnvSampler, R_66.xy, (tmpvar_25 / 0.17));
  sampleEnvSpecular_68 = (tmpvar_71.xyz * ((tmpvar_71.w * tmpvar_71.w) * 16.0));
  sampleEnvSpecular_68 = (sampleEnvSpecular_68 * ((cEnvStrength * GILighting_11.w) * (EnvInfo.w * 10.0)));
  highp vec3 tmpvar_72;
  tmpvar_72 = normalize((tmpvar_52 + SunDirection.xyz));
  highp float tmpvar_73;
  tmpvar_73 = clamp (dot (tmpvar_26, tmpvar_72), 0.0, 1.0);
  highp float tmpvar_74;
  tmpvar_74 = clamp (dot (tmpvar_52, tmpvar_72), 0.0, 1.0);
  mediump float tmpvar_75;
  tmpvar_75 = max (0.08, tmpvar_25);
  mediump float tmpvar_76;
  tmpvar_76 = (tmpvar_75 * tmpvar_75);
  m_60 = tmpvar_76;
  highp float tmpvar_77;
  tmpvar_77 = (m_60 * m_60);
  highp float tmpvar_78;
  tmpvar_78 = (((
    (tmpvar_73 * tmpvar_77)
   - tmpvar_73) * tmpvar_73) + 1.0);
  D_59 = (tmpvar_77 / ((tmpvar_78 * tmpvar_78) * 3.141593));
  highp float tmpvar_79;
  tmpvar_79 = (m_60 * 0.5);
  mediump float tmpvar_80;
  tmpvar_80 = clamp (color_55, 0.0, 1.0);
  highp float tmpvar_81;
  tmpvar_81 = (0.25 / ((
    (color_54 * (1.0 - tmpvar_79))
   + tmpvar_79) * (
    (tmpvar_80 * (1.0 - tmpvar_79))
   + tmpvar_79)));
  G_58 = tmpvar_81;
  mediump float color_82;
  color_82 = exp2(((
    (-5.55473 * tmpvar_74)
   - 6.98316) * tmpvar_74));
  sunSpec_61 = ((D_59 * G_58) * (tmpvar_63 + (
    (clamp ((50.0 * tmpvar_63.y), 0.0, 1.0) - tmpvar_63)
   * color_82)));
  sunSpec_61 = (sunSpec_61 * (SunColor.xyz * clamp (
    (color_55 * shadow_10)
  , 0.0, 1.0)));
  Spec_62 = ((tmpvar_63 * sampleEnvSpecular_68) + sunSpec_61);
  SpecularColor_6 = tmpvar_63;
  OUT_12.xyz = Spec_62;
  highp vec3 tmpvar_83;
  tmpvar_83 = normalize(cVirtualLitDir.xyz);
  mediump float color_84;
  color_84 = clamp (dot (tmpvar_83, tmpvar_26), 0.0, 1.0);
  mediump vec3 color_85;
  color_85 = (cVirtualLitColor.xyz * (Emission_14.w * (0.444 + 
    (color_84 * 0.556)
  )));
  diffLighting_4 = (diffLighting_4 + color_85);
  highp float tmpvar_86;
  tmpvar_86 = clamp (dot (tmpvar_26, normalize(
    (tmpvar_52 + tmpvar_83)
  )), 0.0, 1.0);
  mediump float tmpvar_87;
  tmpvar_87 = ((tmpvar_25 * tmpvar_25) + 0.0002);
  m2_2 = tmpvar_87;
  m2_2 = (m2_2 * m2_2);
  highp float tmpvar_88;
  tmpvar_88 = (((
    (tmpvar_86 * m2_2)
   - tmpvar_86) * tmpvar_86) + 1.0);
  D_1 = ((tmpvar_88 * tmpvar_88) + 1e-06);
  D_1 = ((0.25 * m2_2) / D_1);
  OUT_12.xyz = (OUT_12.xyz + ((color_85 * tmpvar_63) * D_1));
  OUT_12.xyz = OUT_12.xyz;
  OUT_12.xyz = (OUT_12.xyz + (diffLighting_4 * DiffuseColor_7));
  mediump float tmpvar_89;
  tmpvar_89 = max (0.5, clamp ((1.0 + 
    (shadow_10 * 0.5)
  ), 0.0, 1.0));
  OUT_12.xyz = (OUT_12.xyz * tmpvar_89);
  highp float tmpvar_90;
  tmpvar_90 = clamp (dot (-(tmpvar_52), SunDirection.xyz), 0.0, 1.0);
  highp float tmpvar_91;
  tmpvar_91 = (1.0 - xlv_TEXCOORD3.w);
  OUT_12.xyz = ((OUT_12.xyz * tmpvar_91) + ((
    (OUT_12.xyz * tmpvar_91)
   + 
    (((FogColor2.xyz * clamp (
      ((tmpvar_52.y * 5.0) + 1.0)
    , 0.0, 1.0)) + FogColor.xyz) + (FogColor3.xyz * (tmpvar_90 * tmpvar_90)))
  ) * xlv_TEXCOORD3.w));
  OUT_12.xyz = (OUT_12.xyz * EnvInfo.z);
  OUT_12.xyz = clamp (OUT_12.xyz, vec3(0.0, 0.0, 0.0), vec3(4.0, 4.0, 4.0));
  highp vec3 tmpvar_92;
  tmpvar_92.x = FogColor.w;
  tmpvar_92.y = FogColor2.w;
  tmpvar_92.z = FogColor3.w;
  OUT_12.xyz = (OUT_12.xyz * tmpvar_92);
  OUT_12.xyz = (OUT_12.xyz / ((OUT_12.xyz * 0.9661836) + 0.180676));
  highp float tmpvar_93;
  tmpvar_93 = float(((
    clamp (cGrayPencent, 0.0, 1.0)
   + UserData[2].x) >= 2.0));
  OUT_12.xyz = ((OUT_12.xyz * (1.0 - tmpvar_93)) + (tmpvar_93 * dot (OUT_12.xyz, vec3(0.3, 0.59, 0.11))));
  OUT_12.xyz = (OUT_12.xyz * OUT_12.w);
  SV_Target = OUT_12;
}

 