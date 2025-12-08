unit SINC.Model.FormaPagamento;

{*******************************************************************************
  SINC - Model FormaPagamento

  Representa a entidade FORMA_PAGAMENTO do banco de dados local

  Autor: Sistema SINC
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.JSON, FireDAC.Comp.Client, Data.DB;

type
  TFormaPagamento = class
  private
    FCodigo: Integer;
    FDescricao: string;
    FGeraCR: string;
    FGeraCH: string;
    FECartao: string;
    FUsaVD: string;
    FUsaCR: string;
    FAtivo: string;
    FParcelas: Integer;
    FIntervalo: Integer;
    FTaxa: Double;
    FEntrada: Double;
    FTipo: string;
    FDias: Integer;

  public
    constructor Create;
    destructor Destroy; override;

    procedure FromDataSet(AQry: TFDQuery);
    procedure FromJSON(AJSON: TJSONObject);
    function ToJSON: TJSONObject;
    procedure Salvar;

    property Codigo: Integer read FCodigo write FCodigo;
    property Descricao: string read FDescricao write FDescricao;
    property GeraCR: string read FGeraCR write FGeraCR;
    property GeraCH: string read FGeraCH write FGeraCH;
    property ECartao: string read FECartao write FECartao;
    property UsaVD: string read FUsaVD write FUsaVD;
    property UsaCR: string read FUsaCR write FUsaCR;
    property Ativo: string read FAtivo write FAtivo;
    property Parcelas: Integer read FParcelas write FParcelas;
    property Intervalo: Integer read FIntervalo write FIntervalo;
    property Taxa: Double read FTaxa write FTaxa;
    property Entrada: Double read FEntrada write FEntrada;
    property Tipo: string read FTipo write FTipo;
    property Dias: Integer read FDias write FDias;
  end;

implementation

uses
  SINC.Services.FormaPagamentoService;

{ TFormaPagamento }

constructor TFormaPagamento.Create;
begin
  inherited;
  FCodigo := 0;
  FDescricao := '';
  FGeraCR := 'N';
  FGeraCH := 'N';
  FECartao := 'N';
  FUsaVD := 'N';
  FUsaCR := 'N';
  FAtivo := 'S';
  FParcelas := 1;
  FIntervalo := 30;
  FTaxa := 0;
  FEntrada := 0;
  FTipo := '';
  FDias := 0;
end;

destructor TFormaPagamento.Destroy;
begin
  inherited;
end;

procedure TFormaPagamento.FromDataSet(AQry: TFDQuery);
begin
  if AQry.IsEmpty then
    Exit;

  FCodigo := AQry.FieldByName('CODIGO').AsInteger;

  if not AQry.FieldByName('DESCRICAO').IsNull then
    FDescricao := AQry.FieldByName('DESCRICAO').AsString;

  if not AQry.FieldByName('GERACR').IsNull then
    FGeraCR := AQry.FieldByName('GERACR').AsString;

  if not AQry.FieldByName('GERACH').IsNull then
    FGeraCH := AQry.FieldByName('GERACH').AsString;

  if not AQry.FieldByName('ECARTAO').IsNull then
    FECartao := AQry.FieldByName('ECARTAO').AsString;

  if not AQry.FieldByName('USAVD').IsNull then
    FUsaVD := AQry.FieldByName('USAVD').AsString;

  if not AQry.FieldByName('USACR').IsNull then
    FUsaCR := AQry.FieldByName('USACR').AsString;

  if not AQry.FieldByName('ATIVO').IsNull then
    FAtivo := AQry.FieldByName('ATIVO').AsString;

  if not AQry.FieldByName('PARCELAS').IsNull then
    FParcelas := AQry.FieldByName('PARCELAS').AsInteger;

  if not AQry.FieldByName('INTERVALO').IsNull then
    FIntervalo := AQry.FieldByName('INTERVALO').AsInteger;

  if not AQry.FieldByName('TAXA').IsNull then
    FTaxa := AQry.FieldByName('TAXA').AsFloat;

  if not AQry.FieldByName('ENTRADA').IsNull then
    FEntrada := AQry.FieldByName('ENTRADA').AsFloat;

  if not AQry.FieldByName('TIPO').IsNull then
    FTipo := AQry.FieldByName('TIPO').AsString;

  if not AQry.FieldByName('DIAS').IsNull then
    FDias := AQry.FieldByName('DIAS').AsInteger;
end;

procedure TFormaPagamento.FromJSON(AJSON: TJSONObject);
begin
  if not Assigned(AJSON) then
    Exit;

  if AJSON.TryGetValue<Integer>('codigo', FCodigo) then;
  if AJSON.TryGetValue<string>('descricao', FDescricao) then;
  if AJSON.TryGetValue<string>('geracr', FGeraCR) then;
  if AJSON.TryGetValue<string>('gerach', FGeraCH) then;
  if AJSON.TryGetValue<string>('ecartao', FECartao) then;
  if AJSON.TryGetValue<string>('usavd', FUsaVD) then;
  if AJSON.TryGetValue<string>('usacr', FUsaCR) then;
  if AJSON.TryGetValue<string>('ativo', FAtivo) then;
  if AJSON.TryGetValue<Integer>('parcelas', FParcelas) then;
  if AJSON.TryGetValue<Integer>('intervalo', FIntervalo) then;
  if AJSON.TryGetValue<Double>('taxa', FTaxa) then;
  if AJSON.TryGetValue<Double>('entrada', FEntrada) then;
  if AJSON.TryGetValue<string>('tipo', FTipo) then;
  if AJSON.TryGetValue<Integer>('dias', FDias) then;
end;

function TFormaPagamento.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('codigo', TJSONNumber.Create(FCodigo));
  Result.AddPair('descricao', FDescricao);
  Result.AddPair('geracr', FGeraCR);
  Result.AddPair('gerach', FGeraCH);
  Result.AddPair('ecartao', FECartao);
  Result.AddPair('usavd', FUsaVD);
  Result.AddPair('usacr', FUsaCR);
  Result.AddPair('ativo', FAtivo);
  Result.AddPair('parcelas', TJSONNumber.Create(FParcelas));
  Result.AddPair('intervalo', TJSONNumber.Create(FIntervalo));
  Result.AddPair('taxa', TJSONNumber.Create(FTaxa));
  Result.AddPair('entrada', TJSONNumber.Create(FEntrada));
  Result.AddPair('tipo', FTipo);
  Result.AddPair('dias', TJSONNumber.Create(FDias));
end;

procedure TFormaPagamento.Salvar;
var
  Service: TFormaPagamentoService;
begin
  Service := TFormaPagamentoService.Create;
  try
    Service.SalvarOuAtualizar(Self);
  finally
    Service.Free;
  end;
end;

end.
