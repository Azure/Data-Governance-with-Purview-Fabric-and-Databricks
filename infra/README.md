# Infraestrutura de Governança de Dados

Este diretório contém templates de Infrastructure as Code (IaC) para implantar uma plataforma abrangente de Governança de Dados no Azure.

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

## Arquitetura

- **Microsoft Fabric**: Plataforma de análise de dados e business intelligence
- **Azure Databricks**: Plataforma de análise baseada em Apache Spark
- **Azure Database for PostgreSQL**: Serviço de banco de dados relacional
- **Azure Storage Account**: Armazenamento de objetos com contêineres de data lake

## Documentação

Consulte [deployment-guide.md](../docs/deployment-guide.md) para instruções abrangentes de implantação e opções de configuração.

Documentação adicional:
- [PostgreSQL Azure AD Administrators](../docs/postgres-azure-ad-admins.md) - Como configurar administradores Azure AD para PostgreSQL

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
```
