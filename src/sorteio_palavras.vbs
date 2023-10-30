dim db,rs,sql,resultado,qtde_palavra,resp,n,id,x
dim audio, compara, status, aux, opcao, level, right

call conecta_banco

sub conecta_banco()
   set db = CreateObject("ADODB.connection")
   
   db.Open("Provider=SQLOLEDB;Data Source=M2-MONPC;Initial Catalog=soletrando;trusted_connection=yes;")
   
   msgbox("Conexão OK"),vbinformation+vbOKOnly,"AVISO"
   
   set audio = createobject("SAPI.SPVOICE")
   
   audio.volume = 100
   audio.rate = -1

   call cadastrar_nome
   call start
end sub

'Aqui será inserido o nome para o placar
sub cadastrar_nome()
   palavra=inputbox("Digite o seu nome","SOLETRANDO")
   
   sql="select * from ranking where jogador_nome='"& palavra &"'"
   
   set rs=db.execute(sql)
  
      sql="insert into ranking (jogador_nome) values ('"& palavra &"')"
      
      rs=db.execute(ucase(sql))
      
      resp=msgbox("Jogador cadastrado com sucesso!")
end sub

' GUSTAVO não conseguimos corrigir a sintaxe do sub verificar
sub verificar()

   sql = "select acertos from ranking as right"

      If (right == 5 AND level == "a") Then
         sql="update ranking set grana=5000"
         sql="update ranking set nivel=b"
         sql="update ranking set acertos=0"

         set resultado = db.execute(sql)
      ElseIf ((right == 1) And (level == "b")) Then
         sql="update ranking set grana=10000"
         sql="update ranking set grana=10000"

      ElseIf ((right == 5) And (level == "b")) Then        
         sql="update ranking set nivel=c"
         sql="update ranking set acertos=0"
      
      ElseIf ((right == 1) And (level == "c")) Then 
         sql="update ranking set grana=100000"
      
      ElseIf ((right == 5) And (level == "c")) Then 
         sql="update ranking set grana=1000000"
         sql="update ranking set nivel=d"
         sql="update ranking set acertos=0"

      ElseIf ((right == 1) And (level == "d")) Then 
         sql="update ranking set nivel=0"
         sql="update ranking set acertos=0"
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
         msgbox("Sair"),vbinformation+vbOKOnly,"Saindo..."
   end select
end sub

' GUSTAVO aqui o problema também está na sintaxe
sub pular()
   x=1
   Do While x=<3
      'Chance de pular a palavra
         resp=msgbox("Deseja pular a palavra?",vbquestion+vbyesno,"PULAR")
         if resp=vbyes Then
            sql="update palavra set ja_foi='S'"
            resultado=db.execute(sql)
            x=x+1
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

   msgbox(instrucoes),vbinformation+vbOKOnly,"Instrucoes"

   call start
end sub

'Aqui está o xabu!
sub sortear_palavra()
   sql = "select count(*) as qtde from palavra"

   set resultado = db.execute(sql)
   
   qtde_palavra = resultado.fields("qtde")
   
   Randomize(second(time))
   
   n = int(rnd * qtde_palavra) + 1
   
   sql = "select * from palavra where id=" & n &""
   
   set resultado = db.execute(sql)
   
   palavra = resultado.fields(1).value
   
   if resultado.fields(2).value = "S" Then
      call sortear_palavra
   else
      audio.speak(""& palavra &"")

      call pular

      compara = inputbox("Digite a palavra ouvida","SOLETRANDO")
      compara = (LCase (compara))

      if compara = palavra Then 
      
         sql = "update palavra set ja_foi='S' where id="& n &"" 
      
         msgbox("Você acertou!!!")

         set resultado = db.execute(sql)
 
         sql = "select nivel from ranking as level"

      Select Case level
      Case a
         call verificar
         sql="update ranking set grana+=1000"

      Case b
         call verificar
         sql="update ranking set grana+=10000"

      Case c
         call verificar
         sql="update ranking set grana+=100000"

      case d
         call verificar
         Debug.WriteLine("VOCÊ GANHOU!")
         sql="update ranking set grana=1000000"

      End Select         
         
         'sql="select count(*) as qtde_palavras from palavra where ja_foi='N'"
         'resultado=db.execute(sql)
         'aux=resultado.fields("qtde_palavras")
         'msgbox(aux)	  
      'if aux <> 0 then
            call sortear_palavra
         'else
         '  msgbox("Fim de palavras no banco")
         'End if	  
         
         
      Else
         msgbox("Você errou!")
         
         resp=msgbox("Deseja jogar novamente?",vbquestion+vbyesno,"ATENÇÃO")
         if resp=vbyes Then
            sql="update palavra set ja_foi='N'"
            
            resultado=db.execute(sql)
            
            call sortear_palavra
         else
            wscript.quit
         end if

      end if

   end if

end sub

