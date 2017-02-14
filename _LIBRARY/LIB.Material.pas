unit LIB.Material;

interface //#################################################################### ■

uses System.Classes, System.UITypes,
     FMX.Types3D,
     LUX, LUX.FMX.Material, LUX.FMX.Types3D;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMyMaterial

     TMyMaterial = class( TLuxMaterial )
     private
     protected
       _MatrixLS  :TShaderVarMatrix3D;
       _MatrixLG  :TShaderVarMatrix3D;
       _MatrixGL  :TShaderVarMatrix3D;
       _Light     :TShaderVarLight;
       _EyePos    :TShaderVarVector3D;
       _Opacity   :TShaderVarSingle;
       _Texture3D :TShaderVarTexture3D<TTexture3DBGRA>;
       ///// メソッド
       procedure DoApply( const Context_:TContext3D ); override;
     public
       constructor Create; override;
       destructor Destroy; override;
       ///// プロパティ
       property Texture3D :TShaderVarTexture3D<TTexture3DBGRA> read _Texture3D;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMyMaterialSource

     TMyMaterialSource = class( TLuxMaterialSource<TMyMaterial> )
     private
     protected
       ///// アクセス
       function GetTexture3D :TTexture3DBGRA;
     public
       ///// プロパティ
       property Texture3D :TTexture3DBGRA read GetTexture3D;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMyMaterial

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// メソッド

procedure TMyMaterial.DoApply( const Context_:TContext3D );
begin
     inherited;

     with Context_ do
     begin
          SetShaders( _ShaderV.Shader, _ShaderP.Shader );

          _MatrixLS.Value := CurrentModelViewProjectionMatrix;
          _MatrixLG.Value := CurrentMatrix;
          _MatrixGL.Value := CurrentMatrix.Inverse.Transpose;
          _Light   .Value := Lights[ 0 ];
          _EyePos  .Value := CurrentCameraInvMatrix.M[ 3 ];
          _Opacity .Value := CurrentOpacity;
     end;

     _ShaderV.SendVars( Context_ );
     _ShaderP.SendVars( Context_ );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TMyMaterial.Create;
begin
     inherited;

     _MatrixLS  := TShaderVarMatrix3D                 .Create( '_MatrixLS'  );
     _MatrixLG  := TShaderVarMatrix3D                 .Create( '_MatrixLG'  );
     _MatrixGL  := TShaderVarMatrix3D                 .Create( '_MatrixGL'  );
     _Light     := TShaderVarLight                    .Create( '_Light'     );
     _EyePos    := TShaderVarVector3D                 .Create( '_EyePos'    );
     _Opacity   := TShaderVarSingle                   .Create( '_Opacity'   );
     _Texture3D := TShaderVarTexture3D<TTexture3DBGRA>.Create( '_Texture3D' );

     _ShaderV.Vars := [ _MatrixLS ,
                        _MatrixLG ,
                        _MatrixGL  ];

     _ShaderP.Vars := [ _MatrixLS ,
                        _MatrixLG ,
                        _MatrixGL ,
                        _Light    ,
                        _EyePos   ,
                        _Opacity  ,
                        _Texture3D ];
end;

destructor TMyMaterial.Destroy;
begin
     _MatrixLS .Free;
     _MatrixLG .Free;
     _MatrixGL .Free;
     _Light    .Free;
     _EyePos   .Free;
     _Opacity  .Free;
     _Texture3D.Free;

     inherited;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMyMaterialSource

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TMyMaterialSource.GetTexture3D :TTexture3DBGRA;
begin
     Result := _Material.Texture3D.Value;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //######################################################## 初期化

finalization //########################################################## 最終化

end. //######################################################################### ■
