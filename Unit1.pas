unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  System.Sensors, System.Sensors.Components, Math, FMX.Controls.Presentation, FMX.Objects;

type
  TForm1 = class(TForm)
    LocationSensor1: TLocationSensor;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    procedure FormCreate(Sender: TObject);
    procedure LocationSensor1LocationChanged(Sender: TObject; const OldLocation, NewLocation: TLocationCoord2D);
  private
    FLastLocation: TLocationCoord2D;
    FLastTime: TDateTime;
    function HaversineDistance(const Lat1, Lon1, Lat2, Lon2: Double): Double;
    procedure DisplaySpeedAsImages(Speed: Double);
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin
  try
    LocationSensor1.Active := True;
  except
    on E: Exception do
      ShowMessage('Error: ' + E.Message);
  end;
  FLastTime := Now;
end;

function TForm1.HaversineDistance(const Lat1, Lon1, Lat2, Lon2: Double): Double;
const
  EarthRadius = 6371; // Earth's radius in kilometers
var
  dLat, dLon, a, c: Double;
begin
  dLat := DegToRad(Lat2 - Lat1);
  dLon := DegToRad(Lon2 - Lon1);
  a := Sin(dLat / 2) * Sin(dLat / 2) +
       Cos(DegToRad(Lat1)) * Cos(DegToRad(Lat2)) *
       Sin(dLon / 2) * Sin(dLon / 2);
  c := 2 * ArcTan2(Sqrt(a), Sqrt(1 - a));
  Result := EarthRadius * c;
end;

procedure TForm1.DisplaySpeedAsImages(Speed: Double);
var
  SpeedStr: string;
begin
  SpeedStr := Format('%.0f', [Speed]);
  if Length(SpeedStr) > 0 then
    Image1.Bitmap.LoadFromFile(SpeedStr[1] + '.png');
  if Length(SpeedStr) > 1 then
    Image2.Bitmap.LoadFromFile(SpeedStr[2] + '.png');
  if Length(SpeedStr) > 2 then
    Image3.Bitmap.LoadFromFile(SpeedStr[3] + '.png');
end;

procedure TForm1.LocationSensor1LocationChanged(Sender: TObject; const OldLocation, NewLocation: TLocationCoord2D);
var
  Distance, TimeDifference, Speed: Double;
begin
  if (FLastLocation.Latitude <> 0) and (FLastLocation.Longitude <> 0) then
  begin
    Distance := HaversineDistance(FLastLocation.Latitude, FLastLocation.Longitude, NewLocation.Latitude, NewLocation.Longitude);
    TimeDifference := (Now - FLastTime) * 24 * 60 * 60; // Différence de temps en secondes
    Speed := (Distance / TimeDifference) * 3.6; // Vitesse en km/h

    DisplaySpeedAsImages(Speed);
  end;

  FLastLocation := NewLocation;
  FLastTime := Now;
end;

end.
