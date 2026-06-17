unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, StdCtrls,
  ExtCtrls, EpikTimer, BGRABitmap,BGRABitmapTypes, Math, LCLIntf;

type
  Tree = record
    CenterBase,X,Y:Integer;
    Type_: Integer;   //1, 2, 3
    Height: Integer;         //Min=70  Max=100
    Width: Integer;       //Min=40  Max=60
    Height_Trunk: Integer; //Tree1.Height div 3
    Height_Stem: Integer;  //Tree1.Height-Tree1.Height_Trunk
    TotalBranch: Integer;  //Min=0 Max=2
    Height_Bush1:Integer;    //Min=20  Max=25
    Width_Bush1:Integer;    //Min=20  Max=25
    Height_Bush2:Integer;    //Min=20  Max=25
    Width_Bush2:Integer;    //Min=20  Max=25
    bmp: TBGRABitmap;
  end;

  type
  Inform = record
    Previous: Float;
    TimePerFrame: Float;
    LinePerFrame: Integer;
    FramePerSec: Integer;
    ActualElapsed: Float;
    LineLeftover: Integer;
    Speed_frame:Extended;
  end;


type

  { TForm1 }

  TForm1 = class(TForm)
    Label3: TLabel;
    PaintBox2: TPaintBox;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure Main_Loop();
    procedure SetUpValue();
    Function Create_Tree(Tree_: Tree; Enable_Frame:Boolean): TBGRABitmap;
    Function Grass_(G_Width,G_Height,LeafHeight:Integer; Enable_Frame:Boolean): TBGRABitmap;
  end;

var
  Form1: TForm1;
  timer_: TEpikTimer;
  Run_:Boolean;
  Background_, bmp, bmp2,Grass: TBGRABitmap;
  Grid_:Tpoint;
  c: TBGRAPixel;
  Trect_:Trect;
  Positioning:integer;
  Information:Inform;
  Tree1,Tree2,Tree3,Tree4,Tree5:Tree;
implementation

{$R *.lfm}

{ TForm1 }
Function TForm1.Grass_(G_Width,G_Height,LeafHeight:Integer; Enable_Frame:Boolean): TBGRABitmap;
var
  pts: array of TPointF;
  Total_Point:integer;
  i,X_Position:integer;
  Low_:Boolean;
begin
  Low_:=True;
  if (LeafHeight>= G_Height) or (LeafHeight<=0) then LeafHeight:= G_Height div 2;
  Total_Point:=round(G_Width/1.5);
  setlength(pts,Total_Point+2);
  Grass_:=TBGRABitmap.Create(G_Width,G_Height,BGRAPixelTransparent);
  X_Position:=0;
  for i := 0 to Total_Point do
  begin
    if i = 0 then pts[i]:=PointF(0+X_Position,G_Height);
    if (i > 0) and Low_ then pts[i]:=PointF(Random(4)+1+X_Position,G_Height-Random(LeafHeight div 3)-((G_Height-LeafHeight) div 3));
    if (i > 0) and (Not Low_) then pts[i]:=PointF(Random(4)+1+X_Position,G_Height-Random(LeafHeight)-(G_Height-LeafHeight));
    X_Position:=Round(pts[i].x);
    Low_:=Not Low_;
  end;
  pts[Total_Point+0]:= PointF(G_Width,G_Height);
  pts[Total_Point+1]:= PointF(0,G_Height);
  Grass_.FillPolyAntialias(pts,BGRA(90,143,29));
  if Enable_Frame then Grass_.Rectangle(0,0,Grass_.Width,Grass_.Height,rgb(255,0,0));
end;

Function TForm1.Create_Tree(Tree_: Tree; Enable_Frame:Boolean): TBGRABitmap;
var
  pts: array[0..2] of TPointF;
  pts2: array[0..7] of TPointF;
