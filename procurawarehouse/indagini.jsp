<%@ page session="true" contentType="text/html; charset=ISO-8859-1" %>
<%@ taglib uri="http://www.tonbeller.com/jpivot" prefix="jp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>


<jp:mondrianQuery id="query01" jdbcDriver="org.postgresql.Driver" jdbcUrl="jdbc:postgresql://localhost/procurawarehouse?user=procura&password=milano" catalogUri="/WEB-INF/queries/procurawarehouse.xml">
select {[Measures].[Condanne], [Measures].[Durata]} ON COLUMNS,
  {([Indagine.Durata].[Tutte le durate], [Indagine.Prove].[Tutte le prove])} ON ROWS
from [processo]

</jp:mondrianQuery>

<c:set var="title01" scope="session">Andamento dei processi rispetto alla qualita' delle indagini</c:set>
