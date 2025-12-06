unit uSincronizar;

interface //Suporte e Vendas direto no Whatsapp (48)998463846

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, acbrutil, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.DBCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client , System.Generics.Collections,
  System.StrUtils, System.Math , uSincronizadorApi , System.IniFiles;


type
  TFrmSincronizar = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnSalvar: TButton;
    ProgressBar1: TProgressBar;
    qryPessoas: TFDQuery;
    qryPessoasCODIGO: TIntegerField;
    qryPessoasEMPRESA: TSmallintField;
    qryPessoasTIPO: TStringField;
    qryPessoasCNPJ: TStringField;
    qryPessoasIE: TStringField;
    qryPessoasFANTASIA: TStringField;
    qryPessoasRAZAO: TStringField;
    qryPessoasPAI: TStringField;
    qryPessoasMAE: TStringField;
    qryPessoasENDERECO: TStringField;
    qryPessoasNUMERO: TStringField;
    qryPessoasCOMPLEMENTO: TStringField;
    qryPessoasCODMUN: TIntegerField;
    qryPessoasMUNICIPIO: TStringField;
    qryPessoasBAIRRO: TStringField;
    qryPessoasUF: TStringField;
    qryPessoasCEP: TStringField;
    qryPessoasFONE1: TStringField;
    qryPessoasFONE2: TStringField;
    qryPessoasCELULAR1: TStringField;
    qryPessoasCELULAR2: TStringField;
    qryPessoasEMAIL1: TStringField;
    qryPessoasEMAIL2: TStringField;
    qryPessoasFOTO: TBlobField;
    qryPessoasSEXO: TStringField;
    qryPessoasDT_NASC: TDateField;
    qryPessoasECIVIL: TStringField;
    qryPessoasDIA_PGTO: TSmallintField;
    qryPessoasOBS: TMemoField;
    qryPessoasNUM_USU: TSmallintField;
    qryPessoasFATURA: TStringField;
    qryPessoasCHEQUE: TStringField;
    qryPessoasCCF: TStringField;
    qryPessoasSPC: TStringField;
    qryPessoasISENTO: TStringField;
    qryPessoasFORN: TStringField;
    qryPessoasFUN: TStringField;
    qryPessoasCLI: TStringField;
    qryPessoasFAB: TStringField;
    qryPessoasTRAN: TStringField;
    qryPessoasADM: TStringField;
    qryPessoasATIVO: TStringField;
    qryPessoasDT_ADMISSAO: TDateField;
    qryPessoasDT_DEMISSAO: TDateField;
    qryPessoasATENDENTE: TStringField;
    qryPessoasLIMITE: TFMTBCDField;
    qryPessoasBANCO: TStringField;
    SA: TStringField;
    qryPessoasGERENTE: TStringField;
    qryPessoasFONE_GERENTE: TStringField;
    qryPessoasPROPRIEDADE: TStringField;
    qryPessoasSALARIO: TFMTBCDField;
    qryPessoasTECNICO: TStringField;
    qryProdutos: TFDQuery;
    qryProdutosCODIGO: TIntegerField;
    qryProdutosTIPO: TStringField;
    qryProdutosCODBARRA: TStringField;
    qryProdutosREFERENCIA: TStringField;
    qryProdutosGRUPO: TIntegerField;
    qryProdutosUNIDADE: TStringField;
    qryProdutosULTFORN: TIntegerField;
    qryProdutosLOCALIZACAO: TStringField;
    qryProdutosCSTICMS: TStringField;
    qryProdutosCSTE: TStringField;
    qryProdutosCSTS: TStringField;
    qryProdutosCSTIPI: TStringField;
    qryProdutosCSOSN: TStringField;
    qryProdutosNCM: TStringField;
    qryProdutosCOMISSAO: TCurrencyField;
    qryProdutosDESCONTO: TCurrencyField;
    qryProdutosFOTO: TBlobField;
    qryProdutosATIVO: TStringField;
    qryProdutosCFOP: TStringField;
    qryProdutosULT_COMPRA: TIntegerField;
    qryProdutosULT_COMPRA_ANTERIOR: TIntegerField;
    qryProdutosCOD_BARRA_ATACADO: TStringField;
    qryProdutosEMPRESA: TSmallintField;
    qryProdutosCEST: TStringField;
    qryProdutosGRADE: TStringField;
    qryProdutosEFISCAL: TStringField;
    qryProdutosPAGA_COMISSAO: TStringField;
    qryProdutosPESO: TFMTBCDField;
    qryProdutosCOMPOSICAO: TStringField;
    qryProdutosINICIO_PROMOCAO: TDateField;
    qryProdutosFIM_PROMOCAO: TDateField;
    qryProdutosESTOQUE_INICIAL: TFMTBCDField;
    qryProdutosPRECO_VARIAVEL: TStringField;
    qryProdutosAPLICACAO: TStringField;
    qryProdutosREDUCAO_BASE: TFMTBCDField;
    qryProdutosMVA: TFMTBCDField;
    qryProdutosFCP: TFMTBCDField;
    qryProdutosPRODUTO_PESADO: TStringField;
    qryProdutosSERVICO: TStringField;
    qryProdutosDESCRICAO: TStringField;
    qryProdutosDT_CADASTRO: TDateField;
    qryProdutosGRUPO_SL: TStringField;
    qryProdutosALIQ_ICM: TCurrencyField;
    qryProdutosALIQ_PIS: TCurrencyField;
    qryProdutosALIQ_COF: TCurrencyField;
    qryProdutosPR_CUSTO: TFMTBCDField;
    qryProdutosMARGEM: TCurrencyField;
    qryProdutosPR_VENDA: TFMTBCDField;
    qryProdutosQTD_ATUAL: TFMTBCDField;
    qryProdutosQTD_MIN: TFMTBCDField;
    qryProdutosE_MEDIO: TFMTBCDField;
    qryProdutosPR_CUSTO_ANTERIOR: TFMTBCDField;
    qryProdutosPR_VENDA_ANTERIOR: TFMTBCDField;
    qryProdutosPRECO_ATACADO: TFMTBCDField;
    qryProdutosQTD_ATACADO: TFMTBCDField;
    qryProdutosALIQ_IPI: TFMTBCDField;
    qryProdutosPRECO_PROMO_ATACADO: TFMTBCDField;
    qryProdutosPRECO_PROMO_VAREJO: TFMTBCDField;
    qryProdutosPR_VENDA_PRAZO: TFMTBCDField;
    qryProdutosPR_CUSTO2: TFMTBCDField;
    qryProdutosPERC_CUSTO: TFMTBCDField;
    qryCidade: TFDQuery;
    qryCidadeCODIGO: TIntegerField;
    qryCidadeDESCRICAO: TStringField;
    qryCidadeCODUF: TIntegerField;
    qryCidadeUF: TStringField;
    chkClientes: TCheckBox;
    chkProduto: TCheckBox;
    ChkCidade: TCheckBox;
    chkVendedores: TCheckBox;
    qryVendedores: TFDQuery;
    qryVendedoresCODIGO: TIntegerField;
    qryVendedoresNOME: TStringField;
    chkEmpresa: TCheckBox;
    qryEmpresa: TFDQuery;
    qryEmpresaCODIGO: TIntegerField;
    qryEmpresaFANTASIA: TStringField;
    qryEmpresaRAZAO: TStringField;
    qryEmpresaENDERECO: TStringField;
    qryEmpresaNUMERO: TStringField;
    qryEmpresaBAIRRO: TStringField;
    qryEmpresaFONE: TStringField;
    qryEmpresaCIDADE: TStringField;
    qryEmpresaUF: TStringField;
    qryEmpresaCEP: TStringField;
    qryEmpresaCNPJ: TStringField;
    qryEmpresaIE: TStringField;
    qryEmpresaCOMPLEMENTO: TStringField;
    qryEmpresaCWEB: TIntegerField;
    procedure btnSalvarClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function FormataCNPJ(const ACNPJ: string): string;
    procedure FormCreate(Sender: TObject);
  private
    vChave, vURLApi: string;
    procedure Upload;
    procedure UploadEmpresa;
    procedure UploadPessoa;
 //   procedure UploadCidade;
   // procedure UploadProduto;
    procedure UploadVendedor;
    procedure UploadImagensProdutos(ACodEmp: Integer);
    function  UploadProduto(ASincronizarImagens: Boolean = False): Boolean;
    procedure UploadProdutosBasico(ACodEmp: Integer);
    procedure RedimensionarImagem(ABitmap: TBitmap; AMaxWidth,
      AMaxHeight: Integer);

    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSincronizar: TFrmSincronizar;

implementation //Acesse lojadodesenvolvedor.com.br e saiba mais sobre esse código fonte.

{$R *.dfm}

uses uDadosWeb, Udados;


function TFrmSincronizar.FormataCNPJ(const ACNPJ: string): string;
var
  LNumerosCNPJ: string;
begin

  LNumerosCNPJ := '';
  for var I := 1 to Length(ACNPJ) do
  begin
    if (ACNPJ[I] >= '0') and (ACNPJ[I] <= '9') then
      LNumerosCNPJ := LNumerosCNPJ + ACNPJ[I];
  end;

  if Length(LNumerosCNPJ) < 14 then
    LNumerosCNPJ := LNumerosCNPJ.PadLeft(14, '0');

  if Length(LNumerosCNPJ) > 14 then
    LNumerosCNPJ := Copy(LNumerosCNPJ, 1, 14);


  if Length(LNumerosCNPJ) = 14 then
  begin
    Result := Copy(LNumerosCNPJ, 1, 2) + '.' +
              Copy(LNumerosCNPJ, 3, 3) + '.' +
              Copy(LNumerosCNPJ, 6, 3) + '/' +
              Copy(LNumerosCNPJ, 9, 4) + '-' +
              Copy(LNumerosCNPJ, 13, 2);
  end
  else
  begin
    Result := ACNPJ;
  end;
end;
procedure TFrmSincronizar.FormCreate(Sender: TObject);
var
  vConfig: TIniFile;
  vCaminho: string;
begin
  vCaminho := xApplicationPath + 'ApiEvolution.ini';
  if not FileExists(vCaminho) then
  begin
    vConfig := TIniFile.Create(vCaminho);
    try
      vConfig.WriteString('FORCA_DE_VENDAS', 'url', '');
      vConfig.WriteString('FORCA_DE_VENDAS', 'chave', '');
    finally
      vConfig.Free;
    end;
  end;
  vConfig := TIniFile.Create(vCaminho);
  try
    vURLApi := vConfig.ReadString('FORCA_DE_VENDAS', 'url', '');
    vChave  := vConfig.ReadString('FORCA_DE_VENDAS', 'chave', '');
  finally
    vConfig.Free;
  end;



