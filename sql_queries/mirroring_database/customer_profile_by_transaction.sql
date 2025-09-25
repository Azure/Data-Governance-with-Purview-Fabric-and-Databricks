WITH cliente_perfil AS (
    SELECT 
        cl.id_cliente,
        cl.nome as nome_cliente,
        cl.cpf,
        EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM cl.data_nascimento) as idade,
        COUNT(DISTINCT c.id_conta) as total_contas,
        COUNT(DISTINCT cart.numero_cartao) as total_cartoes,
        COUNT(DISTINCT pix.id_chave_pix) as total_chaves_pix,
        COUNT(t.id_transacao) as total_transacoes,
        SUM(t.valor) as valor_total_movimentado,
        AVG(t.valor) as valor_medio_transacao
    FROM [mirror_mkl_bank].[core_bank].[clientes] cl
    LEFT JOIN [mirror_mkl_bank].[core_bank].[contas] c ON cl.id_cliente = c.id_cliente
    LEFT JOIN [mirror_mkl_bank].[core_bank].[cartoes] cart ON cl.id_cliente = cart.id_cliente
    LEFT JOIN [mirror_mkl_bank].[core_bank].[chaves_pix] pix ON c.id_conta = pix.id_conta
    LEFT JOIN [mirror_mkl_bank].[core_bank].[transacoes] t ON c.id_conta = t.id_conta
    GROUP BY cl.id_cliente, cl.nome, cl.cpf, cl.data_nascimento
),
segmentacao AS (
    SELECT *,
        CASE 
            WHEN valor_total_movimentado >= 500000 THEN 'Premium'
            WHEN valor_total_movimentado >= 100000 THEN 'Gold'
            WHEN valor_total_movimentado >= 50000 THEN 'Silver'
            ELSE 'Standard'
        END as segmento_cliente,
        CASE 
            WHEN idade < 25 THEN 'Jovem (< 25)'
            WHEN idade < 40 THEN 'Adulto (25-40)'
            WHEN idade < 60 THEN 'Maduro (40-60)'
            ELSE 'Senior (60+)'
        END as faixa_etaria
    FROM cliente_perfil
    WHERE total_transacoes > 0
)
SELECT 
    segmento_cliente,
    faixa_etaria,
    COUNT(*) as quantidade_clientes,
    AVG(total_transacoes) as media_transacoes,
    AVG(valor_total_movimentado) as media_movimentacao,
    AVG(total_cartoes) as media_cartoes,
    AVG(total_chaves_pix) as media_chaves_pix,
    SUM(valor_total_movimentado) as valor_total_segmento
FROM segmentacao
GROUP BY segmento_cliente, faixa_etaria
ORDER BY 
    CASE segmento_cliente 
        WHEN 'Premium' THEN 1 
        WHEN 'Gold' THEN 2 
        WHEN 'Silver' THEN 3 
        ELSE 4 
    END,
    faixa_etaria;