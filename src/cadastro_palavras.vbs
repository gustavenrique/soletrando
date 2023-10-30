dim db,sql,rs,palavra,resp

call conecta_banco

sub conecta_banco()
   set db = CreateObject("ADODB.connection")
   
   db.Open("Provider=SQLOLEDB;Data Source=LAB5-03;Initial Catalog=soletrando;trusted_connection=yes;")
   
   msgbox("Conexão OK"),vbinformation+vbOKOnly,"AVISO"
   
   call cadastrar_palavras
end sub

'Podemos usar o outro código de base para inserir o nome
sub cadastrar_palavras()
   palavra=inputbox("Digite a palavra a ser cadastrada", "SOLETRANDO")
   
   sql="select * from tb_soletrando where palavra='"& palavra &"'"
   
   set rs=db.execute(sql)
   if rs.EOF = false Then
      msgbox("Palavra já cadastrada!"),vbExclamation+vbokonly,"ATENÇÃO"
      
      call cadastrar_palavras
   Else
      sql="insert into tb_soletrando (palavra,ja_foi) values ('"& palavra &"','N')"
      
      rs=db.execute(ucase(sql))
      
      resp=msgbox("Palavra cadastrada com sucesso!" + vbnewline & _
                  "Deseja cadastrar nova palavra?",vbQuestion+vbyesno,"ATENÇÃO")
      if resp=vbyes then
         call cadastrar_palavras
      Else
         wscript.quit
      end If
   end if
end sub