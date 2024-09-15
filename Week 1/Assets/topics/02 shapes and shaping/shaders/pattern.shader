Shader "examples/week 2/pattern"
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
                float output = 0;
                int gridSize = 20;
                float2 uv = i.uv * gridSize;
                float2 gridUV = frac(uv) * 2 -1; // griduv is for a single cell. *2-1 make cell uv center


                //float index = floor(uv.x/gridSize); //+ floor(uv.y/gridSize);
                float time = _Time.z;

                
                float index2 = min(floor(uv.x) , floor(uv.y));
                float index = pow(floor(uv.x) , (sin(time + index2/3)+1)/2);

                gridUV.x += sin(time + index/3) * 0.5;
                gridUV.y += cos(time + index/3) * 0.5;

                output = 1 - step(0.5  * ((sin(time + index/2)+1)/2) ,length(gridUV));

                float3 coloredOutput = lerp(float3(0.5,0.2,0.9), float3(0.8,0.4,0.5), output * cos(time + index2)) ;
                
                //return float4(gridUV.x, 0, gridUV.y, 1);
                return float4(coloredOutput, 1.0);
            }
            ENDCG
        }
    }
}
