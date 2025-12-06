<?php

require_once __DIR__ . '/../config/Database.php';

class EmpresaController {
    /**
     * Recupera e valida o código da empresa informado via rota, query string ou contexto global.
     *
     * @param mixed $codemp Código fornecido via parâmetro opcional
     * @return int Código da empresa validado
     * @throws InvalidArgumentException Quando o código não é fornecido ou não é numérico
     */
    private function resolveCodemp($codemp = null) {
        $value = $codemp
            ?? $_GET['codemp']
            ?? $_GET['codEmp']
            ?? $_GET['id']
            ?? ($GLOBALS['cod_emp'] ?? null);

        if ($value === null || $value === '') {
            throw new InvalidArgumentException('Informe o código da empresa (codemp) para executar esta ação');
        }

        $value = (string)$value;

        if (!ctype_digit($value)) {
            throw new InvalidArgumentException('O código da empresa deve ser numérico');
        }

        return (int)$value;
    }

    /**
     * Formata CNPJ para 00.000.000/0000-00 mantendo apenas dígitos
     */
    private function formatCnpjMasked($cnpjDigits) {
        $digits = preg_replace('/[^0-9]/', '', (string)$cnpjDigits);

        if (strlen($digits) !== 14) {
            return $cnpjDigits;
        }

        return preg_replace(
            '/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/',
            '$1.$2.$3/$4-$5',
            $digits
        );
    }

