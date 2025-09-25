WITH clientes_cohort AS (
    SELECT 
        cl.id_cliente,
        cl.nome as nome_cliente,
        c.data_abertura,
        DATE_TRUNC('month', c.data_abertura) as cohort_mes,
        EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM cl.data_nascimento) as idade,
        a.estado,
        a.cidade
    FROM [mirror_mkl_bank].[core_bank].[cliente] cl
    JOIN [mirror_mkl_bank].[core_bank].[conta] c ON cl.id_cliente = c.id_cliente
    JOIN [mirror_mkl_bank].[core_bank].[agencia] a ON c.codigo_agencia = a.codigo_agencia
    WHERE c.data_abertura >= '2023-01-01'
),
atividade_cliente AS (
    SELECT 
        cc.id_cliente,
        cc.cohort_mes,
        cc.idade,
        cc.estado,
        DATE_TRUNC('month', t.data_transacao) as mes_atividade,
        COUNT(t.id_transacao) as transacoes_mes,
        SUM(t.valor) as valor_mes,
        AVG(t.valor) as ticket_medio_mes,
        -- Número de meses desde a abertura da conta (movido para cá)
        EXTRACT(EPOCH FROM (DATE_TRUNC('month', t.data_transacao) - cc.cohort_mes)) / (30.44 * 24 * 3600) as meses_desde_abertura
    FROM clientes_cohort cc
    JOIN [mirror_mkl_bank].[core_bank].[conta] c ON cc.id_cliente = c.id_cliente
    LEFT JOIN [mirror_mkl_bank].[core_bank].[transacao_conta] t ON c.id_conta = t.id_conta
    WHERE t.data_transacao >= cc.data_abertura
    GROUP BY cc.id_cliente, cc.cohort_mes, cc.idade, cc.estado, 
             DATE_TRUNC('month', t.data_transacao)
),
analise_temporal AS (
    SELECT *,
        -- Ranking de atividade dentro do cohort (agora meses_desde_abertura existe)
        RANK() OVER (
            PARTITION BY cohort_mes, ROUND(meses_desde_abertura::numeric, 0)
            ORDER BY transacoes_mes DESC
        ) as ranking_atividade_cohort,
        
        -- Percentil de valor dentro do cohort
        PERCENT_RANK() OVER (
            PARTITION BY cohort_mes, ROUND(meses_desde_abertura::numeric, 0)
            ORDER BY valor_mes
        ) as percentil_valor_cohort,
        
        -- Valor cumulativo
        SUM(valor_mes) OVER (
            PARTITION BY id_cliente 
            ORDER BY mes_atividade 
            ROWS UNBOUNDED PRECEDING
        ) as valor_cumulativo,
        
        -- Média móvel de atividade (3 meses)
        AVG(transacoes_mes) OVER (
            PARTITION BY id_cliente 
            ORDER BY mes_atividade 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) as media_movel_atividade
        
    FROM atividade_cliente
    WHERE mes_atividade IS NOT NULL
),
segmentacao_final AS (
    SELECT *,
        CASE 
            WHEN percentil_valor_cohort >= 0.8 THEN 'High Value'
            WHEN percentil_valor_cohort >= 0.6 THEN 'Medium High'
            WHEN percentil_valor_cohort >= 0.4 THEN 'Medium'
            WHEN percentil_valor_cohort >= 0.2 THEN 'Medium Low'
            ELSE 'Low Value'
        END as segmento_valor,
        
        CASE 
            WHEN idade < 25 THEN 'Gen Z'
            WHEN idade < 40 THEN 'Millennial'
            WHEN idade < 55 THEN 'Gen X'
            ELSE 'Boomer'
        END as geracao,
        
        CASE 
            WHEN meses_desde_abertura <= 3 THEN 'Novo (0-3m)'
            WHEN meses_desde_abertura <= 6 THEN 'Recente (3-6m)'
            WHEN meses_desde_abertura <= 12 THEN 'Estabelecido (6-12m)'
            ELSE 'Maduro (12m+)'
        END as estagio_cliente
        
    FROM analise_temporal
)
SELECT 
    cohort_mes,
    estagio_cliente,
    segmento_valor,
    geracao,
    estado,
    COUNT(DISTINCT id_cliente) as clientes_unicos,
    AVG(transacoes_mes) as media_transacoes,
    AVG(valor_mes) as media_valor_mes,
    AVG(valor_cumulativo) as media_valor_cumulativo,
    AVG(ticket_medio_mes) as ticket_medio,
    STDDEV(transacoes_mes) as volatilidade_atividade
FROM segmentacao_final
GROUP BY cohort_mes, estagio_cliente, segmento_valor, geracao, estado
HAVING COUNT(DISTINCT id_cliente) >= 3
ORDER BY cohort_mes DESC, clientes_unicos DESC
LIMIT 40;