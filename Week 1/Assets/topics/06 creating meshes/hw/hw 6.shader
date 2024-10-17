Shader "examples/week 6/hw 6"
{
    Properties
    {
        _color ("color", Color) = (0, 0, 0.8, 1)
        _GradientScale ("Gradient Scale", Float) = 1.0
        _DarkeningFactor ("Darkening Factor", Float) = 1.0
        _Radius ("Cylinder Radius", Float) = 0.5
        _Speed ("Rolling Speed", Float) = 1.0
        _Amplitude ("Oscillation Amplitude", Float) = 1.0
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float3 _color;
            float _GradientScale;
            float _DarkeningFactor;
            float _Radius;
            float _Speed;
            float _Amplitude;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 pos : SV_POSITION;
                float3 worldPos  : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;

                float angle = sin(_Time.y) * _Speed;

                float cosTheta = cos(angle);
                float sinTheta = sin(angle);

                float3x3 rotationMatrix = float3x3(
                    1,       0,        0,
                    0,  cosTheta, -sinTheta,
                    0,  sinTheta,  cosTheta
                );

                float3 rotatedVertex = mul(rotationMatrix, v.vertex.xyz);

                float displacement = sin(angle) * _Amplitude;

                rotatedVertex.y -= displacement;

                o.pos = UnityObjectToClipPos(float4(rotatedVertex, 1.0));

                float3 rotatedNormal = mul(rotationMatrix, v.normal);

                o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, rotatedNormal));

                o.worldPos = mul(unity_ObjectToWorld, float4(rotatedVertex, 1.0)).xyz;

                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float curvature = saturate(dot(normalize(i.worldNormal), float3(0, 0, 1)));
                float darkening = 1.0 - curvature * _DarkeningFactor;

                float3 color = _color * darkening;

                return float4(color, 1);
            }
            ENDCG
        }
    }
}