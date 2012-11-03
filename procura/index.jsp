<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>Procura della Repubblica di Milano</title>
  <meta name="keywords" content="procura della repubblica, milano, giustizia, legge" />
  <meta name="description" content="Sito della Procura della Repubblica presso il Tribunale di Milano" />
  <link href="css/style.css" rel="stylesheet" type="text/css" />
 </head>
<body>
 <div id="templatemo_header">
  <div id="site_title">
   <img src="images/emblema.png" alt="emblema" align="left" style="margin-right:5px;"/>
   <h3><br/>Procura della<br />Repubblica<br />di Topolinia</h3>
  </div>
  <div id="templatemo_menu">
   <ul>
    <li><a href="index.jsp" class="current"><span></span>Home</a></li>
    <li><a href="jsp/processi.jsp"><span></span>Processi</a></li>
    <%
      String ruolo =  (String)session.getAttribute("ruolo");
      if(ruolo!=null){
       if(ruolo.compareTo("pm")==0 || ruolo.compareTo("pg")==0 || ruolo.compareTo("am")==0){
    %>
    <li><a href="jsp/indagati.jsp"><span></span>Indagati</a></li>
    <li><a href="jsp/indagini.jsp"><span></span>Indagini</a></li>
    <% 
       }
       if(ruolo.compareTo("am")==0){
    %>
    <li><a href="jsp/admin.jsp"><span></span>Admin</a></li>
    <% 
       }
      }
    %>
   </ul>    	
  </div>
 </div>

 <div id="templatemo_middle">
  <div id="mid_left">
   <img src="images/palazzo.png" alt="palazzo" style="padding: 5px;border:1px solid; border-color: #ccc #666 #666 #ccc;" />
  </div>
  <div id="mid_right">
   <h2>Procura della Repubblica</h2>
   <h3 style="text-align:right;">presso il Tribunale di Topolinia</h3>
  </div>
 </div>

 <div id="templatemo_main_wrapper">
  <div id="templatemo_main">
   <div class="three_column margin_r25 vertical_divider" style="text-align:right;">
    <h3>Staff</h3>
    <img src="images/staff.png" alt="staff" />
    <p><strong>Magistrato:</strong><br/>Pippo</p>
    <p><strong>Funzionario Giudiziario:</strong><br/>Paperino</p>
   </div>
   <div class="three_column margin_r25 vertical_divider" style="text-align:right;">
    <h3>Contatti</h3>
    <img src="images/contatti.png" alt="contatti" />
    <p><strong>Centralino:</strong> 01/54321-5432</p>
    <p><strong>Fax:</strong> 01/2345678</p>
    <p><strong>Indirizzo:</strong> Via Paperopoli 1<br/>12345 Topolinia TO</p>
   </div>
   <div class="three_column" style="text-align:right;">
    <h3>Login</h3>
    <img src="images/login.png" alt="login" />
    <%
      String username =  (String)session.getAttribute("username");
      if(username!=null){
    %>
    <form action="jsp/logout.jsp" method="POST">
     <strong>Benvenuto <% out.println(username); %></strong><br/>
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Logout" />
    </form>
    <%
      }else{
    %>
    <form action="jsp/login.jsp" method="POST">
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
    2011 - Procura di Topolinia
   </div>
  </div>
 </body>
</html>
