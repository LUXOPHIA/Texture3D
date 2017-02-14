unit Main;

interface //####################################################################

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Math.Vectors,
  FMX.Types3D, FMX.Objects3D, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.Controls3D, FMX.Viewport3D, FMX.TabControl,
  LUX, LUX.FMX, LUX.FMX.Context.DX11,
  LIB.Material;

type
  TForm1 = class(TForm)
    TabControl1: TTabControl;
      TabItemV: TTabItem;
        Viewport3D1: TViewport3D;
          Dummy1: TDummy;
            Dummy2: TDummy;
              Camera1: TCamera;
          Light1: TLight;
          Grid3D1: TGrid3D;
          StrokeCube1: TStrokeCube;
          Dummy3: TDummy;
            RoundCube1: TRoundCube;
        Timer1: TTimer;
      TabItemS: TTabItem;
        TabControlS: TTabControl;
          TabItemSV: TTabItem;
            TabControlSV: TTabControl;
              TabItemSVC: TTabItem;
                MemoSVC: TMemo;
              TabItemSVE: TTabItem;
                MemoSVE: TMemo;
          TabItemSP: TTabItem;
            TabControlSP: TTabControl;
              TabItemSPC: TTabItem;
                MemoSPC: TMemo;
              TabItemSPE: TTabItem;
                MemoSPE: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Timer1Timer(Sender: TObject);
  private
    { private 宣言 }
    _MouseS :TShiftState;
    _MouseP :TPointF;
  public
    { public 宣言 }
    _MyMaterial :TMyMaterialSource;
    ///// メソッド
    procedure MakeTexture3D;
  end;

var
  Form1: TForm1;

implementation //###############################################################

{$R *.fmx}

uses System.Math,
     LUX.D3, LUX.FMX.Types3D;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

procedure TForm1.MakeTexture3D;
var
   X, Y, Z :Integer;
   P :TSingle3D;
   C :TAlphaColorF;
begin
     with _MyMaterial.Texture3D do
     begin
          Width  := 128;
          Height := 128;
          Depth  := 128;

          for Z := 0 to Depth-1 do
          begin
               P.Z := ( ( Z + 0.5 ) / Depth - 0.5 ) * 10;

               for Y := 0 to Height-1 do
               begin
                    P.Y := ( ( Y + 0.5 ) / Height - 0.5 ) * 10;

                    for X := 0 to Width-1 do
                    begin
                         P.X := ( ( X + 0.5 ) / Width - 0.5 ) * 10;

                         C.R := ( 1 + Cos( 3 * Pi2 * Roo2( Pow2( P.Y ) + Pow2( P.Z ) ) ) ) / 2;
                         C.G := ( 1 + Cos( 1 * Pi2 * Roo2( Pow2( P.X ) + Pow2( P.Y ) ) ) ) / 2;
                         C.B := ( 1 + Cos( 2 * Pi2 * Roo2( Pow2( P.Z ) + Pow2( P.X ) ) ) ) / 2;

                         Pixels[ X, Y, Z ] := C.ToAlphaColor;
                    end;
               end;
          end;

          UpdateTexture;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
var
   T :String;
begin
     Assert( Viewport3D1.Context.ClassName = 'TLuxDX11Context', 'TLuxDX11Context クラスが適用されていません。' );

     //////////

     _MyMaterial := TMyMaterialSource.Create( Self );

     with RoundCube1 do
     begin
          LocalMatrix    := TMatrix3D.CreateRotationZ( DegToRad( 45 ) )
                          * TMatrix3D.CreateRotationX( ArcTan( Roo2( 1/2 ) ) );

          MaterialSource := _MyMaterial;
     end;

     MemoSVC.Lines.LoadFromFile( '..\..\_LIBRARY\ShaderV.hlsl' );
     MemoSPC.Lines.LoadFromFile( '..\..\_LIBRARY\ShaderP.hlsl' );

     with _MyMaterial do
     begin
          with ShaderV do
          begin
               Source.Text := MemoSVC.Text;

               for T in Errors.Keys do
               begin
                    with MemoSVE.Lines do
                    begin
                         Add( '▼ ' + T   );
                         Add( Errors[ T ] );
                    end;
               end;
          end;

          with ShaderP do
          begin
               Source.Text := MemoSPC.Text;

               for T in Errors.Keys do
               begin
                    with MemoSPE.Lines do
                    begin
                         Add( '▼ ' + T   );
                         Add( Errors[ T ] );
                    end;
               end;
          end;
     end;

     MakeTexture3D;
end;

//------------------------------------------------------------------------------

procedure TForm1.Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     _MouseS := Shift;
     _MouseP := TPointF.Create( X, Y );
end;

procedure TForm1.Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
   P :TPointF;
begin
     if ssLeft in _MouseS then
     begin
          P := TPointF.Create( X, Y );

          with Dummy1.RotationAngle do Y := Y + ( P.X - _MouseP.X ) / 2;
          with Dummy2.RotationAngle do X := X - ( P.Y - _MouseP.Y ) / 2;

          _MouseP := P;
     end;
end;

procedure TForm1.Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     Viewport3D1MouseMove( Sender, Shift, X, Y );

     _MouseS := [];
end;

//------------------------------------------------------------------------------

procedure TForm1.Timer1Timer(Sender: TObject);
begin
     with Dummy3.RotationAngle do Y := Y - 1;
end;

end. //#########################################################################
