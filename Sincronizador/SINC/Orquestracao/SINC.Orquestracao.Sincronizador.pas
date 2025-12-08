unit SINC.Orquestracao.Sincronizador;

{*******************************************************************************
  SINC - Camada de Orquestração

  Controla o processo de sincronização bidirecional
  Coordena Services e API para garantir integridade dos dados

  Autor: Sistema SINC
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.JSON, System.Generics.Collections,
  SINC.API.SincronizadorApi,
  SINC.Services.EmpresaService, SINC.Services.UsuarioService,
  SINC.Services.PessoaService, SINC.Services.FormaPagamentoService,
  SINC.Services.VendedorService, SINC.Services.OrcamentoService,
  SINC.Services.OrcamentoItemService,
  SINC.Model.Empresa, SINC.Model.Usuario, SINC.Model.Pessoa,
  SINC.Model.FormaPagamento, SINC.Model.Vendedor,
  SINC.Model.Orcamento, SINC.Model.OrcamentoItem;

type
  TLogProc = reference to procedure(const AMsg: string);

  TSincronizador = class
  private
    FAPI: TSincronizadorApi;
    FOnLog: TLogProc;

    procedure Log(const AMsg: string);

  public
    constructor Create;
    destructor Destroy; override;

    // Métodos de ENVIO (Local → API)
    procedure EnviarEmpresa;
    procedure EnviarUsuarios;
    procedure EnviarPessoas;
    procedure EnviarFormasPagamento;
    procedure EnviarVendedores;
    procedure EnviarOrcamentos;

    // Métodos de RECEBIMENTO (API → Local)
    procedure ReceberClientes;
    procedure ReceberPedidosWeb;
    procedure ReceberFormasPagamento;

    // Sincronização completa
    procedure SincronizarEnvio;
    procedure SincronizarRecebimento;
    procedure SincronizarTudo;

    // Reset
    procedure ResetEmpresaNaAPI;

    property OnLog: TLogProc read FOnLog write FOnLog;
  end;

implementation

uses
  SINC.Orquestracao.PedidoWeb;

{ TSincronizador }

constructor TSincronizador.Create;
begin
  inherited;
  FAPI := TSincronizadorApi.Create;
end;

destructor TSincronizador.Destroy;
begin
  FAPI.Free;
  inherited;
end;

procedure TSincronizador.Log(const AMsg: string);
begin
  if Assigned(FOnLog) then
    FOnLog(AMsg);
end;

procedure TSincronizador.EnviarEmpresa;
var
  Service: TEmpresaService;
  Empresas: TObjectList<TEmpresa>;
  Empresa: TEmpresa;
begin
  Log('=== ENVIANDO EMPRESAS ===');

  Service := TEmpresaService.Create;
  try
    Empresas := Service.ListarParaEnvio;
    try
      if Empresas.Count = 0 then
      begin
        Log('Nenhuma empresa para enviar');
        Exit;
      end;

      for Empresa in Empresas do
      begin
        try
          Log(Format('Enviando empresa: %s', [Empresa.Fantasia]));

          if FAPI.EnviarEmpresa(Empresa) then
          begin
            // Marca como sincronizado
            Empresa.Flag := 'S';
            Service.SalvarOuAtualizar(Empresa);
            Log('Empresa enviada com sucesso');
          end
          else
            Log('Erro ao enviar empresa');

        except
          on E: Exception do
            Log('Erro: ' + E.Message);
        end;
      end;

    finally
      Empresas.Free;
    end;

  finally
    Service.Free;
  end;
end;

procedure TSincronizador.EnviarUsuarios;
var
  Service: TUsuarioService;
  Usuarios: TObjectList<TUsuario>;
  Usuario: TUsuario;
begin
  Log('=== ENVIANDO USUÁRIOS ===');

  Service := TUsuarioService.Create;
  try
    Usuarios := Service.ListarParaEnvio;
    try
      if Usuarios.Count = 0 then
      begin
        Log('Nenhum usuário para enviar');
        Exit;
      end;

      for Usuario in Usuarios do
      begin
        try
          Log(Format('Enviando usuário: %s', [Usuario.Login]));

          if FAPI.EnviarUsuario(Usuario) then
          begin
            Usuario.Flag := 'S';
            Service.SalvarOuAtualizar(Usuario);
            Log('Usuário enviado com sucesso');
          end
          else
            Log('Erro ao enviar usuário');

        except
          on E: Exception do
            Log('Erro: ' + E.Message);
        end;
      end;

    finally
      Usuarios.Free;
    end;

  finally
    Service.Free;
  end;
end;

procedure TSincronizador.EnviarPessoas;
var
  Service: TPessoaService;
  Pessoas: TObjectList<TPessoa>;
  Pessoa: TPessoa;
begin
  Log('=== ENVIANDO CLIENTES ===');

  Service := TPessoaService.Create;
  try
    Pessoas := Service.ListarParaEnvio;
    try
      if Pessoas.Count = 0 then
      begin
        Log('Nenhum cliente para enviar');
        Exit;
      end;

      for Pessoa in Pessoas do
      begin
        try
          Log(Format('Enviando cliente: %s', [Pessoa.Fantasia]));

          if FAPI.EnviarPessoa(Pessoa) then
          begin
            Pessoa.Flag := 'S';
            Service.SalvarOuAtualizar(Pessoa);
            Log('Cliente enviado com sucesso');
          end
          else
            Log('Erro ao enviar cliente');

        except
          on E: Exception do
            Log('Erro: ' + E.Message);
        end;
      end;

    finally
      Pessoas.Free;
    end;

  finally
    Service.Free;
  end;
end;

procedure TSincronizador.EnviarFormasPagamento;
var
  Service: TFormaPagamentoService;
  Formas: TObjectList<TFormaPagamento>;
  Forma: TFormaPagamento;
begin
  Log('=== ENVIANDO FORMAS DE PAGAMENTO ===');

  Service := TFormaPagamentoService.Create;
  try
    Formas := Service.ListarParaEnvio;
    try
      if Formas.Count = 0 then
      begin
        Log('Nenhuma forma de pagamento para enviar');
        Exit;
      end;

      for Forma in Formas do
      begin
        try
          Log(Format('Enviando forma de pagamento: %s', [Forma.Descricao]));

          if FAPI.EnviarFormaPagamento(Forma) then
            Log('Forma de pagamento enviada com sucesso')
          else
            Log('Erro ao enviar forma de pagamento');

        except
          on E: Exception do
            Log('Erro: ' + E.Message);
        end;
      end;

    finally
      Formas.Free;
    end;

  finally
    Service.Free;
  end;
end;

procedure TSincronizador.EnviarVendedores;
var
  Service: TVendedorService;
  Vendedores: TObjectList<TVendedor>;
  Vendedor: TVendedor;
begin
  Log('=== ENVIANDO VENDEDORES ===');

  Service := TVendedorService.Create;
  try
    Vendedores := Service.ListarParaEnvio;
    try
      if Vendedores.Count = 0 then
      begin
        Log('Nenhum vendedor para enviar');
        Exit;
      end;

      for Vendedor in Vendedores do
      begin
        try
          Log(Format('Enviando vendedor: %s', [Vendedor.Nome]));

          if FAPI.EnviarVendedor(Vendedor) then
          begin
            Vendedor.Flag := 'S';
            Service.SalvarOuAtualizar(Vendedor);
            Log('Vendedor enviado com sucesso');
          end
          else
            Log('Erro ao enviar vendedor');

        except
          on E: Exception do
            Log('Erro: ' + E.Message);
        end;
      end;

    finally
      Vendedores.Free;
    end;

  finally
    Service.Free;
  end;
end;

procedure TSincronizador.EnviarOrcamentos;
var
  ServiceOrc: TOrcamentoService;
  ServiceItem: TOrcamentoItemService;
  Orcamentos: TObjectList<TOrcamento>;
  Orcamento: TOrcamento;
  Itens: TObjectList<TOrcamentoItem>;
begin
  Log('=== ENVIANDO ORÇAMENTOS ===');

  ServiceOrc := TOrcamentoService.Create;
  ServiceItem := TOrcamentoItemService.Create;
  try
    Orcamentos := ServiceOrc.ListarParaEnvio;
    try
      if Orcamentos.Count = 0 then
      begin
        Log('Nenhum orçamento para enviar');
        Exit;
      end;

      for Orcamento in Orcamentos do
      begin
        try
          Log(Format('Enviando orçamento #%d', [Orcamento.Codigo]));

          // Busca itens do orçamento
          Itens := ServiceItem.ListarPorOrcamento(Orcamento.Codigo);
          try
            if FAPI.EnviarOrcamento(Orcamento, Itens) then
            begin
              // Marca como sincronizado
              ServiceOrc.SalvarOuAtualizar(Orcamento);
              Log('Orçamento enviado com sucesso');
            end
            else
              Log('Erro ao enviar orçamento');

          finally
            Itens.Free;
          end;

        except
          on E: Exception do
            Log('Erro: ' + E.Message);
        end;
      end;

    finally
      Orcamentos.Free;
    end;

  finally
    ServiceOrc.Free;
    ServiceItem.Free;
  end;
end;

procedure TSincronizador.ReceberClientes;
var
  Service: TPessoaService;
  JSONArray: TJSONArray;
  JSONObj: TJSONObject;
  Pessoa: TPessoa;
  I: Integer;
begin
  Log('=== RECEBENDO CLIENTES DA API ===');

  Service := TPessoaService.Create;
  try
    JSONArray := FAPI.ReceberPessoas;
    if not Assigned(JSONArray) then
    begin
      Log('Nenhum cliente recebido da API');
      Exit;
    end;

    try
      for I := 0 to JSONArray.Count - 1 do
      begin
        JSONObj := JSONArray.Items[I] as TJSONObject;

        Pessoa := TPessoa.Create;
        try
          // JSON → Model
          Pessoa.FromJSON(JSONObj);

          // Verifica se já existe
          if Service.Existe(Pessoa.Empresa, Pessoa.Codigo) then
          begin
            Log(Format('Atualizando cliente: %s', [Pessoa.Fantasia]));
          end
          else
          begin
            Log(Format('Criando novo cliente: %s', [Pessoa.Fantasia]));
          end;

          // Model → BD
          Service.SalvarOuAtualizar(Pessoa);

        finally
          Pessoa.Free;
        end;
      end;

      Log(Format('%d cliente(s) recebido(s)', [JSONArray.Count]));

    finally
      JSONArray.Free;
    end;

  finally
    Service.Free;
  end;
end;

procedure TSincronizador.ReceberPedidosWeb;
var
  PedidoWeb: TPedidoWeb;
begin
  Log('=== RECEBENDO PEDIDOS WEB ===');

  PedidoWeb := TPedidoWeb.Create;
  try
    PedidoWeb.OnLog := FOnLog;
    PedidoWeb.BuscarPedidosPendentes;
  finally
    PedidoWeb.Free;
  end;
end;

procedure TSincronizador.ReceberFormasPagamento;
var
  Service: TFormaPagamentoService;
  JSONArray: TJSONArray;
  JSONObj: TJSONObject;
  Forma: TFormaPagamento;
  I: Integer;
begin
  Log('=== RECEBENDO FORMAS DE PAGAMENTO ===');

  Service := TFormaPagamentoService.Create;
  try
    JSONArray := FAPI.ReceberFormasPagamento;
    if not Assigned(JSONArray) then
    begin
      Log('Nenhuma forma de pagamento recebida da API');
      Exit;
    end;

    try
      for I := 0 to JSONArray.Count - 1 do
      begin
        JSONObj := JSONArray.Items[I] as TJSONObject;

        Forma := TFormaPagamento.Create;
        try
          Forma.FromJSON(JSONObj);

          if Service.Existe(Forma.Codigo) then
            Log(Format('Atualizando forma de pagamento: %s', [Forma.Descricao]))
          else
            Log(Format('Criando nova forma de pagamento: %s', [Forma.Descricao]));

          Service.SalvarOuAtualizar(Forma);

        finally
          Forma.Free;
        end;
      end;

      Log(Format('%d forma(s) de pagamento recebida(s)', [JSONArray.Count]));

    finally
      JSONArray.Free;
    end;

  finally
    Service.Free;
  end;
end;

procedure TSincronizador.SincronizarEnvio;
begin
  Log('╔═══════════════════════════════════════╗');
  Log('║  INICIANDO SINCRONIZAÇÃO DE ENVIO     ║');
  Log('╚═══════════════════════════════════════╝');

  try
    EnviarEmpresa;
    EnviarUsuarios;
    EnviarVendedores;
    EnviarFormasPagamento;
    EnviarPessoas;
    EnviarOrcamentos;

    Log('╔═══════════════════════════════════════╗');
    Log('║  ENVIO FINALIZADO COM SUCESSO         ║');
    Log('╚═══════════════════════════════════════╝');

  except
    on E: Exception do
    begin
      Log('ERRO NO ENVIO: ' + E.Message);
      raise;
    end;
  end;
end;

procedure TSincronizador.SincronizarRecebimento;
begin
  Log('╔═══════════════════════════════════════╗');
  Log('║  INICIANDO SINCRONIZAÇÃO DE RECEBIMENTO║');
  Log('╚═══════════════════════════════════════╝');

  try
    ReceberClientes;
    ReceberFormasPagamento;
    ReceberPedidosWeb;

    Log('╔═══════════════════════════════════════╗');
    Log('║  RECEBIMENTO FINALIZADO COM SUCESSO   ║');
    Log('╚═══════════════════════════════════════╝');

  except
    on E: Exception do
    begin
      Log('ERRO NO RECEBIMENTO: ' + E.Message);
      raise;
    end;
  end;
end;

procedure TSincronizador.SincronizarTudo;
begin
  Log('╔═══════════════════════════════════════╗');
  Log('║  SINCRONIZAÇÃO COMPLETA INICIADA      ║');
  Log('╚═══════════════════════════════════════╝');

  SincronizarEnvio;
  SincronizarRecebimento;

  Log('╔═══════════════════════════════════════╗');
  Log('║  SINCRONIZAÇÃO COMPLETA FINALIZADA    ║');
  Log('╚═══════════════════════════════════════╝');
end;

procedure TSincronizador.ResetEmpresaNaAPI;
begin
  Log('=== RESETANDO EMPRESA NA API ===');

  try
    if FAPI.ResetEmpresa then
      Log('Empresa resetada com sucesso na API')
    else
      Log('Erro ao resetar empresa na API');

  except
    on E: Exception do
      Log('Erro: ' + E.Message);
  end;
end;

end.
