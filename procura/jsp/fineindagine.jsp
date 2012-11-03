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
  String id = request.getParameter("id");
  String giorno = request.getParameter("giorno");
  String mese = request.getParameter("mese");
  String anno = request.getParameter("anno");
  String submit = request.getParameter("submit");
  
  if (id == null || giorno == null || mese == null || anno == null || submit == null) {
   response.sendRedirect("errore.jsp");
  }else{
   if (!(id.compareTo("")==0 || giorno.compareTo("")==0 || mese.compareTo("")==0 || anno.compareTo("")==0 || submit.compareTo("Aggiungi")!=0)) {
    Connection conn = open_conn("procura");
    Statement stat = conn.createStatement();
    stat.executeUpdate("UPDATE indagine SET datafine='"+anno+"-"+mese+"-"+giorno+"' WHERE id="+id+";");
    stat.close();
    conn.close();
   }
   response.sendRedirect("indagini.jsp?id="+id);
  }
%>
