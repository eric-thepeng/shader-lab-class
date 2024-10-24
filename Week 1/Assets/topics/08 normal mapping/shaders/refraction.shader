﻿Shader "examples/week 8/refraction"
{
    Properties 
    {
        _tint ("tint color", Color) = (1, 1, 1, 1)
        _albedo ("albedo", 2D) = "white" {}
        [NoScaleOffset] _normalMap ("normal map", 2D) = "bump" {}
        [NoScaleOffset] _displacementMap ("displacement map", 2D) = "gray" {}
        _gloss ("gloss", Range(0,1)) = 1
        _normalIntensity ("normal intensity", Range(0, 1)) = 1
        _displacementIntensity ("displacement intensity", Range(0, 0.5)) = 0
        _refractionIntensity ("refraction intensity", Range(0, 0.5)) = 0.05
        _opacity ("opacity", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" "Queue"="Transparent" "IgnoreProjector"="True"}

        GrabPass
        {
            "_BackgroundTex"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // might be UnityLightingCommon.cginc for later versions of unity
            #include "Lighting.cginc"

            #define MAX_SPECULAR_POWER 256

            float3 _tint;
            sampler2D _albedo; float4 _albedo_ST;
            sampler2D _normalMap;
            sampler2D _displacementMap;
            sampler2D _BackgroundTex;
            
            float _gloss;
            float _normalIntensity;
            float _displacementIntensity;
            float _opacity;
            float _refractionIntensity;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 posWorld : TEXCOORD4;

                float4 screenUV : TEXCOORD5;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.uv = TRANSFORM_TEX(v.uv, _albedo);
                
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldNormal(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                
                float height = tex2Dlod(_displacementMap, float4(o.uv, 0, 0)).r * 2 - 1;
                v.vertex.xyz += v.normal * height * _displacementIntensity;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenUV = ComputeGrabScreenPos(o.vertex);

                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                float3 color = 0;

                // Calculate screen-space UV for the refraction effect
                float2 screenUV = i.screenUV.xy / i.screenUV.w;

                // Sample normal map and adjust for intensity
                float3 tangentSpaceNormal = UnpackNormal(tex2D(_normalMap, uv));
                tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _normalIntensity));

                // Adjust refractionUV based on the refraction intensity
                float2 refractionOffset = tangentSpaceNormal.xy * _refractionIntensity;

                // Offset the screen-space UV with the calculated refraction offset
                float2 refractionUV = screenUV + refractionOffset;

                // Sample the background texture at the refracted UV coordinates
                float3 background = tex2D(_BackgroundTex, refractionUV).rgb;

                // Calculate the world-space normal
                float3x3 tangentToWorld = float3x3
                (
                    i.tangent.x, i.bitangent.x, i.normal.x,
                    i.tangent.y, i.bitangent.y, i.normal.y,
                    i.tangent.z, i.bitangent.z, i.normal.z
                );

                float3 normal = mul(tangentToWorld, tangentSpaceNormal);

                // Blinn-Phong lighting calculation
                float3 surfaceColor = tex2D(_albedo, uv).rgb;

                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0; // includes intensity

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                float3 halfDirection = normalize(viewDirection + lightDirection);

                float diffuseFalloff = max(0, dot(normal, lightDirection));
                float specularFalloff = max(0, dot(normal, halfDirection));

                float3 specular = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.0001) * lightColor * _gloss;
                float3 diffuse = diffuseFalloff * surfaceColor * lightColor * _tint;

                // Combine diffuse and specular lighting
                float3 surfaceLighting = diffuse + specular;

                // Blend the surface color with the refracted background based on opacity
                color = lerp(background, surfaceLighting, _opacity);

                // Return the final color with full alpha
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}