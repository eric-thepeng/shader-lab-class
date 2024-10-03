Shader "examples/week 4/value noise 1D"
{
    
    Properties 
    {
        _bgCor1 ("bg color 1", Color) = (1,1,1,1)
        _circleCor ("circle color", Color) = (1,1,1,1)
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

            float3 _circleCor;
            float3 _bgCor1;

            float rand(float v) {
                return frac(sin(v) * 43758.5453123);
            }

            float Circle(float2 uv, float2 center, float circleRadius) {
                float dist = distance(uv, center);
                return smoothstep(circleRadius, circleRadius - 0.01, dist);
            }

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {   float2 uv = i.uv;
                float time = _Time.y;

                float3 color = _bgCor1;
                float spawnInterval = 0.15; 
                float maxFadeDuration = 3.0;
                float minFadeDuration = 0.5;

                int numActiveCircles = ceil(maxFadeDuration / spawnInterval); 
                int totalCircles = int(floor(time / spawnInterval));

                for (int n = 0; n < numActiveCircles; n++) {
                    float t0 = (totalCircles - n) * spawnInterval; // Spawn time of this circle

                    float seed = t0; // Use spawn time as seed for rand
                    float2 position = float2(rand(seed + 1.0), rand(seed + 2.0)); // Random position
                    
                    float startRadius = rand(seed + 5.0) * 0.02 + 0.02; // Drop start radius 0.02 - 0.04
                    float finalRadius = rand(seed + 4.0) * 0.1 + 0.15; // Drop final radius 0.15 - 0.25
                    
                    float fadeDuration = rand(seed + 3.0) * (maxFadeDuration-minFadeDuration) + minFadeDuration; // Random fade duration
                    float timeSinceSpawn = time - t0;

                    if (timeSinceSpawn >= 0.0 && timeSinceSpawn <= fadeDuration) {
                        float alpha = 1.0 - (timeSinceSpawn / fadeDuration); // Fade out
                        float circle = Circle(uv, position, lerp(startRadius,finalRadius,timeSinceSpawn/fadeDuration));
                        color += circle * alpha * _circleCor;
                    }
                }

                return float4(color.rgb, 1.0);
            }
            ENDCG
        }
    }
    

/* ORIGIONAL CLASS CODE
    
    SubShader
    {
        
        /*
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float rand (float v) {
                return frac(sin(v) * 43758.5453123);
            }

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                uv *= 30;
                
                float ipos = floor(uv.x);
                float fpos = frac(uv.x);
                
                float vn = 0;
                float thisColumn = rand(ipos);
                float nextColumn = rand(ipos + 1);
                
                vn = lerp(thisColumn,nextColumn,smoothstep(0,1,fpos));
                
                return float4(vn.rrr, 1.0);
            }
            ENDCG
        }*/
    }*/
}
