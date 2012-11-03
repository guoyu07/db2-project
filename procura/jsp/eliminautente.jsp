<%@ include file = "connessione.jsp" %>
<%
  String ruolo = (String)session.getAttribute("ruolo");
  if (ruolo == null) {
   response.sendRedirect("errore.jsp");
  }else{
   if (ruolo.compareTo("am") != 0){
    response.sendRedirect("errore.jsp");
   }
  }
  String username = request.getParameter("username");

  if (username == null) {
    response.sendRedirect("errore.jsp");
  }else{
   Connection conn = open_conn("login");
   Statement stat = conn.createStatement();
   stat.executeUpdate("DELETE FROM login WHERE username='"+username+"'");

   stat.close();
   conn.close();
   response.sendRedirect("admin.jsp");
  }
%>
