<%@ include file = "connessione.jsp" %>
<%
  String username = request.getParameter("username");
  String password = request.getParameter("password");

  if (username == null || password == null) {
   response.sendRedirect("errore.jsp");
  }else{
   Connection conn = open_conn("login");
   Statement stat = conn.createStatement();
   ResultSet rset = stat.executeQuery("SELECT * FROM pwdmatch('"+username+"','"+password+"');");

   if(rset.next()){
    if(rset.getBoolean("match")){
     session.setAttribute("login","ok");
     session.setAttribute("username", username);
     session.setAttribute("ruolo", rset.getString("role"));
    }else{
     session.setAttribute("login","errpass");
    }
   }else{
     session.setAttribute("login","erruser");
   }
   response.sendRedirect("../index.jsp");

   stat.close();
   conn.close();
  }
%>
