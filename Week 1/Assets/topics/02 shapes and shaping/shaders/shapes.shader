Shader "examples/week 2/shapes"
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
                float2 uv = i.uv * 2 - 1;
                float shape = 0;

                //cirlce
                //shape = 1-step(0.5, length(uv));
                
                //square
                //float2 size = (0.2 * (sin(_Time.y) * 2 + 1),0.2);

                float2 size = (0.2,0.2);
                float left = step(-size.x, uv.x);
                float right = 1-step(size.x, uv.x);
                float top = step(-size.y, uv.y);
                float bot = 1-step(size.y, uv.y);

                shape = left * right * top * bot;
                
                return float4(shape.rrr, 1.0);
            }
            ENDCG
        }
    }
}
