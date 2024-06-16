unit ufrmMain;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  System.Math, System.Math.Vectors,
  System.Generics.Collections, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts;

type
  TParticle = record
    Position: TPointF;
    Velocity: TPointF;
    Mass: Single;
  end;

  TfrmMain = class(TForm)
    Timer1: TTimer;
    PaintBox1: TPaintBox;
    LayoutControls: TLayout;
    tbG: TTrackBar;
    Label1: TLabel;
    lblGValue: TLabel;
    LayoutDisplay: TLayout;
    btnRestart: TButton;
    btnRestoreDefaults: TButton;
    Layout1: TLayout;
    Layout2: TLayout;
    Label2: TLabel;
    lblDensityValue: TLabel;
    tbGridDensity: TTrackBar;
    Layout3: TLayout;
    Label3: TLabel;
    lblMaxVectorLineLength: TLabel;
    tbMaxVectorLineLength: TTrackBar;
    Layout4: TLayout;
    Label4: TLabel;
    lblMass1Value: TLabel;
    tbMass1: TTrackBar;
    Layout5: TLayout;
    Label5: TLabel;
    lblMass2Value: TLabel;
    tbMass2: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
    procedure tbChange(Sender: TObject);
    procedure btnRestartClick(Sender: TObject);
    procedure btnRestoreDefaultsClick(Sender: TObject);
  private
    Particles: TArray<TParticle>;
    function GetG: Single;
    function GetGridDensity: Integer;
    function GetMaxVectorLength: Integer;
    procedure DrawForceVectors(ACanvas: TCanvas);
    procedure ResetSimulation;
    procedure SetDefaults;
    procedure UpdateParticles;
    procedure UpdateValues;
  public
  end;

var
  frmMain: TfrmMain;

implementation


{$R *.fmx}


// TfrmMain
// ============================================================================
procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Timer1.Enabled := False;
  Timer1.Interval := 16; // Approximately 60 FPS

  SetLength(Particles, 2);

  SetDefaults;
  ResetSimulation;
end;

// ----------------------------------------------------------------------------
function TfrmMain.GetG: Single;
begin
  Result := tbG.Value;
end;

// ----------------------------------------------------------------------------
function TfrmMain.GetGridDensity: Integer;
begin
  Result := Round(tbGridDensity.Value);
end;

// ----------------------------------------------------------------------------
function TfrmMain.GetMaxVectorLength: Integer;
begin
  Result := Round(tbMaxVectorLineLength.Value);
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnRestartClick(Sender: TObject);
begin
  ResetSimulation;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnRestoreDefaultsClick(Sender: TObject);
begin
  SetDefaults;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.tbChange(Sender: TObject);
begin
  UpdateValues;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  UpdateParticles;
  PaintBox1.Repaint;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
var
  LParticle: TParticle;
begin
  Canvas.BeginScene;
  try
    Canvas.ClearRect(PaintBox1.BoundsRect, TAlphaColors.Black);
    DrawForceVectors(Canvas);

    Canvas.Fill.Color := TAlphaColors.White;
    for LParticle in Particles do
    begin
      Canvas.FillEllipse(RectF(LParticle.Position.X - 5, LParticle.Position.Y - 5,
        LParticle.Position.X + 5, LParticle.Position.Y + 5), 1);
    end;
  finally
    Canvas.EndScene;
  end;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.DrawForceVectors(ACanvas: TCanvas);
var
  i, j: Integer;
  LParticle: TParticle;
  LGridPoint, LForceVector: TPointF;
  LSpacingX, LSpacingY: Single;
  LForce, LDistance: TPointF;
  LDistanceSqr, LForceMag, LForceVectorLength, LInverseScaleFactor: Single;