begin
  if (Tree_.Type_=1)then
  begin
    Tree_.CenterBase:=Tree_.Width div 2;
    Create_Tree:=TBGRABitmap.Create(Tree_.Width,Tree_.Height,BGRAPixelTransparent);
    pts2[0]:=PointF(Tree_.CenterBase-15,Tree_.Height);
    pts2[1]:=PointF(Tree_.CenterBase-15,Tree_.Height-5);
    pts2[2]:=PointF(Tree_.CenterBase-5,Tree_.Height-5);
    pts2[3]:=PointF(Tree_.CenterBase-5,Tree_.Height-Tree_.Height_Trunk-0.5);
    pts2[4]:=PointF(Tree_.CenterBase+5,Tree_.Height-Tree_.Height_Trunk-0.5);
    pts2[5]:=PointF(Tree_.CenterBase+5,Tree_.Height-5);
    pts2[6]:=PointF(Tree_.CenterBase+15,Tree_.Height-5);
    pts2[7]:=PointF(Tree_.CenterBase+15,Tree_.Height);
    Create_Tree.FillPolyAntialias(pts2,BGRA(151,120,76));
    pts[0]:=PointF(Tree_.CenterBase-0.5,Tree_.Height-Tree_.Height_Trunk);
    pts[1]:=PointF(Tree_.CenterBase-0.5,Tree_.Height-Tree_.Height_Trunk-(Tree_.Height-Tree_.Height_Trunk));
    pts[2]:=PointF(Tree_.CenterBase+Tree_.CenterBase,Tree_.Height-Tree_.Height_Trunk);
    Create_Tree.FillPolyAntialias(pts,BGRA(90,143,29));    //bmp.FillPolyAntialias([pts[0],pts[1],pts[2]],BGRA(90,143,29));
    pts[0]:=PointF(Tree_.CenterBase,Tree_.Height-Tree_.Height_Trunk);
    pts[1]:=PointF(Tree_.CenterBase,Tree_.Height-Tree_.Height_Trunk-(Tree_.Height-Tree_.Height_Trunk));
    pts[2]:=PointF(Tree_.CenterBase-Tree_.CenterBase,Tree_.Height-Tree_.Height_Trunk);
    Create_Tree.FillPolyAntialias(pts,BGRA(108,167,39));
  end;

  if (Tree_.Type_=2) then
  begin
    Tree_.CenterBase:=(Tree_.Width+60) div 2;
    Create_Tree:=TBGRABitmap.Create(Tree_.Width+60,Tree_.Height,BGRAPixelTransparent);
    pts2[0]:=PointF(Tree_.CenterBase-15,Tree_.Height);
    pts2[1]:=PointF(Tree_.CenterBase-15,Tree_.Height-5);
    pts2[2]:=PointF(Tree_.CenterBase-5,Tree_.Height-5);
    pts2[3]:=PointF(Tree_.CenterBase-5,Tree_.Height-Tree_.Height_Trunk-0.5);
    pts2[4]:=PointF(Tree_.CenterBase+5,Tree_.Height-Tree_.Height_Trunk-0.5);
    pts2[5]:=PointF(Tree_.CenterBase+5,Tree_.Height-5);
    pts2[6]:=PointF(Tree_.CenterBase+15,Tree_.Height-5);
    pts2[7]:=PointF(Tree_.CenterBase+15,Tree_.Height);
    Create_Tree.FillPolyAntialias(pts2,BGRA(151,120,76));
    Create_Tree.FillEllipseLinearColorAntialias(Tree_.CenterBase,20,Tree_.Width div 2,20,BGRA(90,143,29),BGRA(168,227,99));

    //Tree_.bmp.LineCap:= pecFlat;
    if Tree_.TotalBranch > 0 then
    begin
      Create_Tree.DrawPolyLineAntialias([PointF(Tree_.CenterBase,Tree_.Height_Trunk-6),PointF(Tree_.CenterBase+20,Tree_.Height_Trunk-6),PointF(Tree_.CenterBase+20,Tree_.Height_Trunk-17)],BGRA(151,120,76),3);
      Create_Tree.FillEllipseLinearColorAntialias(Tree_.CenterBase+20,Tree_.Height_Trunk-17,Tree_.Width_Bush1,Tree_.Height_Bush1,BGRA(90,143,29),BGRA(168,227,99));
    end;
    if Tree_.TotalBranch >=2  then
    begin
      Create_Tree.DrawPolyLineAntialias([PointF(Tree_.CenterBase,Tree_.Height_Trunk+3),PointF(Tree_.CenterBase-20,Tree_.Height_Trunk+3),PointF(Tree_.CenterBase-20,Tree_.Height_Trunk-8)],BGRA(151,120,76),3);
      Create_Tree.FillEllipseLinearColorAntialias(Tree_.CenterBase-20,Tree_.Height_Trunk-8,Tree_.Width_Bush1,Tree_.Height_Bush1,BGRA(90,143,29),BGRA(168,227,99));
    end;
  end;

  if (Tree_.Type_=3) then
  begin
    Tree_.CenterBase:=Tree_.Width div 2;
    Create_Tree:=TBGRABitmap.Create(Tree_.Width,Tree_.Height,BGRAPixelTransparent);
    pts2[0]:=PointF(Tree_.CenterBase-15,Tree_.Height);
    pts2[1]:=PointF(Tree_.CenterBase-15,Tree_.Height-5);
    pts2[2]:=PointF(Tree_.CenterBase-5,Tree_.Height-5);
    pts2[3]:=PointF(Tree_.CenterBase-5,Tree_.Height-Tree_.Height_Trunk-0.5);
    pts2[4]:=PointF(Tree_.CenterBase+5,Tree_.Height-Tree_.Height_Trunk-0.5);
    pts2[5]:=PointF(Tree_.CenterBase+5,Tree_.Height-5);
    pts2[6]:=PointF(Tree_.CenterBase+15,Tree_.Height-5);
    pts2[7]:=PointF(Tree_.CenterBase+15,Tree_.Height);
    Create_Tree.FillPolyAntialias(pts2,BGRA(151,120,76));

    pts[0]:=PointF(Tree_.CenterBase-0.5,Tree_.Height-Tree_.Height_Trunk-10);
    pts[1]:=PointF(Tree_.CenterBase-0.5,0);
    pts[2]:=PointF(Tree_.CenterBase+Tree_.CenterBase,Tree_.Height-Tree_.Height_Trunk-10);
    Create_Tree.FillPolyAntialias(pts,BGRA(90,143,29));
    pts[0]:=PointF(Tree_.CenterBase,Tree_.Height-Tree_.Height_Trunk-10);
    pts[1]:=PointF(Tree_.CenterBase,0);
    pts[2]:=PointF(Tree_.CenterBase-Tree_.CenterBase,Tree_.Height-Tree_.Height_Trunk-10);
    Create_Tree.FillPolyAntialias(pts,BGRA(108,167,39));

    pts[0]:=PointF(Tree_.CenterBase-0.5,Tree_.Height-Tree_.Height_Trunk);
    pts[1]:=PointF(Tree_.CenterBase-0.5,0);
    pts[2]:=PointF(Tree_.CenterBase+Tree_.CenterBase,Tree_.Height-Tree_.Height_Trunk);
    Create_Tree.FillPolyAntialias(pts,BGRA(90,143,29));
    pts[0]:=PointF(Tree_.CenterBase,Tree_.Height-Tree_.Height_Trunk);
    pts[1]:=PointF(Tree_.CenterBase,0);
    pts[2]:=PointF(Tree_.CenterBase-Tree_.CenterBase,Tree_.Height-Tree_.Height_Trunk);
    Create_Tree.FillPolyAntialias(pts,BGRA(108,167,39));
  end;
  if Enable_Frame then Create_Tree.Rectangle(0,0,Create_Tree.Width,Create_Tree.Height,rgb(255,0,0));
