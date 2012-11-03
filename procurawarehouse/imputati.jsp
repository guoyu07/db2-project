<%@ page session="true" contentType="text/html; charset=ISO-8859-1" %>
<%@ taglib uri="http://www.tonbeller.com/jpivot" prefix="jp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>


<jp:mondrianQuery id="query01" jdbcDriver="org.postgresql.Driver" jdbcUrl="jdbc:postgresql://localhost/procurawarehouse?user=procura&password=milano" catalogUri="/WEB-INF/queries/procurawarehouse.xml">
select {[Measures].[Condanne], [Measures].[Durata]} ON COLUMNS,
  {([Imputato.Genere].[Tutti i generi], [Imputato.Eta].[Tutte le eta], [Imputato.Organizzazione].[Tutte le organizzazioni])} ON ROWS
from [processo]

</jp:mondrianQuery>

<c:set var="title01" scope="session">Andamento dei processi rispetto alle caratteristiche degli imputati</c:set>
