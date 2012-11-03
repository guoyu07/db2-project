<%@ include file = "connessione.jsp" %>
<%@ page language="java" import="java.io.*" %>
<%
  String ruolo = (String)session.getAttribute("ruolo");
  if (ruolo == null) {
   response.sendRedirect("errore.jsp");
  }else{
   if ((ruolo.compareTo("pm") != 0) && (ruolo.compareTo("pg") != 0)){
    response.sendRedirect("errore.jsp");
   }
  }
  String indagine = request.getParameter("id");
  String descrizione = request.getParameter("descrizione");
  String tipo = request.getParameter("tipo");
  String identificativo = request.getParameter("identificativo");
  String path = request.getParameter("file");
  String formato = request.getParameter("formato");
  String submit = request.getParameter("submit");
  
  if (indagine == null || descrizione == null || tipo == null || identificativo == null || path == null || formato == null || submit == null) {
   response.sendRedirect("errore.jsp");
  }else{
   Connection conn = open_conn("procura");
   Statement stat = conn.createStatement();
   if(tipo.compareTo("materiale") == 0){
    if (!(indagine.compareTo("")==0 || descrizione.compareTo("")==0 || identificativo.compareTo("")==0 || submit.compareTo("Aggiungi")!=0)) {
     stat.executeUpdate("INSERT INTO prova (indagine, descrizione, tipo, identificativo) VALUES ("+indagine+",'"+descrizione+"','"+tipo+"','"+identificativo+"');");
    }
   }else if(tipo.compareTo("digitale") == 0){
    if (!(indagine.compareTo("")==0 || descrizione.compareTo("")==0 || path.compareTo("")==0 || formato.compareTo("")==0 || submit.compareTo("Aggiungi")!=0)) {
      //TODO
    }
    stat.close();
    conn.close();
   }
   response.sendRedirect("indagini.jsp?id="+indagine);
  }
%>
