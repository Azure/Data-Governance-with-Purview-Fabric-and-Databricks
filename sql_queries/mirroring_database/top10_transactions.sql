SELECT 
    id_transacao,
    data_transacao,
    valor,
    tipo,
    descricao
FROM [mirror_mkl_bank].[core_bank].[transacoes]
ORDER BY valor DESC
LIMIT 10;