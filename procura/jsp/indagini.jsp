<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ include file = "connessione.jsp" %>
<%
  String ruolo = (String)session.getAttribute("ruolo");
  if (ruolo == null) {
   response.sendRedirect("errore.jsp");
  }
%>
<html xmlns="http://www.w3.org/1999/xhtml">
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
  <title>Procura della Repubblica di Milano - Indagini</title>
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
    <li><a href="indagati.jsp"><span></span>Indagati</a></li>
    <li><a href="indagini.jsp" class="current"><span></span>Indagini</a></li>
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
    String grado = request.getParameter("grado");
    String iden = request.getParameter("id");
    String add = request.getParameter("submit");
    if(iden == null){
     if(add !=null ){
      if(add.compareTo("newindagine")==0){
  %>
  <div id="mid_left">
   <fieldset>
    <legend>Nuova indagine</legend>
    <form action="nuovaindagine.jsp" method="POST">
     <table>
      <tr>
       <td>Data inizio:</td>
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
       <td>Indagato:</td>
       <td>
        <select name="indagato">
  <%
      Statement stat = conn.createStatement();
      ResultSet rset = stat.executeQuery("SELECT id, (nome || ' ' || cognome) AS indagato FROM indagato ORDER BY indagato.nome, indagato.cognome;");
      while(rset.next()){
  %>
         <option value='<%=rset.getInt("id")%>'><%=rset.getString("indagato")%></option>
  <%
      }
      stat.close();
  %>
        </select>
       </td>
      </tr>
      <tr>
       <td>Illecito:</td>
       <td>
        <input type="text" name="illecito" />
       </td>
      </tr>
     </table>
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Aggiungi" />
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Annulla" />
    </form>
   </fieldset>
  </div>
  <div id="mid_right">
  <%
      }else{
       response.sendRedirect("errore.jsp");
      }
     }
     Statement stat1 = conn.createStatement();
     ResultSet rset1 = stat1.executeQuery("SELECT id, to_char(datainizio, 'DD-MM-YYYY') AS datainizio, COALESCE(to_char(datafine, 'DD-MM-YYYY'),'indagine in atto') AS datafine, (SELECT count(*) FROM prova WHERE indagine=indagine.id ) AS prove, (SELECT count(*) FROM citazione WHERE indagine=id) AS indagati FROM indagine ORDER BY datainizio DESC;");
     out.println("<table class='contenuti' width='100%'><tr><th>Inizio indagine</th><th>Fine indagine</th><th>Numero prove</th><th>Indagato</th><th>Illecito</th><th>Dettagli</th></tr>");    
     while(rset1.next()){
      out.println("<tr><td rowspan='"+rset1.getInt("indagati")+"'><center>"+rset1.getString("datainizio")+"</center></td>");
      out.println("<td rowspan='"+rset1.getInt("indagati")+"'><center>"+rset1.getString("datafine")+"</center></td>");
      out.println("<td rowspan='"+rset1.getInt("indagati")+"'><center>"+rset1.getInt("prove")+"</center></td>");
      Statement stat2 = conn.createStatement();
      ResultSet rset2 = stat2.executeQuery("SELECT id, (nome || ' ' || cognome || ' nato il ' || to_char(datanascita,'DD-MM-YYYY') || ' a ' || luogonascita ) AS indagato, illecito FROM citazione, indagato WHERE indagine="+rset1.getInt("id")+" AND indagato=id ORDER BY indagato.nome, indagato.cognome;");
      while(rset2.next()){
       if(!rset2.isFirst()){
        out.println("<tr>");
       }
       out.println("<td><a href='indagati.jsp?id="+rset2.getInt("id")+"'>"+rset2.getString("indagato")+"</a></td>");
       out.println("<td>"+rset2.getString("illecito")+"</td>");
       if(rset2.isFirst()){
        out.println("<td rowspan='"+rset1.getInt("indagati")+"'><form action='indagini.jsp?id="+rset1.getInt("id")+"'><center><button type='submit' class='submit_btn' name='id' id='aggiungi' value='"+rset1.getInt("id")+"'>Dettagli</button></center></form></td></tr>");
       }
      }
      stat2.close();
     }
  %>
  </table>
  <%
    if(ruolo.compareTo("pm")==0 || ruolo.compareTo("pg")==0){
  %>
  <table width="100%"><tr><td align="right">
   <form action="indagini.jsp">
    <button type="submit" class="submit_btn" name="submit" id="aggiungi" value="newindagine">Aggiungi</button>
   </form>
  </tr></td>
  <%
    }
  %>
  </table>
  <%
     if(add!=null){
      if(add.compareTo("newindagine")==0){
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
     stat1.close();
    }else{
     Statement stat3 = conn.createStatement();
     ResultSet rset3 = stat3.executeQuery("SELECT to_char(datainizio, 'DD-MM-YYYY') AS datainizio, COALESCE(to_char(datafine, 'DD-MM-YYYY'),'indagine in atto') AS datafine, (SELECT count(*) FROM prova WHERE indagine=indagine.id ) AS prove, (SELECT count(*) FROM citazione WHERE indagine=id) AS indagati FROM indagine WHERE id="+iden+" ORDER BY datainizio DESC;");
     rset3.next();
  %>
  <div id="mid_left">
  <%
    if(rset3.getString("datafine").compareTo("indagine in atto")==0){
     out.println("<img src='../images/lente.png' alt='lente' />");
    }else{
     out.println("<img src='../images/giustizia.png' alt='giustizia' />");
    }
    if(add !=null){
     if(add.compareTo("prova")== 0 && (ruolo.compareTo("pm") == 0) || (ruolo.compareTo("pg") == 0)){
   %>
   <fieldset>
    <legend>Nuova prova</legend>
    <form action="nuovaprova.jsp" method="POST">
     <table>
      <tr>
       <td>Descrizione:</td>
       <td>
        <input type="text" name="descrizione" />
       </td>
      </tr>
      <tr>
      <tr>
       <td>Tipo:</td>
       <td>
        <input type="radio" name="tipo" value="materiale" checked/> Materiale<br />
        <input type="radio" name="tipo" value="digitale" /> Digitale<br />
       </td>
      </tr>
       <td>Identificativo:</td>
       <td>
        <input type="text" name="identificativo" /><br />
        <span class="suggestion">(solo se materiale)</span>
       </td>
      </tr>
      <tr>
       <td>File:</td>
       <td>
       <input type="file" name="file" size="11"><br />
        <span class="suggestion">(solo se digitale)</span>
       </td>
      </tr>
      <tr>
       <td>Formato:</td>
       <td>
        <input type="radio" name="formato" value="documento" checked/> Documento<br />
        <input type="radio" name="formato" value="immagine" /> Immagine<br />
        <input type="radio" name="formato" value="audio" /> Audio<br />
        <input type="radio" name="formato" value="video" /> Video<br />
        <span class="suggestion">(solo se digitale)</span>
       </td>
      </tr>
     </table>
     <input type="hidden" name="id" value="<%=iden%>">
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Aggiungi" />
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Annulla" />
    </form>
   </fieldset>
   <%
     }else if(add.compareTo("fineindagine")==0 && (ruolo.compareTo("pm") == 0) || (ruolo.compareTo("pg") == 0)){
   %>
   <fieldset>
    <legend>Fine indagine</legend>
    <form action="fineindagine.jsp" method="POST">
     <table>
      <tr>
       <td>Data:</td>
       <td>
        <input type="text" name="giorno" size="1"/>
        <select name="mese" onchange="validateDate()">
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
     <input type="hidden" name="id" value="<%=iden%>">
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Aggiungi" />
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Annulla" />
    </form>
   </fieldset>
   <%
     }else if(add.compareTo("inizioprocesso")==0 && ruolo.compareTo("pm") == 0){
      if(grado != null){
   %>
   <fieldset>
    <legend>Inizio processo</legend>
    <form action="iniziaprocesso.jsp" method="POST">
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
      <tr>
       <td>Imputati:</td>
       <td>
  <%
      Statement stat4 = conn.createStatement();
      ResultSet rset4 = stat4.executeQuery("SELECT id, (nome || ' ' || cognome) AS indagato FROM citazione, indagato WHERE indagine="+iden+" AND citazione.indagato=id ORDER BY indagato.nome, indagato.cognome;");
      while(rset4.next()){
  %>
         <input type="checkbox" name="imputato" value="<%=rset4.getInt("id")%>" /> <%=rset4.getString("indagato")%><br/>
  <%
      }
      stat4.close();
  %>
       </td>
      </tr>
     </table>
     <input type="hidden" name="grado" value="<%=grado%>">
     <input type="hidden" name="id" value="<%=iden%>">
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Aggiungi" />
     <input type="submit" class="submit_btn" name="submit" id="submit" value="Annulla" />
    </form>
   </fieldset>
   <%
      }
     }else if(add.compareTo("aggiungiindagato")==0 && (ruolo.compareTo("pm") == 0) || (ruolo.compareTo("pg") == 0)){
   %>
   <fieldset>
    <legend>Nuovo indagato</legend>
    <form action="aggiungiindagato.jsp" method="POST">
     <table>
      <tr>
       <td>Indagato:</td>
       <td>
        <select name="indagato">
  <%
      Statement stat5 = conn.createStatement();
      ResultSet rset5 = stat5.executeQuery("SELECT id, (nome || ' ' || cognome) AS indagato FROM indagato WHERE id NOT IN (SELECT indagato FROM citazione WHERE indagine="+iden+");");
      while(rset5.next()){
  %>
         <option value='<%=rset5.getInt("id")%>'><%=rset5.getString("indagato")%></option>
  <%
      }
      stat5.close();
  %>
        </select>
       </td>
      </tr>
      <tr>
       <td>Illecito:</td>
       <td>
        <input type="text" name="illecito" />
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
   <h4><span style="color:#1a89de">Data inizio: </span><%out.println(rset3.getString("datainizio"));%></h4>
   <h4><span style="color:#1a89de">Data fine: </span><%out.println(rset3.getString("datafine"));%></h4>
  <%
     String fineindagine = rset3.getString("datafine");
     if(((ruolo.compareTo("pm") == 0) || (ruolo.compareTo("pg") == 0)) && rset3.getInt("prove")>0 && fineindagine.compareTo("indagine in atto")==0){
  %>
     <table width="100%">
     <tr>
      <td align="right"><form action="indagini.jsp">
        <input type="hidden" name="id" value="<%=iden%>">
        <button type="submit" class="submit_btn" name="submit" id="aggiungi" value="fineindagine">Concludi l'indagine</button>
      </form></td>
     </tr>
     </table>
  <%
     }
     stat3.close();
     Statement stat6 = conn.createStatement();
     ResultSet rset6 = stat6.executeQuery("SELECT id, (nome || ' ' || cognome || ' nato il ' || to_char(datanascita,'DD-MM-YYYY') || ' a ' || luogonascita ) AS anagrafici, residenza, genere FROM citazione, indagato WHERE indagine="+iden+" AND indagato=id ORDER BY indagato.nome, indagato.cognome;");
     out.println("<h4><span style='color:#1a89de'>Indagati: </span></h4><table class='contenuti' width='100%'>");
     out.println("<tr><th>Indagato</th><th>Residenza</th><th>Genere</th></tr>"); 
     while(rset6.next()){      
      out.println("<tr><td><a href='indagati.jsp?id="+rset6.getInt("id")+"'>"+rset6.getString("anagrafici")+"</a></td>");
      out.println("<td><center>"+rset6.getString("residenza")+"</center></td>");
      if(rset6.getString("genere").compareTo("m")==0){
       out.println("<td style='color:blue;'><center><img src='../images/smallmale.png' alt='male' /></center></td></tr>");
      }else{
       out.println("<td style='color:red;'><center><img src='../images/smallfemale.png' alt='female' /></center></td></tr>");
      }
     }
     out.println("</table>");      
     stat6.close();
     if((ruolo.compareTo("pm") == 0) || (ruolo.compareTo("pg") == 0)){
  %>
     <table width="100%">
     <tr>
      <td align="right"><form action="indagini.jsp">
        <input type="hidden" name="id" value="<%=iden%>">
        <button type="submit" class="submit_btn" name="submit" id="aggiungi" value="aggiungiindagato">Aggiungi indagato</button>
      </form></td>
     </tr>
     </table>
  <%
     }
     Statement stat7 = conn.createStatement();
     ResultSet rset7 = stat7.executeQuery("SELECT id, descrizione, tipo, identificativo, formato FROM prova WHERE indagine="+iden+";");
     if(rset7.next()){
      out.println("<br /><h4><span style='color:#1a89de'>Prove: </span></h4><table class='contenuti' width='100%'>");
      out.println("<tr><th>Descrizione</th><th>Tipo</th><th>Identificativo</th><th>Download</th></tr>");
      out.println("<tr><td>"+rset7.getString("descrizione")+"</td>");
      out.println("<td><center>"+rset7.getString("tipo")+"</center></td>");
      if(rset7.getString("tipo")!=null){
       if(rset7.getString("tipo").compareTo("materiale")==0){
        out.println("<td>"+rset7.getString("identificativo")+"</td><td></td></tr>");
       }else{
        if(rset7.getString("formato")!=null){
         if(rset7.getString("formato").compareTo("documento")==0){
          out.println("<td><center><img src='../images/documento.png' alt='documento' /></center></td></tr>");
         }else if(rset7.getString("formato").compareTo("immagine")==0){
          out.println("<td><center><img src='../images/immagine.png' alt='immagine' /></center></td></tr>");
         }else if(rset7.getString("formato").compareTo("audio")==0){
          out.println("<td><center><img src='../images/audio.png' alt='audio' /></center></td></tr>");
         }else if(rset7.getString("formato").compareTo("video")==0){
          out.println("<td></td><td><center><img src='../images/video.png' alt='video' /></center></td></tr>");
         }
        }
       }
      }
      while(rset7.next()){    
       out.println("<tr><td>"+rset7.getString("descrizione")+"</td>");
       out.println("<td><center>"+rset7.getString("tipo")+"</center></td>");
       if(rset7.getString("tipo")!=null){
        if(rset7.getString("tipo").compareTo("materiale")==0){
         out.println("<td>"+rset7.getString("identificativo")+"</td>");
        }else{
         if(rset7.getString("formato")!=null){
          if(rset7.getString("formato").compareTo("documento")==0){
           out.println("<td><center><img src='../images/documento.png' alt='documento' /></center></td></tr>");
          }else if(rset7.getString("formato").compareTo("immagine")==0){
           out.println("<td><center><img src='../images/immagine.png' alt='immagine' /></center></td></tr>");
          }else if(rset7.getString("formato").compareTo("audio")==0){
           out.println("<td><center><img src='../images/audio.png' alt='audio' /></center></td></tr>");
          }else if(rset7.getString("formato").compareTo("video")==0){
           out.println("<td><center><img src='../images/video.png' alt='video' /></center></td></tr>");
          }
         }
        }
       }
      }
      out.println("</table>");  
     }
     stat7.close();
     if((ruolo.compareTo("pm") == 0) || (ruolo.compareTo("pg") == 0)){
  %>
     <table width="100%">
     <tr>
      <td align="right"><form action="indagini.jsp">
        <input type="hidden" name="id" value="<%=iden%>">
        <button type="submit" class="submit_btn" name="submit" id="aggiungi" value="prova">Aggiungi prova</button>
      </form></td>
     </tr>
     </table>
  <%
     }
     Statement stat8 = conn.createStatement();
     String ultimogrado = new String();
     Boolean fineprocesso = true;
     ResultSet rset8 = stat8.executeQuery("SELECT gradogiudizio, to_char(datainizio, 'DD-MM-YYYY') AS datainizio, COALESCE(to_char(datafine, 'DD-MM-YYYY'),'non concluso') AS datafine FROM processo WHERE indagine="+iden+";");
     if(rset8.next()){
      out.println("<br /><h4><span style='color:#1a89de'>Processi: </span></h4><table class='contenuti' width='100%'>");
      out.println("<tr><th>Grado di giudizio</th><th>Data inizio</th><th>Data fine</th></tr>"); 
      out.println("<tr><td>"+rset8.getString("gradogiudizio")+"</td>");
      out.println("<td>"+rset8.getString("datainizio")+"</td>");
      out.println("<td>"+rset8.getString("datafine")+"</td></tr>");
      ultimogrado=rset8.getString("gradogiudizio");
      fineprocesso=(rset8.getString("datafine").compareTo("non concluso")!=0);
      while(rset8.next()){
       out.println("<tr><td>"+rset8.getString("gradogiudizio")+"</td>");
       out.println("<td>"+rset8.getString("datainizio")+"</td>");
       out.println("<td>"+rset8.getString("datafine")+"</td></tr>");
       ultimogrado=rset8.getString("gradogiudizio");
      fineprocesso=(rset8.getString("datafine").compareTo("non concluso")!=0);
      }
      out.println("</table>");
     }
     stat8.close();
     if(ruolo.compareTo("pm") == 0){
      if(ultimogrado.compareTo("")==0 && fineindagine.compareTo("indagine in atto")!=0){
  %>
     <table width="100%">
     <tr>
      <td align="right"><form action="indagini.jsp">
        <input type="hidden" name="id" value="<%=iden%>">
        <input type="hidden" name="grado" value="Primo grado">
        <button type="submit" class="submit_btn" name="submit" id="aggiungi" value="inizioprocesso">Aggiungi processo di primo grado</button>
      </form></td>
     </tr>
     </table>
  <%
      }else{
       if(ultimogrado.compareTo("Primo grado")==0 && fineprocesso){
  %>
     <table width="100%">
     <tr>
      <td align="right"><form action="indagini.jsp">
        <input type="hidden" name="id" value="<%=iden%>">
        <input type="hidden" name="grado" value="Appello">
        <button type="submit" class="submit_btn" name="submit" id="aggiungi" value="inizioprocesso">Aggiungi processo di appello</button>
      </form></td>
     </tr>
     </table>
  <%
       }else if(ultimogrado.compareTo("Appello")==0 && fineprocesso){
  %>
     <table width="100%">
     <tr>
      <td align="right"><form action="indagini.jsp">
        <input type="hidden" name="id" value="<%=iden%>">
        <input type="hidden" name="grado" value="Cassazione">
        <button type="submit" class="submit_btn" name="submit" id="aggiungi" value="inizioprocesso">Aggiungi processo di cassazione</button>
      </form></td>
     </tr>
     </table>
  <%
       }
      }
     }
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
