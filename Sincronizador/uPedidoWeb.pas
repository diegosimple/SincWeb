unit uPedidoWeb;

interface //Suporte e Vendas direto no Whatsapp (48)998463846

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, acbrutil,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.DBCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids , uSincronizadorApi , System.JSON, System.NetEncoding , System.IniFiles;

type
  TFrmPedidoWeb = class(TForm)
    Panel2: TPanel;
    btnSalvar: TButton;
    DBGrid1: TDBGrid;
    btnAtualizar: TButton;
    dsOrc: TDataSource;
    qryBuscaCliente: TFDQuery;
    qryBuscaClienteEMPRESA: TSmallintField;
    qryBuscaClienteCODIGO: TIntegerField;
    qryBuscaClienteTIPO: TStringField;
    qryBuscaClienteCNPJ: TStringField;
    qryBuscaClienteIE: TStringField;
    qryBuscaClienteFANTASIA: TStringField;
    qryBuscaClienteRAZAO: TStringField;
    qryBuscaClienteENDERECO: TStringField;
    qryBuscaClienteNUMERO: TStringField;
    qryBuscaClienteCOMPLEMENTO: TStringField;
    qryBuscaClienteCODMUN: TIntegerField;
    qryBuscaClienteMUNICIPIO: TStringField;
    qryBuscaClienteBAIRRO: TStringField;
    qryBuscaClienteUF: TStringField;
    qryBuscaClienteCEP: TStringField;
    qryBuscaClienteFONE1: TStringField;
    qryBuscaClienteFONE2: TStringField;
    qryBuscaClienteCELULAR1: TStringField;
    qryBuscaClienteCELULAR2: TStringField;
    qryBuscaClienteEMAIL1: TStringField;
    qryBuscaClienteEMAIL2: TStringField;
    qryBuscaClienteFOTO: TBlobField;
    qryBuscaClienteSEXO: TStringField;
    qryBuscaClienteDT_NASC: TDateField;
    qryBuscaClienteECIVIL: TStringField;
    qryBuscaClienteLIMITE: TFMTBCDField;
    qryBuscaClienteDIA_PGTO: TSmallintField;
    qryBuscaClienteOBS: TMemoField;
    qryBuscaClienteNUM_USU: TSmallintField;
    qryBuscaClienteFATURA: TStringField;
    qryBuscaClienteCHEQUE: TStringField;
    qryBuscaClienteCCF: TStringField;
    qryBuscaClienteSPC: TStringField;
    qryBuscaClienteISENTO: TStringField;
    qryBuscaClienteFORN: TStringField;
    qryBuscaClienteFUN: TStringField;
    qryBuscaClienteCLI: TStringField;
    qryBuscaClienteFAB: TStringField;
    qryBuscaClienteTRAN: TStringField;
    qryBuscaClienteADM: TStringField;
    qryBuscaClienteATIVO: TStringField;
    qryBuscaClienteDT_ADMISSAO: TDateField;
    qryBuscaClienteDT_DEMISSAO: TDateField;
    qryBuscaClienteSALARIO: TFMTBCDField;
    qryBuscaClientePAI: TStringField;
    qryBuscaClienteMAE: TStringField;
    qryBuscaClienteBANCO: TStringField;
    qryBuscaClienteAGENCIA: TStringField;
    qryBuscaClienteGERENTE: TStringField;
    qryBuscaClienteFONE_GERENTE: TStringField;
    qryBuscaClientePROPRIEDADE: TStringField;
    qryBuscaClienteDT_CADASTRO: TDateField;
    qryBuscaClienteTECNICO: TStringField;
    qryBuscaClienteATENDENTE: TStringField;
    qryBuscaClienteCODIGO_WEB: TIntegerField;
    cdsPessoas: TFDQuery;
    cdsPessoascodigo: TFDAutoIncField;
    cdsPessoastipo: TStringField;
    cdsPessoascnpj: TStringField;
    cdsPessoasie: TStringField;
    cdsPessoasfantasia: TStringField;
    cdsPessoasrazao: TStringField;
    cdsPessoasendereco: TStringField;
    cdsPessoasnumero: TStringField;
    cdsPessoascomplemento: TStringField;
    cdsPessoascodmun: TIntegerField;
    cdsPessoasmunicipio: TStringField;
    cdsPessoasbairro: TStringField;
    cdsPessoasuf: TStringField;
    cdsPessoascep: TStringField;
    cdsPessoascelular1: TStringField;
    cdsPessoascelular2: TStringField;
    cdsPessoasisento: TStringField;
    cdsPessoascodigolocal: TIntegerField;
    qryOrcamento: TFDQuery;
    mtPedidos: TFDMemTable;
    procedure btnSalvarClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
     vChave, vURLApi: string;
    procedure Download;
    function CalculaCNPJ(pessoa, cnpj: string): string;
    procedure BaixarPessoa;
    procedure BaixaPedido;
    procedure StatusOrcamento(gid: string);
    procedure UpdateGidPessoa(gid: string);
    procedure UpdateOrcamento(gid: string);
    procedure CriarCamposMemTable;
    procedure CarregarPedidosDaAPI;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPedidoWeb: TFrmPedidoWeb;

implementation //Acesse lojadodesenvolvedor.com.br e saiba mais sobre esse código fonte.

{$R *.dfm}

uses uDadosWeb, Udados;

procedure TFrmPedidoWeb.btnSalvarClick(Sender: TObject);
begin
  try
    btnSalvar.Enabled := false;
    try
      dadosweb.ConexaoApp.close;
      dadosweb.ConexaoApp.Open;
      if dadosweb.ConexaoApp.Connected then
      begin
        Download;
        btnAtualizarClick(self);
      end;

    except
      on e: Exception do
        raise Exception.Create
          ('Erro de conexão com o banco de dados do servidor ' + e.Message);
    end;
  finally
    btnSalvar.Enabled := true;
  end;
end;

