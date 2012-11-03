--
-- PostgreSQL database dump
--

-- Started on 2011-02-01 11:41:14 CET

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 363 (class 2612 OID 18641)
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: procura
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO procura;

SET search_path = public, pg_catalog;

--
-- TOC entry 19 (class 1255 OID 18642)
-- Dependencies: 6 363
-- Name: archiviazione(); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION archiviazione() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF OLD.datafine IS NULL AND NEW.datafine IS NOT NULL THEN
  INSERT INTO varprocesso
   SELECT pro.id, pro.datainizio, pro.datafine, ind.id, ind.datainizio, ind.datafine
   FROM processo pro, indagine ind
   WHERE pro.id=NEW.id AND pro.indagine=ind.id;

  INSERT INTO varprova
   SELECT id, indagine
   FROM prova
   WHERE indagine=NEW.indagine;

  INSERT INTO varcondannato
   SELECT con.imputato, con.processo, ind.genere, ind.datanascita
   FROM condanna con, indagato ind
   WHERE con.processo=NEW.id AND con.imputato=ind.id;

  INSERT INTO varprosciolto
   SELECT pro.imputato, pro.processo, ind.genere, ind.datanascita
   FROM proscioglimento pro, indagato ind
   WHERE pro.processo=NEW.id AND pro.imputato=ind.id;

  INSERT INTO varorganizzazionecriminale
   SELECT organizzazionecriminale, imputato, inizio, fine
   FROM appartenenza
   WHERE imputato IN (SELECT imputato FROM carico WHERE processo=NEW.id);
 END IF;
 RETURN NEW;
END;
$$;


ALTER FUNCTION public.archiviazione() OWNER TO procura;

--
-- TOC entry 20 (class 1255 OID 18643)
-- Dependencies: 6 363
-- Name: carico(); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION carico() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 PERFORM *
 FROM carico
 WHERE imputato=OLD.indagato
  AND processo IN (SELECT id FROM processo WHERE indagine=OLD.indagine);

 IF FOUND THEN
  RAISE EXCEPTION 'Non è possibile modificare una citazione di indagine dopo che il processo correlato è già iniziato'
  USING ERRCODE = '61000';
 END IF;
 
 RETURN NEW;
END;
$$;


ALTER FUNCTION public.carico() OWNER TO procura;

--
-- TOC entry 21 (class 1255 OID 18644)
-- Dependencies: 363 6
-- Name: citazione(); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION citazione() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 PERFORM *
 FROM citazione
 WHERE indagato=NEW.imputato
  AND indagine IN (SELECT indagine FROM processo WHERE id=NEW.processo);

 IF NOT FOUND THEN
  RAISE EXCEPTION 'Non è possibile iniziare un processo contro un soggetto che non è stato indagato'
  USING ERRCODE = '60000';
 END IF;
 
 RETURN NEW;
END;
$$;


ALTER FUNCTION public.citazione() OWNER TO procura;

--
-- TOC entry 22 (class 1255 OID 18645)
-- Dependencies: 363 6
-- Name: conclusioneprocesso(); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION conclusioneprocesso() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
 carichi INTEGER;
 condanne INTEGER;
 proscioglimenti INTEGER;
BEGIN
 SELECT count(*) INTO carichi
 FROM carico
 WHERE processo=NEW.processo
  AND imputato=NEW.imputato; 

 SELECT count(*) INTO condanne
 FROM condanna
 WHERE processo=NEW.processo
  AND imputato=NEW.imputato;

 SELECT count(*) INTO proscioglimenti
 FROM proscioglimento
 WHERE processo=NEW.processo
  AND imputato=NEW.imputato;

 IF (carichi-(condanne+proscioglimenti))=0 THEN
  UPDATE processo
  SET concluso=true
  WHERE id=NEW.processo;
 END IF;
 RETURN NEW;
END;
$$;


ALTER FUNCTION public.conclusioneprocesso() OWNER TO procura;

--
-- TOC entry 23 (class 1255 OID 18646)
-- Dependencies: 363 6
-- Name: condanna(); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION condanna() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 PERFORM *
 FROM carico
 WHERE processo=NEW.processo AND imputato=NEW.imputato;

 IF NOT FOUND THEN
  RAISE EXCEPTION 'Non è possibile inserire un esito per un processo che non è mai stato a carico di questo imputato'
  USING ERRCODE = '40000';
 ELSE
  PERFORM *
  FROM condanna
  WHERE processo=NEW.processo AND imputato=NEW.imputato;

  IF FOUND THEN
   RAISE EXCEPTION 'Non è possibile inserire un proscioglimento per un processo per il quale è già stata emanata una condanna'
   USING ERRCODE = '41000';
  END IF;
 END IF;
 RETURN NEW;
END;
$$;


ALTER FUNCTION public.condanna() OWNER TO procura;

--
-- TOC entry 24 (class 1255 OID 18647)
-- Dependencies: 363 6
-- Name: datafine(); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION datafine() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
 conc BOOLEAN;