end;


procedure TFrmSincronizar.UploadEmpresa;
var
  LWebCodEmp, ACodEmp: Integer;
  Mcnpj, Acnpj: string;
  qryDadosEmpresa: TFDQuery;
  qrUser, qryFormasPgto: TFDQuery;

  LSincronizador: TSincronizadorApi;
  LChaveApi: string;
begin
  if not chkEmpresa.Checked then
    Exit;

  ProgressBar1.Position := 0;
  Application.ProcessMessages;

  qryDadosEmpresa := TFDQuery.Create(nil);
  qryFormasPgto := TFDQuery.Create(nil);
  qrUser :=  TFDQuery.Create(nil);
    Acnpj :=  Dados.qryEmpresa.fieldByName('CNPJ').ASSTRING;
   LSincronizador := TSincronizadorApi.Create(Dados.Conexao, vURLApi, Acnpj, vChave );

    try
      LChaveApi := LSincronizador.ObterTokenDaApi(Acnpj, vChave);
      LSincronizador.LApiKeyJWT := LChaveApi;
    except
      on E: Exception do
      begin
        ShowMessage('Erro ao obter token: ' + E.Message);
        Exit;
      end;
    end;


  try
    try
      // 1. Buscar dados da empresa local COM ALIAS para compatibilidade com PHP
      qryDadosEmpresa.Connection := Dados.Conexao;
      qryDadosEmpresa.SQL.Text :=
        'SELECT E.CODIGO, E.CWEB, ' +
        '       E.FANTASIA AS nomefantasia, ' +
        '       E.RAZAO AS razaosocial, ' +
        '       E.ENDERECO AS endereco, ' +
        '       E.NUMERO AS End_Numero, ' +
        '       E.COMPLEMENTO AS Complemento, ' +
        '       E.BAIRRO AS Bairro, ' +
        '       E.CIDADE AS Cidade, ' +
        '       E.UF AS Uf, ' +
        '       E.CEP AS Cep, ' +
        '       E.CNPJ AS Cnpj, ' +
        '       E.IE AS Ie, ' +
        '       E.FONE AS Fone ' +
        'FROM EMPRESA E ' +
        'WHERE E.CODIGO = :CODIGO';
      qryDadosEmpresa.ParamByName('CODIGO').Value := Dados.qryEmpresa.FieldByName('CODIGO').Value;
      qryDadosEmpresa.Open;

      if qryDadosEmpresa.IsEmpty then
      begin
        ShowMessage('Empresa não encontrada!');
        Exit;
      end;

      ACodEmp := qryDadosEmpresa.FieldByName('CWEB').AsInteger;
      Acnpj := TiraAcentos(qryDadosEmpresa.FieldByName('Cnpj').AsString);
      Mcnpj := FormataCNPJ(Acnpj);

      // Buscar a chave API da empresa (você precisa ter isso cadastrado)
      // Por enquanto vou usar uma chave padrão, mas você deve buscar do banco
    //  LChaveApi := LSincronizador.LApiKeyJWT; // TODO: Buscar do banco de dados

      ProgressBar1.Max := 2; // 1 para empresa, 1 para formas de pagamento

      // 2. Buscar formas de pagamento
      qryFormasPgto.Connection := Dados.Conexao;
      qryFormasPgto.SQL.Text :=
        'SELECT CODIGO AS id, DESCRICAO as descricao, PARCELAS as parcelas ' +
        'FROM FORMA_PAGAMENTO ' +
        'WHERE ATIVO = ''S'' ' +
        'ORDER BY DESCRICAO';
      qryFormasPgto.Open;





      qrUser.Connection := Dados.Conexao;
      qruser.SQL.Text := ' SELECT ' +
        ' LOGIN AS nome, ' +
        ' SENHA_APP AS senha, ' +
        ' lower(LOGIN) || ''@vendas.com'' AS email, ' +
        ' 10.00 AS desconto_padrao, ' +  //crie uma conluna DESCONTO_PADRAO, float
        ' 1 AS permite_desconto, ' +   //crie um coluna   PERMITE_DESCONTO interger
        ' ''P'' AS tipo_desconto ' +     //crie uma coluna    TIPO_DESCONTO char
        ' FROM USUARIOS ' +
        ' WHERE ATIVO = ''S''; ';
      qruser.Open;
      with qryDadosEmpresa do
      begin
        Edit;
        FieldByName('nomefantasia').AsString := UpperCase(FieldByName('nomefantasia').AsString);
        FieldByName('razaosocial').AsString := UpperCase(FieldByName('razaosocial').AsString);
        FieldByName('endereco').AsString := UpperCase(FieldByName('endereco').AsString);
        FieldByName('Cnpj').AsString := Mcnpj;
        FieldByName('Ie').AsString := TiraPontos(FieldByName('Ie').AsString);
        Post;
      end;

      // 4. Sincronizar via API
      if LSincronizador.SincronizarEmpresa(
           Mcnpj,
           vChave,
           ACodEmp,
           qryDadosEmpresa,
           qryFormasPgto,
           qrUser,
           LWebCodEmp) then
      begin
        ProgressBar1.StepIt;

        // Atualizar CWEB na empresa local se for nova
        if (ACodEmp = 0) or (qryDadosEmpresa.FieldByName('CWEB').IsNull) then
        begin
          Dados.qryEmpresa.Edit;
          Dados.qryEmpresa.FieldByName('CWEB').AsInteger := LWebCodEmp;
          Dados.qryEmpresa.Post;
          Dados.Conexao.Commit;
        end;

        ProgressBar1.StepIt;
        ShowMessage('Empresa sincronizada com sucesso!');
      end
      else
        ShowMessage('Erro ao sincronizar empresa');

    except
      on E: Exception do
      begin
        ShowMessage('Erro durante sincronização: ' + E.Message);
        Dados.Conexao.Rollback;
      end;
    end;

  finally
    qryDadosEmpresa.Free;
    qryFormasPgto.Free;
    LSincronizador.Free;
  end;
end;




//procedure TFrmSincronizar.UploadEmpresa;
//var
//  LWebCodEmp,ACodEmp      : Integer;
//  vTotal       : Integer;
//  Mcnpj, Acnpj : string;
//begin
//  if not chkEmpresa.Checked then
//    Exit;
//
//  ProgressBar1.Position := 0;
//  Application.ProcessMessages; // Atualiza a UI imediatamente
//
//  try
//    // 1. Obter dados da empresa local
//    qryEmpresa.Close;
//    qryEmpresa.Params[0].Value := Dados.qryEmpresaCODIGO.Value; // empresa local
//    qryEmpresa.Open;
//
//    if qryEmpresa.IsEmpty then
//      Exit;
//
//    ACodEmp := qryEmpresa.FieldByName('CWEB').AsInteger; // código WEB
//    Acnpj   := TiraAcentos(qryEmpresa.FieldByName('CNPJ').AsString);
//    Mcnpj   := FormataCNPJ(Acnpj);
//
//    with Dados.qryConsulta do
//    begin
//      Close;
//      SQL.Clear;
//      SQL.Add('SELECT CODIGO, DESCRICAO, PARCELAS FROM FORMA_PAGAMENTO');
//      SQL.Add('WHERE ATIVO =''S'' ');
//      SQL.Add('ORDER BY DESCRICAO');
//      Open;
//    end;
//
//    dadosweb.cdsEmpresa.Close;
//    dadosweb.cdsEmpresa.Open;
//
//    with dadosweb.cdsformadepagemento do
//    begin
//      Close;
//      SQL.Clear;
//      SQL.Add('select * from condpgto');
//      Open;
//    end;
//
//    vTotal := qryEmpresa.RecordCount;
//    ProgressBar1.Max := vTotal;
//
//    while not qryEmpresa.Eof do
//    begin
//      if dadosweb.cdsEmpresa.Locate(
//        'Cnpj',
//        Mcnpj,
//        []) then
//        dadosweb.cdsEmpresa.Edit
//      else
//        dadosweb.cdsEmpresa.Insert;
//      dadosweb.cdsEmpresa.FieldByName('Cnpj').AsString        := Mcnpj;
//      dadosweb.cdsEmpresa.FieldByName('Ie').AsString          := TiraPontos(qryEmpresa.FieldByName('IE').AsString);
//      dadosweb.cdsEmpresa.FieldByName('nomefantasia').AsString:= UpperCase(qryEmpresa.FieldByName('FANTASIA').AsString);
//      dadosweb.cdsEmpresa.FieldByName('razaosocial').AsString := UpperCase(qryEmpresa.FieldByName('RAZAO').AsString);
//      dadosweb.cdsEmpresa.FieldByName('endereco').AsString    := UpperCase(qryEmpresa.FieldByName('ENDERECO').AsString);
//      dadosweb.cdsEmpresa.FieldByName('End_Numero').AsString  := qryEmpresa.FieldByName('NUMERO').AsString;
//      dadosweb.cdsEmpresa.FieldByName('Complemento').AsString := qryEmpresa.FieldByName('COMPLEMENTO').AsString;
//      dadosweb.cdsEmpresa.FieldByName('Bairro').AsString      := qryEmpresa.FieldByName('BAIRRO').AsString;
//      dadosweb.cdsEmpresa.FieldByName('Cidade').AsString      := qryEmpresa.FieldByName('CIDADE').AsString;
//      dadosweb.cdsEmpresa.FieldByName('Uf').AsString          := qryEmpresa.FieldByName('UF').AsString;
//      dadosweb.cdsEmpresa.FieldByName('Cep').AsString         := qryEmpresa.FieldByName('CEP').AsString;
//      dadosweb.cdsEmpresa.FieldByName('Fone').AsString        := qryEmpresa.FieldByName('FONE').AsString;
//      dadosweb.cdsEmpresa.Post;
//      if dadosweb.cdsEmpresa.ChangeCount > 0 then
//      begin
//        dadosweb.cdsEmpresa.ApplyUpdates(-1);
//        dadosweb.cdsEmpresa.Refresh;
//      end;
//      LWebCodEmp := dadosweb.cdsEmpresa.FieldByName('CODEMP').AsInteger;
//      ProgressBar1.StepIt;
//      Application.ProcessMessages;
//      qryEmpresa.Next;
//    end;
//
//    if dadosweb.cdsEmpresa.ChangeCount > 0 then
//      dadosweb.cdsEmpresa.ApplyUpdates(-1);
//
//    Dados.qryConsulta.First;
//    while not Dados.qryConsulta.Eof do
//    begin
//      if dadosweb.cdsformadepagemento.Locate(
//        'descricao',
//        Dados.qryConsulta.FieldByName('DESCRICAO').AsString,
//        []) then
//        dadosweb.cdsformadepagemento.Edit
//      else
//        dadosweb.cdsformadepagemento.Append;
//      dadosweb.cdsformadepagemento.FieldByName('codemp').AsInteger     := ACodEmp;
//      dadosweb.cdsformadepagemento.FieldByName('id').AsInteger         := Dados.qryConsulta.FieldByName('CODIGO').AsInteger;
//      dadosweb.cdsformadepagemento.FieldByName('parcelas').AsInteger   := Dados.qryConsulta.FieldByName('PARCELAS').AsInteger;
//      dadosweb.cdsformadepagemento.FieldByName('descricao').AsString   := Dados.qryConsulta.FieldByName('DESCRICAO').AsString;
//      dadosweb.cdsformadepagemento.FieldByName('last_mod').AsDateTime := Now;
//      dadosweb.cdsformadepagemento.Post;
//
//      Dados.qryConsulta.Next; // Avance para o próximo registro
//    end;
//
//    if dadosweb.cdsformadepagemento.ChangeCount > 0 then
//      dadosweb.cdsformadepagemento.ApplyUpdates(-1);
//
//
//    dadosweb.cdsConsulta.close;
//    dadosweb.cdsConsulta.SQL.Clear;
//    dadosweb.cdsConsulta.SQL.Add('select codemp, cnpj from empresas ');
//    dadosweb.cdsConsulta.SQL.Add('where cnpj = :cnpj');
//    dadosweb.cdsConsulta.ParamByName('cnpj').AsString := Mcnpj;//Dados.qryEmpresaCNPJ.AsString;
//    dadosweb.cdsConsulta.Open;
//
//    if not dadosweb.cdsConsulta.IsEmpty then
//    begin
//      if (ACodEmp = 0) or (qryEmpresa.FieldByName('CWEB').isnull) then
//      begin
//        Dados.qryempresa.Edit;
//
//        Dados.qryempresa.FieldByName('cweb').AsInteger := dadosweb.cdsConsulta.FieldByName('codemp').AsInteger;
//        Dados.qryempresa.Post;
//        Dados.Conexao.Commit;
//      end;
//    end;
//
//  except
//    on E: Exception do
//    begin
//      ShowMessage('Ocorreu um erro durante o upload da empresa: ' + E.Message);
//
//    end;
//  end;
//end;



