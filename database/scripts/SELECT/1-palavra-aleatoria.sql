DECLARE @JogadorID INT = 1
DECLARE @Nivel CHAR(1) = 'a'

SELECT
	p.id,
	p.palavra,
	p.nivel
FROM 
	palavra p (NOLOCK)
WHERE
	p.nivel = @Nivel
	AND p.id NOT IN (
		SELECT palavra_id 
		FROM tentativa 
		WHERE jogador_id = @JogadorID
	)
ORDER BY NEWID()