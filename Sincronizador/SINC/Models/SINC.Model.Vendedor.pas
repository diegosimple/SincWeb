unit SINC.Model.Vendedor;

{*******************************************************************************
  SINC - Model Vendedor

  Representa a entidade VENDEDORES do banco de dados local

  Autor: Sistema SINC
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.JSON, FireDAC.Comp.Client, Data.DB;

type
  TVendedor = class
  private
    FCodigo: Integer;
    FCMA: Double;
    FCMP: Double;
    FAtivo: string;
    FEmpresa: Integer;
    FFlag: string;
    FNome: string;

  public
    constructor Create;
    destructor Destroy; override;

    procedure FromDataSet(AQry: TFDQuery);
    procedure FromJSON(AJSON: TJSONObject);
    function ToJSON: TJSONObject;
    procedure Salvar;

    property Codigo: Integer read FCodigo write FCodigo;
    property CMA: Double read FCMA write FCMA;
    property CMP: Double read FCMP write FCMP;
    property Ativo: string read FAtivo write FAtivo;
    property Empresa: Integer read FEmpresa write FEmpresa;
    property Flag: string read FFlag write FFlag;
    property Nome: string read FNome write FNome;
  end;

implementation

uses
  SINC.Services.VendedorService;

{ TVendedor }

constructor TVendedor.Create;
begin
  inherited;
  FCodigo := 0;
  FCMA := 0;
  FCMP := 0;
  FAtivo := 'S';
  FEmpresa := 0;
  FFlag := '';
  FNome := '';
end;

destructor TVendedor.Destroy;
begin
  inherited;
end;

procedure TVendedor.FromDataSet(AQry: TFDQuery);
begin
  if AQry.IsEmpty then
    Exit;

  FCodigo := AQry.FieldByName('CODIGO').AsInteger;

  if not AQry.FieldByName('CMA').IsNull then
    FCMA := AQry.FieldByName('CMA').AsFloat;

  if not AQry.FieldByName('CMP').IsNull then
    FCMP := AQry.FieldByName('CMP').AsFloat;

  if not AQry.FieldByName('ATIVO').IsNull then
    FAtivo := AQry.FieldByName('ATIVO').AsString;

  if not AQry.FieldByName('EMPRESA').IsNull then
    FEmpresa := AQry.FieldByName('EMPRESA').AsInteger;

  if not AQry.FieldByName('FLAG').IsNull then
    FFlag := AQry.FieldByName('FLAG').AsString;

  if not AQry.FieldByName('NOME').IsNull then
    FNome := AQry.FieldByName('NOME').AsString;
end;

procedure TVendedor.FromJSON(AJSON: TJSONObject);
begin
  if not Assigned(AJSON) then
    Exit;

  if AJSON.TryGetValue<Integer>('codigo', FCodigo) then;
  if AJSON.TryGetValue<Double>('cma', FCMA) then;
  if AJSON.TryGetValue<Double>('cmp', FCMP) then;
  if AJSON.TryGetValue<string>('ativo', FAtivo) then;
  if AJSON.TryGetValue<Integer>('empresa', FEmpresa) then;
  if AJSON.TryGetValue<string>('flag', FFlag) then;
  if AJSON.TryGetValue<string>('nome', FNome) then;
end;

function TVendedor.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('codigo', TJSONNumber.Create(FCodigo));
  Result.AddPair('cma', TJSONNumber.Create(FCMA));
  Result.AddPair('cmp', TJSONNumber.Create(FCMP));
  Result.AddPair('ativo', FAtivo);
  Result.AddPair('empresa', TJSONNumber.Create(FEmpresa));
  Result.AddPair('flag', FFlag);
  Result.AddPair('nome', FNome);
end;

procedure TVendedor.Salvar;
var
  Service: TVendedorService;
begin
  Service := TVendedorService.Create;
  try
    Service.SalvarOuAtualizar(Self);
  finally
    Service.Free;
  end;
end;

end.
