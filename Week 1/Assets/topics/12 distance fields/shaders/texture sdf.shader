﻿Shader "examples/week 12/texture sdf"
{
    Properties {
        [NoScaleOffset]_tex ("texture", 2D) = "white" {}
        _threshold ("threshold", Range(0, 1)) = 0.5
        _softness ("softness", Range(0, 1)) = 0
        _outlineThreshold ("outline threshold", Range(0,1)) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _tex;
            float _threshold;
            float _softness;
            float _outlineThreshold;

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
                float3 color = 0;

                float df = tex2D(_tex, i.uv).r;
                float shape = smoothstep(_threshold,_threshold + _softness,df);
                float outline = smoothstep(_outlineThreshold, _outlineThreshold + _softness, df);
                
                color = step(0.5,outline);
                return float4(color, shape);
            }
            ENDCG
        }
    }
}
