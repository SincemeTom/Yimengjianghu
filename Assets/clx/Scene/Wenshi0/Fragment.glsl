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
uniform highp vec4 cShadowBias;
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
uniform highp sampler2D sShadowMapSampler;
uniform highp sampler2D sSecondShadowSampler;
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
  highp vec3 R_1;
  mediump vec3 SpecularColor_2;
  mediump vec3 DiffuseColor_3;
  highp vec4 sampleDepth_4;
  mediump vec2 inRange_5;
  mediump float shadow2_6;
  mediump vec2 shadow_and_ao_7;
  mediump float shadow_8;
  highp vec4 OUT_9;
  mediump vec3 BaseColor_10;
  mediump float Metallic_11;
  highp vec3 N_12;
  mediump vec4 Emission_13;
  mediump vec4 GILighting_14;
  mediump float Alpha_15;
  mediump float SSSmask_16;
  mediump vec4 tangentNormal_17;
  highp vec4 base_color_data_18;
  highp float mask_19;
  mediump vec4 tmpvar_20;
  tmpvar_20 = texture (sBaseSampler, xlv_TEXCOORD0.xy, cBaseMapBias);
  BaseColor_10 = (tmpvar_20.xyz * tmpvar_20.xyz);
  Alpha_15 = tmpvar_20.w;
  mask_19 = Alpha_15;
  mediump vec4 tmpvar_21;
  tmpvar_21.w = 1.0;
  tmpvar_21.xyz = BaseColor_10;
  base_color_data_18 = tmpvar_21;
  highp vec3 tmpvar_22;
  tmpvar_22.x = dot (cColorTransform0, base_color_data_18);
  tmpvar_22.y = dot (cColorTransform1, base_color_data_18);
  tmpvar_22.z = dot (cColorTransform2, base_color_data_18);
  highp vec3 tmpvar_23;
  tmpvar_23 = ((BaseColor_10 * (1.0 - mask_19)) + (clamp (tmpvar_22, 0.0, 1.0) * mask_19));
  BaseColor_10 = tmpvar_23;
  Emission_13.w = 0.0;
  Metallic_11 = clamp (((tmpvar_20.w * 2.0) - 1.0), 0.0, 1.0);
  mediump vec4 tmpvar_24;
  tmpvar_24 = texture (sNormalSampler, xlv_TEXCOORD0.xy, cNormalMapBias);
  tangentNormal_17.zw = tmpvar_24.zw;
  SSSmask_16 = (1.0 - tmpvar_24.w);
  mediump float tmpvar_25;
  mediump float rain_26;
  rain_26 = EnvInfo.x;
  highp float tmpvar_27;
  tmpvar_27 = clamp (((xlv_TEXCOORD2.y * 0.7) + (0.4 * rain_26)), 0.0, 1.0);
  rain_26 = (1.0 - (rain_26 * tmpvar_27));
  tmpvar_25 = (rain_26 - (rain_26 * tmpvar_24.z));
  tangentNormal_17.xy = ((tmpvar_24.xy * 2.0) - 1.0);
  tangentNormal_17.xy = (tangentNormal_17.xy * cParamter.w);
  mediump float tmpvar_28;
  tmpvar_28 = sqrt(clamp ((
    (1.0 - (tangentNormal_17.x * tangentNormal_17.x))
   - 
    (tangentNormal_17.y * tangentNormal_17.y)
  ), 0.0, 1.0));
  N_12 = (((xlv_TEXCOORD4 * tangentNormal_17.x) + (xlv_TEXCOORD5 * tangentNormal_17.y)) + (xlv_TEXCOORD2.xyz * tmpvar_28));
  highp vec3 tmpvar_29;
  tmpvar_29 = normalize(N_12);
  N_12 = tmpvar_29;
  highp vec3 tmpvar_30;
  tmpvar_30.x = dot (cColorTransform3, base_color_data_18);
  tmpvar_30.y = dot (cColorTransform4, base_color_data_18);
  tmpvar_30.z = dot (cColorTransform5, base_color_data_18);
  highp vec3 tmpvar_31;
  tmpvar_31 = ((BaseColor_10 * (1.0 - SSSmask_16)) + (clamp (tmpvar_30, 0.0, 1.0) * SSSmask_16));
  BaseColor_10 = tmpvar_31;
  highp vec2 tmpvar_32;
  tmpvar_32.x = xlv_TEXCOORD1.w;
  tmpvar_32.y = xlv_TEXCOORD2.w;
  Emission_13.xyz = texture (sEmissionMapSampler, tmpvar_32).xyz;
  Emission_13.xyz = (Emission_13.xyz * cEmissionScale.xyz);
  Emission_13.xyz = (Emission_13.xyz * UserData[0].xyz);
  Emission_13.xyz = (Emission_13.xyz * tmpvar_20.w);
  GILighting_14.xyz = vec3(0.0, 0.0, 0.0);
  GILighting_14.w = tmpvar_24.w;
  OUT_9.w = Alpha_15;
  highp vec2 tmpvar_33;
  tmpvar_33 = texture (sSecondShadowSampler, (gl_FragCoord.xy * ScreenInfoPS.zw)).xy;
  shadow_and_ao_7 = tmpvar_33;
  shadow_8 = (1.0 - shadow_and_ao_7.x);
  highp vec3 tmpvar_34;
  tmpvar_34 = (xlv_TEXCOORD6.xyz / xlv_TEXCOORD6.w);
  highp vec2 tmpvar_35;
  tmpvar_35 = vec2(lessThan (abs(
    (tmpvar_34.xy - 0.5)
  ), vec2(0.5, 0.5)));
  inRange_5 = tmpvar_35;
  inRange_5.x = (inRange_5.x * inRange_5.y);
  sampleDepth_4.x = dot (texture (sShadowMapSampler, tmpvar_34.xy), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth_4.y = dot (texture (sShadowMapSampler, (tmpvar_34.xy + (cShadowBias.ww * vec2(1.0, 0.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth_4.z = dot (texture (sShadowMapSampler, (tmpvar_34.xy + (cShadowBias.ww * vec2(0.0, 1.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth_4.w = dot (texture (sShadowMapSampler, (tmpvar_34.xy + cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec4 tmpvar_36;
  tmpvar_36 = vec4(greaterThan (vec4(min (0.99999, tmpvar_34.z)), sampleDepth_4));
  highp vec2 tmpvar_37;
  tmpvar_37 = fract((tmpvar_34.xy / cShadowBias.ww));
  highp vec2 tmpvar_38;
  tmpvar_38 = ((tmpvar_36.xz * (1.0 - tmpvar_37.x)) + (tmpvar_36.yw * tmpvar_37.x));
  shadow2_6 = ((tmpvar_38.x * (1.0 - tmpvar_37.y)) + (tmpvar_38.y * tmpvar_37.y));
  shadow2_6 = (shadow2_6 * inRange_5.x);
  shadow2_6 = (1.0 - shadow2_6);
  shadow_8 = min (shadow_8, shadow2_6);
  SpecularColor_2 = ((BaseColor_10 * Metallic_11) + 0.04);
  DiffuseColor_3 = ((BaseColor_10 - (BaseColor_10 * Metallic_11)) / 3.141593);
  highp vec3 tmpvar_39;
  tmpvar_39 = normalize(-(xlv_TEXCOORD3.xyz));
  highp vec3 I_40;
  I_40 = -(tmpvar_39);
  R_1 = (I_40 - (2.0 * (
    dot (tmpvar_29, I_40)
   * tmpvar_29)));
  mediump float color_41;
  color_41 = clamp (dot (tmpvar_29, tmpvar_39), 0.0, 1.0);
  mediump float color_42;
  color_42 = dot (SunDirection.xyz, tmpvar_29);
  shadow_8 = (shadow_8 * clamp ((
    (abs(color_42) + ((2.0 * tmpvar_24.w) * tmpvar_24.w))
   - 1.0), 0.0, 1.0));
  mediump vec4 GILighting_43;
  GILighting_43.xyz = GILighting_14.xyz;
  mediump float shadow_44;
  mediump vec3 bakeLighting_45;
  mediump vec4 lightMapRaw_46;
  mediump vec4 lightMapScale_47;
  lightMapScale_47 = cLightMapScale;
  mediump vec4 tmpvar_48;
  tmpvar_48 = texture (sLightMapSampler, xlv_TEXCOORD0.zw);
  lightMapRaw_46.w = tmpvar_48.w;
  lightMapRaw_46.xyz = ((tmpvar_48.xyz * lightMapScale_47.xxx) + lightMapScale_47.yyy);
  mediump float tmpvar_49;
  tmpvar_49 = (dot (lightMapRaw_46.xyz, vec3(0.0955, 0.1878, 0.035)) + 7.5e-05);
  mediump float tmpvar_50;
  tmpvar_50 = exp2(((tmpvar_49 * 50.27) - 8.737));
  shadow_44 = (shadow_8 * (tmpvar_48.w * tmpvar_48.w));
  GILighting_43.w = (tmpvar_24.w * clamp (tmpvar_50, 0.0, 1.0));
  bakeLighting_45 = ((lightMapRaw_46 * (
    (tmpvar_24.w * tmpvar_50)
   / tmpvar_49)).xyz + (SunColor.xyz * clamp (
    (color_42 * shadow_44)
  , 0.0, 1.0)));
  shadow_8 = shadow_44;
  highp float D_51;
  mediump vec3 sunSpec_52;
  mediump float m2_53;
  mediump vec3 Spec_54;
  mediump float tmpvar_55;
  tmpvar_55 = ((tmpvar_25 * tmpvar_25) + 0.0002);
  m2_53 = (tmpvar_55 * tmpvar_55);
  mediump vec3 tmpvar_56;
  mediump vec4 tmpvar_57;
  tmpvar_57 = ((tmpvar_25 * vec4(-1.0, -0.0275, -0.572, 0.022)) + vec4(1.0, 0.0425, 1.04, -0.04));
  mediump vec2 tmpvar_58;
  tmpvar_58 = ((vec2(-1.04, 1.04) * (
    (min ((tmpvar_57.x * tmpvar_57.x), exp2((-9.28 * color_41))) * tmpvar_57.x)
   + tmpvar_57.y)) + tmpvar_57.zw);
  tmpvar_56 = ((SpecularColor_2 * tmpvar_58.x) + tmpvar_58.y);
  highp vec3 R_59;
  R_59.z = R_1.z;
  mediump float fSign_60;
  mediump vec3 sampleEnvSpecular_61;
  highp float tmpvar_62;
  tmpvar_62 = float((R_1.z > 0.0));
  fSign_60 = tmpvar_62;
  mediump float tmpvar_63;
  tmpvar_63 = ((fSign_60 * 2.0) - 1.0);
  R_59.xy = (R_1.xy / ((R_1.z * tmpvar_63) + 1.0));
  R_59.xy = ((R_59.xy * vec2(0.25, -0.25)) + (0.25 + (0.5 * fSign_60)));
  mediump vec4 tmpvar_64;
  tmpvar_64 = textureLod (sEnvSampler, R_59.xy, (tmpvar_25 / 0.17));
  sampleEnvSpecular_61 = (tmpvar_64.xyz * ((tmpvar_64.w * tmpvar_64.w) * 16.0));
  sampleEnvSpecular_61 = (sampleEnvSpecular_61 * ((cEnvStrength * GILighting_43.w) * (EnvInfo.w * 10.0)));
  highp float tmpvar_65;
  tmpvar_65 = clamp (dot (tmpvar_29, normalize(
    (tmpvar_39 + SunDirection.xyz)
  )), 0.0, 1.0);
  highp float tmpvar_66;
  tmpvar_66 = (((
    (tmpvar_65 * m2_53)
   - tmpvar_65) * tmpvar_65) + 1.0);
  D_51 = ((tmpvar_66 * tmpvar_66) + 1e-06);
  D_51 = ((0.25 * m2_53) / D_51);
  sunSpec_52 = (tmpvar_56 * D_51);
  sunSpec_52 = (sunSpec_52 * (SunColor.xyz * clamp (
    (color_42 * shadow_44)
  , 0.0, 1.0)));
  Spec_54 = ((tmpvar_56 * sampleEnvSpecular_61) + sunSpec_52);
  SpecularColor_2 = tmpvar_56;
  OUT_9.xyz = Spec_54;
  OUT_9.xyz = (OUT_9.xyz + Emission_13.xyz);
  OUT_9.xyz = (OUT_9.xyz + (bakeLighting_45 * DiffuseColor_3));
  mediump float tmpvar_67;
  tmpvar_67 = clamp ((shadow_and_ao_7.y + (shadow_44 * 0.5)), 0.0, 1.0);
  OUT_9.xyz = (OUT_9.xyz * tmpvar_67);
  highp float tmpvar_68;
  tmpvar_68 = clamp (dot (-(tmpvar_39), SunDirection.xyz), 0.0, 1.0);
  highp float tmpvar_69;
  tmpvar_69 = (1.0 - xlv_TEXCOORD3.w);
  OUT_9.xyz = ((OUT_9.xyz * tmpvar_69) + ((
    (OUT_9.xyz * tmpvar_69)
   + 
    (((FogColor2.xyz * clamp (
      ((tmpvar_39.y * 5.0) + 1.0)
    , 0.0, 1.0)) + FogColor.xyz) + (FogColor3.xyz * (tmpvar_68 * tmpvar_68)))
  ) * xlv_TEXCOORD3.w));
  OUT_9.xyz = (OUT_9.xyz * EnvInfo.z);
  OUT_9.xyz = clamp (OUT_9.xyz, vec3(0.0, 0.0, 0.0), vec3(4.0, 4.0, 4.0));
  OUT_9.xyz = ((OUT_9.xyz * (1.0 - ScreenColor.w)) + (ScreenColor.xyz * ScreenColor.w));
  highp vec3 tmpvar_70;
  tmpvar_70.x = FogColor.w;
  tmpvar_70.y = FogColor2.w;
  tmpvar_70.z = FogColor3.w;
  OUT_9.xyz = (OUT_9.xyz * tmpvar_70);
  OUT_9.xyz = (OUT_9.xyz / ((OUT_9.xyz * 0.9661836) + 0.180676));
  highp float tmpvar_71;
  tmpvar_71 = float(((
    clamp (cGrayPencent, 0.0, 1.0)
   + UserData[2].x) >= 2.0));
  OUT_9.xyz = ((OUT_9.xyz * (1.0 - tmpvar_71)) + (tmpvar_71 * dot (OUT_9.xyz, vec3(0.3, 0.59, 0.11))));
  OUT_9.w = 1.0;
  SV_Target = OUT_9;
}

 