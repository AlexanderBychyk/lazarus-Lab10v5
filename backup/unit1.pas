unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Grids, ActnList, Menus, Buttons;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    ComboBox1: TComboBox;
    Label1: TLabel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    LabeledEdit4: TLabeledEdit;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox1CloseUp(Sender: TObject);
    procedure ComboBox1DropDown(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure LabeledEdit1Enter(Sender: TObject);
    procedure LabeledEdit2Enter(Sender: TObject);
    procedure LabeledEdit3Enter(Sender: TObject);
    procedure LabeledEdit4Enter(Sender: TObject);
  private

  public

  end;

const sortLabel = 'Сортировка по';
type
  TDatabase = record
    id: integer;
    name: string[100];
    number: integer;
    hours: integer;
    rate: integer;
    payday: real;
  end;

var
  Form1: TForm1;
  F: file of TDatabase;
  A: array of TDatabase;
  i,n: integer;
  isSaved: boolean;
  nameFile: string;

implementation

{$R *.lfm}

{ TForm1 }
procedure setSortLabel(ComboBox1: TComboBox);
begin
  ComboBox1.Items.Insert(0, sortLabel);
  ComboBox1.ItemIndex := 0;
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
  setSortLabel(ComboBox1);
  isSaved:=true;
end;
procedure TForm1.ComboBox1CloseUp(Sender: TObject);
begin
  if ComboBox1.ItemIndex = -1 then setSortLabel(ComboBox1);
end;
procedure TForm1.ComboBox1DropDown(Sender: TObject);
begin
  if ComboBox1.Items[0] = sortLabel then begin
    ComboBox1.Items.Delete(0);
    ComboBox1.ItemIndex := -1;
  end;
end;


procedure renderStringGridHead(StringGrid: TStringGrid);
begin
  StringGrid.ColCount := 6;
  StringGrid.RowCount := 1;
  StringGrid.FixedRows := 1;

  StringGrid.Cells[0,0] := '№'; 
  StringGrid.Cells[1,0] := 'Ф.И.О.';
  StringGrid.Cells[2,0] := 'Табельный №';
  StringGrid.Cells[3,0] := 'Часы';
  StringGrid.Cells[4,0] := 'Тариф';  
  StringGrid.Cells[5,0] := 'Зарплата';
end;

 
procedure changeLabeledEditColor(LabeledEdit: TLabeledEdit);
begin
  LabeledEdit.Color:=clDefault;
end;
procedure TForm1.LabeledEdit1Enter(Sender: TObject);
begin
  changeLabeledEditColor(LabeledEdit1);
end;
procedure TForm1.LabeledEdit2Enter(Sender: TObject);
begin
  changeLabeledEditColor(LabeledEdit2);
end;
procedure TForm1.LabeledEdit3Enter(Sender: TObject);
begin
  changeLabeledEditColor(LabeledEdit3);
end;
procedure TForm1.LabeledEdit4Enter(Sender: TObject);
begin
  changeLabeledEditColor(LabeledEdit4);
end;
function checkLabeledEdit(LabeledEdit: TLabeledEdit): integer;
begin
  if (LabeledEdit.Text='') then begin
    LabeledEdit.Color:=clRed;
    checkLabeledEdit := 0;
  end
  else checkLabeledEdit := 1;
end;


//procedure testP(StringGrid: TStringGrid; sortIndex:integer);
//begin
//  StringGrid.SortColRow(true,0);
//end;


procedure setSave(button: Tbutton; bool: boolean);
begin
  button.Enabled := not bool;
  isSaved:=bool;
end;


procedure visibleHandler(StringGrid1:TStringGrid; Label1:TLabel;
                         LabeledEdit1, LabeledEdit2, LabeledEdit3,
                         LabeledEdit4: TLabeledEdit; Button1, Button4,
                         Button5: TButton; bool: boolean);
begin
  StringGrid1.Visible:=bool;
  Label1.Visible:=not bool;

  LabeledEdit1.Enabled := bool;
  LabeledEdit2.Enabled := bool;
  LabeledEdit3.Enabled := bool;
  LabeledEdit4.Enabled := bool;
  Button1.Enabled := bool; 
  Button4.Enabled := false;
  Button5.Enabled := bool;

  LabeledEdit1.Text := '';
  LabeledEdit2.Text := '';
  LabeledEdit3.Text := '';
  LabeledEdit4.Text := '';
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if(SaveDialog1.Execute) then begin
    nameFile:=SaveDialog1.FileName;
    assignFile(F,nameFile);
    reWrite(F);
    closeFile(F);

    visibleHandler(StringGrid1,Label1,LabeledEdit1,LabeledEdit2,
                   LabeledEdit3,LabeledEdit4,Button1,Button4,Button5,true);

    renderStringGridHead(StringGrid1);

    n:=-1; 
    isSaved:=true;
  end;
end;


procedure TForm1.Button1Click(Sender: TObject);
var checkCount: integer;
begin
  checkCount := 0;
  inc(checkCount,checkLabeledEdit(LabeledEdit1));
  inc(checkCount,checkLabeledEdit(LabeledEdit2));
  inc(checkCount,checkLabeledEdit(LabeledEdit3));
  inc(checkCount,checkLabeledEdit(LabeledEdit4));

  if (checkCount = 4) then begin
    inc(n,1);
    setLength(A, n+1);
    A[n].id := n+1;
    A[n].name := LabeledEdit1.Text;
    A[n].number := StrToInt(LabeledEdit2.Text);
    A[n].hours := StrToInt(LabeledEdit3.Text);
    A[n].rate := StrToInt(LabeledEdit4.Text);
    if (A[n].hours > 144) then begin
      A[n].payday := (A[n].hours*A[n].rate*2)-(A[n].hours*A[n].rate*2*0.12);
    end else begin
      A[n].payday := (A[n].hours*A[n].rate)-(A[n].hours*A[n].rate*0.12);
    end;

    StringGrid1.RowCount := n+2;
    StringGrid1.Cells[0,n+1] := intToStr(A[n].id);
    StringGrid1.Cells[1,n+1] := A[n].name;
    StringGrid1.Cells[2,n+1] := intToStr(A[n].number);
    StringGrid1.Cells[3,n+1] := intToStr(A[n].hours);
    StringGrid1.Cells[4,n+1] := intToStr(A[n].rate);
    StringGrid1.Cells[5,n+1] := floatToStr(A[n].payday);

    setSave(button4,false);
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var buttonIndex: integer;
begin
  if (isSaved = false) then begin
    buttonIndex := QuestionDlg('Внимание!','В файле есть не сохранённые изменения.'
                               +#10+'Вы уверены, что хотите закрыть?',
                               mtCustom, [mbYes,'Да',mbCancel,'Нет','IsDefault'],1);
    if buttonIndex = 0 then begin
      visibleHandler(StringGrid1,Label1,LabeledEdit1,
                     LabeledEdit2,LabeledEdit3,LabeledEdit4,
                     Button1,Button4,Button5,false);
    end;
  end else visibleHandler(StringGrid1,Label1,LabeledEdit1,
                          LabeledEdit2,LabeledEdit3,LabeledEdit4,
                          Button1,Button4,Button5,false);
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var index:integer;
begin
  index:=ComboBox1.ItemIndex;
  StringGrid1.SortColRow(true,index);
end;


procedure TForm1.Button4Click(Sender: TObject);
begin    
  assignFile(F,nameFile);
  reWrite(F);
  For i:=low(A) to high(A) do begin
    write(F, A[i]);
  end;
  closeFile(F);
  setSave(button4,true);
end;

procedure TForm1.Button3Click(Sender: TObject);
var buttonIndex: integer;
begin
  if (isSaved = false) then begin
    buttonIndex := QuestionDlg('Внимание!','В файле есть не сохранённые изменения.'
                               +#10+'Вы уверены, что хотите закрыть?',
                               mtCustom, [mbYes,'Да',mbCancel,'Нет','IsDefault'],1);
    if buttonIndex <> 0 then begin
      abort;
    end;
  end;

  if (OpenDialog1.Execute) then begin
        nameFile:=OpenDialog1.FileName;
        assignFile(F,nameFile);
        reSet(F);
      end;
      n:=-1;
      renderStringGridHead(StringGrid1);

      while not EOF(F) do begin
        inc(n,1);
        SetLength(A,n+1);
        read(F,A[n]);

        StringGrid1.RowCount := n+2;
        StringGrid1.Cells[0,n+1] := intToStr(A[n].id);
        StringGrid1.Cells[1,n+1] := A[n].name;
        StringGrid1.Cells[2,n+1] := intToStr(A[n].number);
        StringGrid1.Cells[3,n+1] := intToStr(A[n].hours);
        StringGrid1.Cells[4,n+1] := intToStr(A[n].rate);
        StringGrid1.Cells[5,n+1] := floatToStr(A[n].payday);
      end;

      visibleHandler(StringGrid1,Label1,LabeledEdit1,LabeledEdit2,
                     LabeledEdit3,LabeledEdit4,Button1,Button4,Button5,true);

      isSaved:=true;
      closeFile(F);
end;


procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var buttonIndex: integer;
begin
  if (isSaved = false) then begin
    buttonIndex := QuestionDlg('Внимание!','В файле есть не сохранённые изменения.'
                               +#10+'Вы уверены, что хотите закрыть?',
                               mtCustom, [mbYes,'Да',mbCancel,'Нет','IsDefault'],1);
    if buttonIndex <> 0 then begin
      abort;
    end;
  end;
end;

end.

