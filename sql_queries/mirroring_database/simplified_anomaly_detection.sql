WITH perfil_base_cliente AS (
    SELECT 
        cl.id_cliente,
        cl.nome as nome_cliente,
        cl.cpf,
        a.estado,
        c.id_conta,
        DATE_TRUNC('week', t.data_transacao) as semana,
        COUNT(t.id_transacao) as transacoes_semana,
        SUM(t.valor) as valor_semana,
        AVG(t.valor) as ticket_medio_semana,
        STDDEV(t.valor) as volatilidade_valores,
        MIN(t.valor) as valor_minimo,
        MAX(t.valor) as valor_maximo
    FROM [mirror_mkl_bank].[core_bank].[cliente] cl
    JOIN [mirror_mkl_bank].[core_bank].[conta] c ON cl.id_cliente = c.id_cliente
    JOIN [mirror_mkl_bank].[core_bank].[agencia] a ON c.codigo_agencia = a.codigo_agencia
    JOIN [mirror_mkl_bank].[core_bank].[transacao_conta] t ON c.id_conta = t.id_conta
    WHERE t.data_transacao >= '2024-01-01'
    GROUP BY cl.id_cliente, cl.nome, cl.cpf, a.estado, c.id_conta,
             DATE_TRUNC('week', t.data_transacao)
),
estatisticas_cliente AS (
    SELECT *,
        -- Estatísticas históricas do cliente
        AVG(transacoes_semana) OVER (
            PARTITION BY id_cliente 
            ORDER BY semana 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as media_historica_transacoes,
        
        STDDEV(transacoes_semana) OVER (
            PARTITION BY id_cliente 
            ORDER BY semana 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as stddev_historica_transacoes,
        
        AVG(valor_semana) OVER (
            PARTITION BY id_cliente 
            ORDER BY semana 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as media_historica_valor,
        
        STDDEV(valor_semana) OVER (
            PARTITION BY id_cliente 
            ORDER BY semana 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as stddev_historica_valor,
        
        -- Ranking de atividade no estado
        PERCENT_RANK() OVER (
            PARTITION BY estado, semana 
            ORDER BY valor_semana
        ) as percentil_estado_semana
        
    FROM perfil_base_cliente
),
deteccao_anomalias AS (
    SELECT *,
        -- Z-Score para transações
        CASE 
            WHEN stddev_historica_transacoes > 0 THEN 
                (transacoes_semana - media_historica_transacoes) / stddev_historica_transacoes
            ELSE 0 
        END as zscore_transacoes,
        
        -- Z-Score para valores
        CASE 
            WHEN stddev_historica_valor > 0 THEN 
                (valor_semana - media_historica_valor) / stddev_historica_valor
            ELSE 0 
        END as zscore_valor,
        
        -- Detecção simples de outliers baseada em desvio padrão
        CASE 
            WHEN ABS((valor_semana - media_historica_valor) / COALESCE(NULLIF(stddev_historica_valor, 0), 1)) > 2 THEN true
            ELSE false
        END as outlier_simples,
        
        -- Classificação de volatilidade
        CASE 
            WHEN volatilidade_valores > 100000 THEN 'Alta Volatilidade'
            WHEN volatilidade_valores > 50000 THEN 'Média Volatilidade'
            WHEN volatilidade_valores > 10000 THEN 'Baixa Volatilidade'
            ELSE 'Estável'
        END as classificacao_volatilidade
        
    FROM estatisticas_cliente
    WHERE media_historica_transacoes IS NOT NULL
),
analise_final AS (
    SELECT *,
        -- Classificação de anomalia simplificada
        CASE 
            WHEN ABS(zscore_valor) > 3 OR outlier_simples = true THEN 'Alto Risco'
            WHEN ABS(zscore_valor) > 2 OR percentil_estado_semana > 0.95 THEN 'Médio Risco'
            WHEN ABS(zscore_valor) > 1 OR percentil_estado_semana > 0.90 THEN 'Baixo Risco'
            ELSE 'Normal'
        END as nivel_anomalia,
        
        -- Score de risco simplificado
        (
            ABS(zscore_valor) * 0.5 +
            ABS(zscore_transacoes) * 0.3 +
            percentil_estado_semana * 0.2
        ) as score_risco
        
    FROM deteccao_anomalias
)
SELECT 
    id_cliente,
    nome_cliente,
    estado,
    semana,
    transacoes_semana,
    valor_semana,
    zscore_valor,
    zscore_transacoes,
    percentil_estado_semana,
    outlier_simples,
    nivel_anomalia,
    classificacao_volatilidade,
    score_risco,
    RANK() OVER (ORDER BY score_risco DESC) as ranking_risco
FROM analise_final
WHERE nivel_anomalia != 'Normal'
ORDER BY score_risco DESC, semana DESC
LIMIT 30;