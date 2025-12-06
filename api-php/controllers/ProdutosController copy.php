<?php
class ProdutosController {

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
     * Listar todos os produtos
     * GET /api/produtos
     * 
     * 
     */
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

            $cnpj = preg_replace('/[^0-9]/', '', $data['cnpj']);
            $chaveApi = $data['chave_api'];
            $codemp = (int)$data['codemp'];
            $produtos = $data['produtos'];
            $produtosInativos = $data['produtos_inativos'] ?? [];

            $db = Database::getInstance()->getConnection();

            // Validar empresa e chave API
            $stmtEmpresa = $db->prepare("SELECT codemp, `key` FROM empresas WHERE cnpj = :cnpj LIMIT 1");
            $stmtEmpresa->execute(['cnpj' => $cnpj]);
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

    public function getAll() {
        $codEmp = $_GET['codEmp'] ?? ($GLOBALS['cod_emp'] ?? null);

        try {
            $db = Database::getInstance()->getConnection();

            $sql = "SELECT * FROM produtos_sf";
            $params = [];

            if ($codEmp) {
                $sql .= " WHERE CodEmp = :codEmp";
                $params['codEmp'] = $codEmp;
            }

            $sql .= " ORDER BY Descricao";

            $stmt = $db->prepare($sql);
            $stmt->execute($params);
            $produtos = $stmt->fetchAll();

            http_response_code(200);
            echo json_encode([
                'success' => true,
                'data' => $produtos,
                'count' => count($produtos)
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erro ao buscar produtos',
                'message' => $e->getMessage()
            ]);
        }
    }

    /**
     * Buscar produto por ID
     * GET /api/produtos/{id}
     */
    public function getById($id) {
        try {
            $db = Database::getInstance()->getConnection();

            $stmt = $db->prepare("SELECT * FROM produtos_sf WHERE Codigo = :id");
            $stmt->execute(['id' => $id]);
            $produto = $stmt->fetch();

            if (!$produto) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'error' => 'Produto não encontrado'
                ]);
                return;
            }

            http_response_code(200);
            echo json_encode([
                'success' => true,
                'data' => $produto
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erro ao buscar produto',
                'message' => $e->getMessage()
            ]);
        }
    }

    /**
     * Buscar produto por código de barras
     * GET /api/produtos/barcode/{barcode}
     */
    public function getByBarcode($barcode) {
        try {
            $db = Database::getInstance()->getConnection();

            $stmt = $db->prepare("SELECT * FROM produtos_sf WHERE Codigo_Barras = :barcode");
            $stmt->execute(['barcode' => $barcode]);
            $produto = $stmt->fetch();

            if (!$produto) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'error' => 'Produto não encontrado'
                ]);
                return;
            }

            http_response_code(200);
            echo json_encode([
                'success' => true,
                'data' => $produto
            ]);

        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erro ao buscar produto',
                'message' => $e->getMessage()
            ]);
        }
    }
}
