Shader "examples/week 2/polar"
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

            float zigzag(float desity, float height, float offset, float2 uv)
            {
                float shape = 0;
                shape = frac(uv.x * desity);
                shape = min(shape, 1-shape);
                
                return smoothstep(0,0.002,shape * height + offset - uv.y);
            }

            float4 frag (Interpolators i) : SV_Target
            {
                //CLASS
                
                /*
                float time = _Time.x;
                
                float2 uv = i.uv;
                uv = uv * 2 -1;
                
                float2 polarUV = float2(atan2(uv.y, uv.x),length(uv)); //atan gives a -pi to pi
                polarUV.x = polarUV.x / 6.28 + 0.5; //range would now be 0 to 1
                polarUV.x = frac(polarUV.x + sin(time*10));

                float output = polarUV.x;
                //return float4(0.5,0.2,0.3,1);
                return lerp(float4(0.5,0.2,0.3,1), float4(0.1,0.9,0.3,1),output);
                return float4(output.r, output.r, output.r, 1.0);

                float zzDensity = 10; //(sin(_Time.x * 5) + 1)/2 * 10;
                float zzHeight =  (sin(time * 10) + 1)/2 * .8;
                float zzOffset = ((sin(time * 5)+1)/2 + 0.5) * .4;
                
                //float output = polarUV.x;
                //output = zigzag(zzDensity,zzHeight, zzOffset, polarUV);
                return float4(output.r, output.r, output.r, 1.0);
                */

                //ASSIGNMENT

                float4 color1 = float4(0.5,0.2,0.3,1);
                float4 color2 = float4(0.1,0.9,0.3,1);
                float4 colorCircle = float4(0.7,0.5,0.8,1);
                float time = _Time.x;
                
                float2 uv = i.uv;
                uv = uv * 2 - 1;

                //Make 2 UV, one for grid and one for Polar
                float2 gridUV = frac(uv * 5) * 2 -1;
                
                float index = min(floor(uv.x) , floor(uv.y));
                gridUV.x += sin(time * 20 + index/3) * 0.5;
                gridUV.y += cos(time * 20 + index/3) * 0.5;

                //Two UVs have different moving strategy by themselves
                uv.x += sin(time * 10) * .5;
                
                float2 polarUV = float2(atan2(uv.y, uv.x),length(uv)); //atan gives a -pi to pi
                polarUV.x = polarUV.x / 6.28 + 0.5; //range would now be 0 to 1
                polarUV.x = frac(polarUV.x + sin(time*10));

                // circle size changes with 1. how close it is to the line 2. some time variation
                //float circleSize =  (sin(time * 10)+2)/2 * min(polarUV.x, 1-polarUV.x) * 0.8;
                float circleSize =
                    0.2
                + 0.3
                * smoothstep(0,0.7,sin(gridUV.x+time * 20));
                //* min(polarUV.x, 1-polarUV.x);
                float circle = 1-step(circleSize,length(gridUV));

                // circle color changes with distance to the line
                return lerp(color1, color2, polarUV.x) + lerp(0,colorCircle * circle,min(polarUV.x, 1-polarUV.x) * 2);
                
            }
            ENDCG
        }
    }
}