//procedure TFrmPedidoWeb.btnAtualizarClick(Sender: TObject);
//var
// ACodWEB: Integer;
//begin
//  ACodWEB := Dados.qryEmpresa.FieldByName('cweb').AsInteger;
//
//  try
//    try
//      btnAtualizar.Enabled := false;
//      dadosweb.ConexaoApp.close;
//      dadosweb.ConexaoApp.Open;
//      if dadosweb.ConexaoApp.Connected then
//      begin
//      with DadosWeb.cdsOrcamento do
//        begin
//          Close;
//          SQL.Clear;
//          SQL.Text :=
//            'select ped.*, cli.razao_nome, cli.cpf_cnpj ' +
//            'from pedidos ped ' +
//            'left join clientes cli on cli.codigo = ped.Cod_Cliente ' +
//            'where ped.Ind_Sinc = ''N'' and ped.codemp = :codemp ' +
//            'order by ped.Data_Venda';
//          Params[0].AsInteger := ACodWEB;
//          Open;
//        end;
//      end;
//
//    except
//      on e: Exception do
//        raise Exception.Create
//          ('Erro de conexão com o banco de dados do servidor ' + e.Message);
//    end;
//  finally
//    btnAtualizar.Enabled := true;
//  end;
//end;

procedure TFrmPedidoWeb.FormShow(Sender: TObject);
begin
  // Configurar DataSource da Grid
  DBGrid1.DataSource := dsOrc;

  // Configurar colunas da grid
  with DBGrid1.Columns do
  begin
    Clear;
    Add.FieldName := 'Data_Venda';
    Add.FieldName := 'NomeCliente';
    Add.FieldName := 'Total_Pedido';
  end;

  // Carregar dados
  btnAtualizarClick(nil);
end;

procedure TFrmPedidoWeb.btnAtualizarClick(Sender: TObject);
begin
  try
    btnAtualizar.Enabled := False;
    Screen.Cursor := crHourGlass;
    try
      CarregarPedidosDaAPI;
    except
      on E: Exception do
        ShowMessage('Erro ao atualizar: ' + E.Message);
    end;
  finally
    btnAtualizar.Enabled := True;
    Screen.Cursor := crDefault;
  end;
end;

function TFrmPedidoWeb.CalculaCNPJ(pessoa, cnpj: string): string;
begin
  if Trim(cnpj) = EmptyStr then
    begin
      if length(TiraPontos(cnpj)) = 11 then
        Result  :=  '00000000000'
      else
        Result  :=  '00000000000000';
      Exit;
    end;
  result := '';
  if length(TiraPontos(cnpj)) = 11 then
    result := copy(cnpj, 1, 3) + '.' + copy(cnpj, 4, 3) + '.' + copy(cnpj, 7, 3)
      + '-' + copy(cnpj, 10, 2)
  else
    result := copy(cnpj, 1, 2) + '.' + copy(cnpj, 3, 3) + '.' + copy(cnpj, 6, 3)
      + '/' + copy(cnpj, 9, 4) + '-' + copy(cnpj, 13, 2);
end;

procedure TFrmPedidoWeb.UpdateGidPessoa(gid: string);
begin
  try
    dadosweb.updWeb.close;
    dadosweb.updWeb.SQL.Text :=
      ' update pessoa set codigolocal=:codigolocal where codigo=:codigo';
    dadosweb.updWeb.Params[0].Value := gid;
    dadosweb.updWeb.Params[1].Value := cdsPessoascodigo.Value;
    dadosweb.updWeb.ExecSQL;
    dadosweb.ConexaoApp.Commit;
  except
  end;
end;

//procedure TFrmPedidoWeb.UpdateOrcamento(gid: string);
//begin
//  dadosweb.updWeb.close;
//  dadosweb.updWeb.SQL.Text :=
//    ' update pedidos set Obs = :codigolocal where Cod_Pedido=:codigo';
//  dadosweb.updWeb.Params[0].Value := gid;
//  dadosweb.updWeb.Params[1].Value := dadosweb.cdsOrcamento.FieldByName('Cod_Pedido').Value;
//  dadosweb.updWeb.ExecSQL;
//  dadosweb.ConexaoApp.Commit;
//end;

procedure TFrmPedidoWeb.UpdateOrcamento(gid: string);
var
  LObsText: string;
begin
  dadosweb.updWeb.Close;
  LObsText := 'pedido no sistema ' + gid;
  dadosweb.updWeb.SQL.Text := 'update pedidos set Obs = :obs_completa where Cod_Pedido = :codigo';
  dadosweb.updWeb.ParamByName('obs_completa').AsString := LObsText;
  dadosweb.updWeb.ParamByName('codigo').Value := dadosweb.cdsOrcamento.FieldByName('Cod_Pedido').Value;
  dadosweb.updWeb.ExecSQL;
  dadosweb.ConexaoApp.Commit;
end;

//procedure TFrmPedidoWeb.BaixarPessoa;
//begin
//  // sincronizar pessoas
//  cdsPessoas.close;
//  cdsPessoas.Open;
//
//  if not cdsPessoas.IsEmpty then
//  begin
//    dados.qryPessoas.close;
//    dados.qryPessoas.SQL.Text := 'select * from PESSOA ' + 'where ' +
//      'empresa=:id ' + ' /*where*/';
//    dados.qryPessoas.Params[0].Value := dados.qryEmpresaCODIGO.Value;
//    dados.qryPessoas.Open;
//
//    while not cdsPessoas.Eof do
//    begin
//      try
//        dados.qryPessoas.Insert;
//        dados.qryPessoasCODIGO_WEB.Value := cdsPessoascodigo.Value;;
//        dados.qryPessoasEMPRESA.Value := 1;
//        dados.qryPessoasCODIGO.Value := dados.Numerador('PESSOA', 'CODIGO',
//          'N', '', '');
//        dados.qryPessoasTIPO.Value := cdsPessoastipo.Value;
//        dados.qryPessoasCNPJ.Value := CalculaCNPJ(cdsPessoastipo.Value,
//          cdsPessoascnpj.Value);
//        dados.qryPessoasIE.Value := cdsPessoasie.Value;
//        dados.qryPessoasRAZAO.Value := cdsPessoasrazao.Value;
//        dados.qryPessoasFANTASIA.Value := cdsPessoasfantasia.Value;
//        dados.qryPessoasENDERECO.Value := cdsPessoasendereco.Value;
//        dados.qryPessoasNUMERO.Value := 'SN';
//        dados.qryPessoasMUNICIPIO.Value := cdsPessoasmunicipio.Value;
//        dados.qryPessoasBAIRRO.Value := cdsPessoasbairro.Value;
//        dados.qryPessoasUF.Value := cdsPessoasuf.Value;
//        dados.qryPessoasCODMUN.Value := cdsPessoascodmun.Value;
//        dados.qryPessoasCEP.Value := cdsPessoascep.Value;
//        dados.qryPessoasDT_CADASTRO.Value := date;
//        dados.qryPessoasCELULAR1.Value := cdsPessoascelular1.Value;
//        dados.qryPessoasDIA_PGTO.Value := 0;
//        dados.qryPessoasLIMITE.AsFloat := 0;
//        dados.qryPessoasSALARIO.Value := 0;
//        dados.qryPessoasFATURA.Value := 'N';
//        dados.qryPessoasCHEQUE.Value := 'N';
//        dados.qryPessoasCCF.Value := 'N';
//        dados.qryPessoasSPC.Value := 'N';
//        dados.qryPessoasISENTO.Value := '2';
//        dados.qryPessoasFORN.Value := 'N';
//        dados.qryPessoasFUN.Value := 'N';
//        dados.qryPessoasCLI.Value := 'S';
//        dados.qryPessoasFAB.Value := 'N';
//        dados.qryPessoasTRAN.Value := 'N';
//        dados.qryPessoasADM.Value := 'N';
//        dados.qryPessoasATIVO.Value := 'S';
//        dados.qryPessoasATENDENTE.Value := 'N';
//        dados.qryPessoasTECNICO.Value := 'N';
//        dados.qryPessoasFAB.Value := 'N';
//        dados.qryPessoas.Post;
//
//        UpdateGidPessoa(IntToStr(dados.qryPessoasCODIGO.Value));
//
//        dados.Conexao.Commit;
//      except
//        dados.Conexao.RollbackRetaining;
//      end;
//      cdsPessoas.Next;
//    end;
//  end;
//end;

