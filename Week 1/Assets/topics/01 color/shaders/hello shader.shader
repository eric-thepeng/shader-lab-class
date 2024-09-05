Shader "examples/week 1/hello shader"
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
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // 1 is bright&white, 0 is dark&black
                float4 stupidColor = float4(0.2, 0.5, 0.2, .5);
                float4 smartColor = 0.1f;
                //stupidColor = stupidColor * 2;
                //stupidColor = stupidColor + 0.3;
                //return stupidColor.xyzw;
                return stupidColor;
            }
            ENDCG
        }
    }
}
