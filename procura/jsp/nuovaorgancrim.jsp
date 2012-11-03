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
  String organizzazione = request.getParameter("organizzazione");
  String submit = request.getParameter("submit");
  String ginizio = request.getParameter("ginizio");
  String minizio = request.getParameter("minizio");
  String ainizio = request.getParameter("ainizio");
  String gfine = request.getParameter("gfine");
  String mfine = request.getParameter("mfine");
  String afine = request.getParameter("afine");
  
  if (organizzazione == null || submit == null || id == null || ginizio == null || minizio == null || ainizio == null || gfine == null || mfine == null || afine == null) {
   response.sendRedirect("errore.jsp");
  }else{
   if (!(organizzazione.compareTo("")==0 || submit.compareTo("Aggiungi")!=0 || ginizio.compareTo("")==0 || minizio.compareTo("")==0 || ainizio.compareTo("")==0)) {
    Connection conn = open_conn("procura");
    Statement stat = conn.createStatement();
    ResultSet rset = stat.executeQuery("SELECT * FROM indagato WHERE id="+id+";");
    if(!rset.next()){
     stat.close();
     response.sendRedirect("errore.jsp");
    }
    stat.close();
    Statement stat1 = conn.createStatement();
    ResultSet rset1 = stat1.executeQuery("SELECT * FROM organizzazionecriminale WHERE nome='"+organizzazione+"';");
    if(!rset1.next()){
     Statement stat2 = conn.createStatement();
     stat2.executeUpdate("INSERT INTO organizzazionecriminale VALUES ('"+organizzazione+"');");
     stat2.close();
    }
    stat1.close();
    Statement stat3 = conn.createStatement();
    ResultSet rset3 = stat3.executeQuery("SELECT * FROM appartenenza WHERE imputato="+id+" AND organizzazionecriminale='"+organizzazione+"';");
    if(!rset3.next()){
     Statement stat4 = conn.createStatement();
     if(gfine.compareTo("")==0 || mfine.compareTo("")==0 || afine.compareTo("")==0){
      stat4.executeUpdate("INSERT INTO appartenenza VALUES ("+id+",'"+organizzazione+"',date '"+ainizio+"-"+minizio+"-"+ginizio+"');");
     }else{
      stat4.executeUpdate("INSERT INTO appartenenza VALUES ("+id+",'"+organizzazione+"',date '"+ainizio+"-"+minizio+"-"+ginizio+"',date '"+afine+"-"+mfine+"-"+gfine+"');");
     }
     stat4.close();
    }
    stat3.close();
    conn.close();
   }
   response.sendRedirect("indagati.jsp?id="+id);
  }
%>
