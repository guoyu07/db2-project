<%@ include file = "connessione.jsp" %>
<%
  String ruolo = (String)session.getAttribute("ruolo");
  if (ruolo == null) {
   response.sendRedirect("errore.jsp");
  }else{
   if ((ruolo.compareTo("pm") != 0) && (ruolo.compareTo("pg") != 0)){
    response.sendRedirect("errore.jsp");
   }
  }
  String nome = request.getParameter("nome");
  String cognome = request.getParameter("cognome");
  String giorno = request.getParameter("giorno");
  String mese = request.getParameter("mese");
  String anno = request.getParameter("anno");
  String luogo = request.getParameter("luogo");
  String residenza = request.getParameter("residenza");
  String genere = request.getParameter("genere");
  String submit = request.getParameter("submit");  
  if (nome == null || cognome == null || giorno == null || mese == null || anno == null || luogo == null || residenza == null || genere == null) {
   response.sendRedirect("errore.jsp");
  }else{
   if (!(nome.compareTo("")==0 || cognome.compareTo("")==0 || giorno.compareTo("")==0 || mese.compareTo("")==0 || anno.compareTo("")==0 || luogo.compareTo("")==0 || residenza.compareTo("")==0 || genere.compareTo("")==0 || submit.compareTo("Aggiungi")!=0)) {
    Connection conn = open_conn("procura");
    Statement stat = conn.createStatement();
    ResultSet rset = stat.executeQuery("SELECT * FROM indagato WHERE nome='"+nome+"' AND cognome='"+cognome+"' AND datanascita=date '"+anno+"-"+mese+"-"+giorno+"' AND luogonascita='"+luogo+"';");
    if(!rset.next()){
     Statement stat1 = conn.createStatement();
     stat1.executeUpdate("INSERT INTO indagato (nome, cognome, datanascita, luogonascita, residenza, genere) VALUES ('"+nome+"','"+cognome+"',date '"+anno+"-"+mese+"-"+giorno+"','"+luogo+"','"+residenza+"','"+genere+"');");
     stat1.close();
    }
    stat.close();
    conn.close();
   }
   response.sendRedirect("indagati.jsp");
  }
%>