procedure TFrmPedidoWeb.BaixarPessoa;
var
  LClientes: TJSONArray;
  LCliente: TJSONObject;
  I: Integer;
  LSincronizador: TSincronizadorApi;
  ACodWEB: Integer;
begin
  ACodWEB := Dados.qryEmpresa.FieldByName('cweb').AsInteger;

  LSincronizador := TSincronizadorApi.Create(
    Dados.Conexao,
    'https://suaapi.com.br/api',
    Dados.qryEmpresa.FieldByName('cnpj').AsString,
    Dados.qryEmpresa.FieldByName('chave_api').AsString
  );
  try
    // Obter token
    LSincronizador.LApiKeyJWT := LSincronizador.ObterTokenDaApi(
      Dados.qryEmpresa.FieldByName('cnpj').AsString,
      Dados.qryEmpresa.FieldByName('chave_api').AsString
    );

    // Baixar clientes
    if LSincronizador.BaixarClientes(ACodWEB, 0, LClientes) then
    begin
      try
        dados.qryPessoas.Close;
        dados.qryPessoas.SQL.Text := 'SELECT * FROM PESSOA WHERE empresa = :id';
        dados.qryPessoas.Params[0].Value := dados.qryEmpresaCODIGO.Value;
        dados.qryPessoas.Open;

        for I := 0 to LClientes.Count - 1 do
        begin
          LCliente := LClientes.Items[I] as TJSONObject;

          try
            // Verificar se já existe pelo cweb
            if dados.qryPessoas.Locate('CODIGO_WEB', LCliente.GetValue<Integer>('codigo'), []) then
              dados.qryPessoas.Edit
            else
              dados.qryPessoas.Insert;

            dados.qryPessoasCODIGO_WEB.Value := LCliente.GetValue<Integer>('codigo');
            dados.qryPessoasEMPRESA.Value := dados.qryEmpresaCODIGO.Value;

            if dados.qryPessoas.State = dsInsert then
              dados.qryPessoasCODIGO.Value := dados.Numerador('PESSOA', 'CODIGO', 'N', '', '');

            dados.qryPessoasTIPO.Value := 'F'; // ou pegar do JSON se tiver
            dados.qryPessoasCNPJ.Value := LCliente.GetValue<string>('cpf_cnpj');
            dados.qryPessoasRAZAO.Value := LCliente.GetValue<string>('razao_nome');
            dados.qryPessoasFANTASIA.Value := LCliente.GetValue<string>('apelido_fantasia');
            dados.qryPessoasENDERECO.Value := LCliente.GetValue<string>('endereco');
            dados.qryPessoasNUMERO.Value := LCliente.GetValue<string>('endereco_numero');
            dados.qryPessoasMUNICIPIO.Value := LCliente.GetValue<string>('cidade');
            dados.qryPessoasBAIRRO.Value := LCliente.GetValue<string>('bairro');
            dados.qryPessoasUF.Value := LCliente.GetValue<string>('uf');
            dados.qryPessoasCEP.Value := LCliente.GetValue<string>('cep');
            dados.qryPessoasCELULAR1.Value := LCliente.GetValue<string>('celular');
            dados.qryPessoasCLI.Value := 'S';
            dados.qryPessoasATIVO.Value := 'S';

            dados.qryPessoas.Post;
            dados.Conexao.Commit;
          except
            on E: Exception do
            begin
              dados.Conexao.RollbackRetaining;
              ShowMessage('Erro ao salvar cliente: ' + E.Message);
            end;
          end;
        end;
      finally
        LClientes.Free;
      end;
    end;
  finally
    LSincronizador.Free;
  end;
end;