BEGIN
 IF NEW.datafine IS NOT NULL THEN
  SELECT concluso INTO conc
  FROM processo
  WHERE id=NEW.id;

  IF NOT conc THEN
   RAISE EXCEPTION 'Non è possibile specificare la data di chiusura di un processo se ci sono ancora degli esiti non registrati'
   USING ERRCODE = '30000';
  END IF;
 END IF;
 RETURN NEW;
END;
$$;


ALTER FUNCTION public.datafine() OWNER TO procura;

--
-- TOC entry 25 (class 1255 OID 18648)
-- Dependencies: 363 6
-- Name: dataindagine(); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION dataindagine() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
 dataFineIndagine DATE;
BEGIN
 SELECT datafine INTO dataFineIndagine
 FROM indagine
 WHERE id=NEW.indagine;

 IF dataFineIndagine IS NULL THEN
  RAISE EXCEPTION 'L''indagine preliminare non è terminata, impossibile associarvi un processo'
  USING ERRCODE = '10000';
 ELSE
  IF dataFineIndagine > NEW.datainizio THEN
   RAISE EXCEPTION 'La data di inizio processo non può precedere la data di terminazione dell''indagine'
   USING ERRCODE = '11000';
  END IF;
 END IF;
 
 RETURN NEW;
END;
$$;


ALTER FUNCTION public.dataindagine() OWNER TO procura;

--
-- TOC entry 26 (class 1255 OID 18649)
-- Dependencies: 6 363
-- Name: dataprocesso(); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION dataprocesso() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
 dataInizioProcesso DATE;
BEGIN
 SELECT datainizio INTO dataInizioProcesso
 FROM processo
 WHERE indagine=NEW.id;

 IF dataInizioProcesso IS NOT NULL THEN
  IF NEW.datafine IS NULL THEN
   RAISE EXCEPTION 'L''indagine preliminare è stata chiusa per l''inizio del processo, non è possibile riaprirla'
   USING ERRCODE = '12000';
  ELSE
   IF dataInizioProcesso < NEW.datafine THEN
    RAISE EXCEPTION 'L''indagine preliminare è stata associata ad un processo iniziato il %, non è possibile fissare la chiusura delle indagini dopo tale data', dataInizioProcesso
    USING ERRCODE = '13000';   
   END IF;
  END IF;
 END IF;
 
 RETURN NEW;
END;
$$;


ALTER FUNCTION public.dataprocesso() OWNER TO procura;

--
-- TOC entry 27 (class 1255 OID 18650)
-- Dependencies: 6 363
-- Name: illecito(); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION illecito() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
 ill TEXT;
BEGIN
 SELECT illecito INTO ill
 FROM citazione
 WHERE indagato=NEW.imputato
  AND indagine IN (SELECT indagine FROM processo WHERE id=NEW.processo);

 IF NEW.capoimputazione IS NULL THEN
  NEW.capoimputazione := ill;
 ELSE
  IF NEW.capoimputazione NOT LIKE ill THEN
   RAISE EXCEPTION 'Il capo di imputazione di un processo deve essere uguale all''illecito da verificare durante l''indagine'
   USING ERRCODE = '20000';
  END IF;
 END IF;
 RETURN NEW;
END;
$$;


ALTER FUNCTION public.illecito() OWNER TO procura;

