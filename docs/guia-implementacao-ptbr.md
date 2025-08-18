# Guia de Configuração: Governança de Dados com Purview, Fabric e Databricks

## 📋 Visão Geral

Este documento fornece instruções completas para configurar e implantar uma plataforma de Governança de Dados no Azure usando Bicep Infrastructure as Code (IaC). A solução inclui Azure Storage, Databricks, Microsoft Fabric, PostgreSQL e Event Hub para processamento de dados em tempo real.

## 🎯 Recursos Implantados

- **Azure Storage Account**: Para Data Lake (camadas bronze, silver, gold)
- **Azure Databricks**: Para análise e processamento de dados
- **Microsoft Fabric**: Para business intelligence
- **PostgreSQL Flexible Server**: Para metadados
- **Azure Event Hub**: Para streaming de dados em tempo real
- **User-Assigned Managed Identity**: Para acesso seguro aos recursos

## 🛠️ Pré-requisitos

Antes de começar, certifique-se de ter instalado:

1. **Azure CLI** (az)
   ```bash
   az --version
   ```

2. **Azure Developer CLI** (azd)
   ```bash
   azd version
   ```

3. **Git** para controle de versão

## 📁 Estrutura do Projeto

```
Data-Governance-with-Purview-Fabric-and-Databricks/
├── azure.yaml                           # Configuração do AZD
├── infra/                               # Infraestrutura como Código
│   ├── main.bicep                       # Template principal (estrutura plana)
│   └── bicep/                           # Template modular estruturado
│       ├── main.bicep                   # Template principal com tipos
│       ├── main.bicepparam              # Parâmetros tipados
│       ├── main.parameters.json         # Parâmetros para AZD
│       ├── types/
│       │   └── common.bicep             # Definições de tipos
│       └── modules/                     # Módulos de recursos
│           ├── storage.bicep            # Storage Account
│           ├── databricks.bicep         # Databricks Workspace
│           ├── fabric.bicep             # Microsoft Fabric
│           ├── postgres.bicep           # PostgreSQL
│           ├── eventhub.bicep           # Event Hub
│           └── identity.bicep           # Managed Identity
├── docs/
│   └── deployment-guide.md
└── app/                                 # Aplicações (futuro)
```

## 🔧 Passos de Implementação Realizados

### 1. Correção de Erros Iniciais no Bicep

**Problema**: Template tinha erros de sintaxe e validação.

**Solução**:
- Corrigido indentação de parâmetros nos módulos
- Atualizado versões de API para recursos Azure
- Implementado convenções de nomenclatura compatíveis
- Adicionado validações de parâmetros

### 2. Implementação de Convenções de Nomenclatura

**Problema**: Nomes de recursos violavam regras do Azure (especialmente Storage Account).

**Solução**:
- Adicionado validação `@maxLength(24)` para Storage Account
- Implementado lógica de limpeza de caracteres inválidos
- Criado função de geração de nomes compatíveis com Azure

```bicep
// Exemplo de validação implementada
@description('Storage account name (must be globally unique)')
@maxLength(24)
param storageAccountName string = ''

// Lógica de limpeza de nomes
var cleanNamePrefix = replace(replace(namePrefix, '_', ''), ' ', '')
var storageAccountName = !empty(storageAccountNameOverride) ? storageAccountNameOverride : 'st${cleanNamePrefix}'
```

### 3. Correção do Formato do Resource Token

**Problema**: Azure Developer CLI exigia formato específico de resource token.

**Solução**:
- Atualizado de `uniqueString(subscription().id, name, location)`
- Para `uniqueString(subscription().id, location, environmentName)`
- Adicionado parâmetro `environmentName` ao template

### 4. Adição de Outputs Obrigatórios

**Problema**: Template não tinha output `RESOURCE_GROUP_ID` exigido pelo AZD.

**Solução**:
```bicep
// Output obrigatório adicionado
output RESOURCE_GROUP_ID string = rg.id

// Outputs estruturados para cada recurso
output resourceGroup object = {
  id: rg.id
  name: rg.name
  location: rg.location
}
```

### 5. Implementação de User-Assigned Managed Identity

