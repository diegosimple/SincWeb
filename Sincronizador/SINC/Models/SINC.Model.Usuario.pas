unit SINC.Model.Usuario;

{*******************************************************************************
  SINC - Model Usuario

  Representa a entidade USUARIOS do banco de dados local

  Autor: Sistema SINC
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.JSON, FireDAC.Comp.Client, Data.DB;

type
  TUsuario = class
  private
    FCodigo: Integer;
    FSenha: string;
    FHierarquia: Integer;
    FECaixa: string;
    FSupervisor: string;
    FAtivo: string;
    FUltimoPedido: Integer;
    FUltimaVenda: Integer;
    FSenhaApp: string;
    FAppSenha: string;
    FFKVendedor: Integer;
    FFlag: string;
    FLogin: string;
    FUsuMaster: string;

  public
    constructor Create;
    destructor Destroy; override;

    procedure FromDataSet(AQry: TFDQuery);
    procedure FromJSON(AJSON: TJSONObject);
    function ToJSON: TJSONObject;
    procedure Salvar;

    property Codigo: Integer read FCodigo write FCodigo;
    property Senha: string read FSenha write FSenha;
    property Hierarquia: Integer read FHierarquia write FHierarquia;
    property ECaixa: string read FECaixa write FECaixa;
    property Supervisor: string read FSupervisor write FSupervisor;
    property Ativo: string read FAtivo write FAtivo;
    property UltimoPedido: Integer read FUltimoPedido write FUltimoPedido;
    property UltimaVenda: Integer read FUltimaVenda write FUltimaVenda;
    property SenhaApp: string read FSenhaApp write FSenhaApp;
    property AppSenha: string read FAppSenha write FAppSenha;
    property FKVendedor: Integer read FFKVendedor write FFKVendedor;
    property Flag: string read FFlag write FFlag;
    property Login: string read FLogin write FLogin;
    property UsuMaster: string read FUsuMaster write FUsuMaster;
  end;

implementation

uses
  SINC.Services.UsuarioService;

{ TUsuario }

constructor TUsuario.Create;
begin
  inherited;
  FCodigo := 0;
  FSenha := '';
  FHierarquia := 0;
  FECaixa := 'N';
  FSupervisor := 'N';
  FAtivo := 'S';
  FUltimoPedido := 0;
  FUltimaVenda := 0;
  FSenhaApp := '';
  FAppSenha := '';
  FFKVendedor := 0;
  FFlag := '';
  FLogin := '';
  FUsuMaster := 'N';
end;

destructor TUsuario.Destroy;
begin
  inherited;
end;

procedure TUsuario.FromDataSet(AQry: TFDQuery);
begin
  if AQry.IsEmpty then
    Exit;

  FCodigo := AQry.FieldByName('CODIGO').AsInteger;

  if not AQry.FieldByName('SENHA').IsNull then
    FSenha := AQry.FieldByName('SENHA').AsString;

  if not AQry.FieldByName('HIERARQUIA').IsNull then
    FHierarquia := AQry.FieldByName('HIERARQUIA').AsInteger;

  if not AQry.FieldByName('ECAIXA').IsNull then
    FECaixa := AQry.FieldByName('ECAIXA').AsString;

  if not AQry.FieldByName('SUPERVISOR').IsNull then
    FSupervisor := AQry.FieldByName('SUPERVISOR').AsString;

  if not AQry.FieldByName('ATIVO').IsNull then
    FAtivo := AQry.FieldByName('ATIVO').AsString;

  if not AQry.FieldByName('ULTIMO_PEDIDO').IsNull then
    FUltimoPedido := AQry.FieldByName('ULTIMO_PEDIDO').AsInteger;

  if not AQry.FieldByName('ULTIMA_VENDA').IsNull then
    FUltimaVenda := AQry.FieldByName('ULTIMA_VENDA').AsInteger;

  if not AQry.FieldByName('SENHA_APP').IsNull then
    FSenhaApp := AQry.FieldByName('SENHA_APP').AsString;

  if not AQry.FieldByName('APP_SENHA').IsNull then
    FAppSenha := AQry.FieldByName('APP_SENHA').AsString;

  if not AQry.FieldByName('FK_VENDEDOR').IsNull then
    FFKVendedor := AQry.FieldByName('FK_VENDEDOR').AsInteger;

  if not AQry.FieldByName('FLAG').IsNull then
    FFlag := AQry.FieldByName('FLAG').AsString;

  if not AQry.FieldByName('LOGIN').IsNull then
    FLogin := AQry.FieldByName('LOGIN').AsString;

  if not AQry.FieldByName('USU_MASTER').IsNull then
    FUsuMaster := AQry.FieldByName('USU_MASTER').AsString;
end;

procedure TUsuario.FromJSON(AJSON: TJSONObject);
begin
  if not Assigned(AJSON) then
    Exit;

  if AJSON.TryGetValue<Integer>('codigo', FCodigo) then;
  if AJSON.TryGetValue<string>('senha', FSenha) then;
  if AJSON.TryGetValue<Integer>('hierarquia', FHierarquia) then;
  if AJSON.TryGetValue<string>('ecaixa', FECaixa) then;
  if AJSON.TryGetValue<string>('supervisor', FSupervisor) then;
  if AJSON.TryGetValue<string>('ativo', FAtivo) then;
  if AJSON.TryGetValue<Integer>('ultimo_pedido', FUltimoPedido) then;
  if AJSON.TryGetValue<Integer>('ultima_venda', FUltimaVenda) then;
  if AJSON.TryGetValue<string>('senha_app', FSenhaApp) then;
  if AJSON.TryGetValue<string>('app_senha', FAppSenha) then;
  if AJSON.TryGetValue<Integer>('fk_vendedor', FFKVendedor) then;
  if AJSON.TryGetValue<string>('flag', FFlag) then;
  if AJSON.TryGetValue<string>('login', FLogin) then;
  if AJSON.TryGetValue<string>('usu_master', FUsuMaster) then;
end;

function TUsuario.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('codigo', TJSONNumber.Create(FCodigo));
  Result.AddPair('senha', FSenha);
  Result.AddPair('hierarquia', TJSONNumber.Create(FHierarquia));
  Result.AddPair('ecaixa', FECaixa);
  Result.AddPair('supervisor', FSupervisor);
  Result.AddPair('ativo', FAtivo);
  Result.AddPair('ultimo_pedido', TJSONNumber.Create(FUltimoPedido));
  Result.AddPair('ultima_venda', TJSONNumber.Create(FUltimaVenda));
  Result.AddPair('senha_app', FSenhaApp);
  Result.AddPair('app_senha', FAppSenha);
  Result.AddPair('fk_vendedor', TJSONNumber.Create(FFKVendedor));
  Result.AddPair('flag', FFlag);
  Result.AddPair('login', FLogin);
  Result.AddPair('usu_master', FUsuMaster);
end;

procedure TUsuario.Salvar;
var
  Service: TUsuarioService;
begin
  Service := TUsuarioService.Create;
  try
    Service.SalvarOuAtualizar(Self);
  finally
    Service.Free;
  end;
end;

end.