//procedure TFrmPedidoWeb.BaixaPedido;
//var
//  LPedidos: TJSONArray;
//  LPedido, LItem: TJSONObject;
//  LItens: TJSONArray;
//  I, J: Integer;
//  LSincronizador: TSincronizadorApi;
//  ACodWEB, ACodPedidoWeb, ACodPedidoLocal: Integer;
//begin
//  ACodWEB := Dados.qryEmpresa.FieldByName('cweb').AsInteger;
//
//  LSincronizador := TSincronizadorApi.Create(
//    Dados.Conexao,
//    vURLApi,
//    Dados.qryEmpresa.FieldByName('cnpj').AsString,
//    vChave
//  );
//  try
//    // Obter token
//    LSincronizador.LApiKeyJWT := LSincronizador.ObterTokenDaApi(
//      Dados.qryEmpresa.FieldByName('cnpj').AsString,
//     vChave
//    );
//
//    if LSincronizador.BaixarPedidosPendentes(ACodWEB, LPedidos) then
//    begin
//      try
//        for I := 0 to LPedidos.Count - 1 do
//        begin
//          LPedido := LPedidos.Items[I] as TJSONObject;
//          ACodPedidoWeb := LPedido.GetValue<Integer>('Cod_Pedido');
//
//          try
//            // Inserir pedido
//            qryOrcamento.Close;
//            qryOrcamento.Params[0].AsInteger := ACodPedidoWeb;
//            qryOrcamento.Open;
//
//            if qryOrcamento.IsEmpty then
//              qryOrcamento.Insert
//            else
//              qryOrcamento.Edit;
//
//            qryOrcamento.FieldByName('CODIGO_WEB').AsInteger := ACodPedidoWeb;
//            qryOrcamento.FieldByName('FKEMPRESA').AsInteger := dados.qryEmpresaCODIGO.Value;
//            qryOrcamento.FieldByName('CODIGO').AsInteger := dados.Numerador('ORCAMENTO', 'CODIGO', 'N', '', '');
//            ACodPedidoLocal := qryOrcamento.FieldByName('CODIGO').AsInteger;
//
//            // Buscar cliente pelo CPF/CNPJ
//            qryBuscaCliente.Close;
//            qryBuscaCliente.Params[0].AsString := LPedido.GetValue<string>('cpf_cnpj');
//            qryBuscaCliente.Open;
//
//            if not qryBuscaCliente.IsEmpty then
//            begin
//              qryOrcamento.FieldByName('CLIENTE').AsString := qryBuscaClienteRAZAO.AsString;
//              qryOrcamento.FieldByName('FK_CLIENTE').AsInteger := qryBuscaClienteCODIGO.AsInteger;
//              qryOrcamento.FieldByName('CNPJ').AsString := LPedido.GetValue<string>('cpf_cnpj');
//            end
//            else
//            begin
//              qryOrcamento.FieldByName('CLIENTE').AsString := 'CONSUMIDOR FINAL';
//              qryOrcamento.FieldByName('FK_CLIENTE').AsInteger := 1;
//              qryOrcamento.FieldByName('CNPJ').AsString := '00000000000';
//            end;
//
//            qryOrcamento.FieldByName('FKVENDEDOR').AsInteger := LPedido.GetValue<Integer>('Cod_Vendedor');
//            qryOrcamento.FieldByName('FORMA_PAGAMENTO').AsString := LPedido.GetValue<string>('Cod_Plg');
//            qryOrcamento.FieldByName('SITUACAO').AsString := 'A';
//            qryOrcamento.FieldByName('DATA').AsDateTime := StrToDate(LPedido.GetValue<string>('Data_Venda'));
//            qryOrcamento.FieldByName('SUBTOTAL').AsCurrency := LPedido.GetValue<Double>('Total_Produtos');
//            qryOrcamento.FieldByName('DESCONTO').AsCurrency := LPedido.GetValue<Double>('Total_Descontos');
//            qryOrcamento.FieldByName('TOTAL').AsCurrency := LPedido.GetValue<Double>('Total_Pedido');
//            qryOrcamento.Post;
//
//            // Excluir itens antigos
//            Dados.qryExecute.Close;
//            Dados.qryExecute.SQL.Text := 'DELETE FROM orcamento_item WHERE fk_orcamento = :id';
//            Dados.qryExecute.Params[0].AsInteger := ACodPedidoLocal;
//            Dados.qryExecute.ExecSQL;
//
//            // Inserir itens
//            LItens := LPedido.GetValue<TJSONArray>('itens');
//            Dados.qryItensO.Close;
//            Dados.qryItensO.Open;
//
//            for J := 0 to LItens.Count - 1 do
//            begin
//              LItem := LItens.Items[J] as TJSONObject;
//
//              Dados.qryItensO.Insert;
//              Dados.qryItensOCODIGO.AsInteger := Dados.Numerador('ORCAMENTO_ITEM', 'CODIGO', 'N', '', '');
//              Dados.qryItensO.FieldByName('FK_PRODUTO').AsLargeInt := LItem.GetValue<Int64>('CodigoProduto');
//              Dados.qryItensO.FieldByName('FK_ORCAMENTO').AsInteger := ACodPedidoLocal;
//              Dados.qryItensO.FieldByName('QTD').AsFloat := LItem.GetValue<Double>('Quantidade');
//              Dados.qryItensO.FieldByName('DESCRICAO').AsString := LItem.GetValue<string>('Descricao');
//              Dados.qryItensO.FieldByName('PRECO').AsCurrency := LItem.GetValue<Double>('Vlr_Venda');
//              Dados.qryItensO.FieldByName('TOTAL').AsCurrency := LItem.GetValue<Double>('Vlr_Total');
//              Dados.qryItensO.FieldByName('ITEM').AsInteger := J + 1;
//              Dados.qryItensO.Post;
//            end;
//
//            Dados.Conexao.Commit;
//
//            // Marcar como sincronizado na nuvem
//            if not LSincronizador.MarcarPedidoSincronizado(ACodWEB, ACodPedidoWeb, ACodPedidoLocal) then
//              ShowMessage('Aviso: Pedido salvo localmente, mas não foi possível marcar como sincronizado na nuvem');
//
//          except
//            on E: Exception do
//            begin
//              Dados.Conexao.RollbackRetaining;
//              ShowMessage('Erro ao salvar pedido ' + IntToStr(ACodPedidoWeb) + ': ' + E.Message);
//            end;
//          end;
//        end;
//      finally
//        LPedidos.Free;
//      end;
//    end;
//  finally
//    LSincronizador.Free;
//  end;
//end;

procedure TFrmPedidoWeb.BaixaPedido;
var
  LPedidos: TJSONArray;
  LPedido, LItem: TJSONObject;
  LItens: TJSONArray;
  I, J: Integer;
  LSincronizador: TSincronizadorApi;
  ACodWEB, ACodPedidoWeb, ACodPedidoLocal: Integer;
  LCNPJ, LChaveAPI, LURL: string;
