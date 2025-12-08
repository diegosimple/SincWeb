unit SINC.API.SincronizadorApi;

{*******************************************************************************
  SINC - Camada de API

  Responsável por comunicação HTTP com a API PHP usando RESTRequest4D
  NUNCA envia DataSet diretamente - sempre converte Model → JSON

  Autor: Sistema SINC
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.JSON, System.Generics.Collections, System.IniFiles,
  RESTRequest4D,
  SINC.Model.Empresa, SINC.Model.Usuario, SINC.Model.Pessoa,
  SINC.Model.FormaPagamento, SINC.Model.Vendedor,
  SINC.Model.Orcamento, SINC.Model.OrcamentoItem;

type
  TSincronizadorApi = class
  private
    FEndpoint: string;
    FChaveAPI: string;

    procedure CarregarConfiguracao;
    function DoRequest(AMetodo, ARota: string; ABody: TJSONObject = nil): IResponse;
    function DoRequestGET(ARota: string): IResponse;
    function DoRequestPOST(ARota: string; ABody: TJSONObject): IResponse;
    function DoRequestPUT(ARota: string; ABody: TJSONObject): IResponse;
    function DoRequestDELETE(ARota: string): IResponse;

  public
    constructor Create;
    destructor Destroy; override;

    // Empresa
    function EnviarEmpresa(AEmpresa: TEmpresa): Boolean;
    function ReceberEmpresa: TJSONObject;

    // Usuário
    function EnviarUsuario(AUsuario: TUsuario): Boolean;
    function ReceberUsuarios: TJSONArray;

    // Clientes / Pessoas
    function EnviarPessoa(APessoa: TPessoa): Boolean;
    function AtualizarPessoa(APessoa: TPessoa): Boolean;
    function ReceberPessoas: TJSONArray;
    function BuscarPessoaPorCodigoWeb(ACodigoWeb: Integer): TJSONObject;

    // Forma de Pagamento
    function EnviarFormaPagamento(AFormaPagamento: TFormaPagamento): Boolean;
    function ReceberFormasPagamento: TJSONArray;

    // Vendedores
    function EnviarVendedor(AVendedor: TVendedor): Boolean;

    // Orçamento
    function EnviarOrcamento(AOrcamento: TOrcamento; AItens: TObjectList<TOrcamentoItem>): Boolean;
    function ReceberOrcamentos: TJSONArray;

    // Pedidos Web
    function GetPedidosPendentes: TJSONArray;
    function AtualizarStatusPedidoWeb(ACodigoWeb: Integer; AStatus: string): Boolean;

    // Reset
    function ResetEmpresa: Boolean;

    // Teste de conexão
    function TestarConexao: Boolean;

    property Endpoint: string read FEndpoint write FEndpoint;
    property ChaveAPI: string read FChaveAPI write FChaveAPI;
  end;

implementation

{ TSincronizadorApi }

constructor TSincronizadorApi.Create;
begin
  inherited;
  CarregarConfiguracao;
end;

destructor TSincronizadorApi.Destroy;
begin
  inherited;
end;

procedure TSincronizadorApi.CarregarConfiguracao;
var
  Ini: TIniFile;
  IniFile: string;
begin
  IniFile := ExtractFilePath(ParamStr(0)) + 'Sincronizador.ini';

  if not FileExists(IniFile) then
    raise Exception.Create('Arquivo de configuração não encontrado: ' + IniFile);

  Ini := TIniFile.Create(IniFile);
  try
    FEndpoint := Ini.ReadString('API', 'Endpoint', '');
    FChaveAPI := Ini.ReadString('API', 'ChaveAPI', '');

    if FEndpoint = '' then
      raise Exception.Create('Endpoint da API não configurado no INI');

    if FChaveAPI = '' then
      raise Exception.Create('Chave da API não configurada no INI');

    // Remove barra final se existir
    if FEndpoint.EndsWith('/') then
      FEndpoint := FEndpoint.Substring(0, FEndpoint.Length - 1);

  finally
    Ini.Free;
  end;
end;

function TSincronizadorApi.DoRequest(AMetodo, ARota: string; ABody: TJSONObject): IResponse;
var
  Request: IRequest;
begin
  Request := TRequest.New.BaseURL(FEndpoint + ARota)
    .Accept('application/json')
    .AddHeader('X-API-KEY', FChaveAPI)
    .Timeout(30000);

  case IndexStr(AMetodo, ['GET', 'POST', 'PUT', 'DELETE']) of
    0: Result := Request.Get;
    1: Result := Request.AddBody(ABody.ToString).Post;
    2: Result := Request.AddBody(ABody.ToString).Put;
    3: Result := Request.Delete;
  else
    raise Exception.Create('Método HTTP inválido: ' + AMetodo);
  end;
end;

function TSincronizadorApi.DoRequestGET(ARota: string): IResponse;
begin
  Result := DoRequest('GET', ARota);
end;

function TSincronizadorApi.DoRequestPOST(ARota: string; ABody: TJSONObject): IResponse;
begin
  Result := DoRequest('POST', ARota, ABody);
end;

function TSincronizadorApi.DoRequestPUT(ARota: string; ABody: TJSONObject): IResponse;
begin
  Result := DoRequest('PUT', ARota, ABody);
end;

function TSincronizadorApi.DoRequestDELETE(ARota: string): IResponse;
begin
  Result := DoRequest('DELETE', ARota);
end;

function TSincronizadorApi.EnviarEmpresa(AEmpresa: TEmpresa): Boolean;
var
  Response: IResponse;
  Body: TJSONObject;
begin
  Result := False;

  if not Assigned(AEmpresa) then
    raise Exception.Create('Empresa não pode ser nula');

  // Model → JSON (NUNCA DataSet → API)
  Body := AEmpresa.ToJSON;
  try
    Response := DoRequestPOST('/empresa', Body);
    Result := (Response.StatusCode = 200) or (Response.StatusCode = 201);
  finally
    Body.Free;
  end;
end;

function TSincronizadorApi.ReceberEmpresa: TJSONObject;
var
  Response: IResponse;
begin
  Result := nil;
  Response := DoRequestGET('/empresa');

  if Response.StatusCode = 200 then
  begin
    Result := TJSONObject.ParseJSONValue(Response.Content) as TJSONObject;
  end
  else
    raise Exception.Create('Erro ao receber empresa: ' + Response.Content);
end;

function TSincronizadorApi.EnviarUsuario(AUsuario: TUsuario): Boolean;
var
  Response: IResponse;
  Body: TJSONObject;
begin
  Result := False;

  if not Assigned(AUsuario) then
    raise Exception.Create('Usuário não pode ser nulo');

  Body := AUsuario.ToJSON;
  try
    Response := DoRequestPOST('/usuarios', Body);
    Result := (Response.StatusCode = 200) or (Response.StatusCode = 201);
  finally
    Body.Free;
  end;
end;

function TSincronizadorApi.ReceberUsuarios: TJSONArray;
var
  Response: IResponse;
begin
  Result := nil;
  Response := DoRequestGET('/usuarios');

  if Response.StatusCode = 200 then
  begin
    Result := TJSONObject.ParseJSONValue(Response.Content) as TJSONArray;
  end;
end;

function TSincronizadorApi.EnviarPessoa(APessoa: TPessoa): Boolean;
var
  Response: IResponse;
  Body: TJSONObject;
begin
  Result := False;

  if not Assigned(APessoa) then
    raise Exception.Create('Pessoa não pode ser nula');

  Body := APessoa.ToJSON;
  try
    Response := DoRequestPOST('/clientes', Body);
    Result := (Response.StatusCode = 200) or (Response.StatusCode = 201);
  finally
    Body.Free;
  end;
end;

function TSincronizadorApi.AtualizarPessoa(APessoa: TPessoa): Boolean;
var
  Response: IResponse;
  Body: TJSONObject;
begin
  Result := False;

  if not Assigned(APessoa) then
    raise Exception.Create('Pessoa não pode ser nula');

  Body := APessoa.ToJSON;
  try
    Response := DoRequestPUT('/clientes/' + APessoa.CodigoWeb.ToString, Body);
    Result := (Response.StatusCode = 200);
  finally
    Body.Free;
  end;
end;

function TSincronizadorApi.ReceberPessoas: TJSONArray;
var
  Response: IResponse;
begin
  Result := nil;
  Response := DoRequestGET('/clientes');

  if Response.StatusCode = 200 then
  begin
    Result := TJSONObject.ParseJSONValue(Response.Content) as TJSONArray;
  end;
end;

function TSincronizadorApi.BuscarPessoaPorCodigoWeb(ACodigoWeb: Integer): TJSONObject;
var
  Response: IResponse;
begin
  Result := nil;
  Response := DoRequestGET('/clientes/' + ACodigoWeb.ToString);

  if Response.StatusCode = 200 then
  begin
    Result := TJSONObject.ParseJSONValue(Response.Content) as TJSONObject;
  end;
end;

function TSincronizadorApi.EnviarFormaPagamento(AFormaPagamento: TFormaPagamento): Boolean;
var
  Response: IResponse;
  Body: TJSONObject;
begin
  Result := False;

  if not Assigned(AFormaPagamento) then
    raise Exception.Create('Forma de Pagamento não pode ser nula');

  Body := AFormaPagamento.ToJSON;
  try
    Response := DoRequestPOST('/formas-pagamento', Body);
    Result := (Response.StatusCode = 200) or (Response.StatusCode = 201);
  finally
    Body.Free;
  end;
end;

function TSincronizadorApi.ReceberFormasPagamento: TJSONArray;
var
  Response: IResponse;
begin
  Result := nil;
  Response := DoRequestGET('/formas-pagamento');

  if Response.StatusCode = 200 then
  begin
    Result := TJSONObject.ParseJSONValue(Response.Content) as TJSONArray;
  end;
end;

function TSincronizadorApi.EnviarVendedor(AVendedor: TVendedor): Boolean;
var
  Response: IResponse;
  Body: TJSONObject;
begin
  Result := False;

  if not Assigned(AVendedor) then
    raise Exception.Create('Vendedor não pode ser nulo');

  Body := AVendedor.ToJSON;
  try
    Response := DoRequestPOST('/vendedores', Body);
    Result := (Response.StatusCode = 200) or (Response.StatusCode = 201);
  finally
    Body.Free;
  end;
end;

function TSincronizadorApi.EnviarOrcamento(AOrcamento: TOrcamento;
  AItens: TObjectList<TOrcamentoItem>): Boolean;
var
  Response: IResponse;
  Body, OrcamentoJSON: TJSONObject;
  ItensArray: TJSONArray;
  I: Integer;
begin
  Result := False;

  if not Assigned(AOrcamento) then
    raise Exception.Create('Orçamento não pode ser nulo');

  OrcamentoJSON := AOrcamento.ToJSON;
  try
    // Adiciona itens ao JSON do orçamento
    ItensArray := TJSONArray.Create;
    if Assigned(AItens) then
    begin
      for I := 0 to AItens.Count - 1 do
      begin
        ItensArray.AddElement(AItens[I].ToJSON);
      end;
    end;

    OrcamentoJSON.AddPair('itens', ItensArray);

    Response := DoRequestPOST('/orcamentos', OrcamentoJSON);
    Result := (Response.StatusCode = 200) or (Response.StatusCode = 201);

  finally
    OrcamentoJSON.Free;
  end;
end;

function TSincronizadorApi.ReceberOrcamentos: TJSONArray;
var
  Response: IResponse;
begin
  Result := nil;
  Response := DoRequestGET('/orcamentos');

  if Response.StatusCode = 200 then
  begin
    Result := TJSONObject.ParseJSONValue(Response.Content) as TJSONArray;
  end;
end;

function TSincronizadorApi.GetPedidosPendentes: TJSONArray;
var
  Response: IResponse;
begin
  Result := nil;
  Response := DoRequestGET('/pedidos/pendentes');

  if Response.StatusCode = 200 then
  begin
    Result := TJSONObject.ParseJSONValue(Response.Content) as TJSONArray;
  end;
end;

function TSincronizadorApi.AtualizarStatusPedidoWeb(ACodigoWeb: Integer; AStatus: string): Boolean;
var
  Response: IResponse;
  Body: TJSONObject;
begin
  Result := False;

  Body := TJSONObject.Create;
  try
    Body.AddPair('status', AStatus);
    Response := DoRequestPUT('/pedidos/' + ACodigoWeb.ToString + '/status', Body);
    Result := (Response.StatusCode = 200);
  finally
    Body.Free;
  end;
end;

function TSincronizadorApi.ResetEmpresa: Boolean;
var
  Response: IResponse;
begin
  Result := False;

  try
    Response := DoRequestDELETE('/empresa/reset');
    Result := (Response.StatusCode = 200) or (Response.StatusCode = 204);
  except
    on E: Exception do
      raise Exception.Create('Erro ao resetar empresa: ' + E.Message);
  end;
end;

function TSincronizadorApi.TestarConexao: Boolean;
var
  Response: IResponse;
begin
  Result := False;

  try
    Response := DoRequestGET('/ping');
    Result := (Response.StatusCode = 200);
  except
    on E: Exception do
      Result := False;
  end;
end;

end.
