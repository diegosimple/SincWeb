unit SINC.Services.FormaPagamentoService;

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client,
  SINC.Model.FormaPagamento, SINC.Provider.ConexaoBD;

type
  TFormaPagamentoService = class
  private
    FConexao: TConexaoBD;
  public
    constructor Create;
    destructor Destroy; override;
    function BuscarPorCodigo(ACodigo: Integer): TFormaPagamento;
    function ListarParaEnvio: TObjectList<TFormaPagamento>;
    procedure SalvarOuAtualizar(AFormaPagamento: TFormaPagamento);
    function Existe(ACodigo: Integer): Boolean;
    function ProximoCodigo: Integer;
  end;

implementation

constructor TFormaPagamentoService.Create;
begin
  inherited;
  FConexao := TConexaoBD.GetInstance;
end;

destructor TFormaPagamentoService.Destroy;
begin
  inherited;
end;

function TFormaPagamentoService.BuscarPorCodigo(ACodigo: Integer): TFormaPagamento;
var
  Qry: TFDQuery;
begin
  Result := nil;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM FORMA_PAGAMENTO WHERE CODIGO = :CODIGO';
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;
    if not Qry.IsEmpty then
    begin
      Result := TFormaPagamento.Create;
      Result.FromDataSet(Qry);
    end;
  finally
    Qry.Free;
  end;
end;

function TFormaPagamentoService.ListarParaEnvio: TObjectList<TFormaPagamento>;
var
  Qry: TFDQuery;
  FormaPgto: TFormaPagamento;
begin
  Result := TObjectList<TFormaPagamento>.Create(True);
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM FORMA_PAGAMENTO WHERE ATIVO = ''S'' ORDER BY CODIGO';
    Qry.Open;
    while not Qry.Eof do
    begin
      FormaPgto := TFormaPagamento.Create;
      FormaPgto.FromDataSet(Qry);
      Result.Add(FormaPgto);
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TFormaPagamentoService.SalvarOuAtualizar(AFormaPagamento: TFormaPagamento);
var
  Qry: TFDQuery;
begin
  if not Assigned(AFormaPagamento) then
    raise Exception.Create('Forma de Pagamento não pode ser nula');

  Qry := FConexao.NovaQuery;
  try
    FConexao.IniciarTransacao;
    try
      if Existe(AFormaPagamento.Codigo) then
      begin
        Qry.SQL.Text := 'UPDATE FORMA_PAGAMENTO SET DESCRICAO = :DESCRICAO, GERACR = :GERACR, ' +
          'GERACH = :GERACH, ECARTAO = :ECARTAO, ATIVO = :ATIVO, PARCELAS = :PARCELAS, ' +
          'INTERVALO = :INTERVALO, TAXA = :TAXA WHERE CODIGO = :CODIGO';
      end
      else
      begin
        if AFormaPagamento.Codigo = 0 then
          AFormaPagamento.Codigo := ProximoCodigo;

        Qry.SQL.Text := 'INSERT INTO FORMA_PAGAMENTO (CODIGO, DESCRICAO, GERACR, GERACH, ECARTAO, ' +
          'ATIVO, PARCELAS, INTERVALO, TAXA, USAVD, USACR, TIPO, DIAS) ' +
          'VALUES (:CODIGO, :DESCRICAO, :GERACR, :GERACH, :ECARTAO, :ATIVO, :PARCELAS, ' +
          ':INTERVALO, :TAXA, :USAVD, :USACR, :TIPO, :DIAS)';

        Qry.ParamByName('USAVD').AsString := AFormaPagamento.UsaVD;
        Qry.ParamByName('USACR').AsString := AFormaPagamento.UsaCR;
        Qry.ParamByName('TIPO').AsString := AFormaPagamento.Tipo;
        Qry.ParamByName('DIAS').AsInteger := AFormaPagamento.Dias;
      end;

      Qry.ParamByName('CODIGO').AsInteger := AFormaPagamento.Codigo;
      Qry.ParamByName('DESCRICAO').AsString := AFormaPagamento.Descricao;
      Qry.ParamByName('GERACR').AsString := AFormaPagamento.GeraCR;
      Qry.ParamByName('GERACH').AsString := AFormaPagamento.GeraCH;
      Qry.ParamByName('ECARTAO').AsString := AFormaPagamento.ECartao;
      Qry.ParamByName('ATIVO').AsString := AFormaPagamento.Ativo;
      Qry.ParamByName('PARCELAS').AsInteger := AFormaPagamento.Parcelas;
      Qry.ParamByName('INTERVALO').AsInteger := AFormaPagamento.Intervalo;
      Qry.ParamByName('TAXA').AsFloat := AFormaPagamento.Taxa;

      Qry.ExecSQL;
      FConexao.CommitTransacao;
    except
      on E: Exception do
      begin
        FConexao.RollbackTransacao;
        raise Exception.Create('Erro ao salvar forma de pagamento: ' + E.Message);
      end;
    end;
  finally
    Qry.Free;
  end;
end;

function TFormaPagamentoService.Existe(ACodigo: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT CODIGO FROM FORMA_PAGAMENTO WHERE CODIGO = :CODIGO';
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;
    Result := not Qry.IsEmpty;
  finally
    Qry.Free;
  end;
end;

function TFormaPagamentoService.ProximoCodigo: Integer;
var
  Qry: TFDQuery;
begin
  Result := 1;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT MAX(CODIGO) AS MAXIMO FROM FORMA_PAGAMENTO';
    Qry.Open;
    if not Qry.FieldByName('MAXIMO').IsNull then
      Result := Qry.FieldByName('MAXIMO').AsInteger + 1;
  finally
    Qry.Free;
  end;
end;

end.