////
//procedure TFrmSincronizar.UploadPessoa;
//var
//ACodEmp: Integer;
//begin
//  ProgressBar1.Position := 0;
//  ProgressBar1.Max := 100;
//
//  if chkClientes.Checked then
//  begin
//
//    chkClientes.Font.Style := [fsBold];
//    chkVendedores.Font.Style := [];
//    Application.ProcessMessages;
//
//    Sleep(500);
//    qryEmpresa.Close;
//    qryEmpresa.Params[0].Value := Dados.qryEmpresaCODIGO.Value;
//    qryEmpresa.Open;
//    ACodEmp := qryEmpresa.FieldByName('cweb').AsInteger;
//
//
//    qryPessoas.close;
//    qryPessoas.Params[0].AsInteger := Dados.qryEmpresaCODIGO.Value;
//    qryPessoas.Open;
//    qryPessoas.First;
//
//    dadosweb.cdsPessoas.close;
//    dadosweb.cdsPessoas.Open;
//
//     while not qryPessoas.Eof do
//    begin
//      if dadosweb.cdsPessoas.Locate('CodEmp;cpf_cnpj',
//            VarArrayOf([ACodEmp, qryPessoas.FieldByName('CNPJ').AsString]),
//            []) then
//        dadosweb.cdsPessoas.Edit
//      else
//        dadosweb.cdsPessoas.Append;
//
//      with dadosweb.cdsPessoas do
//      begin
//        FieldByName('codemp').AsInteger          := ACodEmp;
//        FieldByName('codigo').AsInteger          := qryPessoas.FieldByName('CODIGO').AsInteger;
//        FieldByName('razao_nome').AsString       := qryPessoas.FieldByName('RAZAO').AsString;
//        FieldByName('apelido_fantasia').AsString := qryPessoas.FieldByName('FANTASIA').AsString;
//        FieldByName('cpf_cnpj').AsString         := qryPessoas.FieldByName('CNPJ').AsString;
//        FieldByName('endereco').AsString         := qryPessoas.FieldByName('ENDERECO').AsString;
//        FieldByName('endereco_numero').AsString  := qryPessoas.FieldByName('NUMERO').AsString;
//        FieldByName('Complemento').AsString      := qryPessoas.FieldByName('COMPLEMENTO').AsString;
//        FieldByName('bairro').AsString           := qryPessoas.FieldByName('BAIRRO').AsString;
//        FieldByName('cep').AsString              := tirapontos(qryPessoas.FieldByName('CEP').AsString);
//        FieldByName('cidade').AsString           := qryPessoas.FieldByName('MUNICIPIO').AsString;
//        FieldByName('uf').AsString               := qryPessoas.FieldByName('UF').AsString;
//
//        if qryPessoas.FindField('TELEFONE') <> nil then
//          FieldByName('Fone').AsString := qryPessoas.FieldByName('TELEFONE').AsString;
//
//        if qryPessoas.FieldByName('CELULAR1').IsNull then
//          FieldByName('Celular').AsString := '0000000000'
//        else
//          FieldByName('Celular').AsString := qryPessoas.FieldByName('CELULAR1').AsString;
//
//        if qryPessoas.FindField('OBS') <> nil then
//          FieldByName('cli_Obs').AsString := qryPessoas.FieldByName('OBS').AsString
//        else
//          FieldByName('cli_Obs').Clear;
//
//        FieldByName('Last_mod').AsDateTime := Now;  // só a data
//        Post;  // apenas uma vez
//      end;
//
//      qryPessoas.Next;
//    end;
//
//  end;
//end;

