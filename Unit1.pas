unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Menus, Vcl.ExtCtrls;

type
  ICode = interface
    procedure CopyObjectFile(const id: integer);
    function ListBoxCheckTimeStamp(const id: integer): ICode;
    function ShowMessBeforeCopy(const bool: Boolean): ICode;
  end;

  TForm1 = class(TForm, ICode)
    ListBox1: TListBox;
    ListBox2: TListBox;
    FileOpenDialog1: TFileOpenDialog;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Panel1: TPanel;
    ListBox3: TListBox;
    Panel2: TPanel;
    N5: TMenuItem;
    N4: TMenuItem;
    N6: TMenuItem;
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure N3Click(Sender: TObject);
  private
    { Private 宣言 }
    IsShowmessage: Boolean;
    function IsArch(const Name: string): Boolean;
    procedure disposeItems;
    procedure Execute(const Name: string);
    function checkTimeStamp(const src, dst: string): Boolean;
    procedure CopyObjectFile(const id: integer);
    function ListBoxCheckTimeStamp(const id: integer): ICode;
    function ShowMessBeforeCopy(const bool: Boolean): ICode;
    procedure Touroku(const fullName: string);
  public
    { Public 宣言 }
  end;

  TListBoxHelper = class helper for TListBox
    procedure AddKeyValue(const Key: string; const Value: array of string);
    procedure checkTimeStamp(const id: integer);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses System.Generics.Collections, System.IOUtils, System.UITypes, System.Types;

const
  fileArray: TArray<string> = ['Win32', 'Win64', 'Linux32', 'Linux64',
    'TMSWeb'];
  version: TArray<string> = ['Debug', 'Release'];

function TForm1.checkTimeStamp(const src, dst: string): Boolean;
var
  LHandle1, LHandle2: integer;
begin
  if FileExists(dst) then
  begin
    LHandle1 := FileOpen(src, fmOpenRead);
    LHandle2 := FileOpen(dst, fmOpenRead);
    try
      result := FileGetDate(LHandle1) - FileGetDate(LHandle2) > 0;
    finally
      FileClose(LHandle1);
      FileClose(LHandle2);
    end;
  end
  else
    result := true;
end;

function TForm1.ListBoxCheckTimeStamp(const id: integer): ICode;
var
  obj: ^TPair<string, string>;
  dir: string;
begin
  result := Self;
  Pointer(obj) := ListBox3.Items.Objects[id];
  dir := ExtractFileDir(obj^.Value);
  if not DirectoryExists(dir) then
    MkDir(dir);
  if not checkTimeStamp(obj^.Key, obj^.Value) and IsShowmessage then
    if MessageDlg('古いファイルで上書きします。それでも実行しますか？' + #13#10 + obj^.Value,
      TMsgDlgType.mtConfirmation, [mbOK, mbNO], 0, mbNO) = mrOK then
      IsShowmessage := false
    else
      raise Exception.Create('Exit');
end;

procedure TForm1.CopyObjectFile(const id: integer);
var
  obj: ^TPair<string, string>;
begin
  Pointer(obj) := ListBox3.Items.Objects[id];
  CopyFile(PChar(obj^.Key), PChar(obj^.Value), false);
end;

procedure TForm1.disposeItems;
begin
  for var i := 0 to ListBox3.Count - 1 do
    Dispose(Pointer(ListBox3.Items.Objects[i]));
  ListBox3.Items.Clear;
end;

procedure TForm1.Execute(const Name: string);
var
  arr: TArray<string>;
  str: string;
