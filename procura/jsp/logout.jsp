<%
  String username=(String)session.getAttribute("username");
  if (username == null) {
   response.sendRedirect("errore.jsp");
  }else{
   session.removeAttribute("username");
   session.removeAttribute("ruolo");
   session.removeAttribute("login");
   response.sendRedirect("../index.jsp");
  }
%> 
