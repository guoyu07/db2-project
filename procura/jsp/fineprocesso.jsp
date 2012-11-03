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
  String submit = request.getParameter("submit");
  String processo = request.getParameter("processo");

  if (giorno == null || mese == null || anno == null || submit == null || processo==null) {
    response.sendRedirect("errore.jsp");
  }else{
   if (submit.compareTo("Aggiungi")==0) {
    Connection conn = open_conn("procura");
    Statement stat = conn.createStatement();
    stat.executeUpdate("UPDATE processo SET datafine=date '"+anno+"-"+mese+"-"+giorno+"' WHERE id="+processo+";");
    stat.close();
    conn.close();
   }
   response.sendRedirect("processi.jsp");
  }
%>
