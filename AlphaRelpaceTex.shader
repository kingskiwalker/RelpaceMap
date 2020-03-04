Shader "Unlit/AlphaRelpaceTex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Mul("multiple",float) =1
        _Frequency("frequency",float) = 0.1
        _Speed("Speed",float) = 1
        [hdr] _Color("Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        AlphaToMask on

        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200

        Pass
        {

            Blend SrcAlpha OneMinusSrcAlpha 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;

                float2 uv : TEXCOORD0;
                float3 normal:NORMAL0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float height:TEXCOORD1; //顶点高度
                float l:TEXCOORD2;      //对应高度值          
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Mul;
            float _Speed;
            float4 _Color;
            float _Frequency;

            v2f vert (appdata v)
            {
                v2f o;

                float2 uv = TRANSFORM_TEX(float4(v.uv.xy,0,0),_MainTex);
                //顶点偏移z
                float height = tex2Dlod(_MainTex,float4(uv.xy,0,0)).r;
                o.l=height;
                v.vertex.xyz += v.normal*_Mul*height;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = lerp(float4(0,0,0,0.5),_Color,i.l);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