// Adicione estas units ao seu uses, se ainda não estiverem lá
//procedure TFrmSincronizar.UploadPessoa;
//var
//  ACodEmp: Integer;
//  totalRegistros, registrosProcessados: Integer;
//  listaCodigosExistentes: THashSet<Integer>;
//  listaParaInserir: TList<Integer>;
//  listaParaAtualizar: TList<Integer>;
//  i: Integer;
//  qryTemp: TFDQuery;
//
// const
//    SQL_BUSCAR_EXISTENTES = 'SELECT codigo FROM clientes WHERE codemp = :codemp';
//    SQL_INSERT =
//      'INSERT INTO clientes (codemp, codigo, razao_nome, apelido_fantasia, cpf_cnpj, ' +
//      'endereco, endereco_numero, Complemento, bairro, cep, cidade, uf, Fone, Celular, cli_Obs, Last_mod) ' +
//      'VALUES (:codemp, :codigo, :razao_nome, :apelido_fantasia, :cpf_cnpj, ' +
//      ':endereco, :endereco_numero, :Complemento, :bairro, :cep, :cidade, :uf, :Fone, :Celular, :cli_Obs, :Last_mod)';
//    SQL_UPDATE =
//      'UPDATE clientes SET razao_nome = :razao_nome, apelido_fantasia = :apelido_fantasia, ' +
//      'cpf_cnpj = :cpf_cnpj, endereco = :endereco, endereco_numero = :endereco_numero, ' +
//      'Complemento = :Complemento, bairro = :bairro, cep = :cep, cidade = :cidade, uf = :uf, ' +
//      'Fone = :Fone, Celular = :Celular, cli_Obs = :cli_Obs, Last_mod = :Last_mod ' +
//      'WHERE codemp = :codemp AND codigo = :codigo';
//begin
//  if not chkClientes.Checked then
//    Exit;
//
//  if not DadosWeb.ConexaoAPP.Connected then
//  begin
//    ShowMessage('Conexão com o banco de dados web não está ativa.');
//    Exit;
//  end;
//  chkClientes.Font.Style := [fsBold];
//  chkVendedores.Font.Style := [];
//  Application.ProcessMessages;
//  ProgressBar1.Position := 0;
//  try
//    qryEmpresa.Close;
//    qryEmpresa.Params[0].Value := Dados.qryEmpresaCODIGO.Value;
//    qryEmpresa.Open;
//    ACodEmp := qryEmpresa.FieldByName('cweb').AsInteger;
//
//    qryPessoas.Close;
//    qryPessoas.Params[0].AsInteger := Dados.qryEmpresaCODIGO.Value;
//    qryPessoas.Open;
//    totalRegistros := qryPessoas.RecordCount;
//    ProgressBar1.Max := totalRegistros;
//
//    if totalRegistros = 0 then
//    begin
//      ShowMessage('Nenhuma pessoa encontrada para sincronizar.');
//      Exit;
//    end;
//    listaCodigosExistentes := THashSet<Integer>.Create;
//    listaParaInserir := TList<Integer>.Create;
//    listaParaAtualizar := TList<Integer>.Create;
//    qryTemp := TFDQuery.Create(nil);
//    try
//      qryTemp.Connection := DadosWeb.ConexaoAPP;
//      qryTemp.SQL.Text := SQL_BUSCAR_EXISTENTES;
//      qryTemp.ParamByName('codemp').AsInteger := ACodEmp;
//      qryTemp.Open;
//      while not qryTemp.Eof do
//      begin
//        listaCodigosExistentes.Add(qryTemp.FieldByName('codigo').AsInteger);
//        qryTemp.Next;
//      end;
//      qryTemp.Close;
//      qryPessoas.First;
//      registrosProcessados := 0;
//      while not qryPessoas.Eof do
//      begin
//        if listaCodigosExistentes.Contains(qryPessoas.FieldByName('CODIGO').AsInteger) then
//          listaParaAtualizar.Add(qryPessoas.RecNo - 1) // Guarda o índice do registro
//        else
//          listaParaInserir.Add(qryPessoas.RecNo - 1); // Guarda o índice do registro
//
//        qryPessoas.Next;
//        Inc(registrosProcessados);
//        ProgressBar1.Position := registrosProcessados;
//        Application.ProcessMessages; // Mantém a UI responsiva
//      end;
//
//      // --- 4. Execução do Array DML para INSERTS ---
//      if listaParaInserir.Count > 0 then
//      begin
//        dadosweb.cdsPessoas.Connection := DadosWeb.ConexaoAPP;
//        dadosweb.cdsPessoas.SQL.Text := SQL_INSERT;
//        dadosweb.cdsPessoas.Params.ArraySize := listaParaInserir.Count;
//
//        for i := 0 to listaParaInserir.Count - 1 do
//        begin
//          qryPessoas.RecNo := listaParaInserir[i] + 1; // Posiciona no registro correto
//          with dadosweb.cdsPessoas.Params do
//          begin
//            ParamByName('codemp').AsIntegers[i] := ACodEmp;
//            ParamByName('codigo').AsIntegers[i] := qryPessoas.FieldByName('CODIGO').AsInteger;
//            ParamByName('razao_nome').AsStrings[i] := qryPessoas.FieldByName('RAZAO').AsString;
//            ParamByName('apelido_fantasia').AsStrings[i] := qryPessoas.FieldByName('FANTASIA').AsString;
//            ParamByName('cpf_cnpj').AsStrings[i] := qryPessoas.FieldByName('CNPJ').AsString;
//            ParamByName('endereco').AsStrings[i] := qryPessoas.FieldByName('ENDERECO').AsString;
//            ParamByName('endereco_numero').AsStrings[i] := qryPessoas.FieldByName('NUMERO').AsString;
//            ParamByName('Complemento').AsStrings[i] := qryPessoas.FieldByName('COMPLEMENTO').AsString;
//            ParamByName('bairro').AsStrings[i] := qryPessoas.FieldByName('BAIRRO').AsString;
//            ParamByName('cep').AsStrings[i] := tirapontos(qryPessoas.FieldByName('CEP').AsString);
//            ParamByName('cidade').AsStrings[i] := qryPessoas.FieldByName('MUNICIPIO').AsString;
//            ParamByName('uf').AsStrings[i] := qryPessoas.FieldByName('UF').AsString;
//            ParamByName('Fone').AsStrings[i] := IfThen(qryPessoas.FindField('FONE1') <> nil, qryPessoas.FieldByName('FONE1').AsString, '');
//            ParamByName('Celular').AsStrings[i] := IfThen(qryPessoas.FieldByName('CELULAR1').IsNull, '0000000000', qryPessoas.FieldByName('CELULAR1').AsString);
//            ParamByName('cli_Obs').AsStrings[i] := IfThen(qryPessoas.FindField('OBS') <> nil, qryPessoas.FieldByName('OBS').AsString, '');
//            ParamByName('Last_mod').AsDateTimes[i] := Now;
//          end;
//        end;
//        // Executa todos os inserts de uma vez
//        dadosweb.cdsPessoas.Execute(listaParaInserir.Count);
//      end;
//
//      // --- 5. Execução do Array DML para UPDATES ---
//      if listaParaAtualizar.Count > 0 then
//      begin
//        dadosweb.cdsPessoas.SQL.Text := SQL_UPDATE;
//        dadosweb.cdsPessoas.Params.ArraySize := listaParaAtualizar.Count;
//
//        for i := 0 to listaParaAtualizar.Count - 1 do
//        begin
//          qryPessoas.RecNo := listaParaAtualizar[i] + 1; // Posiciona no registro correto
//          with dadosweb.cdsPessoas.Params do
//          begin
//            // Parâmetros do SET
//            ParamByName('razao_nome').AsStrings[i] := qryPessoas.FieldByName('RAZAO').AsString;
//            ParamByName('apelido_fantasia').AsStrings[i] := qryPessoas.FieldByName('FANTASIA').AsString;
//            ParamByName('cpf_cnpj').AsStrings[i] := qryPessoas.FieldByName('CNPJ').AsString;
//            ParamByName('endereco').AsStrings[i] := qryPessoas.FieldByName('ENDERECO').AsString;
//            ParamByName('endereco_numero').AsStrings[i] := qryPessoas.FieldByName('NUMERO').AsString;
//            ParamByName('Complemento').AsStrings[i] := qryPessoas.FieldByName('COMPLEMENTO').AsString;
//            ParamByName('bairro').AsStrings[i] := qryPessoas.FieldByName('BAIRRO').AsString;
//            ParamByName('cep').AsStrings[i] := tirapontos(qryPessoas.FieldByName('CEP').AsString);
//            ParamByName('cidade').AsStrings[i] := qryPessoas.FieldByName('MUNICIPIO').AsString;
//            ParamByName('uf').AsStrings[i] := qryPessoas.FieldByName('UF').AsString;
//            ParamByName('Fone').AsStrings[i] := IfThen(qryPessoas.FindField('FONE1') <> nil, qryPessoas.FieldByName('FONE1').AsString, '');
//            ParamByName('Celular').AsStrings[i] := IfThen(qryPessoas.FieldByName('CELULAR1').IsNull, '0000000000', qryPessoas.FieldByName('CELULAR1').AsString);
//            ParamByName('cli_Obs').AsStrings[i] := IfThen(qryPessoas.FindField('OBS') <> nil, qryPessoas.FieldByName('OBS').AsString, '');
//            ParamByName('Last_mod').AsDateTimes[i] := Now;
//            // Parâmetros do WHERE (crucial para o UPDATE funcionar!)
//            ParamByName('codemp').AsIntegers[i] := ACodEmp;
//            ParamByName('codigo').AsIntegers[i] := qryPessoas.FieldByName('CODIGO').AsInteger;
//          end;
//        end;
//        // Executa todos os updates de uma vez
//        dadosweb.cdsPessoas.Execute(listaParaAtualizar.Count);
//      end;
//
//      ShowMessage(Format('Sincronização concluída com sucesso! %d registros inseridos e %d atualizados.',
//        [listaParaInserir.Count, listaParaAtualizar.Count]));
//
//    finally
//      // Libera recursos da memória
//      listaCodigosExistentes.Free;
//      listaParaInserir.Free;
//      listaParaAtualizar.Free;
//      qryTemp.Free;
//      qryPessoas.Close;
//    end;
//
//  except
//    on E: Exception do
//    begin
//      ShowMessage('Ocorreu um erro durante a sincronização: ' + E.Message);
//      // Log do erro E.Message em um arquivo, se desejar
//    end;
//  end;
//end;



procedure TFrmSincronizar.UploadPessoa;
var
  ACodEmp: Integer;
  qryClientesAtivos: TFDQuery;
  LSincronizador: TSincronizadorApi;
  LChaveApi, LCNPJ: string;
  LTotalSincronizados: Integer;
begin
  if not chkClientes.Checked then
    Exit;

  ProgressBar1.Position := 0;
  Application.ProcessMessages;
  LCNPJ :=  Dados.qryEmpresa.fieldByName('CNPJ').ASSTRING;
  ACodEmp := Dados.qryEmpresa.FieldByName('CWEB').AsInteger;

  qryClientesAtivos := TFDQuery.Create(nil);
  try
      LSincronizador := TSincronizadorApi.Create(Dados.Conexao, vURLApi, LCNPJ, vChave );
      LChaveApi := LSincronizador.ObterTokenDaApi(LCNPJ, vChave);
      LSincronizador.LApiKeyJWT := LChaveApi;

    try
      qryClientesAtivos.Connection := Dados.Conexao;
      qryClientesAtivos.SQL.Text :=
        'SELECT ' +
        '  P.CODIGO AS codigo, ' +
        '  P.RAZAO AS razao_nome, ' +
        '  P.FANTASIA AS apelido_fantasia, ' +
        '  P.CNPJ AS cpf_cnpj, ' +
        '  P.ENDERECO AS endereco, ' +
        '  P.NUMERO AS endereco_numero, ' +
        '  P.COMPLEMENTO AS Complemento, ' +
        '  P.BAIRRO AS bairro, ' +
        '  P.CEP AS cep, ' +
        '  P.MUNICIPIO AS cidade, ' +
        '  P.UF AS uf, ' +
        '  P.FONE1 AS Fone, ' +
        '  P.CELULAR1 AS Celular, ' +
        '  P.OBS AS cli_Obs ' +
        'FROM PESSOA P ' +
        'WHERE P.EMPRESA = :CODEMP AND CLI = ''S'' ' +  // Ajuste o filtro conforme sua tabela
        'ORDER BY P.RAZAO';
      qryClientesAtivos.ParamByName('CODEMP').AsInteger := Dados.idEmpresa;
      qryClientesAtivos.Open;

      if qryClientesAtivos.IsEmpty then
      begin
        ShowMessage('Nenhum cliente encontrado!');
        Exit;
      end;

      ProgressBar1.Max := qryClientesAtivos.RecordCount;
      if LSincronizador.Sincronizar(
           LCNPJ,
           ACodEmp,
           qryClientesAtivos,
           'POST',
           'clientes/sync') then
      begin
        ProgressBar1.Position := ProgressBar1.Max;
         ShowMessage('Clientes sincronizados com sucesso!');
      end
      else
        ShowMessage('Erro ao sincronizar clientes');

    except
      on E: Exception do
      begin
        ShowMessage('Erro durante sincronização: ' + E.Message);
      end;
    end;

  finally
    qryClientesAtivos.Free;
    LSincronizador.Free;
  end;
end;

//Procedure TFrmSincronizar.UploadCidade;
//begin
//  if ChkCidade.Checked then
//  begin
//
//    chkClientes.Font.Style := [];
//    ChkCidade.Font.Style := [fsBold];
//    chkVendedores.Font.Style := [];
//    Application.ProcessMessages;
//
//    Sleep(500);
//
//    qryCidade.close;
//    qryCidade.Open;
//    qryCidade.First;
//
//    dadosweb.cdsCidade.close;
//    dadosweb.cdsCidade.Open;
//
//    while not qryCidade.Eof do
//    begin
//      if not dadosweb.cdsCidade.Locate('CODIGO', qryCidade.FieldByName('CODIGO')
//        .Value, []) then
//      begin
//        dadosweb.cdsCidade.Insert;
//        dadosweb.cdsCidade.FieldByName('CODIGO').Value :=
//          qryCidade.FieldByName('CODIGO').Value;
//        dadosweb.cdsCidade.FieldByName('descricao').Value :=
//          qryCidade.FieldByName('DESCRICAO').Value;
//        dadosweb.cdsCidade.FieldByName('coduf').Value :=
//          qryCidade.FieldByName('CODUF').Value;
//        dadosweb.cdsCidade.FieldByName('uf').Value :=
//          qryCidade.FieldByName('UF').Value;
//        dadosweb.cdsCidade.Post;
//      end;
//      qryCidade.Next;
//    end;
//  end;
//end;

