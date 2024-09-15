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
                float time = _Time.x;
                
                float2 uv = i.uv;
                uv = uv * 2 -1;
                
                float2 polarUV = float2(atan2(uv.y, uv.x),length(uv)); //atan gives a -pi to pi
                polarUV.x = polarUV.x / 6.28 + 0.5; //range would now be 0 to 1

                polarUV.x = frac(polarUV.x + time);
                
                
                float output = polarUV.x;
                output = polarUV.x;
                output = zigzag(40, 0.1, 0.4, polarUV);
                return float4(output.rrr, 1.0);
            }
            ENDCG
        }
    }
}
