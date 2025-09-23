# 📖 Catálogo de Produtos de Dados MKL Bank

## 🏦 Domínio: Financeiro

### 🔹 Produto 1 – **Visão 360º da Conta**

* **Fontes:** `contas`, `transacoes`, movimentações, `agencias`.
* **OKR:** Garantir visão consolidada do cliente e sua movimentação.
* **KPIs:**

  * % de cobertura de clientes com dados completos
  * Evolução do saldo médio por cliente
* **CDEs:** `id_conta`, `id_cliente`, `saldo`, `data_abertura`.

### 🔹 Produto 2 – **Receita & Custos de Transações**

* **Fontes:** `transacoes`, movimentações, tabelas de tarifas.
* **OKR:** Aumentar a margem líquida por canal de pagamento.
* **KPIs:**

  * Receita líquida por canal
  * Margem % consolidada
* **CDEs:** `id_transacao`, `valor`, `tipo_transacao`, `tarifa`.

### 🔹 Produto 3 – **Previsão de Fluxo de Caixa**

* **Fontes:** histórico de `transacoes` + saldos.
* **OKR:** Antecipar risco de liquidez e prever saldo projetado.
* **KPIs:**

  * Acurácia da previsão (MAPE)
  * % de contas em risco de saldo negativo
* **CDEs:** `data_transacao`, `valor`, `saldo`.

---

## 📊 Domínio: Comercial & Estratégia

### 🔹 Produto 4 – **Painel de Movimentações por Canal**

* **Fontes:** movimentações (Pix, Boleto, Cartão, Transferências, Depósitos).
* **OKR:** Entender adoção e comportamento dos clientes em canais.
* **KPIs:**

  * Volume total por canal (R\$ e nº)
  * Crescimento mensal por canal (%)
* **CDEs:** `valor`, `data_movimento`, `operacao`, `id_movimento`.

### 🔹 Produto 5 – **Jornada de Pagamentos do Cliente**

* **Fontes:** `transacoes`, movimentações, `contas`.
* **OKR:** Mapear jornada de pagamentos e preferências por canal.
* **KPIs:**

  * Ticket médio por cliente e canal
  * % de clientes ativos por tipo de movimentação
* **CDEs:** `id_cliente`, `id_conta`, `tipo_transacao`.

---

## 🛡️ Domínio: Risco & Compliance

### 🔹 Produto 6 – **Monitoramento de Risco e Compliance**

* **Fontes:** `transacoes`, movimentações, `contas`, `agencias`.
* **OKR:** Garantir conformidade regulatória e reduzir exposição a fraudes.
* **KPIs:**

  * Nº de transações suspeitas identificadas
  * % de casos reportados ao Bacen em até 24h
* **CDEs:** `id_transacao`, `valor`, `id_cliente`, `numero_conta`.

---

## ⚙️ Domínio: Operações & TI

### 🔹 Produto 7 – **Indicadores de Performance Operacional**

* **Fontes:** `transacoes`, movimentações, `agencias`.
* **OKR:** Melhorar eficiência operacional e reduzir falhas.
* **KPIs:**

  * Tempo médio de liquidação (SLA)
  * Taxa de falhas ou estornos (%)
* **CDEs:** `data_movimento`, `status`, `operacao`, `id_transacao`.

---

## 🌍 Domínio: Rede de Agências

### 🔹 Produto 8 – **Performance de Agências**

* **Fontes:** `agencias`, `contas`, `transacoes`.
* **OKR:** Monitorar performance financeira e operacional por agência.
* **KPIs:**

  * Volume de transações por agência
  * Receita líquida por agência
  * Nº de clientes ativos por agência
* **CDEs:** `codigo_agencia`, `numero_conta`, `id_cliente`, `valor`.

---

📌 **Resumo dos CDEs (mais críticos a governar)**

* **Identificadores:** `id_transacao`, `id_conta`, `id_cliente`, `codigo_agencia`
* **Financeiros:** `valor`, `saldo`
* **Temporais:** `data_transacao`, `data_movimento`
* **Operacionais:** `status`, `tipo_transacao`, `operacao`

---
