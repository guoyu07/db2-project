<%@ page language="java" import="java.sql.*" %>

<%! 
  public Connection open_conn(){
   Connection conn = null;
   try{
    Class.forName("org.postgresql.Driver");
   }catch (ClassNotFoundException e){
    System.out.println(e + e.getMessage());
   }

   try {
    conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/procura","procura","milano" );
   }catch (SQLException e){
    System.out.println(e + e.getMessage());
   }

   return(conn);
  }
%> 
