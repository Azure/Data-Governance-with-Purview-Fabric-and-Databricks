# Infraestrutura de Governança de Dados

Este diretório contém templates de **Infrastructure as Code (IaC)** em **Bicep** e **Terraform** para implantar a plataforma de Governança de Dados no Azure: ingestão (Event Hub), processamento (Databricks), armazenamento (Data Lake), analytics (Fabric) e persistência relacional (PostgreSQL), agora com **Key Vault** e **Event Hub Capture** integrados.

## Quick Start

### Implantação com Bicep
```powershell
cd bicep
az deployment sub create --name "dg-deployment" --location "eastus" --template-file "main.bicep" --parameters "main.bicepparam"
```

### Implantação com Terraform
```powershell
cd terraform
terraform init
terraform plan -var-file="environments/dev/terraform.tfvars"
terraform apply -var-file="environments/dev/terraform.tfvars" -auto-approve
```

## Arquitetura (Componentes)

| Recurso | Propósito | Principais Configs |
|---------|-----------|--------------------|
| Azure Storage | Data Lake (bronze / silver / gold / staging / ehcapture) | TLS 1.2, versioning, containers parametrizados |
| Azure Databricks | Processamento & ML | SKU parametrizável, no-public-IP opcional |
| Microsoft Fabric | BI / Semântica | Capacidade F SKU dinâmica |
| PostgreSQL Flexible Server | Metadados / aplicações | Versões 11–17 suportadas (padrão 17 Bicep, ajustável) |
| Event Hub (market-data) | Streaming de cotações & eventos | Capture habilitado, consumer groups dinâmicos |
| Managed Identity | Acesso seguro a segredos | User-assigned |
| Key Vault | Gestão de segredos (senhas e conexões) | Soft delete + purge protection |

### Novidades Recentes
* ✅ **Event Hub** único `market-data` com:
	* Partition key = símbolo (definido pelo produtor).
	* Consumer groups parametrizados (ex: `raw-loader`, `analytics`, `replay`).
	* **Capture** para Blob Container `ehcapture` (Avro) – replay histórico.
* ✅ **Key Vault** provisionado (Bicep sempre; Terraform opcional via flag) armazenando `postgres-admin-password` e (Terraform) `eventhub-connection-string`.
* ✅ Lista de símbolos consolidada em `assets/sample_sintetic_data/market_data_subscriptions.json`.

## Documentação

Consulte:
* `../README.md` – visão geral do projeto.
* `../docs/deployment-guide.md` – guia detalhado de deployment.
* `../docs/postgres-azure-ad-admins.md` – administração Azure AD no PostgreSQL.
* Notebook `notebooks/09_secrets_and_eventhub_demo.ipynb` – uso prático de Key Vault + Event Hub.

### Paridade Bicep x Terraform (Resumo)
| Item | Bicep | Terraform |
|------|-------|-----------|
| Key Vault | Sempre implantado (sem flag) | Controlado via `enable_key_vault` |
| Segredo Postgres | Criado | Criado |
| Segredo Event Hub | Manual pós-deploy (exemplo no README raiz) | Automático (usa output `primary_connection_string`) |
| Event Hub Capture | Parametrizado | Parametrizado |
| Consumer Groups | Param `eventHubConfig.consumerGroups` | Var `eventhub_consumer_groups` |
| Lista de símbolos | Arquivo JSON | Idem | 

### Segredos & Fallback `.env`
Fluxo recomendado no código:
1. Tentar Key Vault (DefaultAzureCredential / MSI).
2. Fallback para variáveis de ambiente ou `.env` (dev local).
3. Nunca comitar senhas em arquivos de parâmetros.

Variables/Segredos padrão:
| Lógico | Key Vault | Env fallback |
|--------|-----------|--------------|
| Postgres password | `postgres-admin-password` | `PGPASSWORD` / `POSTGRES_ADMIN_PASSWORD` |
| Event Hub connection | `eventhub-connection-string` (Terraform) | `EVENTHUB_CONNECTION_STRING` |

