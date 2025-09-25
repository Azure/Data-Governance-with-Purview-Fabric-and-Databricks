WITH movimentacao_mensal AS (
    SELECT 
        a.codigo_agencia,
        a.nome as nome_agencia,
        a.cidade,
        a.estado,
        DATE_TRUNC('month', t.data_transacao) as mes_ano,
        COUNT(t.id_transacao) as total_transacoes,
        SUM(t.valor) as valor_total,
        AVG(t.valor) as valor_medio
    FROM [mirror_mkl_bank].[core_bank].[agencias] a
    JOIN [mirror_mkl_bank].[core_bank].[contas] c ON a.codigo_agencia = c.codigo_agencia
    JOIN [mirror_mkl_bank].[core_bank].[transacoes] t ON c.id_conta = t.id_conta
    WHERE t.data_transacao >= '2024-01-01'
    GROUP BY a.codigo_agencia, a.nome, a.cidade, a.estado, 
             DATE_TRUNC('month', t.data_transacao)
),
ranking_performance AS (
    SELECT *,
        -- Rankings mensais
        RANK() OVER (PARTITION BY mes_ano ORDER BY valor_total DESC) as ranking_valor_mes,
        RANK() OVER (PARTITION BY mes_ano ORDER BY total_transacoes DESC) as ranking_transacoes_mes,
        
        -- Análise temporal com LAG
        LAG(valor_total, 1) OVER (PARTITION BY codigo_agencia ORDER BY mes_ano) as valor_mes_anterior,
        LAG(total_transacoes, 1) OVER (PARTITION BY codigo_agencia ORDER BY mes_ano) as transacoes_mes_anterior,
        
        -- Médias móveis (3 meses)
        AVG(valor_total) OVER (
            PARTITION BY codigo_agencia 
            ORDER BY mes_ano 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) as media_movel_3m_valor,
        
        AVG(total_transacoes) OVER (
            PARTITION BY codigo_agencia 
            ORDER BY mes_ano 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) as media_movel_3m_transacoes,
        
        -- Percentil por estado
        PERCENT_RANK() OVER (PARTITION BY estado, mes_ano ORDER BY valor_total) as percentil_estado
        
    FROM movimentacao_mensal
),
crescimento_calculado AS (
    SELECT *,
        CASE 
            WHEN valor_mes_anterior > 0 THEN 
                ((valor_total - valor_mes_anterior) / valor_mes_anterior::float) * 100
            ELSE NULL 
        END as crescimento_valor_pct,
        
        CASE 
            WHEN transacoes_mes_anterior > 0 THEN 
                ((total_transacoes - transacoes_mes_anterior) / transacoes_mes_anterior::float) * 100
            ELSE NULL 
        END as crescimento_transacoes_pct
        
    FROM ranking_performance
)
SELECT 
    codigo_agencia,
    nome_agencia,
    cidade,
    estado,
    mes_ano,
    total_transacoes,
    valor_total,
    ranking_valor_mes,
    ranking_transacoes_mes,
    crescimento_valor_pct,
    crescimento_transacoes_pct,
    media_movel_3m_valor,
    percentil_estado,
    CASE 
        WHEN percentil_estado >= 0.8 THEN 'Top 20%'
        WHEN percentil_estado >= 0.6 THEN 'Acima da Média'
        WHEN percentil_estado >= 0.4 THEN 'Média'
        WHEN percentil_estado >= 0.2 THEN 'Abaixo da Média'
        ELSE 'Bottom 20%'
    END as classificacao_estado
FROM crescimento_calculado
WHERE mes_ano >= '2024-01-01'
ORDER BY mes_ano DESC, ranking_valor_mes
LIMIT 50;