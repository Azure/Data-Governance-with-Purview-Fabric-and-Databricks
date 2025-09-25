SELECT 
    tipo_chave,
    COUNT(*) as total_chaves,
    COUNT(CASE WHEN status = 'A' THEN 1 END) as chaves_ativas,
    COUNT(CASE WHEN status = 'I' THEN 1 END) as chaves_inativas,
    ROUND(
        (COUNT(CASE WHEN status = 'A' THEN 1 END) * 100.0 / COUNT(*)), 2
    ) as percentual_ativas
FROM [mirror_mkl_bank].[core_bank].[chaves_pix]
GROUP BY tipo_chave
ORDER BY total_chaves DESC;