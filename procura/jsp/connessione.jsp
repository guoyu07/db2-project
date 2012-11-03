<%@ page language="java" import="java.sql.*" %>

<%!
  public Connection open_conn(String database){
   Connection conn = null;
   try{
    Class.forName("org.postgresql.Driver");
   }catch (ClassNotFoundException e){
    System.out.println(e + e.getMessage());
   }

   try {
    conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/"+database,"procura","milano" );
   }catch (SQLException e){
    System.out.println(e + e.getMessage());
   }

   return(conn);
  }

  public void close_conn(Connection conn){
   try {
    conn.close();
   }catch (SQLException e){
    System.out.println(e + e.getMessage());
   }
  }
%> 