--
-- TOC entry 31 (class 1255 OID 19091)
-- Dependencies: 6 363
-- Name: nuovaindagine(date); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION nuovaindagine(inizio date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
 newid integer;
BEGIN
 SELECT nextval('indagine_sq') INTO newid;
 INSERT INTO indagine VALUES (newid, inizio);
 RETURN newid;
END;
$$;


ALTER FUNCTION public.nuovaindagine(inizio date) OWNER TO procura;

--
-- TOC entry 32 (class 1255 OID 19092)
-- Dependencies: 6 363
-- Name: nuovoprocesso(integer, text, date); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION nuovoprocesso(indagine integer, gradogiudizio text, datainizio date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
 newid integer;
BEGIN
 SELECT nextval('processo_sq') INTO newid;
 INSERT INTO processo VALUES (newid, indagine, gradogiudizio, datainizio);
 RETURN newid;
END;
$$;


ALTER FUNCTION public.nuovoprocesso(indagine integer, gradogiudizio text, datainizio date) OWNER TO procura;

--
-- TOC entry 33 (class 1255 OID 18651)
-- Dependencies: 363 6
-- Name: processo(); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION processo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

 PERFORM *
 FROM processo
 WHERE indagine=OLD.indagine;

 IF FOUND THEN
  PERFORM *
  FROM prova
  WHERE indagine=OLD.indagine;

  IF NOT FOUND THEN
   RAISE EXCEPTION 'Non è possibile lasciare un processo senza neanche una prova prodotta dall''indagine preliminare'
   USING ERRCODE = '51000';
  END IF;
 END IF;
 
 RETURN NEW;
END;
$$;


ALTER FUNCTION public.processo() OWNER TO procura;

--
-- TOC entry 28 (class 1255 OID 18652)
-- Dependencies: 6 363
-- Name: proscioglimento(); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION proscioglimento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 PERFORM *
 FROM carico
 WHERE processo=NEW.processo AND imputato=NEW.imputato;

 IF NOT FOUND THEN
  RAISE EXCEPTION 'Non è possibile inserire un esito per un processo che non è mai stato a carico di questo imputato'
  USING ERRCODE = '40000';
 ELSE
  PERFORM *
  FROM proscioglimento
  WHERE processo=NEW.processo AND imputato=NEW.imputato;

  IF FOUND THEN
   RAISE EXCEPTION 'Non è possibile inserire una condanna per un processo per il quale è già stata emanato un proscioglimento'
   USING ERRCODE = '42000';
  END IF;
 END IF;
 RETURN NEW;
END;
$$;


ALTER FUNCTION public.proscioglimento() OWNER TO procura;

--
-- TOC entry 29 (class 1255 OID 18653)
-- Dependencies: 363 6
-- Name: prove(); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION prove() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 PERFORM *
 FROM prova
 WHERE indagine=NEW.indagine;

 IF NOT FOUND THEN
  RAISE EXCEPTION 'Non è possibile aprire un processo se l''indagine preliminare non ha prodotto alcuna prova'
  USING ERRCODE = '50000';
 END IF;
 
 RETURN NEW;
END;
$$;


ALTER FUNCTION public.prove() OWNER TO procura;

--
-- TOC entry 30 (class 1255 OID 18654)
-- Dependencies: 363 6
-- Name: valoriiniziali(); Type: FUNCTION; Schema: public; Owner: procura
--

CREATE FUNCTION valoriiniziali() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 NEW.concluso := FALSE;
 NEW.datafine := NULL;
 RETURN NEW;
END;
$$;


ALTER FUNCTION public.valoriiniziali() OWNER TO procura;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1550 (class 1259 OID 18655)
-- Dependencies: 1849 6
-- Name: appartenenza; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE appartenenza (
    imputato integer NOT NULL,
    organizzazionecriminale character varying(50) NOT NULL,
    inizio date NOT NULL,
    fine date,
    CONSTRAINT date_ck CHECK ((inizio < fine))
);


ALTER TABLE public.appartenenza OWNER TO procura;

--
-- TOC entry 1551 (class 1259 OID 18659)
-- Dependencies: 6
-- Name: carico; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE carico (
    processo integer NOT NULL,
    imputato integer NOT NULL,
    capoimputazione text
);


ALTER TABLE public.carico OWNER TO procura;

--
-- TOC entry 1552 (class 1259 OID 18665)
-- Dependencies: 6
-- Name: citazione; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE citazione (
    indagato integer NOT NULL,
    indagine integer NOT NULL,
    illecito text NOT NULL
);


ALTER TABLE public.citazione OWNER TO procura;

--
-- TOC entry 1553 (class 1259 OID 18671)
-- Dependencies: 6
-- Name: condanna; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE condanna (
    processo integer NOT NULL,
    imputato integer NOT NULL,
    entita text NOT NULL
);


ALTER TABLE public.condanna OWNER TO procura;

--
-- TOC entry 1554 (class 1259 OID 18677)
-- Dependencies: 6
-- Name: copertura; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE copertura (
    indagato integer NOT NULL,
    incaricopa character varying(50) NOT NULL
);


ALTER TABLE public.copertura OWNER TO procura;

--
-- TOC entry 1555 (class 1259 OID 18680)
-- Dependencies: 6
-- Name: imputato; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE imputato (
    indagato integer NOT NULL
);


ALTER TABLE public.imputato OWNER TO procura;

--
-- TOC entry 1556 (class 1259 OID 18683)
-- Dependencies: 6
-- Name: incaricopa; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE incaricopa (
    nome character varying(50) NOT NULL
);


ALTER TABLE public.incaricopa OWNER TO procura;

--
-- TOC entry 1557 (class 1259 OID 18686)
-- Dependencies: 6
-- Name: indagato_sq; Type: SEQUENCE; Schema: public; Owner: procura
--

CREATE SEQUENCE indagato_sq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.indagato_sq OWNER TO procura;

--
-- TOC entry 1955 (class 0 OID 0)
-- Dependencies: 1557
-- Name: indagato_sq; Type: SEQUENCE SET; Schema: public; Owner: procura
--

SELECT pg_catalog.setval('indagato_sq', 4, true);


--
-- TOC entry 1558 (class 1259 OID 18688)
-- Dependencies: 1850 1851 6
-- Name: indagato; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE indagato (
    id integer DEFAULT nextval('indagato_sq'::regclass) NOT NULL,
    nome character varying(30) NOT NULL,
    cognome character varying(30) NOT NULL,
    datanascita date NOT NULL,
    luogonascita character varying(50),
    residenza text NOT NULL,
    genere "char" NOT NULL,
    CONSTRAINT genere_ck CHECK (((genere = 'm'::"char") OR (genere = 'f'::"char")))
);


ALTER TABLE public.indagato OWNER TO procura;

--
-- TOC entry 1559 (class 1259 OID 18696)
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
-- TOC entry 1956 (class 0 OID 0)
-- Dependencies: 1559
-- Name: indagine_sq; Type: SEQUENCE SET; Schema: public; Owner: procura
--

SELECT pg_catalog.setval('indagine_sq', 4, true);


--
-- TOC entry 1560 (class 1259 OID 18698)
-- Dependencies: 1852 1853 6
-- Name: indagine; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE indagine (
    id integer DEFAULT nextval('indagine_sq'::regclass) NOT NULL,
    datainizio date NOT NULL,
    datafine date,
    CONSTRAINT date_ck CHECK ((datainizio < datafine))
);


ALTER TABLE public.indagine OWNER TO procura;

--
-- TOC entry 1561 (class 1259 OID 18703)
-- Dependencies: 6
-- Name: organizzazionecriminale; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE organizzazionecriminale (
    nome character varying(50) NOT NULL
);


ALTER TABLE public.organizzazionecriminale OWNER TO procura;

--
-- TOC entry 1562 (class 1259 OID 18706)
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
-- TOC entry 1957 (class 0 OID 0)
-- Dependencies: 1562
-- Name: processo_sq; Type: SEQUENCE SET; Schema: public; Owner: procura
--

SELECT pg_catalog.setval('processo_sq', 6, true);


--
-- TOC entry 1563 (class 1259 OID 18708)
-- Dependencies: 1854 1855 1856 1857 6
-- Name: processo; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE processo (
    id integer DEFAULT nextval('processo_sq'::regclass) NOT NULL,
    indagine integer NOT NULL,
    gradogiudizio character varying(11) NOT NULL,
    datainizio date NOT NULL,
    concluso boolean DEFAULT false NOT NULL,
    datafine date,
    CONSTRAINT date_ck CHECK ((datainizio < datafine)),
    CONSTRAINT gradogiudizio_ck CHECK (((((gradogiudizio)::text = 'Primo grado'::text) OR ((gradogiudizio)::text = 'Appello'::text)) OR ((gradogiudizio)::text = 'Cassazione'::text)))
);


ALTER TABLE public.processo OWNER TO procura;

--
-- TOC entry 1564 (class 1259 OID 18715)
-- Dependencies: 6
-- Name: proscioglimento; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE proscioglimento (
    processo integer NOT NULL,
    imputato integer NOT NULL,
    motivo text NOT NULL
);


ALTER TABLE public.proscioglimento OWNER TO procura;

--
-- TOC entry 1565 (class 1259 OID 18721)
-- Dependencies: 6
-- Name: prova_sq; Type: SEQUENCE; Schema: public; Owner: procura
--

CREATE SEQUENCE prova_sq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.prova_sq OWNER TO procura;

--
-- TOC entry 1958 (class 0 OID 0)
-- Dependencies: 1565
-- Name: prova_sq; Type: SEQUENCE SET; Schema: public; Owner: procura
--

SELECT pg_catalog.setval('prova_sq', 4, true);


--
-- TOC entry 1566 (class 1259 OID 18723)
-- Dependencies: 1858 1859 1860 6
-- Name: prova; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE prova (
    id integer DEFAULT nextval('prova_sq'::regclass) NOT NULL,
    indagine integer NOT NULL,
    descrizione text NOT NULL,
    tipo character varying(9) NOT NULL,
    identificativo integer,
    file bytea,
    formato character varying(9),
    CONSTRAINT formato_ck CHECK ((((((formato)::text = 'documento'::text) OR ((formato)::text = 'immagine'::text)) OR ((formato)::text = 'audio'::text)) OR ((formato)::text = 'video'::text))),
    CONSTRAINT tipo_ck CHECK ((((tipo)::text = 'materiale'::text) OR ((tipo)::text = 'digitale'::text)))
);


ALTER TABLE public.prova OWNER TO procura;

--
-- TOC entry 1567 (class 1259 OID 18732)
-- Dependencies: 6
-- Name: varcondannato; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE varcondannato (
    idimputato integer NOT NULL,
    idprocesso integer NOT NULL,
    genere "char" NOT NULL,
    datanascita date NOT NULL
);


ALTER TABLE public.varcondannato OWNER TO procura;

--
-- TOC entry 1568 (class 1259 OID 18735)
-- Dependencies: 6
-- Name: varorganizzazionecriminale; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE varorganizzazionecriminale (
    nome character varying(50) NOT NULL,
    idimputato integer NOT NULL,
    inizioappartenenza date NOT NULL,
    fineappartenenza date
);


ALTER TABLE public.varorganizzazionecriminale OWNER TO procura;

--
-- TOC entry 1569 (class 1259 OID 18738)
-- Dependencies: 6
-- Name: varprocesso; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE varprocesso (
    idprocesso integer NOT NULL,
    inizioprocesso date NOT NULL,
    fineprocesso date NOT NULL,
    idindagine integer NOT NULL,
    inizioindagine date NOT NULL,
    fineindagine date NOT NULL
);


ALTER TABLE public.varprocesso OWNER TO procura;

--
-- TOC entry 1570 (class 1259 OID 18741)
-- Dependencies: 6
-- Name: varprosciolto; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE varprosciolto (
    idimputato integer NOT NULL,
    idprocesso integer NOT NULL,
    genere "char" NOT NULL,
    datanascita date NOT NULL
);


ALTER TABLE public.varprosciolto OWNER TO procura;

--
-- TOC entry 1571 (class 1259 OID 18744)
-- Dependencies: 6
-- Name: varprova; Type: TABLE; Schema: public; Owner: procura; Tablespace: 
--

CREATE TABLE varprova (
    idprova integer NOT NULL,
    idindagine integer NOT NULL
);


ALTER TABLE public.varprova OWNER TO procura;

--
-- TOC entry 1932 (class 0 OID 18655)
-- Dependencies: 1550
-- Data for Name: appartenenza; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY appartenenza (imputato, organizzazionecriminale, inizio, fine) FROM stdin;
2	Banda Bassotti	2010-09-21	\N
\.


--
-- TOC entry 1933 (class 0 OID 18659)
-- Dependencies: 1551
-- Data for Name: carico; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY carico (processo, imputato, capoimputazione) FROM stdin;
1	1	Furto con scasso al fortino di Paperon de' Paperoni
2	1	Rapimento di Minnie
1	2	Furto con scasso al fortino di Paperon de' Paperoni
3	2	Frode fiscale
\.


--
-- TOC entry 1934 (class 0 OID 18665)
-- Dependencies: 1552
-- Data for Name: citazione; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY citazione (indagato, indagine, illecito) FROM stdin;
1	1	Furto con scasso al fortino di Paperon de' Paperoni
2	1	Furto con scasso al fortino di Paperon de' Paperoni
1	2	Rapimento di Minnie
2	3	Frode fiscale
4	4	Traffico di stupefacenti
1	4	Spaccio di droga
2	4	Spaccio di droga
\.


--
-- TOC entry 1935 (class 0 OID 18671)
-- Dependencies: 1553
-- Data for Name: condanna; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY condanna (processo, imputato, entita) FROM stdin;
1	2	12 anni di carcere
\.


--
-- TOC entry 1936 (class 0 OID 18677)
-- Dependencies: 1554
-- Data for Name: copertura; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY copertura (indagato, incaricopa) FROM stdin;
1	Sindaco di Topolinia
1	Comandante della Polizia di Paperopoli
2	Sindaco di Topolinia
\.


--
-- TOC entry 1937 (class 0 OID 18680)
-- Dependencies: 1555
-- Data for Name: imputato; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY imputato (indagato) FROM stdin;
1
2
\.


--
-- TOC entry 1938 (class 0 OID 18683)
-- Dependencies: 1556
-- Data for Name: incaricopa; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY incaricopa (nome) FROM stdin;
Sindaco di Topolinia
Comandante della Polizia di Paperopoli
Sindaco di Paperopoli
\.


--
-- TOC entry 1939 (class 0 OID 18688)
-- Dependencies: 1558
-- Data for Name: indagato; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY indagato (id, nome, cognome, datanascita, luogonascita, residenza, genere) FROM stdin;
1	Macchia	Nera	1985-01-01	Topolinia	via Paperopoli 7, 12345 Topolinia TP	m
2	Pietro	Gambadilegno	1079-01-01	Topolinia	via Paperopoli 30, 12345 Topolinia TP	m
\.


--
-- TOC entry 1940 (class 0 OID 18698)
-- Dependencies: 1560
-- Data for Name: indagine; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY indagine (id, datainizio, datafine) FROM stdin;
1	2010-01-15	2010-07-30
2	2010-06-30	2010-09-21
3	2010-07-20	2010-10-31
\.


--
-- TOC entry 1941 (class 0 OID 18703)
-- Dependencies: 1561
-- Data for Name: organizzazionecriminale; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY organizzazionecriminale (nome) FROM stdin;
Banda Bassotti
\.


--
-- TOC entry 1942 (class 0 OID 18708)
-- Dependencies: 1563
-- Data for Name: processo; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY processo (id, indagine, gradogiudizio, datainizio, concluso, datafine) FROM stdin;
3	3	Primo grado	2011-01-03	f	\N
1	1	Primo grado	2010-08-22	t	2011-01-12
2	2	Primo grado	2011-01-01	t	\N
\.


--
-- TOC entry 1943 (class 0 OID 18715)
-- Dependencies: 1564
-- Data for Name: proscioglimento; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY proscioglimento (processo, imputato, motivo) FROM stdin;
1	1	mancanza di prove
2	1	mancanza di prove
\.


--
-- TOC entry 1944 (class 0 OID 18723)
-- Dependencies: 1566
-- Data for Name: prova; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY prova (id, indagine, descrizione, tipo, identificativo, file, formato) FROM stdin;
1	1	Mozzicone di sigaretta con il DNA di Gambadilegno appena fuori dal fortino	materiale	1	\N	\N
2	2	Mozzicone di sigaretta con il DNA di Gambadilegno appena fuori dal fortino	materiale	2	\N	\N
3	3	Contabilità della Gambadilegno S.p.a	materiale	3	\N	\N
\.


--
-- TOC entry 1945 (class 0 OID 18732)
-- Dependencies: 1567
-- Data for Name: varcondannato; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY varcondannato (idimputato, idprocesso, genere, datanascita) FROM stdin;
\.


--
-- TOC entry 1946 (class 0 OID 18735)
-- Dependencies: 1568
-- Data for Name: varorganizzazionecriminale; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY varorganizzazionecriminale (nome, idimputato, inizioappartenenza, fineappartenenza) FROM stdin;
\.


--
-- TOC entry 1947 (class 0 OID 18738)
-- Dependencies: 1569
-- Data for Name: varprocesso; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY varprocesso (idprocesso, inizioprocesso, fineprocesso, idindagine, inizioindagine, fineindagine) FROM stdin;
\.


--
-- TOC entry 1948 (class 0 OID 18741)
-- Dependencies: 1570
-- Data for Name: varprosciolto; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY varprosciolto (idimputato, idprocesso, genere, datanascita) FROM stdin;
\.


--
-- TOC entry 1949 (class 0 OID 18744)
-- Dependencies: 1571
-- Data for Name: varprova; Type: TABLE DATA; Schema: public; Owner: procura
--

COPY varprova (idprova, idindagine) FROM stdin;
\.


--
-- TOC entry 1862 (class 2606 OID 18748)
-- Dependencies: 1550 1550 1550
-- Name: appartenenza_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY appartenenza
    ADD CONSTRAINT appartenenza_pk PRIMARY KEY (imputato, organizzazionecriminale);


--
-- TOC entry 1865 (class 2606 OID 18750)
-- Dependencies: 1551 1551 1551
-- Name: carico_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY carico
    ADD CONSTRAINT carico_pk PRIMARY KEY (processo, imputato);


--
-- TOC entry 1867 (class 2606 OID 18752)
-- Dependencies: 1552 1552 1552
-- Name: citazione_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY citazione
    ADD CONSTRAINT citazione_pk PRIMARY KEY (indagato, indagine);


--
-- TOC entry 1869 (class 2606 OID 18754)
-- Dependencies: 1553 1553 1553
-- Name: condanna_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY condanna
    ADD CONSTRAINT condanna_pk PRIMARY KEY (processo, imputato);


--
-- TOC entry 1871 (class 2606 OID 18756)
-- Dependencies: 1554 1554 1554
-- Name: copertura_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY copertura
    ADD CONSTRAINT copertura_pk PRIMARY KEY (indagato, incaricopa);


--
-- TOC entry 1874 (class 2606 OID 18758)
-- Dependencies: 1555 1555
-- Name: imputato_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY imputato
    ADD CONSTRAINT imputato_pk PRIMARY KEY (indagato);


--
-- TOC entry 1876 (class 2606 OID 18760)
-- Dependencies: 1556 1556
-- Name: incaricopa_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY incaricopa
    ADD CONSTRAINT incaricopa_pk PRIMARY KEY (nome);


--
-- TOC entry 1878 (class 2606 OID 18762)
-- Dependencies: 1558 1558
-- Name: indagato_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY indagato
    ADD CONSTRAINT indagato_pk PRIMARY KEY (id);


--
-- TOC entry 1880 (class 2606 OID 18764)
-- Dependencies: 1558 1558 1558 1558 1558
-- Name: indagato_un; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY indagato
    ADD CONSTRAINT indagato_un UNIQUE (nome, cognome, datanascita, luogonascita);


--
-- TOC entry 1882 (class 2606 OID 18766)
-- Dependencies: 1560 1560
-- Name: indagine_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY indagine
    ADD CONSTRAINT indagine_pk PRIMARY KEY (id);


--
-- TOC entry 1884 (class 2606 OID 18768)
-- Dependencies: 1561 1561
-- Name: organizzazionecriminale_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY organizzazionecriminale
    ADD CONSTRAINT organizzazionecriminale_pk PRIMARY KEY (nome);


--
-- TOC entry 1886 (class 2606 OID 18770)
-- Dependencies: 1563 1563
-- Name: processo_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY processo
    ADD CONSTRAINT processo_pk PRIMARY KEY (id);


--
-- TOC entry 1888 (class 2606 OID 18772)
-- Dependencies: 1563 1563 1563
-- Name: processo_un; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY processo
    ADD CONSTRAINT processo_un UNIQUE (indagine, gradogiudizio);


--
-- TOC entry 1890 (class 2606 OID 18774)
-- Dependencies: 1564 1564 1564
-- Name: proscioglimento_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY proscioglimento
    ADD CONSTRAINT proscioglimento_pk PRIMARY KEY (processo, imputato);


--
-- TOC entry 1892 (class 2606 OID 18776)
-- Dependencies: 1566 1566
-- Name: prova_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY prova
    ADD CONSTRAINT prova_pk PRIMARY KEY (id);


--
-- TOC entry 1894 (class 2606 OID 18778)
-- Dependencies: 1567 1567 1567
-- Name: varimputato_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY varcondannato
    ADD CONSTRAINT varimputato_pk PRIMARY KEY (idimputato, idprocesso);


--
-- TOC entry 1896 (class 2606 OID 18780)
-- Dependencies: 1568 1568 1568
-- Name: varorganizzazionecriminale_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY varorganizzazionecriminale
    ADD CONSTRAINT varorganizzazionecriminale_pk PRIMARY KEY (nome, idimputato);


--
-- TOC entry 1898 (class 2606 OID 18782)
-- Dependencies: 1569 1569
-- Name: varprocesso_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY varprocesso
    ADD CONSTRAINT varprocesso_pk PRIMARY KEY (idprocesso);


--
-- TOC entry 1900 (class 2606 OID 18784)
-- Dependencies: 1570 1570 1570
-- Name: varprosciolto_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY varprosciolto
    ADD CONSTRAINT varprosciolto_pk PRIMARY KEY (idimputato, idprocesso);


--
-- TOC entry 1902 (class 2606 OID 18786)
-- Dependencies: 1571 1571
-- Name: varprova_pk; Type: CONSTRAINT; Schema: public; Owner: procura; Tablespace: 
--

ALTER TABLE ONLY varprova
    ADD CONSTRAINT varprova_pk PRIMARY KEY (idprova);


--
-- TOC entry 1872 (class 1259 OID 18787)
-- Dependencies: 1554
-- Name: incpa_in; Type: INDEX; Schema: public; Owner: procura; Tablespace: 
--

CREATE INDEX incpa_in ON copertura USING btree (incaricopa);


--
-- TOC entry 1863 (class 1259 OID 18788)
-- Dependencies: 1550
-- Name: orgcrim_in; Type: INDEX; Schema: public; Owner: procura; Tablespace: 
--

CREATE INDEX orgcrim_in ON appartenenza USING btree (organizzazionecriminale);


--
-- TOC entry 1924 (class 2620 OID 18789)
-- Dependencies: 1563 19
-- Name: archiviazione; Type: TRIGGER; Schema: public; Owner: procura
--

CREATE TRIGGER archiviazione
    AFTER UPDATE ON processo
    FOR EACH ROW
    EXECUTE PROCEDURE archiviazione();


--
-- TOC entry 1920 (class 2620 OID 18790)
-- Dependencies: 20 1552
-- Name: carico; Type: TRIGGER; Schema: public; Owner: procura
--

CREATE TRIGGER carico
    BEFORE DELETE OR UPDATE ON citazione
    FOR EACH ROW
    EXECUTE PROCEDURE carico();


--
-- TOC entry 1918 (class 2620 OID 18791)
-- Dependencies: 21 1551
-- Name: citazione; Type: TRIGGER; Schema: public; Owner: procura
--

CREATE TRIGGER citazione
    BEFORE INSERT OR UPDATE ON carico
    FOR EACH ROW
    EXECUTE PROCEDURE citazione();


--
-- TOC entry 1929 (class 2620 OID 18792)
-- Dependencies: 22 1564
-- Name: conclusioneprocesso; Type: TRIGGER; Schema: public; Owner: procura
--

CREATE TRIGGER conclusioneprocesso
    AFTER INSERT ON proscioglimento
    FOR EACH ROW
    EXECUTE PROCEDURE conclusioneprocesso();


--
-- TOC entry 1921 (class 2620 OID 18793)
-- Dependencies: 22 1553
-- Name: conclusioneprocesso; Type: TRIGGER; Schema: public; Owner: procura
--

CREATE TRIGGER conclusioneprocesso
    AFTER INSERT ON condanna
    FOR EACH ROW
    EXECUTE PROCEDURE conclusioneprocesso();


--
-- TOC entry 1930 (class 2620 OID 18794)
-- Dependencies: 23 1564
-- Name: condanna; Type: TRIGGER; Schema: public; Owner: procura
--

CREATE TRIGGER condanna
    BEFORE INSERT OR UPDATE ON proscioglimento
    FOR EACH ROW
    EXECUTE PROCEDURE condanna();


--
-- TOC entry 1925 (class 2620 OID 18795)
-- Dependencies: 1563 24
-- Name: datafine; Type: TRIGGER; Schema: public; Owner: procura
--

CREATE TRIGGER datafine
    BEFORE UPDATE ON processo
    FOR EACH ROW
    EXECUTE PROCEDURE datafine();


--
-- TOC entry 1926 (class 2620 OID 18796)
-- Dependencies: 1563 25
-- Name: dataindagine; Type: TRIGGER; Schema: public; Owner: procura
--

CREATE TRIGGER dataindagine
    BEFORE INSERT OR UPDATE ON processo
    FOR EACH ROW
    EXECUTE PROCEDURE dataindagine();


--
-- TOC entry 1923 (class 2620 OID 18797)
-- Dependencies: 1560 26
-- Name: dataprocesso; Type: TRIGGER; Schema: public; Owner: procura
--

CREATE TRIGGER dataprocesso
    BEFORE UPDATE ON indagine
    FOR EACH ROW
    EXECUTE PROCEDURE dataprocesso();


--
-- TOC entry 1919 (class 2620 OID 18798)
-- Dependencies: 27 1551
-- Name: illecito; Type: TRIGGER; Schema: public; Owner: procura
--

CREATE TRIGGER illecito
    BEFORE INSERT OR UPDATE ON carico
    FOR EACH ROW
    EXECUTE PROCEDURE illecito();


--
-- TOC entry 1931 (class 2620 OID 18799)
-- Dependencies: 1566 33
-- Name: processo; Type: TRIGGER; Schema: public; Owner: procura
--

CREATE TRIGGER processo
    AFTER DELETE OR UPDATE ON prova
    FOR EACH ROW
    EXECUTE PROCEDURE processo();


--
-- TOC entry 1922 (class 2620 OID 18800)
-- Dependencies: 28 1553
-- Name: proscioglimento; Type: TRIGGER; Schema: public; Owner: procura
--

CREATE TRIGGER proscioglimento
    BEFORE INSERT OR UPDATE ON condanna
    FOR EACH ROW
    EXECUTE PROCEDURE proscioglimento();


--
-- TOC entry 1927 (class 2620 OID 18801)
-- Dependencies: 29 1563
-- Name: prove; Type: TRIGGER; Schema: public; Owner: procura
--

CREATE TRIGGER prove
    BEFORE INSERT OR UPDATE ON processo
    FOR EACH ROW
    EXECUTE PROCEDURE prove();


--
-- TOC entry 1928 (class 2620 OID 18802)
-- Dependencies: 30 1563
-- Name: valoriiniziali; Type: TRIGGER; Schema: public; Owner: procura
--

CREATE TRIGGER valoriiniziali
    BEFORE INSERT ON processo
    FOR EACH ROW
    EXECUTE PROCEDURE valoriiniziali();


--
-- TOC entry 1917 (class 2606 OID 18803)
-- Dependencies: 1560 1566 1881
-- Name: Indagine_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY prova
    ADD CONSTRAINT "Indagine_fk" FOREIGN KEY (indagine) REFERENCES indagine(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1903 (class 2606 OID 18808)
-- Dependencies: 1873 1555 1550
-- Name: imputato_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY appartenenza
    ADD CONSTRAINT imputato_fk FOREIGN KEY (imputato) REFERENCES imputato(indagato) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1905 (class 2606 OID 18813)
-- Dependencies: 1551 1555 1873
-- Name: imputato_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY carico
    ADD CONSTRAINT imputato_fk FOREIGN KEY (imputato) REFERENCES imputato(indagato) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1909 (class 2606 OID 18818)
-- Dependencies: 1553 1555 1873
-- Name: imputato_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY condanna
    ADD CONSTRAINT imputato_fk FOREIGN KEY (imputato) REFERENCES imputato(indagato) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1915 (class 2606 OID 18823)
-- Dependencies: 1555 1564 1873
-- Name: imputato_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY proscioglimento
    ADD CONSTRAINT imputato_fk FOREIGN KEY (imputato) REFERENCES imputato(indagato) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1911 (class 2606 OID 18828)
-- Dependencies: 1556 1554 1875
-- Name: incaricopa_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY copertura
    ADD CONSTRAINT incaricopa_fk FOREIGN KEY (incaricopa) REFERENCES incaricopa(nome) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1907 (class 2606 OID 18833)
-- Dependencies: 1558 1552 1877
-- Name: indagato_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY citazione
    ADD CONSTRAINT indagato_fk FOREIGN KEY (indagato) REFERENCES indagato(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1912 (class 2606 OID 18838)
-- Dependencies: 1558 1554 1877
-- Name: indagato_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY copertura
    ADD CONSTRAINT indagato_fk FOREIGN KEY (indagato) REFERENCES indagato(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1913 (class 2606 OID 18843)
-- Dependencies: 1555 1877 1558
-- Name: indagato_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY imputato
    ADD CONSTRAINT indagato_fk FOREIGN KEY (indagato) REFERENCES indagato(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1908 (class 2606 OID 18848)
-- Dependencies: 1552 1881 1560
-- Name: indagine_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY citazione
    ADD CONSTRAINT indagine_fk FOREIGN KEY (indagine) REFERENCES indagine(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1914 (class 2606 OID 18853)
-- Dependencies: 1560 1881 1563
-- Name: indagine_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY processo
    ADD CONSTRAINT indagine_fk FOREIGN KEY (indagine) REFERENCES indagine(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1904 (class 2606 OID 18858)
-- Dependencies: 1550 1883 1561
-- Name: organizzazionecriminale_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY appartenenza
    ADD CONSTRAINT organizzazionecriminale_fk FOREIGN KEY (organizzazionecriminale) REFERENCES organizzazionecriminale(nome) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1906 (class 2606 OID 18863)
-- Dependencies: 1551 1885 1563
-- Name: processo_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY carico
    ADD CONSTRAINT processo_fk FOREIGN KEY (processo) REFERENCES processo(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1910 (class 2606 OID 18868)
-- Dependencies: 1885 1563 1553
-- Name: processo_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY condanna
    ADD CONSTRAINT processo_fk FOREIGN KEY (processo) REFERENCES processo(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1916 (class 2606 OID 18873)
-- Dependencies: 1563 1564 1885
-- Name: processo_fk; Type: FK CONSTRAINT; Schema: public; Owner: procura
--

ALTER TABLE ONLY proscioglimento
    ADD CONSTRAINT processo_fk FOREIGN KEY (processo) REFERENCES processo(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1954 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2011-02-01 11:41:15 CET

--
-- PostgreSQL database dump complete
--

