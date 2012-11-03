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
  String esito = request.getParameter("esito");
  String commento = request.getParameter("commento");
  String submit = request.getParameter("submit");
  String imputato = request.getParameter("imputato");
  String processo = request.getParameter("processo");

  if (esito == null || commento == null || submit == null || imputato == null || processo==null) {
    response.sendRedirect("errore.jsp");
  }else{
   if (submit.compareTo("Aggiungi")==0){
    Connection conn = open_conn("procura");
    Statement stat = conn.createStatement();
    if(esito.compareTo("proscioglimento")==0){
     stat.executeUpdate("INSERT INTO proscioglimento VALUES("+processo+","+imputato+",'"+commento+"');");
    }else if(esito.compareTo("condanna")==0){
     stat.executeUpdate("INSERT INTO condanna VALUES("+processo+","+imputato+",'"+commento+"');");
    }
    stat.close();
    conn.close();
   }
   response.sendRedirect("processi.jsp");
  }
%>
