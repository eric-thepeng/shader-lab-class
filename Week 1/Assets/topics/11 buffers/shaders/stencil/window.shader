Shader "examples/week 11/window"
{
    Properties {
        _stencilRef ("Stencil Reference", Int) = 0
    }

    SubShader
    {
        Tags{"Queue" = "Geometry-1"} // render before other geometry
        ZWrite Off // disable writing to depth buffer
        ColorMask 0 // disable writing to color buffer
        
        Stencil{
            Ref [_stencilRef] // reference value for stencil buffer
            Comp Always // always pass stencil test
            Pass Replace // replace stencil value with reference value
            }

        // nothing new below
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
                return 0;
            }
            ENDCG
        }
    }
}
