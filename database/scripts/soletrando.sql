-- IF NOT EXISTS(SELECT TOP 1 1 FROM sys.databases WHERE name = 'soletrando')
-- 	CREATE DATABASE soletrando

-- USE soletrando

-- GO

IF NOT EXISTS (SELECT TOP 1 1 FROM sys.tables WHERE name = 'palavra')
	CREATE TABLE palavra (
		id INT IDENTITY(1, 1) NOT NULL,
		palavra VARCHAR(50) NOT NULL,
		nivel CHAR(1) NOT NULL,
		ja_foi BIT NOT NULL DEFAULT 0,
		CHECK (nivel IN ('a', 'b', 'c', 'd')),
		CONSTRAINT PK_Palavra PRIMARY KEY (id)
	)
	
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.tables WHERE name = 'jogador')
	CREATE TABLE jogador (
		id INT IDENTITY(1, 1) NOT NULL,
		nome VARCHAR(50) NOT NULL,
		CONSTRAINT PK_Jogador PRIMARY KEY (id)
	)

IF NOT EXISTS (SELECT TOP 1 1 FROM sys.tables WHERE name = 'tentativa')
	CREATE TABLE tentativa (
		id INT IDENTITY(1, 1) NOT NULL,
		jogador_id INT NOT NULL,
		palavra_id INT NOT NULL,
		acertou BIT NOT NULL,
		data DATETIME NOT NULL DEFAULT GETDATE(),
		CONSTRAINT FK_JogadorTentativa_Jogador FOREIGN KEY (jogador_id)
			REFERENCES jogador (id),
		CONSTRAINT FK_JogadorTentativa_Palavra FOREIGN KEY (jogador_id)
			REFERENCES jogador (id),
		CONSTRAINT PK_Tentativa PRIMARY KEY (id)
	)

GO

-- NIVEL A
IF NOT EXISTS (SELECT TOP 1 1 FROM palavra WHERE nivel = 'a')
	INSERT INTO palavra
		(palavra, nivel) 
	VALUES 
		('banana', 'a'),
		('caneta', 'a'),
		('dezena', 'a'),
		('farofa', 'a'),
		('hora', 'a'),
		('lixo', 'a'),
		('noite', 'a'),
		('pirulito', 'a'),
		('azedo', 'a'),
		('beijo', 'a')

-- NIVEL B
IF NOT EXISTS (SELECT TOP 1 1 FROM palavra WHERE nivel = 'b')
	INSERT INTO palavra
		(palavra, nivel)
	VALUES
		('quiabo', 'b'),
		('barriga', 'b'),
		('tesoura', 'b'),
		('rainha', 'b'),
		('agulha', 'b'),
		('tartaruga', 'b'),
		('feliz', 'b'),
		('globo', 'b'),
		('volante', 'b'),
		('pincel', 'b')

-- NIVEL C
IF NOT EXISTS (SELECT TOP 1 1 FROM palavra WHERE nivel = 'c')
	INSERT INTO palavra
		(palavra, nivel)
	VALUES
		('vicissitude', 'c'),
		('conspurcar', 'c'),
		('excesso', 'c'),
		('quinquilharia', 'c'),
		('capcioso', 'c'),
		('extraterrestre', 'c'),
		('infeccioso', 'c'),
		('exclusividade', 'c'),
		('impronunciamento', 'c'),
		('interdisciplinaridade', 'c')


-- NIVEL D
IF NOT EXISTS (SELECT TOP 1 1 FROM palavra WHERE nivel = 'd')
	INSERT INTO palavra
		(palavra, nivel)
	VALUES
		('idiossincrasia', 'd'),
		('impeachment', 'd'),
		('assoreamento', 'd'),
		('ascensorista', 'd'),
		('antropocentrismo', 'd'),
		('otorrinolaringologista', 'd'),
		('anticonstitucionalmente', 'd'),
		('incompreensibilidade', 'd'),
		('inconstitucionalissimamente', 'd'),
		('esternocleidomastoideo', 'd')