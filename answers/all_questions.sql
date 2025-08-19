/* ==============================================================
   Q01 – TOP 5 cursos com mais inscrições **ativas**
   Retorne: id_curso · nome · total_inscritos
=================================================================*/
SELECT 
    i.id_curso,
    c.nome,
    COUNT(i.id_curso) AS total_inscritos
FROM inscricoes i
LEFT JOIN cursos c ON i.id_curso = c.id_curso
WHERE i.status = 'ativo'
GROUP BY i.id_curso, c.nome
ORDER BY total_inscritos DESC
LIMIT 5;

/* ==============================================================
   Q02 – Taxa de conclusão por curso
   Para cada curso, calcule:
     • total_inscritos
     • total_concluidos   (status = 'concluída')
     • taxa_conclusao (%) = concluídos / inscritos * 100
   Ordene descendentemente pela taxa de conclusão.
=================================================================*/
SELECT
    i.id_curso,
    c.nome,
    COUNT(i.id_curso) AS total_inscritos,
    COUNT(CASE WHEN i.status = 'concluido' THEN 1 END) AS total_concluidos,
    ROUND(
        COUNT(CASE WHEN i.status = 'concluido' THEN 1 END) * 100.0 / COUNT(i.id_curso),
        2
    ) AS "taxa_conclusao (%)"
FROM inscricoes i
LEFT JOIN cursos c ON i.id_curso = c.id_curso
GROUP BY i.id_curso, c.nome
ORDER BY "taxa_conclusao (%)" DESC;

/* ==============================================================
   Q03 – Tempo médio (dias) para concluir cada **nível** de curso
   Definições:
     • Início = data_insc   (tabela inscricoes)
     • Fim    = maior data em progresso onde porcentagem = 100
   Calcule a média de dias entre início e fim,
   agrupando por cursos.nivel (ex.: Básico, Avançado).
=================================================================*/
-- Não será possivel por falta de informação. Devo conversar com engenheiro de dados responsável pela tabela "progresso"
-- em incluir a coluna "id_curso" para que sejá possível calcular a média de conclusão por cada nivel de curso.

/* ==============================================================
   Q04 – TOP 10 módulos com maior **taxa de abandono**
   - Considere abandono quando porcentagem < 20 %
   - Inclua apenas módulos com pelo menos 20 alunos
   Retorne: id_modulo · titulo · abandono_pct
   Ordene do maior para o menor.
=================================================================*/

SELECT 
    p.id_modulo,
    m.titulo,
    ROUND( (SUM(CASE WHEN p.percentual < 20 THEN 1 ELSE 0 END) * 100.0) / COUNT(p.id_aluno), 2) AS abandono_pct
FROM progresso p
JOIN modulos m ON p.id_modulo = m.id_modulo
GROUP BY p.id_modulo, m.titulo
HAVING COUNT(p.id_aluno) >= 20
ORDER BY abandono_pct DESC
LIMIT 10;


/* ==============================================================
   Q05 – Crescimento de inscrições (janela móvel de 3 meses)
   1. Para cada mês calendário (YYYY-MM), conte inscrições.
   2. Calcule a soma móvel de 3 meses (mês atual + 2 anteriores) → rolling_3m.
   3. Calcule a variação % em relação à janela anterior.
   Retorne: ano_mes · inscricoes_mes · rolling_3m · variacao_pct
=================================================================*/
WITH mensal AS (
    -- 1. Contar inscrições por mês
    SELECT 
        strftime('%Y-%m', data_inscricao) AS ano_mes,
        COUNT(*) AS inscricoes_mes
    FROM inscricoes
    GROUP BY strftime('%Y-%m', data_inscricao)
),
rolling AS (
    SELECT 
        ano_mes,
        inscricoes_mes,
        SUM(inscricoes_mes) OVER(
            ORDER BY ano_mes
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_3m
    FROM mensal
)
-- 3. Variação percentual em relação à janela anterior
SELECT
    ano_mes,
    inscricoes_mes,
    rolling_3m,
    ROUND(100.0 * (rolling_3m - LAG(rolling_3m) OVER (ORDER BY ano_mes)) / 
          LAG(rolling_3m) OVER (ORDER BY ano_mes), 2) AS variacao_pct
FROM rolling
ORDER BY ano_mes;