**Problema**: Template não tinha identidade gerenciada para acesso seguro.

**Solução**:
- Criado módulo `identity.bicep`
- Adicionado ao template principal
- Configurado outputs para integração com outros recursos

### 6. Adição do Azure Event Hub

**Problema**: Plataforma precisava de capacidade de streaming em tempo real.

**Solução**:
- Criado módulo `eventhub.bicep` completo
- Implementado namespace e tópico configuráveis
- Adicionado suporte a Kafka
- Configurado TLS 1.2 mínimo para segurança

**Recursos do Event Hub**:
```bicep
// Configuração do Event Hub
param eventHubConfig types.eventHubConfigType = {
  skuName: 'Standard'
  capacity: 1
  topicName: 'data-governance-events'
  partitionCount: 2
  messageRetentionInDays: 1
}
```

### 7. Configuração do Azure Developer CLI

**Problema**: Parâmetros de deployment não estavam configurados.

**Solução**:
- Criado arquivo `azure.yaml` para configuração AZD
- Configurado ambiente com variáveis obrigatórias
- Definido credenciais PostgreSQL seguras

## 🚀 Passos para Deployment

### 1. Preparação do Ambiente

```bash
# Navegar para o diretório do projeto
cd "c:\Users\diogomiyake\projects\customers\Data-Governance-with-Purview-Fabric-and-Databricks"

# Verificar ferramentas instaladas
az --version
azd version
```

### 2. Inicialização do Ambiente AZD

```bash
# Criar novo ambiente AZD
azd env new
# Nome sugerido: workshop_datagovernance_[seunome]

# Configurar variáveis de ambiente obrigatórias
azd env set POSTGRES_ADMIN_USER pgadmin
azd env set POSTGRES_ADMIN_PASSWORD "DataGov2024!"

# Verificar configuração
azd env get-values
```

### 3. Validação e Preview

```bash
# Validar template antes do deployment
azd provision --preview

# Verificar recursos que serão criados:
# - Resource Group
# - Storage Account (Data Lake)
# - Databricks Workspace
# - Microsoft Fabric Capacity
# - PostgreSQL Flexible Server
# - Event Hub Namespace + Topic
# - User-Assigned Managed Identity
```

### 4. Deployment da Infraestrutura

```bash
# Executar deployment completo
azd provision

# Ou deployment completo com aplicação (se disponível)
azd up
```

## 📊 Configurações Implementadas

### Storage Account
- **SKU**: Standard_LRS
- **Containers**: staging, bronze, silver, gold
- **Nomenclatura**: Compatível com limitações Azure (24 caracteres)

### Databricks Workspace
- **SKU**: Standard/Premium
- **No Public IP**: Configurável
- **Managed Resource Group**: Customizável

### Microsoft Fabric
- **SKU**: F2 (configurável: F2, F4, F8, F16, F32, F64, F128)
- **Admin Users**: Lista configurável de usuários AAD

**⚠️ Importante para Admin Users**:
- Use apenas usuários **válidos** do Azure AD
- Formato correto: `usuario@dominio.com` ou `usuario_dominio.com#EXT#@tenant.onmicrosoft.com`
- Verificar existência antes do deployment:
```bash
az ad user show --id "usuario@dominio.com"
```

### PostgreSQL Flexible Server
- **Versão**: 16 (configurável: 13, 14, 15, 16)
- **Storage**: 64GB
- **SKU**: Standard_D2s_v3
- **Backup**: Geo-redundante desabilitado

### Event Hub
- **Namespace SKU**: Standard
- **Tópico**: data-governance-events
- **Partições**: 2
- **Retenção**: 1-7 dias (configurável)
- **Kafka**: Habilitado
- **TLS**: Mínimo 1.2

## 🔒 Considerações de Segurança

### Managed Identity
- User-assigned identity para acesso inter-recursos
- Elimina necessidade de chaves hardcoded
- Princípio de menor privilégio implementado

### Credenciais
- Senhas via variáveis de ambiente AZD
- Connection strings não expostas em outputs
- TLS 1.2 mínimo em todos os serviços