begin
  ACodWEB := Dados.qryEmpresa.FieldByName('cweb').AsInteger;
  LCNPJ := Dados.qryEmpresa.FieldByName('cnpj').AsString;
  LChaveAPI := vChave;
  LURL := vURLApi;

  LSincronizador := TSincronizadorApi.Create(Dados.Conexao, LURL, LCNPJ, LChaveAPI);
  try
    try
      // Obter token
      LSincronizador.LApiKeyJWT := LSincronizador.ObterTokenDaApi(LCNPJ, LChaveAPI);

      // Usar os dados que já estão no MemTable
      if mtPedidos.RecordCount = 0 then
      begin
        ShowMessage('Nenhum pedido para sincronizar.');
        Exit;
      end;

      mtPedidos.First;
      while not mtPedidos.Eof do
      begin
        ACodPedidoWeb := mtPedidos.FieldByName('Cod_Pedido').AsInteger;

        try
          // Verificar se já existe
          qryOrcamento.Close;
          qryOrcamento.Params[0].AsInteger := ACodPedidoWeb;
          qryOrcamento.Open;

          if qryOrcamento.IsEmpty then
            qryOrcamento.Insert
          else
            qryOrcamento.Edit;

          qryOrcamento.FieldByName('CODIGO_WEB').AsInteger := ACodPedidoWeb;
          qryOrcamento.FieldByName('FKEMPRESA').AsInteger := Dados.qryEmpresaCODIGO.Value;
          qryOrcamento.FieldByName('CODIGO').AsInteger :=
            Dados.Numerador('ORCAMENTO', 'CODIGO', 'N', '', '');
          ACodPedidoLocal := qryOrcamento.FieldByName('CODIGO').AsInteger;

          // Buscar cliente pelo CPF/CNPJ
          if (mtPedidos.FieldByName('cpf_cnpj').AsString <> '00000000000') and
             (mtPedidos.FieldByName('cpf_cnpj').AsString <> '00000000000000') and
             (mtPedidos.FieldByName('cpf_cnpj').AsString <> '') then
          begin
            qryBuscaCliente.Close;
            qryBuscaCliente.Params[0].AsString := mtPedidos.FieldByName('cpf_cnpj').AsString;
            qryBuscaCliente.Open;

            if not qryBuscaCliente.IsEmpty then
            begin
              qryOrcamento.FieldByName('CLIENTE').AsString := qryBuscaClienteRAZAO.AsString;
              qryOrcamento.FieldByName('FK_CLIENTE').AsInteger := qryBuscaClienteCODIGO.AsInteger;
              qryOrcamento.FieldByName('CNPJ').AsString := mtPedidos.FieldByName('cpf_cnpj').AsString;
              qryOrcamento.FieldByName('ENDERECO').AsString := qryBuscaClienteENDERECO.AsString;
              qryOrcamento.FieldByName('NUMERO').AsString := qryBuscaClienteNUMERO.AsString;
              qryOrcamento.FieldByName('CIDADE').AsString := qryBuscaClienteMUNICIPIO.AsString;
              qryOrcamento.FieldByName('BAIRRO').AsString := qryBuscaClienteBAIRRO.AsString;
              qryOrcamento.FieldByName('UF').AsString := qryBuscaClienteUF.AsString;
              qryOrcamento.FieldByName('CEP').AsString := qryBuscaClienteCEP.AsString;
            end
            else
            begin
              qryOrcamento.FieldByName('CLIENTE').AsString :=
                mtPedidos.FieldByName('NomeCliente').AsString;
              qryOrcamento.FieldByName('FK_CLIENTE').AsInteger := 1;
              qryOrcamento.FieldByName('CNPJ').AsString :=
                mtPedidos.FieldByName('cpf_cnpj').AsString;
            end;
          end
          else
          begin
            qryOrcamento.FieldByName('CLIENTE').AsString := 'CONSUMIDOR FINAL';
            qryOrcamento.FieldByName('FK_CLIENTE').AsInteger := 1;
            qryOrcamento.FieldByName('CNPJ').AsString := '00000000000';
          end;

          qryOrcamento.FieldByName('FKVENDEDOR').AsInteger :=
            mtPedidos.FieldByName('Cod_Vendedor').AsInteger;
          qryOrcamento.FieldByName('FORMA_PAGAMENTO').AsString :=
            mtPedidos.FieldByName('Cod_Plg').AsString;
          qryOrcamento.FieldByName('SITUACAO').AsString := 'A';
          qryOrcamento.FieldByName('DATA').AsDateTime :=
            mtPedidos.FieldByName('Data_Venda').AsDateTime;
          qryOrcamento.FieldByName('SUBTOTAL').AsCurrency :=
            mtPedidos.FieldByName('Total_Produtos').AsCurrency;
          qryOrcamento.FieldByName('DESCONTO').AsCurrency :=
            mtPedidos.FieldByName('Total_Descontos').AsCurrency;
          qryOrcamento.FieldByName('TOTAL').AsCurrency :=
            mtPedidos.FieldByName('Total_Pedido').AsCurrency;
          qryOrcamento.Post;

          // Buscar itens deste pedido específico da API
          if LSincronizador.BaixarPedidosPendentes(ACodWEB, LPedidos) then
          begin
            try
              // Encontrar o pedido correto no array
              for I := 0 to LPedidos.Count - 1 do
              begin
                LPedido := LPedidos.Items[I] as TJSONObject;
                if LPedido.GetValue<Integer>('Cod_Pedido') = ACodPedidoWeb then
                begin
                  // Excluir itens antigos
                  Dados.qryExecute.Close;
                  Dados.qryExecute.SQL.Text :=
                    'DELETE FROM orcamento_item WHERE fk_orcamento = :id';
                  Dados.qryExecute.Params[0].AsInteger := ACodPedidoLocal;
                  Dados.qryExecute.ExecSQL;

                  // Inserir novos itens
                  if LPedido.TryGetValue<TJSONArray>('itens', LItens) then
                  begin
                    Dados.qryItensO.Close;
                    Dados.qryItensO.Open;

                    for J := 0 to LItens.Count - 1 do
                    begin
                      LItem := LItens.Items[J] as TJSONObject;

                      Dados.qryItensO.Insert;
                      Dados.qryItensOCODIGO.AsInteger :=
                        Dados.Numerador('ORCAMENTO_ITEM', 'CODIGO', 'N', '', '');
                      Dados.qryItensO.FieldByName('FK_PRODUTO').AsLargeInt :=
                        LItem.GetValue<Int64>('CodigoProduto');
                      Dados.qryItensO.FieldByName('FK_ORCAMENTO').AsInteger := ACodPedidoLocal;
                      Dados.qryItensO.FieldByName('QTD').AsFloat :=
                        LItem.GetValue<Double>('Quantidade');
                      Dados.qryItensO.FieldByName('DESCRICAO').AsString :=
                        LItem.GetValue<string>('Descricao');
                      Dados.qryItensO.FieldByName('PRECO').AsCurrency :=
                        LItem.GetValue<Double>('Vlr_Venda');
                      Dados.qryItensO.FieldByName('TOTAL').AsCurrency :=
                        LItem.GetValue<Double>('Vlr_Total');
                      Dados.qryItensO.FieldByName('ITEM').AsInteger := J + 1;
                      Dados.qryItensO.Post;
                    end;
                  end;

                  Break;
                end;
              end;
            finally
              LPedidos.Free;
            end;
          end;

          Dados.Conexao.Commit;

          // Marcar como sincronizado na nuvem
          if LSincronizador.MarcarPedidoSincronizado(ACodWEB, ACodPedidoWeb, ACodPedidoLocal) then
          begin
            // Remover do MemTable após sucesso
            mtPedidos.Delete;
            Continue; // Não fazer Next porque Delete já move o cursor
          end
          else
            ShowMessage('Aviso: Pedido ' + IntToStr(ACodPedidoWeb) +
                       ' salvo localmente, mas não foi possível marcar como sincronizado na nuvem');

        except
          on E: Exception do
          begin
            Dados.Conexao.RollbackRetaining;
            ShowMessage('Erro ao salvar pedido ' + IntToStr(ACodPedidoWeb) + ': ' + E.Message);
          end;
        end;

        mtPedidos.Next;
      end;

      // Atualizar grid
      if mtPedidos.RecordCount > 0 then
        ShowMessage(Format('Ainda restam %d pedido(s) pendente(s).', [mtPedidos.RecordCount]))
      else
        ShowMessage('Todos os pedidos foram sincronizados com sucesso!');

    except
      on E: Exception do
      begin
        ShowMessage('Erro na sincronização: ' + E.Message);
        raise;
      end;
    end;
  finally
    LSincronizador.Free;
  end;
