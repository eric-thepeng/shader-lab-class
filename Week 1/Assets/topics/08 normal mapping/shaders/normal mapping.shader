Shader "examples/week 8/normal mapping"
{
    Properties 
    {
        _albedo ("albedo", 2D) = "white" {}
        [NoScaleOffset] _normalMap("normal map", 2D) = "bump" {}
        _gloss ("gloss", Range(0,1)) = 1
        _normalIntensity ("normal intensity", Range(0,1)) = 1
    }
    SubShader
    {
        // this tag is required to use _LightColor0
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // might be UnityLightingCommon.cginc for later versions of unity
            #include "Lighting.cginc"

            #define MAX_SPECULAR_POWER 256

            sampler2D _albedo; float4 _albedo_ST;
            float _gloss;
            sampler2D _normalMap;
            float _normalIntensity;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                
                // using transform tex in vert shader
                o.uv = TRANSFORM_TEX(v.uv, _albedo);
                
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldDir(float3(1,0,0));
                o.bitangent = UnityObjectToWorldDir(float3(0,1,0));
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float3 blinnphong (float2 uv, float3 normal, float3 worldPos) {
                float3 surfaceColor = tex2D(_albedo, uv).rgb;

                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0; // includes intensity

                // blinn-phong
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - worldPos);
                float3 halfDirection = normalize(viewDirection + lightDirection);

                float diffuseFalloff = max(0, dot(normal, lightDirection));
                float specularFalloff = max(0, dot(normal, halfDirection));

                float3 diffuse = diffuseFalloff * surfaceColor * lightColor;

                // the specular power, which controls the sharpness of the direct specular light is dependent on the glossiness (smoothness)
                float3 specular = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.0001) * _gloss * lightColor;

                return diffuse + specular;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                float3 color = 0;


                //float4 normalTex = float4(UnpackNormal(tex2D(_normalMap, uv))*0.5 + 0.5,1);
                // normal map RGB = (Tangent, Bitangent, Normal)
                /*
                 *  1.	x 分量：表示法线向量在切线空间中 沿着切线轴（Tangent） 的方向上的分量。通常映射自法线贴图中的 红色通道 (R)。
	                2.	y 分量：表示法线向量在切线空间中 沿着副切线轴（Binormal/Bitangent） 的方向上的分量。通常映射自法线贴图中的 绿色通道 (G)。
	                3.	z 分量：表示法线向量在切线空间中 沿着法线轴（Normal） 的方向上的分量。这通常是通过 x 和 y 分量计算出来的，并映射自法线贴图中的 蓝色通道 (B)。在标准法线贴图中，z 分量的值通常接近 1，表示法线接近于物体表面的法线方向。

                法线贴图的编码：

	                •	在法线贴图中，x 和 y 分量通常被编码在 [0, 1] 的范围内。因此，它们需要被解码并映射到 [-1, 1] 的范围。UnpackNormal 会将法线贴图中的红色和绿色通道的值从 [0, 1] 重新映射到 [-1, 1] 之间。
	                •	z 分量也通常会被编码在 [0, 1] 范围内，但在 UnpackNormal 处理中，它会被恢复成一个接近 1 的正值。
                 */

                float3 tangentSpaceNormal = normalize(UnpackNormal(tex2D(_normalMap, uv)));

                tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _normalIntensity));


                float3x3 tangentToWorld = float3x3(
                    i.tangent.x, i.bitangent.x, i.normal.x,
                    i.tangent.y, i.bitangent.y, i.normal.y,
                    i.tangent.z, i.bitangent.z, i.normal.z
                    );

                float3 normal = mul(tangentToWorld, tangentSpaceNormal); 
                
                color = blinnphong(uv, normal, i.worldPos);
                return float4(color,1);
            }
            ENDCG
        }
    }
}
