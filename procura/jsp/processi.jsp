<%@ include file = "connessione.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
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
    <li><a href="processi.jsp" class="current"><span></span>Processi</a></li>
    <%
      String ruolo =  (String)session.getAttribute("ruolo");
      if(ruolo!=null){
       if(ruolo.compareTo("pm")==0 || ruolo.compareTo("pg")==0 || ruolo.compareTo("am")==0){
    %>
    <li><a href="indagati.jsp"><span></span>Indagati</a></li>
    <li><a href="indagini.jsp"><span></span>Indagini</a></li>
    <% 
       }
       if(ruolo.compareTo("am")==0){
    %>
    <li><a href="admin.jsp"><span></span>Admin</a></li>
    <% 
       }
      }
    %>
   </ul>    	
  </div>
 </div>
 
 <div id="templatemo_middle">
 <%
   String proc = request.getParameter("processo");
   String impu = request.getParameter("imputato");    
   if(ruolo!=null){
    if(ruolo.compareTo("pm")==0){ 
     if(proc !=null && impu ==null){
 %>
  <div id="mid_left">
   <fieldset>
    <legend>Fine processo</legend>
    <form action="fineprocesso.jsp" method="POST">
     <table>
      <tr>
       <td>Data:</td>
       <td>
        <input type="text" name="giorno" size="1"/>
        <select name="mese">
         <option value="1">Gennaio</option>
         <option value="2">Febbraio</option>
         <option value="3">Marzo</option>
         <option value="4">Aprile</option>
         <option value="5">Maggio</option>
         <option value="6">Giugno</option>
         <option value="7">Luglio</option>
         <option value="8">Agosto</option>
         <option value="9">Settembre</option>
         <option value="10">Ottobre</option>
         <option value="11">Novembre</option>
         <option value="12">Dicembre</option>
        </select>
        <input type="text" name="anno" size="3"/><br/>
        <span class="suggestion">(giorno mese anno)</span>
       </td>
      </tr>
     </table>
     <input type="hidden" name="processo" value="<%=proc%>">
     <input type="submit" class="submit_btn" name="submit" id="aggiungi" value="Aggiungi" />
     <input type="submit" class="submit_btn" name="submit" id="annulla" value="Annulla" />
    </form>
   </fieldset>
  </div>
  <div id="mid_right">
 <%
     }
     if(proc !=null && impu !=null){
 %>
  <div id="mid_left">
   <fieldset>
    <legend>Esito processo</legend>
    <form action="esito.jsp" method="POST">
     <table>
      <tr>
       <td>Esito:</td>
       <td>
        <input type="radio" name="esito" value="condanna" checked/> Condannato<br />
        <input type="radio" name="esito" value="proscioglimento" /> Prosciolto
       </td>
      </tr>
      <tr>
       <td>Commento:</td>
       <td>
        <input type="text" name="commento" /><br/>
        <span class="suggestion">(entit&agrave; condanna o motivo proscioglimento)</span>
       </td>
      </tr>
     </table>
     <input type="hidden" name="processo" value="<%=proc%>">
     <input type="hidden" name="imputato" value="<%=impu%>">
     <input type="submit" class="submit_btn" name="submit" id="aggiungi" value="Aggiungi" />
     <input type="submit" class="submit_btn" name="submit" id="annulla" value="Annulla" />
    </form>
   </fieldset>
  </div>
  <div id="mid_right">
  <%
      }
     }
    }
    Connection conn = open_conn("procura");
    Statement stat = conn.createStatement();
    ResultSet rset = stat.executeQuery("SELECT id, (SELECT count(*) FROM carico WHERE processo=id) AS imputati, gradogiudizio, to_char(datainizio, 'DD/MM/YYYY') AS datainizio, COALESCE(to_char(datafine, 'DD/MM/YYYY'),'non concluso') AS datafine, concluso FROM processo ORDER BY processo.datainizio DESC;");
    out.println("<table class='contenuti' width='100%'><tr><th>Grado di giudizio</th><th>Data inizio</th><th>Data fine</th><th>Imputato</th><th>Capo di imputazione</th><th>Esito</th></tr>");
    while(rset.next()){
     out.println("<td rowspan='"+rset.getInt("imputati")+"'><center>"+rset.getString("gradogiudizio")+"</center></td>");
     out.println("<td rowspan='"+rset.getInt("imputati")+"'><center>"+rset.getString("datainizio")+"</center></td>");
     if(ruolo!=null){
      if(ruolo.compareTo("pm")==0 && rset.getString("datafine").compareTo("non concluso")==0 && rset.getBoolean("concluso")){
       out.println("<td rowspan='"+rset.getInt("imputati")+"'><form action='processi.jsp' method='POST'><center>");
       out.println("<button type='submit' class='submit_btn' name='processo' value='"+rset.getString("id")+"'>Aggiungi</button>");
       out.println("</center></form></td>");
      }else{
       out.println("<td rowspan='"+rset.getInt("imputati")+"'><center>"+rset.getString("datafine")+"</center></td>");
      }
     }else{
      out.println("<td rowspan='"+rset.getInt("imputati")+"'><center>"+rset.getString("datafine")+"</center></td>");
     }
     Statement stat1 = conn.createStatement();
     ResultSet rset1 = stat1.executeQuery("SELECT id, capoimputazione, (nome || ' ' || cognome) AS imputato, COALESCE((SELECT ('condanna a ' || entita) FROM condanna WHERE processo="+rset.getInt("id")+" AND imputato=id),(SELECT ('proscioglimento per ' || motivo) FROM proscioglimento WHERE processo="+rset.getInt("id")+" AND imputato=id),'nessun esito') AS esito FROM carico, indagato WHERE processo="+rset.getInt("id")+" AND carico.imputato=indagato.id ORDER BY indagato.nome, indagato.cognome;");

     while(rset1.next()){
      if(!rset1.isFirst()){
       out.println("<tr>");
      }
      if(ruolo!=null){
       if(ruolo.compareTo("pg")==0 || ruolo.compareTo("pm")==0 || ruolo.compareTo("am")==0){
        out.println("<td><a href='indagati.jsp?id="+rset1.getInt("id")+"'>"+rset1.getString("imputato")+"</a></td>");
       }
      }else{
       out.println("<td>"+rset1.getString("imputato")+"</td>");
      }
      out.println("<td>"+rset1.getString("capoimputazione")+"</td>");      
      if(ruolo!=null){
       if(ruolo.compareTo("pm")==0 && rset1.getString("esito").compareTo("nessun esito")==0 ){
        out.println("<td><form action='processi.jsp' method='POST'><center>");
        out.println("<input type='hidden' name='processo' value='"+rset.getString("id")+"'>");
        out.println("<input type='hidden' name='imputato' value='"+rset1.getString("id")+"'>");
        out.println("<input type='submit' class='submit_btn' name='submit' id='submit' value='Aggiungi' />");
        out.println("</center></form></td></tr>");
       }else{
        out.println("<td>"+rset1.getString("esito")+"</td></tr>");
       }
      }else{
       out.println("<td>"+rset1.getString("esito")+"</td></tr>");
      }
     }
     stat1.close();
    }
    out.println("</table>");
    stat.close();
    conn.close();
 
    if(ruolo!=null){
     if(ruolo.compareTo("pm")==0){
      if(proc !=null){
       out.println("</div>");
      }
     }
    }
  %>

  <div id="mid_left">
  </div>
  <div id="mid_right">
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
