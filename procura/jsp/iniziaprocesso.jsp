<%@ include file = "connessione.jsp" %>
<%
  String ruolo = (String)session.getAttribute("ruolo");
  if (ruolo == null) {
   response.sendRedirect("errore.jsp");
  }else{
   if (ruolo.compareTo("pm") != 0){
    response.sendRedirect("errore.jsp");
   }
  }
  String giorno = request.getParameter("giorno");
  String mese = request.getParameter("mese");
  String anno = request.getParameter("anno");
  String indagine = request.getParameter("id");
  String grado = request.getParameter("grado");
  String[] indagati = request.getParameterValues("imputato");
  String submit = request.getParameter("submit");
  if (giorno == null || mese == null || anno == null || indagine==null || grado==null || submit==null) {
   response.sendRedirect("errore.jsp");
  }else{
   if(indagati != null){
    if (!(giorno.compareTo("")==0 || mese.compareTo("")==0 || anno.compareTo("")==0 || indagine.compareTo("")==0 || grado.compareTo("")==0 || indagati[0].compareTo("")==0 || submit.compareTo("Aggiungi")!=0)) {
     Connection conn = open_conn("procura");
     Statement stat = conn.createStatement();
     ResultSet rset = stat.executeQuery("SELECT * FROM processo WHERE indagine="+indagine+" AND gradogiudizio='"+grado+"';");
     if(rset.next()){
      stat.close();
      response.sendRedirect("errore.jsp");
     }else{
      stat.close();
      Statement stat1 = conn.createStatement();
      ResultSet rset1 = stat1.executeQuery("SELECT nuovoprocesso("+indagine+", '"+grado+"', date '"+anno+"-"+mese+"-"+giorno+"') AS id;");
      rset1.next();
      int processo = rset1.getInt("id");
      stat1.close();
      for(int i=0; i<indagati.length; i++){
       Statement stat2 = conn.createStatement();
       ResultSet rset2 = stat2.executeQuery("SELECT * FROM imputato WHERE indagato="+indagati[i]+";");
       if(!rset2.next()){
        Statement stat3 = conn.createStatement();
        stat3.executeUpdate("INSERT INTO imputato VALUES ("+indagati[i]+");");
        stat3.close();
       }
       stat2.close();
       Statement stat4 = conn.createStatement();
       stat4.executeUpdate("INSERT INTO carico VALUES ("+processo+","+indagati[i]+");");
       stat4.close();
      }
     }
     conn.close();
    }
   }
   response.sendRedirect("indagini.jsp?id="+indagine);
  }
%>
