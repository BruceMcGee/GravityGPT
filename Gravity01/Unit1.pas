unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects;

type
  TForm1 = class(TForm)
    Circle1: TCircle;
    Circle2: TCircle;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FAngle: Single;
    FRadius: Single;
    FCenter: TPointF;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}


procedure TForm1.FormCreate(Sender: TObject);
begin
  // Initialize the angle and radius
  FAngle := 0;
  FRadius := 100;

  // Set the center point of the orbit
  FCenter := PointF(ClientWidth / 2, ClientHeight / 2);

  // Set the timer interval and start the timer
  Timer1.Interval := 16; // Approximately 60 FPS
  Timer1.Enabled := True;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  Circle1Pos, Circle2Pos: TPointF;
begin
  // Update the angle
  FAngle := FAngle + 0.05;
  if FAngle > 2 * Pi then
    FAngle := FAngle - 2 * Pi;

  // Calculate the new positions for the circles
  Circle1Pos := PointF(
    FCenter.X + FRadius * Cos(FAngle),
    FCenter.Y + FRadius * Sin(FAngle)
    );

  Circle2Pos := PointF(
    FCenter.X - FRadius * Cos(FAngle),
    FCenter.Y - FRadius * Sin(FAngle)
    );

  // Set the new positions
  Circle1.Position.X := Circle1Pos.X - Circle1.Width / 2;
  Circle1.Position.Y := Circle1Pos.Y - Circle1.Height / 2;

  Circle2.Position.X := Circle2Pos.X - Circle2.Width / 2;
  Circle2.Position.Y := Circle2Pos.Y - Circle2.Height / 2;
end;

end.
