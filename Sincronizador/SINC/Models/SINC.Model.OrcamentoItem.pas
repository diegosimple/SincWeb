unit SINC.Model.OrcamentoItem;

{*******************************************************************************
  SINC - Model OrcamentoItem

  Representa a entidade ORCAMENTO_ITEM do banco de dados local

  Autor: Sistema SINC
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.JSON, FireDAC.Comp.Client, Data.DB;

type
  TOrcamentoItem = class
  private
    FCodigo: Integer;
    FFKOrcamento: Integer;
    FFKProduto: Integer;
    FQtd: Double;
    FPreco: Double;
    FTotal: Double;
    FItem: Integer;
    FFKGrade: Integer;
    FDesconto: Double;
    FDescricao: string;

  public
    constructor Create;
    destructor Destroy; override;

    procedure FromDataSet(AQry: TFDQuery);
    procedure FromJSON(AJSON: TJSONObject);
    function ToJSON: TJSONObject;
    procedure Salvar;

    property Codigo: Integer read FCodigo write FCodigo;
    property FKOrcamento: Integer read FFKOrcamento write FFKOrcamento;
    property FKProduto: Integer read FFKProduto write FFKProduto;
    property Qtd: Double read FQtd write FQtd;
    property Preco: Double read FPreco write FPreco;
    property Total: Double read FTotal write FTotal;
    property Item: Integer read FItem write FItem;
    property FKGrade: Integer read FFKGrade write FFKGrade;
    property Desconto: Double read FDesconto write FDesconto;
    property Descricao: string read FDescricao write FDescricao;
  end;

implementation

uses
  SINC.Services.OrcamentoItemService;

{ TOrcamentoItem }

constructor TOrcamentoItem.Create;
begin
  inherited;
  FCodigo := 0;
  FFKOrcamento := 0;
  FFKProduto := 0;
  FQtd := 0;
  FPreco := 0;
  FTotal := 0;
  FItem := 0;
  FFKGrade := 0;
  FDesconto := 0;
  FDescricao := '';
end;

destructor TOrcamentoItem.Destroy;
begin
  inherited;
end;

procedure TOrcamentoItem.FromDataSet(AQry: TFDQuery);
begin
  if AQry.IsEmpty then
    Exit;

  FCodigo := AQry.FieldByName('CODIGO').AsInteger;
  FFKOrcamento := AQry.FieldByName('FK_ORCAMENTO').AsInteger;

  if not AQry.FieldByName('FK_PRODUTO').IsNull then
    FFKProduto := AQry.FieldByName('FK_PRODUTO').AsInteger;

  if not AQry.FieldByName('QTD').IsNull then
    FQtd := AQry.FieldByName('QTD').AsFloat;

  if not AQry.FieldByName('PRECO').IsNull then
    FPreco := AQry.FieldByName('PRECO').AsFloat;

  if not AQry.FieldByName('TOTAL').IsNull then
    FTotal := AQry.FieldByName('TOTAL').AsFloat;

  if not AQry.FieldByName('ITEM').IsNull then
    FItem := AQry.FieldByName('ITEM').AsInteger;

  if not AQry.FieldByName('FK_GRADE').IsNull then
    FFKGrade := AQry.FieldByName('FK_GRADE').AsInteger;

  if not AQry.FieldByName('DESCONTO').IsNull then
    FDesconto := AQry.FieldByName('DESCONTO').AsFloat;

  if not AQry.FieldByName('DESCRICAO').IsNull then
    FDescricao := AQry.FieldByName('DESCRICAO').AsString;
end;

procedure TOrcamentoItem.FromJSON(AJSON: TJSONObject);
begin
  if not Assigned(AJSON) then
    Exit;

  if AJSON.TryGetValue<Integer>('codigo', FCodigo) then;
  if AJSON.TryGetValue<Integer>('fk_orcamento', FFKOrcamento) then;
  if AJSON.TryGetValue<Integer>('fk_produto', FFKProduto) then;
  if AJSON.TryGetValue<Double>('qtd', FQtd) then;
  if AJSON.TryGetValue<Double>('preco', FPreco) then;
  if AJSON.TryGetValue<Double>('total', FTotal) then;
  if AJSON.TryGetValue<Integer>('item', FItem) then;
  if AJSON.TryGetValue<Integer>('fk_grade', FFKGrade) then;
  if AJSON.TryGetValue<Double>('desconto', FDesconto) then;
  if AJSON.TryGetValue<string>('descricao', FDescricao) then;
end;

function TOrcamentoItem.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('codigo', TJSONNumber.Create(FCodigo));
  Result.AddPair('fk_orcamento', TJSONNumber.Create(FFKOrcamento));
  Result.AddPair('fk_produto', TJSONNumber.Create(FFKProduto));
  Result.AddPair('qtd', TJSONNumber.Create(FQtd));
  Result.AddPair('preco', TJSONNumber.Create(FPreco));
  Result.AddPair('total', TJSONNumber.Create(FTotal));
  Result.AddPair('item', TJSONNumber.Create(FItem));
  Result.AddPair('fk_grade', TJSONNumber.Create(FFKGrade));
  Result.AddPair('desconto', TJSONNumber.Create(FDesconto));
  Result.AddPair('descricao', FDescricao);
end;

procedure TOrcamentoItem.Salvar;
var
  Service: TOrcamentoItemService;
begin
  Service := TOrcamentoItemService.Create;
  try
    Service.SalvarOuAtualizar(Self);
  finally
    Service.Free;
  end;
end;

end.
