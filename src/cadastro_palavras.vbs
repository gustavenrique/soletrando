dim db, query, queryResult, palavra, resp

call conecta_banco

sub conecta_banco()
   set db = CreateObject("ADODB.connection")
   
   ' SEM DOCKER: db.Open("Provider=SQLOLEDB;Data Source=SEU_HOSTNAME;Initial Catalog=soletrando;trusted_connection=yes;")
   db.Open("Provider=SQLOLEDB;Data Source=127.0.0.1;Initial Catalog=soletrando; User ID=sa; Password=sqlserver2023!") ' COM DOCKER
   
   msgbox("Conexao OK"),vbinformation+vbOKOnly,"AVISO"
   
   call cadastrar_palavras
end sub

sub cadastrar_palavras()
   palavra = inputbox("Digite a palavra a ser cadastrada", "Soletrando")

   if isNull(palavra) or isEmpty(palavra) then
         wscript.quit
   end if
   
   query = "SELECT TOP 1 1 FROM palavra p WHERE p.palavra='"& palavra &"'"
   
   set queryResult = db.execute(query)

   if queryResult.EOF = false Then
      msgbox("Palavra ja cadastrada!"),vbExclamation+vbokonly,"ATENCAO"
      
      call cadastrar_palavras
   else
      Dim nivel: nivel = InputBox("Digite o nivel da palavra", "Soletrando")

      query = "INSERT INTO palavra (palavra, nivel) VALUES ('" & palavra & "', '" + nivel + "')"
      
      queryResult = db.execute(ucase(query))
      
      cadastrarNovamente = msgbox( _
         "Palavra cadastrada com sucesso!" + vbnewline + "Deseja cadastrar nova palavra?", _
         vbQuestion + vbYesNo, _
         "ATENÇÃO" _
      )

      if cadastrarNovamente <> vbyes then
         wscript.quit
      end If

      call cadastrar_palavras
   end if
end sub