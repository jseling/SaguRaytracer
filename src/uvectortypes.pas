unit uVectorTypes;

{$IFDEF FPC}
  {$modeswitch advancedrecords}
{$ENDIF}

{$inline on}

interface

uses
  Math, System.SysUtils;

type
  PVector3f = ^TVector3f;
  { TVector3f }

  //memory allocation at stack in this case is fastest than using class at heap
  TVector3f = record
  public
    X: Single;
    Y: Single;
    Z: Single;

    //this is fastest than a formal constructor
    function Init(_AX, _AY, _AZ: Single): PVector3f; inline;

    function Add(_AVector: PVector3f): PVector3f; inline;
    function Subtract(_AVector: PVector3f): PVector3f; inline;
    function Scale(_AFactor: Single): PVector3f; inline;
    function DotProduct(_AVector: PVector3f): Single; inline;
    function Magnitude(): Single; inline;
    function Normalize(): PVector3f; inline;
    function Reflect(_ANormal: PVector3f): PVector3f; inline;
    function Refract(_AN: PVector3f; eta_t: Single; eta_i: Single = 1): TVector3f; inline;

    function Clone(): TVector3f; inline;
    function PrettyString(): string; 
  end;

  TVector4f = record
  public
    X: Single;
    Y: Single;
    Z: Single;
    W: Single;
    procedure Init(_AX, _AY, _AZ, _AW: Single);
  end;

  PColor = ^TColor;

  { TColor }

  TColor = record
  public
    R: Single;
    G: Single;
    B: Single;
    function Create(_AR, _AG, _AB: Single): PColor;
    function Add(const _AOtherColor: TColor): PColor;
  end;

  TByteColor = record
  public
    R: Byte;
    G: Byte;
    B: Byte;

    //expect a vector with RGB values within 0..1 interval.
    procedure SetFromVector3f(const _AVectorColor: tVector3f);
  end;

  TArrayVector3f = array of tVector3f;
  TArraySingle = array of Single;

implementation

{ TColor }

function TColor.Create(_AR, _AG, _AB: Single): PColor;
begin
  R := _AR;
  G := _AG;
  B := _AB;
  Result := @Self;
end;

function TColor.Add(const _AOtherColor: TColor): PColor;
begin
  R := R + _AOtherColor.R;
  G := G + _AOtherColor.G;
  B := B + _AOtherColor.B;
  Result := @Self;
end;

{ TiColor }

procedure TByteColor.SetFromVector3f(const _AVectorColor:tVector3f);
var
  AR, AG, AB: Integer;

  function FixRange(_AValue: Integer): Byte;
  begin
    Result := _AValue;
    if _AValue > 255 then
      Result := 255;

    if _AValue < 0 then
      Result := 0;
  end;
begin
//writeln(_AVectorColor.PrettyString);
  AR := Trunc(_AVectorColor.x * 255);
  AG := Trunc(_AVectorColor.y * 255);
  AB := Trunc(_AVectorColor.Z * 255);

  //writeln(FLOATtostr(_AVectorColor.Z * 255) );

  R := FixRange(AR);
  G := FixRange(AG);
  B := FixRange(AB);

  //writeln(inttostr(AR) + ', ' +inttostr(AG) + ', '+ inttostr(AB))
end;

{ TVector3f }

function TVector3f.Add(_AVector: PVector3f): PVector3f;
begin
  X := X + _AVector.X;
  Y := Y + _AVector.Y;
  Z := Z + _AVector.Z;

  Result := @Self;
end;

function TVector3f.Clone: TVector3f;
begin
  Result.Init(X, Y, Z);
end;

function TVector3f.Init(_AX, _AY, _AZ: Single): PVector3f;
begin
  X := _AX;
  Y := _AY;
  Z := _AZ;

  Result := @Self;
end;

function TVector3f.DotProduct(_AVector: PVector3f): Single;
begin
  Result := X * _AVector.X +
            Y * _AVector.Y +
            Z * _AVector.Z;
end;

function TVector3f.Magnitude(): Single;
begin
  Result := Sqrt(X * X +
                 Y * Y +
                 Z * Z);
end;

function TVector3f.Normalize(): PVector3f;
var
  AMag: Single;
begin
  AMag := Self.Magnitude();

  X := X / AMag;
  Y := Y / AMag;
  Z := Z / AMag;

  Result := @Self;
end;

function TVector3f.Reflect(_ANormal: PVector3f): PVector3f;
var
  AIDotN: Single;
  ANScale2: TVector3f;
  AReflection: TVector3f;
begin
  ANScale2 := _ANormal.Clone;
  ANScale2.Scale(2);

//writeln('self ' + self.PrettyString);
//writeln('normal scaled ' + ANScale2.PrettyString);

  AIDotN := Self.DotProduct(_ANormal);

  //writeln('dot ' + floattostr(AIDotN));

  Self.Subtract(ANScale2.Scale(AIDotN));

//writeln('self ' + self.PrettyString);
  Result := @Self;
end;

function TVector3f.Refract(_AN: PVector3f; eta_t: Single; eta_i: Single = 1): TVector3f;
var
  cosi: Single;
  eta: Single;
  k: Single;
begin
  cosi := Max(-1, Min(1, Self.DotProduct(_AN))) * (-1);

  if (cosi < 0) then
  begin
    Result := Self.Refract(_AN.Scale(-1), eta_i, eta_t);
    exit;
  end;

  eta := eta_i / eta_t;
  k := 1 - eta * eta * (1 - cosi * cosi);

  if (k < 0) then
    Result.Init(1, 0, 0)
  else
  begin
    Result := Self.Clone();
    Result.Scale(eta).Add(_AN.Scale(eta * cosi - sqrt(k)));
  end;
end;

function TVector3f.Scale(_AFactor: Single): PVector3f;
begin
  X := X * _AFactor;
  Y := Y * _AFactor;
  Z := Z * _AFactor;

  Result := @Self;
end;

function TVector3f.Subtract(_AVector: PVector3f): PVector3f;
begin
  X := X - _AVector.X;
  Y := Y - _AVector.Y;
  Z := Z - _AVector.Z;

  Result := @Self;
end;

{ TVector4f }

procedure TVector4f.Init(_AX, _AY, _AZ, _AW: Single);
begin
  X := _AX;
  Y := _AY;
  Z := _AZ;
  W := _AW;
end;

function TVector3f.PrettyString: string;
begin
  Result := '[' + floattostr(x) + ', ' + floattostr(y) + ', ' + floattostr(z) + ']';  
end;

end.
