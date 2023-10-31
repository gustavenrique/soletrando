' INTEGRANTES DO GRUPO:
' - Gustavo Henrique
' - Gustavo Formagio
' - Monique
' - Thayane
' - Thiago

Function Import(p):Import = False:Dim f,m:Set f=CreateObject("Scripting.FileSystemObject"):If(f.FileExists(f.GetAbsolutePathName(p)))Then:ExecuteGlobal(f.OpenTextFile(f.GetAbsolutePathName(p)).ReadAll):Import=-1:Exit Function:End If:Set m=CreateObject("Microsoft.XMLHTTP"):On Error Resume Next:m.Open "GET",p,0:If Not(Err.Number=-2147012890)Then:m.Send:If(m.Status=200)Then:ExecuteGlobal(m.ResponseText):Import=-1:End If:End If:End Function

Import "./Builder/JogadorBuilder.vbs"

dim db, query, queryResult, qtde_palavra, resp, n, id
dim audio, status, aux, level

dim jogador: set jogador = CreateObject("Scripting.Dictionary")
dim palavra: set palavra = createObject("Scripting.Dictionary")

call conectaBanco
call escolherJogador
call start

sub start()
   dim opcao: opcao = inputbox("Escolha uma das opcoes: " + vbnewline & _ 
   "1) Comecar jogo" + vbnewline & _
   "2) Ver instrucoes" + vbnewline & _
   "3) Ver Ranking" + vbnewline & _
   "4) Sair", "Ola, " + jogador("nome") + "!")

   select case opcao
      case 1
         call sortearPalavra
      case 2
         call verInstrucoes
      case 3
         call verRanking
      case else
         MsgBox "Sair", vbinformation + vbOKOnly, "Saindo..."
   end select
end sub

sub conectaBanco()
   set db = CreateObject("ADODB.connection")
   
   ' SEM DOCKER: db.Open("Provider=SQLOLEDB;Data Source=SEU_HOSTNAME;Initial Catalog=soletrando;trusted_connection=yes;")
   db.Open("Provider=SQLOLEDB;Data Source=127.0.0.1;Initial Catalog=soletrando; User ID=sa; Password=sqlserver2023!") ' COM DOCKER
   
   set audio = createobject("SAPI.SPVOICE")
   
   audio.volume = 100
   audio.rate = -1
end sub

sub escolherJogador()
   Dim nome: nome = InputBox("Digite o seu nome","SOLETRANDO")

   if isNull(nome) or isEmpty(nome) then
      wscript.quit
   end if
   
   query = "SELECT nome FROM jogador WHERE nome='"& nome &"'"
   
   set queryResult = db.execute(query)

   if not queryResult.EOF then
      MsgBox "Usando jogador ja existente..."
   else
      query = "INSERT INTO jogador (nome) VALUES ('"& nome &"')"
      
      queryResult = db.execute(lcase(query))

      MsgBox "Jogador cadastrado com sucesso!"
   end if

   dim jogadorId: jogadorId = (db.execute("SELECT id FROM jogador WHERE nome = '" + nome + "'")).fields("id")

   jogador("id") = jogadorId
   jogador("nome") = nome
end sub

sub verInstrucoes()
   dim instrucoes: instrucoes = _
      "Nivel A: 5 Palavras sorteadas de 10 possiveis " + vbnewline & _ 
      "Nivel B: 5 Palavras sorteadas de 10 possiveis " + vbnewline & _ 
      "Nivel C: 5 Palavras sorteadas de 10 possiveis " + vbnewline & _ 
      "Nivel D: 1 Palavra sorteada de 10 possiveis "

   MsgBox instrucoes, vbInformation + vbOKOnly, "Instrucoes"

   call start
end sub

function buscarNivel()
   query = "SELECT COUNT(*) AS acertos FROM tentativa WHERE jogador_id = " + cstr(jogador("id")) + " AND status = 'acertou'"

   set queryResult = db.execute(query)

   dim acertos: acertos = queryResult.fields("acertos")

   jogador("acertos") = acertos

   if acertos <= 5 then
      buscarNivel = "a"
   elseif acertos > 5 and acertos <= 10 then
      buscarNivel = "b"
   elseif acertos > 10 and acertos <= 15 then
      buscarNivel = "c"
   else
      buscarNivel = "d"
   end if
end function

function aumentarJogadorGrana()
   dim aumento

   if palavra("nivel") = "a" then
      aumento = 1000
   elseif palavra("nivel") = "b" then
      aumento = 10000
   elseif palavra("nivel") = "c" then
      aumento = 100000
   else
      aumento = 500000
   end if

   db.execute("UPDATE jogador SET grana = grana + "+ cstr(aumento) +" WHERE id = "+ cstr(jogador("id")))
end function

sub sortearPalavra()
   dim nivel: nivel = buscarNivel()

   query = "SELECT TOP 1 " & _
        "   p.id, " & _
        "   p.palavra, " & _
        "   p.nivel " & _
        "FROM " & _
        "   palavra p (NOLOCK) " & _
        "WHERE " & _
        "   p.nivel = '" + nivel + "' " & _
        "   AND p.id NOT IN ( " & _
        "      SELECT palavra_id " & _
        "      FROM tentativa " & _
        "      WHERE jogador_id = "+ cstr(jogador("id")) +" " & _
        "   ) " & _
        "ORDER BY NEWID()"

   set queryResult = db.execute(query)

   if queryResult.EOF then
      MsgBox "Nao ha mais palavras para voce, " + jogador("nome")
      wscript.quit
   end if
   
   palavra("id") = queryResult.fields("id").value
   palavra("palavra") = queryResult.fields("palavra").value
   palavra("nivel") = nivel
   
   audio.speak(palavra("palavra"))

   dim pulou: pulou = pular()

   if pulou then
      call sortearPalavra
   else
      dim palavraDigitada: palavraDigitada = lcase(inputbox("Digite a palavra ouvida","SOLETRANDO"))

      if palavraDigitada = palavra("palavra") then
         MsgBox("Voce acertou!!!")

         db.execute("INSERT INTO tentativa (jogador_id, palavra_id, status) VALUES ("+ cstr(jogador("id")) +", "+ cstr(palavra("id")) +", 'Acertou')")
         aumentarJogadorGrana()
      else 
         MsgBox "Voce errou!"

         db.execute("DELETE FROM tentativa WHERE jogador_id = "+ cstr(jogador("id")))
         db.execute("UPDATE jogador SET grana = 0 WHERE id = "+ cstr(jogador("id")))
      end if

      call start
   end if
end sub

function pular()
   resp = MsgBox("Deseja pular a palavra?", vbquestion + vbyesno, "PULAR")

   if resp = vbyes then
      query = "INSERT INTO tentativa (jogador_id, palavra_id, status) VALUES (" + cstr(jogador("id")) + ", " + palavra("id") + ", 'Pulou')"

      set queryResult = db.execute(query)

      pular = true
   else
      pular = false
   end if
end function

sub verRanking()
   query = "SELECT id, nome, grana FROM jogador ORDER BY grana DESC, nome"

   set queryResult = db.execute(query)

   dim jogadores: jogadores = "JOGADOR    |    PREMIO" + vbnewline

   if not queryResult.EOF then
      do until queryResult.EOF
         jogadores = jogadores + queryResult("nome").value + "    |    "+ cstr(queryResult("grana").value) + vbnewline

         queryResult.moveNext
      loop 

      msgbox jogadores
   else
      msgbox "Nao ha jogadores cadastrados"
   end if
end sub

' sortear palavra, se baseando na quantidade que ele ja acertou
' caso ele queira pular