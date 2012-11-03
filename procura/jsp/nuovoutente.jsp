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
  String password = request.getParameter("password");
  ruolo = request.getParameter("ruolo");

  if (username == null || password == null || ruolo == null) {
    response.sendRedirect("errore.jsp");
  }else{
   if (username.length()<5){
    session.setAttribute("newuser","erruser");
   }else if (password.length()<5){
    session.setAttribute("newuser","errpass");
   }else{
    Connection conn = open_conn("login");
    Statement stat = conn.createStatement();
    ResultSet rset = stat.executeQuery("SELECT newuser('"+username+"','"+password+"','"+ruolo+"') AS result;");

    rset.next();
    if(rset.getBoolean("result")){
     session.setAttribute("newuser","ok");
    }else{
     session.setAttribute("newuser","errdupl");
    }
    stat.close();
    conn.close();
   }
   response.sendRedirect("admin.jsp");
  }
%>