begin
  LSpacingX := PaintBox1.Width / (tbGridDensity.Value + 1);
  LSpacingY := PaintBox1.Height / (tbGridDensity.Value + 1);

  ACanvas.Stroke.Kind := TBrushKind.Solid;
  ACanvas.Stroke.Color := TAlphaColors.Red;
  ACanvas.Stroke.Thickness := 1;

  for i := 1 to GetGridDensity do
  begin
    for j := 1 to GetGridDensity do
    begin
      LGridPoint := TPointF.Create(i * LSpacingX, j * LSpacingY);
      LForceVector := TPointF.Create(0, 0);

      // Calculate total force from all particles
      for LParticle in Particles do
      begin
        LDistance := LParticle.Position - LGridPoint;
        LDistanceSqr := Sqr(LDistance.X) + Sqr(LDistance.Y);

        if LDistanceSqr = 0 then
          Continue; // Avoid division by zero

        LForceMag := (tbG.Value * LParticle.Mass) / LDistanceSqr;
        LForce := LDistance * (LForceMag / Sqrt(LDistanceSqr));
        LForceVector := LForceVector + LForce;
      end;

      LForceVectorLength := Sqrt(Sqr(LForceVector.X) + Sqr(LForceVector.Y));

      // Scale the force vector
      if LForceVectorLength > 0 then
      begin
        LInverseScaleFactor := Min(GetMaxVectorLength / (1 + LForceVectorLength), GetMaxVectorLength);
        LForceVector := LForceVector * LInverseScaleFactor;
      end;
      ACanvas.DrawLine(LGridPoint, LGridPoint + LForceVector, 1);
    end;
  end;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.ResetSimulation;
begin
  Timer1.Enabled := False;
  try
    Particles[0].Position := PointF(PaintBox1.Width / 2 - 100, PaintBox1.Height / 2);
    Particles[0].Velocity := PointF(0, 0.6);

    Particles[1].Position := PointF(PaintBox1.Width / 2 + 100, PaintBox1.Height / 2);
    Particles[1].Velocity := PointF(0, -0.6);
  finally
    Timer1.Enabled := True;
  end;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.SetDefaults;
begin
  tbG.Value := 8.0; // Gravitational constant for simulation
  tbGridDensity.Value := 50.0;
  tbMaxVectorLineLength.Value := 30; // Maximum length for force vectors

  Particles[0].Mass := 50;
  tbMass1.Value := Particles[0].Mass;
  Particles[1].Mass := 50;
  tbMass2.Value := Particles[1].Mass;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.UpdateParticles;
var
  i, j: Integer;
  LDistance, LForce, LAccel: TPointF;
  LDistanceSqr, LForceMag: Single;
begin
  for i := 0 to High(Particles) do
  begin
    for j := 0 to High(Particles) do
    begin
      if i <> j then
      begin
        LDistance := Particles[j].Position - Particles[i].Position;
        LDistanceSqr := Sqr(LDistance.X) + Sqr(LDistance.Y);

        if LDistanceSqr = 0 then
          Continue; // Avoid division by zero

        LForceMag := (tbG.Value * Particles[i].Mass * Particles[j].Mass) / LDistanceSqr;
        LForce := LDistance * (LForceMag / Sqrt(LDistanceSqr));
        LAccel := LForce * (1 / Particles[i].Mass);
        Particles[i].Velocity := Particles[i].Velocity + LAccel;
      end;
    end;
  end;

  for i := 0 to High(Particles) do
    Particles[i].Position := Particles[i].Position + Particles[i].Velocity;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.UpdateValues;
begin
  Timer1.Enabled := False;
  try
    lblGValue.Text := GetG.ToString;
    lblDensityValue.Text := GetGridDensity.ToString;
    lblMaxVectorLineLength.Text := GetMaxVectorLength.ToString;
    Particles[0].Mass := tbMass1.Value;
    lblMass1Value.Text := Particles[0].Mass.ToString;
    Particles[1].Mass := tbMass2.Value;
    lblMass2Value.Text := Particles[1].Mass.ToString;
  finally
    Timer1.Enabled := True;
  end;
end;

end.