end;

Procedure TForm1.SetUpValue();
begin
  Randomize;
  Grass:=TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height,BGRAPixelTransparent);
  Grass:=Grass_(PaintBox2.Width,30,20,False);

  Tree1.X:=150;
  Tree1.Y:=155;
  Tree1.Type_:= Random(3)+1;
  Tree1.Height:=70+Random(30);
  Tree1.Width:=40+Random(20);
  if (Tree1.Type_=1) or (Tree1.Type_=3) then
  begin
    Tree1.Height_Trunk:=Tree1.Height div 3;
    Tree1.CenterBase:=Tree1.Width div 2;
    Tree1.bmp:=TBGRABitmap.Create(Tree1.Width,Tree1.Height,BGRAPixelTransparent);
  end;
  if Tree1.Type_=2 then
  begin
    Tree1.Height_Trunk:=Round(Tree1.Height / 1.3);
    Tree1.CenterBase:=(Tree1.Width+60) div 2;
    Tree1.bmp:=TBGRABitmap.Create(Tree1.Width+60,Tree1.Height,BGRAPixelTransparent);
  end;
  Tree1.Height_Stem:=Tree1.Height-Tree1.Height_Trunk;
  Tree1.TotalBranch:=Random(3);
  Tree1.Height_Bush1:=4+Random(5);
  Tree1.Width_Bush1:=7+Random(5);
  Tree1.Height_Bush2:=4+Random(5);
  Tree1.Width_Bush2:=7+Random(5);

  Tree1.bmp:=Create_Tree(Tree1,True);

  Tree2.X:=350;
  Tree2.Y:=155;
  Tree2.Type_:=Random(3)+1;
  Tree2.Height:=70+Random(30);
  Tree2.Width:=40+Random(20);
  if (Tree2.Type_=1) or (Tree2.Type_=3) then
  begin
    Tree2.Height_Trunk:=Tree2.Height div 3;
    Tree2.CenterBase:=Tree2.Width div 2;
    Tree2.bmp:=TBGRABitmap.Create(Tree2.Width,Tree2.Height,BGRAPixelTransparent);
  end;
  if Tree2.Type_=2 then
  begin
    Tree2.Height_Trunk:=Round(Tree2.Height / 1.3);
    Tree2.CenterBase:=(Tree2.Width+60) div 2;
    Tree2.bmp:=TBGRABitmap.Create(Tree2.Width+60,Tree2.Height,BGRAPixelTransparent);
  end;
  Tree2.Height_Stem:=Tree2.Height-Tree2.Height_Trunk;
  Tree2.TotalBranch:=Random(4);
  Tree2.Height_Bush1:=4+Random(5);
  Tree2.Width_Bush1:=7+Random(5);
  Tree2.Height_Bush2:=4+Random(5);
  Tree2.Width_Bush2:=7+Random(5);

  Tree2.bmp:=Create_Tree(Tree2,True);

  Tree3.X:=240;
  Tree3.Y:=155;
  Tree3.Type_:=Random(3)+1;
  Tree3.Height:=70+Random(30);
  Tree3.Width:=40+Random(20);
  if (Tree3.Type_=1) or (Tree3.Type_=3) then
  begin
    Tree3.Height_Trunk:=Tree3.Height div 3;
    Tree3.CenterBase:=Tree3.Width div 2;
    Tree3.bmp:=TBGRABitmap.Create(Tree3.Width,Tree3.Height,BGRAPixelTransparent);
  end;
  if Tree3.Type_=2 then
  begin
    Tree3.Height_Trunk:=Round(Tree3.Height / 1.3);
    Tree3.CenterBase:=(Tree3.Width+60) div 2;
    Tree3.bmp:=TBGRABitmap.Create(Tree3.Width+60,Tree3.Height,BGRAPixelTransparent);
  end;
  Tree3.Height_Stem:=Tree3.Height-Tree3.Height_Trunk;
  Tree3.TotalBranch:=Random(4);
  Tree3.Height_Bush1:=4+Random(5);
  Tree3.Width_Bush1:=7+Random(5);
  Tree3.Height_Bush2:=4+Random(5);
  Tree3.Width_Bush2:=7+Random(5);

  Tree3.bmp:=Create_Tree(Tree3,True);

  Tree4.X:=150;
  Tree4.Y:=265;
  Tree4.Type_:= Random(3)+1;
  Tree4.Height:=70+Random(30);
  Tree4.Width:=40+Random(20);
  if (Tree4.Type_=1) or (Tree4.Type_=3) then
  begin
    Tree4.Height_Trunk:=Tree4.Height div 3;
    Tree4.CenterBase:=Tree4.Width div 2;
    Tree4.bmp:=TBGRABitmap.Create(Tree4.Width,Tree4.Height,BGRAPixelTransparent);
  end;
  if Tree4.Type_=2 then
  begin
    Tree4.Height_Trunk:=Round(Tree4.Height / 1.3);
    Tree4.CenterBase:=(Tree4.Width+60) div 2;
    Tree4.bmp:=TBGRABitmap.Create(Tree4.Width+60,Tree4.Height,BGRAPixelTransparent);
  end;
  Tree4.Height_Stem:=Tree4.Height-Tree4.Height_Trunk;
  Tree4.TotalBranch:=Random(3);
  Tree4.Height_Bush1:=4+Random(5);
  Tree4.Width_Bush1:=7+Random(5);
  Tree4.Height_Bush2:=4+Random(5);
  Tree4.Width_Bush2:=7+Random(5);

  Tree4.bmp:=Create_Tree(Tree4,False);

  Tree5.X:=240;
  Tree5.Y:=265;
  Tree5.Type_:=Random(3)+1;
  Tree5.Height:=70+Random(30);
  Tree5.Width:=40+Random(20);
  if (Tree5.Type_=1) or (Tree5.Type_=3) then
  begin
    Tree5.Height_Trunk:=Tree5.Height div 3;
    Tree5.CenterBase:=Tree5.Width div 2;
    Tree5.bmp:=TBGRABitmap.Create(Tree5.Width,Tree5.Height,BGRAPixelTransparent);
  end;
  if Tree5.Type_=2 then
  begin
    Tree5.Height_Trunk:=Round(Tree5.Height / 1.3);
    Tree5.CenterBase:=(Tree5.Width+60) div 2;
    Tree5.bmp:=TBGRABitmap.Create(Tree5.Width+60,Tree5.Height,BGRAPixelTransparent);
  end;
  Tree5.Height_Stem:=Tree5.Height-Tree5.Height_Trunk;
  Tree5.TotalBranch:=Random(4);
  Tree5.Height_Bush1:=4+Random(5);
  Tree5.Width_Bush1:=7+Random(5);
  Tree5.Height_Bush2:=4+Random(5);
  Tree5.Width_Bush2:=7+Random(5);

  Tree5.bmp:=Create_Tree(Tree5,False);

  Information.Speed_frame:=0.02;
  timer_ := TEpikTimer.Create(nil);
  //timer_.TimebaseSource:=timer_.TimebaseSource.HardwareTimebase;
  Run_:=False;

  c := ColorToBGRA(rgb(255,255,255));

  //Load your bitmap here

  Grid_.X:=26;
  Grid_.y:=15;

  if Grid_.X<0 then Grid_.X:=0;
  if Grid_.Y<0 then Grid_.Y:=0;

  Background_ := TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height, ColorToBGRA($00F0F0F0));//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))
  bmp := TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height, ColorToBGRA($00F0F0F0));//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))
  bmp2 := TBGRABitmap.Create(Round(PaintBox2.Width/(Grid_.X+1))+1,PaintBox2.Height, ColorToBGRA($00CCCCCC));//ColorToBGRA($00CCCCCC)//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))
  bmp.FontName := 'Times New Roman';
  bmp.FontAntialias:= true;
  bmp.FontHeight:=12;
  bmp.FontStyle:=[fsBold];