//procedure TFrmSincronizar.UploadProduto;
//var
//  ACodEmp: Integer;
//begin
//  if chkProduto.Checked then
//  begin
//    // Visual feedback for the user
//    chkClientes.Font.Style := [];
//    ChkCidade.Font.Style := [];
//    chkProduto.Font.Style := [fsBold];
//    chkVendedores.Font.Style := [];
//    Application.ProcessMessages;
//    Sleep(500); // Small pause for visual effect
//
//
//    try
//      // Open qryEmpresa once
//      qryEmpresa.Close;
//      qryEmpresa.Params[0].Value := Dados.qryEmpresaCODIGO.Value;
//      qryEmpresa.Open;
//
//      ACodEmp := qryEmpresa.FieldByName('cweb').AsInteger;
//
//      // Open qryProdutos once
//      qryProdutos.close;
//      qryProdutos.Params[0].AsInteger := Dados.qryEmpresaCODIGO.Value;
//      qryProdutos.Open;
//      qryProdutos.First;
//
//      // Open ClientDataSets once before the loop for efficiency
//
//      dadosweb.cdsProdutos.Close;
//      dadosweb.cdsProdutos.Open; // Open with current data if any
//     with dadosweb.cdsprodutos_embalagens do
//     begin
//       Close;
//       SQL.Clear;
//       SQL.Add('select *  from produtos_embalagens');
//       SQL.Add('order by nome');
//       Open;
//      end;
//      //select *  from produtos_embalagens
//  //order by nome
//      //dadosweb.cdsprodutos_embalagens.Open; // Open with current data if any
//
//      while not qryProdutos.Eof do
//      begin
//        // --- Process cdsProdutos ---
//        if dadosweb.cdsProdutos.Locate(
//          'codemp;id',
//          VarArrayOf([ACodEmp, qryProdutos.FieldByName('CODIGO').AsInteger]),
//          []) then
//          dadosweb.cdsProdutos.Edit
//        else
//          dadosweb.cdsProdutos.Insert;
//
//        with dadosweb.cdsProdutos do
//        begin
//          FieldByName('codemp').AsInteger      := ACodEmp;
//          FieldByName('id').AsLargeInt         := qryProdutos.FieldByName('CODIGO').AsInteger; // Use AsInteger for consistency if CODIGO is always integer range
//          FieldByName('mercadoria').AsString    := qryProdutos.FieldByName('DESCRICAO').AsString;
//
//          // Check for field existence before accessing
//          if qryProdutos.FindField('DESCRICAO') <> nil then
//            FieldByName('apelido').AsString      := qryProdutos.FieldByName('DESCRICAO').AsString
//          else
//            FieldByName('apelido').Clear;
//
//          FieldByName('ean').AsString           := qryProdutos.FieldByName('CODBARRA').AsString;
//          FieldByName('referencia').AsString    := qryProdutos.FieldByName('REFERENCIA').AsString;
//          FieldByName('um').AsString            := qryProdutos.FieldByName('UNIDADE').AsString;
//
//          if qryProdutos.FindField('PESO') <> nil then
//            FieldByName('peso').AsFloat          := qryProdutos.FieldByName('PESO').AsFloat
//          else
//            FieldByName('peso').Clear;
//
//          // Assigning AsFloat to AsCurrency, ensure PR_VENDA has appropriate precision
//          FieldByName('preco').AsCurrency       := qryProdutos.FieldByName('PR_VENDA').AsFloat;
//
//          if qryProdutos.FindField('DESCONTO') <> nil then
//            FieldByName('descontomax').AsFloat  := qryProdutos.FieldByName('DESCONTO').AsFloat
//          else
//            FieldByName('descontomax').Clear;
//
//          if qryProdutos.FindField('FOTO') <> nil then
//            FieldByName('img1').Value           := qryProdutos.FieldByName('FOTO').Value
//          else
//            FieldByName('img1').Clear;
//
//          FieldByName('estoque').AsFloat        := qryProdutos.FieldByName('QTD_ATUAL').AsFloat;
//          FieldByName('last_mod').AsDateTime    := Now;
//          Post; // Post changes to the ClientDataSet's delta
//        end;
//
//        // --- Process cdsprodutos_embalagens ---
//        if dadosweb.cdsprodutos_embalagens.Locate(
//          'codemp;id_produto',
//          VarArrayOf([ACodEmp, qryProdutos.FieldByName('CODIGO').AsInteger]),
//          []) then
//          dadosweb.cdsprodutos_embalagens.Edit
//        else
//          dadosweb.cdsprodutos_embalagens.Insert;
//
//        with dadosweb.cdsprodutos_embalagens do
//        begin
//          FieldByName('codemp').AsInteger      := ACodEmp;
//          FieldByName('id').AsInteger          := qryProdutos.FieldByName('CODIGO').AsInteger; // Ensure 'id' type matches database
//          FieldByName('id_produto').AsLargeInt := qryProdutos.FieldByName('CODIGO').AsInteger; // Ensure 'id_produto' type matches database
//          FieldByName('nome').AsString         := qryProdutos.FieldByName('DESCRICAO').AsString;
//          FieldByName('qtd').AsFloat           := qryProdutos.FieldByName('QTD_ATUAL').AsFloat;
//          FieldByName('um').AsString           := qryProdutos.FieldByName('UNIDADE').AsString;
//          FieldByName('valor_unit').AsFloat    := qryProdutos.FieldByName('PR_VENDA').AsFloat;
//
//          FieldByName('total').AsCurrency      := (qryProdutos.FieldByName('QTD_ATUAL').AsFloat * qryProdutos.FieldByName('PR_VENDA').AsFloat);
//          FieldByName('atalho').AsCurrency     := 0;
//          FieldByName('last_mod').AsDateTime   := Now;
//          Post; // Post changes to the ClientDataSet's delta
//        end;
//
//        qryProdutos.Next;
//      end;
//
//      if dadosweb.cdsProdutos.ChangeCount > 0 then
//        dadosweb.cdsProdutos.ApplyUpdates(-1); // -1 to apply all changes
//      if dadosweb.cdsprodutos_embalagens.ChangeCount > 0 then
//        dadosweb.cdsprodutos_embalagens.ApplyUpdates(-1);
//
//    except
//      on E: Exception do
//      begin
//        ShowMessage('Ocorreu um erro durante o upload do produto: ' + E.Message);
//
//      end;
//    end;
//  end;
//end;

//procedure TFrmSincronizar.UploadProduto;
//var
//  ACodEmp: Integer;
//  I: Integer;
//  ms: TMemoryStream;
//  qrProduWeb: TFDQuery;
//begin
//  if not chkProduto.Checked then Exit;
//
//  ms := nil;
//
//  chkProduto.Font.Style := [fsBold];
//  Application.ProcessMessages;
//
//  qryEmpresa.Close;
//  qryEmpresa.Params[0].Value := Dados.qryEmpresaCODIGO.Value;
//  qryEmpresa.Open;
//  ACodEmp := qryEmpresa.FieldByName('cweb').AsInteger;
//
//  qryProdutos.Close;
//  qryProdutos.Params[0].AsInteger := Dados.qryEmpresaCODIGO.Value;
//  qryProdutos.Open;
//  qryProdutos.FetchAll;
//  if qryProdutos.IsEmpty then Exit;
//  qrProduWeb := TFDQuery.Create(nil);
//  try
//    qrProduWeb.Connection := dadosweb.ConexaoAPP;
//
//    with qrProduWeb do
//    begin
//      Close;
//      SQL.Text :=
//        ' INSERT INTO produtos ' +
//        ' (codemp, id, mercadoria, apelido, ean, referencia, um, peso, preco, descontomax, img1, estoque, last_mod) ' +
//        ' VALUES ' +
//        ' (:codemp, :id, :mercadoria, :apelido, :ean, :referencia, :um, :peso, :preco, :descontomax, :img1, :estoque, :last_mod) ' +
//        ' ON DUPLICATE KEY UPDATE ' +
//        ' mercadoria   = VALUES(mercadoria), ' +
//        ' apelido      = VALUES(apelido), ' +
//        ' ean          = VALUES(ean), ' +
//        ' referencia   = VALUES(referencia), ' +
//        ' um           = VALUES(um), ' +
//        ' peso         = VALUES(peso), ' +
//        ' preco        = VALUES(preco), ' +
//        ' descontomax  = VALUES(descontomax), ' +
//        ' img1         = VALUES(img1), ' +
//        ' estoque      = VALUES(estoque), ' +
//        ' last_mod     = VALUES(last_mod); ' ;
//
//      Params.ParamByName('img1').DataType := ftBlob;
//      Params.ArraySize := qryProdutos.RecordCount;
//      ProgressBar1.Max := qryProdutos.RecordCount;
//      qryProdutos.First;
//      for I := 0 to qryProdutos.RecordCount - 1 do
//      begin
//        ProgressBar1.Position := I + 1;
//        qryProdutos.RecNo := I + 1;
//        Params[0].AsIntegers[I]  := ACodEmp;
//        Params[1].AsIntegers[I]  := qryProdutos.FieldByName('CODIGO').AsInteger;
//        Params[2].AsStrings[I]   := qryProdutos.FieldByName('DESCRICAO').AsString;
//        Params[3].AsStrings[I]   := qryProdutos.FieldByName('DESCRICAO').AsString;
//        Params[4].AsStrings[I]   := qryProdutos.FieldByName('CODBARRA').AsString;
//        Params[5].AsStrings[I]   := qryProdutos.FieldByName('REFERENCIA').AsString;
//        Params[6].AsStrings[I]   := qryProdutos.FieldByName('UNIDADE').AsString;
//        Params[7].AsFloats[I]    := qryProdutos.FieldByName('PESO').AsFloat;
//        Params[8].AsFloats[I]    := qryProdutos.FieldByName('PR_VENDA').AsFloat;
//        Params[9].AsFloats[I]    := qryProdutos.FieldByName('DESCONTO').AsFloat;
//        if not qryProdutos.FieldByName('FOTO').IsNull then
//        begin
//          ms := TMemoryStream.Create;
//        try
//          try
//            TBlobField(qryProdutos.FieldByName('FOTO')).SaveToStream(ms);
//            ms.Position := 0;
//            Params[10].AsStreams[I] := ms;
//          except
//            ms.Free;
//            raise;
//          end;
//        finally
//            ms.Free;
//        end;
//        end
//        else
//        begin
//          Params[10].Clear;
//        end;
//
//        Params[11].AsFloats[I]   := qryProdutos.FieldByName('QTD_ATUAL').AsFloat;
//        Params[12].AsDateTimes[I]:= Now;
//        Application.ProcessMessages;
//      end;
//
//      Execute(qryProdutos.RecordCount, 0);
//    end;
//
//  finally
//    FreeAndNil(qrProduWeb);
//  end;
//end;

function TFrmSincronizar.UploadProduto(ASincronizarImagens: Boolean = False): Boolean;
var

  ACodEmp: Integer;

begin
  Result := False;
  if not chkProduto.Checked then Exit;

  try
    chkProduto.Font.Style := [fsBold];
    Application.ProcessMessages;

    qryEmpresa.Close;
    qryEmpresa.Params[0].Value := Dados.qryEmpresaCODIGO.Value;
    qryEmpresa.Open;
    ACodEmp := qryEmpresa.FieldByName('cweb').AsInteger;

    // Carrega produtos
    qryProdutos.Close;
    qryProdutos.Params[0].AsInteger := Dados.qryEmpresaCODIGO.Value;
    qryProdutos.Open;
    qryProdutos.FetchAll;


    if qryProdutos.IsEmpty then
    begin
      Result := True;
      Exit;
    end;


    UploadProdutosBasico(ACodEmp);
    if ASincronizarImagens then
      UploadImagensProdutos(ACodEmp);
    Result := True;

  except
    on E: Exception do
    begin
      ShowMessage('Erro no upload de produtos: ' + E.Message);
      Result := False;
    end;
  end;
