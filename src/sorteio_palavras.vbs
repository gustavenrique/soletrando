dim db, queryResult, query, resultado, qtde_palavra, resp, n, id
dim audio, compara, status, aux, opcao, level, right

call conecta_banco

sub conecta_banco()
   set db = CreateObject("ADODB.connection")
   
   ' SEM DOCKER: db.Open("Provider=SQLOLEDB;Data Source=SEU_HOSTNAME;Initial Catalog=soletrando;trusted_connection=yes;")
   db.Open("Provider=SQLOLEDB;Data Source=127.0.0.1;Initial Catalog=soletrando; User ID=sa; Password=sqlserver2023!") ' COM DOCKER
   
   set audio = createobject("SAPI.SPVOICE")
   
   audio.volume = 100
   audio.rate = -1

   call cadastrar_nome
   call start
end sub

'Aqui será inserido o nome para o placar
sub cadastrar_nome()
   Dim nome: nome = InputBox("Digite o seu nome","SOLETRANDO")
   
   query = "SELECT TOP 1 nome FROM jogador WHERE nome='"& nome &"'"
   
   set queryResult = db.execute(query)
  
   query = "INSERT INTO jogador (nome) VALUES ('"& nome &"')"
   
   queryResult = db.execute(ucase(query))
   
   MsgBox("Jogador cadastrado com sucesso!")
end sub

'Menu
sub start()
   ' menu com começar jogo, sair ou ver instruções
   opcao = inputbox("Escolha uma das opcoes: " + vbnewline & _ 
   "1) Comecar jogo" + vbnewline & _
   "2) Ver instrucoes" + vbnewline & _
   "3) Sair", "Menu")

   select case opcao
      case 1
         call sortear_palavra
      case 2
         call ver_instrucoes
      case else
         MsgBox("Sair"),vbinformation+vbOKOnly,"Saindo..."
   end select
end sub

' GUSTAVO aqui o problema também está na sintaxe
sub pular()
   Dim count: count = 1

   Do While count <= 3
      'Chance de pular a palavra
      resp = MsgBox("Deseja pular a palavra?",vbquestion+vbyesno,"PULAR")

      if resp=vbyes Then
         query="update palavra set ja_foi='S'"
         resultado=db.execute(query)
         count = count + 1
         call sortear_palavra
      else
         Next
      end if  
   Loop
end sub

'Manual de Regras
sub ver_instrucoes()
   instrucoes = "Nivel A: 5 Palavras sorteadas de 10 possiveis " + vbnewline & _ 
      "Nivel B: 5 Palavras sorteadas de 10 possiveis " + vbnewline & _ 
      "Nivel C: 5 Palavras sorteadas de 10 possiveis " + vbnewline & _ 
      "Nivel D: 1 Palavra sorteada de 10 possiveis "

   MsgBox(instrucoes, vbInformation + vbOKOnly,"Instrucoes")

   call start
end sub

'Aqui está o xabu!
sub sortear_palavra()
   query = "select count(*) as qtde from palavra"

   set resultado = db.execute(query)
   
   qtde_palavra = resultado.fields("qtde")
   
   Randomize(second(time))
   
   n = int(rnd * qtde_palavra) + 1
   
   query = "select * from palavra where id=" & n &""
   
   set resultado = db.execute(query)
   
   palavra = resultado.fields(1).value
   
   if resultado.fields(2).value = "S" Then
      call sortear_palavra
   else
      audio.speak(""& palavra &"")

      call pular

      compara = inputbox("Digite a palavra ouvida","SOLETRANDO")
      compara = (LCase (compara))

      if compara = palavra Then 
      
         query = "update palavra set ja_foi='S' where id="& n &"" 
      
         MsgBox("Você acertou!!!")

         set resultado = db.execute(query)
 
         query = "select nivel from ranking as level"

      Select Case level
      Case a
         call verificar
         query="update ranking set grana+=1000"

      Case b
         call verificar
         query="update ranking set grana+=10000"

      Case c
         call verificar
         query="update ranking set grana+=100000"

      case d
         call verificar
         Debug.WriteLine("VOCÊ GANHOU!")
         query="update ranking set grana=1000000"

      End Select         
         
         'query="select count(*) as qtde_palavras from palavra where ja_foi='N'"
         'resultado=db.execute(query)
         'aux=resultado.fields("qtde_palavras")
         'MsgBox(aux)	  
      'if aux <> 0 then
            call sortear_palavra
         'else
         '  MsgBox("Fim de palavras no banco")
         'End if
         
      Else
         MsgBox("Você errou!")
         
         resp=MsgBox("Deseja jogar novamente?",vbquestion+vbyesno,"ATENÇÃO")
         if resp=vbyes Then
            query="update palavra set ja_foi='N'"
            
            resultado=db.execute(query)
            
            call sortear_palavra
         else
            wscript.quit
         end if

      end if

   end if

end sub

sub verificar()
   ' TODO: Apenas incrementar grana do jogador se baseando no nivel da palavra acertada
   query = "select acertos from ranking as right" ' SELECT COUNT(*) FROM tentativa WHERE jogador_id = <JOGADOR_ID> AND acertou = 1

   right = db.execute(query)

   If (right == 5 AND level == "a") Then
      query="update ranking set grana = 5000, nivel = 'b', acertos = 0"

   elseif ((right == 1) And (level == "b")) Then
      query="update ranking set grana = 10000"

   elseif ((right == 5) And (level == "b")) Then        
      query="update ranking set nivel = 'c', acertos = 0"
   
   elseif ((right == 1) And (level == "c")) Then 
      query="update ranking set grana = 100000"
   
   elseif ((right == 5) And (level == "c")) Then 
      query="update ranking set grana = 1000000, nivel = 'd', acertos=0"
   
   elseif ((right == 1) And (level == "d")) Then 
      query="update ranking set nivel=0, acertos=0"
   end if

   set resultado = db.execute(query)
end sub