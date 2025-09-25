SELECT 
    a.codigo_agencia,
    a.nome as nome_agencia,
    a.cidade,
    a.estado,
    COUNT(t.id_transacao) as total_transacoes,
    SUM(t.valor) as valor_total_movimentado,
    AVG(t.valor) as valor_medio_transacao,
    COUNT(DISTINCT c.id_conta) as contas_ativas,
    COUNT(DISTINCT cl.id_cliente) as clientes_unicos
FROM [mirror_mkl_bank].[core_bank].[agencias] a
LEFT JOIN [mirror_mkl_bank].[core_bank].[contas] c ON a.codigo_agencia = c.codigo_agencia
LEFT JOIN [mirror_mkl_bank].[core_bank].[clientes] cl ON c.id_cliente = cl.id_cliente
LEFT JOIN [mirror_mkl_bank].[core_bank].[transacoes] t ON c.id_conta = t.id_conta
GROUP BY a.codigo_agencia, a.nome, a.cidade, a.estado
HAVING COUNT(t.id_transacao) > 0
ORDER BY valor_total_movimentado DESC
LIMIT 15;