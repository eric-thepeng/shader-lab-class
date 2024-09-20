﻿Shader "examples/week 3/compound transformations"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

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

            float rectangle (float2 uv, float2 scale) {
                float2 s = scale * 0.5;
                float2 shaper = float2(step(-s.x, uv.x), step(-s.y, uv.y));
                shaper *= float2(1-step(s.x, uv.x), 1-step(s.y, uv.y));
                return shaper.x * shaper.y;
            }
            
            #define TAU 6.28318531

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1;
                float3 color = 0;

                float time = _Time.x * 15;
                float2 cUV = uv;

                float3x3 translate2D = float3x3(
                    1,0,sin(time) * 0.5,
                    0,1,cos(time) * 0.5,
                    0,0,1
                );

                float scale = sin(time * 2) + 2;
                float3x3 scale2D = float3x3(
                    scale,0,0,
                    0,scale,0,
                    0,0,1
                );

                float angle = frac(time * 0.5) * TAU;
                float3x3 rotate2D = float3x3(
                    cos(angle),-sin(angle),0,
                    sin(angle),cos(angle),0,
                    0,0,1
                );

                float3x3 composite2D= mul( mul(rotate2D, scale2D), translate2D );

                float3 uv3 = mul(composite2D, float3(uv.xy, 1));

                uv = uv3.xy;
                color = rectangle(uv, float2(0.25,0.5));
                color += float3(uv.x, 0, uv.y);
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