end;

procedure TFrmSincronizar.UploadProdutosBasico(ACodEmp: Integer);
var
  qryProdutosAtivos: TFDQuery;
  qryProdutosInativos: TFDQuery;
  LSincronizador: TSincronizadorApi;
  LApiKey, LCNPJ: string;
  LTotalSincronizados, LTotalExcluidos: Integer;
begin
//  if not chkProdutos.Checked then
//    Exit;

  ProgressBar1.Position := 0;
  Application.ProcessMessages;

  qryProdutosAtivos := TFDQuery.Create(nil);
  qryProdutosInativos := TFDQuery.Create(nil);

  LCNPJ := Dados.qryEmpresa.FieldByName('CNPJ').AsString;


   LSincronizador := TSincronizadorApi.Create(Dados.Conexao, vURLApi, LCNPJ, vChave );

   LApiKey := LSincronizador.ObterTokenDaApi(LCNPJ, vChave);
   LSincronizador.LApiKeyJWT := LApiKey;


  try
    try
      // Buscar CNPJ e Chave API da empresa
      // 1. Buscar produtos ATIVOS com ALIAS para compatibilidade com PHP
      qryProdutosAtivos.Connection := Dados.Conexao;
      qryProdutosAtivos.SQL.Text :=
        'SELECT ' +
        '  P.CODIGO AS id, ' +
        '  P.DESCRICAO AS mercadoria, ' +
        '  P.DESCRICAO AS apelido, ' +
        '  P.CODBARRA AS ean, ' +
        '  P.REFERENCIA AS referencia, ' +
        '  P.UNIDADE AS um, ' +
        '  P.PESO AS peso, ' +
        '  P.PR_VENDA AS preco, ' +
        '  P.DESCONTO AS descontomax, ' +
        '  P.QTD_ATUAL AS estoque ' +
        'FROM PRODUTO P ' +
        'WHERE P.ATIVO = ''S'' AND P.RESTAUTANTE = ''S'' AND P.EMPRESA = :CODEMP ' +
        'ORDER BY P.DESCRICAO';

      qryProdutosAtivos.ParamByName('CODEMP').AsInteger := Dados.idEmpresa;
      qryProdutosAtivos.Open;

      if qryProdutosAtivos.IsEmpty then
      begin
        ShowMessage('Nenhum produto ativo encontrado!');
        Exit;
      end;

      // 2. Buscar produtos INATIVOS (para excluir)
      qryProdutosInativos.Connection := Dados.Conexao;
      qryProdutosInativos.SQL.Text :=
        'SELECT CODIGO AS id FROM PRODUTO WHERE ATIVO = ''N'' OR RESTAUTANTE = ''N''  AND EMPRESA = :CODEMP  ';
      qryProdutosInativos.ParamByName('CODEMP').AsInteger := Dados.idEmpresa;
      qryProdutosInativos.Open;

      ProgressBar1.Max := qryProdutosAtivos.RecordCount;

      // 3. Sincronizar via API
      if LSincronizador.SincronizarProdutos(
           LCNPJ,
           ACodEmp,
           qryProdutosAtivos,
           qryProdutosInativos,
           LTotalSincronizados,
           LTotalExcluidos) then
      begin
        ProgressBar1.Position := ProgressBar1.Max;
        ShowMessage(
          Format('Sincronização concluída!' + sLineBreak +
                 'Produtos sincronizados: %d' + sLineBreak +
                 'Produtos excluídos: %d',
                 [LTotalSincronizados, LTotalExcluidos])
        );
      end
      else
        ShowMessage('Erro ao sincronizar produtos');

    except
      on E: Exception do
      begin
        ShowMessage('Erro durante sincronização: ' + E.Message);
      end;
    end;

  finally
    qryProdutosAtivos.Free;
    qryProdutosInativos.Free;
    LSincronizador.Free;
  end;
end;


procedure TFrmSincronizar.UploadImagensProdutos(ACodEmp: Integer);
const
  MAX_SIZE_BYTES = 64000; // ~64KB
  MAX_WIDTH = 800;
  MAX_HEIGHT = 800;
var
  I: Integer;
  msOriginal, msCompactada: TMemoryStream;
  jpg: TJPEGImage;
  png: TPngImage;
  bmp: TBitmap;
  Qualidade: Integer;
  LSincronizador: TSincronizadorApi;
  LCNPJ, LChaveApi: string;
  LProdutoID: Integer;
  LTotalEnviados, LTotalErros: Integer;
begin
//  if not chkImagensProdutos.Checked then
//    Exit;

  qryProdutos.Filtered := False;
  qryProdutos.Filter := 'FOTO IS NOT NULL';
  qryProdutos.Filtered := True;

  if qryProdutos.IsEmpty then
  begin
    ShowMessage('Nenhuma imagem para sincronizar!');
    Exit;
  end;

  // Buscar CNPJ e Chave API da empresa
  LCNPJ := Dados.qryEmpresa.FieldByName('CNPJ').AsString;

  LSincronizador := TSincronizadorApi.Create(Dados.Conexao, vURLApi, LCNPJ, vChave );

   LChaveApi := LSincronizador.ObterTokenDaApi(LCNPJ, vChave);
   LSincronizador.LApiKeyJWT := LChaveApi;

  try
    ProgressBar1.Max := qryProdutos.RecordCount;
    ProgressBar1.Position := 0;

    qryProdutos.First;
    I := 0;
    LTotalEnviados := 0;
    LTotalErros := 0;

    while not qryProdutos.EOF do
    begin
      ProgressBar1.Position := I + 1;
      Application.ProcessMessages;

      if not qryProdutos.FieldByName('FOTO').IsNull then
      begin
        msOriginal := TMemoryStream.Create;
        msCompactada := TMemoryStream.Create;
        bmp := TBitmap.Create;
        jpg := TJPEGImage.Create;
        png := TPngImage.Create;

        try
          try
            // Carrega o blob original
            TBlobField(qryProdutos.FieldByName('FOTO')).SaveToStream(msOriginal);
           // TBlobField(qryProdutos.FieldByName('FOTO')).SaveToStream(msOriginal);
            msOriginal.Position := 0;

            // Detecta e carrega o formato da imagem
            try
              png.LoadFromStream(msOriginal);
              bmp.Assign(png);
            except
              msOriginal.Position := 0;
              try
                jpg.LoadFromStream(msOriginal);
                bmp.Assign(jpg);
              except
                msOriginal.Position := 0;
                try
                  bmp.LoadFromStream(msOriginal);
                except
                  // Se falhar, pula esta imagem
                  Inc(LTotalErros);
                  qryProdutos.Next;
                  Continue;
                end;
              end;
            end;

            // REDIMENSIONA se a imagem for muito grande
            if (bmp.Width > MAX_WIDTH) or (bmp.Height > MAX_HEIGHT) then
            begin
              RedimensionarImagem(bmp, MAX_WIDTH, MAX_HEIGHT);
            end;

            // COMPRIME com ajuste automático de qualidade
            Qualidade := 70; // Começa com qualidade 70

            repeat
              msCompactada.Clear;
              msCompactada.Position := 0;

              jpg.Assign(bmp);
              jpg.CompressionQuality := Qualidade;
              jpg.SaveToStream(msCompactada);

              // Se ainda está muito grande, reduz a qualidade
              if (msCompactada.Size > MAX_SIZE_BYTES) and (Qualidade > 20) then
                Qualidade := Qualidade - 10
              else
                Break; // Tamanho OK ou qualidade mínima atingida

            until Qualidade < 20;

            // Se AINDA estiver grande, redimensiona mais
            if msCompactada.Size > MAX_SIZE_BYTES then
            begin
              RedimensionarImagem(bmp, MAX_WIDTH div 2, MAX_HEIGHT div 2);

              msCompactada.Clear;
              jpg.Assign(bmp);
              jpg.CompressionQuality := 40;
              jpg.SaveToStream(msCompactada);
            end;

            // Enviar via API
            msCompactada.Position := 0;
            LProdutoID := qryProdutos.FieldByName('CODIGO').AsInteger;

            if LSincronizador.EnviarImagemProduto(
                 LCNPJ,
                 ACodEmp,
                 LProdutoID,
                 msCompactada) then
            begin
              Inc(LTotalEnviados);
            end
            else
            begin
              Inc(LTotalErros);
            end;

          except
            on E: Exception do
            begin
              Inc(LTotalErros);
              // Log do erro (opcional)
              // ShowMessage('Erro ao processar imagem ID ' +
              //   qryProdutos.FieldByName('CODIGO').AsString + ': ' + E.Message);
            end;
          end;

        finally
          msOriginal.Free;
          msCompactada.Free;
          bmp.Free;
          jpg.Free;
          png.Free;
        end;
      end;

      Inc(I);
      qryProdutos.Next;
    end;

    // Exibir resultado
    ShowMessage(
      Format('Sincronização de imagens concluída!' + sLineBreak +
             'Imagens enviadas: %d' + sLineBreak +
             'Erros: %d',
             [LTotalEnviados, LTotalErros])
    );

  finally
    LSincronizador.Free;
    qryProdutos.Filtered := False;
  end;
end;


