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
  String incarico = request.getParameter("incarico");
  String submit = request.getParameter("submit");
  
  if (incarico == null || submit == null || id == null) {
   response.sendRedirect("errore.jsp");
  }else{
   if (!(incarico.compareTo("")==0 || submit.compareTo("Aggiungi")!=0)) {
    Connection conn = open_conn("procura");
    Statement stat = conn.createStatement();
    ResultSet rset = stat.executeQuery("SELECT * FROM indagato WHERE id="+id+";");
    if(!rset.next()){
     stat.close();
     response.sendRedirect("errore.jsp");
    }
    stat.close();
    Statement stat1 = conn.createStatement();
    ResultSet rset1 = stat1.executeQuery("SELECT * FROM incaricopa WHERE nome='"+incarico+"';");
    if(!rset1.next()){
     Statement stat2 = conn.createStatement();
     stat2.executeUpdate("INSERT INTO incaricopa VALUES ('"+incarico+"');");
     stat2.close();
    }
    stat1.close();
    Statement stat3 = conn.createStatement();
    ResultSet rset3 = stat3.executeQuery("SELECT * FROM copertura WHERE indagato="+id+" AND incaricopa='"+incarico+"';");
    if(!rset3.next()){
     Statement stat4 = conn.createStatement();
     stat4.executeUpdate("INSERT INTO copertura VALUES ("+id+",'"+incarico+"');");
     stat4.close();
    }
    stat3.close();

    conn.close();
   }
   response.sendRedirect("indagati.jsp?id="+id);
  }
%>
