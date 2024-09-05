﻿Shader "examples/week 1/gradient"
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

                float3 color = float3(uv.x, 0.0, uv.y);

                color = uv.y;

                float3 colorA = float3(0.3, 0.1, 0.9);
                float3 colorB = float3(0.1,0.4,0.5);

                //3 same ways to gradient blend two colors
                //color = colorA * uv.x + colorB * (1-uv.x);
                //color = colorA + (colorB - colorA) * uv.x;
                color = lerp(colorA,colorB,uv.y);
 
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
