SELECT 
    DATE_TRUNC('month', data_transacao) as mes,
    COUNT(*) as total_transacoes,
    SUM(valor) as valor_total,
    AVG(valor) as valor_medio
FROM [mirror_mkl_bank].[core_bank].[transacoes]
GROUP BY DATE_TRUNC('month', data_transacao)
ORDER BY mes;