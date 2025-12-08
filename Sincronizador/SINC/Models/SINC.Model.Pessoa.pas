unit SINC.Model.Pessoa;

{*******************************************************************************
  SINC - Model Pessoa

  Representa a entidade PESSOA do banco de dados local

  Autor: Sistema SINC
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.JSON, FireDAC.Comp.Client, Data.DB;

type
  TPessoa = class
  private
    FEmpresa: Integer;
    FCodigo: Integer;
    FTipo: string;
    FCNPJ: string;
    FIE: string;
    FFantasia: string;
    FRazao: string;
    FEndereco: string;
    FNumero: string;
    FComplemento: string;
    FCodMun: Integer;
    FMunicipio: string;
    FBairro: string;
    FUF: string;
    FCEP: string;
    FFone1: string;
    FFone2: string;
    FCelular1: string;
    FCelular2: string;
    FEmail1: string;
    FEmail2: string;
    FSexo: string;
    FDtNasc: TDate;
    FECivil: string;
    FLimite: Double;
    FDiaPgto: Integer;
    FNumUsu: Integer;
    FFatura: string;
    FCheque: string;
    FCCF: string;
    FSPC: string;
    FIsento: string;
    FForn: string;
    FFun: string;
    FCli: string;
    FFab: string;
    FTran: string;
    FAdm: string;
    FAtivo: string;
    FDtCadastro: TDate;
    FCodigoWeb: Integer;
    FReferencia: Integer;
    FFlag: string;
    FWhatsapp: string;

  public
    constructor Create;
    destructor Destroy; override;

    procedure FromDataSet(AQry: TFDQuery);
    procedure FromJSON(AJSON: TJSONObject);
    function ToJSON: TJSONObject;
    procedure Salvar;

    property Empresa: Integer read FEmpresa write FEmpresa;
    property Codigo: Integer read FCodigo write FCodigo;
    property Tipo: string read FTipo write FTipo;
    property CNPJ: string read FCNPJ write FCNPJ;
    property IE: string read FIE write FIE;
    property Fantasia: string read FFantasia write FFantasia;
    property Razao: string read FRazao write FRazao;
    property Endereco: string read FEndereco write FEndereco;
    property Numero: string read FNumero write FNumero;
    property Complemento: string read FComplemento write FComplemento;
    property CodMun: Integer read FCodMun write FCodMun;
    property Municipio: string read FMunicipio write FMunicipio;
    property Bairro: string read FBairro write FBairro;
    property UF: string read FUF write FUF;
    property CEP: string read FCEP write FCEP;
    property Fone1: string read FFone1 write FFone1;
    property Fone2: string read FFone2 write FFone2;
    property Celular1: string read FCelular1 write FCelular1;
    property Celular2: string read FCelular2 write FCelular2;
    property Email1: string read FEmail1 write FEmail1;
    property Email2: string read FEmail2 write FEmail2;
    property Sexo: string read FSexo write FSexo;
    property DtNasc: TDate read FDtNasc write FDtNasc;
    property ECivil: string read FECivil write FECivil;
    property Limite: Double read FLimite write FLimite;
    property DiaPgto: Integer read FDiaPgto write FDiaPgto;
    property NumUsu: Integer read FNumUsu write FNumUsu;
    property Fatura: string read FFatura write FFatura;
    property Cheque: string read FCheque write FCheque;
    property CCF: string read FCCF write FCCF;
    property SPC: string read FSPC write FSPC;
    property Isento: string read FIsento write FIsento;
    property Forn: string read FForn write FForn;
    property Fun: string read FFun write FFun;
    property Cli: string read FCli write FCli;
    property Fab: string read FFab write FFab;
    property Tran: string read FTran write FTran;
    property Adm: string read FAdm write FAdm;
    property Ativo: string read FAtivo write FAtivo;
    property DtCadastro: TDate read FDtCadastro write FDtCadastro;
    property CodigoWeb: Integer read FCodigoWeb write FCodigoWeb;
    property Referencia: Integer read FReferencia write FReferencia;
    property Flag: string read FFlag write FFlag;
    property Whatsapp: string read FWhatsapp write FWhatsapp;
  end;

implementation

uses
  SINC.Services.PessoaService;

{ TPessoa }

constructor TPessoa.Create;
begin
  inherited;
  FEmpresa := 0;
  FCodigo := 0;
  FTipo := 'FISICA';
  FCNPJ := '';
  FIE := '';
  FFantasia := '';
  FRazao := '';
  FEndereco := '';
  FNumero := '';
  FComplemento := '';
  FCodMun := 0;
  FMunicipio := '';
  FBairro := '';
  FUF := '';
  FCEP := '';
  FFone1 := '';
  FFone2 := '';
  FCelular1 := '';
  FCelular2 := '';
  FEmail1 := '';
  FEmail2 := '';
  FSexo := '';
  FDtNasc := 0;
  FECivil := '';
  FLimite := 0;
  FDiaPgto := 0;
  FNumUsu := 0;
  FFatura := 'N';
  FCheque := 'N';
  FCCF := 'N';
  FSPC := 'N';
  FIsento := 'N';
  FForn := 'N';
  FFun := 'N';
  FCli := 'S';
  FFab := 'N';
  FTran := 'N';
  FAdm := 'N';
  FAtivo := 'S';
  FDtCadastro := Date;
  FCodigoWeb := 0;
  FReferencia := 0;
  FFlag := '';
  FWhatsapp := '';
end;

destructor TPessoa.Destroy;
begin
  inherited;
end;

procedure TPessoa.FromDataSet(AQry: TFDQuery);
begin
  if AQry.IsEmpty then
    Exit;

  FEmpresa := AQry.FieldByName('EMPRESA').AsInteger;
  FCodigo := AQry.FieldByName('CODIGO').AsInteger;
  FTipo := AQry.FieldByName('TIPO').AsString;

  if not AQry.FieldByName('CNPJ').IsNull then
    FCNPJ := AQry.FieldByName('CNPJ').AsString;

  if not AQry.FieldByName('IE').IsNull then
    FIE := AQry.FieldByName('IE').AsString;

  if not AQry.FieldByName('FANTASIA').IsNull then
    FFantasia := AQry.FieldByName('FANTASIA').AsString;

  if not AQry.FieldByName('RAZAO').IsNull then
    FRazao := AQry.FieldByName('RAZAO').AsString;

  if not AQry.FieldByName('ENDERECO').IsNull then
    FEndereco := AQry.FieldByName('ENDERECO').AsString;

  if not AQry.FieldByName('NUMERO').IsNull then
    FNumero := AQry.FieldByName('NUMERO').AsString;

  if not AQry.FieldByName('COMPLEMENTO').IsNull then
    FComplemento := AQry.FieldByName('COMPLEMENTO').AsString;

  if not AQry.FieldByName('CODMUN').IsNull then
    FCodMun := AQry.FieldByName('CODMUN').AsInteger;

  if not AQry.FieldByName('MUNICIPIO').IsNull then
    FMunicipio := AQry.FieldByName('MUNICIPIO').AsString;

  if not AQry.FieldByName('BAIRRO').IsNull then
    FBairro := AQry.FieldByName('BAIRRO').AsString;

  if not AQry.FieldByName('UF').IsNull then
    FUF := AQry.FieldByName('UF').AsString;

  if not AQry.FieldByName('CEP').IsNull then
    FCEP := AQry.FieldByName('CEP').AsString;

  if not AQry.FieldByName('FONE1').IsNull then
    FFone1 := AQry.FieldByName('FONE1').AsString;

  if not AQry.FieldByName('FONE2').IsNull then
    FFone2 := AQry.FieldByName('FONE2').AsString;

  if not AQry.FieldByName('CELULAR1').IsNull then
    FCelular1 := AQry.FieldByName('CELULAR1').AsString;

  if not AQry.FieldByName('CELULAR2').IsNull then
    FCelular2 := AQry.FieldByName('CELULAR2').AsString;

  if not AQry.FieldByName('EMAIL1').IsNull then
    FEmail1 := AQry.FieldByName('EMAIL1').AsString;

  if not AQry.FieldByName('EMAIL2').IsNull then
    FEmail2 := AQry.FieldByName('EMAIL2').AsString;

  if not AQry.FieldByName('SEXO').IsNull then
    FSexo := AQry.FieldByName('SEXO').AsString;

  if not AQry.FieldByName('DT_NASC').IsNull then
    FDtNasc := AQry.FieldByName('DT_NASC').AsDateTime;

  if not AQry.FieldByName('ECIVIL').IsNull then
    FECivil := AQry.FieldByName('ECIVIL').AsString;

  if not AQry.FieldByName('LIMITE').IsNull then
    FLimite := AQry.FieldByName('LIMITE').AsFloat;

  if not AQry.FieldByName('DIA_PGTO').IsNull then
    FDiaPgto := AQry.FieldByName('DIA_PGTO').AsInteger;

  if not AQry.FieldByName('NUM_USU').IsNull then
    FNumUsu := AQry.FieldByName('NUM_USU').AsInteger;

  if not AQry.FieldByName('FATURA').IsNull then
    FFatura := AQry.FieldByName('FATURA').AsString;

  if not AQry.FieldByName('CHEQUE').IsNull then
    FCheque := AQry.FieldByName('CHEQUE').AsString;

  if not AQry.FieldByName('CCF').IsNull then
    FCCF := AQry.FieldByName('CCF').AsString;

  if not AQry.FieldByName('SPC').IsNull then
    FSPC := AQry.FieldByName('SPC').AsString;

  if not AQry.FieldByName('ISENTO').IsNull then
    FIsento := AQry.FieldByName('ISENTO').AsString;

  if not AQry.FieldByName('FORN').IsNull then
    FForn := AQry.FieldByName('FORN').AsString;

  if not AQry.FieldByName('FUN').IsNull then
    FFun := AQry.FieldByName('FUN').AsString;

  if not AQry.FieldByName('CLI').IsNull then
    FCli := AQry.FieldByName('CLI').AsString;

  if not AQry.FieldByName('FAB').IsNull then
    FFab := AQry.FieldByName('FAB').AsString;

  if not AQry.FieldByName('TRAN').IsNull then
    FTran := AQry.FieldByName('TRAN').AsString;

  if not AQry.FieldByName('ADM').IsNull then
    FAdm := AQry.FieldByName('ADM').AsString;

  if not AQry.FieldByName('ATIVO').IsNull then
    FAtivo := AQry.FieldByName('ATIVO').AsString;

  if not AQry.FieldByName('DT_CADASTRO').IsNull then
    FDtCadastro := AQry.FieldByName('DT_CADASTRO').AsDateTime;

  if not AQry.FieldByName('CODIGO_WEB').IsNull then
    FCodigoWeb := AQry.FieldByName('CODIGO_WEB').AsInteger;

  if not AQry.FieldByName('REFERENCIA').IsNull then
    FReferencia := AQry.FieldByName('REFERENCIA').AsInteger;

  if not AQry.FieldByName('FLAG').IsNull then
    FFlag := AQry.FieldByName('FLAG').AsString;

  if not AQry.FieldByName('WHATSAPP').IsNull then
    FWhatsapp := AQry.FieldByName('WHATSAPP').AsString;
end;

procedure TPessoa.FromJSON(AJSON: TJSONObject);
begin
  if not Assigned(AJSON) then
    Exit;

  if AJSON.TryGetValue<Integer>('empresa', FEmpresa) then;
  if AJSON.TryGetValue<Integer>('codigo', FCodigo) then;
  if AJSON.TryGetValue<string>('tipo', FTipo) then;
  if AJSON.TryGetValue<string>('cnpj', FCNPJ) then;
  if AJSON.TryGetValue<string>('ie', FIE) then;
  if AJSON.TryGetValue<string>('fantasia', FFantasia) then;
  if AJSON.TryGetValue<string>('razao', FRazao) then;
  if AJSON.TryGetValue<string>('endereco', FEndereco) then;
  if AJSON.TryGetValue<string>('numero', FNumero) then;
  if AJSON.TryGetValue<string>('complemento', FComplemento) then;
  if AJSON.TryGetValue<Integer>('codmun', FCodMun) then;
  if AJSON.TryGetValue<string>('municipio', FMunicipio) then;
  if AJSON.TryGetValue<string>('bairro', FBairro) then;
  if AJSON.TryGetValue<string>('uf', FUF) then;
  if AJSON.TryGetValue<string>('cep', FCEP) then;
  if AJSON.TryGetValue<string>('fone1', FFone1) then;
  if AJSON.TryGetValue<string>('fone2', FFone2) then;
  if AJSON.TryGetValue<string>('celular1', FCelular1) then;
  if AJSON.TryGetValue<string>('celular2', FCelular2) then;
  if AJSON.TryGetValue<string>('email1', FEmail1) then;
  if AJSON.TryGetValue<string>('email2', FEmail2) then;
  if AJSON.TryGetValue<string>('sexo', FSexo) then;
  if AJSON.TryGetValue<string>('ecivil', FECivil) then;
  if AJSON.TryGetValue<Double>('limite', FLimite) then;
  if AJSON.TryGetValue<Integer>('dia_pgto', FDiaPgto) then;
  if AJSON.TryGetValue<Integer>('num_usu', FNumUsu) then;
  if AJSON.TryGetValue<string>('fatura', FFatura) then;
  if AJSON.TryGetValue<string>('cheque', FCheque) then;
  if AJSON.TryGetValue<string>('ccf', FCCF) then;
  if AJSON.TryGetValue<string>('spc', FSPC) then;
  if AJSON.TryGetValue<string>('isento', FIsento) then;
  if AJSON.TryGetValue<string>('forn', FForn) then;
  if AJSON.TryGetValue<string>('fun', FFun) then;
  if AJSON.TryGetValue<string>('cli', FCli) then;
  if AJSON.TryGetValue<string>('fab', FFab) then;
  if AJSON.TryGetValue<string>('tran', FTran) then;
  if AJSON.TryGetValue<string>('adm', FAdm) then;
  if AJSON.TryGetValue<string>('ativo', FAtivo) then;
  if AJSON.TryGetValue<Integer>('codigo_web', FCodigoWeb) then;
  if AJSON.TryGetValue<Integer>('referencia', FReferencia) then;
  if AJSON.TryGetValue<string>('flag', FFlag) then;
  if AJSON.TryGetValue<string>('whatsapp', FWhatsapp) then;
end;

function TPessoa.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('empresa', TJSONNumber.Create(FEmpresa));
  Result.AddPair('codigo', TJSONNumber.Create(FCodigo));
  Result.AddPair('tipo', FTipo);
  Result.AddPair('cnpj', FCNPJ);
  Result.AddPair('ie', FIE);
  Result.AddPair('fantasia', FFantasia);
  Result.AddPair('razao', FRazao);
  Result.AddPair('endereco', FEndereco);
  Result.AddPair('numero', FNumero);
  Result.AddPair('complemento', FComplemento);
  Result.AddPair('codmun', TJSONNumber.Create(FCodMun));
  Result.AddPair('municipio', FMunicipio);
  Result.AddPair('bairro', FBairro);
  Result.AddPair('uf', FUF);
  Result.AddPair('cep', FCEP);
  Result.AddPair('fone1', FFone1);
  Result.AddPair('fone2', FFone2);
  Result.AddPair('celular1', FCelular1);
  Result.AddPair('celular2', FCelular2);
  Result.AddPair('email1', FEmail1);
  Result.AddPair('email2', FEmail2);
  Result.AddPair('sexo', FSexo);

  if FDtNasc > 0 then
    Result.AddPair('dt_nasc', FormatDateTime('yyyy-mm-dd', FDtNasc))
  else
    Result.AddPair('dt_nasc', TJSONNull.Create);

  Result.AddPair('ecivil', FECivil);
  Result.AddPair('limite', TJSONNumber.Create(FLimite));
  Result.AddPair('dia_pgto', TJSONNumber.Create(FDiaPgto));
  Result.AddPair('num_usu', TJSONNumber.Create(FNumUsu));
  Result.AddPair('fatura', FFatura);
  Result.AddPair('cheque', FCheque);
  Result.AddPair('ccf', FCCF);
  Result.AddPair('spc', FSPC);
  Result.AddPair('isento', FIsento);
  Result.AddPair('forn', FForn);
  Result.AddPair('fun', FFun);
  Result.AddPair('cli', FCli);
  Result.AddPair('fab', FFab);
  Result.AddPair('tran', FTran);
  Result.AddPair('adm', FAdm);
  Result.AddPair('ativo', FAtivo);
  Result.AddPair('dt_cadastro', FormatDateTime('yyyy-mm-dd', FDtCadastro));
  Result.AddPair('codigo_web', TJSONNumber.Create(FCodigoWeb));
  Result.AddPair('referencia', TJSONNumber.Create(FReferencia));
  Result.AddPair('flag', FFlag);
  Result.AddPair('whatsapp', FWhatsapp);
end;

procedure TPessoa.Salvar;
var
  Service: TPessoaService;
begin
  Service := TPessoaService.Create;
  try
    Service.SalvarOuAtualizar(Self);
  finally
    Service.Free;
  end;
end;

end.
