unit uRaytracer;

interface

uses
  uVectorTypes,
  uSceneElements,
  uViewer,
  uScene,
  uSceneElementLists,
  uBaseList, System.SysUtils;

type
  TRaytracer = class
  private
    class function CastRay(_AOrig, _ADir: TVector3f;
  _AScene: TScene;
  _ADepth: integer): TVector3f;
    class function SceneIntersect(_AOrig, _ADir: TVector3f;
  _AScene: TScene; out hit, n: TVector3f;
  out material: TMaterial): boolean;
  public
    class procedure Render(_AViewer: TViewer; _AScene: TScene);
  end;

implementation

uses
  Math;

{ TRaytracer }

class function TRaytracer.CastRay(_AOrig, _ADir: TVector3f;
  _AScene: TScene;
  _ADepth: integer): TVector3f;
var
  point, N: TVector3f;
  material: TMaterial;
  diffuse_light_intensity: Single;
  specular_light_intensity: Single;
  i: integer;
  light_dir: TVector3f;
  diffuse_color: Tvector3f;
  specular_color: TVector3f;
  light_distance: Single;
  shadow_orig: TVector3f;

  shadow_pt, shadow_N: TVector3f;
  tmpmaterial: TMaterial;

  reflect_dir: TVector3f;
  reflect_orig: TVector3f;
  reflect_color: TVector3f;

  ANewDepth: Integer;

  refract_dir: TVector3f;
  refract_orig: TVector3f;
  refract_color: TVector3f;
r: single;
begin


  if (_ADepth > 4) or (not SceneIntersect(_AOrig, _ADir, _AScene, point, N, material)) then
  begin
    Result.Init(0.2, 0.7, 0.8); // background color
    exit;
  end;

  //writeln('intersection');

//   reflect_dir := _ADir.Clone().Reflect(N).Normalize;
//   refract_dir := _ADir.Clone().Refract(N, material.RefractiveIndex).Normalize;

//   if reflect_dir.DotProduct(N) < 0 then
//     reflect_orig := point.Clone().Subtract(N.Scale(0.001))
//   else
//     reflect_orig := point.Clone().Add(N.Scale(0.001));

//   if refract_dir.DotProduct(N) < 0 then
//     refract_orig := point.Clone().Subtract(N.Scale(0.001))
//  else
//     refract_orig := point.Clone().Add(N.Scale(0.001));

  // ANewDepth := _ADepth + 1;
  // reflect_color := CastRay(reflect_orig, reflect_dir, _AScene, ANewDepth);
  // refract_color := CastRay(refract_orig, refract_dir, _AScene, ANewDepth);

  diffuse_light_intensity := 0;
  specular_light_intensity := 0;

  for i := 0 to _AScene.LightList.Count -1 do
  begin
    light_dir := _AScene.LightList.Get(i).position.Clone();
    light_dir.Subtract(@point).normalize;

    // light_distance := _AScene.LightList.Get(i).position.Clone().Subtract(point).Magnitude;

    // if light_dir.DotProduct(N) < 0 then
    //   shadow_orig := point.Clone().Subtract(N.Scale(0.001))
    // else
    //   shadow_orig := point.Clone().Add(N.Scale(0.001));

    // if (SceneIntersect(shadow_orig, light_dir, _AScene, shadow_pt, shadow_N, tmpmaterial) and
    //    (shadow_pt.Subtract(shadow_orig).Magnitude < light_distance)) then
    //     continue;

    diffuse_light_intensity := diffuse_light_intensity +
      _AScene.LightList.Get(i).intensity * Max(0, light_dir.DotProduct(@N));

r :=  light_dir.Scale(-1).Reflect(@N).Scale(-1).DotProduct(@_ADir);

writeln('r ' + floattostr(r));

     specular_light_intensity := specular_light_intensity +
       Power(Max(0,r),
         material.SpecularExponent) * _AScene.LightList.Get(i).intensity;
  end;

  diffuse_color := material.CalculateDiffuseColorInScene(diffuse_light_intensity);
  specular_color := material.CalculateSpecularColorInScene(specular_light_intensity);
  // reflect_color := material.CalculateReflectColorInScene(reflect_color);
  // refract_color := material.CalculateRefractColorInScene(refract_color);


