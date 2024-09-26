﻿Shader "examples/week 4/value noise 1D"
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
        }
    }
}
