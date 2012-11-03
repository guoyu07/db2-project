--
-- PostgreSQL database dump
--

-- Started on 2011-02-01 11:41:27 CET

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 356 (class 2612 OID 18963)
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- TOC entry 348 (class 1247 OID 18948)
-- Dependencies: 6 1547
-- Name: dblink_pkey_results; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE dblink_pkey_results AS (
	"position" integer,
	colname text
);


ALTER TYPE public.dblink_pkey_results OWNER TO postgres;

--
-- TOC entry 59 (class 1255 OID 19019)
-- Dependencies: 6 356
-- Name: calcolofasciaeta(numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION calcolofasciaeta(eta numeric) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
 fasciaeta CHARACTER VARYING(9);
BEGIN
 IF eta <= 17 THEN
  fasciaeta := 'minorenne';
 ELSIF eta >=18 AND eta<=39 THEN
  fasciaeta := 'giovane';
 ELSIF eta >=40 AND eta<=59 THEN
  fasciaeta := 'mezza età';
 ELSE
  fasciaeta := 'anziano';
 END IF;
 RETURN fasciaeta;
END;
$$;


ALTER FUNCTION public.calcolofasciaeta(eta numeric) OWNER TO postgres;

--
-- TOC entry 57 (class 1255 OID 18968)
-- Dependencies: 6 356
-- Name: calcoloorganizzazionecriminale(integer, date); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION calcoloorganizzazionecriminale(imput integer, inizioindagine date) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
 orgcrim RECORD;
 periodopiulungo INTEGER := 0;
 migliororgcrim CHARACTER VARYING;
BEGIN
  FOR orgcrim IN SELECT * FROM dblink('SELECT nome, COALESCE(fineappartenenza, CURRENT_DATE)-inizioappartenenza FROM varorganizzazionecriminale WHERE idimputato=' || imput)
              AS o(nome CHARACTER VARYING, giorniappartenenza INTEGER) LOOP
              
   IF periodopiulungo < orgcrim.giorniappartenenza THEN
    migliororgcrim := orgcrim.nome;
    periodopiulungo := orgcrim.giorniappartenenza;
   END IF;
  END LOOP;
  RETURN migliororgcrim;
END;
$$;


ALTER FUNCTION public.calcoloorganizzazionecriminale(imput integer, inizioindagine date) OWNER TO procura;

--
-- TOC entry 37 (class 1255 OID 18938)
-- Dependencies: 6
-- Name: dblink(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink(text, text) RETURNS SETOF record
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_record';


ALTER FUNCTION public.dblink(text, text) OWNER TO postgres;

--
-- TOC entry 38 (class 1255 OID 18939)
-- Dependencies: 6
-- Name: dblink(text, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink(text, text, boolean) RETURNS SETOF record
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_record';


ALTER FUNCTION public.dblink(text, text, boolean) OWNER TO postgres;

--
-- TOC entry 39 (class 1255 OID 18940)
-- Dependencies: 6
-- Name: dblink(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink(text) RETURNS SETOF record
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_record';


ALTER FUNCTION public.dblink(text) OWNER TO postgres;

--
-- TOC entry 40 (class 1255 OID 18941)
-- Dependencies: 6
-- Name: dblink(text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink(text, boolean) RETURNS SETOF record
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_record';


ALTER FUNCTION public.dblink(text, boolean) OWNER TO postgres;

--
-- TOC entry 47 (class 1255 OID 18951)
-- Dependencies: 6
-- Name: dblink_build_sql_delete(text, int2vector, integer, text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_build_sql_delete(text, int2vector, integer, text[]) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_build_sql_delete';


ALTER FUNCTION public.dblink_build_sql_delete(text, int2vector, integer, text[]) OWNER TO postgres;

--
-- TOC entry 46 (class 1255 OID 18950)
-- Dependencies: 6
-- Name: dblink_build_sql_insert(text, int2vector, integer, text[], text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_build_sql_insert(text, int2vector, integer, text[], text[]) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_build_sql_insert';


ALTER FUNCTION public.dblink_build_sql_insert(text, int2vector, integer, text[], text[]) OWNER TO postgres;

--
-- TOC entry 48 (class 1255 OID 18952)
-- Dependencies: 6
-- Name: dblink_build_sql_update(text, int2vector, integer, text[], text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_build_sql_update(text, int2vector, integer, text[], text[]) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_build_sql_update';


ALTER FUNCTION public.dblink_build_sql_update(text, int2vector, integer, text[], text[]) OWNER TO postgres;

--
-- TOC entry 55 (class 1255 OID 18959)
-- Dependencies: 6
-- Name: dblink_cancel_query(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_cancel_query(text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_cancel_query';


ALTER FUNCTION public.dblink_cancel_query(text) OWNER TO postgres;

--
-- TOC entry 33 (class 1255 OID 18934)
-- Dependencies: 6
-- Name: dblink_close(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_close(text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_close';


ALTER FUNCTION public.dblink_close(text) OWNER TO postgres;

--
-- TOC entry 34 (class 1255 OID 18935)
-- Dependencies: 6
-- Name: dblink_close(text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_close(text, boolean) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_close';


ALTER FUNCTION public.dblink_close(text, boolean) OWNER TO postgres;

--
-- TOC entry 35 (class 1255 OID 18936)
-- Dependencies: 6
-- Name: dblink_close(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_close(text, text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_close';


ALTER FUNCTION public.dblink_close(text, text) OWNER TO postgres;

--
-- TOC entry 36 (class 1255 OID 18937)
-- Dependencies: 6
-- Name: dblink_close(text, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_close(text, text, boolean) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_close';


ALTER FUNCTION public.dblink_close(text, text, boolean) OWNER TO postgres;

--
-- TOC entry 19 (class 1255 OID 18920)
-- Dependencies: 6
-- Name: dblink_connect(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_connect(text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_connect';


ALTER FUNCTION public.dblink_connect(text) OWNER TO postgres;

--
-- TOC entry 20 (class 1255 OID 18921)
-- Dependencies: 6
-- Name: dblink_connect(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_connect(text, text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_connect';


ALTER FUNCTION public.dblink_connect(text, text) OWNER TO postgres;

--
-- TOC entry 21 (class 1255 OID 18922)
-- Dependencies: 6
-- Name: dblink_connect_u(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_connect_u(text) RETURNS text
    LANGUAGE c STRICT SECURITY DEFINER
    AS '$libdir/dblink', 'dblink_connect';


ALTER FUNCTION public.dblink_connect_u(text) OWNER TO postgres;

--
-- TOC entry 22 (class 1255 OID 18923)
-- Dependencies: 6
-- Name: dblink_connect_u(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_connect_u(text, text) RETURNS text
    LANGUAGE c STRICT SECURITY DEFINER
    AS '$libdir/dblink', 'dblink_connect';


ALTER FUNCTION public.dblink_connect_u(text, text) OWNER TO postgres;

--
-- TOC entry 49 (class 1255 OID 18953)
-- Dependencies: 6
-- Name: dblink_current_query(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_current_query() RETURNS text
    LANGUAGE c
    AS '$libdir/dblink', 'dblink_current_query';


ALTER FUNCTION public.dblink_current_query() OWNER TO postgres;

--
-- TOC entry 23 (class 1255 OID 18924)
-- Dependencies: 6
-- Name: dblink_disconnect(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_disconnect() RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_disconnect';


ALTER FUNCTION public.dblink_disconnect() OWNER TO postgres;

--
-- TOC entry 24 (class 1255 OID 18925)
-- Dependencies: 6
-- Name: dblink_disconnect(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_disconnect(text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_disconnect';


ALTER FUNCTION public.dblink_disconnect(text) OWNER TO postgres;

--
-- TOC entry 56 (class 1255 OID 18960)
-- Dependencies: 6
-- Name: dblink_error_message(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_error_message(text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_error_message';


ALTER FUNCTION public.dblink_error_message(text) OWNER TO postgres;

--
-- TOC entry 41 (class 1255 OID 18942)
-- Dependencies: 6
-- Name: dblink_exec(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_exec(text, text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_exec';


ALTER FUNCTION public.dblink_exec(text, text) OWNER TO postgres;

--
-- TOC entry 42 (class 1255 OID 18943)
-- Dependencies: 6
-- Name: dblink_exec(text, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_exec(text, text, boolean) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_exec';


ALTER FUNCTION public.dblink_exec(text, text, boolean) OWNER TO postgres;

--
-- TOC entry 43 (class 1255 OID 18944)
-- Dependencies: 6
-- Name: dblink_exec(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_exec(text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_exec';


ALTER FUNCTION public.dblink_exec(text) OWNER TO postgres;

--
-- TOC entry 44 (class 1255 OID 18945)
-- Dependencies: 6
-- Name: dblink_exec(text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_exec(text, boolean) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_exec';


ALTER FUNCTION public.dblink_exec(text, boolean) OWNER TO postgres;

--
-- TOC entry 29 (class 1255 OID 18930)
-- Dependencies: 6
-- Name: dblink_fetch(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_fetch(text, integer) RETURNS SETOF record
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_fetch';


ALTER FUNCTION public.dblink_fetch(text, integer) OWNER TO postgres;

--
-- TOC entry 30 (class 1255 OID 18931)
-- Dependencies: 6
-- Name: dblink_fetch(text, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_fetch(text, integer, boolean) RETURNS SETOF record
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_fetch';


ALTER FUNCTION public.dblink_fetch(text, integer, boolean) OWNER TO postgres;

--
-- TOC entry 31 (class 1255 OID 18932)
-- Dependencies: 6
-- Name: dblink_fetch(text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_fetch(text, text, integer) RETURNS SETOF record
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_fetch';


ALTER FUNCTION public.dblink_fetch(text, text, integer) OWNER TO postgres;

--
-- TOC entry 32 (class 1255 OID 18933)
-- Dependencies: 6
-- Name: dblink_fetch(text, text, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_fetch(text, text, integer, boolean) RETURNS SETOF record
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_fetch';


ALTER FUNCTION public.dblink_fetch(text, text, integer, boolean) OWNER TO postgres;

--
-- TOC entry 54 (class 1255 OID 18958)
-- Dependencies: 6
-- Name: dblink_get_connections(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_get_connections() RETURNS text[]
    LANGUAGE c
    AS '$libdir/dblink', 'dblink_get_connections';


ALTER FUNCTION public.dblink_get_connections() OWNER TO postgres;

--
-- TOC entry 45 (class 1255 OID 18949)
-- Dependencies: 348 6
-- Name: dblink_get_pkey(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_get_pkey(text) RETURNS SETOF dblink_pkey_results
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_get_pkey';


ALTER FUNCTION public.dblink_get_pkey(text) OWNER TO postgres;

--
-- TOC entry 52 (class 1255 OID 18956)
-- Dependencies: 6
-- Name: dblink_get_result(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_get_result(text) RETURNS SETOF record
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_get_result';


ALTER FUNCTION public.dblink_get_result(text) OWNER TO postgres;

--
-- TOC entry 53 (class 1255 OID 18957)
-- Dependencies: 6
-- Name: dblink_get_result(text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_get_result(text, boolean) RETURNS SETOF record
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_get_result';


ALTER FUNCTION public.dblink_get_result(text, boolean) OWNER TO postgres;

--
-- TOC entry 51 (class 1255 OID 18955)
-- Dependencies: 6
-- Name: dblink_is_busy(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_is_busy(text) RETURNS integer
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_is_busy';


ALTER FUNCTION public.dblink_is_busy(text) OWNER TO postgres;

--
-- TOC entry 25 (class 1255 OID 18926)
-- Dependencies: 6
-- Name: dblink_open(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_open(text, text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_open';


ALTER FUNCTION public.dblink_open(text, text) OWNER TO postgres;

--
-- TOC entry 26 (class 1255 OID 18927)
-- Dependencies: 6
-- Name: dblink_open(text, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_open(text, text, boolean) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_open';


ALTER FUNCTION public.dblink_open(text, text, boolean) OWNER TO postgres;

--
-- TOC entry 27 (class 1255 OID 18928)
-- Dependencies: 6
-- Name: dblink_open(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_open(text, text, text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_open';


ALTER FUNCTION public.dblink_open(text, text, text) OWNER TO postgres;

--
-- TOC entry 28 (class 1255 OID 18929)
-- Dependencies: 6
-- Name: dblink_open(text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_open(text, text, text, boolean) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_open';


ALTER FUNCTION public.dblink_open(text, text, text, boolean) OWNER TO postgres;

--
-- TOC entry 50 (class 1255 OID 18954)
-- Dependencies: 6
-- Name: dblink_send_query(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dblink_send_query(text, text) RETURNS integer
    LANGUAGE c STRICT
    AS '$libdir/dblink', 'dblink_send_query';


ALTER FUNCTION public.dblink_send_query(text, text) OWNER TO postgres;

--
-- TOC entry 58 (class 1255 OID 18966)
-- Dependencies: 6 356
-- Name: refreshdw(); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION refreshdw() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
 proc RECORD;
 imput RECORD;
 ind CHARACTER VARYING(10);
 gio CHARACTER(10);
 dur INTEGER;
 imp CHARACTER VARYING(10);
 eta CHARACTER VARYING(3);
BEGIN
 -- connessione al database --
 PERFORM dblink_connect('dbname=procura host=localhost port=5432 user=procura password=milano');
 
 -- scansione dei processi --
 FOR proc IN SELECT * FROM dblink('SELECT * FROM varprocesso')
              AS p(idprocesso INTEGER, inizioprocesso DATE, fineprocesso DATE,
                   idindagine INTEGER, inizioindagine DATE, fineindagine DATE) LOOP
                   
 -- inserimento dei dati relativi alla dimensione indagine --
  ind := to_char(nextval('indagine_sq'),'FM9999999999');
  
  INSERT INTO indagine
  VALUES (ind, to_char(proc.fineindagine-proc.inizioindagine, 'FM000'),
          to_char((SELECT * FROM dblink('SELECT count(*) FROM varprova WHERE idindagine=' || proc.idindagine)
              AS prov(numeroprove INTEGER)),'FM000'));

  -- inserimento dei dati relativi alla dimensione tempo solo se necessario --
  gio := to_char(proc.fineprocesso,'YYYY-MM-DD');

  PERFORM *
  FROM tempo
  WHERE giorno LIKE gio;

  IF NOT FOUND THEN
   INSERT INTO tempo
   VALUES (gio, to_char(proc.fineprocesso,'YYYY-MM'),
           to_char(proc.fineprocesso,'YYYY') || '-' || trunc(to_number(to_char(proc.fineprocesso,'MM'),'99')/4)+1,
           to_char(proc.fineprocesso,'YYYY'));
  END IF;
          
  -- calcolo della misura durata --
  dur := proc.fineprocesso-proc.inizioprocesso;
  
  -- scandione degli imputati condannati di un processo --
  FOR imput IN SELECT * FROM dblink('SELECT * FROM varcondannato WHERE idprocesso=' || proc.idprocesso)
              AS i(idimputato INTEGER, idprocesso INTEGER, genere CHAR, datanascita DATE) LOOP

   -- inserimento dei dati relativi alla dimensione imputato --
   imp := to_char(nextval('imputato_sq'), 'FM9999999999');
   eta := to_char(age(proc.inizioprocesso,imput.datanascita),'YYY');   

   INSERT INTO imputato
   VALUES (imp, imput.genere, eta, calcolofasciaeta(to_number(eta,'000')), calcoloorganizzazionecriminale(imput.idimputato, proc.inizioindagine));

   -- inserimento dei dati relativi al fatto processo --
   INSERT INTO processo
   VALUES (nextval('processo_sq'), imp, ind, gio, 100, dur);
              
  END LOOP;

  -- scandione degli imputati assolti di un processo --
  FOR imput IN SELECT * FROM dblink('SELECT * FROM varprosciolto WHERE idprocesso=' || proc.idprocesso)
              AS i(idimputato INTEGER, idprocesso INTEGER, genere CHAR, datanascita DATE) LOOP

   -- inserimento dei dati relativi alla dimensione imputato --
   imp := to_char(nextval('imputato_sq'), 'FM9999999999');
   eta := to_char(age(proc.inizioprocesso,imput.datanascita),'YYY');   

   INSERT INTO imputato
   VALUES (imp, imput.genere, eta, calcolofasciaeta(to_number(eta,'000')), calcoloorganizzazionecriminale(imput.idimputato, proc.inizioindagine));

   -- inserimento dei dati relativi al fatto processo --
   INSERT INTO processo
   VALUES (nextval('processo_sq'), imp, ind, gio, 0, dur);
              
  END LOOP;
 END LOOP;
 
 -- azzeramento dell'archivio variazionale --
 PERFORM dblink_exec('DELETE FROM varprocesso');
 PERFORM dblink_exec('DELETE FROM varprova');
 PERFORM dblink_exec('DELETE FROM varcondannato');
 PERFORM dblink_exec('DELETE FROM varprosciolto');
 PERFORM dblink_exec('DELETE FROM varorganizzazionecriminale');
 -- disconnessione al database --
 PERFORM dblink_disconnect();
END;
$$;


ALTER FUNCTION public.refreshdw() OWNER TO procura;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1549 (class 1259 OID 18978)
-- Dependencies: 6
-- Name: imputato; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE imputato (
    id character varying(10) NOT NULL,
    genere "char" NOT NULL,
    eta character varying(3) NOT NULL,
    fasciaeta character varying(9) NOT NULL,
    organizzazionecriminale character varying(50)
);


ALTER TABLE public.imputato OWNER TO procura;

--
-- TOC entry 1543 (class 1259 OID 18882)
-- Dependencies: 6
-- Name: imputato_sq; Type: SEQUENCE; Schema: public; Owner: procura
--

CREATE SEQUENCE imputato_sq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.imputato_sq OWNER TO procura;

--
-- TOC entry 1850 (class 0 OID 0)
-- Dependencies: 1543
-- Name: imputato_sq; Type: SEQUENCE SET; Schema: public; Owner: procura
--

SELECT pg_catalog.setval('imputato_sq', 59, true);


--
-- TOC entry 1548 (class 1259 OID 18973)
-- Dependencies: 6
-- Name: indagine; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE indagine (
    id character varying(10) NOT NULL,
    durata character varying(3) NOT NULL,
    prove character varying(3) NOT NULL
);


ALTER TABLE public.indagine OWNER TO procura;

--
-- TOC entry 1544 (class 1259 OID 18887)
-- Dependencies: 6
-- Name: indagine_sq; Type: SEQUENCE; Schema: public; Owner: procura
--

CREATE SEQUENCE indagine_sq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.indagine_sq OWNER TO procura;

--
-- TOC entry 1851 (class 0 OID 0)
-- Dependencies: 1544
-- Name: indagine_sq; Type: SEQUENCE SET; Schema: public; Owner: procura
--

SELECT pg_catalog.setval('indagine_sq', 32, true);


--
-- TOC entry 1550 (class 1259 OID 18983)
-- Dependencies: 6
-- Name: processo; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE processo (
    id integer NOT NULL,
    idimputato character varying(10) NOT NULL,
    idindagine character varying(10) NOT NULL,
    giorno character(10) NOT NULL,
    percentualecondanne integer NOT NULL,
    durataprocesso integer NOT NULL
);


ALTER TABLE public.processo OWNER TO procura;

--
-- TOC entry 1545 (class 1259 OID 18892)
-- Dependencies: 6
-- Name: processo_sq; Type: SEQUENCE; Schema: public; Owner: procura
--

CREATE SEQUENCE processo_sq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.processo_sq OWNER TO procura;

--
-- TOC entry 1852 (class 0 OID 0)
-- Dependencies: 1545
-- Name: processo_sq; Type: SEQUENCE SET; Schema: public; Owner: procura
--

SELECT pg_catalog.setval('processo_sq', 55, true);


--
-- TOC entry 1546 (class 1259 OID 18894)
-- Dependencies: 6
-- Name: tempo; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE tempo (
    giorno character(10) NOT NULL,
    mese character(7) NOT NULL,
    trimestre character(6) NOT NULL,
    anno character(4) NOT NULL
);


ALTER TABLE public.tempo OWNER TO procura;

--
-- TOC entry 1841 (class 0 OID 18978)
-- Dependencies: 1549
-- Data for Name: imputato; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY imputato (id, genere, eta, fasciaeta, organizzazionecriminale) FROM stdin;
1	m	021	giovane	Banda Bassotti
2	m	022	giovane	Banda Bassotti
3	f	044	mezza età	\N
4	f	032	giovane	Banda Lupin
5	f	033	giovane	Banda Bassotti
6	m	061	anziano	\N
7	f	017	minorenne	\N
8	m	016	minorenne	Banda Lupin
55	m	023	giovane	Banda Bassotti
56	f	024	giovane	Banda Bassotti
57	m	024	giovane	Banda Bassotti
58	f	028	giovane	Banda Bassotti
59	f	057	mezza età	\N
\.


--
-- TOC entry 1840 (class 0 OID 18973)
-- Dependencies: 1548
-- Data for Name: indagine; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY indagine (id, durata, prove) FROM stdin;
5	090	003
7	033	019
6	088	001
8	052	005
4	044	012
3	041	018
2	021	021
1	015	024
32	094	013
\.


--
-- TOC entry 1842 (class 0 OID 18983)
-- Dependencies: 1550
-- Data for Name: processo; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY processo (id, idimputato, idindagine, giorno, percentualecondanne, durataprocesso) FROM stdin;
1	1	1	2001-12-21	100	20
3	2	1	2001-12-21	100	20
4	3	2	2002-03-02	100	31
5	4	3	2002-03-08	100	41
7	4	4	2002-03-08	100	50
2	1	2	2002-03-02	100	31
12	8	7	2003-07-07	100	34
11	7	6	2008-12-21	0	92
9	6	6	2008-12-21	0	92
8	6	5	2008-12-21	0	90
14	5	8	2003-07-07	0	52
6	5	4	2002-03-08	100	50
13	4	8	2003-07-07	100	52
10	6	7	2003-07-07	100	34
51	55	32	2010-11-11	100	32
52	56	32	2010-11-11	100	32
53	57	32	2010-11-11	100	32
54	58	32	2010-11-11	100	32
55	59	32	2010-11-11	0	32
\.


--
-- TOC entry 1839 (class 0 OID 18894)
-- Dependencies: 1546
-- Data for Name: tempo; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY tempo (giorno, mese, trimestre, anno) FROM stdin;
2001-12-21	2001-12	2001-4	2001
2002-03-02	2002-03	2002-1	2002
2003-07-07	2003-07	2003-3	2003
2002-03-08	2002-03	2002-1	2002
2008-12-21	2008-12	2008-4	2008
2010-11-11	2010-11	2010-3	2010
\.


--
-- TOC entry 1833 (class 2606 OID 18982)
-- Dependencies: 1549 1549
-- Name: imputato_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY imputato
    ADD CONSTRAINT imputato_pk PRIMARY KEY (id);


--
-- TOC entry 1831 (class 2606 OID 18977)
-- Dependencies: 1548 1548
-- Name: indagine_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY indagine
    ADD CONSTRAINT indagine_pk PRIMARY KEY (id);


--
-- TOC entry 1835 (class 2606 OID 18987)
-- Dependencies: 1550 1550
-- Name: processo_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY processo
    ADD CONSTRAINT processo_pk PRIMARY KEY (id);


--
-- TOC entry 1829 (class 2606 OID 18904)
-- Dependencies: 1546 1546
-- Name: tempo_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY tempo
    ADD CONSTRAINT tempo_pk PRIMARY KEY (giorno);


--
-- TOC entry 1836 (class 2606 OID 18988)
-- Dependencies: 1549 1550 1832
-- Name: imputato_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY processo
    ADD CONSTRAINT imputato_fk FOREIGN KEY (idimputato) REFERENCES imputato(id);


--
-- TOC entry 1837 (class 2606 OID 18993)
-- Dependencies: 1548 1550 1830
-- Name: indagine_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY processo
    ADD CONSTRAINT indagine_fk FOREIGN KEY (idindagine) REFERENCES indagine(id);


--
-- TOC entry 1838 (class 2606 OID 18998)
-- Dependencies: 1550 1828 1546
-- Name: tempo_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY processo
    ADD CONSTRAINT tempo_fk FOREIGN KEY (giorno) REFERENCES tempo(giorno);


--
-- TOC entry 1847 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 1848 (class 0 OID 0)
-- Dependencies: 21
-- Name: dblink_connect_u(text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION dblink_connect_u(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION dblink_connect_u(text) FROM postgres;
GRANT ALL ON FUNCTION dblink_connect_u(text) TO postgres;


--
-- TOC entry 1849 (class 0 OID 0)
-- Dependencies: 22
-- Name: dblink_connect_u(text, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION dblink_connect_u(text, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION dblink_connect_u(text, text) FROM postgres;
GRANT ALL ON FUNCTION dblink_connect_u(text, text) TO postgres;


-- Completed on 2011-02-01 11:41:28 CET

--
-- PostgreSQL database dump complete
--

