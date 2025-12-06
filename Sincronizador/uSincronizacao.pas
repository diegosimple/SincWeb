unit uSincronizacao;

{*******************************************************************************
  CONTROLADOR DE SINCRONIZAÇÃO

  Responsável por:
  - Orquestrar envio e recebimento de dados
  - Gerenciar progress bar
  - Emitir eventos de log
  - Controlar transações

  Autor: Sistema FSVendas
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.Classes, Vcl.ComCtrls, Data.DB,
  FireDAC.Comp.Client, uSincronizadorApi, uConfiguracao, uLogSistema;

type
  TProgressEvent = procedure(ATotal, AAtual: Integer; const AMensagem: string) of object;

  TControladorSincronizacao = class
  private
    FApi: TSincronizadorApi;
    FConfig: TConfiguracao;
    FConexao: TFDConnection;
    FLogSistema: TLogSistema;
    FProgressBar: TProgressBar;
    FOnProgress: TProgressEvent;

    FCNPJ: string;
    FChaveAPI: string;
    FCodEmpresa: Integer;

    procedure AtualizarProgress(ATotal, AAtual: Integer; const AMensagem: string);
    procedure Log(const AMensagem: string; ATipo: TLogTipo = ltInfo);
  public
    constructor Create(AConexao: TFDConnection; AConfig: TConfiguracao;
      ALogSistema: TLogSistema; AProgressBar: TProgressBar);
    destructor Destroy; override;

    // Envio
    function EnviarEmpresa: Boolean;
    function EnviarClientes: Boolean;
    function EnviarProdutos(AIncluirImagens: Boolean): Boolean;

    // Recebimento
    function ReceberClientes: Boolean;
    function ReceberPedidos: Boolean;

    // Reset
    function ResetarEmpresa: Boolean;

    property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
  end;

implementation

uses
  Vcl.Dialogs, System.Math, Udados;

{ TControladorSincronizacao }

constructor TControladorSincronizacao.Create(AConexao: TFDConnection;
  AConfig: TConfiguracao; ALogSistema: TLogSistema; AProgressBar: TProgressBar);
begin
  inherited Create;
  FConexao := AConexao;
  FConfig := AConfig;
  FLogSistema := ALogSistema;
  FProgressBar := AProgressBar;

  // Obter dados da empresa
  if not Assigned(Dados) or not Dados.qryEmpresa.Active then
    raise Exception.Create('Dados da empresa não carregados');

  FCNPJ := Dados.qryEmpresa.FieldByName('CNPJ').AsString;
  FChaveAPI := FConfig.GetChaveAPI;
  FCodEmpresa := Dados.qryEmpresa.FieldByName('CWEB').AsInteger;

  // Criar API
  FApi := TSincronizadorApi.Create(FConexao, FConfig.GetEndpoint, FCNPJ, FChaveAPI);

  // Obter token
  try
    Log('[SISTEMA] Obtendo token de autenticação...');
    FApi.LApiKeyJWT := FApi.ObterTokenDaApi(FCNPJ, FChaveAPI);
    Log('[SISTEMA] Token obtido com sucesso', ltSucesso);
  except
    on E: Exception do
    begin
      Log('[ERRO] Falha na autenticação: ' + E.Message, ltErro);
      raise;
    end;
  end;
end;

destructor TControladorSincronizacao.Destroy;
begin
  FreeAndNil(FApi);
  inherited;
end;

procedure TControladorSincronizacao.AtualizarProgress(ATotal, AAtual: Integer;
  const AMensagem: string);
begin
  if Assigned(FProgressBar) then
  begin
    FProgressBar.Max := ATotal;
    FProgressBar.Position := AAtual;
  end;

  if Assigned(FOnProgress) then
    FOnProgress(ATotal, AAtual, AMensagem);
end;

procedure TControladorSincronizacao.Log(const AMensagem: string; ATipo: TLogTipo);
begin
  if Assigned(FLogSistema) then
    FLogSistema.AdicionarLog(AMensagem, ATipo);
end;

// ===== ENVIO =====

function TControladorSincronizacao.EnviarEmpresa: Boolean;
var
  LWebCodEmp: Integer;
  qryDadosEmpresa, qryFormasPgto, qrUser: TFDQuery;
begin
  Result := False;
  Log('[EMPRESA] Iniciando envio...');

  qryDadosEmpresa := TFDQuery.Create(nil);
  qryFormasPgto := TFDQuery.Create(nil);
  qrUser := TFDQuery.Create(nil);
  try
    AtualizarProgress(3, 1, 'Carregando dados da empresa...');

    qryDadosEmpresa.Connection := FConexao;
    qryDadosEmpresa.SQL.Text :=
      'SELECT E.CODIGO, E.CWEB, ' +
      '       E.FANTASIA AS nomefantasia, E.RAZAO AS razaosocial, ' +
      '       E.ENDERECO AS endereco, E.NUMERO AS End_Numero, ' +
      '       E.COMPLEMENTO, E.BAIRRO, E.CIDADE, E.UF, E.CEP, ' +
      '       E.CNPJ, E.IE, E.FONE ' +
      'FROM EMPRESA E WHERE E.CODIGO = :CODIGO';
    qryDadosEmpresa.ParamByName('CODIGO').Value := Dados.qryEmpresaCODIGO.Value;
    qryDadosEmpresa.Open;

    if qryDadosEmpresa.IsEmpty then
      raise Exception.Create('Empresa não encontrada');

    AtualizarProgress(3, 2, 'Carregando formas de pagamento...');

    qryFormasPgto.Connection := FConexao;
    qryFormasPgto.SQL.Text :=
      'SELECT CODIGO AS id, DESCRICAO as descricao, PARCELAS as parcelas ' +
      'FROM FORMA_PAGAMENTO WHERE ATIVO = ''S'' ORDER BY DESCRICAO';
    qryFormasPgto.Open;

    qrUser.Connection := FConexao;
    qrUser.SQL.Text :=
      'SELECT LOGIN AS nome, SENHA_APP AS senha, ' +
      'lower(LOGIN) || ''@vendas.com'' AS email, ' +
      '10.00 AS desconto_padrao, 1 AS permite_desconto, ''P'' AS tipo_desconto ' +
      'FROM USUARIOS WHERE ATIVO = ''S''';
    qrUser.Open;

    AtualizarProgress(3, 3, 'Enviando para API...');

    if FApi.SincronizarEmpresa(FCNPJ, FChaveAPI, FCodEmpresa,
       qryDadosEmpresa, qryFormasPgto, qrUser, LWebCodEmp) then
    begin
      if (FCodEmpresa = 0) then
      begin
        Dados.qryEmpresa.Edit;
        Dados.qryEmpresa.FieldByName('CWEB').AsInteger := LWebCodEmp;
        Dados.qryEmpresa.Post;
        Dados.Conexao.Commit;
        FCodEmpresa := LWebCodEmp;
      end;

      FConfig.SetUltimoEnvio('Empresa', Now);
      Log('[EMPRESA] POST /api/empresa/sync - Status: 200 - Sucesso', ltSucesso);
      Result := True;
    end;
  except
    on E: Exception do
    begin
      Log('[EMPRESA] Erro: ' + E.Message, ltErro);
      raise;
    end;
  end;
  finally
    qryDadosEmpresa.Free;
    qryFormasPgto.Free;
    qrUser.Free;
  end;
end;

function TControladorSincronizacao.EnviarClientes: Boolean;
var
  qryClientes: TFDQuery;
  LTotal: Integer;
begin
  Result := False;
  Log('[CLIENTES] Iniciando envio...');

  qryClientes := TFDQuery.Create(nil);
  try
    qryClientes.Connection := FConexao;
    qryClientes.SQL.Text :=
      'SELECT * FROM PESSOA WHERE empresa = :id AND cli = ''S'' AND ativo = ''S'' AND codigo != 1';
    qryClientes.ParamByName('id').Value := Dados.qryEmpresaCODIGO.Value;
    qryClientes.Open;

    LTotal := qryClientes.RecordCount;
    if LTotal = 0 then
    begin
      Log('[CLIENTES] Nenhum cliente para enviar', ltAviso);
      Exit;
    end;

    AtualizarProgress(LTotal, 0, Format('Enviando %d clientes...', [LTotal]));

    if FApi.Sincronizar(FCNPJ, FCodEmpresa, qryClientes, 'POST', 'clientes/sync') then
    begin
      FConfig.SetUltimoEnvio('Clientes', Now);
      Log(Format('[CLIENTES] POST /api/clientes/sync - Status: 200 - %d registros enviados', [LTotal]), ltSucesso);
      Result := True;
    end;
  except
    on E: Exception do
    begin
      Log('[CLIENTES] Erro: ' + E.Message, ltErro);
      raise;
    end;
  finally
    qryClientes.Free;
  end;
end;

function TControladorSincronizacao.EnviarProdutos(AIncluirImagens: Boolean): Boolean;
var
  qryProdutos: TFDQuery;
  LTotal: Integer;
begin
  Result := False;
  Log('[PRODUTOS] Iniciando envio...');

  qryProdutos := TFDQuery.Create(nil);
  try
    qryProdutos.Connection := FConexao;
    qryProdutos.SQL.Text :=
      'SELECT PRO.*, gr.descricao grupo_sl FROM Produto PRO ' +
      'LEFT JOIN grupo gr ON gr.codigo = pro.grupo ' +
      'WHERE pro.empresa = :id AND pro.ativo = ''S''';
    qryProdutos.ParamByName('id').Value := Dados.qryEmpresaCODIGO.Value;
    qryProdutos.Open;

    LTotal := qryProdutos.RecordCount;
    if LTotal = 0 then
    begin
      Log('[PRODUTOS] Nenhum produto para enviar', ltAviso);
      Exit;
    end;

    AtualizarProgress(LTotal, 0, Format('Enviando %d produtos...', [LTotal]));

    if FApi.Sincronizar(FCNPJ, FCodEmpresa, qryProdutos, 'POST', 'produtos/sync') then
    begin
      FConfig.SetUltimoEnvio('Produtos', Now);
      Log(Format('[PRODUTOS] POST /api/produtos/sync - Status: 200 - %d registros enviados', [LTotal]), ltSucesso);
      Result := True;
    end;
  except
    on E: Exception do
    begin
      Log('[PRODUTOS] Erro: ' + E.Message, ltErro);
      raise;
    end;
  finally
    qryProdutos.Free;
  end;
end;

// ===== RECEBIMENTO =====

function TControladorSincronizacao.ReceberClientes: Boolean;
var
  LClientes: TJSONArray;
  LCliente: TJSONObject;
  I: Integer;
  qryPessoas: TFDQuery;
begin
  Result := False;
  Log('[CLIENTES] Iniciando recebimento...');

  qryPessoas := TFDQuery.Create(nil);
  try
    AtualizarProgress(100, 0, 'Baixando clientes da API...');

    if FApi.BaixarClientes(FCodEmpresa, FConfig.GetUltimoRecebimento('Clientes'), LClientes) then
    begin
      try
        qryPessoas.Connection := FConexao;
        qryPessoas.SQL.Text := 'SELECT * FROM PESSOA WHERE empresa = :id';
        qryPessoas.ParamByName('id').Value := Dados.qryEmpresaCODIGO.Value;
        qryPessoas.Open;

        for I := 0 to LClientes.Count - 1 do
        begin
          LCliente := LClientes.Items[I] as TJSONObject;
          AtualizarProgress(LClientes.Count, I + 1, Format('Processando cliente %d/%d', [I + 1, LClientes.Count]));

          if qryPessoas.Locate('CODIGO_WEB', LCliente.GetValue<Integer>('codigo'), []) then
            qryPessoas.Edit
          else
            qryPessoas.Insert;

          qryPessoas.FieldByName('CODIGO_WEB').AsInteger := LCliente.GetValue<Integer>('codigo');
          if qryPessoas.State = dsInsert then
            qryPessoas.FieldByName('CODIGO').AsInteger := Dados.Numerador('PESSOA', 'CODIGO', 'N', '', '');

          qryPessoas.FieldByName('RAZAO').AsString := LCliente.GetValue<string>('razao_nome');
          qryPessoas.FieldByName('FANTASIA').AsString := LCliente.GetValue<string>('apelido_fantasia');
          qryPessoas.FieldByName('CNPJ').AsString := LCliente.GetValue<string>('cpf_cnpj');
          qryPessoas.FieldByName('CLI').AsString := 'S';
          qryPessoas.FieldByName('ATIVO').AsString := 'S';

          qryPessoas.Post;
        end;

        FConexao.Commit;
        FConfig.SetUltimoRecebimento('Clientes', Now);
        Log(Format('[CLIENTES] GET /api/clientes/download - Status: 200 - %d clientes recebidos', [LClientes.Count]), ltSucesso);
        Result := True;
      finally
        LClientes.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      FConexao.Rollback;
      Log('[CLIENTES] Erro: ' + E.Message, ltErro);
      raise;
    end;
  finally
    qryPessoas.Free;
  end;
end;

function TControladorSincronizacao.ReceberPedidos: Boolean;
var
  LPedidos: TJSONArray;
begin
  Result := False;
  Log('[PEDIDOS] Iniciando recebimento...');

  try
    AtualizarProgress(100, 0, 'Baixando pedidos da API...');

    if FApi.BaixarPedidosPendentes(FCodEmpresa, LPedidos) then
    begin
      try
        Log(Format('[PEDIDOS] GET /api/pedidos/pendentes - Status: 200 - %d pedidos recebidos', [LPedidos.Count]), ltSucesso);
        FConfig.SetUltimoRecebimento('Pedidos', Now);
        Result := True;
      finally
        LPedidos.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      Log('[PEDIDOS] Erro: ' + E.Message, ltErro);
      raise;
    end;
  end;
end;

// ===== RESET =====

function TControladorSincronizacao.ResetarEmpresa: Boolean;
begin
  Result := False;

  if MessageDlg('ATENÇÃO: Esta operação irá apagar TODOS os dados da empresa na nuvem!' + #13#10#13#10 +
                'Tem certeza que deseja continuar?',
                mtWarning, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  if MessageDlg('CONFIRMAÇÃO FINAL: Todos os dados (empresa, clientes, produtos, pedidos) serão APAGADOS!' + #13#10#13#10 +
                'Esta ação é IRREVERSÍVEL. Continuar?',
                mtWarning, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  Log('[SISTEMA] Resetando dados da empresa na nuvem...');

  try
    if FApi.ResetarEmpresa(FCNPJ, FChaveAPI, FCodEmpresa) then
    begin
      // Limpar timestamps
      FConfig.LimparTimestamps;

      // Resetar CWEB
      Dados.qryEmpresa.Edit;
      Dados.qryEmpresa.FieldByName('CWEB').AsInteger := 0;
      Dados.qryEmpresa.Post;
      Dados.Conexao.Commit;

      Log('[SISTEMA] DELETE /api/empresa/reset - Status: 200 - Empresa resetada', ltSucesso);
      ShowMessage('Empresa resetada com sucesso!');
      Result := True;
    end;
  except
    on E: Exception do
    begin
      Log('[ERRO] Falha ao resetar empresa: ' + E.Message, ltErro);
      ShowMessage('Erro ao resetar empresa: ' + E.Message);
    end;
  end;
end;

end.
