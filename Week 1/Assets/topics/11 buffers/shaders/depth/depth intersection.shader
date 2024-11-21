﻿Shader "examples/week 11/depth intersection"
{
    Properties {
        _size ("intersection size", Range(0,1)) = 0.2
        _step ("step", Range(0,1)) = 0.1
    }

    SubShader
    {
        Tags{"Queue" = "Transparent"}
        Cull Off
        ZWrite Off
        Blend One One
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // declare depth texture
            sampler2D _CameraDepthTexture;
            float _step;
            float _size;


            struct MeshData
            {
                float4 vertex : POSITION;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float surfZ : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);


                o.surfZ = o.screenPos.z / o.screenPos.w;
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;

                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                float depth = Linear01Depth(tex2D(_CameraDepthTexture, screenUV));
                depth /= _ProjectionParams.w;
                
                float depthDiff = abs(depth - i.surfZ);
                color = step(_size,depthDiff);
                
                return float4(color, 1);
            }
            ENDCG
        }
    }
}