end;

procedure TForm1.Main_Loop();
var
  Frame_, Line_, Line_Frame:integer;
begin
  if Not Run_ then
  begin
    Run_:=True;
    Information.Previous:=0;
    Frame_:=0;
    Line_:=0;
    timer_.Clear;
    timer_.Start;

    while Run_ do
    begin
      Line_Frame:=0;
      application.ProcessMessages; //Work one program only   Case 1.

      //Run your program here  => Finish up your brackground

      bmp.PutImage(0,0,Background_,dmDrawWithTransparency);

      Trect_.TopLeft.x:=1;
      Trect_.TopLeft.y:=0;
      Trect_.BottomRight.x:=PaintBox2.Width;
      Trect_.BottomRight.y:=PaintBox2.Height;
      Background_.PutImagePart(0,0,Background_,Trect_,dmDrawWithTransparency);

      Positioning:=Positioning+1;
      if Positioning = (bmp2.Width) then Positioning :=0;

      Trect_.TopLeft.x:=Positioning;
      Trect_.TopLeft.y:=0;
      Trect_.BottomRight.x:=Positioning+1;
      Trect_.BottomRight.y:=bmp2.Height;
      c := ColorToBGRA(rgb(255,50,0));
      Background_.PutImagePart(PaintBox2.Width-1,0,bmp2,Trect_,dmDrawWithTransparency);

      //Any text information here  => Finish up your text status
      c := ColorToBGRA(rgb(0,105,208));


      bmp.TextOut(10,(bmp.FontFullHeight*0)+5,'Tree1 ='+IntToStr(Tree1.Type_)+'  CenterBase ='+IntToStr(Tree1.CenterBase),c);
      bmp.TextOut(10,(bmp.FontFullHeight*1)+5,'Tree2 ='+IntToStr(Tree2.Type_)+'  CenterBase ='+IntToStr(Tree2.CenterBase),c);
      bmp.TextOut(10,(bmp.FontFullHeight*2)+5,'Tree3 ='+IntToStr(Tree3.Type_)+'  CenterBase ='+IntToStr(Tree3.CenterBase),c);

      //Draw tree
      bmp.PutImage(Tree1.X-Tree1.CenterBase,Tree1.Y-Tree1.Height,Tree1.bmp,dmDrawWithTransparency);
      bmp.DrawPolyLineAntialias([PointF(Tree1.X-5,Tree1.Y+5), PointF(Tree1.X+5,Tree1.Y+5)],BGRA(0,255,0,255),1);
      bmp.DrawPolyLineAntialias([PointF(Tree1.X,Tree1.Y), PointF(Tree1.X,Tree1.Y+10)],BGRA(0,255,0,255),1);

      bmp.PutImage(Tree2.X-Tree2.CenterBase,Tree2.Y-Tree2.Height,Tree2.bmp,dmDrawWithTransparency);
      bmp.DrawPolyLineAntialias([PointF(Tree2.X-5,Tree2.Y+5), PointF(Tree2.X+5,Tree2.Y+5)],BGRA(0,255,0,255),1);
      bmp.DrawPolyLineAntialias([PointF(Tree2.X,Tree2.Y), PointF(Tree2.X,Tree2.Y+10)],BGRA(0,255,0,255),1);

      bmp.PutImage(Tree3.X-Tree3.CenterBase,Tree3.Y-Tree3.Height,Tree3.bmp,dmDrawWithTransparency);
      bmp.DrawPolyLineAntialias([PointF(Tree3.X-5,Tree3.Y+5), PointF(Tree3.X+5,Tree3.Y+5)],BGRA(0,255,0,255),1);
      bmp.DrawPolyLineAntialias([PointF(Tree3.X,Tree3.Y), PointF(Tree3.X,Tree3.Y+10)],BGRA(0,255,0,255),1);

      bmp.PutImage(Tree4.X-Tree4.CenterBase,Tree4.Y-Tree4.Height,Tree4.bmp,dmDrawWithTransparency);
      bmp.PutImage(Tree5.X-Tree5.CenterBase,Tree5.Y-Tree5.Height,Tree5.bmp,dmDrawWithTransparency);

      //Draw Grass
      bmp.PutImage(0,240,Grass,dmDrawWithTransparency);

      //Render here   => Finish up your rander
      bmp.Draw(PaintBox2.Canvas,0,0,True);

      //Clear your hardware here

      while (((timer_.Elapsed -Information.Previous) <= Information.Speed_frame) and
             (timer_.Elapsed < 1) and (Run_)) do //and (timer_.Elapsed < 1) do
      begin
        //application.ProcessMessages; //Share CUP  Case 2

        //Detect hardware here


        Line_:=Line_+1;
        Line_Frame:=Line_Frame+1;

        //Run_:=not Run_; //For run only 1 cycle
      end;

      //Other status here
      Information.Previous:=timer_.Elapsed;
      Frame_:=Frame_+1;

      if timer_.Elapsed >= 1 then
      begin

        timer_.Stop;
        Information.Previous:=0;
        Frame_:=0;
        Line_:=0;
        timer_.Clear;
        timer_.Start;
      end;

      //You can move your render to here. (!It is up to you)

    end;

    If not Run_ then  timer_.Stop;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i, i2, i3 : Integer;