Exportar URI do KV para uso em notebooks / apps:
```powershell
azd env set KEY_VAULT_URI "https://<kv-name>.vault.azure.net/"
```

### Event Hub Capture
| Parâmetro | Exemplo | Função |
|-----------|---------|--------|
| Interval | 300 seg | Gatilho por tempo |
| SizeLimit | 314572800 bytes (~300MB) | Gatilho por volume |
| Encoding | Avro | Formato do arquivo |
| Container | `ehcapture` | Reprocessamento / replay |

Reprocesso: listar blobs por ordem temporal & ingerir novamente (ex: Spark Avro → Bronze). 

## Estrutura de Diretórios

```
bicep/                 # Templates Bicep com tipos definidos pelo usuário
├── main.bicep        # Template principal
├── main.bicepparam   # Arquivo de parâmetros
├── modules/          # Módulos Bicep
└── types/           # Tipos definidos pelo usuário

terraform/            # Configurações Terraform
├── main.tf          # Configuração principal
├── variables.tf     # Variáveis
├── outputs.tf       # Saídas
├── modules/         # Módulos Terraform
└── environments/    # Configurações específicas por ambiente
keyvault/ (Terraform módulo)         # Gestão de segredos
eventhub/ (Terraform módulo)         # Streaming + capture + CGs
```

## Parametrização Principal

### Bicep (`main.bicep` / `main.bicepparam`)
| Grupo | Parâmetro | Descrição |
|-------|-----------|-----------|
| PostgreSQL | `postgresConfig.version` | Versão (11–17) |
| Event Hub | `eventHubConfig.topicName` | Nome (padrão `market-data`) |
| Event Hub | `eventHubConfig.consumerGroups` | Lista de consumer groups |
| Event Hub | `eventHubConfig.capture*` | Controle de Capture |
| Storage | `storageConfig.containers` | Adiciona `ehcapture` automaticamente |
| Key Vault | `keyVaultName` | Override do nome (opcional) |

### Terraform (`variables.tf`)
| Var | Descrição |
|-----|-----------|
| `postgres_version` | Versão PostgreSQL (11–16 aceit.) |
| `eventhub_consumer_groups` | Lista consumer groups |
| `eventhub_capture_*` | Configuração Capture |
| `enable_key_vault` | Ativa módulo Key Vault |
| `key_vault_name` | Nome customizado |

## Exemplos de Ajuste Rápido
Adicionar um novo consumer group para replay avançado:
```powershell
# Terraform
eventhub_consumer_groups = ["raw-loader","analytics","replay","risk-engine"]

# Bicep (main.bicepparam)
param eventHubConfig = {
	// ...
	consumerGroups: ['raw-loader','analytics','replay','risk-engine']
}
```

Alterar intervalo de Capture para 1 minuto:
```powershell
# Terraform
eventhub_capture_interval_seconds = 60

# Bicep
param eventHubConfig = {
	// ...
	captureIntervalInSeconds: 60
}
```

## Boas Práticas
* Use Key Vault em ambientes não locais; `.env` apenas para desenvolvimento.
* Habilite ROTINA de rotação de segredos (novo upload mantém versão anterior recuperável).
* Ajuste partições do Event Hub **antes** de alta carga (reduzir exige recriação).
* Limpe ou compacte dados de Capture após janelas de retenção definidas (custo!).
* Defina naming overrides para consistência multi-ambiente.

## Próximos Passos (Sugeridos)
| Item | Benefício |
|------|-----------|
| Private Endpoints (KV, EH, Storage) | Segurança de rede |
| RBAC-only Key Vault (migrar Bicep) | Gestão simplificada de acesso |
| Pipelines CI/CD (lint + validate) | Qualidade / governança |
| Data Quality layer | Confiança nos dados |
| Reprocessamento automatizado via Capture | Resiliência de ingestão |

---
Para dúvidas adicionais consulte o README principal ou abra uma Issue.
```
