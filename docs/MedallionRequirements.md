# Arquitetura medalhão MKL Bank

## Documentação do sistema core do banco mkl.
O sistema core do banco MKL possui as tabelas com os schemas na pasta `sample_sintetic_data`. 

Tabelas: 
- `agencias.csv`
- `cartoes.csv`
- `chaves_pix.csv`
- `clientes.csv`
- `contas.csv`
- `movimentacao_boleto_pago.csv`
- `movimentacao_deposito_recebido.csv`
- `movimentacao_pagamento_cartao.csv`
- `movimentacao_pix_realizado.csv`
- `movimentacao_pix_recebido.csv`
- `movimentacao_transferencia_realizada.csv`
- `movimentacao_transferencia_recebida.csv`
- `transacoes.csv`

## Esquema das Colunas por Arquivo

### 1. **agencias.csv**
- `agencia_id` - Identificador único da agência
- `nome_agencia` - Nome da agência
- `endereco` - Endereço da agência
- `cidade` - Cidade da agência
- `estado` - Estado da agência
- `cep` - CEP da agência
- `telefone` - Telefone da agência

### 2. **cartoes.csv**
- `cartao_id` - Identificador único do cartão
- `conta_id` - Identificador da conta associada
- `numero_cartao` - Número do cartão
- `tipo_cartao` - Tipo do cartão (débito/crédito)
- `data_emissao` - Data de emissão do cartão
- `data_validade` - Data de validade do cartão
- `limite` - Limite do cartão
- `status` - Status do cartão (ativo/bloqueado/cancelado)

### 3. **chaves_pix.csv**
- `chave_pix_id` - Identificador único da chave PIX
- `conta_id` - Identificador da conta associada
- `tipo_chave` - Tipo da chave (CPF/CNPJ/email/telefone/aleatória)
- `valor_chave` - Valor da chave PIX
- `data_cadastro` - Data de cadastro da chave
- `status` - Status da chave (ativa/inativa)

### 4. **clientes.csv**
- `cliente_id` - Identificador único do cliente
- `nome` - Nome completo do cliente
- `cpf` - CPF do cliente
- `data_nascimento` - Data de nascimento
- `email` - Email do cliente
- `telefone` - Telefone do cliente
- `endereco` - Endereço do cliente
- `cidade` - Cidade do cliente
- `estado` - Estado do cliente
- `cep` - CEP do cliente
- `data_cadastro` - Data de cadastro do cliente

### 5. **contas.csv**
- `conta_id` - Identificador único da conta
- `cliente_id` - Identificador do cliente
- `agencia_id` - Identificador da agência
- `numero_conta` - Número da conta
- `tipo_conta` - Tipo da conta (corrente/poupança)
- `saldo` - Saldo da conta
- `data_abertura` - Data de abertura da conta
- `status` - Status da conta (ativa/bloqueada/encerrada)

### 6. **movimentacao_boleto_pago.csv**
- `transacao_id` - Identificador da transação
- `conta_id` - Identificador da conta
- `codigo_barras` - Código de barras do boleto
- `valor` - Valor pago
- `data_pagamento` - Data do pagamento
- `beneficiario` - Nome do beneficiário

### 7. **movimentacao_deposito_recebido.csv**
- `transacao_id` - Identificador da transação
- `conta_id` - Identificador da conta
- `valor` - Valor depositado
- `data_deposito` - Data do depósito
- `tipo_deposito` - Tipo de depósito (dinheiro/cheque)
- `depositante` - Nome do depositante

### 8. **movimentacao_pagamento_cartao.csv**
- `transacao_id` - Identificador da transação
- `cartao_id` - Identificador do cartão
- `valor` - Valor da transação
- `data_pagamento` - Data do pagamento
- `estabelecimento` - Nome do estabelecimento
- `categoria` - Categoria da compra

### 9. **movimentacao_pix_realizado.csv**
- `transacao_id` - Identificador da transação
- `conta_origem_id` - Identificador da conta origem
- `chave_pix_destino` - Chave PIX de destino
- `valor` - Valor transferido
- `data_transferencia` - Data da transferência
- `descricao` - Descrição da transferência

### 10. **movimentacao_pix_recebido.csv**
- `transacao_id` - Identificador da transação
- `conta_destino_id` - Identificador da conta destino
- `chave_pix_origem` - Chave PIX de origem
- `valor` - Valor recebido
- `data_recebimento` - Data do recebimento
- `descricao` - Descrição da transferência

### 11. **movimentacao_transferencia_realizada.csv**
- `transacao_id` - Identificador da transação
- `conta_origem_id` - Identificador da conta origem
- `conta_destino_id` - Identificador da conta destino
- `valor` - Valor transferido
- `data_transferencia` - Data da transferência
- `tipo_transferencia` - Tipo (TED/DOC)

### 12. **movimentacao_transferencia_recebida.csv**
- `transacao_id` - Identificador da transação
- `conta_destino_id` - Identificador da conta destino
- `conta_origem_id` - Identificador da conta origem
- `valor` - Valor recebido
- `data_recebimento` - Data do recebimento
- `tipo_transferencia` - Tipo (TED/DOC)

### 13. **transacoes.csv**
- `transacao_id` - Identificador único da transação
- `conta_id` - Identificador da conta
- `tipo_transacao` - Tipo da transação
- `valor` - Valor da transação
- `data_transacao` - Data e hora da transação
- `descricao` - Descrição da transação
- `status` - Status da transação (processada/pendente/cancelada)

Estes esquemas representam a estrutura típica de um sistema bancário core, com tabelas para gerenciar clientes, contas, transações e diferentes tipos de movimentações financeiras.

## Sistema Core 

O Sistema core deve conter  todas as tabelas salvas no postgresql na Azure. 

## Engenharia de dados e camada medalhão

### Ingestão
Dados ingeridos no Databricks e salvos do ADLS Gen2
Para a camada Bronze no formato delta.

### Transformações  
**Camada Silver**  
Dados na camada silver com o schema das tabelas forçando a tipagem de dados e criação de coluna `saved_date` com o timestamp da data que o dado foi salvo.  

**Camada Gold**  
Dados da camada gold separados em `star schema` com `Slow Change Dimension Type 2` salvos em fatos e dimensões. 

**Camada Platinum**  
Tabelas com os produtos de dados conforme o arquivo `DataProducts.md`


## Camada Semântica  
Será feita usando o Fabric e o Powerbi usando semantic models e DirectLake para melhor performance.


## Referências

