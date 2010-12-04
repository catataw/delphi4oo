object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'frmPrincipal'
  ClientHeight = 223
  ClientWidth = 426
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object salvar: TButton
    Left = 118
    Top = 168
    Width = 75
    Height = 25
    Caption = 'salvar'
    TabOrder = 0
    OnClick = salvarClick
  end
  object Edit1: TEdit
    Left = 56
    Top = 32
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
  end
  object Edit2: TEdit
    Left = 56
    Top = 72
    Width = 121
    Height = 21
    TabOrder = 2
    Text = 'Edit2'
  end
  object Edit3: TEdit
    Left = 56
    Top = 112
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 'Edit3'
  end
end
