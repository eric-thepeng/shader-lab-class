Shader "examples/week 2/shaping"
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
                uv = uv * 2 - 1; // making the range -1 to 1
                uv *= 4;

                float x = uv.x;
                float y = uv.y;

                float c = x;
                c = sin(-x); //sin: -1 to 1
                c = cos(x);
                c = abs(x);
                c = ceil(x);
                c = floor(x);
                c = frac(x);
                c = min(x,y);
                c = max(x,y);
                c = sign(x);
                c = step(x, 2);
                c = smoothstep(0,1,x);

                return float4(c.rrr, 1.0);
            }
            ENDCG
        }
    }
}
