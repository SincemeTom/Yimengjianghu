
uniform float3 BloomTint;
uniform sampler2D SourceLinear0_Sampler;
uniform sampler2D sBloomSampler0;
uniform sampler2D sBloomSampler1;

in float2 uv;
out float4 SV_Target;

void main()
{
    float3 sourceColor = texture(SourceLinear0_Sampler, uv).xyz;
    float3 bloom0Color = texture (sBloomSampler0, uv).xyz;
    float3 bloom1Color = texture (sBloomSampler1, uv).xyz;
    float3 sourceLinear = sourceColor * sourceColor;
    sourceLinear = sourceLinear.xyz + (bloom0Color * bloom0Color + bloom1Color * bloom1Color) * BloomTint * (1.0 - sourceColor);
    float3 finalColor = sqrt(sourceLinear);
    SV_Target = float4(finalColor, 1.0);
}