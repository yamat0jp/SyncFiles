object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'SyncFiles'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object ListBox1: TListBox
    Left = 0
    Top = 0
    Width = 624
    Height = 121
    Align = alTop
    ItemHeight = 15
    TabOrder = 0
    OnKeyDown = ListBox1KeyDown
  end
  object Panel1: TPanel
    Left = 0
    Top = 121
    Width = 624
    Height = 320
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 1
    object ListBox2: TListBox
      Left = 1
      Top = 42
      Width = 500
      Height = 277
      Align = alLeft
      ItemHeight = 15
      TabOrder = 0
    end
    object ListBox3: TListBox
      Left = 501
      Top = 42
      Width = 122
      Height = 277
      Align = alClient
      ItemHeight = 15
      TabOrder = 1
    end
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 622
      Height = 41
      Align = alTop
      TabOrder = 2
      object Label1: TLabel
        Left = 24
        Top = 20
        Width = 50
        Height = 15
        Caption = #12513#12483#12475#12540#12472
      end
    end
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileName = 'C:\Users\yamat\Documents\GitHub\SyncFiles'
    FileTypes = <
      item
        DisplayName = #23455#34892#12501#12449#12452#12523
        FileMask = '*.dpr;*.dproj'
      end
      item
        DisplayName = #12377#12409#12390#12398#12501#12449#12452#12523
        FileMask = '*.*'
      end>
    Options = []
    Title = #23550#35937#12450#12503#12522#12398#36984#25246
    Left = 200
    Top = 192
  end
  object MainMenu1: TMainMenu
    Left = 464
    Top = 168
    object N1: TMenuItem
      Caption = #30331#37682
      OnClick = N1Click
    end
    object N4: TMenuItem
      Caption = #20877#26908#32034
      OnClick = N4Click
    end
    object N5: TMenuItem
      Caption = #23455#34892
      OnClick = N5Click
    end
    object N6: TMenuItem
      Caption = #34920#31034
      OnClick = N6Click
    end
    object N3: TMenuItem
      Caption = #36984#25246#23455#34892
      OnClick = N3Click
    end
    object N2: TMenuItem
      Caption = #32066#20102
      OnClick = N2Click
    end
  end
end
