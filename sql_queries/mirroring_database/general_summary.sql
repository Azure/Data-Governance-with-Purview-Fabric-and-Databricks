SELECT 
    'Agências' as tabela,
    COUNT(*) as total_registros
FROM [mirror_mkl_bank].[core_bank].agencias

UNION ALL

SELECT 
    'Clientes' as tabela,
    COUNT(*) as total_registros
FROM [mirror_mkl_bank].[core_bank].clientes

UNION ALL

SELECT 
    'Contas' as tabela,
    COUNT(*) as total_registros
FROM [mirror_mkl_bank].[core_bank].contas

UNION ALL

SELECT 
    'Cartões' as tabela,
    COUNT(*) as total_registros
FROM [mirror_mkl_bank].[core_bank].cartoes

UNION ALL

SELECT 
    'Chaves PIX' as tabela,
    COUNT(*) as total_registros
FROM [mirror_mkl_bank].[core_bank].chaves_pix

ORDER BY total_registros DESC;