Shader "examples/week 7/hw 7"
{
    Properties 
    {
        _surfaceColor ("surface color", Color) = (0.4, 0.1, 0.9)
        _gloss ("gloss", Range(0,1)) = 1
        _diffuseLightSteps ("diffuse lgiht steps", Int) = 4
        _specularLightSteps ("specular light steps", Int) = 2
        _ambientColor ("ambient color", Color) = (0.1, 0.1, 0.1)
        
        _gridScale ("Grid Scale", Float) = 20.0
        _borderSize ("Border Size", Range(0, 0.5)) = 0.1
    }
    SubShader
    {
        // this tag is required to use _LightColor0
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // might be UnityLightingCommon.cginc for later versions of unity
            #include "Lighting.cginc"

            #define MAX_SPECULAR_POWER 256
            
            float3 _surfaceColor;
            float _gloss;

            int _diffuseLightSteps;
            int _specularLightSteps;
            float3 _ambientColor;

            float _gridScale;
            float _borderSize;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 posWorld : TEXCOORD1;
                float4 screenPos : TEXCOORD2;
                float2 uv : TEXCOORD3;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                
                float3 color = 0;

                float3 normal = normalize(i.normal);
                
                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0; // includes intensity

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                float3 halfDirection = normalize(viewDirection + lightDirection);

                float diffuseFalloff = max(0, dot(normal, lightDirection));
                
                float specularFalloff = max(0, dot(normal, halfDirection));
                specularFalloff = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.0001) * _gloss;

                //diffuseFalloff = floor(diffuseFalloff * _diffuseLightSteps) / _diffuseLightSteps;
                //specularFalloff = floor(specularFalloff * _specularLightSteps) / _specularLightSteps;

                float3 diffuse = diffuseFalloff * _surfaceColor * lightColor;
                float3 specular = specularFalloff * lightColor;

                color = diffuse + specular + _ambientColor;

                
                // Screen Space Griding the Color
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                screenUV = frac(screenUV * _gridScale);
                if(screenUV.x > _borderSize &&
                    screenUV.x < 1.0 - _borderSize &&
                    screenUV.y > _borderSize &&
                    screenUV.y < 1.0 - _borderSize)
                {
                    //color *= 0.5;
                }

                float2 uv = i.uv;
                uv = frac(uv * _gridScale);
                _borderSize *= 5 * clamp(dot(normal, float3(0, 1, 0)), 0.2, 1.0);
                _borderSize *= clamp(dot(lightDirection, float3(0, 1, 0)), 0.3, 1);

                if(uv.x > _borderSize &&
                    uv.x < 1.0 - _borderSize &&
                    uv.y > _borderSize &&
                    uv.y < 1.0 - _borderSize)
                {
                    //color *= dot(normal, float3(1, 0, 0));
                    color *= min(1,dot(lightDirection, float3(1, 0, 0)) + 0.4);
                    //color += 0.2 * float3(0.07,0.08,0.05) * dot(normal, float3(1, 0, 0));
                    //color -= min(1,dot(lightDirection, float3(1, 0, 0)) + 0.1) * float3(0.07,0.08,0.05);
                    //color *=
                }

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}