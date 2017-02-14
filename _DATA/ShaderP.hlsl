//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【設定】

SamplerState _SamplerState
{
    Filter   = MIN_MAG_MIP_POINT;
    AddressU = ADDRESS_MIRROR;
    AddressV = ADDRESS_MIRROR;
    AddressW = ADDRESS_MIRROR;
};

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//##############################################################################

struct TSenderP               //フラグメントの変数型
{
    float4 Scr :SV_Position;  //位置（スクリーン）
    float4 Pos :TEXCOORD0  ;  //位置（グローバル）
    float4 Tan :TANGENT    ;  //接線（グローバル）
    float4 Bin :BINORMAL   ;  //従法線（グローバル）
    float4 Nor :NORMAL     ;  //法線（グローバル）
    float4 Tex :TEXCOORD1  ;  //テクスチャ座標
};

struct TResultP               //ピクセルの変数型
{
    float4 Col :SV_Target  ;  //色
};

////////////////////////////////////////////////////////////////////////////////

TResultP MainP( TSenderP _Sender )
{
    TResultP _Result;

    float3 Nor = normalize( _Sender.Nor.xyz );                                  //表面法線（グローバル）
    float3 Tan = normalize( _Sender.Tan.xyz );                                  //表面接線（グローバル）
    float3 Bin = normalize( _Sender.Bin.xyz );                                  //表面従法線（グローバル）
    float3 Lig = -_Light.Dir.xyz;                                               //光線方向（グローバル）
    float3 Vie = normalize( _EyePos.xyz - _Sender.Pos.xyz );                    //視線方向（グローバル）
    float3 Hal = normalize( Lig + Vie );                                        //ハーフベクトル

    float3 T;
    T.x = ( _Sender.Pos.x + 5 ) / 10;
    T.y = ( _Sender.Pos.y + 5 ) / 10;
    T.z = ( _Sender.Pos.z + 5 ) / 10;

    _Result.Col = _Texture3D.Sample( _SamplerState, T );

    //--------------------------------------------------------------------------

    _Result.Col.a = 1;

    _Result.Col = _Opacity * _Result.Col;

    return _Result;
}

//##############################################################################
