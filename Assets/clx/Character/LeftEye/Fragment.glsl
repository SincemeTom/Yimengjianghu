#version 300 es
uniform highp vec4 EnvInfo;
uniform highp vec4 SunColor;
uniform highp vec4 SunDirection;
uniform highp vec4 FogColor;
uniform highp vec4 ShadowColor;
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
uniform highp float cBaseMapBias;
uniform highp float cNormalMapBias;
uniform highp vec4 cEyeColor;
uniform highp vec4 cColorTransform0;
uniform highp vec4 cColorTransform1;
uniform highp vec4 cColorTransform2;
uniform highp float cGrayPencent;
uniform mediump sampler2D sBaseSampler;
uniform mediump sampler2D sNormalSampler;
uniform mediump sampler2D sRefMaskSampler;
uniform mediump sampler2D sModelEnvSampler;
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
  highp vec4 OUT_1;
  highp vec3 Specular_2;
  highp float F_3;
  highp vec3 Lighting_4;
  highp vec3 VirtualLight2_5;
  highp vec3 VirtualLight_6;
  highp vec3 DirectLight2_7;
  highp vec3 SunColor2_8;
  highp vec3 R_9;
  mediump vec2 inRange_10;
  mediump float shadow_11;
  highp vec4 GILighting_12;
  mediump vec4 tangentNormal_13;
  highp vec3 SpecularColor_14;
  highp vec3 refmask_15;
  highp vec4 Diffuse_16;
  mediump vec4 tmpvar_17;
  tmpvar_17 = texture (sBaseSampler, xlv_TEXCOORD0.xy, cBaseMapBias);
  Diffuse_16 = tmpvar_17;
  Diffuse_16.xyz = (Diffuse_16.xyz * Diffuse_16.xyz);
  mediump vec3 tmpvar_18;
  tmpvar_18 = texture (sRefMaskSampler, xlv_TEXCOORD0.xy).xyz;
  refmask_15 = tmpvar_18;
  highp vec4 tmpvar_19;
  tmpvar_19.w = 1.0;
  tmpvar_19.xyz = Diffuse_16.xyz;
  highp vec3 tmpvar_20;
  tmpvar_20.x = dot (cColorTransform0, tmpvar_19);
  tmpvar_20.y = dot (cColorTransform1, tmpvar_19);
  tmpvar_20.z = dot (cColorTransform2, tmpvar_19);
  Diffuse_16.xyz = ((Diffuse_16.xyz * (1.0 - refmask_15.z)) + (clamp (tmpvar_20, 0.0, 1.0) * refmask_15.z));
  SpecularColor_14 = vec3(0.04, 0.04, 0.04);
  mediump vec4 color_21;
  color_21 = texture (sNormalSampler, xlv_TEXCOORD0.xy, cNormalMapBias);
  tangentNormal_13.w = color_21.w;
  tangentNormal_13.xyz = ((color_21.xyz * 2.0) - 1.0);
  highp vec3 tmpvar_22;
  tmpvar_22 = normalize(((
    (xlv_TEXCOORD4 * tangentNormal_13.x)
   + 
    (xlv_TEXCOORD5 * tangentNormal_13.y)
  ) + (xlv_TEXCOORD2.xyz * tangentNormal_13.z)));
  highp vec3 tmpvar_23;
  tmpvar_23 = (tmpvar_22 - normalize(xlv_TEXCOORD2.xyz));
  mediump vec3 tmpvar_24;
  mediump vec4 linearColor_25;
  mediump vec3 nSquared_26;
  highp vec3 tmpvar_27;
  tmpvar_27 = (tmpvar_22 * tmpvar_22);
  nSquared_26 = tmpvar_27;
  highp ivec3 tmpvar_28;
  tmpvar_28 = ivec3(lessThan (tmpvar_22, vec3(0.0, 0.0, 0.0)));
  highp vec4 tmpvar_29;
  tmpvar_29 = (((nSquared_26.x * cPointCloud[tmpvar_28.x]) + (nSquared_26.y * cPointCloud[
    (tmpvar_28.y + 2)
  ])) + (nSquared_26.z * cPointCloud[(tmpvar_28.z + 4)]));
  linearColor_25 = tmpvar_29;
  linearColor_25.xyz = max (vec3(0.9, 0.9, 0.9), linearColor_25.xyz);
  highp vec3 tmpvar_30;
  tmpvar_30 = vec3((ShadowColor.x * (10.0 + (
    (cPointCloud[3].w * ShadowColor.z)
   * 100.0))));
  linearColor_25.xyz = (linearColor_25.xyz * tmpvar_30);
  tmpvar_24 = linearColor_25.xyz;
  GILighting_12.xyz = tmpvar_24;
  GILighting_12.w = 1.0;
  highp vec3 tmpvar_31;
  tmpvar_31 = (xlv_TEXCOORD6.xyz / xlv_TEXCOORD6.w);
  highp float tmpvar_32;
  tmpvar_32 = min (0.99999, tmpvar_31.z);
  highp vec2 tmpvar_33;
  tmpvar_33 = vec2(lessThan (abs(
    (tmpvar_31.xy - 0.5)
  ), vec2(0.5, 0.5)));
  inRange_10 = tmpvar_33;
  inRange_10.x = (inRange_10.x * inRange_10.y);
  highp float inShadow_34;
  highp vec3 sampleDepth3_35;
  highp vec3 sampleDepth2_36;
  highp vec3 sampleDepth1_37;
  sampleDepth1_37.x = dot (texture (sShadowMapSampler, (tmpvar_31.xy - cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth1_37.y = dot (texture (sShadowMapSampler, (tmpvar_31.xy + (cShadowBias.ww * vec2(0.0, -1.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth1_37.z = dot (texture (sShadowMapSampler, (tmpvar_31.xy + (cShadowBias.ww * vec2(1.0, -1.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth2_36.x = dot (texture (sShadowMapSampler, (tmpvar_31.xy + (cShadowBias.ww * vec2(-1.0, 0.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth2_36.y = dot (texture (sShadowMapSampler, tmpvar_31.xy), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth2_36.z = dot (texture (sShadowMapSampler, (tmpvar_31.xy + (cShadowBias.ww * vec2(1.0, 0.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth3_35.x = dot (texture (sShadowMapSampler, (tmpvar_31.xy + (cShadowBias.ww * vec2(-1.0, 1.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth3_35.y = dot (texture (sShadowMapSampler, (tmpvar_31.xy + (cShadowBias.ww * vec2(0.0, 1.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth3_35.z = dot (texture (sShadowMapSampler, (tmpvar_31.xy + cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec3 tmpvar_38;
  tmpvar_38 = vec3(greaterThan (vec3(tmpvar_32), sampleDepth2_36));
  highp vec2 tmpvar_39;
  tmpvar_39 = fract((tmpvar_31.xy / cShadowBias.ww));
  highp vec4 tmpvar_40;
  tmpvar_40 = ((vec3(
    greaterThan (vec3(tmpvar_32), sampleDepth1_37)
  ).xyyz * (1.0 - tmpvar_39.y)) + (tmpvar_38.xyyz * tmpvar_39.y));
  highp vec4 tmpvar_41;
  tmpvar_41 = ((tmpvar_38.xyyz * (1.0 - tmpvar_39.y)) + (vec3(
    greaterThan (vec3(tmpvar_32), sampleDepth3_35)
  ).xyyz * tmpvar_39.y));
  inShadow_34 = ((tmpvar_40.x * (1.0 - tmpvar_39.x)) + (tmpvar_40.y * tmpvar_39.x));
  inShadow_34 = (inShadow_34 + ((tmpvar_40.z * 
    (1.0 - tmpvar_39.x)
  ) + (tmpvar_40.w * tmpvar_39.x)));
  inShadow_34 = (inShadow_34 + ((tmpvar_41.x * 
    (1.0 - tmpvar_39.x)
  ) + (tmpvar_41.y * tmpvar_39.x)));
  inShadow_34 = (inShadow_34 + ((tmpvar_41.z * 
    (1.0 - tmpvar_39.x)
  ) + (tmpvar_41.w * tmpvar_39.x)));
  inShadow_34 = (inShadow_34 * 0.25);
  shadow_11 = inShadow_34;
  shadow_11 = (shadow_11 * inRange_10.x);
  shadow_11 = (1.0 - shadow_11);
  highp vec3 tmpvar_42;
  tmpvar_42 = normalize(-(xlv_TEXCOORD3.xyz));
  highp vec3 tmpvar_43;
  tmpvar_43 = normalize((tmpvar_22 - (tmpvar_23 * 2.0)));
  highp vec3 I_44;
  I_44 = -(tmpvar_42);
  R_9 = (I_44 - (2.0 * (
    dot (tmpvar_43, I_44)
   * tmpvar_43)));
  mediump float color_45;
  color_45 = clamp (dot (tmpvar_22, tmpvar_42), 0.0, 1.0);
  SunColor2_8 = (((
    (SunColor.xyz * UserData[1].x)
   * 2.0) * ShadowColor.y) * cPointCloud[0].w);
  GILighting_12.xyz = (GILighting_12.xyz * (UserData[1].y * 2.0));
  highp float tmpvar_46;
  tmpvar_46 = clamp (dot (normalize(
    (tmpvar_22 + (tmpvar_23 * 3.0))
  ), SunDirection.xyz), 0.0, 1.0);
  DirectLight2_7 = (vec3(tmpvar_46) * vec3(tmpvar_46));
  DirectLight2_7 = (((DirectLight2_7 * shadow_11) * (SunColor2_8 * Diffuse_16.w)) * (20.0 * cEyeColor.xyz));
  highp vec3 tmpvar_47;
  tmpvar_47 = normalize(cVirtualLitDir.xyz);
  highp vec3 tmpvar_48;
  tmpvar_48 = ((cVirtualLitColor.xyz * UserData[1].z) * 2.0);
  VirtualLight_6 = (vec3(clamp (dot (tmpvar_22, tmpvar_47), 0.0, 1.0)) * tmpvar_48);
  highp float tmpvar_49;
  tmpvar_49 = clamp (dot (normalize(
    (tmpvar_22 + (tmpvar_23 * 5.0))
  ), tmpvar_47), 0.0, 1.0);
  VirtualLight2_5 = (vec3(tmpvar_49) * vec3(tmpvar_49));
  VirtualLight2_5 = ((VirtualLight2_5 * tmpvar_48) * ((Diffuse_16.w * 10.0) * cEyeColor.xyz));
  Lighting_4 = (((
    (GILighting_12.xyz + (vec3((clamp (
      dot (normalize((tmpvar_22 + (tmpvar_23 * 0.5))), SunDirection.xyz)
    , 0.0, 1.0) * shadow_11)) * SunColor2_8))
   + DirectLight2_7) + VirtualLight_6) + VirtualLight2_5);
  mediump vec3 tmpvar_50;
  mediump vec3 SpecularColor_51;
  SpecularColor_51 = SpecularColor_14;
  mediump vec2 tmpvar_52;
  tmpvar_52 = ((vec2(-1.04, 1.04) * (
    (min (0.49, exp2((-9.28 * color_45))) * 0.7)
   + 0.03425)) + vec2(0.8684, -0.0334));
  tmpvar_50 = ((SpecularColor_51 * tmpvar_52.x) + tmpvar_52.y);
  SpecularColor_14 = tmpvar_50;
  highp float tmpvar_53;
  tmpvar_53 = ((0.2 * (1.0 - refmask_15.z)) + (5.0 * refmask_15.z));
  mediump float tmpvar_54;
  tmpvar_54 = (1.0 - color_45);
  F_3 = tmpvar_54;
  F_3 = ((F_3 * F_3) * (F_3 * F_3));
  highp vec3 R_55;
  R_55.z = R_9.z;
  mediump float fSign_56;
  mediump vec3 sampleEnvSpecular_57;
  highp float tmpvar_58;
  tmpvar_58 = float((R_9.z > 0.0));
  fSign_56 = tmpvar_58;
  mediump float tmpvar_59;
  tmpvar_59 = ((fSign_56 * 2.0) - 1.0);
  R_55.xy = (R_9.xy / ((R_9.z * tmpvar_59) + 1.0));
  R_55.xy = ((R_55.xy * vec2(0.25, -0.25)) + (0.25 + (0.5 * fSign_56)));
  mediump vec4 tmpvar_60;
  tmpvar_60 = textureLod (sModelEnvSampler, R_55.xy, 0.0);
  sampleEnvSpecular_57 = (tmpvar_60.xyz * ((tmpvar_60.w * tmpvar_60.w) * 16.0));
  highp float tmpvar_61;
  tmpvar_61 = (cEnvStrength * EnvInfo.w);
  sampleEnvSpecular_57 = (sampleEnvSpecular_57 * (tmpvar_61 * 10.0));
  highp vec3 R_62;
  R_62.z = R_9.z;
  mediump float fSign_63;
  mediump vec3 sampleEnvSpecular_64;
  highp float tmpvar_65;
  tmpvar_65 = float((R_9.z > 0.0));
  fSign_63 = tmpvar_65;
  mediump float tmpvar_66;
  tmpvar_66 = ((fSign_63 * 2.0) - 1.0);
  R_62.xy = (R_9.xy / ((R_9.z * tmpvar_66) + 1.0));
  R_62.xy = ((R_62.xy * vec2(0.25, -0.25)) + (0.25 + (0.5 * fSign_63)));
  mediump vec4 tmpvar_67;
  tmpvar_67 = textureLod (sModelEnvSampler, R_62.xy, 1.764706);
  sampleEnvSpecular_64 = (tmpvar_67.xyz * ((tmpvar_67.w * tmpvar_67.w) * 16.0));
  sampleEnvSpecular_64 = (sampleEnvSpecular_64 * (tmpvar_61 * 10.0));
  highp vec3 tmpvar_68;
  tmpvar_68 = (((
    ((pow (max (0.0001, 
      dot (tmpvar_43, normalize((SunDirection.xyz + tmpvar_42)))
    ), 500.0) * SunColor2_8) * shadow_11)
   * tmpvar_53) + (
    (pow (max (0.0001, dot (tmpvar_43, tmpvar_42)), 500.0) * VirtualLight_6)
   * tmpvar_53)) + ((0.5 * 
    ((sampleEnvSpecular_64 * SpecularColor_14) + (sampleEnvSpecular_57 * (F_3 + 0.1)))
  ) * dot (GILighting_12.xyz, vec3(0.3, 0.59, 0.11))));
  Specular_2 = tmpvar_68;
  mediump vec3 SpecularColor_69;
  SpecularColor_69 = (SpecularColor_14 * 2.0);
  mediump vec3 DiffLit_70;
  DiffLit_70 = Lighting_4;
  mediump vec3 lighting_71;
  lighting_71 = vec3(0.0, 0.0, 0.0);
  if ((Lights0[3].w > 0.0)) {
    highp float D_72;
    highp float Atten_73;
    highp vec3 L_74;
    highp vec3 tmpvar_75;
    tmpvar_75 = (Lights0[0].xyz - xlv_TEXCOORD1.xyz);
    highp float tmpvar_76;
    tmpvar_76 = sqrt(dot (tmpvar_75, tmpvar_75));
    L_74 = (tmpvar_75 / tmpvar_76);
    highp float tmpvar_77;
    tmpvar_77 = clamp (dot (tmpvar_43, L_74), 0.0, 1.0);
    highp float tmpvar_78;
    tmpvar_78 = clamp (((tmpvar_76 * Lights0[1].w) + Lights0[0].w), 0.0, 1.0);
    Atten_73 = (tmpvar_78 * tmpvar_78);
    DiffLit_70 = (DiffLit_70 + (Lights0[1].xyz * (tmpvar_77 * Atten_73)));
    highp float tmpvar_79;
    tmpvar_79 = clamp (dot (tmpvar_43, normalize(
      (tmpvar_42 + L_74)
    )), 0.0, 1.0);
    highp float tmpvar_80;
    tmpvar_80 = (((
      (tmpvar_79 * 0.008136041)
     - tmpvar_79) * tmpvar_79) + 1.0);
    D_72 = ((tmpvar_80 * tmpvar_80) + 1e-06);
    D_72 = (0.00203401 / D_72);
    lighting_71 = ((Lights0[1].xyz * SpecularColor_69) * ((Atten_73 * tmpvar_77) * D_72));
  };
  if (((Lights1[3].w > 0.0) && (Lights1[2].w <= 0.0))) {
    highp float D_81;
    mediump float spot_82;
    mediump float Atten_83;
    mediump float DoL_84;
    mediump float NoL_85;
    mediump vec3 L_86;
    highp vec4 tmpvar_87;
    tmpvar_87 = Lights1[0];
    highp vec4 tmpvar_88;
    tmpvar_88 = Lights1[1];
    highp vec3 tmpvar_89;
    tmpvar_89 = Lights1[3].xyz;
    highp vec3 tmpvar_90;
    tmpvar_90 = (tmpvar_87.xyz - xlv_TEXCOORD1.xyz);
    L_86 = tmpvar_90;
    mediump float tmpvar_91;
    tmpvar_91 = sqrt(dot (L_86, L_86));
    L_86 = (L_86 / tmpvar_91);
    highp float tmpvar_92;
    tmpvar_92 = clamp (dot (tmpvar_43, L_86), 0.0, 1.0);
    NoL_85 = tmpvar_92;
    highp float tmpvar_93;
    mediump vec3 y_94;
    y_94 = -(L_86);
    tmpvar_93 = dot (Lights1[2].xyz, y_94);
    DoL_84 = tmpvar_93;
    highp float tmpvar_95;
    tmpvar_95 = clamp (((tmpvar_91 * tmpvar_88.w) + tmpvar_87.w), 0.0, 1.0);
    Atten_83 = tmpvar_95;
    Atten_83 = (Atten_83 * Atten_83);
    highp float tmpvar_96;
    tmpvar_96 = pow (clamp ((
      (DoL_84 * tmpvar_89.y)
     + tmpvar_89.z), 0.0, 1.0), tmpvar_89.x);
    spot_82 = tmpvar_96;
    highp float tmpvar_97;
    tmpvar_97 = clamp (dot (tmpvar_43, normalize(
      (tmpvar_42 + L_86)
    )), 0.0, 1.0);
    highp float tmpvar_98;
    tmpvar_98 = (((
      (tmpvar_97 * 0.008136041)
     - tmpvar_97) * tmpvar_97) + 1.0);
    D_81 = ((tmpvar_98 * tmpvar_98) + 1e-06);
    D_81 = (0.00203401 / D_81);
    lighting_71 = (lighting_71 + ((
      (Lights1[1].xyz * SpecularColor_69)
     * 
      ((Atten_83 * NoL_85) * D_81)
    ) * spot_82));
    DiffLit_70 = (DiffLit_70 + (tmpvar_88.xyz * (
      (NoL_85 * Atten_83)
     * spot_82)));
  };
  Lighting_4 = DiffLit_70;
  Specular_2 = (tmpvar_68 + lighting_71);
  Specular_2 = (Specular_2 * refmask_15.y);
  highp vec3 tmpvar_99;
  tmpvar_99 = (Specular_2 + ((Lighting_4 * Diffuse_16.xyz) / 3.14));
  highp vec4 tmpvar_100;
  tmpvar_100.w = 1.0;
  tmpvar_100.xyz = tmpvar_99;
  OUT_1.w = tmpvar_100.w;
  OUT_1.xyz = (tmpvar_99 * EnvInfo.z);
  highp float tmpvar_101;
  tmpvar_101 = clamp (dot (-(tmpvar_42), SunDirection.xyz), 0.0, 1.0);
  highp float tmpvar_102;
  tmpvar_102 = (1.0 - xlv_TEXCOORD3.w);
  OUT_1.xyz = ((OUT_1.xyz * tmpvar_102) + ((
    (OUT_1.xyz * tmpvar_102)
   + 
    (((FogColor2.xyz * clamp (
      ((tmpvar_42.y * 5.0) + 1.0)
    , 0.0, 1.0)) + FogColor.xyz) + (FogColor3.xyz * (tmpvar_101 * tmpvar_101)))
  ) * xlv_TEXCOORD3.w));
  highp vec3 tmpvar_103;
  tmpvar_103.x = FogColor.w;
  tmpvar_103.y = FogColor2.w;
  tmpvar_103.z = FogColor3.w;
  OUT_1.xyz = (OUT_1.xyz * tmpvar_103);
  OUT_1.xyz = (OUT_1.xyz / ((OUT_1.xyz * 0.9661836) + 0.180676));
  highp float tmpvar_104;
  tmpvar_104 = float(((
    clamp (cGrayPencent, 0.0, 1.0)
   + UserData[2].x) >= 2.0));
  OUT_1.xyz = ((OUT_1.xyz * (1.0 - tmpvar_104)) + (tmpvar_104 * dot (OUT_1.xyz, vec3(0.3, 0.59, 0.11))));
  SV_Target = OUT_1;
}

 