begin
  if FileExists(Name) then
  begin
    ListBox2.Items.Add('登録します');
    Touroku(Name);
  end
  else if DirectoryExists(Name) then
  begin
    ListBox2.Items.Add('検索します ... ...');
    ListBox2.Items.Add('登録します');
    arr := TDirectory.GetDirectories(Name, TSearchOption.soTopDirectoryOnly,
      function(const Path: string; const SearchRec: TSearchRec): Boolean
      begin
        result := SearchRec.Attr = faDirectory;
      end);
    for var s in arr do
    begin
      str := ExtractFileName(s);
      if not IsArch(str) then
        Touroku(Name + '\' + str);
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  Name: string;
begin
  name := ChangeFileExt(Application.ExeName, '.txt');
  if FileExists(name) then
    ListBox1.Items.LoadFromFile(name);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if ListBox1.Count > 0 then
    ListBox1.Items.SaveToFile(ChangeFileExt(Application.ExeName, '.txt'));
  disposeItems;
end;

function TForm1.IsArch(const Name: string): Boolean;
begin
  for var s in fileArray do
    if Name = s then
      Exit(true);
  result := false;
end;

procedure TForm1.ListBox1KeyDown(Sender: TObject; var Key: Word;
Shift: TShiftState);
begin
  if Key = VK_DELETE then
    ListBox1.DeleteSelected;
end;

procedure TForm1.N1Click(Sender: TObject);
begin
  if FileOpenDialog1.Execute then
  begin
    case FileOpenDialog1.FileTypeIndex of
      1:
        ListBox1.Items.Add(ExtractFileDir(FileOpenDialog1.FileName));
      2:
        ListBox1.Items.Add(FileOpenDialog1.FileName);
    end;
    N4Click(Sender);
  end;
end;

procedure TForm1.N2Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.N3Click(Sender: TObject);
begin
  if ListBox1.ItemIndex > -1 then
  begin
    disposeItems;
    Execute(ListBox1.Items[ListBox1.ItemIndex]);
    N5Click(Sender);
  end;
end;

procedure TForm1.N4Click(Sender: TObject);
begin
  disposeItems;
  ListBox2.Items.Clear;
  for var s in ListBox1.Items do
    Execute(s);
  ListBox2.Items.Add(ListBox3.Count.ToString + ' Items');
end;

procedure TForm1.N5Click(Sender: TObject);
var
  cnt: integer;
begin
  cnt := 0;
  try
    ShowMessBeforeCopy(true);
    for var i := 0 to ListBox3.Count - 1 do
      ListBox3.checkTimeStamp(i);
  except
    on Exception do
    else
      raise;
  end;
  for var i := 0 to ListBox3.Count - 1 do
  begin
    CopyObjectFile(i);
    inc(cnt);
  end;
  ListBox2.Items.Add('実行終了 ' + cnt.ToString + ' files Copied');
end;

procedure TForm1.N6Click(Sender: TObject);
begin
  case ListBox2.Width of
    150:
      ListBox2.Width := 500;
    500:
      ListBox2.Width := 150;
  end;
end;

function TForm1.ShowMessBeforeCopy(const bool: Boolean): ICode;
begin
  IsShowmessage := bool;
  result := Self;
end;

procedure TForm1.Touroku(const fullName: string);
var
  arch, text, Path: string;
  full, Name: string;
begin
  if ListBox1.Items.IndexOf(fullName) > -1 then
    Exit;
  full := ExtractFilePath(fullName);
  name := ExtractFileName(fullName);
  for var fname in fileArray do
    for var ver in version do
    begin
      arch := TPath.Combine(fname, ver);
      text := name + '%s => ' + TPath.Combine(arch, name) + '%s';
      Path := TPath.Combine(full, name);

      if not DirectoryExists(TPath.Combine(full, arch)) then
        continue;
      if FileExists(Path) then
      begin
        if ListBox2.Items.IndexOf(Path) = -1 then
          ListBox2.Items.Add(Path);
        ListBox3.Items.Add(Format(text, ['', '']));
        ListBox3.AddKeyValue(Path, [full, arch, name]);
      end
      else
        for var detail in TDirectory.GetFiles(Path) do
        begin
          if ListBox2.Items.IndexOf(detail) = -1 then
            ListBox2.Items.Add(detail);
          if FileExists(detail) then
          begin
            ListBox3.Items.Add(Format(text, ['\' + Path, '\' + Path]));
            ListBox3.AddKeyValue(detail, [full, arch, name, Path]);
          end;
        end;
    end;
end;

{ TListBoxHelper }

procedure TListBoxHelper.AddKeyValue(const Key: string;
const Value: array of string);
var
  p: ^TPair<string, string>;
begin
  if Items.IndexOf(Key) = -1 then
  begin
    New(p);
    p^.Key := Key;
    p^.Value := TPath.Combine(Value);
    Items.Objects[Items.Count - 1] := Pointer(p);
  end;
end;

procedure TListBoxHelper.checkTimeStamp(const id: integer);
var
  obj: ^TPair<string, string>;
  dir: string;
begin
  Pointer(obj) := Items.Objects[id];
  dir := ExtractFileDir(obj^.Value);
  if not DirectoryExists(dir) then
    MkDir(dir);
  if not Form1.checkTimeStamp(obj^.Key, obj^.Value) and Form1.IsShowmessage then
    if MessageDlg('古いファイルで上書きします。それでも実行しますか？' + #13#10 + obj^.Value,
      TMsgDlgType.mtConfirmation, [mbOK, mbNO], 0, mbNO) = mrOK then
      Form1.IsShowmessage := false
    else
      raise Exception.Create('Exit');
end;

end.
