# 🚀 Plataforma de Governança de Dados - Azure

[![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com)
[![Bicep](https://img.shields.io/badge/Bicep-1BA1E2?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
[![Status](https://img.shields.io/badge/Status-Pronto%20para%20Deploy-success?style=for-the-badge)]()

## Use o repositório para 
- Fazer provas de conceito
- Aprendizado
- Referência

## NÃO USE PARA PRODUÇÃO!!
O projeto não possui todos os guardrails e necessidades para ser pronto para produção.
 

## 📊 Sobre o Projeto

Esta é uma plataforma de **Governança de Dados** implementada no Azure usando **Infrastructure as Code (Bicep)**. A solução combina armazenamento de dados, análise, business intelligence e streaming em tempo real.
A solução é voltada para o setor de finanças **(FSI)**.

### Objetivos do projeto

O objetivo do projeto é mostrar e ensinar como o Purview pode gerenciar a Governança de Dados. 
Para este projeto o Purview irá gerenciar os recursos que se encontram dentro do Databricks, Fabric, e da Azure. 

### 🎯 Arquitetura



## 🛠️ Tecnologias Utilizadas

| Serviço | Propósito | SKU/Configuração |
|---------|-----------|------------------|
| **Azure Storage** | Data Lake (Bronze/Silver/Gold) | Standard_LRS |
| **Azure Databricks** | Analytics & ML | Standard/Premium |
| **Microsoft Fabric** | Business Intelligence | F2-F128 |
| **PostgreSQL** | Metadata Store | Flexible Server |
| **Event Hub** | Real-time Streaming | Standard/Premium |
| **Managed Identity** | Secure Authentication | User-assigned |

## 🚀 Quick Start

### 1. Pré-requisitos

- Ter uma conta da Azure, você pode se inscrever gratuitamente [aqui](https://azure.microsoft.com/free/). (Em caso de uso pessoal)
- Ter uma conta de testes do Purview
- Ter acesso admin ou os privilegios minimos para poder criar os recursos. 
- Opcional: Ter os plugins do [bicep para o VsCode](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep).
- Instalar o [Az Cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) e o [Az Developer Cli](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd?tabs=winget-windows%2Cbrew-mac%2Cscript-linux&pivots=os-windows).
- Instalar o [UV package manager](https://docs.astral.sh/uv/getting-started/installation/).


```bash
# Verificar ferramentas instaladas
az --version        # Azure CLI
azd version         # Azure Developer CLI
```

### 2. Configuração
```bash
# Fazer um fork Clonar e navegar
# Faça um fork deste repositorio após isso pegue a sua URL e clone.
git clone <repo-url>
cd Data-Governance-with-Purview-Fabric-and-Databricks

# Configurar ambiente
azd env new
azd env set POSTGRES_ADMIN_USER pgadmin
azd env set POSTGRES_ADMIN_PASSWORD "DataGov2024!"
```

### 3. Deploy
```bash
# Preview (opcional)
azd provision --preview

# Deploy completo
azd provision
```

## 📁 Estrutura do Repositório

```
📦 Data-Governance-with-Purview-Fabric-and-Databricks
 ┣ 📂 infra/                    # Infrastructure as Code
 ┃ ┣ 📂 bicep/                  # Templates Bicep modulares
 ┃ ┃ ┣ 📂 modules/              # Módulos de recursos
 ┃ ┃ ┃ ┣ 📜 storage.bicep       # Azure Storage
 ┃ ┃ ┃ ┣ 📜 databricks.bicep    # Databricks Workspace
 ┃ ┃ ┃ ┣ 📜 fabric.bicep        # Microsoft Fabric
 ┃ ┃ ┃ ┣ 📜 postgres.bicep      # PostgreSQL Server
 ┃ ┃ ┃ ┣ 📜 eventhub.bicep      # Event Hub
 ┃ ┃ ┃ ┗ 📜 identity.bicep      # Managed Identity
 ┃ ┃ ┣ 📂 types/
 ┃ ┃ ┃ ┗ 📜 common.bicep        # Definições de tipos
 ┃ ┃ ┣ 📜 main.bicep            # Template principal
 ┃ ┃ ┣ 📜 main.bicepparam       # Parâmetros tipados
 ┃ ┃ ┗ 📜 main.parameters.json  # Parâmetros AZD
 ┃ ┗ 📜 main.bicep              # Template raiz alternativo
 ┣ 📂 docs/                     # Documentação
 ┃ ┣ 📜 guia-implementacao-ptbr.md # Guia completo (PT-BR)
 ┃ ┗ 📜 deployment-guide.md     # Guia de deployment (EN)
 ┣ 📂 app/                      # Aplicações (futuro)
 ┣ 📜 azure.yaml                # Configuração AZD
 ┗ 📜 README-PTBR.md            # Este arquivo
```

## ⚙️ Configurações Personalizáveis

### 🏗️ Infraestrutura

Edite `infra/bicep/main.bicepparam` para personalizar:

```bicep
// Microsoft Fabric
param fabricConfig = {
  skuName: 'F4'                    // F2, F4, F8, F16, F32, F64, F128
  adminUsers: ['admin@empresa.com'] // Lista de administradores
}

// Event Hub
param eventHubConfig = {
  skuName: 'Premium'                    // Basic, Standard, Premium
  topicName: 'meus-eventos'             // Nome do tópico
  partitionCount: 4                     // Número de partições
  messageRetentionInDays: 7             // Retenção de mensagens
}

// Storage
param storageConfig = {
  skuName: 'Standard_GRS'               // Replicação geo-redundante
  containers: ['bronze', 'silver', 'gold', 'raw'] // Containers customizados
}
```

### 🔧 Ambiente

```bash
# Configurações de ambiente
azd env set POSTGRES_ADMIN_USER "meuadmin"
azd env set POSTGRES_ADMIN_PASSWORD "MinhaSenh@123"

# Verificar configurações
azd env get-values
```

## 📈 Casos de Uso

### 🎯 Data Lake Analytics
- **Ingestão**: Event Hub → Storage (Bronze)
- **Transformação**: Databricks (Bronze → Silver → Gold)
- **Visualização**: Microsoft Fabric dashboards

### 🔄 Real-time Processing
- **Streaming**: Event Hub com Kafka
- **Processing**: Databricks Structured Streaming
- **Storage**: Delta Lake format

### 📊 Business Intelligence
- **Data Source**: Storage Account (Gold layer)
- **Analytics**: Microsoft Fabric
- **Reports**: Power BI integration

## 🔒 Segurança

### 🛡️ Implementado
- ✅ **Managed Identity** para autenticação
- ✅ **TLS 1.2** mínimo em todos os serviços
- ✅ **Resource-level RBAC**
- ✅ **Secure parameter handling**

### 🔮 Roadmap Segurança
- 🔄 **Private Endpoints**
- 🔄 **VNet Integration**
- ✅ **Key Vault integration** (armazenar segredos em vez de .env em produção)
- 🔄 **Data encryption at rest**

## 🔐 Gerenciamento de Segredos (Key Vault + .env)

Para desenvolvimento local você pode continuar usando `.env` / variáveis AZD. Para ambientes compartilhados ou produção use **Azure Key Vault**.

### Segredos Criados Automaticamente

Ao fazer o deploy a infra cria (Bicep / Terraform):
- `postgres-admin-password`
- (Opcional Terraform) `eventhub-connection-string` – criado se o módulo de Event Hub expõe a connection string (já habilitado no Terraform). No Bicep você pode criar depois manualmente.

### Criar/Atualizar Segredo Manualmente

```bash
# Login
az login

# Definir variáveis auxiliares
KV_NAME="<seu-keyvault>" \
PG_PASS="NovaSenh@2025" \
EH_NAMESPACE="<namespace-eventhub>" \
EH_RULE="RootManageSharedAccessKey"

# Postgres password
az keyvault secret set --vault-name $KV_NAME \
  --name postgres-admin-password --value "$PG_PASS"

# Event Hub connection string (Bicep) - se não criada automaticamente
CONN=$(az eventhubs namespace authorization-rule keys list \
  --resource-group <rg> \
  --namespace-name $EH_NAMESPACE \
  --name $EH_RULE \
  --query primaryConnectionString -o tsv)
az keyvault secret set --vault-name $KV_NAME \
  --name eventhub-connection-string --value "$CONN"
```

### Exemplo de Código (Python) – Fallback Key Vault -> .env

Adicione ao `pyproject.toml` (se ainda não):
```toml
[project.optional-dependencies]
secrets = ["azure-identity>=1.16.0","azure-keyvault-secrets>=4.8.0","python-dotenv>=1.0.0"]
```

Código de acesso:
```python
import os
from dotenv import load_dotenv
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

load_dotenv()  # carrega .env para fallback local

KV_URI = os.getenv("KEY_VAULT_URI")  # exporte após deploy (ex: azd env set KEY_VAULT_URI <uri>)

def get_secret(name: str) -> str:
    # 1) Tenta Key Vault se disponível
    if KV_URI:
        try:
            cred = DefaultAzureCredential(exclude_interactive_browser_credential=False)
            client = SecretClient(vault_url=KV_URI, credential=cred)
            return client.get_secret(name).value
        except Exception as ex:  # noqa
            print(f"[WARN] Falha ao obter '{name}' no Key Vault: {ex}; usando fallback .env")
    # 2) Fallback: variável de ambiente /.env
    val = os.getenv(name.upper().replace('-', '_'))
    if not val:
        raise RuntimeError(f"Secret '{name}' não encontrado em KV nem .env")
    return val

POSTGRES_PASSWORD = get_secret("postgres-admin-password")
EVENTHUB_CONN = get_secret("eventhub-connection-string")
```

### Boas Práticas
- Use **Key Vault** para produção; `.env` apenas local/dev.
- Nunca faça commit de senhas em parâmetros Bicep / tfvars públicos.
- Conceda acesso por Managed Identity (já criado) com permissões mínimas (Get, List).
- Rotacione senhas periodicamente (`az keyvault secret set` atualiza versão sem quebrar consumidores que pedem a versão mais recente).

### Exportar URI do Vault para Ambiente
```bash
azd env set KEY_VAULT_URI "https://<kv-name>.vault.azure.net/"
```

### Terraform vs Bicep – Diferenças
| Item | Bicep | Terraform |
|------|-------|-----------|
| Criação do Key Vault | Sempre implantado | Controlado via `enable_key_vault` | 
| Segredo Postgres | Sim | Sim |
| Segredo Event Hub | Manual pós-deploy | Automático (usa output da conexão) |
| RBAC vs Access Policy | Access Policy | RBAC (`enable_rbac_authorization`) |

Se quiser paridade total (segredo Event Hub no Bicep) é preciso replicar a lógica de nome do namespace ou executar uma segunda implantação após o namespace existir.

## ♻️ Migração de .env para Key Vault

| Antigo (.env) | Novo (Key Vault) | Observação |
|---------------|------------------|------------|
| PGPASSWORD / POSTGRES_ADMIN_PASSWORD | postgres-admin-password | Mantenha variável env como fallback |
| EVENTHUB_CONNECTION_STRING | eventhub-connection-string | Não armazene em Git |

No código, acesse sempre via função utilitária (exemplo acima) para abstrair a origem.

## 📋 Monitoramento

### 📊 Métricas Disponíveis
```bash
# Status da infraestrutura
azd monitor

# Logs de atividade
az monitor activity-log list --resource-group [RG]

# Métricas específicas
az monitor metrics list --resource [RESOURCE-ID]
```

### 🎯 KPIs Importantes
- **Event Hub**: Throughput, latência, erros
- **Databricks**: Job execution, cluster utilization
- **Storage**: Request rate, availability
- **PostgreSQL**: Connections, query performance

## 🐛 Troubleshooting

### ❌ Problemas Comuns

| Erro | Causa | Solução |
|------|-------|---------|
| `InvalidTemplate` | Parâmetro não fornecido | `azd env set PARAM value` |
| `Storage name invalid` | Nome muito longo | Verificar convenções |
| `Quota exceeded` | Limite da região | Solicitar aumento |
| `Permission denied` | RBAC insuficiente | Verificar roles |

### 🔧 Comandos Úteis

```bash
# Reset completo
azd down --force --purge

# Validação de template
az deployment group validate \
  --resource-group [RG] \
  --template-file main.bicep \
  --parameters @main.parameters.json

# Debug detalhado
azd provision --debug
```

## 🎯 Roadmap

### 🚧 Próximas Funcionalidades

- [ ] **Streaming de dados** (EventHub)
- [ ] **CI/CD Pipeline** (GitHub Actions)
- [ ] **Data Quality** monitoring
- [ ] **Automated testing** infrastructure
- [ ] **Cost optimization** insights
- [ ] **Multi-environment** support
- [ ] **Backup & Disaster Recovery**

### 📈 Melhorias Planejadas

- [ ] **Private networking** implementation
- [ ] **Advanced security** (Key Vault, encryption)
- [ ] **Observability** (Application Insights)
- [ ] **Auto-scaling** policies
- [ ] **Data cataloging** automation

## 🤝 Contribuindo

### 🛠️ Desenvolvimento

1. **Fork** o repositório
2. **Create** feature branch (`git checkout -b feature/nova-funcionalidade`)
3. **Commit** changes (`git commit -am 'Add nova funcionalidade'`)
4. **Push** to branch (`git push origin feature/nova-funcionalidade`)
5. **Create** Pull Request

### 📝 Documentação

Contribuições para documentação são muito bem-vindas! Especialmente:
- Tutoriais de uso
- Exemplos de código
- Troubleshooting guides
- Traduções

## 📞 Suporte

### 📚 Documentação
- [Guia Completo (PT-BR)](./docs/guia-implementacao-ptbr.md)
- [Deployment Guide (EN)](./docs/deployment-guide.md)
- [Azure Bicep Docs](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)

### 🆘 Problemas
- Abra uma [Issue](../../issues) para bugs
- Use [Discussions](../../discussions) para dúvidas
- Consulte [FAQ](./docs/guia-implementacao-ptbr.md#troubleshooting)

## 📄 Licença

Este projeto está licenciado sob a **MIT License** - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

<div align="center">

**🚀 Desenvolvido com ❤️ para a comunidade Azure**

[![Azure](https://img.shields.io/badge/Powered%20by-Azure-0078D4?style=flat&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com)
[![Bicep](https://img.shields.io/badge/Built%20with-Bicep-1BA1E2?style=flat&logo=microsoftazure&logoColor=white)](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)

</div>