writeln(floattostr(specular_light_intensity));
  WRITELN(specular_color.PrettyString);



  result := diffuse_color.Clone();
  //result.Add(@specular_color);//.Add(reflect_color).Add(refract_color);

  // WRITELN(RESULT.PrettyString);
end;

class procedure TRaytracer.Render(_AViewer: TViewer; _AScene: TScene);
var
  j: Integer;
  i: integer;
  x, y: Single;
  AFOV: Single;
  Aorig: Tvector3f;
  Adir: tvector3f;
  AColor: tVector3f;
begin

  AFOV := _AScene.Camera.FOV;

  //writeln(_AScene.Camera.Position.PrettyString);

  for j := 0 to _AViewer.Height - 1 do
    for i := 0 to _AViewer.Width - 1 do
    begin
     //writeln('for');
      x :=  (2*(i + 0.5)/_AViewer.Width  - 1)*tan(AFOV/2)*_AViewer.Width/_AViewer.Height;
      y := -(2*(j + 0.5)/_AViewer.Height - 1)*tan(AFOV/2);

      Adir.Init(x, y, -1).Normalize();      {TODO: IMPLEMENT CAMERA DIRECTION}
      //Adir := Adir.Normalize();

      //writeln('DIR '+ aDIR.PrettyString);

      Aorig := _AScene.Camera.Position;

      //writeln('ORIG '+_AScene.Camera.Position.PrettyString);

      AColor := CastRay(Aorig, Adir, _AScene, 0);

      //writeln(AColor.PrettyString);

      _AViewer.SetPixel(i, j, AColor);
    end;
end;

class function TRaytracer.SceneIntersect(_AOrig, _ADir: TVector3f;
  _AScene: TScene; out hit, n: TVector3f;
  out material: TMaterial): boolean;
var
  ASphereDist: Single;
  ADist_i: Single;
  i: integer;
  checkerboard_dist: Single;
  d: Single;
  pt: tVector3f;
  ADir_: TVector3f;
  AOrig_: TVector3f;

begin
  ASphereDist := MaxInt;

  //writeln('scene intersect');
  for i := 0 to _AScene.ObjectList.Count - 1 do
  begin
    if (_AScene.ObjectList.Get(i).RayIntersect(_AOrig, _ADir, ADist_i) and (ADist_i < ASphereDist)) then
    begin
      ASphereDist := ADist_i;
      hit := _AOrig.Clone();

      ADir_ :=  _ADir.Clone();

      hit.Add(ADir_.Scale(ADist_i));

      N := hit.Clone();
      N.Subtract(@_AScene.ObjectList.Get(i).center).normalize();
      material := _AScene.ObjectList.Get(i).material;
    end;
  end;

  checkerboard_dist := MaxInt;

  //writeln('checkboard intersect');
  {
  if (Abs(_ADir.y) > 0.001) then
  begin
    d := -(_AOrig.y + 4) / _ADir.y; // the checkerboard plane has equation y = -4
    pt := _AOrig.Clone().Add(_ADir.Clone().Scale(d));
    if (d>0) and (abs(pt.x) < 10) and (pt.z < -10) and (pt.z > -30) and (d < ASphereDist) then
    begin
      checkerboard_dist := d;
      hit := pt;
      N.Init(0, 1, 0);

      material := TMaterial.Create('checkboard');
      if ((trunc(0.5 * hit.x + 1000) + trunc(0.5 * hit.z)) and 1) = 1 then
        material.DiffuseColor.Init(0.3, 0.3, 0.3)
      else
        material.DiffuseColor.Init(0.3, 0.2, 0.1);
    end;
  end;    }

  //writeln('intersections ok');
  //result := Min(ASphereDist, checkerboard_dist) < 1000;
  result := ASphereDist < 1000;
end;

end.
