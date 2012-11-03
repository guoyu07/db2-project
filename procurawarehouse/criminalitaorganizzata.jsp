<%@ page session="true" contentType="text/html; charset=ISO-8859-1" %>
<%@ taglib uri="http://www.tonbeller.com/jpivot" prefix="jp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>


<jp:mondrianQuery id="query01" jdbcDriver="org.postgresql.Driver" jdbcUrl="jdbc:postgresql://localhost/procurawarehouse?user=procura&password=milano" catalogUri="/WEB-INF/queries/procurawarehouse.xml">
select {[Measures].[Condanne]} ON COLUMNS,
  {([Imputato.Organizzazione].[Tutte le organizzazioni], [Tempo.Periodo].[Tutti i periodi])} ON ROWS
from [processo]

</jp:mondrianQuery>

<c:set var="title01" scope="session">Andamento della lotta mirata alla criminalita' organizzata</c:set>