end;

procedure TFrmPedidoWeb.StatusOrcamento(gid: string);
begin
  dadosweb.updWeb.close;
  dadosweb.updWeb.SQL.Text :=
    'update pedidos set Ind_Sinc =''S'' where Cod_Pedido=:codigo';
  dadosweb.updWeb.Params[0].Value := gid;
  dadosweb.updWeb.ExecSQL;
  dadosweb.ConexaoApp.Commit;
end;


//procedure TFrmPedidoWeb.BaixaPedido;
//var
//  item: Integer;
//  ACodWEB, ACodEmp: Integer;
//  AcdPedidoWEB, AcdPedido: string;
//  // Arrays para armazenar os itens
//  arrCodigoProduto: array of Int64;
//  arrDescricao: array of string;
//  arrQuantidade: array of Double;
//  arrVlrVenda: array of Currency;
//  arrVlrTotal: array of Currency;
//  itemCount: Integer;
//begin
//  ACodEmp := Dados.qryEmpresaCODIGO.AsInteger;
//  ACodWEB := Dados.qryEmpresa.FieldByName('cweb').AsInteger;
//
//  with DadosWeb.cdsOrcamento do
//  begin
//    Close;
//    SQL.Clear;
//    SQL.Text :=
//      'select ped.*, cli.razao_nome, cli.cpf_cnpj ' +
//      'from pedidos ped ' +
//      'left join clientes cli on cli.codigo = ped.Cod_Cliente ' +
//      'where ped.Ind_Sinc = ''N'' and ped.codemp = :codemp ' +
//      'order by ped.Data_Venda';
//    Params[0].AsInteger := ACodWEB;
//    Open;
//  end;
//
//  if not DadosWeb.cdsOrcamento.IsEmpty then
//  begin
//    DadosWeb.cdsOrcamento.First;
//    while not DadosWeb.cdsOrcamento.Eof do
//    begin
//      qryOrcamento.Close;
//      qryOrcamento.Params[0].AsInteger := DadosWeb.cdsOrcamento.FieldByName('Cod_Pedido').AsInteger;
//      qryOrcamento.Open;
//      if qryOrcamento.IsEmpty then
//        qryOrcamento.Insert
//      else
//        qryOrcamento.Edit;
//
//      qryOrcamento.FieldByName('CODIGO_WEB').AsInteger := DadosWeb.cdsOrcamento.FieldByName('Cod_Pedido').AsInteger;
//      qryOrcamento.FieldByName('FKEMPRESA').AsInteger := ACodEmp;
//      qryOrcamento.FieldByName('CODIGO').AsInteger := Dados.Numerador('ORCAMENTO', 'CODIGO', 'N', '', '');
//      qryOrcamento.FieldByName('CNPJ').AsString := DadosWeb.cdsOrcamento.FieldByName('cpf_cnpj').AsString;
//
//      if (qryOrcamento.FieldByName('CNPJ').AsString <> '00000000000') and
//         (qryOrcamento.FieldByName('CNPJ').AsString <> '00000000000000') then
//      begin
//        qryBuscaCliente.Close;
//        qryBuscaCliente.Params[0].AsString := DadosWeb.cdsOrcamento.FieldByName('cpf_cnpj').AsString;
//        qryBuscaCliente.Open;
//        qryOrcamento.FieldByName('CLIENTE').AsString := qryBuscaCliente.FieldByName('RAZAO').AsString;
//        qryOrcamento.FieldByName('FK_CLIENTE').AsInteger := qryBuscaCliente.FieldByName('CODIGO').AsInteger;
//      end
//      else
//      begin
//        qryOrcamento.FieldByName('CLIENTE').AsString := 'CONSUMIDOR FINAL';
//        qryOrcamento.FieldByName('FK_CLIENTE').AsInteger := 1;
//      end;
//
//      qryOrcamento.FieldByName('FKVENDEDOR').AsInteger := DadosWeb.cdsOrcamento.FieldByName('Cod_Vendedor').AsInteger;
//      qryOrcamento.FieldByName('ENDERECO').AsString := qryBuscaClienteENDERECO.AsString;
//      qryOrcamento.FieldByName('NUMERO').AsString := qryBuscaClienteNUMERO.AsString;
//      qryOrcamento.FieldByName('CIDADE').AsString := qryBuscaClienteMUNICIPIO.AsString;
//      qryOrcamento.FieldByName('BAIRRO').AsString := qryBuscaClienteBAIRRO.AsString;
//      qryOrcamento.FieldByName('UF').AsString := qryBuscaClienteUF.AsString;
//      qryOrcamento.FieldByName('CEP').AsString := qryBuscaClienteCEP.AsString;
//      qryOrcamento.FieldByName('FORMA_PAGAMENTO').AsString := DadosWeb.cdsOrcamento.FieldByName('Cod_Plg').AsString;
//      qryOrcamento.FieldByName('SITUACAO').AsString := 'A';
//      qryOrcamento.FieldByName('DATA').AsDateTime := DadosWeb.cdsOrcamento.FieldByName('Data_Venda').AsDateTime;
//      qryOrcamento.FieldByName('SUBTOTAL').AsCurrency := DadosWeb.cdsOrcamento.FieldByName('Total_Produtos').AsCurrency;
//      qryOrcamento.FieldByName('DESCONTO').AsCurrency := DadosWeb.cdsOrcamento.FieldByName('Total_Descontos').AsCurrency;
//      qryOrcamento.FieldByName('TOTAL').AsCurrency := DadosWeb.cdsOrcamento.FieldByName('Total_Pedido').AsCurrency;
//      qryOrcamento.Post;
//
//      AcdPedido := inttostr(qryOrcamento.FieldByName('CODIGO').AsInteger);
//      UpdateOrcamento(AcdPedido);
//      AcdPedidoWEB := IntToStr(DadosWeb.cdsOrcamento.FieldByName('Cod_Pedido').AsInteger);
//      StatusOrcamento(AcdPedidoWEB);
//      DadosWeb.ConexaoApp.Commit;
//
//      // Carrega os itens em arrays - CORRIGIDO
//      with DadosWeb.cdsItens do
//      begin
//        Close;
//        SQL.Clear;
//        SQL.Text :=
//          'select ped.*, pro.mercadoria ' +
//          'from pedido_item ped ' +
//          'left join produtos pro on pro.id = ped.CodigoProduto ' +
//          'where ped.codemp = :codemp and ped.Cod_Pedido = :codigo';
//        Params[0].AsInteger := ACodWEB;
//        Params[1].AsInteger := DadosWeb.cdsOrcamento.FieldByName('Cod_Pedido').AsInteger;
//        Open;
//
//        // Inicializa arrays com tamanho suficiente
//        SetLength(arrCodigoProduto, RecordCount);
//        SetLength(arrDescricao, RecordCount);
//        SetLength(arrQuantidade, RecordCount);
//        SetLength(arrVlrVenda, RecordCount);
//        SetLength(arrVlrTotal, RecordCount);
//
//        // Preenche arrays
//        itemCount := 0;
//        First; // Garante que estamos no primeiro registro
//        while not Eof do
//        begin
//          arrCodigoProduto[itemCount] := FieldByName('CodigoProduto').AsLargeInt;
//          arrDescricao[itemCount] := FieldByName('Descricao').AsString;
//          arrQuantidade[itemCount] := FieldByName('Quantidade').AsFloat;
//          arrVlrVenda[itemCount] := FieldByName('Vlr_Venda').AsCurrency;
//          arrVlrTotal[itemCount] := FieldByName('Vlr_Total').AsCurrency;
//          Inc(itemCount);
//          Next;
//        end;
//        // Não feche o dataset aqui ainda, vamos fechar depois de usar os arrays
//      end;
//
//      // Exclui itens antigos
//      Dados.qryExecute.Close;
//      Dados.qryExecute.SQL.Text := 'delete from orcamento_item where fk_orcamento = :id';
//      Dados.qryExecute.Params[0].AsInteger := qryOrcamento.FieldByName('CODIGO').AsInteger;
//      Dados.qryExecute.ExecSQL;
//
//      // Insere novos itens a partir dos arrays
//      Dados.qryItensO.Close;
//      Dados.qryItensO.Open;
//      for item := 0 to itemCount - 1 do
//      begin
//        Dados.qryItensO.Insert;
//        Dados.qryItensOCODIGO.AsInteger := Dados.Numerador('ORCAMENTO_ITEM', 'CODIGO', 'N', '', '');
//        Dados.qryItensO.FieldByName('FK_PRODUTO').AsLargeInt := arrCodigoProduto[item];
//        Dados.qryItensO.FieldByName('FK_ORCAMENTO').AsInteger := qryOrcamento.FieldByName('CODIGO').AsInteger;
//        Dados.qryItensO.FieldByName('QTD').AsFloat := arrQuantidade[item];
//        Dados.qryItensO.FieldByName('DESCRICAO').AsString := arrDescricao[item];
//        Dados.qryItensO.FieldByName('PRECO').AsCurrency := arrVlrVenda[item];
//        Dados.qryItensO.FieldByName('TOTAL').AsCurrency := arrVlrTotal[item];
//        Dados.qryItensO.FieldByName('ITEM').AsInteger := item + 1;
//        Dados.qryItensO.Post;
//      end;
//
//      // Agora fecha o dataset dos itens
//      DadosWeb.cdsItens.Close;
//
//      Dados.Conexao.Commit;
//      DadosWeb.cdsOrcamento.Next;
//    end;
//  end;
//end;


