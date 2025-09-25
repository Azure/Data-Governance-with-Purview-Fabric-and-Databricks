WITH cliente_produtos AS (
    SELECT 
        cl.id_cliente,
        cl.nome as nome_cliente,
        cl.cpf,
        a.estado,
        a.cidade,
        COUNT(DISTINCT cart.numero_cartao) as total_cartoes,
        COUNT(DISTINCT CASE WHEN cart.status = 'A' THEN cart.numero_cartao END) as cartoes_ativos,
        COUNT(DISTINCT pix.id_chave_pix) as total_chaves_pix,
        COUNT(DISTINCT CASE WHEN pix.status = 'A' THEN pix.id_chave_pix END) as chaves_pix_ativas,
        STRING_AGG(DISTINCT pix.tipo_chave, ', ') as tipos_chaves_pix
    FROM [mirror_mkl_bank].[core_bank].[clientes] cl
    JOIN [mirror_mkl_bank].[core_bank].[contas] c ON cl.id_cliente = c.id_cliente
    JOIN [mirror_mkl_bank].[core_bank].[agencias] a ON c.codigo_agencia = a.codigo_agencia
    LEFT JOIN [mirror_mkl_bank].[core_bank].[cartoes] cart ON cl.id_cliente = cart.id_cliente
    LEFT JOIN [mirror_mkl_bank].[core_bank].[chaves_pix] pix ON c.id_conta = pix.id_conta
    GROUP BY cl.id_cliente, cl.nome, cl.cpf, a.estado, a.cidade
),
perfil_produtos AS (
    SELECT *,
        CASE 
            WHEN total_cartoes > 0 AND total_chaves_pix > 0 THEN 'Usuário Completo'
            WHEN total_cartoes > 0 AND total_chaves_pix = 0 THEN 'Só Cartão'
            WHEN total_cartoes = 0 AND total_chaves_pix > 0 THEN 'Só PIX'
            ELSE 'Sem Produtos'
        END as perfil_uso
    FROM cliente_produtos
)
SELECT 
    perfil_uso,
    estado,
    COUNT(*) as quantidade_clientes,
    AVG(total_cartoes) as media_cartoes,
    AVG(total_chaves_pix) as media_chaves_pix,
    AVG(cartoes_ativos) as media_cartoes_ativos,
    AVG(chaves_pix_ativas) as media_chaves_ativas,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY estado) as percentual_estado
FROM perfil_produtos
GROUP BY perfil_uso, estado
HAVING COUNT(*) > 5
ORDER BY estado, quantidade_clientes DESC;