    /**
     * POST /empresa
     * Cria nova empresa com usuário e formas de pagamento
     *
     * Espera JSON:
     * {
     *   "empresa": {
     *     "nomefantasia": "string",
     *     "razaosocial": "string",
     *     "endereco": "string",
     *     "end_numero": "string",
     *     "complemento": "string",
     *     "bairro": "string",
     *     "fone": "string",
     *     "cidade": "string",
     *     "uf": "string",
     *     "cep": "string",
     *     "cnpj": "string",
     *     "ie": "string",
     *     "ativo_sf": 1,
     *     "qtd_lic_sf": 2,
     *     "ativo_zap": 1,
     *     "key": "string"
     *   },
     *   "usuario": {
     *     "nome": "string",
     *     "email": "string",
     *     "senha": "string"
     *   },
     *   "formasPagamento": [
     *     {
     *       "descricao": "string",
     *       "parcelas": 1,
     *       "pacrescimo": 0.0,
     *       "pdesconto": 0.0
     *     }
     *   ]
     * }
     *
     * Retorna: {"success": true, "codemp": 123}
     */
    public function create() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);


          
            // Validar dados obrigatórios
            if (!isset($data['empresa']) || !isset($data['usuario'])) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Dados de empresa e usuário são obrigatórios'
                ]);
                return;
            }

            $empresa = $data['empresa'];
            $usuario = $data['usuario'];
            $formasPagamento = $data['formasPagamento'] ?? [];

            // Validar campos obrigatórios da empresa
            if (empty($empresa['nomefantasia']) || empty($empresa['cnpj'])) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Nome fantasia e CNPJ são obrigatórios'
                ]);
                return;
            }

            // Validar campos obrigatórios do usuário
            if (empty($usuario['nome']) || empty($usuario['email']) || empty($usuario['senha'])) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Nome, email e senha do usuário são obrigatórios'
                ]);
                return;
            }

            $db = Database::getInstance()->getConnection();

            // Iniciar transação
            $db->beginTransaction();

            try {
                // 1. Verificar se CNPJ já existe
                $stmtCheck = $db->prepare("SELECT codemp FROM empresas WHERE cnpj = :cnpj LIMIT 1");
                $stmtCheck->execute(['cnpj' => $empresa['cnpj']]);
                $empresaExistente = $stmtCheck->fetch();

                if ($empresaExistente) {
                    throw new Exception('CNPJ já cadastrado no sistema');
                }

                // 2. Inserir empresa
                $stmtEmpresa = $db->prepare("
                    INSERT INTO empresas (
                        nomefantasia, razaosocial, endereco, end_numero, complemento,
                        bairro, fone, cidade, uf, cep, cnpj, ie,
                        ativo_sf, qtd_lic_sf, ativo_zap, `key`
                    ) VALUES (
                        :nomefantasia, :razaosocial, :endereco, :end_numero, :complemento,
                        :bairro, :fone, :cidade, :uf, :cep, :cnpj, :ie,
                        :ativo_sf, :qtd_lic_sf, :ativo_zap, :key
                    )
                ");

                $stmtEmpresa->execute([
                    'nomefantasia' => $empresa['nomefantasia'],
                    'razaosocial' => $empresa['razaosocial'] ?? null,
                    'endereco' => $empresa['endereco'] ?? null,
                    'end_numero' => $empresa['end_numero'] ?? null,
                    'complemento' => $empresa['complemento'] ?? null,
                    'bairro' => $empresa['bairro'] ?? null,
                    'fone' => $empresa['fone'] ?? null,
                    'cidade' => $empresa['cidade'] ?? null,
                    'uf' => $empresa['uf'] ?? null,
                    'cep' => $empresa['cep'] ?? null,
                    'cnpj' => $empresa['cnpj'],
                    'ie' => $empresa['ie'] ?? null,
                    'ativo_sf' => $empresa['ativo_sf'] ?? 1,
                    'qtd_lic_sf' => $empresa['qtd_lic_sf'] ?? 2,
                    'ativo_zap' => $empresa['ativo_zap'] ?? 1,
                    'key' => $empresa['key'] ?? null
                ]);

                // Obter o código da empresa inserida
                $codemp = $db->lastInsertId();

                // 3. Inserir usuário (ID = 1 para primeiro usuário da empresa)
                $stmtUsuario = $db->prepare("
                    INSERT INTO usuarios (
                        codemp, id, nome, email, senha, last_mod
                    ) VALUES (
                        :codemp, 1, :nome, :email, :senha, NOW()
                    )
                ");

                // Hash da senha
             //   $senhaHash = password_hash($usuario['senha'], PASSWORD_DEFAULT);

                $stmtUsuario->execute([
                    'codemp' => $codemp,
                    'nome' => $usuario['nome'],
                    'email' => $usuario['email'],
                    'senha' => $usuario['senha']
                ]);

                // 4. Inserir formas de pagamento
                if (!empty($formasPagamento)) {
                    $stmtCondPgto = $db->prepare("
                        INSERT INTO condpgto (
                            codemp, id, descricao, parcelas, pacrescimo, pdesconto, last_mod
                        ) VALUES (
                            :codemp, :id, :descricao, :parcelas, :pacrescimo, :pdesconto, NOW()
                        )
                    ");

                    foreach ($formasPagamento as $index => $formaPgto) {
                        $stmtCondPgto->execute([
                            'codemp' => $codemp,
                            'id' => $index + 1,
                            'descricao' => $formaPgto['descricao'] ?? '',
                            'parcelas' => $formaPgto['parcelas'] ?? 1,
                            'pacrescimo' => $formaPgto['pacrescimo'] ?? 0.0,
                            'pdesconto' => $formaPgto['pdesconto'] ?? 0.0
                        ]);
                    }
                }

                // Commit da transação
                $db->commit();

                // Retornar sucesso com código da empresa
                http_response_code(201);
                echo json_encode([
                    'success' => true,
                    'message' => 'Empresa cadastrada com sucesso',
                    'codemp' => (int)$codemp
                ]);

            } catch (Exception $e) {
                $db->rollBack();
                throw $e;
            }

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => $e->getMessage()
            ]);
        }
    }

    /**
     * POST /empresa/vendedores
     * Insere ou atualiza vendedores de uma empresa
     *
     * Espera JSON:
     * {
     *   "codemp": 123,
     *   "chave_api": "key_da_empresa",
     *   "vendedores": [
     *     { "id": 1, "nome": "João" },
     *     { "nome": "Maria" } // id opcional -> max(id)+1
     *   ]
     * }
     */
    public function insertVendedores() {
        try {
            $data = json_decode(file_get_contents('php://input'), true) ?? [];

            if (empty($data['codemp']) || !ctype_digit((string)$data['codemp'])) {
                http_response_code(400);
                echo json_encode([
                    'status' => false,
                    'mensagem' => 'Código da empresa é obrigatório'
                ]);
                return;
            }

            if (empty($data['chave_api'])) {
                http_response_code(400);
                echo json_encode([
                    'status' => false,
                    'mensagem' => 'Chave API é obrigatória'
                ]);
                return;
            }

            if (empty($data['vendedores']) || !is_array($data['vendedores'])) {
                http_response_code(400);
                echo json_encode([
                    'status' => false,
                    'mensagem' => 'Informe pelo menos um vendedor'
                ]);
                return;
            }

            $codemp = (int)$data['codemp'];
            $chaveApi = $data['chave_api'];
            $vendedores = $data['vendedores'];

            $db = Database::getInstance()->getConnection();
            $db->beginTransaction();

            try {
                // Validar empresa / chave
                $stmtCheck = $db->prepare("SELECT `key` FROM empresas WHERE codemp = :codemp LIMIT 1");
                $stmtCheck->execute(['codemp' => $codemp]);
                $empresa = $stmtCheck->fetch(PDO::FETCH_ASSOC);

                if (!$empresa) {
                    throw new Exception('Empresa não encontrada');
                }

                if ($empresa['key'] !== $chaveApi) {
                    throw new Exception('Chave API inválida para esta empresa');
                }

                // Descobrir o próximo ID disponível
                $stmtMax = $db->prepare("SELECT COALESCE(MAX(id), 0) AS max_id FROM vendedores WHERE codemp = :codemp");
                $stmtMax->execute(['codemp' => $codemp]);
                $nextId = (int)$stmtMax->fetchColumn();

                $stmtCheckVend = $db->prepare("
                    SELECT id FROM vendedores 
                    WHERE codemp = :codemp AND id = :id
                ");

                $stmtUpdateVend = $db->prepare("
                    UPDATE vendedores SET
                        nome = :nome,
                        last_mod = NOW()
                    WHERE codemp = :codemp AND id = :id
                ");

                $stmtInsertVend = $db->prepare("
                    INSERT INTO vendedores (
                        codemp, id, nome, last_mod
                    ) VALUES (
                        :codemp, :id, :nome, NOW()
                    )
                ");

                $totalInseridos = 0;
                $totalAtualizados = 0;

                foreach ($vendedores as $vendedor) {
                    if (!is_array($vendedor)) {
                        continue;
                    }

                    $nome = trim($vendedor['nome'] ?? '');
                    if ($nome === '') {
                        throw new Exception('Nome do vendedor é obrigatório');
                    }

                    $vendedorId = null;
                    if (isset($vendedor['id']) && ctype_digit((string)$vendedor['id'])) {
                        $vendedorId = (int)$vendedor['id'];
                    }

                    if (!$vendedorId || $vendedorId <= 0) {
                        $nextId++;
                        $vendedorId = $nextId;
                    }

                    $stmtCheckVend->execute([
                        'codemp' => $codemp,
                        'id' => $vendedorId
                    ]);

                    if ($stmtCheckVend->fetch()) {
                        $stmtUpdateVend->execute([
                            'nome' => $nome,
                            'codemp' => $codemp,
                            'id' => $vendedorId
                        ]);
                        $totalAtualizados++;
                    } else {
                        $stmtInsertVend->execute([
                            'codemp' => $codemp,
                            'id' => $vendedorId,
                            'nome' => $nome
                        ]);
                        $totalInseridos++;
                    }
                }

                $db->commit();

                http_response_code(200);
                echo json_encode([
                    'status' => true,
                    'mensagem' => 'Vendedores sincronizados com sucesso',
                    'inseridos' => $totalInseridos,
                    'atualizados' => $totalAtualizados
                ]);
            } catch (Exception $e) {
                $db->rollBack();
                throw $e;
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'status' => false,
                'mensagem' => $e->getMessage()
            ]);
        }
    }

    /**
     * POST /empresa/sync
     * Sincroniza dados da empresa vindos do sistema Delphi
     * 
     * Espera JSON:
     * {
     *   "cnpj": "12345678901234",
     *   "chave_api": "key_da_empresa",
     *   "cweb": 1,
     *   "dados": [
     *     {
     *       "Cnpj": "12.345.678/0001-23",
     *       "Ie": "123456789",
     *       "nomefantasia": "Nome Fantasia",
     *       "razaosocial": "Razão Social LTDA",
     *       "endereco": "Rua Exemplo",
     *       "End_Numero": "123",
     *       "Complemento": "Sala 1",
     *       "Bairro": "Centro",
     *       "Cidade": "São Paulo",
     *       "Uf": "SP",
     *       "Cep": "12345-678",
     *       "Fone": "(11) 1234-5678"
     *     }
     *   ],
     *   "formas_pagamento": [
     *     {
     *       "id": 1,
     *       "descricao": "Dinheiro",
     *       "parcelas": 1
     *     }
     *   ]
     * }
     * 
     * Retorna: {"status": true, "codigo_empresa": 123, "mensagem": "Sincronizado com sucesso"}
     * 

     */
    public function syncEmpresa() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);

            // Validar dados obrigatórios
            if (empty($data['cnpj'])) {
                http_response_code(400);
                echo json_encode([
                    'status' => false,
                    'mensagem' => 'CNPJ é obrigatório'
                ]);
                return;
            }

            if (empty($data['chave_api'])) {
                http_response_code(400);
                echo json_encode([
                    'status' => false,
                    'mensagem' => 'Chave API é obrigatória'
                ]);
                return;
            }

            if (empty($data['dados']) || !is_array($data['dados'])) {
                http_response_code(400);
                echo json_encode([
                    'status' => false,
                    'mensagem' => 'Dados da empresa são obrigatórios'
                ]);
                return;
            }

            $cnpjDigits = preg_replace('/[^0-9]/', '', $data['cnpj']);
            if (strlen($cnpjDigits) !== 14) {
                http_response_code(400);
                echo json_encode([
                    'status' => false,
                    'mensagem' => 'CNPJ deve conter 14 dígitos'
                ]);
                return;
            }

            $cnpjFormatado = $this->formatCnpjMasked($cnpjDigits);
            $chaveApi = $data['chave_api'];
            $cweb = $data['cweb'] ?? 0;
            $dadosEmpresa = $data['dados'][0]; // Pega o primeiro registro do array
            $formasPagamento = $data['formas_pagamento'] ?? [];
            $usuario = $data['usuario'] ?? [];

            $db = Database::getInstance()->getConnection();

            // Iniciar transação
            $db->beginTransaction();

            try {
                // 1. Verificar se a empresa já existe pelo CNPJ
                $stmtCheck = $db->prepare("
                    SELECT codemp, `key` 
                    FROM empresas 
                    WHERE REPLACE(REPLACE(REPLACE(cnpj, '.', ''), '/', ''), '-', '') = :cnpj
                    LIMIT 1
                ");
                $stmtCheck->execute(['cnpj' => $cnpjDigits]);
                $empresaExistente = $stmtCheck->fetch(PDO::FETCH_ASSOC);

                $codemp = null;

                if ($empresaExistente) {
                    // Validar chave API
                    if ($empresaExistente['key'] !== $chaveApi) {
                        throw new Exception('Chave API inválida para esta empresa');
                    }

                    // Empresa existe - fazer UPDATE
                    $codemp = $empresaExistente['codemp'];

                    $stmtUpdate = $db->prepare("
                        UPDATE empresas SET
                            nomefantasia = :nomefantasia,
                            razaosocial = :razaosocial,
                            endereco = :endereco,
                            end_numero = :end_numero,
                            complemento = :complemento,
                            bairro = :bairro,
                            fone = :fone,
                            cidade = :cidade,
                            uf = :uf,
                            cep = :cep,
                            ie = :ie
                        WHERE codemp = :codemp
                    ");

                    $stmtUpdate->execute([
                        'nomefantasia' => $dadosEmpresa['nomefantasia'] ?? '',
                        'razaosocial' => $dadosEmpresa['razaosocial'] ?? '',
                        'endereco' => $dadosEmpresa['endereco'] ?? '',
                        'end_numero' => $dadosEmpresa['end_numero'] ?? '',
                        'complemento' => $dadosEmpresa['complemento'] ?? '',
                        'bairro' => $dadosEmpresa['bairro'] ?? '',
                        'fone' => $dadosEmpresa['Fone'] ?? '',
                        'cidade' => $dadosEmpresa['cidade'] ?? '',
                        'uf' => $dadosEmpresa['uf'] ?? '',
                        'cep' => $dadosEmpresa['cep'] ?? '',
                        'ie' => $dadosEmpresa['ie'] ?? '',
                        'codemp' => $codemp
                    ]);

                } else {
                    // Empresa não existe - fazer INSERT
                    $stmtInsert = $db->prepare("
                        INSERT INTO empresas (
                            nomefantasia, razaosocial, endereco, end_numero, complemento,
                            bairro, fone, cidade, uf, cep, cnpj, ie,
                            ativo_sf, qtd_lic_sf, ativo_zap, `key`
                        ) VALUES (
                            :nomefantasia, :razaosocial, :endereco, :end_numero, :complemento,
                            :bairro, :fone, :cidade, :uf, :cep, :cnpj, :ie,
                            1, 2, 1, :key
                        )
                    ");

                    $stmtInsert->execute([
                        'nomefantasia' => $dadosEmpresa['nomefantasia'] ?? '',
                        'razaosocial' => $dadosEmpresa['razaosocial'] ?? '',
                        'endereco' => $dadosEmpresa['endereco'] ?? '',
                        'end_numero' => $dadosEmpresa['end_numero'] ?? '',
                        'complemento' => $dadosEmpresa['complemento'] ?? '',
                        'bairro' => $dadosEmpresa['bairro'] ?? '',
                        'fone' => $dadosEmpresa['Fone'] ?? '',
                        'cidade' => $dadosEmpresa['cidade'] ?? '',
                        'uf' => $dadosEmpresa['uf'] ?? '',
                        'cep' => $dadosEmpresa['cep'] ?? '',
                        'cnpj' => $cnpjFormatado,
                        'ie' => $dadosEmpresa['ie'] ?? '',
                        'key' => $chaveApi
                    ]);

                    $codemp = $db->lastInsertId();
                }

                // 2. Sincronizar formas de pagamento
                if (!empty($formasPagamento)) {
                    foreach ($formasPagamento as $forma) {
                        // Verificar se já existe
                        $stmtCheckForma = $db->prepare("
                            SELECT id FROM condpgto 
                            WHERE codemp = :codemp AND id = :id
                        ");
                        $stmtCheckForma->execute([
                            'codemp' => $codemp,
                            'id' => $forma['id']
                        ]);

                        if ($stmtCheckForma->fetch()) {
                            // UPDATE
                            $stmtUpdateForma = $db->prepare("
                                UPDATE condpgto SET
                                    descricao = :descricao,
                                    parcelas = :parcelas,
                                    last_mod = NOW()
                                WHERE codemp = :codemp AND id = :id
                            ");
                            $stmtUpdateForma->execute([
                                'descricao' => $forma['descricao'] ?? '',
                                'parcelas' => $forma['parcelas'] ?? 1,
                                'codemp' => $codemp,
                                'id' => $forma['id']
                            ]);
                        } else {
                            // INSERT
                            $stmtInsertForma = $db->prepare("
                                INSERT INTO condpgto (
                                    codemp, id, descricao, parcelas, 
                                    pacrescimo, pdesconto, last_mod
                                ) VALUES (
                                    :codemp, :id, :descricao, :parcelas, 
                                    0.0, 0.0, NOW()
                                )
                            ");
                            $stmtInsertForma->execute([
                                'codemp' => $codemp,
                                'id' => $forma['id'],
                                'descricao' => $forma['descricao'] ?? '',
                                'parcelas' => $forma['parcelas'] ?? 1
                            ]);
                        }
                    }
                }

                if (!empty($usuario)) {
                    foreach ($usuario as $index => $user) {
                        $usuarioId = isset($user['id']) && is_numeric($user['id'])
                            ? (int)$user['id']
                            : $index + 1;

                        // Verificar se usuário já existe
                        $stmtCheckUsuario = $db->prepare("
                            SELECT id FROM usuarios 
                            WHERE codemp = :codemp AND id = :id
                        ");
                        $stmtCheckUsuario->execute([
                            'codemp' => $codemp,
                            'id' => $usuarioId
                        ]);

                        if ($stmtCheckUsuario->fetch()) {
                            // UPDATE
                        $stmtUpdateUsuario = $db->prepare("
                            UPDATE usuarios SET
                                nome = :nome,
                                email = :email,
                                senha = :senha,
                                desconto_padrao = :desconto_padrao,
                                permite_desconto = :permite_desconto,
                                tipo_desconto = :tipo_desconto,
                                last_mod = NOW()
                            WHERE codemp = :codemp AND id = :id
                        ");
                        $stmtUpdateUsuario->execute([
                            'nome' => $user['nome'] ?? '',
                            'email' => $user['email'] ?? '',
                            'senha' => $user['senha'] ?? '',
                            'desconto_padrao' => $user['desconto_padrao'] ?? 10.00,
                            'permite_desconto' => $user['permite_desconto'] ?? 1,
                            'tipo_desconto' => $user['tipo_desconto'] ?? 'P',
                            'codemp' => $codemp,
                            'id' => $usuarioId
                        ]);
                        } else {
                        // INSERT
                        $stmtInsertUsuario = $db->prepare("
                            INSERT INTO usuarios (
                                codemp, id, nome, email, senha, 
                                desconto_padrao, permite_desconto, tipo_desconto, 
                                last_mod
                            ) VALUES (
                                :codemp, :id, :nome, :email, :senha,
                                :desconto_padrao, :permite_desconto, :tipo_desconto,
                                NOW()
                            )
                        ");
                        $stmtInsertUsuario->execute([
                            'codemp' => $codemp,
                            'id' => $usuarioId,
                            'nome' => $user['nome'] ?? '',
                            'email' => $user['email'] ?? '',
                            'senha' => $user['senha'] ?? '',
                            'desconto_padrao' => $user['desconto_padrao'] ?? 10.00,
                            'permite_desconto' => $user['permite_desconto'] ?? 1,
                            'tipo_desconto' => $user['tipo_desconto'] ?? 'P'
                        ]);
                        }
                    }
                }

                // Commit da transação
                $db->commit();

                // Retornar sucesso
                http_response_code(200);
                echo json_encode([
                    'status' => true,
                    'codigo_empresa' => (int)$codemp,
                    'mensagem' => 'Empresa sincronizada com sucesso'
                ]);

            } catch (Exception $e) {
                $db->rollBack();
                throw $e;
            }

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'status' => false,
                'mensagem' => $e->getMessage()
            ]);
        }
    }

    /**
     * GET /empresa/{codemp}
     * Retorna dados da empresa com usuários e formas de pagamento
     *
     * Retorna:
     * {
     *   "success": true,
     *   "empresa": {...},
     *   "usuarios": [...],
     *   "formasPagamento": [...]
     * }
     */
    public function get($codemp = null) {
        try {
            $codemp = $this->resolveCodemp($codemp);
            $db = Database::getInstance()->getConnection();

            // Buscar dados da empresa
            $stmtEmpresa = $db->prepare("
                SELECT
                    codemp, nomefantasia, razaosocial, endereco, end_numero, complemento,
                    bairro, fone, cidade, uf, cep, cnpj, ie,
                    ativo_sf, qtd_lic_sf, ativo_zap, `key`
                FROM empresas
                WHERE codemp = :codemp
            ");
            $stmtEmpresa->execute(['codemp' => $codemp]);
            $empresa = $stmtEmpresa->fetch(PDO::FETCH_ASSOC);

            if (!$empresa) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'message' => 'Empresa não encontrada'
                ]);
                return;
            }

            // Buscar usuários
            $stmtUsuarios = $db->prepare("
                SELECT id, nome, email, last_mod
                FROM usuarios
                WHERE codemp = :codemp
                ORDER BY id
            ");
            $stmtUsuarios->execute(['codemp' => $codemp]);
            $usuarios = $stmtUsuarios->fetchAll(PDO::FETCH_ASSOC);

            // Buscar formas de pagamento
            $stmtCondPgto = $db->prepare("
                SELECT id, descricao, parcelas, pacrescimo, pdesconto, last_mod
                FROM condpgto
                WHERE codemp = :codemp
                ORDER BY id
            ");
            $stmtCondPgto->execute(['codemp' => $codemp]);
            $formasPagamento = $stmtCondPgto->fetchAll(PDO::FETCH_ASSOC);

            // Retornar dados completos
            http_response_code(200);
            echo json_encode([
                'success' => true,
                'empresa' => $empresa,
                'usuarios' => $usuarios,
                'formasPagamento' => $formasPagamento
            ]);

        } catch (InvalidArgumentException $e) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => $e->getMessage()
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => $e->getMessage()
            ]);
        }
    }

    /**
     * GET /empresa
     * Retorna todas as empresas (lista simplificada)
     */
    public function getAll() {
        try {
            $codemp = $this->resolveCodemp();
            $db = Database::getInstance()->getConnection();

            $stmt = $db->prepare("
                SELECT
                    codemp, nomefantasia, razaosocial, cnpj, cidade, uf,
                    ativo_sf, qtd_lic_sf, ativo_zap
                FROM empresas
                WHERE codemp = :codemp
                ORDER BY nomefantasia
            ");
            $stmt->execute(['codemp' => $codemp]);
            $empresas = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            if (empty($empresas)) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'message' => 'Empresa não encontrada para o código informado'
                ]);
                return;
            }

            http_response_code(200);
            echo json_encode([
                'success' => true,
                'empresas' => $empresas
            ]);

        } catch (InvalidArgumentException $e) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => $e->getMessage()
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => $e->getMessage()
            ]);
        }
    }

    
}