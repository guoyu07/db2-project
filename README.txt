Creare utente postgres procura;


Database procura: 		database relativo alla traccia;

Database login: 		database per l'autenticazione sul wis;

Database procurawarehouse: 	database per l'analisi dei dati con mondrian;



Per accedere al wis:
Username	Password	Ruolo

topolino	milano		Amministratore

paperino	milano		Polizia Giudiziaria

pippo		milano		Pubblico Ministero


Per utilizzare la funzione di ETL del database procurawarehouse è necessario:

- installare la componente aggiunriva postgresql-contrib

- caricare lo script dblink.sql


Per utilizzare il sistema di criptaggio del database login è necessario:

- caricare lo script pgcrypto.sql