procedure TFrmPedidoWeb.Download;
begin
  // Baixa Pessoa
 // BaixarPessoa;

  // sincronizar ORCAMENTO
  BaixaPedido;


  ShowMessage('Sincronização Conluida!');
end;

procedure TFrmPedidoWeb.FormActivate(Sender: TObject);
begin
  dados.vForm := nil;
  dados.vForm := self;
  dados.GetComponentes;
end;

procedure TFrmPedidoWeb.FormCreate(Sender: TObject);
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

//procedure TFrmPedidoWeb.FormShow(Sender: TObject);
//begin
//  btnAtualizarClick(nil);
//
//  with DBGrid1.Columns do
//  begin
//    Items[0].FieldName := 'Data_Venda';
//    Items[1].FieldName := 'NomeCliente';
//    Items[2].FieldName := 'Total_Pedido';
//  end;
//end;

procedure TFrmPedidoWeb.CriarCamposMemTable;
begin
  mtPedidos.Close;
  mtPedidos.FieldDefs.Clear;
  mtPedidos.FieldDefs.Add('Cod_Pedido', ftInteger, 0, False);
  mtPedidos.FieldDefs.Add('Data_Venda', ftDate, 0, False);
  mtPedidos.FieldDefs.Add('NomeCliente', ftString, 180, False);
  mtPedidos.FieldDefs.Add('cpf_cnpj', ftString, 60, False);
  mtPedidos.FieldDefs.Add('razao_nome', ftString, 180, False);
  mtPedidos.FieldDefs.Add('Cod_Cliente', ftInteger, 0, False);
  mtPedidos.FieldDefs.Add('Cod_Vendedor', ftInteger, 0, False);
  mtPedidos.FieldDefs.Add('Nome_Vendedor', ftString, 60, False);
  mtPedidos.FieldDefs.Add('Cod_Plg', ftInteger, 0, False);
  mtPedidos.FieldDefs.Add('Nome_Plg', ftString, 60, False);
  mtPedidos.FieldDefs.Add('Total_Produtos', ftCurrency, 0, False);
  mtPedidos.FieldDefs.Add('Total_Descontos', ftCurrency, 0, False);
  mtPedidos.FieldDefs.Add('Total_Pedido', ftCurrency, 0, False);
  mtPedidos.FieldDefs.Add('Obs', ftString, 250, False);
  mtPedidos.FieldDefs.Add('Ind_Sinc', ftString, 1, False);
  mtPedidos.CreateDataSet;
  mtPedidos.Open;
