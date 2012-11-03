<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ include file = "connessione.jsp" %>
<%!
  public String trans_role(String role){
   String result = new String();  
   if(role.compareTo("pg")==0){
    result="Polizia Giudiziaria";
   }else if(role.compareTo("pm")==0){
    result="Pubblico Ministero";
   }else if(role.compareTo("am")==0){
    result="Amministratore";
   }
   return result;
  }
%>
<%
  String ruolo = (String)session.getAttribute("ruolo");
  if (ruolo == null) {
   response.sendRedirect("errore.jsp");
  }else{
   if (ruolo.compareTo("am") != 0){
    response.sendRedirect("errore.jsp");
   }
  }
%>
<html xmlns="http://www.w3.org/1999/xhtml">
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
  <title>Procura della Repubblica di Milano - Processi</title>
  <meta name="keywords" content="procura della repubblica, milano, giustizia, legge" />
  <meta name="description" content="Sito della Procura della Repubblica presso il Tribunale di Milano" />
  <link href="../css/style.css" rel="stylesheet" type="text/css" />
 </head>
<body>
 <div id="templatemo_header">
  <div id="site_title">
   <img src="../images/emblema.png" alt="emblema" align="left" style="margin-right:5px;"/>
   <h3><br/>Procura della<br />Repubblica<br />di Milano</h3>
  </div>
  <div id="templatemo_menu">
   <ul>
    <li><a href="../index.jsp"><span></span>Home</a></li>
    <li><a href="processi.jsp"><span></span>Processi</a></li>
    <li><a href="indagati.jsp"><span></span>Indagati</a></li>
    <li><a href="indagini.jsp"><span></span>Indagini</a></li>
    <li><a href="admin.jsp" class="current"><span></span>Admin</a></li>
   </ul>    	
  </div>
 </div>

 <div id="templatemo_middle">
  <div id="mid_left">
   <fieldset>
    <legend>Nuovo utente</legend>
    <form action="nuovoutente.jsp" method="POST">
     <table>
      <tr>
       <td>Username:</td>
       <td>
        <input type="text" name="username" /><br/>
        <span class="suggestion">(almeno 5 caratteri)</span>
       </td>
      </tr>
      <tr>
       <td>Password:</td>
       <td>
        <input type="text" name="password" /><br/>
        <span class="suggestion">(almeno 5 caratteri)</span>
       </td>
      </tr>
      <tr>
       <td>Ruolo:</td>
       <td>
        <input type="radio" name="ruolo" value="pg" checked/> Polizia Giudiziaria<br />
        <input type="radio" name="ruolo" value="pm" /> Pubblico Ministero<br />
        <input type="radio" name="ruolo" value="am" /> Amministratore
       </td>
      </tr>
     </table>
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Aggiungi" />
    </form>
    <% 
      String newuser =  (String)session.getAttribute("newuser");
      if(newuser!=null){
       if(newuser.compareTo("ok")==0){
        out.println("<p style='color:green'>Inserito nuovo utente</p>");
       }else if(newuser.compareTo("erruser")==0){
        out.println("<p style='color:red'>Username non valida</p>");
       }else if(newuser.compareTo("errpass")==0){
        out.println("<p style='color:red'>Password non valida</p>");
       }else if(newuser.compareTo("errdupl")==0){
        out.println("<p style='color:red'>Username gi&agrave; in uso</p>");
       }
       session.removeAttribute("newuser");
      }
    %>
   </fieldset>
  </div>
  <div id="mid_right">
  <%
    Connection conn = open_conn("login");
    Statement stat = conn.createStatement();
    ResultSet rset = stat.executeQuery("SELECT * FROM login ORDER BY username;");
    out.println("<table class='contenuti' width='100%'><tr><th>Username</th><th>Ruolo</th><th>Elimina</th></tr>");

    while(rset.next()){
     out.println("<tr><td>"+rset.getString("username")+"</td>");
     out.println("<td>"+trans_role(rset.getString("ruolo"))+"</td>");
     if(rset.getString("username").compareTo((String)session.getAttribute("username"))==0){
      out.println("<td></td></tr>");
     }else{
      out.println("<td><form action='eliminautente.jsp' method='POST'>");
      out.println("<center><button type='submit' class='submit_btn' name='username' value='"+rset.getString("username")+"'>Elimina</button></center>");
      out.println("</form></td></tr>");
     }
    }
    out.println("</table>");
    stat.close();
    conn.close();
  %>
  </div>
 </div>

 <div id="templatemo_main_wrapper">
  <div id="templatemo_main">
   <div class="three_column margin_r25 vertical_divider" style="text-align:right;">
    <h3>Staff</h3>
    <img src="../images/staff.png" alt="staff" />
    <p><strong>Magistrato:</strong><br/>Dott. Elio Ramondini</p>
    <p><strong>Funzionario Giudiziario:</strong><br/>Dott. Aldo Caruso</p>
   </div>
   <div class="three_column margin_r25 vertical_divider" style="text-align:right;">
    <h3>Contatti</h3>
    <img src="../images/contatti.png" alt="contatti" />
    <p><strong>Centralino:</strong> 02/54331-5436</p>
    <p><strong>Fax:</strong> 02/5457068</p>
    <p><strong>Indirizzo:</strong> Via Freguglia 1<br/>20122 Milano MI</p>
   </div>
   <div class="three_column" style="text-align:right;">
    <h3>Login</h3>
    <img src="../images/login.png" alt="login" />
    <%
      String username =  (String)session.getAttribute("username");
      if(username!=null){
    %>
    <form action="logout.jsp" method="POST">
     <strong>Benvenuto <% out.println(username); %></strong><br/>
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Logout" />
    </form>
    <%
      }else{
    %>
    <form action="login.jsp" method="POST">
     <strong>Username:</strong><input name="username" size=10 type="text"/><br/>
     <strong>Password:</strong><input name="password" size=10 type="password"/><br/>
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Login" />
    </form>
    <% 
      }
      String login =  (String)session.getAttribute("login");
      if(login!=null){
       if(login.compareTo("errpass")==0){
        out.println("<p style='color:red'>Password errata</p>");
       }else if(login.compareTo("erruser")==0){
        out.println("<p style='color:red'>Utente inesistente</p>");
       }
       session.removeAttribute("login");
      }
    %>
   </div>
  </div>
  <div id="templatemo_footer_wrapper">
   <div id="templatemo_footer">
    2011 - Procura di Milano
   </div>
  </div>
 </body>
</html>
