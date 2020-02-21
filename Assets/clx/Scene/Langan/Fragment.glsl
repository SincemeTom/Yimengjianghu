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
uniform highp vec4 cColorTransform0;
uniform highp vec4 cColorTransform1;
uniform highp vec4 cColorTransform2;
uniform highp float cGrayPencent;
uniform highp vec4 cColorTransform3;
uniform highp vec4 cColorTransform4;
uniform highp vec4 cColorTransform5;
uniform mediump sampler2D sBaseSampler;
uniform mediump sampler2D sNormalSampler;
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
  mediump vec4 GILighting_13;
  mediump float Alpha_14;
  mediump float SSSmask_15;
  mediump vec4 tangentNormal_16;
  highp vec4 base_color_data_17;
  highp float mask_18;
  mediump vec4 tmpvar_19;
  tmpvar_19 = texture (sBaseSampler, xlv_TEXCOORD0.xy, cBaseMapBias);//col
  BaseColor_10 = (tmpvar_19.xyz * tmpvar_19.xyz);
  Alpha_14 = tmpvar_19.w;
  mask_18 = Alpha_14;
  mediump vec4 tmpvar_20;
  tmpvar_20.w = 1.0;
  tmpvar_20.xyz = BaseColor_10;
  base_color_data_17 = tmpvar_20;
  highp vec3 tmpvar_21;
  tmpvar_21.x = dot (cColorTransform0, base_color_data_17);
  tmpvar_21.y = dot (cColorTransform1, base_color_data_17);
  tmpvar_21.z = dot (cColorTransform2, base_color_data_17);// BaseColor
  highp vec3 tmpvar_22;
  tmpvar_22 = ((BaseColor_10 * (1.0 - mask_18)) + (clamp (tmpvar_21, 0.0, 1.0) * mask_18));
  BaseColor_10 = tmpvar_22;
  Metallic_11 = clamp (((tmpvar_19.w * 2.0) - 1.0), 0.0, 1.0);
  mediump vec4 tmpvar_23;
  tmpvar_23 = texture (sNormalSampler, xlv_TEXCOORD0.xy, cNormalMapBias);
  tangentNormal_16.zw = tmpvar_23.zw;
  SSSmask_15 = (1.0 - tmpvar_23.w);//SSSMask
  mediump float tmpvar_24;
  mediump float rain_25;
  rain_25 = EnvInfo.x;
  highp float tmpvar_26;
  tmpvar_26 = clamp (((xlv_TEXCOORD2.y * 0.7) + (0.4 * rain_25)), 0.0, 1.0);
  rain_25 = (1.0 - (rain_25 * tmpvar_26)); // Rain
  tmpvar_24 = (rain_25 - (rain_25 * tmpvar_23.z));//roughness
  tangentNormal_16.xy = ((tmpvar_23.xy * 2.0) - 1.0);
  tangentNormal_16.xy = (tangentNormal_16.xy * cParamter.w);
  mediump float tmpvar_27;
  tmpvar_27 = sqrt(clamp ((
    (1.0 - (tangentNormal_16.x * tangentNormal_16.x))
   - 
    (tangentNormal_16.y * tangentNormal_16.y)
  ), 0.0, 1.0));
  N_12 = (((xlv_TEXCOORD4 * tangentNormal_16.x) + (xlv_TEXCOORD5 * tangentNormal_16.y)) + (xlv_TEXCOORD2.xyz * tmpvar_27));
  highp vec3 tmpvar_28;
  tmpvar_28 = normalize(N_12);
  N_12 = tmpvar_28;//normalVec
  highp vec3 tmpvar_29;
  tmpvar_29.x = dot (cColorTransform3, base_color_data_17);
  tmpvar_29.y = dot (cColorTransform4, base_color_data_17);
  tmpvar_29.z = dot (cColorTransform5, base_color_data_17); // BaseColor
  highp vec3 tmpvar_30;
  tmpvar_30 = ((BaseColor_10 * (1.0 - SSSmask_15)) + (clamp (tmpvar_29, 0.0, 1.0) * SSSmask_15));
  BaseColor_10 = tmpvar_30; // // BaseColor
  GILighting_13.xyz = vec3(0.0, 0.0, 0.0);
  GILighting_13.w = tmpvar_23.w;
  OUT_9.w = Alpha_14;
  highp vec2 tmpvar_31;
  tmpvar_31 = texture (sSecondShadowSampler, (gl_FragCoord.xy * ScreenInfoPS.zw)).xy;
  shadow_and_ao_7 = tmpvar_31;
  shadow_8 = (1.0 - shadow_and_ao_7.x);//Runtime Scene Shadow
  highp vec3 tmpvar_32;
  tmpvar_32 = (xlv_TEXCOORD6.xyz / xlv_TEXCOORD6.w);//light space position
  highp vec2 tmpvar_33;
  tmpvar_33 = vec2(lessThan (abs(
    (tmpvar_32.xy - 0.5)
  ), vec2(0.5, 0.5)));
  inRange_5 = tmpvar_33;
  inRange_5.x = (inRange_5.x * inRange_5.y);
  sampleDepth_4.x = dot (texture (sShadowMapSampler, tmpvar_32.xy), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth_4.y = dot (texture (sShadowMapSampler, (tmpvar_32.xy + (cShadowBias.ww * vec2(1.0, 0.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth_4.z = dot (texture (sShadowMapSampler, (tmpvar_32.xy + (cShadowBias.ww * vec2(0.0, 1.0)))), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  sampleDepth_4.w = dot (texture (sShadowMapSampler, (tmpvar_32.xy + cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec4 tmpvar_34;
  tmpvar_34 = vec4(greaterThan (vec4(min (0.99999, tmpvar_32.z)), sampleDepth_4));
  highp vec2 tmpvar_35;
  tmpvar_35 = fract((tmpvar_32.xy / cShadowBias.ww));
  highp vec2 tmpvar_36;
  tmpvar_36 = ((tmpvar_34.xz * (1.0 - tmpvar_35.x)) + (tmpvar_34.yw * tmpvar_35.x));
  shadow2_6 = ((tmpvar_36.x * (1.0 - tmpvar_35.y)) + (tmpvar_36.y * tmpvar_35.y));
  shadow2_6 = (shadow2_6 * inRange_5.x);
  shadow2_6 = (1.0 - shadow2_6);//Runtime Character Shadow
  shadow_8 = min (shadow_8, shadow2_6);// Final Shadow
  SpecularColor_2 = ((BaseColor_10 * Metallic_11) + 0.04);
  DiffuseColor_3 = ((BaseColor_10 - (BaseColor_10 * Metallic_11)) / 3.141593);
  highp vec3 tmpvar_37;
  tmpvar_37 = normalize(-(xlv_TEXCOORD3.xyz));//viewDir
  highp vec3 I_38;
  I_38 = -(tmpvar_37);
  R_1 = (I_38 - (2.0 * (
    dot (tmpvar_28, I_38)
   * tmpvar_28)));
  mediump float color_39;
  color_39 = clamp (dot (tmpvar_28, tmpvar_37), 0.0, 1.0);//NdotV
  mediump float color_40;
  color_40 = dot (SunDirection.xyz, tmpvar_28);//NdotL
  shadow_8 = (shadow_8 * clamp ((
    (abs(color_40) + ((2.0 * tmpvar_23.w) * tmpvar_23.w))
   - 1.0), 0.0, 1.0));//shadow * ao
  mediump vec4 GILighting_41;
  GILighting_41.xyz = GILighting_13.xyz;
  mediump float shadow_42;
  mediump vec3 bakeLighting_43;
  mediump vec4 lightMapRaw_44;
  mediump vec4 lightMapScale_45;
  lightMapScale_45 = cLightMapScale;
  mediump vec4 tmpvar_46;
  tmpvar_46 = texture (sLightMapSampler, xlv_TEXCOORD0.zw);
  lightMapRaw_44.w = tmpvar_46.w;
  lightMapRaw_44.xyz = ((tmpvar_46.xyz * lightMapScale_45.xxx) + lightMapScale_45.yyy);
  mediump float tmpvar_47;
  tmpvar_47 = (dot (lightMapRaw_44.xyz, vec3(0.0955, 0.1878, 0.035)) + 7.5e-05);
  mediump float tmpvar_48;
  tmpvar_48 = exp2(((tmpvar_47 * 50.27) - 8.737));//lightmapColorTmp
  shadow_42 = (shadow_8 * (tmpvar_46.w * tmpvar_46.w));
  GILighting_41.w = (tmpvar_23.w * clamp (tmpvar_48, 0.0, 1.0));
  bakeLighting_43 = ((lightMapRaw_44 * (
    (tmpvar_23.w * tmpvar_48)
   / tmpvar_47)).xyz + (SunColor.xyz * clamp (
    (color_40 * shadow_42)
  , 0.0, 1.0)));
  shadow_8 = shadow_42;
  highp float D_49;
  mediump vec3 sunSpec_50;
  mediump float m2_51;
  mediump vec3 Spec_52;
  mediump float tmpvar_53;
  tmpvar_53 = ((tmpvar_24 * tmpvar_24) + 0.0002);//m
  m2_51 = (tmpvar_53 * tmpvar_53);
  mediump vec3 tmpvar_54;
  mediump vec4 tmpvar_55;
  tmpvar_55 = ((tmpvar_24 * vec4(-1.0, -0.0275, -0.572, 0.022)) + vec4(1.0, 0.0425, 1.04, -0.04));
  mediump vec2 tmpvar_56;
  tmpvar_56 = ((vec2(-1.04, 1.04) * (
    (min ((tmpvar_55.x * tmpvar_55.x), exp2((-9.28 * color_39))) * tmpvar_55.x)
   + tmpvar_55.y)) + tmpvar_55.zw);
  tmpvar_54 = ((SpecularColor_2 * tmpvar_56.x) + tmpvar_56.y); // ReflectColor
  highp vec3 R_57;
  R_57.z = R_1.z;
  mediump float fSign_58;
  mediump vec3 sampleEnvSpecular_59;
  highp float tmpvar_60;
  tmpvar_60 = float((R_1.z > 0.0));
  fSign_58 = tmpvar_60;
  mediump float tmpvar_61;
  tmpvar_61 = ((fSign_58 * 2.0) - 1.0);
  R_57.xy = (R_1.xy / ((R_1.z * tmpvar_61) + 1.0));
  R_57.xy = ((R_57.xy * vec2(0.25, -0.25)) + (0.25 + (0.5 * fSign_58)));
  mediump vec4 tmpvar_62;
  tmpvar_62 = textureLod (sEnvSampler, R_57.xy, (tmpvar_24 / 0.17));//srcColor
  sampleEnvSpecular_59 = (tmpvar_62.xyz * ((tmpvar_62.w * tmpvar_62.w) * 16.0));
  sampleEnvSpecular_59 = (sampleEnvSpecular_59 * ((cEnvStrength * GILighting_41.w) * (EnvInfo.w * 10.0)));
  highp float tmpvar_63;
  tmpvar_63 = clamp (dot (tmpvar_28, normalize(
    (tmpvar_37 + SunDirection.xyz)
  )), 0.0, 1.0);//NdotH
  highp float tmpvar_64;
  tmpvar_64 = (((
    (tmpvar_63 * m2_51)
   - tmpvar_63) * tmpvar_63) + 1.0);
  D_49 = ((tmpvar_64 * tmpvar_64) + 1e-06);
  D_49 = ((0.25 * m2_51) / D_49);
  sunSpec_50 = (tmpvar_54 * D_49);
  sunSpec_50 = (sunSpec_50 * (SunColor.xyz * clamp (
    (color_40 * shadow_42)
  , 0.0, 1.0)));
  Spec_52 = ((tmpvar_54 * sampleEnvSpecular_59) + sunSpec_50);//SpecColor
  SpecularColor_2 = tmpvar_54;
  OUT_9.xyz = Spec_52;
  OUT_9.xyz = OUT_9.xyz;
  OUT_9.xyz = (OUT_9.xyz + (bakeLighting_43 * DiffuseColor_3));
  mediump float tmpvar_65;
  tmpvar_65 = clamp ((shadow_and_ao_7.y + (shadow_42 * 0.5)), 0.0, 1.0);
  OUT_9.xyz = (OUT_9.xyz * tmpvar_65);//Blend AO
  highp float tmpvar_66;
  tmpvar_66 = clamp (dot (-tmpvar_37, SunDirection.xyz), 0.0, 1.0);//LdotI
  highp float tmpvar_67;
  tmpvar_67 = (1.0 - xlv_TEXCOORD3.w);
  OUT_9.xyz = ((OUT_9.xyz * tmpvar_67) + ((
    (OUT_9.xyz * tmpvar_67)
   + 
    (((FogColor2.xyz * clamp (
      ((tmpvar_37.y * 5.0) + 1.0)
    , 0.0, 1.0)) + FogColor.xyz) + (FogColor3.xyz * (tmpvar_66 * tmpvar_66)))
  ) * xlv_TEXCOORD3.w));
  OUT_9.xyz = (OUT_9.xyz * EnvInfo.z);
  OUT_9.xyz = clamp (OUT_9.xyz, vec3(0.0, 0.0, 0.0), vec3(4.0, 4.0, 4.0));
  OUT_9.xyz = ((OUT_9.xyz * (1.0 - ScreenColor.w)) + (ScreenColor.xyz * ScreenColor.w));
  highp vec3 tmpvar_68;
  tmpvar_68.x = FogColor.w;
  tmpvar_68.y = FogColor2.w;
  tmpvar_68.z = FogColor3.w;
  OUT_9.xyz = (OUT_9.xyz * tmpvar_68);
  OUT_9.xyz = (OUT_9.xyz / ((OUT_9.xyz * 0.9661836) + 0.180676));
  highp float tmpvar_69;
  tmpvar_69 = float(((
    clamp (cGrayPencent, 0.0, 1.0)
   + UserData[2].x) >= 2.0));
  OUT_9.xyz = ((OUT_9.xyz * (1.0 - tmpvar_69)) + (tmpvar_69 * dot (OUT_9.xyz, vec3(0.3, 0.59, 0.11))));
  OUT_9.w = 1.0;
  SV_Target = OUT_9;
}

 