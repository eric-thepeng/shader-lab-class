Shader "examples/week 5/arbitrary data"
{
    Properties
    {
        _color ("color", Color) = (0, 0, 0.8, 1)
        _scale ("noise scale", Range(2, 100)) = 15.5
        _displacement ("displacement", Range(0, 0.3)) = 0.12
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float3 _color;
            float _scale;
            float _displacement;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 color : COLOR;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 worldUV : TEXCOORD0;
                float height : TEXCOORD1;
            };

            // ripple is only the outer edge of the circle, and within a fixed range of that edge.
            // strength decrease with time increase
            // radius increase with time increase
            // height of ripple decrease as strength decrease
            float Ripple (float2 uv, float2 center, float radius, float width) {
                float d = distance(uv, center);
                if(abs(radius-d) > width/2) return 0;
                if(abs(radius-d) < width/2) return 1;
                return smoothstep((width/2), 0, abs(radius - d));
            }

            float rand(float v) {
                return frac(sin(v) * 43758.5453123);
            }
            
            Interpolators vert (MeshData v)
            {
                Interpolators o;

                o.worldUV = mul(unity_ObjectToWorld,v.vertex).xz * 0.02;

                float time = _Time.y;

                float spawnInterval = 1; 
                float maxFadeDuration = 4.0;
                float minFadeDuration = 2.5;

                float width = 0.008;

                int maxRipples = 10;
                int totalCircles = min(int(floor(time / spawnInterval)), maxRipples);
                int numActiveCircles = min(totalCircles, int(ceil(maxFadeDuration / spawnInterval)));
                
                for (int n = 0; n < numActiveCircles; n++) {
                    float t0 = (totalCircles - n) * spawnInterval; // Spawn time of this circle

                    float seed = t0; // Use spawn time as seed for rand
                    float2 position = float2(rand(seed + 1.0), rand(seed + 2.0)); // Random position, 0-1 range
                    position = position * 2.0 - 1.0; // Map to range [-1, 1]
                    position *= 0.1;
                    
                    float startRadius = rand(seed + 5.0) * 0.02 + 0.02; // Drop start radius 0.02 - 0.04
                    float finalRadius = rand(seed + 4.0) * 0.1 + 0.15; // Drop final radius 0.15 - 0.25
                    
                    float fadeDuration = rand(seed + 3.0) * (maxFadeDuration-minFadeDuration) + minFadeDuration; // Random fade duration
                    float timeSinceSpawn = time - t0;

                    if (timeSinceSpawn >= 0.0 && timeSinceSpawn <= fadeDuration) {
                            float normalizedTime = timeSinceSpawn / fadeDuration;
                            float riseFraction = 0.2; // Rise height fast in the rising stage
                            
                            float strength;
                            if (normalizedTime < riseFraction) {
                                // rising stage: rise from 0 to 1
                                strength = normalizedTime / riseFraction;
                            } else {
                                // decreasing stage: 1 to 0
                                strength = 1.0 - (normalizedTime - riseFraction) / (1.0 - riseFraction);
                            }

                            strength = saturate(strength);

                            float radius = lerp(startRadius, finalRadius, timeSinceSpawn / fadeDuration);
                            float waveHeight = _displacement * strength * Ripple(o.worldUV, position, radius, width);
                            v.vertex.y += waveHeight * v.color.r;
                        }
                }
                

                //v.vertex.y += wave(o.worldUV) * _displacement * v.color.r;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.height = v.vertex.y;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                
                float3 topFace = (i.height/_displacement * .35 + 0.5) * _color;
                float3 otherFaces = lerp(_color * 0.75, _color * 0.65, i.normal.x);

                color = lerp(otherFaces, topFace, i.normal.y);
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }

    /* 
    ORIGIONAL CLASS CODE
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float3 _color;
            float _scale;
            float _displacement;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 color : COLOR;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 worldUV : TEXCOORD0;
            };

            float wave (float2 uv) {
                // simple sin wave 0-1 with scale adjustment and time animation
                float wave1 = sin(((uv.x + uv.y) * _scale) + _Time.z) * 0.5 + 0.5;

                // using cos and sin with different uv relationships and time and scale modifiers. 0-2 range
                float wave2 = (cos(((uv.x - uv.y) * _scale/2.568) + _Time.z) + 1) * sin(_Time.x * 5.2321 + (uv.x * uv.y)) * 0.5 + 0.5;
                
                // dividing by 3 to make 0-1 range
                return (wave1 + wave2) / 3;
            }
            
            Interpolators vert (MeshData v)
            {
                Interpolators o;

                o.worldUV = mul(unity_ObjectToWorld,v.vertex).xz * 0.02;

                v.vertex.y += wave(o.worldUV) * _displacement * v.color.r;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                float w = wave(i.worldUV);

                float3 topFace = (w.rrr * 0.5 + 0.5) * _color;
                float3 otherFaces = lerp(_color * 0.75, _color * 0.65, i.normal.x);

                color = lerp(otherFaces, topFace, i.normal.y);
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }*/
}
