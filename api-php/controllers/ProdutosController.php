<?php

require_once __DIR__ . '/../config/Database.php';

class ProdutosController {
    /**
     * Formata CNPJ (somente dígitos) para 00.000.000/0000-00
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
     * Recupera e valida o código da empresa
     */
    private function resolveCodemp($codemp = null) {
        $value = $codemp
            ?? $_GET['codemp']
            ?? $_GET['codEmp']
            ?? $_GET['id']
            ?? ($GLOBALS['cod_emp'] ?? null);

        if ($value === null || $value === '') {
            throw new InvalidArgumentException('Informe o código da empresa (codemp)');
        }

        $value = (string)$value;

        if (!ctype_digit($value)) {
            throw new InvalidArgumentException('O código da empresa deve ser numérico');
        }

        return (int)$value;
    }

    /**
     * POST /produtos/sync
     * Sincroniza produtos vindos do sistema Delphi
     * 
     * Espera JSON:
     * {
     *   "cnpj": "12345678901234",
     *   "chave_api": "key_da_empresa",
     *   "codemp": 1,
     *   "produtos_inativos": [1, 2, 3],
     *   "produtos": [
     *     {
     *       "id": 1,
     *       "mercadoria": "Produto Teste",
     *       "apelido": "Produto Teste",
     *       "ean": "7891234567890",
     *       "referencia": "REF001",
     *       "um": "UN",
     *       "peso": 1.5,
     *       "preco": 99.90,
     *       "descontomax": 10.0,
     *       "estoque": 100.0,
     *       "img1": "base64_string_ou_null"
     *     }
     *   ]
     * }
     * 
     * Retorna: {"status": true, "total_sincronizados": 10, "total_excluidos": 2}
     */
    public function syncProdutos() {
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

            if (empty($data['codemp'])) {
                http_response_code(400);
                echo json_encode([
                    'status' => false,
                    'mensagem' => 'Código da empresa é obrigatório'
                ]);
                return;
            }

            if (empty($data['produtos']) || !is_array($data['produtos'])) {
                http_response_code(400);
                echo json_encode([
                    'status' => false,
                    'mensagem' => 'Lista de produtos é obrigatória'
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
            $codemp = (int)$data['codemp'];
            $produtos = $data['produtos'];
            $produtosInativos = $data['produtos_inativos'] ?? [];

            $db = Database::getInstance()->getConnection();

            // Validar empresa e chave API
            $stmtEmpresa = $db->prepare("
                SELECT codemp, `key`, cnpj 
                FROM empresas 
                WHERE REPLACE(REPLACE(REPLACE(cnpj, '.', ''), '/', ''), '-', '') = :cnpj
                LIMIT 1
            ");
            $stmtEmpresa->execute(['cnpj' => $cnpjDigits]);
            $empresa = $stmtEmpresa->fetch(PDO::FETCH_ASSOC);

            if (!$empresa) {
                throw new Exception('Empresa não encontrada');
            }

            if ($empresa['key'] !== $chaveApi) {
                throw new Exception('Chave API inválida');
            }

            if ($empresa['codemp'] != $codemp) {
                throw new Exception('Código da empresa não corresponde ao CNPJ informado');
            }

            // Iniciar transação
            $db->beginTransaction();

            try {
                $totalSincronizados = 0;
                $totalExcluidos = 0;

                // 1. Excluir produtos inativos
                if (!empty($produtosInativos)) {
                    $placeholders = implode(',', array_fill(0, count($produtosInativos), '?'));
                    $stmtDelete = $db->prepare("
                        DELETE FROM produtos 
                        WHERE codemp = ? AND id IN ($placeholders)
                    ");
                    
                    $params = array_merge([$codemp], $produtosInativos);
                    $stmtDelete->execute($params);
                    $totalExcluidos = $stmtDelete->rowCount();
                }

                // 2. Preparar statement para INSERT/UPDATE
                $stmtProduto = $db->prepare("
                    INSERT INTO produtos (
                        codemp, id, mercadoria, apelido, ean, referencia, 
                        um, peso, preco, descontomax, img1, estoque, last_mod
                    ) VALUES (
                        :codemp, :id, :mercadoria, :apelido, :ean, :referencia,
                        :um, :peso, :preco, :descontomax, :img1, :estoque, NOW()
                    )
                    ON DUPLICATE KEY UPDATE
                        mercadoria = VALUES(mercadoria),
                        apelido = VALUES(apelido),
                        ean = VALUES(ean),
                        referencia = VALUES(referencia),
                        um = VALUES(um),
                        peso = VALUES(peso),
                        preco = VALUES(preco),
                        descontomax = VALUES(descontomax),
                        img1 = VALUES(img1),
                        estoque = VALUES(estoque),
                        last_mod = NOW()
                ");

                // 3. Processar cada produto
                foreach ($produtos as $produto) {
                    // Decodificar imagem base64 se existir
                    $img1 = null;
                    if (!empty($produto['img1']) && $produto['img1'] !== 'null') {
                        $img1 = base64_decode($produto['img1']);
                    }

                    $stmtProduto->execute([
                        'codemp' => $codemp,
                        'id' => $produto['id'] ?? 0,
                        'mercadoria' => $produto['mercadoria'] ?? '',
                        'apelido' => $produto['apelido'] ?? '',
                        'ean' => $produto['ean'] ?? '',
                        'referencia' => $produto['referencia'] ?? '',
                        'um' => $produto['um'] ?? 'UN',
                        'peso' => $produto['peso'] ?? 0.0,
                        'preco' => $produto['preco'] ?? 0.0,
                        'descontomax' => $produto['descontomax'] ?? 0.0,
                        'img1' => $img1,
                        'estoque' => $produto['estoque'] ?? 0.0
                    ]);

                    $totalSincronizados++;
                }

                // Commit da transação
                $db->commit();

                // Retornar sucesso
                http_response_code(200);
                echo json_encode([
                    'status' => true,
                    'mensagem' => 'Produtos sincronizados com sucesso',
                    'total_sincronizados' => $totalSincronizados,
                    'total_excluidos' => $totalExcluidos
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
     * GET /produtos
     * Listar todos os produtos
     */
    public function getAll() {
        try {
            $codemp = $this->resolveCodemp();
            $db = Database::getInstance()->getConnection();

            $stmt = $db->prepare("
                SELECT 
                    id, mercadoria, apelido, ean, referencia, 
                    um, peso, preco, descontomax, estoque, last_mod
                FROM produtos
                WHERE codemp = :codemp
                ORDER BY mercadoria
            ");
            $stmt->execute(['codemp' => $codemp]);
            $produtos = $stmt->fetchAll(PDO::FETCH_ASSOC);

            http_response_code(200);
            echo json_encode([
                'success' => true,
                'produtos' => $produtos,
                'total' => count($produtos)
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
     * GET /produtos/{id}
     * Buscar produto por ID
     */
    public function getById($id) {
        try {
            $codemp = $this->resolveCodemp();
            $db = Database::getInstance()->getConnection();

            $stmt = $db->prepare("
                SELECT * FROM produtos 
                WHERE codemp = :codemp AND id = :id
            ");
            $stmt->execute([
                'codemp' => $codemp,
                'id' => $id
            ]);
            $produto = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$produto) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'message' => 'Produto não encontrado'
                ]);
                return;
            }

            // Converter img1 para base64 se existir
            if (!empty($produto['img1'])) {
                $produto['img1'] = base64_encode($produto['img1']);
            }

            http_response_code(200);
            echo json_encode([
                'success' => true,
                'produto' => $produto
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
     * GET /produtos/barcode/{ean}
     * Buscar produto por código de barras
     */
    public function getByBarcode($ean) {
        try {
            $codemp = $this->resolveCodemp();
            $db = Database::getInstance()->getConnection();

            $stmt = $db->prepare("
                SELECT * FROM produtos 
                WHERE codemp = :codemp AND ean = :ean
                LIMIT 1
            ");
            $stmt->execute([
                'codemp' => $codemp,
                'ean' => $ean
            ]);
            $produto = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$produto) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'message' => 'Produto não encontrado'
                ]);
                return;
            }

            // Converter img1 para base64 se existir
            if (!empty($produto['img1'])) {
                $produto['img1'] = base64_encode($produto['img1']);
            }

            http_response_code(200);
            echo json_encode([
                'success' => true,
                'produto' => $produto
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
     * PUT /produtos/{id}/imagem
     * Atualiza apenas a imagem de um produto
     * 
     * Espera JSON:
     * {
     *   "cnpj": "12345678901234",
     *   "chave_api": "key_da_empresa",
     *   "codemp": 1,
     *   "img1": "base64_string"
     * }
     * 
     * Retorna: {"status": true, "mensagem": "Imagem atualizada"}
     */
    public function updateImagem($id) {
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

            if (empty($data['codemp'])) {
                http_response_code(400);
                echo json_encode([
                    'status' => false,
                    'mensagem' => 'Código da empresa é obrigatório'
                ]);
                return;
            }

            if (empty($data['img1'])) {
                http_response_code(400);
                echo json_encode([
                    'status' => false,
                    'mensagem' => 'Imagem é obrigatória'
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
            $codemp = (int)$data['codemp'];
            $img1Base64 = $data['img1'];

            $db = Database::getInstance()->getConnection();

            // Validar empresa e chave API
            $stmtEmpresa = $db->prepare("
                SELECT codemp, `key`, cnpj 
                FROM empresas 
                WHERE REPLACE(REPLACE(REPLACE(cnpj, '.', ''), '/', ''), '-', '') = :cnpj
                LIMIT 1
            ");
            $stmtEmpresa->execute(['cnpj' => $cnpjDigits]);
            $empresa = $stmtEmpresa->fetch(PDO::FETCH_ASSOC);

            if (!$empresa) {
                throw new Exception('Empresa não encontrada');
            }

            if ($empresa['key'] !== $chaveApi) {
                throw new Exception('Chave API inválida');
            }

            if ($empresa['codemp'] != $codemp) {
                throw new Exception('Código da empresa não corresponde ao CNPJ informado');
            }

            // Verificar se produto existe
            $stmtCheck = $db->prepare("SELECT id FROM produtos WHERE codemp = :codemp AND id = :id");
            $stmtCheck->execute(['codemp' => $codemp, 'id' => $id]);
            
            if (!$stmtCheck->fetch()) {
                http_response_code(404);
                echo json_encode([
                    'status' => false,
                    'mensagem' => 'Produto não encontrado'
                ]);
                return;
            }

            // Decodificar imagem base64
            $img1 = base64_decode($img1Base64);

            if ($img1 === false) {
                throw new Exception('Erro ao decodificar imagem Base64');
            }

            // Atualizar apenas a imagem
            $stmtUpdate = $db->prepare("
                UPDATE produtos 
                SET img1 = :img1, last_mod = NOW() 
                WHERE codemp = :codemp AND id = :id
            ");

            $stmtUpdate->execute([
                'img1' => $img1,
                'codemp' => $codemp,
                'id' => $id
            ]);

            // Retornar sucesso
            http_response_code(200);
            echo json_encode([
                'status' => true,
                'mensagem' => 'Imagem atualizada com sucesso'
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'status' => false,
                'mensagem' => $e->getMessage()
            ]);
        }
    }
}