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
  String indagato = request.getParameter("indagato");
  String illecito = request.getParameter("illecito");
  String submit = request.getParameter("submit");
  
  if (indagato == null || illecito == null || submit == null || id == null) {
   response.sendRedirect("errore.jsp");
  }else{
   if (!(indagato.compareTo("")==0 || illecito.compareTo("")==0 || id.compareTo("")==0 || submit.compareTo("Aggiungi")!=0)) {
    Connection conn = open_conn("procura");
    Statement stat = conn.createStatement();
    stat.executeUpdate("INSERT INTO citazione VALUES ("+indagato+","+id+",'"+illecito+"');");
    stat.close();
    conn.close();
   }
   response.sendRedirect("indagini.jsp?id="+id);
  }
%>