end;

procedure TFrmPedidoWeb.CarregarPedidosDaAPI;
var
  LPedidos: TJSONArray;
  LPedido: TJSONObject;
  I: Integer;
  LSincronizador: TSincronizadorApi;
  ACodWEB: Integer;
  LCNPJ, LApiKey, LURL: string;
begin
  ACodWEB := Dados.qryEmpresa.FieldByName('cweb').AsInteger;
  LCNPJ := Dados.qryEmpresa.FieldByName('cnpj').AsString;
  LApiKey := '';
  LURL := vURLApi; // ou usar URL fixa

  // Criar campos do MemTable
  CriarCamposMemTable;

  LSincronizador := TSincronizadorApi.Create(Dados.Conexao, LURL, LCNPJ, vChave);
  try
    try
      // Obter token JWT
     LApiKey := LSincronizador.ObterTokenDaApi(LCNPJ, vChave);
     LSincronizador.LApiKeyJWT :=  LApiKey;
      // Buscar pedidos pendentes
      if LSincronizador.BaixarPedidosPendentes(ACodWEB, LPedidos) then
      begin
        try
          mtPedidos.EmptyDataSet;

          // Popular MemTable com dados da API usando FieldByName
          for I := 0 to LPedidos.Count - 1 do
          begin
            LPedido := LPedidos.Items[I] as TJSONObject;

            mtPedidos.Append;

            mtPedidos.FieldByName('Cod_Pedido').AsInteger :=
              LPedido.GetValue<Integer>('Cod_Pedido');

            // Data_Venda
            try
              mtPedidos.FieldByName('Data_Venda').AsDateTime :=
                StrToDate(LPedido.GetValue<string>('Data_Venda'));
            except
              mtPedidos.FieldByName('Data_Venda').AsDateTime := Now;
            end;

            mtPedidos.FieldByName('NomeCliente').AsString :=
              LPedido.GetValue<string>('NomeCliente');

            // Campos do JOIN com clientes (podem ser null)
            if not LPedido.GetValue('razao_nome').Null then
              mtPedidos.FieldByName('razao_nome').AsString :=
                LPedido.GetValue<string>('razao_nome');

            if not LPedido.GetValue('cpf_cnpj').Null then
              mtPedidos.FieldByName('cpf_cnpj').AsString :=
                LPedido.GetValue<string>('cpf_cnpj');

            mtPedidos.FieldByName('Cod_Cliente').AsInteger :=
              LPedido.GetValue<Integer>('Cod_Cliente');

            mtPedidos.FieldByName('Cod_Vendedor').AsInteger :=
              LPedido.GetValue<Integer>('Cod_Vendedor');

            mtPedidos.FieldByName('Nome_Vendedor').AsString :=
              LPedido.GetValue<string>('Nome_Vendedor');

            mtPedidos.FieldByName('Cod_Plg').AsInteger :=
              LPedido.GetValue<Integer>('Cod_Plg');

            if not LPedido.GetValue('Nome_Plg').Null then
              mtPedidos.FieldByName('Nome_Plg').AsString :=
                LPedido.GetValue<string>('Nome_Plg');

            mtPedidos.FieldByName('Total_Produtos').AsCurrency :=
              LPedido.GetValue<Double>('Total_Produtos');

            if not LPedido.GetValue('Total_Descontos').Null then
              mtPedidos.FieldByName('Total_Descontos').AsCurrency :=
                LPedido.GetValue<Double>('Total_Descontos');

            if not LPedido.GetValue('Total_Pedido').Null then
              mtPedidos.FieldByName('Total_Pedido').AsCurrency :=
                LPedido.GetValue<Double>('Total_Pedido');

            if not LPedido.GetValue('Obs').Null then
              mtPedidos.FieldByName('Obs').AsString :=
                LPedido.GetValue<string>('Obs');

            mtPedidos.FieldByName('Ind_Sinc').AsString :=
              LPedido.GetValue<string>('Ind_Sinc');

            mtPedidos.Post;
          end;

          mtPedidos.First;

          if mtPedidos.RecordCount = 0 then
            ShowMessage('Nenhum pedido pendente encontrado.')
          else
            ShowMessage(Format('%d pedido(s) pendente(s) encontrado(s).', [mtPedidos.RecordCount]));

        finally
          LPedidos.Free;
        end;
      end;

    except
      on E: Exception do
      begin
        ShowMessage('Erro ao buscar pedidos da API: ' + E.Message);
        raise;
      end;
    end;
  finally
    LSincronizador.Free;
  end;
end;


end.