//procedure TFrmSincronizar.UploadProdutosBasico(ACodEmp: Integer);
//var
//  AProdLocal,
//  AprodWeb:TFDQuery;
//
//  I: Integer;
//
//begin
//
//  AProdLocal := TFDQuery.Create(nil);
//  AprodWeb := TFDQuery.Create(nil);
//  try
//    AProdLocal.Connection := dados.Conexao;
//    AprodWeb.Connection    := dadosweb.ConexaoAPP;  // <-- banco web
//
//    AProdLocal.SQL.Text := 'SELECT CODIGO FROM PRODUTO WHERE ATIVO = ''N''';
//    AProdLocal.Open;
//
//    if not AProdLocal.IsEmpty then
//    begin
//      AprodWeb.SQL.Text := 'DELETE FROM produtos WHERE id = :id';
//
//      AProdLocal.First;
//      while not AProdLocal.Eof do
//      begin
//        AprodWeb.ParamByName('id').AsInteger := AProdLocal.FieldByName('CODIGO').AsInteger;
//        AprodWeb.ExecSQL;
//
//        AProdLocal.Next;
//      end;
//    end;
//
//  finally
//    AprodWeb.Free;
//    AProdLocal.Free;
//  end;
//
//
//
//  with TFDQuery.Create(nil) do
//  try
//    Connection := dadosweb.ConexaoAPP;
//
//    Close;
//   SQL.Text :=
//      ' INSERT INTO produtos ' +
//      ' (codemp, id, mercadoria, apelido, ean, referencia, um, peso, preco, descontomax, img1, estoque, last_mod) ' +
//      ' VALUES ' +
//      ' (:codemp, :id, :mercadoria, :apelido, :ean, :referencia, :um, :peso, :preco, :descontomax, :img1, :estoque, :last_mod) ' +
//      ' ON DUPLICATE KEY UPDATE ' +
//      ' mercadoria   = VALUES(mercadoria), ' +
//      ' apelido      = VALUES(apelido), ' +
//      ' ean          = VALUES(ean), ' +
//      ' referencia   = VALUES(referencia), ' +
//      ' um           = VALUES(um), ' +
//      ' peso         = VALUES(peso), ' +
//      ' preco        = VALUES(preco), ' +
//      ' descontomax  = VALUES(descontomax), ' +
//      ' estoque      = VALUES(estoque), ' +
//      ' last_mod     = VALUES(last_mod); ' ;
//
//    Params.ParamByName('img1').DataType := ftBlob;
//
//    Params.ArraySize := qryProdutos.RecordCount;
//    ProgressBar1.Max := qryProdutos.RecordCount;
//
//
//    qryProdutos.First;
//    for I := 0 to qryProdutos.RecordCount - 1 do
//    begin
//      ProgressBar1.Position := I + 1;
//      qryProdutos.RecNo := I + 1;
//
//      Params[0].AsIntegers[I]  := ACodEmp;
//      Params[1].AsIntegers[I]  := qryProdutos.FieldByName('CODIGO').AsInteger;
//      Params[2].AsStrings[I]   := qryProdutos.FieldByName('DESCRICAO').AsString;
//      Params[3].AsStrings[I]   := qryProdutos.FieldByName('DESCRICAO').AsString;
//      Params[4].AsStrings[I]   := qryProdutos.FieldByName('CODBARRA').AsString;
//      Params[5].AsStrings[I]   := qryProdutos.FieldByName('REFERENCIA').AsString;
//      Params[6].AsStrings[I]   := qryProdutos.FieldByName('UNIDADE').AsString;
//      Params[7].AsFloats[I]    := qryProdutos.FieldByName('PESO').AsFloat;
//      Params[8].AsFloats[I]    := qryProdutos.FieldByName('PR_VENDA').AsFloat;
//      Params[9].AsFloats[I]    := qryProdutos.FieldByName('DESCONTO').AsFloat;
//      Params[10].Clear;
//      Params[11].AsFloats[I]   := qryProdutos.FieldByName('QTD_ATUAL').AsFloat;
//      Params[12].AsDateTimes[I]:= Now;
//
//      Application.ProcessMessages;
//    end;
//
//    Execute(qryProdutos.RecordCount, 0);
//
//  finally
//    Free;
//  end;
//end;
//procedure TFrmSincronizar.UploadImagensProdutos(ACodEmp: Integer);
//var
//  I: Integer;
//  ms: TMemoryStream;
//  qrUpdateImg: TFDQuery;
//begin
//  qryProdutos.Filtered := False;
//  qryProdutos.Filter := 'FOTO IS NOT NULL';
//  qryProdutos.Filtered := True;
//
//  if qryProdutos.IsEmpty then Exit;
//
//  qrUpdateImg := TFDQuery.Create(nil);
//  try
//    qrUpdateImg.Connection := dadosweb.ConexaoAPP;
//
//    with qrUpdateImg do
//    begin
//      Close;
//      SQL.Text := 'UPDATE produtos SET img1 = :img1, last_mod = :last_mod WHERE id = :id AND codemp = :codemp';
//
//      ProgressBar1.Max := qryProdutos.RecordCount;
//      ProgressBar1.Position := 0;
//
//      qryProdutos.First;
//      I := 0;
//      while not qryProdutos.EOF do
//      begin
//        ProgressBar1.Position := I + 1;
//
//        if not qryProdutos.FieldByName('FOTO').IsNull then
//        begin
//          ms := TMemoryStream.Create;
//          try
//            TBlobField(qryProdutos.FieldByName('FOTO')).SaveToStream(ms);
//            ms.Position := 0;
//
//            Params.ParamByName('img1').LoadFromStream(ms, ftBlob);
//            Params.ParamByName('last_mod').AsDateTime := Now;
//            Params.ParamByName('id').AsInteger := qryProdutos.FieldByName('CODIGO').AsInteger;
//            Params.ParamByName('codemp').AsInteger := ACodEmp;
//
//            ExecSQL;
//          finally
//            ms.Free;
//          end;
//        end;
//
//        Inc(I);
//        qryProdutos.Next;
//        Application.ProcessMessages;
//      end;
//    end;
//
//  finally
//    FreeAndNil(qrUpdateImg);
//  end;
//
//  // Remove filtro
//  qryProdutos.Filtered := False;
//end;

//procedure TFrmSincronizar.UploadImagensProdutos(ACodEmp: Integer);
//var
//  I: Integer;
//  msOriginal, msCompactada: TMemoryStream;
//  qrUpdateImg: TFDQuery;
//  jpg: TJPEGImage;
//  png: TPngImage;
//  bmp: TBitmap;
//begin
//  qryProdutos.Filtered := False;
//  qryProdutos.Filter := 'FOTO IS NOT NULL';
//  qryProdutos.Filtered := True;
//
//  if qryProdutos.IsEmpty then Exit;
//
//  qrUpdateImg := TFDQuery.Create(nil);
//  try
//    qrUpdateImg.Connection := dadosweb.ConexaoAPP;
//
//    qrUpdateImg.SQL.Text :=
//      'UPDATE produtos ' +
//      'SET img1 = :img1, last_mod = :last_mod ' +
//      'WHERE id = :id AND codemp = :codemp';
//
//    ProgressBar1.Max := qryProdutos.RecordCount;
//    ProgressBar1.Position := 0;
//
//    qryProdutos.First;
//    I := 0;
//    while not qryProdutos.EOF do
//    begin
//      ProgressBar1.Position := I + 1;
//
//      if not qryProdutos.FieldByName('FOTO').IsNull then
//      begin
//        msOriginal := TMemoryStream.Create;
//        msCompactada := TMemoryStream.Create;
//        bmp := TBitmap.Create;
//        jpg := TJPEGImage.Create;
//        png := TPngImage.Create;
//        try
//          // Carrega o blob original
//          TBlobField(qryProdutos.FieldByName('FOTO')).SaveToStream(msOriginal);
//          msOriginal.Position := 0;
//
//          // Tenta detectar o formato da imagem
//          try
//            // Tenta PNG primeiro
//            png.LoadFromStream(msOriginal);
//            bmp.Assign(png);
//          except
//            msOriginal.Position := 0;
//            try
//              jpg.LoadFromStream(msOriginal);
//              bmp.Assign(jpg);
//            except
//              msOriginal.Position := 0;
//              bmp.LoadFromStream(msOriginal); // fallback
//            end;
//          end;
//
//          // Compacta em JPEG com qualidade reduzida (70%)
//          jpg.Assign(bmp);
//          jpg.CompressionQuality := 50;
//          jpg.SaveToStream(msCompactada);
//
//          msCompactada.Position := 0;
//          qrUpdateImg.Params.ParamByName('img1').LoadFromStream(msCompactada, ftBlob);
//          qrUpdateImg.Params.ParamByName('last_mod').AsDateTime := Now;
//          qrUpdateImg.Params.ParamByName('id').AsInteger := qryProdutos.FieldByName('CODIGO').AsInteger;
//          qrUpdateImg.Params.ParamByName('codemp').AsInteger := ACodEmp;
//
//          qrUpdateImg.ExecSQL;
//        finally
//          msOriginal.Free;
//          msCompactada.Free;
//          bmp.Free;
//          jpg.Free;
//          png.Free;
//        end;
//      end;
//
//      Inc(I);
//      qryProdutos.Next;
//      Application.ProcessMessages;
//    end;
//  finally
//    qrUpdateImg.Free;
//  end;
//
//  qryProdutos.Filtered := False;
//end;

//procedure TFrmSincronizar.UploadImagensProdutos(ACodEmp: Integer);
//const
//  MAX_SIZE_BYTES = 64000; // ~64KB
//  MAX_WIDTH = 800;
//  MAX_HEIGHT = 800;
//var
//  I: Integer;
//  msOriginal, msCompactada: TMemoryStream;
//  qrUpdateImg: TFDQuery;
//  jpg: TJPEGImage;
//  png: TPngImage;
//  bmp: TBitmap;
//  Qualidade: Integer;
//begin
//  qryProdutos.Filtered := False;
//  qryProdutos.Filter := 'FOTO IS NOT NULL';
//  qryProdutos.Filtered := True;
//
//  if qryProdutos.IsEmpty then Exit;
//
//  qrUpdateImg := TFDQuery.Create(nil);
//  try
//    qrUpdateImg.Connection := dadosweb.ConexaoAPP;
//
//    qrUpdateImg.SQL.Text :=
//      'UPDATE produtos ' +
//      'SET img1 = :img1, last_mod = :last_mod ' +
//      'WHERE id = :id AND codemp = :codemp';
//
//    ProgressBar1.Max := qryProdutos.RecordCount;
//    ProgressBar1.Position := 0;
//
//    qryProdutos.First;
//    I := 0;
//
//    while not qryProdutos.EOF do
//    begin
//      ProgressBar1.Position := I + 1;
//
//      if not qryProdutos.FieldByName('FOTO').IsNull then
//      begin
//        msOriginal := TMemoryStream.Create;
//        msCompactada := TMemoryStream.Create;
//        bmp := TBitmap.Create;
//        jpg := TJPEGImage.Create;
//        png := TPngImage.Create;
//
//        try
//          // Carrega o blob original
//          TBlobField(qryProdutos.FieldByName('FOTO')).SaveToStream(msOriginal);
//          msOriginal.Position := 0;
//
//          // Detecta e carrega o formato da imagem
//          try
//            png.LoadFromStream(msOriginal);
//            bmp.Assign(png);
//          except
//            msOriginal.Position := 0;
//            try
//              jpg.LoadFromStream(msOriginal);
//              bmp.Assign(jpg);
//            except
//              msOriginal.Position := 0;
//              try
//                bmp.LoadFromStream(msOriginal);
//              except
//                // Se falhar, pula esta imagem
//                qryProdutos.Next;
//                Continue;
//              end;
//            end;
//          end;
//
//          // **REDIMENSIONA se a imagem for muito grande**
//          if (bmp.Width > MAX_WIDTH) or (bmp.Height > MAX_HEIGHT) then
//          begin
//            RedimensionarImagem(bmp, MAX_WIDTH, MAX_HEIGHT);
//          end;
//
//          // **COMPRIME com ajuste automático de qualidade**
//          Qualidade := 70; // Começa com qualidade 70
//
//          repeat
//            msCompactada.Clear;
//            msCompactada.Position := 0;
//
//            jpg.Assign(bmp);
//            jpg.CompressionQuality := Qualidade;
//            jpg.SaveToStream(msCompactada);
//
//            // Se ainda está muito grande, reduz a qualidade
//            if (msCompactada.Size > MAX_SIZE_BYTES) and (Qualidade > 20) then
//              Qualidade := Qualidade - 10
//            else
//              Break; // Tamanho OK ou qualidade mínima atingida
//
//          until Qualidade < 20;
//
//          // **Se AINDA estiver grande, redimensiona mais**
//          if msCompactada.Size > MAX_SIZE_BYTES then
//          begin
//            RedimensionarImagem(bmp, MAX_WIDTH div 2, MAX_HEIGHT div 2);
//
//            msCompactada.Clear;
//            jpg.Assign(bmp);
//            jpg.CompressionQuality := 40;
//            jpg.SaveToStream(msCompactada);
//          end;
//
//          // Atualiza no banco
//          msCompactada.Position := 0;
//          qrUpdateImg.Params.ParamByName('img1').LoadFromStream(msCompactada, ftBlob);
//          qrUpdateImg.Params.ParamByName('last_mod').AsDateTime := Now;
//          qrUpdateImg.Params.ParamByName('id').AsInteger := qryProdutos.FieldByName('CODIGO').AsInteger;
//          qrUpdateImg.Params.ParamByName('codemp').AsInteger := ACodEmp;
//
//          qrUpdateImg.ExecSQL;
//
//        except
//          on E: Exception do
//          begin
////             Log do erro (opcional)
//             ShowMessage('Erro ao processar imagem ID ' +
//               qryProdutos.FieldByName('CODIGO').AsString + ': ' + E.Message);
//          end;
//        end;
//
//        msOriginal.Free;
//        msCompactada.Free;
//        bmp.Free;
//        jpg.Free;
//        png.Free;
//      end;
//
//      Inc(I);
//      qryProdutos.Next;
//      Application.ProcessMessages;
//    end;
//
//  finally
//    qrUpdateImg.Free;
//  end;
//
//  qryProdutos.Filtered := False;
//end;

