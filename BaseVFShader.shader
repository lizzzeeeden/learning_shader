Shader "Learning/BaseVFShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)

        //基础光照
        _Ambient("Ambient Amount",Range(0,1))=0.8
        _SpecularColor("Specular Color",Color)=(1,1,1,1)
        _Gloss("Gloss(Specular) Amount",Range(0,80))=15

        //...
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        Tags{"RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent"}  //透明设置

        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha                     //透明设置

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                float3 normal:NORMAL;

                //...
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

                float3 normal:NORMAL;
                float3 lightDir:TEXCOORD2;
                float3 viewDir:TEXCOORD3;

                //...
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            //基础光照
            float _Ambient;
            fixed4 _SpecularColor;
            float _Gloss;

            //...

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv=float2(TRANSFORM_TEX(v.uv,_MainTex));

                //基础光照参数（模型空间）
                o.lightDir=normalize(ObjSpaceLightDir(v.vertex));
                o.viewDir=normalize(ObjSpaceViewDir(v.vertex));
                o.normal=normalize(v.normal);
                //...

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                //...
                
                //预制光照
                fixed3 diffuse =_LightColor0*(dot(i.normal,i.lightDir)*0.5+0.5);                           //漫反射
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb*_Ambient;                                    //环境光
                fixed3 halfDir = normalize(i.lightDir+i.viewDir);
                fixed3 specular = _LightColor0*_SpecularColor*pow(saturate(dot(i.normal,halfDir)),_Gloss); //高光

                col*=fixed4(diffuse+ambient+specular,1)*_Color;
                return col;
            }
            ENDCG
        }
    }
}
