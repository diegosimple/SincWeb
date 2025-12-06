# API PHP - ConectivaSF

API REST em PHP para comunicação com app mobile React Native.

## 📋 Requisitos

- PHP 7.4 ou superior
- MySQL 5.7+ ou MariaDB 10.2+
- Composer
- Extensões PHP:
  - PDO
  - pdo_mysql
  - json
  - mbstring

## 🚀 Instalação

### 1. Instalar Dependências

```bash
cd api-php
composer install
```

Isso instalará o `firebase/php-jwt` necessário para autenticação JWT.

### 2. Configurar Banco de Dados MySQL

Edite o arquivo `config/config.php` com os dados do seu MySQL em nuvem:

```php
define('DB_HOST', 'seu-servidor.mysql.com.br');
define('DB_NAME', 'conectivasf');
define('DB_USER', 'seu_usuario');
define('DB_PASS', 'sua_senha');
```

### 3. Criar Tabelas no Banco

Execute o script SQL no seu banco MySQL:

```bash
mysql -h seu-servidor.mysql.com.br -u seu_usuario -p conectivasf < database/schema.sql
```

Ou copie e execute o conteúdo de `database/schema.sql` no phpMyAdmin ou outro cliente MySQL.

### 4. Configurar Servidor Web

#### Apache (.htaccess já incluído)

O arquivo `.htaccess` redireciona todas as requisições para `public/index.php`.

```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ public/index.php [QSA,L]
```

Certifique-se que o `mod_rewrite` está ativo:

```bash
sudo a2enmod rewrite
sudo service apache2 restart
```

#### Nginx

```nginx
server {
    listen 80;
    server_name seu-dominio.com.br;
    root /caminho/para/api-php/public;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

### 5. Permissões

```bash
chmod -R 755 api-php/
chmod -R 775 api-php/logs/ (se criar pasta de logs)
```

## 🔌 Endpoints da API

### Base URL

```
http://seu-dominio.com.br/api-php/api
```

ou se estiver na raiz:

```
http://seu-dominio.com.br/api
```

### Autenticação

#### POST /api/auth/login

Login de usuário e obtenção de token JWT.

**Request:**
```json
{
  "email": "admin@conectivasf.com",
  "senha": "admin123"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "nome": "Administrador",
    "email": "admin@conectivasf.com",
    "codEmp": 1
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### Clientes

**Headers obrigatório:**
```
Authorization: Bearer {token}
```

#### GET /api/clientes

Lista todos os clientes.

**Query Params:**
- `codEmp` (opcional) - Filtrar por empresa

#### GET /api/clientes/{id}

Busca cliente por ID.

#### POST /api/clientes

Criar novo cliente.

#### PUT /api/clientes/{id}

Atualizar cliente.

---

### Produtos

#### GET /api/produtos

Lista todos os produtos.

#### GET /api/produtos/{id}

Busca produto por ID.

#### GET /api/produtos/barcode/{codigo_barras}

Busca produto por código de barras.

---

### Pedidos

#### GET /api/pedidos

Lista todos os pedidos.

#### GET /api/pedidos/{id}

Busca pedido por ID com itens.

#### POST /api/pedidos

Criar novo pedido.

**Request:**
```json
{
  "CodCliente": 1,
  "Valor_Total": 500.00,
  "Status": "Pendente",
  "Obs": "Observações do pedido",
  "itens": [
    {
      "CodProduto": 1,
      "Quantidade": 2,
      "Preco_Unitario": 150.00,
      "Valor_Total": 300.00
    }
  ]
}
```

#### PUT /api/pedidos/{id}

Atualizar pedido.

#### POST /api/pedidos/sync

Sincronizar múltiplos pedidos do app mobile.

**Request:**
```json
{
  "pedidos": [
    {
      "Numero_Pedido": "PED001",
      "CodCliente": 1,
      "CodVendedor": 1,
      "Data_Pedido": "2025-01-15 10:30:00",
      "Valor_Total": 500.00,
      "Status": "Pendente",
      "CodEmp": 1,
      "itens": [...]
    }
  ]
}
```

---

### Sincronização

#### POST /api/sync/all

Sincronizar todos os dados (baixar clientes, produtos, planos).

**Request:**
```json
{
  "codEmp": 1,
  "lastSync": "2025-01-01 00:00:00"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Sincronização concluída",
  "data": {
    "clientes": [...],
    "produtos": [...],
    "planosPagamento": [...]
  },
  "syncDate": "2025-01-15 14:30:00",
  "counts": {
    "clientes": 150,
    "produtos": 500,
    "planosPagamento": 5
  }
}
```

#### GET /api/sync/last

Retorna data da última sincronização.

**Query Params:**
- `codEmp` (obrigatório)

---

## 🔐 Segurança

### Produção

Antes de colocar em produção:

1. **Altere o JWT_SECRET** em `config/config.php`
2. **Desabilite error reporting**:
```php
error_reporting(0);
ini_set('display_errors', 0);
```

3. **Configure CORS** para domínio específico:
```php
define('CORS_ALLOW_ORIGIN', 'https://seu-dominio.com.br');
```

4. **Use HTTPS** sempre!

5. **Hash de senhas**: Implemente bcrypt para senhas:
```php
// Criar senha
$hash = password_hash($senha, PASSWORD_BCRYPT);

// Verificar senha
if (password_verify($senha, $hash)) {
    // OK
}
```

## 📱 Integração com App Mobile

Configure a URL da API no app React Native:

Edite `mobile/src/services/api.js`:

```javascript
const API_BASE_URL = 'https://seu-dominio.com.br/api-php/api';
```

## 🧪 Testar API

### Com cURL

```bash
# Login
curl -X POST http://seu-dominio.com.br/api-php/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@conectivasf.com","senha":"admin123"}'

# Listar clientes (com token)
curl -X GET http://seu-dominio.com.br/api-php/api/clientes \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

### Com Postman/Insomnia

Importe a coleção e teste todos os endpoints.

## 📝 Logs

Para habilitar logs de erro, crie a pasta:

```bash
mkdir api-php/logs
chmod 775 api-php/logs
```

Os erros serão gravados em `logs/error.log`.

## 🆘 Troubleshooting

### Erro 404 em todas as rotas

- Verifique se o `mod_rewrite` está ativo (Apache)
- Verifique se o `.htaccess` existe em `public/`

### Erro de conexão com banco

- Verifique as credenciais em `config/config.php`
- Verifique se o MySQL aceita conexões remotas
- Verifique firewall do servidor

### Erro "Class Firebase\JWT\JWT not found"

- Execute `composer install` na pasta `api-php/`

## 📦 Estrutura de Arquivos

```
api-php/
├── config/
│   ├── config.php           # Configurações gerais
│   └── Database.php         # Classe de conexão
├── controllers/             # Controladores
├── middleware/              # Middleware de autenticação
├── database/
│   └── schema.sql          # Script SQL
├── public/
│   ├── .htaccess           # Rewrite rules
│   └── index.php           # Entry point
├── composer.json           # Dependências
└── README.md
```

## ✅ Checklist de Deploy

- [ ] Composer install executado
- [ ] Banco de dados criado e configurado
- [ ] Schema SQL executado
- [ ] config.php atualizado com dados corretos
- [ ] JWT_SECRET alterado
- [ ] Error reporting desabilitado
- [ ] CORS configurado
- [ ] HTTPS configurado
- [ ] Permissões de arquivo corretas
- [ ] Teste de todos os endpoints
- [ ] App mobile conectado e testado

---

**Login Padrão:**
```
Email: admin@conectivasf.com
Senha: admin123
```

Altere a senha padrão após primeiro acesso!
