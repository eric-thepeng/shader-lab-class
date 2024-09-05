Shader "examples/week 1/gradient exercise"
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

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                float3 color = 0;

                // add your code here
                float3 colorA = float3(0.1,0.2,0.05);
                float3 colorB = float3(0.8,0.9,0.12);
                float3 colorC = float3(0.4,0.3,0.72);
                float3 colorD = float3(0.5,0.05,0.93);

                color = lerp(colorA,colorB,uv.x) /2 + lerp(colorC,colorD,uv.y) /2;


                                
                color =
                    0.25 * colorA * (abs(uv.x-0) + abs(uv.x-0)) +
                    0.25 * colorB * (abs(uv.x-0) + abs(uv.x-1)) +
                    0.25 * colorC * (abs(uv.x-1) + abs(uv.x-0)) +
                    0.25 * colorD * (abs(uv.x-1) + abs(uv.x-1));

                color =
                   colorA * abs(uv.x-0) * abs(uv.x-0) +
                   colorB * abs(uv.x-0) * abs(uv.x-1) +
                    colorC * abs(uv.x-1) * abs(uv.x-0) +
                        colorD * abs(uv.x-1) * abs(uv.x-1);

                float3 colorAB = lerp(colorA, colorB,uv.x);
                float3 colorCD = lerp(colorC, colorD, uv.y);
                color = (colorAB+colorCD)/2;

      
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
