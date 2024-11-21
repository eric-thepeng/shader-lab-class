Shader "examples/week 11/hw 11 intersection"
{
    Properties {
        _size ("intersection size", Range(0.1, 1)) = 0.2
        _stencilRef ("stencil reference", Int) = 1
    }

    SubShader
    {
        Tags{"Queue"="Geometry-1"}
        Cull Off
        ZWrite Off
        // ColorMask 0
        // blend source + destination
        Blend One One
        
        Stencil {
            Ref [_stencilRef]
            Comp Always
            
            Pass Replace
        }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // declare depth texture
            sampler2D _CameraDepthTexture;
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

                o.surfZ = (-UnityObjectToViewPos(v.vertex)).z;
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                return float4(0,0,1,1);
                float3 color = 0;

                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                float depth = Linear01Depth(tex2D(_CameraDepthTexture, screenUV));

                depth /= _ProjectionParams.w; // 1 / far plane
                
                float difference = abs(depth - i.surfZ);
                // color = 1-step(_size, difference);
                color = smoothstep(_size, 0, difference);

                float edgeHighlight = smoothstep(_size * 0.5, _size * 0.1, difference);
                color += edgeHighlight * float3(1, 0, 0); // 红色边缘高亮
                
                return float4(color, 1);
            }
            ENDCG
        }
    }
}
