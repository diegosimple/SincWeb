unit SINC.Orquestracao.PedidoWeb;

{*******************************************************************************
  SINC - Camada de Pedido Web

  Responsável por processar pedidos vindos da API
  Fluxo: Baixar → Validar Cliente → Criar Orçamento → Criar Itens → Confirmar

  Autor: Sistema SINC
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.JSON, System.Generics.Collections,
  SINC.API.SincronizadorApi,
  SINC.Services.PessoaService, SINC.Services.OrcamentoService,
  SINC.Services.OrcamentoItemService,
  SINC.Model.Pessoa, SINC.Model.Orcamento, SINC.Model.OrcamentoItem;

type
  TLogProc = reference to procedure(const AMsg: string);

  TPedidoWeb = class
  private
    FAPI: TSincronizadorApi;
    FOnLog: TLogProc;

    procedure Log(const AMsg: string);
    function ValidarCliente(ACodigoWeb: Integer; out APessoa: TPessoa): Boolean;
    function CriarOrcamentoLocal(APedidoJSON: TJSONObject): Integer;
    function CriarItensLocal(ACodigoOrcamento: Integer; AItensJSON: TJSONArray): Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure BuscarPedidosPendentes;
    procedure ImportarPedido(APedidoJSON: TJSONObject);
    procedure ProcessarPedido(APedidoJSON: TJSONObject);

    property OnLog: TLogProc read FOnLog write FOnLog;
  end;

implementation

{ TPedidoWeb }

constructor TPedidoWeb.Create;
begin
  inherited;
  FAPI := TSincronizadorApi.Create;
end;

destructor TPedidoWeb.Destroy;
begin
  FAPI.Free;
  inherited;
end;

procedure TPedidoWeb.Log(const AMsg: string);
begin
  if Assigned(FOnLog) then
    FOnLog(AMsg);
end;

procedure TPedidoWeb.BuscarPedidosPendentes;
var
  PedidosJSON: TJSONArray;
  PedidoJSON: TJSONObject;
  I: Integer;
begin
  Log('=== BUSCANDO PEDIDOS PENDENTES ===');

  try
    PedidosJSON := FAPI.GetPedidosPendentes;

    if not Assigned(PedidosJSON) then
    begin
      Log('Nenhum pedido pendente encontrado');
      Exit;
    end;

    try
      Log(Format('Total de pedidos pendentes: %d', [PedidosJSON.Count]));

      for I := 0 to PedidosJSON.Count - 1 do
      begin
        PedidoJSON := PedidosJSON.Items[I] as TJSONObject;
        ProcessarPedido(PedidoJSON);
      end;

    finally
      PedidosJSON.Free;
    end;

  except
    on E: Exception do
      Log('Erro ao buscar pedidos: ' + E.Message);
  end;
end;

procedure TPedidoWeb.ImportarPedido(APedidoJSON: TJSONObject);
begin
  ProcessarPedido(APedidoJSON);
end;

procedure TPedidoWeb.ProcessarPedido(APedidoJSON: TJSONObject);
var
  CodigoWeb: Integer;
  CodigoOrcamento: Integer;
  ItensJSON: TJSONArray;
  Cliente: TPessoa;
begin
  if not Assigned(APedidoJSON) then
    Exit;

  try
    // Extrai código web do pedido
    if not APedidoJSON.TryGetValue<Integer>('codigo', CodigoWeb) then
    begin
      Log('Pedido sem código');
      Exit;
    end;

    Log(Format('--- Processando Pedido Web #%d ---', [CodigoWeb]));

    // 1. Verificar/Buscar Cliente
    if not ValidarCliente(CodigoWeb, Cliente) then
    begin
      Log('Erro ao validar cliente do pedido');
      Exit;
    end;

    try
      // 2. Criar Orçamento Local
      CodigoOrcamento := CriarOrcamentoLocal(APedidoJSON);
      if CodigoOrcamento = 0 then
      begin
        Log('Erro ao criar orçamento local');
        Exit;
      end;

      // 3. Criar Itens do Orçamento
      if APedidoJSON.TryGetValue<TJSONArray>('itens', ItensJSON) then
      begin
        if not CriarItensLocal(CodigoOrcamento, ItensJSON) then
        begin
          Log('Erro ao criar itens do orçamento');
          Exit;
        end;
      end;

      // 4. Confirmar para API que pedido foi sincronizado
      if FAPI.AtualizarStatusPedidoWeb(CodigoWeb, 'sincronizado') then
      begin
        Log(Format('Pedido #%d sincronizado com sucesso!', [CodigoWeb]));
      end
      else
      begin
        Log('Erro ao atualizar status do pedido na API');
      end;

    finally
      if Assigned(Cliente) then
        Cliente.Free;
    end;

  except
    on E: Exception do
      Log('Erro ao processar pedido: ' + E.Message);
  end;
end;

function TPedidoWeb.ValidarCliente(ACodigoWeb: Integer; out APessoa: TPessoa): Boolean;
var
  Service: TPessoaService;
  ClienteJSON: TJSONObject;
begin
  Result := False;
  APessoa := nil;

  Service := TPessoaService.Create;
  try
    // Tenta buscar cliente no BD local pelo código web
    APessoa := Service.BuscarPorCodigoWeb(ACodigoWeb);

    if Assigned(APessoa) then
    begin
      Log(Format('Cliente encontrado no BD local: %s', [APessoa.Fantasia]));
      Result := True;
      Exit;
    end;

    // Se não existe localmente, busca na API
    Log(Format('Cliente não encontrado localmente. Buscando na API...', []));

    try
      ClienteJSON := FAPI.BuscarPessoaPorCodigoWeb(ACodigoWeb);

      if not Assigned(ClienteJSON) then
      begin
        Log('Cliente não encontrado na API');
        Exit;
      end;

      try
        // Cria cliente local a partir do JSON
        APessoa := TPessoa.Create;
        APessoa.FromJSON(ClienteJSON);

        // Salva no banco local
        APessoa.Salvar;

        Log(Format('Cliente criado localmente: %s', [APessoa.Fantasia]));
        Result := True;

      finally
        ClienteJSON.Free;
      end;

    except
      on E: Exception do
      begin
        Log('Erro ao buscar cliente da API: ' + E.Message);
        if Assigned(APessoa) then
          FreeAndNil(APessoa);
      end;
    end;

  finally
    Service.Free;
  end;
end;

function TPedidoWeb.CriarOrcamentoLocal(APedidoJSON: TJSONObject): Integer;
var
  Service: TOrcamentoService;
  Orcamento: TOrcamento;
  CodigoWeb: Integer;
begin
  Result := 0;

  Service := TOrcamentoService.Create;
  try
    Orcamento := TOrcamento.Create;
    try
      // Preenche dados do orçamento a partir do JSON
      Orcamento.FromJSON(APedidoJSON);

      // Dados obrigatórios
      if APedidoJSON.TryGetValue<Integer>('codigo', CodigoWeb) then
        Orcamento.CodigoWeb := CodigoWeb;

      Orcamento.Data := Date;
      Orcamento.Situacao := 'A'; // Aberto

      // Salva orçamento
      Service.SalvarOuAtualizar(Orcamento);

      Result := Orcamento.Codigo;
      Log(Format('Orçamento local criado: #%d', [Result]));

    finally
      Orcamento.Free;
    end;

  finally
    Service.Free;
  end;
end;

function TPedidoWeb.CriarItensLocal(ACodigoOrcamento: Integer; AItensJSON: TJSONArray): Boolean;
var
  Service: TOrcamentoItemService;
  Item: TOrcamentoItem;
  ItemJSON: TJSONObject;
  I: Integer;
begin
  Result := False;

  if not Assigned(AItensJSON) then
  begin
    Log('Array de itens não fornecido');
    Exit;
  end;

  Service := TOrcamentoItemService.Create;
  try
    for I := 0 to AItensJSON.Count - 1 do
    begin
      ItemJSON := AItensJSON.Items[I] as TJSONObject;

      Item := TOrcamentoItem.Create;
      try
        Item.FromJSON(ItemJSON);
        Item.FKOrcamento := ACodigoOrcamento;
        Item.Item := I + 1;

        Service.SalvarOuAtualizar(Item);

        Log(Format('Item %d adicionado: %s', [Item.Item, Item.Descricao]));

      finally
        Item.Free;
      end;
    end;

    Result := True;
    Log(Format('%d item(ns) criado(s) com sucesso', [AItensJSON.Count]));

  finally
    Service.Free;
  end;
end;

end.
