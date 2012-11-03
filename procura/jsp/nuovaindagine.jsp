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
  String giorno = request.getParameter("giorno");
  String mese = request.getParameter("mese");
  String anno = request.getParameter("anno");
  String indagato = request.getParameter("indagato");
  String illecito = request.getParameter("illecito");
  String submit = request.getParameter("submit");
  
  if (giorno == null || mese == null || anno == null || indagato == null || illecito == null || submit==null) {
   response.sendRedirect("errore.jsp");
  }else{
   if (!(giorno.compareTo("")==0 || mese.compareTo("")==0 || anno.compareTo("")==0 || indagato.compareTo("")==0 || illecito.compareTo("")==0 || submit.compareTo("Aggiungi")!=0)) {
    Connection conn = open_conn("procura");
    Statement stat = conn.createStatement();
    ResultSet rset = stat.executeQuery("SELECT nuovaindagine(date '"+anno+"-"+mese+"-"+giorno+"') AS id;");
    rset.next();
    int indagine = rset.getInt("id");
    stat.close();
    Statement stat1 = conn.createStatement();
    stat1.executeUpdate("INSERT INTO citazione VALUES ("+indagato+","+indagine+",'"+illecito+"');");
    stat1.close();
    conn.close();
   }
   response.sendRedirect("indagini.jsp");
  }
%>
