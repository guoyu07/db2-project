<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ include file = "connessione.jsp" %>
<%
  String ruolo = (String)session.getAttribute("ruolo");
  if (ruolo == null) {
   response.sendRedirect("errore.jsp");
  }else{
   if (ruolo.compareTo("am") != 0 && ruolo.compareTo("pm") != 0 && ruolo.compareTo("pg") != 0){
    response.sendRedirect("errore.jsp");
   }
  }
%>
<html xmlns="http://www.w3.org/1999/xhtml">
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
  <title>Procura della Repubblica di Milano - Indagati</title>
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
    <%
      if(ruolo!=null){
       if(ruolo.compareTo("pm")==0 || ruolo.compareTo("pg")==0 || ruolo.compareTo("am")==0){
    %>
    <li><a href="indagati.jsp" class="current"><span></span>Indagati</a></li>
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
    Connection conn = open_conn("procura");
    String iden = request.getParameter("id");
    String add = request.getParameter("submit");
    if(iden == null){
     if(add !=null ){
      if(add.compareTo("newindagato")==0){
  %>
  <div id="mid_left">
   <fieldset>
    <legend>Nuovo indagato</legend>
    <form action="nuovoindagato.jsp" method="POST">
     <table>
      <tr>
       <td>Nome:</td>
       <td>
        <input type="text" name="nome" />
       </td>
      </tr>
      <tr>
       <td>Cognome:</td>
       <td>
        <input type="text" name="cognome" />
       </td>
      </tr>
      <tr>
       <td>Data nascita:</td>
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
      <tr>
       <td>Luogo nascita:</td>
       <td>
        <input type="text" name="luogo" />
       </td>
      </tr>
      <tr>
       <td>Residenza:</td>
       <td>
        <input type="text" name="residenza" />
       </td>
      </tr>
      <tr>
       <td>Genere:</td>
       <td>
        <input type="radio" name="genere" value="m" checked/> Uomo<br />
        <input type="radio" name="genere" value="f" /> Donna<br />
       </td>
      </tr>
     </table>
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Aggiungi" />
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Annulla" />
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
      }else{
       response.sendRedirect("errore.jsp");
      }
     }
     Statement stat = conn.createStatement();
     ResultSet rset = stat.executeQuery("SELECT id, (nome || ' ' || cognome || ' nato il ' || to_char(datanascita,'DD-MM-YYYY') || ' a ' || luogonascita ) AS anagrafici, residenza, genere, (SELECT count(*) FROM appartenenza WHERE imputato=id) AS organizzazioni FROM indagato ORDER BY indagato.nome, indagato.cognome;");
     out.println("<table class='contenuti' width='100%'><tr><th>Indagato</th><th>Residenza</th><th>Genere</th><th>Incarico Pubblico Amministrativo</th><th>Organizzazione criminale</th><th>Inizio afferenza</th><th>Fine afferenza</th></tr>");    
     while(rset.next()){
      int organizzazioni = rset.getInt("organizzazioni");
      int span = 1;
      if(organizzazioni>1){
       span=organizzazioni;
      }
      out.println("<tr><td rowspan='"+span+"'><a href='indagati.jsp?id="+rset.getInt("id")+"'>"+rset.getString("anagrafici")+"</a></td>");
      out.println("<td rowspan='"+span+"'>"+rset.getString("residenza")+"</td>");
      if(rset.getString("genere").compareTo("m")==0){
       out.println("<td rowspan='"+span+"' style='color:blue;'><center><img src='../images/smallmale.png' alt='male' /></center></td>");
      }else{
       out.println("<td rowspan='"+span+"' style='color:red;'><center><img src='../images/smallfemale.png' alt='female' /></center></td>");
      }
      Statement stat1 = conn.createStatement();
      ResultSet rset1 = stat1.executeQuery("SELECT incaricopa FROM copertura WHERE indagato="+rset.getInt("id")+";");
      String incarichi = "";
      while(rset1.next()){
       incarichi = incarichi + rset1.getString("incaricopa") + "<br />";
      }     
      out.println("<td rowspan='"+span+"'>"+incarichi+"</td>");
      stat1.close();
      if(organizzazioni>0){
       Statement stat2 = conn.createStatement();
       ResultSet rset2 = stat2.executeQuery("SELECT organizzazionecriminale, to_char(inizio,'DD-MM-YYYY') AS inizio, COALESCE(to_char(fine,'DD-MM-YYYY'),'afferente tuttora') AS fine FROM appartenenza WHERE imputato="+rset.getInt("id")+";");
       while(rset2.next()){
        if(!rset2.isFirst()){
         out.println("<tr>");
        }
        out.println("<td>"+rset2.getString("organizzazionecriminale")+"</td>");
        out.println("<td><center>"+rset2.getString("inizio")+"</center></td>");
        out.println("<td><center>"+rset2.getString("fine")+"</center></td></tr>");
       }
       stat2.close();
      }else{
      out.println("<td colspan='3'>non afferisce ad alcuna organizzazione criminale</td></tr>");
      }
     }
  %>
  </table>
  <%
    if(ruolo.compareTo("pm")==0 || ruolo.compareTo("pg")==0){
  %>
  <table width="100%"><tr><td align="right">
   <form action="indagati.jsp">
    <button type="submit" class="submit_btn" name="submit" id="aggiungi" value="newindagato">Aggiungi</button>
   </form>
  </tr></td>
  <%
    }
  %>
  </table>
  <%
     if(add!=null){
      if(add.compareTo("newindagato")==0){
  %>
  </div>
  <%
      }
     }else{
  %>
  <div id="mid_left"></div>
  <div id="mid_right"></div>
  <%
     }
     stat.close();
    }else{
     Statement stat3 = conn.createStatement();
     ResultSet rset3 = stat3.executeQuery("SELECT nome, cognome, to_char(datanascita,'DD-MM-YYYY') AS datanascita, luogonascita, residenza, genere FROM indagato WHERE id="+iden+";");
     rset3.next();
  %>
  <div id="mid_left">
  <%
    if(rset3.getString("genere").compareTo("m")==0){
     out.println("<img src='../images/male.png' alt='male' />");
    }else{
     out.println("<img src='../images/female.png' alt='female' />");
    }
    if(add !=null){
     if(add.compareTo("incaricopa")== 0 && (ruolo.compareTo("pm") == 0) || (ruolo.compareTo("pg") == 0)){
   %>
   <fieldset>
    <legend>Nuovo incarico</legend>
    <form action="nuovoincaricopa.jsp" method="POST">
     <table>
      <tr>
       <td>Incarico:</td>
       <td>
        <input type="text" name="incarico" />
       </td>
      </tr>
     </table>
     <input type="hidden" name="id" value="<%=iden%>">
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Aggiungi" />
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Annulla" />
    </form>
   </fieldset>
   <%
     }else if(add.compareTo("organcrim")==0 && (ruolo.compareTo("pm") == 0) || (ruolo.compareTo("pg") == 0)){
   %>
   <fieldset>
    <legend>Nuova organizzazione</legend>
    <form action="nuovaorgancrim.jsp" method="POST">
     <table>
      <tr>
       <td>Organizzazione:</td>
       <td>
        <input type="text" name="organizzazione" />
       </td>
      </tr>
      <tr>
       <td>Inizio:</td>
       <td>
        <input type="text" name="ginizio" size="1"/>
        <select name="minizio">
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
        <input type="text" name="ainizio" size="3"/><br/>
        <span class="suggestion">(giorno mese anno)</span>
       </td>
      </tr>
      <tr>
       <td>Fine:</td>
       <td>
        <input type="text" name="gfine" size="1"/>
        <select name="mfine">
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
        <input type="text" name="afine" size="3"/><br/>
        <span class="suggestion">(giorno mese anno)</span>
       </td>
      </tr>
     </table>
     <input type="hidden" name="id" value="<%=iden%>">
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Aggiungi" />
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Annulla" />
    </form>
   </fieldset>
   <%
     }
    }
  %>
  </div>
  <div id="mid_right">
   <h2><%out.println(rset3.getString("cognome"));out.println(" ");out.println(rset3.getString("nome"));%><h2>
   <h4><span style="color:#1a89de">Data di nascita: </span><%out.println(rset3.getString("datanascita"));%></h4>
   <h4><span style="color:#1a89de">Luogo di nascita: </span><%out.println(rset3.getString("luogonascita"));%></h4>
   <h4><span style="color:#1a89de">Residenza: </span><%out.println(rset3.getString("residenza"));%></h4>
  <%     
     stat3.close();
     Statement stat4 = conn.createStatement();
     ResultSet rset4 = stat4.executeQuery("SELECT incaricopa FROM copertura WHERE indagato="+iden+";");
     if(rset4.next()){
   %>
     <table width="100%">
     <tr>
      <td><h4><span style="color:#1a89de">Incarichi Pubblico-Amministrativi: </span></h4></td>
   <%
     if((ruolo.compareTo("pm") == 0) || (ruolo.compareTo("pg") == 0)){
   %>
      <td align="right"><form action="indagati.jsp">
        <input type="hidden" name="id" value="<%=iden%>">
        <button type="submit" class="submit_btn" name="submit" id="aggiungi" value="incaricopa">Aggiungi</button>
      </form></td>
   <%
     }
   %>
     </tr>
     </table>
     <table width="100%"> 
   <% 
      out.println("<tr><td align='right'><h4>"+rset4.getString("incaricopa")+"</h4></td></tr>");
      while(rset4.next()){      
       out.println("<tr><td align='right'><h4>"+rset4.getString("incaricopa")+"</h4></td></tr>");
      }
      out.println("</table>");      
     }else{
      if((ruolo.compareTo("pm") == 0) || (ruolo.compareTo("pg") == 0)){
   %>
      <table width="100%">
       <td align="right"><form action="indagati.jsp">
        <input type="hidden" name="id" value="<%=iden%>">
        <button type="submit" class="submit_btn" name="submit" id="aggiungi" value="incaricopa">Aggiungi incarichi pubblico-amministrativi</button>
      </form></td></table>
   <%
      }
     }
     stat4.close();
     Statement stat5 = conn.createStatement();
     ResultSet rset5 = stat5.executeQuery("SELECT organizzazionecriminale, to_char(inizio,'DD-MM-YYYY') AS inizio, COALESCE(to_char(fine,'DD-MM-YYYY'),'afferente tuttora') AS fine FROM appartenenza WHERE imputato="+iden+";");
     if(rset5.next()){
   %>
     <table width="100%">
     <tr>
      <td><h4><span style="color:#1a89de">Organizzazioni criminali: </span></h4></td>
   <%
     if((ruolo.compareTo("pm") == 0) || (ruolo.compareTo("pg") == 0)){
   %>
      <td align="right"><form action="indagati.jsp">
        <input type="hidden" name="id" value="<%=iden%>">
        <button type="submit" class="submit_btn" name="submit" id="aggiungi" value="organcrim">Aggiungi</button>
      </form></td>
   <%
     }
   %>
     </tr>
     </table>
     <table class="contenuti" width="100%"> 
   <%    
      out.println("<tr><th>Organizzazione criminale</th><th>Inizio afferenza</th><th>Fine afferenza</th></tr>");      
      out.println("<tr><td>"+rset5.getString("organizzazionecriminale")+"</td>");
      out.println("<td><center>"+rset5.getString("inizio")+"</center></td>");
      out.println("<td><center>"+rset5.getString("fine")+"</center></td></tr>");
      while(rset5.next()){      
       out.println("<tr><td>"+rset5.getString("organizzazionecriminale")+"</td>");
       out.println("<td><center>"+rset5.getString("inizio")+"</center></td>");
       out.println("<td><center>"+rset5.getString("fine")+"</center></td></tr>");
      }
      out.println("</table>");      
     }else{
      if((ruolo.compareTo("pm") == 0) || (ruolo.compareTo("pg") == 0)){
   %>
      <table width="100%">
       <td align="right"><form action="indagati.jsp">
        <input type="hidden" name="id" value="<%=iden%>">
        <button type="submit" class="submit_btn" name="submit" id="aggiungi" value="organcrim">Aggiungi organizzazione criminale</button>
      </form></td></table>
   <%
      }
     }     
     stat5.close();
     Statement stat6 = conn.createStatement();
     ResultSet rset6 = stat6.executeQuery("SELECT id, illecito, to_char(datainizio,'DD-MM-YYYY') AS inizio, COALESCE(to_char(datafine,'DD-MM-YYYY'), 'non terminata') AS fine FROM citazione, indagine WHERE indagato="+iden+" AND indagine=id;");
     if(rset6.next()){
      out.println("<br/><h4><span style='color:#1a89de'>Indagini: </span></h4><table class='contenuti' width='100%'>");
      out.println("<tr><th>Illecito</th><th>Data inizio</th><th>Data fine</th></tr>");      
      out.println("<tr><td><a href='indagini.jsp?id="+rset6.getString("id")+"'>"+rset6.getString("illecito")+"</a></td>");
      out.println("<td><center>"+rset6.getString("inizio")+"</center></td>");
      out.println("<td><center>"+rset6.getString("fine")+"</center></td></tr>");
      while(rset6.next()){      
       out.println("<tr><td><a href='indagini.jsp?id="+rset6.getString("id")+"'>"+rset6.getString("illecito")+"</a></td>");
       out.println("<td><center>"+rset6.getString("inizio")+"</center></td>");
       out.println("<td><center>"+rset6.getString("fine")+"</center></td></tr>");
      }
      out.println("</table>");      
     }
     stat6.close();
     Statement stat7 = conn.createStatement();
     ResultSet rset7 = stat7.executeQuery("SELECT gradogiudizio, to_char(datainizio,'DD-MM-YYYY') AS inizio, COALESCE(to_char(datafine, 'DD/MM/YYYY'),'non concluso') AS fine, capoimputazione, COALESCE((SELECT ('condanna a ' || entita) FROM condanna WHERE processo=id AND imputato="+iden+"), (SELECT ('proscioglimento per ' || motivo) FROM proscioglimento WHERE processo=id AND imputato="+iden+"),'nessun esito') AS esito FROM carico, processo WHERE imputato="+iden+" AND carico.processo=processo.id ORDER BY processo.datainizio DESC;");
     if(rset7.next()){
      out.println("<br /><h4><span style='color:#1a89de'>Processi: </span></h4><table class='contenuti' width='100%'>");
      out.println("<tr><th>Grado di giudizio</th><th>Data inizio</th><th>Data fine</th><th>Capo di imputazione</th><th>Esito</th></tr>");      
      out.println("<tr><td><center>"+rset7.getString("gradogiudizio")+"</center></td>");
      out.println("<td><center>"+rset7.getString("inizio")+"</center></td>");
      out.println("<td><center>"+rset7.getString("fine")+"</center></td>");
      out.println("<td>"+rset7.getString("capoimputazione")+"</td>");
      out.println("<td>"+rset7.getString("esito")+"</td></tr>");
      while(rset7.next()){      
       out.println("<tr><td><center>"+rset7.getString("gradogiudizio")+"</center></td>");
       out.println("<td><center>"+rset7.getString("inizio")+"</center></td>");
       out.println("<td><center>"+rset7.getString("fine")+"</center></td>");
       out.println("<td>"+rset7.getString("capoimputazione")+"</td>");
       out.println("<td>"+rset7.getString("esito")+"</td></tr>");
      }
      out.println("</table>");      
     }
     stat7.close();
    }
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
