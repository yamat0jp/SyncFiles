unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JvComponentBase, JvDragDrop,
  Vcl.StdCtrls, Vcl.Menus, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
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
  public
    { Public 宣言 }
    mainDir: string;
    function GetSameFile(const Name: string): string;
    function IsArch(const Name: string): Boolean;
    procedure disposeItems;
    procedure Execute(const Name: string);
    function checkTimeStamp(const src, dst: string): Boolean;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses System.Generics.Collections, System.IOUtils, System.UITypes;

const
  fileArray: TArray<string> = ['Win32', 'Win64', 'Linux32', 'Linux64'];

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

procedure TForm1.disposeItems;
begin
  for var i := 0 to ListBox3.Count - 1 do
    Dispose(Pointer(ListBox3.Items.Objects[i]));
  ListBox3.Items.Clear;
end;

procedure TForm1.Execute(const Name: string);
const
  version: TArray<string> = ['Debug', 'Release'];
var
  str, text, cur, arch: string;
  obj: ^TPair<string, string>;
begin
  if FileExists(Name) then
  begin
    mainDir := ExtractFileDir(Name);
    str := GetSameFile(Name);
  end
  else
  begin
    mainDir := Name;
    str := GetSameFile(mainDir);
    ListBox2.Items.Add('検索します ... ...');
  end;
  if str <> '' then
  begin
    ListBox2.Items.Add('登録します');
    for var s in str.Split([',']) do
    begin
      if IsArch(s) then
        continue;
      cur := TPath.Combine(mainDir, s);
      for var fname in fileArray do
        for var ver in version do
        begin
          arch := TPath.Combine(fname, ver);
          text := s + '%s => ' + TPath.Combine(arch, s) + '%s';
          if not DirectoryExists(TPath.Combine(mainDir, arch)) then
            continue;
          if not DirectoryExists(cur) then
          begin
            New(obj);
            obj^.Key := cur;
            obj^.Value := TPath.Combine(mainDir, arch, s);
            ListBox2.Items.Add(TPath.Combine(mainDir, s));
            if FileExists(obj^.Key) then
              ListBox3.Items.AddObject(Format(text, ['', '']), Pointer(obj));
          end
          else
            for var t in GetSameFile(cur).Split([',']) do
            begin
              New(obj);
              obj^.Key := TPath.Combine(cur, t);
              obj^.Value := TPath.Combine(mainDir, arch, s, t);
              ListBox2.Items.Add(TPath.Combine(cur, t));
              if FileExists(obj^.Key) then
                ListBox3.Items.AddObject(Format(text, ['\' + t, '\' + t]),
                  Pointer(obj));
            end;
        end;
    end;
    ListBox3.Sorted := true;
    ListBox3.Sorted := false;
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

function TForm1.GetSameFile(const Name: string): string;
var
  rec: TSearchRec;
  i, data: integer;
  d: string;
begin
  result := '';
  if Name = mainDir then
  begin
    data := faDirectory;
    d := Name + '\*';
  end
  else
  begin
    data := faNormal;
    if FileExists(Name) then
      d := Name
    else
      d := Name + '\*.*';
  end;
  i := FindFirst(d, data, rec);
  try
    while i = 0 do
    begin
      if (data = faDirectory) and ((rec.Name = '.') or (rec.Name = '..')) then
      begin
        i := FindNext(rec);
        continue;
      end;
      if result = '' then
        result := rec.Name
      else
        result := result + ',' + rec.Name;
      if rec.Size > 4000000 then
        result := result + '(size_over)';
      i := FindNext(rec);
    end;
  finally
    FindClose(rec);
  end;
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
  obj: ^TPair<string, string>;
  dir: string;
  cnt: integer;
  bool: Boolean;
begin
  cnt := 0;
  bool := false;
  for var i := 0 to ListBox3.Count - 1 do
  begin
    Pointer(obj) := ListBox3.Items.Objects[i];
    dir := ExtractFileDir(obj^.Value);
    if not DirectoryExists(dir) then
      MkDir(dir);
    if not checkTimeStamp(obj^.Key, obj^.Value) and not bool then
    begin
      if MessageDlg('古いファイルで上書きします。それでも実行しますか？' + #13#10 + obj^.Value,
        TMsgDlgType.mtConfirmation, [mbOK, mbNO], 0, mbNO) = mrOK then
        bool := true
      else
        Exit;
    end;
  end;
  for var i := 0 to ListBox3.Count - 1 do
  begin
    Pointer(obj) := ListBox3.Items.Objects[i];
    CopyFile(PChar(obj^.Key), PChar(obj^.Value), false);
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

end.
