#version 300 es
uniform highp vec4 EnvInfo;
uniform highp vec4 SunColor;
uniform highp vec4 SunDirection;
uniform highp vec4 FogColor;
uniform highp vec4 ShadowColor;
uniform highp vec4 ScreenInfoPS;
uniform highp vec4 FogColor2;
uniform highp vec4 FogColor3;
uniform highp vec4 Lights0[4];
uniform highp vec4 Lights1[4];
uniform highp vec4 UserData[3];
uniform highp vec4 cShadowBias;
uniform highp vec4 cPointCloud[6];
uniform highp vec4 cVirtualLitDir;
uniform highp vec4 cVirtualLitColor;
uniform highp float cEnvStrength;
uniform highp float cRoughness;
uniform highp float cBaseMapBias;
uniform highp float cGrayPencent;
uniform mediump sampler2D sBaseSampler;
uniform mediump sampler2D sAOSampler;
uniform highp sampler2D ScreenTexture_Sampler;
uniform mediump sampler2D sModelEnvSampler;
uniform highp sampler2D sShadowMapSampler;
in highp vec4 xlv_TEXCOORD0;
in highp vec4 xlv_TEXCOORD1;
in highp vec4 xlv_TEXCOORD2;
in highp vec4 xlv_TEXCOORD3;
in highp vec4 xlv_TEXCOORD4;
out highp vec4 SV_Target;
void main ()
{
  highp vec4 OUT_1;
  highp vec3 Specular_2;
  highp vec3 Lighting_3;
  highp vec4 sceneColor_4;
  highp vec3 SunColor2_5;
  highp vec3 R_6;
  mediump vec2 inRange_7;
  mediump float shadow_8;
  highp vec4 GILighting_9;
  highp vec4 Diffuse_10;
  highp vec4 mixVal_11;
  highp vec3 SpecularColor_12;
  SpecularColor_12 = vec3(0.04, 0.04, 0.04);
  mediump vec4 tmpvar_13;
  tmpvar_13 = texture (sAOSampler, xlv_TEXCOORD0.xy);
  mixVal_11 = tmpvar_13;
  mediump vec4 tmpvar_14;
  tmpvar_14 = texture (sBaseSampler, xlv_TEXCOORD0.xy, cBaseMapBias);
  Diffuse_10 = tmpvar_14;
  Diffuse_10.xyz = (Diffuse_10.xyz * (Diffuse_10.xyz * Diffuse_10.w));
  highp vec3 tmpvar_15;
  tmpvar_15 = normalize(xlv_TEXCOORD2.xyz);
  mediump vec3 tmpvar_16;
  mediump vec4 linearColor_17;
  mediump vec3 nSquared_18;
  highp vec3 tmpvar_19;
  tmpvar_19 = (tmpvar_15 * tmpvar_15);
  nSquared_18 = tmpvar_19;
  highp ivec3 tmpvar_20;
  tmpvar_20 = ivec3(lessThan (tmpvar_15, vec3(0.0, 0.0, 0.0)));
  highp vec4 tmpvar_21;
  tmpvar_21 = (((nSquared_18.x * cPointCloud[tmpvar_20.x]) + (nSquared_18.y * cPointCloud[
    (tmpvar_20.y + 2)
  ])) + (nSquared_18.z * cPointCloud[(tmpvar_20.z + 4)]));
  linearColor_17 = tmpvar_21;
  linearColor_17.xyz = max (vec3(0.9, 0.9, 0.9), linearColor_17.xyz);
  highp vec3 tmpvar_22;
  tmpvar_22 = vec3((ShadowColor.x * (10.0 + (
    (cPointCloud[3].w * ShadowColor.z)
   * 100.0))));
  linearColor_17.xyz = (linearColor_17.xyz * tmpvar_22);
  tmpvar_16 = linearColor_17.xyz;
  GILighting_9.xyz = tmpvar_16;
  GILighting_9.xyz = (GILighting_9.xyz * (UserData[1].y * 2.0));
  GILighting_9.w = 1.0;
  highp vec3 tmpvar_23;
  tmpvar_23 = (xlv_TEXCOORD4.xyz / xlv_TEXCOORD4.w);
  highp float tmpvar_24;
  tmpvar_24 = min (0.99999, tmpvar_23.z);
  highp vec2 tmpvar_25;
  tmpvar_25 = vec2(lessThan (abs(
    (tmpvar_23.xy - 0.5)
  ), vec2(0.5, 0.5)));
  inRange_7 = tmpvar_25;
  inRange_7.x = (inRange_7.x * inRange_7.y);
  highp float inShadow_26;
  highp vec3 sampleDepth3_27;
  highp vec3 sampleDepth2_28;
  highp vec3 sampleDepth1_29;
  sampleDepth1_29.x = dot (texture (sShadowMapSampler, (tmpvar_23.xy - cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth1_29.y = dot (texture (sShadowMapSampler, (tmpvar_23.xy + (cShadowBias.ww * vec2(0.0, -1.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth1_29.z = dot (texture (sShadowMapSampler, (tmpvar_23.xy + (cShadowBias.ww * vec2(1.0, -1.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth2_28.x = dot (texture (sShadowMapSampler, (tmpvar_23.xy + (cShadowBias.ww * vec2(-1.0, 0.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth2_28.y = dot (texture (sShadowMapSampler, tmpvar_23.xy), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth2_28.z = dot (texture (sShadowMapSampler, (tmpvar_23.xy + (cShadowBias.ww * vec2(1.0, 0.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth3_27.x = dot (texture (sShadowMapSampler, (tmpvar_23.xy + (cShadowBias.ww * vec2(-1.0, 1.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth3_27.y = dot (texture (sShadowMapSampler, (tmpvar_23.xy + (cShadowBias.ww * vec2(0.0, 1.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth3_27.z = dot (texture (sShadowMapSampler, (tmpvar_23.xy + cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec3 tmpvar_30;
  tmpvar_30 = vec3(greaterThan (vec3(tmpvar_24), sampleDepth2_28));
  highp vec2 tmpvar_31;
  tmpvar_31 = fract((tmpvar_23.xy / cShadowBias.ww));
  highp vec4 tmpvar_32;
  tmpvar_32 = ((vec3(
    greaterThan (vec3(tmpvar_24), sampleDepth1_29)
  ).xyyz * (1.0 - tmpvar_31.y)) + (tmpvar_30.xyyz * tmpvar_31.y));
  highp vec4 tmpvar_33;
  tmpvar_33 = ((tmpvar_30.xyyz * (1.0 - tmpvar_31.y)) + (vec3(
    greaterThan (vec3(tmpvar_24), sampleDepth3_27)
  ).xyyz * tmpvar_31.y));
  inShadow_26 = ((tmpvar_32.x * (1.0 - tmpvar_31.x)) + (tmpvar_32.y * tmpvar_31.x));
  inShadow_26 = (inShadow_26 + ((tmpvar_32.z * 
    (1.0 - tmpvar_31.x)
  ) + (tmpvar_32.w * tmpvar_31.x)));
  inShadow_26 = (inShadow_26 + ((tmpvar_33.x * 
    (1.0 - tmpvar_31.x)
  ) + (tmpvar_33.y * tmpvar_31.x)));
  inShadow_26 = (inShadow_26 + ((tmpvar_33.z * 
    (1.0 - tmpvar_31.x)
  ) + (tmpvar_33.w * tmpvar_31.x)));
  inShadow_26 = (inShadow_26 * 0.25);
  shadow_8 = inShadow_26;
  shadow_8 = (shadow_8 * inRange_7.x);
  shadow_8 = (1.0 - shadow_8);
  highp vec3 tmpvar_34;
  tmpvar_34 = normalize(-(xlv_TEXCOORD3.xyz));
  highp vec3 I_35;
  I_35 = -(tmpvar_34);
  R_6 = (I_35 - (2.0 * (
    dot (tmpvar_15, I_35)
   * tmpvar_15)));
  mediump float color_36;
  color_36 = clamp (dot (tmpvar_15, tmpvar_34), 0.0, 1.0);
  mediump float color_37;
  color_37 = clamp (dot (tmpvar_15, SunDirection.xyz), 0.0, 1.0);
  SunColor2_5 = (SunColor.xyz * ((UserData[1].x * 2.0) * ShadowColor.y));
  SunColor2_5 = (SunColor2_5 * cPointCloud[0].w);
  highp vec4 tmpvar_38;
  tmpvar_38 = texture (ScreenTexture_Sampler, (gl_FragCoord.xy * ScreenInfoPS.zw));
  sceneColor_4.w = tmpvar_38.w;
  sceneColor_4.xyz = ((0.187 * tmpvar_38.xyz) / (1.035 - tmpvar_38.xyz));
  highp vec3 tmpvar_39;
  tmpvar_39.x = FogColor.w;
  tmpvar_39.y = FogColor2.w;
  tmpvar_39.z = FogColor3.w;
  sceneColor_4.xyz = (sceneColor_4.xyz / tmpvar_39);
  mediump vec3 tmpvar_40;
  mediump vec3 SpecularColor_41;
  SpecularColor_41 = SpecularColor_12;
  mediump float Roughness_42;
  Roughness_42 = cRoughness;
  mediump vec4 tmpvar_43;
  tmpvar_43 = ((Roughness_42 * vec4(-1.0, -0.0275, -0.572, 0.022)) + vec4(1.0, 0.0425, 1.04, -0.04));
  mediump vec2 tmpvar_44;
  tmpvar_44 = ((vec2(-1.04, 1.04) * (
    (min ((tmpvar_43.x * tmpvar_43.x), exp2((-9.28 * color_36))) * tmpvar_43.x)
   + tmpvar_43.y)) + tmpvar_43.zw);
  tmpvar_40 = ((SpecularColor_41 * tmpvar_44.x) + tmpvar_44.y);
  SpecularColor_12 = tmpvar_40;
  highp vec3 tmpvar_45;
  tmpvar_45 = normalize(cVirtualLitDir.xyz);
  highp float tmpvar_46;
  tmpvar_46 = clamp (dot (tmpvar_15, tmpvar_45), 0.0, 1.0);
  Lighting_3 = (((
    (color_37 * SunColor2_5)
   * shadow_8) + GILighting_9.xyz) + ((
    (vec3(tmpvar_46) * cVirtualLitColor.xyz)
   * UserData[1].z) * 2.0));
  highp float tmpvar_47;
  tmpvar_47 = clamp (dot (tmpvar_15, SunDirection.xyz), 0.0, 1.0);
  highp float tmpvar_48;
  tmpvar_48 = clamp (dot (tmpvar_15, normalize(
    (tmpvar_34 + SunDirection.xyz)
  )), 0.0, 1.0);
  highp float tmpvar_49;
  tmpvar_49 = (cRoughness * cRoughness);
  highp float tmpvar_50;
  tmpvar_50 = (tmpvar_49 * tmpvar_49);
  highp float tmpvar_51;
  tmpvar_51 = (((
    (tmpvar_48 * tmpvar_50)
   - tmpvar_48) * tmpvar_48) + 1.0);
  highp float tmpvar_52;
  tmpvar_52 = clamp (dot (tmpvar_15, tmpvar_45), 0.0, 1.0);
  highp float tmpvar_53;
  tmpvar_53 = clamp (dot (tmpvar_15, normalize(
    (tmpvar_34 + tmpvar_45)
  )), 0.0, 1.0);
  highp float tmpvar_54;
  tmpvar_54 = (tmpvar_49 * tmpvar_49);
  highp float tmpvar_55;
  tmpvar_55 = (((
    (tmpvar_53 * tmpvar_54)
   - tmpvar_53) * tmpvar_53) + 1.0);
  mediump float Roughness_56;
  Roughness_56 = cRoughness;
  highp vec3 R_57;
  R_57.z = R_6.z;
  mediump float fSign_58;
  mediump vec3 sampleEnvSpecular_59;
  highp float tmpvar_60;
  tmpvar_60 = float((R_6.z > 0.0));
  fSign_58 = tmpvar_60;
  mediump float tmpvar_61;
  tmpvar_61 = ((fSign_58 * 2.0) - 1.0);
  R_57.xy = (R_6.xy / ((R_6.z * tmpvar_61) + 1.0));
  R_57.xy = ((R_57.xy * vec2(0.25, -0.25)) + (0.25 + (0.5 * fSign_58)));
  mediump vec4 color_62;
  color_62 = textureLod (sModelEnvSampler, R_57.xy, (Roughness_56 / 0.17));
  sampleEnvSpecular_59 = (color_62.xyz * ((color_62.w * color_62.w) * 16.0));
  sampleEnvSpecular_59 = (sampleEnvSpecular_59 * ((cEnvStrength * EnvInfo.w) * 10.0));
  highp vec3 tmpvar_63;
  tmpvar_63 = (((
    ((sampleEnvSpecular_59 * SpecularColor_12) * ((mixVal_11.x * mixVal_11.w) * mixVal_11.y))
   * 
    dot (GILighting_9.xyz, vec3(0.3, 0.59, 0.11))
  ) + (
    ((((
      ((tmpvar_50 / (tmpvar_51 * tmpvar_51)) * 0.25)
     * SpecularColor_12) * (
      (tmpvar_47 * tmpvar_47)
     * 
      (tmpvar_47 * tmpvar_47)
    )) * SunColor2_5) * color_37)
   * shadow_8)) + ((
    ((((
      (tmpvar_54 / (tmpvar_55 * tmpvar_55))
     * 0.25) * SpecularColor_12) * ((tmpvar_52 * tmpvar_52) * (tmpvar_52 * tmpvar_52))) * vec3(tmpvar_46))
   * cVirtualLitColor.xyz) * (UserData[1].z * 2.0)));
  Specular_2 = tmpvar_63;
  highp vec3 tmpvar_64;
  tmpvar_64 = sceneColor_4.xyz;
  sceneColor_4.xyz = (sceneColor_4.xyz * (1.0 - Diffuse_10.w));
  highp float tmpvar_65;
  tmpvar_65 = clamp (cRoughness, 0.0, 1.0);
  mediump vec3 SpecularColor_66;
  SpecularColor_66 = (SpecularColor_12 * 2.0);
  mediump float Roughness_67;
  Roughness_67 = tmpvar_65;
  mediump vec3 DiffLit_68;
  DiffLit_68 = Lighting_3;
  mediump vec3 lighting_69;
  lighting_69 = vec3(0.0, 0.0, 0.0);
  if ((Lights0[3].w > 0.0)) {
    highp float D_70;
    highp float m2_71;
    highp float Atten_72;
    highp vec3 L_73;
    highp vec3 tmpvar_74;
    tmpvar_74 = (Lights0[0].xyz - xlv_TEXCOORD1.xyz);
    highp float tmpvar_75;
    tmpvar_75 = sqrt(dot (tmpvar_74, tmpvar_74));
    L_73 = (tmpvar_74 / tmpvar_75);
    highp float tmpvar_76;
    tmpvar_76 = clamp (dot (tmpvar_15, L_73), 0.0, 1.0);
    highp float tmpvar_77;
    tmpvar_77 = clamp (((tmpvar_75 * Lights0[1].w) + Lights0[0].w), 0.0, 1.0);
    Atten_72 = (tmpvar_77 * tmpvar_77);
    DiffLit_68 = (DiffLit_68 + (Lights0[1].xyz * (tmpvar_76 * Atten_72)));
    mediump float tmpvar_78;
    tmpvar_78 = ((Roughness_67 * Roughness_67) + 0.0002);
    m2_71 = tmpvar_78;
    m2_71 = (m2_71 * m2_71);
    highp float tmpvar_79;
    tmpvar_79 = clamp (dot (tmpvar_15, normalize(
      (tmpvar_34 + L_73)
    )), 0.0, 1.0);
    highp float tmpvar_80;
    tmpvar_80 = (((
      (tmpvar_79 * m2_71)
     - tmpvar_79) * tmpvar_79) + 1.0);
    D_70 = ((tmpvar_80 * tmpvar_80) + 1e-06);
    D_70 = ((0.25 * m2_71) / D_70);
    lighting_69 = ((Lights0[1].xyz * SpecularColor_66) * ((Atten_72 * tmpvar_76) * D_70));
  };
  if (((Lights1[3].w > 0.0) && (Lights1[2].w <= 0.0))) {
    highp float D_81;
    highp float m2_82;
    mediump float spot_83;
    mediump float Atten_84;
    mediump float DoL_85;
    mediump float NoL_86;
    mediump vec3 L_87;
    highp vec4 tmpvar_88;
    tmpvar_88 = Lights1[0];
    highp vec4 tmpvar_89;
    tmpvar_89 = Lights1[1];
    highp vec3 tmpvar_90;
    tmpvar_90 = Lights1[3].xyz;
    highp vec3 tmpvar_91;
    tmpvar_91 = (tmpvar_88.xyz - xlv_TEXCOORD1.xyz);
    L_87 = tmpvar_91;
    mediump float tmpvar_92;
    tmpvar_92 = sqrt(dot (L_87, L_87));
    L_87 = (L_87 / tmpvar_92);
    highp float tmpvar_93;
    tmpvar_93 = clamp (dot (tmpvar_15, L_87), 0.0, 1.0);
    NoL_86 = tmpvar_93;
    highp float tmpvar_94;
    mediump vec3 y_95;
    y_95 = -(L_87);
    tmpvar_94 = dot (Lights1[2].xyz, y_95);
    DoL_85 = tmpvar_94;
    highp float tmpvar_96;
    tmpvar_96 = clamp (((tmpvar_92 * tmpvar_89.w) + tmpvar_88.w), 0.0, 1.0);
    Atten_84 = tmpvar_96;
    Atten_84 = (Atten_84 * Atten_84);
    highp float tmpvar_97;
    tmpvar_97 = pow (clamp ((
      (DoL_85 * tmpvar_90.y)
     + tmpvar_90.z), 0.0, 1.0), tmpvar_90.x);
    spot_83 = tmpvar_97;
    mediump float tmpvar_98;
    tmpvar_98 = ((Roughness_67 * Roughness_67) + 0.0002);
    m2_82 = tmpvar_98;
    m2_82 = (m2_82 * m2_82);
    highp float tmpvar_99;
    tmpvar_99 = clamp (dot (tmpvar_15, normalize(
      (tmpvar_34 + L_87)
    )), 0.0, 1.0);
    highp float tmpvar_100;
    tmpvar_100 = (((
      (tmpvar_99 * m2_82)
     - tmpvar_99) * tmpvar_99) + 1.0);
    D_81 = ((tmpvar_100 * tmpvar_100) + 1e-06);
    D_81 = ((0.25 * m2_82) / D_81);
    lighting_69 = (lighting_69 + ((
      (Lights1[1].xyz * SpecularColor_66)
     * 
      ((Atten_84 * NoL_86) * D_81)
    ) * spot_83));
    DiffLit_68 = (DiffLit_68 + (tmpvar_89.xyz * (
      (NoL_86 * Atten_84)
     * spot_83)));
  };
  Lighting_3 = DiffLit_68;
  Specular_2 = (tmpvar_63 + lighting_69);
  sceneColor_4.xyz = (sceneColor_4.xyz + ((Lighting_3 * Diffuse_10.xyz) / 3.14));
  sceneColor_4.xyz = (sceneColor_4.xyz + Specular_2);
  sceneColor_4.xyz = (sceneColor_4.xyz * (mixVal_11.x * EnvInfo.z));
  highp vec3 tmpvar_101;
  tmpvar_101 = sceneColor_4.xyz;
  highp float tmpvar_102;
  tmpvar_102 = clamp (dot (-(tmpvar_34), SunDirection.xyz), 0.0, 1.0);
  highp float tmpvar_103;
  tmpvar_103 = (1.0 - xlv_TEXCOORD3.w);
  sceneColor_4.xyz = ((sceneColor_4.xyz * tmpvar_103) + ((
    (sceneColor_4.xyz * tmpvar_103)
   + 
    (((FogColor2.xyz * clamp (
      ((tmpvar_34.y * 5.0) + 1.0)
    , 0.0, 1.0)) + FogColor.xyz) + (FogColor3.xyz * (tmpvar_102 * tmpvar_102)))
  ) * xlv_TEXCOORD3.w));
  sceneColor_4.xyz = ((tmpvar_101 * (1.0 - Diffuse_10.w)) + (sceneColor_4.xyz * Diffuse_10.w));
  sceneColor_4.xyz = ((tmpvar_64 * (1.0 - 
    sqrt(mixVal_11.w)
  )) + (sceneColor_4.xyz * sqrt(mixVal_11.w)));
  highp vec4 tmpvar_104;
  tmpvar_104.w = 1.0;
  tmpvar_104.xyz = sceneColor_4.xyz;
  OUT_1.w = tmpvar_104.w;
  highp vec3 tmpvar_105;
  tmpvar_105.x = FogColor.w;
  tmpvar_105.y = FogColor2.w;
  tmpvar_105.z = FogColor3.w;
  OUT_1.xyz = (sceneColor_4.xyz * tmpvar_105);
  OUT_1.xyz = (OUT_1.xyz / ((OUT_1.xyz * 0.9661836) + 0.180676));
  highp float tmpvar_106;
  tmpvar_106 = float(((
    clamp (cGrayPencent, 0.0, 1.0)
   + UserData[2].x) >= 2.0));
  OUT_1.xyz = ((OUT_1.xyz * (1.0 - tmpvar_106)) + (tmpvar_106 * dot (OUT_1.xyz, vec3(0.3, 0.59, 0.11))));
  SV_Target = OUT_1;
}

 