begin
  SetUpValue();

  c := ColorToBGRA(rgb(190,190,190));

  i2:=Round(PaintBox2.Width/(Grid_.X+1));
  i3:=0;
  for i := 0 to Grid_.X do
  begin
    i3:=i3+i2;
    Background_.DrawPolyLineAntialias([PointF(i3,0), PointF(i3,PaintBox2.Height)],BGRA(255,255,255,150),1);
    //Background_.DrawPolyLineAntialias([PointF(i3,Tem.Position2.y+tem.offset), PointF(i3,Tem.Position2.y+tem.offset+round(tem.Radius*2))],BGRA(190,5,18,100),1);
  end;

  i2:=Round(PaintBox2.Height/(Grid_.Y+1));
  i3:=0;
  for i := 0 to Grid_.Y do
  begin
    i3:=i3+i2;
    Background_.DrawPolyLineAntialias([PointF(0,i3), PointF(PaintBox2.Width,i3)],BGRA(255,255,255,150),1);
  end;

  c := ColorToBGRA(rgb(255,255,255));

  Trect_.TopLeft.x:=0;
  Trect_.TopLeft.y:=0;
  Trect_.BottomRight.x:=bmp2.Width;
  Trect_.BottomRight.y:=bmp2.Height;
  bmp2.PutImagePart(0,0,Background_,Trect_,dmDrawWithTransparency);
  //bmp2.DrawPolyLineAntialias([PointF(0,0), PointF(0,bmp2.Height)],c,1);

  Positioning:=(PaintBox2.Width mod (Trect_.BottomRight.x-1));

end;


procedure TForm1.FormActivate(Sender: TObject);
begin
  Main_Loop();
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Run_:=False;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  timer_.Free;
  Background_.Free;
  bmp.Free;
  bmp2.Free;
  Tree1.bmp.Free;
  Tree2.bmp.Free;
  Tree3.bmp.Free;
  Grass.Free;
  //FreeAndNil(Tem);
end;

end.

