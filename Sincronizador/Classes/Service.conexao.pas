unit Service.conexao;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.UI,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.FB,
  System.IniFiles, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet,
  Provider.constants, u.Conexao;

type
  TServiceConexao = class(TDataModule)
    FDConn: TFDConnection;
    Cursor: TFDGUIxWaitCursor;
    FBDriverLinkService: TFDPhysFBDriverLink;
    Qry_Filial: TFDQuery;
    Qry_FilialRAZAO_SOCIAL: TStringField;
    Qry_FilialCNPJ: TStringField;
    Qry_FilialID: TIntegerField;

    procedure DataModuleCreate(Sender: TObject);
    procedure FBDriverLinkServiceDriverCreated(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ServiceConexao: TServiceConexao;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TServiceConexao.DataModuleCreate(Sender: TObject);

begin

   FDConn.Connected := False;
   //dados da empresa

   Qry_Filial.Close;
   Qry_Filial.Params[0].AsInteger := 1;
   Qry_Filial.Open();

   iCOD_FILIAL   := Qry_FilialID.AsInteger;
   sRAZAO_FILIAL := Qry_FilialRAZAO_SOCIAL.AsString;

end;


procedure TServiceConexao.FBDriverLinkServiceDriverCreated(Sender: TObject);
var
LConexao: TConexao;
begin
  inherited;
     LConexao := TConexao.Create(Self);
     FBDriverLinkService.VendorHome := ExtractFileDir(ParamStr(0)) +  '\dlls\';
   //  FBDriverLinkService.VendorLib := 'fbclient25.dll';  // para Firebird 2.5
     FBDriverLinkService.VendorLib := 'fbclient50.dll';  // para Firebird 5.0
       try
       LConexao.GetConfigConnection(FDConn);
       finally
         FreeAndNil(LConexao);
       end;
end;

end.