// **FUNÇÃO AUXILIAR para redimensionar mantendo proporção**
procedure TFrmSincronizar.RedimensionarImagem(ABitmap: TBitmap; AMaxWidth, AMaxHeight: Integer);
var
  NovaLargura, NovaAltura: Integer;
  Proporcao: Double;
  bmpTemp: TBitmap;
begin
  if (ABitmap.Width <= AMaxWidth) and (ABitmap.Height <= AMaxHeight) then
    Exit;

  // Calcula proporção
  if ABitmap.Width > ABitmap.Height then
  begin
    Proporcao := AMaxWidth / ABitmap.Width;
    NovaLargura := AMaxWidth;
    NovaAltura := Round(ABitmap.Height * Proporcao);
  end
  else
  begin
    Proporcao := AMaxHeight / ABitmap.Height;
    NovaAltura := AMaxHeight;
    NovaLargura := Round(ABitmap.Width * Proporcao);
  end;

  bmpTemp := TBitmap.Create;
  try
    bmpTemp.Width := NovaLargura;
    bmpTemp.Height := NovaAltura;

    // Redimensiona com qualidade
    bmpTemp.Canvas.StretchDraw(Rect(0, 0, NovaLargura, NovaAltura), ABitmap);

    ABitmap.Assign(bmpTemp);
  finally
    bmpTemp.Free;
  end;
end;




procedure TFrmSincronizar.UploadVendedor;
var
  ACodEmp: Integer;
begin
  if chkVendedores.Checked then
  begin
    chkClientes.Font.Style := [];
    ChkCidade.Font.Style   := [];
    chkProduto.Font.Style  := [];
    chkVendedores.Font.Style := [fsBold];
    Application.ProcessMessages;

    try
    qryEmpresa.Close;
    qryEmpresa.Params[0].Value := Dados.qryEmpresaCODIGO.Value;
    qryEmpresa.Open;
    ACodEmp := qryEmpresa.FieldByName('cweb').AsInteger;

    qryVendedores.Close;
    qryVendedores.Params[0].AsInteger := Dados.qryEmpresaCODIGO.Value;
    qryVendedores.Open;


   with Dados.qryConsulta do
   begin
     Close;
     SQL.Clear;
     SQL.add('select CODIGO, LOGIN, SENHA_APP from USUARIOS');
     SQL.add('where ativo = ''S''');
     Open;
   end;

   with dadosweb.cdsVendedor do
    begin
      Close;
      SQL.Clear;
      SQL.add('select * from vendedores');
      SQL.add('order by nome');
      Open;
    end;

    with dadosweb.cdsUsuarios do
    begin
      Close;
      SQL.Clear;
      SQL.add('select * from usuarios');
      SQL.add('order by nome');
      Open;
    end;

    qryVendedores.First;
    while not qryVendedores.Eof do
    begin
      if dadosweb.cdsVendedor.Locate(
           'codemp;id',
           VarArrayOf([ACodEmp, qryVendedores.FieldByName('codigo').AsInteger]),
           []) then
        dadosweb.cdsVendedor.Edit
      else
        dadosweb.cdsVendedor.Insert;

      with dadosweb.cdsVendedor do
      begin
        FieldByName('codemp').AsInteger    := ACodEmp;
        FieldByName('id').AsInteger        := qryVendedores.FieldByName('codigo').AsInteger;
        FieldByName('nome').AsString       := qryVendedores.FieldByName('nome').AsString;
        FieldByName('last_mod').AsDateTime := Now;
        Post;
      end;
      qryVendedores.Next;

    end;

    Dados.qryConsulta.First;

    while not Dados.qryConsulta.Eof do
    begin
     if dadosweb.cdsUsuarios.Locate('codemp;id',
     VarArrayOf([ACodEmp, Dados.qryConsulta.FieldByName('codigo').AsInteger]),
     [])then
      dadosweb.cdsUsuarios.Edit
      else
     dadosweb.cdsUsuarios.Append;
     with dadosweb.cdsUsuarios do
     begin
      FieldByName('codemp').AsInteger    := ACodEmp;
      FieldByName('id').AsInteger        := Dados.qryConsulta.FieldByName('CODIGO').AsInteger;
      FieldByName('nome').AsString       := Dados.qryConsulta.FieldByName('LOGIN').AsString;
      FieldByName('email').AsString      :=  Dados.qryConsulta.FieldByName('LOGIN').AsString + '@s6.com';
      FieldByName('senha').AsString      :=  Dados.qryConsulta.FieldByName('SENHA_APP').AsString;
      FieldByName('last_mod').AsDateTime := Now;
      Post;
     end;

     Dados.qryConsulta.Next;
    end;

    if dadosweb.cdsVendedor.ChangeCount > 0 then
        dadosweb.cdsVendedor.ApplyUpdates(-1);
    if dadosweb.cdsUsuarios.ChangeCount > 0 then
        dadosweb.cdsUsuarios.ApplyUpdates(-1);


    except
      on E: Exception do
      begin
        ShowMessage('Ocorreu um erro durante o upload dos Vendedores: ' + E.Message);
      end;
    end;
  end;
end;

//procedure TFrmSincronizar.UploadVendedor;
//begin
//  if chkVendedores.Checked then
//  begin
//    chkClientes.Font.Style := [];
//    ChkCidade.Font.Style := [];
//    chkProduto.Font.Style := [];
//    chkVendedores.Font.Style := [fsBold];
//    Application.ProcessMessages;
//
//    qryVendedores.close;
//    qryVendedores.Open;
//    qryVendedores.First;
//
//    dadosweb.cdsVendedor.close;
//    dadosweb.cdsVendedor.Open;
//
//    while not qryVendedores.Eof do
//    begin
//      if dadosweb.cdsVendedor.Locate('codigo', qryVendedores.FieldByName('codigo')
//        .Value, []) then
//        dadosweb.cdsVendedor.Edit
//      else
//        dadosweb.cdsVendedor.Insert;
//      dadosweb.cdsVendedor.FieldByName('codigo').Value :=
//        qryVendedores.FieldByName('CODIGO').Value;
//      dadosweb.cdsVendedor.FieldByName('nome').Value :=
//        qryVendedores.FieldByName('NOME').Value;
////      dadosweb.cdsVendedor.FieldByName('GID').Value :=
////        qryVendedores.FieldByName('GID').Value;
//      dadosweb.cdsVendedor.Post;
//      qryVendedores.Next;
//    end;
//  end;
//end;

procedure TFrmSincronizar.FormActivate(Sender: TObject);
begin
  dados.vForm := nil;
  dados.vForm := self;
  dados.GetComponentes;
end;

procedure TFrmSincronizar.FormShow(Sender: TObject);
begin
  chkEmpresa.Checked := True;

end;

procedure TFrmSincronizar.Upload;
var
  cont: integer;
  bSucessoProd: Boolean;
begin

  // sincronizar pessoas

  UploadEmpresa;
  Application.ProcessMessages;
  ProgressBar1.Position := 15;
  Sleep(500);

  UploadPessoa;
  Application.ProcessMessages;
  ProgressBar1.Position := 25;
  Sleep(500);

//  UploadCidade;
//  Application.ProcessMessages;
//  ProgressBar1.Position := 50;
//  Sleep(500);

  bSucessoProd := UploadProduto(True);
  if bSucessoProd then
 ShowMessage('Produtos Sincronizados com Sucesso!');
  Application.ProcessMessages;
  ProgressBar1.Position := 75;
  Sleep(500);

  UploadVendedor;
  Application.ProcessMessages;
  ProgressBar1.Position := 100;

  Application.ProcessMessages;
  ShowMessage('Sincronização Conluida!');
end;

procedure TFrmSincronizar.btnSalvarClick(Sender: TObject);
begin
  try
    btnSalvar.Enabled := false;
    try
      dadosweb.ConexaoApp.close;
      dadosweb.ConexaoApp.Open;
      if dadosweb.ConexaoApp.Connected then
      begin
        Upload;
      end;

    except
      on e: Exception do
        raise Exception.Create
          ('Erro de conexão com o banco de dados do servidor ' + e.Message);
    end;
  finally
    ChkCidade.Font.Style := [];
    chkProduto.Font.Style := [];
    chkClientes.Font.Style := [];
    chkVendedores.Font.Style := [];
    btnSalvar.Enabled := true;
  end;
end;

end.