### Network Security
- Public network access configurável
- Zone redundancy disponível
- Private endpoints ready (configurável)

## 🛠️ Personalização

### Modificar Configurações

Edite o arquivo `infra/bicep/main.bicepparam` para personalizar:

```bicep
// Exemplo de customização
param fabricConfig = {
  skuName: 'F4'  // Aumentar capacidade
  adminUsers: ['seu.email@empresa.com']  // ⚠️ APENAS usuários válidos do Azure AD
}

param eventHubConfig = {
  skuName: 'Premium'  // Upgrade para Premium
  topicName: 'custom-events'
  partitionCount: 4
  messageRetentionInDays: 7
}
```

**🔍 Validação de Usuários do Fabric**:
Antes de fazer deployment, sempre validar se os usuários existem:
```bash
# Validar usuário individual
az ad user show --id "admin@MngEnvMCAP922076.onmicrosoft.com"

# Listar usuários disponíveis no tenant
az ad user list --query "[].{Name:displayName,UPN:userPrincipalName,ObjectId:id}" --output table

# Buscar usuário por nome
az ad user list --filter "startswith(displayName,'Admin')" --query "[].{Name:displayName,UPN:userPrincipalName}" --output table
```

### Adicionar Novos Recursos

1. Criar novo módulo em `infra/bicep/modules/`
2. Adicionar tipo em `infra/bicep/types/common.bicep`
3. Integrar no `main.bicep`
4. Atualizar parâmetros

## 📋 Validação Pós-Deployment

### Verificar Recursos Criados

```bash
# Listar recursos do grupo
az resource list --resource-group rg-[ambiente] --output table

# Verificar logs de deployment
azd monitor
```

### Testar Conectividade

1. **Storage Account**: Verificar containers criados
2. **Databricks**: Acessar workspace via portal
3. **Fabric**: Verificar capacity no portal
4. **PostgreSQL**: Testar conexão
5. **Event Hub**: Verificar namespace e tópico

## 🐛 Troubleshooting

### Erros Comuns

1. **"InvalidTemplate" - parâmetro não fornecido**
   - Verificar variáveis de ambiente AZD: `azd env get-values`
   - Configurar credenciais faltantes

2. **"Invalid principal name" no Microsoft Fabric**
   - **Causa**: Usuário inválido na lista `adminUsers` do Fabric
   - **Solução**: Verificar usuários existem no Azure AD
   ```bash
   # Verificar usuário específico
   az ad user show --id "usuario@dominio.com"
   
   # Listar todos os usuários do tenant
   az ad user list --query "[].{Name:displayName,UPN:userPrincipalName}" --output table
   ```
   - **Correção**: Remover usuários fictícios do arquivo `main.bicepparam`

3. **Nome de Storage Account inválido**
   - Verificar se nome tem menos de 24 caracteres
   - Verificar disponibilidade global do nome

4. **Quota insuficiente**
   - Verificar quotas da região: `az vm list-usage --location centralus`
   - Solicitar aumento de quota se necessário

### Comandos Úteis

```bash
# Reset do ambiente
azd env select
azd down  # Remove todos os recursos

# Debug de template
az deployment group validate --resource-group [RG] --template-file main.bicep --parameters @main.parameters.json

# Monitoramento
azd monitor
az monitor activity-log list --resource-group [RG]
```

## 📞 Próximos Passos

1. **Configurar CI/CD**: Implementar GitHub Actions
2. **Data Pipeline**: Criar pipelines Databricks
3. **Monitoring**: Configurar Application Insights
4. **Security**: Implementar Private Endpoints
5. **Backup**: Configurar estratégias de backup

## 📚 Recursos Adicionais

- [Azure Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Developer CLI](https://docs.microsoft.com/azure/developer/azure-developer-cli/)
- [Microsoft Fabric Documentation](https://docs.microsoft.com/fabric/)
- [Azure Databricks Best Practices](https://docs.microsoft.com/azure/databricks/)

---

**Documento criado em**: Agosto 2025  
**Versão**: 1.0  
**Status**: Infraestrutura validada e pronta para deployment  
**Autor**: Assistente IA - GitHub Copilot
