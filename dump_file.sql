--
-- PostgreSQL database dump
--

-- Dumped from database version 17.1 (Ubuntu 17.1-1.pgdg24.10+1)
-- Dumped by pg_dump version 17.1 (Ubuntu 17.1-1.pgdg24.10+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: chargeability_manager; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA chargeability_manager;


ALTER SCHEMA chargeability_manager OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: calendar; Type: TABLE; Schema: chargeability_manager; Owner: postgres
--

CREATE TABLE chargeability_manager.calendar (
    dd_cal date NOT NULL,
    dd_desc character varying(20),
    mm_cal character varying(2),
    mm_desc character varying(20),
    yy_cal integer,
    work_day boolean,
    fiscal_year integer,
    fortnight integer
);


ALTER TABLE chargeability_manager.calendar OWNER TO postgres;

--
-- Name: resources; Type: TABLE; Schema: chargeability_manager; Owner: postgres
--

CREATE TABLE chargeability_manager.resources (
    eid character varying(100) NOT NULL,
    last_name character varying(100),
    first_name character varying(100),
    level integer,
    loaded_cost double precision,
    office character varying(100),
    dte character varying(100)
);


ALTER TABLE chargeability_manager.resources OWNER TO postgres;

--
-- Name: time_report; Type: TABLE; Schema: chargeability_manager; Owner: postgres
--

CREATE TABLE chargeability_manager.time_report (
    eid character varying(100) NOT NULL,
    wbs character varying(20) NOT NULL,
    yy_cal integer,
    mm_cal character varying(2) NOT NULL,
    fortnight integer NOT NULL,
    work_hh double precision,
    fl_forecast boolean DEFAULT false
);


ALTER TABLE chargeability_manager.time_report OWNER TO postgres;

--
-- Name: wbs; Type: TABLE; Schema: chargeability_manager; Owner: postgres
--

CREATE TABLE chargeability_manager.wbs (
    wbs character varying(20) NOT NULL,
    wbs_type character varying(20),
    project_name character varying(100),
    budget_mm double precision,
    budget_tot double precision
);


ALTER TABLE chargeability_manager.wbs OWNER TO postgres;

--
-- Name: check_budget_all; Type: VIEW; Schema: chargeability_manager; Owner: postgres
--

CREATE VIEW chargeability_manager.check_budget_all AS
 WITH cal AS (
         SELECT DISTINCT calendar.fiscal_year,
            calendar.yy_cal,
            calendar.mm_cal,
            calendar.fortnight
           FROM chargeability_manager.calendar
          WHERE (calendar.dd_cal < ( SELECT DISTINCT max((date_trunc('month'::text, (to_date((((time_report.yy_cal || '-'::text) || (time_report.mm_cal)::text) || '-01'::text), 'YYYY-MM-DD'::text) + '1 mon'::interval)) - '1 day'::interval)) AS last_day_of_month
                   FROM chargeability_manager.time_report))
        )
 SELECT c.fiscal_year,
    w.project_name,
    sum((r.loaded_cost * tr.work_hh)) AS tot_cost,
    (max(w.budget_mm) * (count(DISTINCT c.mm_cal))::double precision) AS budget_ytd
   FROM (((chargeability_manager.wbs w
     JOIN cal c ON ((1 = 1)))
     LEFT JOIN chargeability_manager.time_report tr ON ((((w.wbs)::text = (tr.wbs)::text) AND (tr.yy_cal = c.yy_cal) AND ((tr.mm_cal)::text = (c.mm_cal)::text) AND (tr.fortnight = c.fortnight))))
     LEFT JOIN chargeability_manager.resources r ON (((r.eid)::text = (tr.eid)::text)))
  WHERE (COALESCE(w.budget_mm, (0)::double precision) > (0)::double precision)
  GROUP BY c.fiscal_year, w.project_name;


ALTER VIEW chargeability_manager.check_budget_all OWNER TO postgres;

--
-- Name: check_budget_tr; Type: VIEW; Schema: chargeability_manager; Owner: postgres
--

CREATE VIEW chargeability_manager.check_budget_tr AS
 WITH cal AS (
         SELECT DISTINCT calendar.fiscal_year,
            calendar.yy_cal,
            calendar.mm_cal,
            calendar.fortnight
           FROM chargeability_manager.calendar
          WHERE (calendar.dd_cal < ( SELECT DISTINCT max((date_trunc('month'::text, (to_date((((time_report.yy_cal || '-'::text) || (time_report.mm_cal)::text) || '-01'::text), 'YYYY-MM-DD'::text) + '1 mon'::interval)) - '1 day'::interval)) AS last_day_of_month
                   FROM chargeability_manager.time_report))
        )
 SELECT c.fiscal_year,
    w.project_name,
    c.yy_cal,
    c.mm_cal,
    c.fortnight,
    sum((r.loaded_cost * tr.work_hh)) AS tot_cost,
    (max(w.budget_mm) * (count(DISTINCT c.mm_cal))::double precision) AS budget_ytd
   FROM (((chargeability_manager.wbs w
     JOIN cal c ON ((1 = 1)))
     JOIN chargeability_manager.time_report tr ON ((((w.wbs)::text = (tr.wbs)::text) AND (tr.yy_cal = c.yy_cal) AND ((tr.mm_cal)::text = (c.mm_cal)::text) AND (tr.fortnight = c.fortnight))))
     JOIN chargeability_manager.resources r ON (((r.eid)::text = (tr.eid)::text)))
  WHERE (COALESCE(w.budget_mm, (0)::double precision) > (0)::double precision)
  GROUP BY c.fiscal_year, w.project_name, c.yy_cal, c.mm_cal, c.fortnight;


ALTER VIEW chargeability_manager.check_budget_tr OWNER TO postgres;

--
-- Name: check_budget_tr_eid; Type: VIEW; Schema: chargeability_manager; Owner: postgres
--

CREATE VIEW chargeability_manager.check_budget_tr_eid AS
 WITH cal AS (
         SELECT DISTINCT calendar.fiscal_year,
            calendar.yy_cal,
            calendar.mm_cal,
            calendar.fortnight
           FROM chargeability_manager.calendar
          WHERE (calendar.dd_cal < ( SELECT DISTINCT max((date_trunc('month'::text, (to_date((((time_report.yy_cal || '-'::text) || (time_report.mm_cal)::text) || '-01'::text), 'YYYY-MM-DD'::text) + '1 mon'::interval)) - '1 day'::interval)) AS last_day_of_month
                   FROM chargeability_manager.time_report))
        )
 SELECT c.fiscal_year,
    w.project_name,
    c.yy_cal,
    c.mm_cal,
    c.fortnight,
    r.eid,
    sum((r.loaded_cost * tr.work_hh)) AS tot_cost,
    (max(w.budget_mm) * (count(DISTINCT c.mm_cal))::double precision) AS budget_ytd
   FROM (((chargeability_manager.wbs w
     JOIN cal c ON ((1 = 1)))
     JOIN chargeability_manager.time_report tr ON ((((w.wbs)::text = (tr.wbs)::text) AND (tr.yy_cal = c.yy_cal) AND ((tr.mm_cal)::text = (c.mm_cal)::text) AND (tr.fortnight = c.fortnight))))
     JOIN chargeability_manager.resources r ON (((r.eid)::text = (tr.eid)::text)))
  WHERE (COALESCE(w.budget_mm, (0)::double precision) > (0)::double precision)
  GROUP BY c.fiscal_year, w.project_name, c.yy_cal, c.mm_cal, c.fortnight, r.eid;


ALTER VIEW chargeability_manager.check_budget_tr_eid OWNER TO postgres;

--
-- Name: chg_target; Type: TABLE; Schema: chargeability_manager; Owner: postgres
--

CREATE TABLE chargeability_manager.chg_target (
    level integer NOT NULL,
    chg_t double precision
);


ALTER TABLE chargeability_manager.chg_target OWNER TO postgres;

--
-- Name: check_forecast; Type: VIEW; Schema: chargeability_manager; Owner: postgres
--

CREATE VIEW chargeability_manager.check_forecast AS
 WITH hours AS (
         SELECT calendar.yy_cal,
            calendar.mm_cal,
            calendar.fortnight,
            (count(calendar.dd_cal) * 8) AS tot_hour
           FROM chargeability_manager.calendar
          WHERE (calendar.work_day = true)
          GROUP BY calendar.yy_cal, calendar.mm_cal, calendar.fortnight
        ), no_chg AS (
         SELECT tr_1.eid,
            tr_1.yy_cal,
            tr_1.mm_cal,
            tr_1.fortnight,
            sum(tr_1.work_hh) AS no_chg
           FROM (chargeability_manager.time_report tr_1
             JOIN chargeability_manager.wbs w ON (((tr_1.wbs)::text = (w.wbs)::text)))
          WHERE ((w.wbs_type)::text = 'NOCHG'::text)
          GROUP BY tr_1.eid, tr_1.yy_cal, tr_1.mm_cal, tr_1.fortnight
        )
 SELECT tr.yy_cal,
    tr.mm_cal,
    tr.fortnight,
    tr.eid,
    sum(tr.work_hh) AS work_hh,
    max(hh.tot_hour) AS tot_hour,
    (((sum(tr.work_hh) - max(COALESCE(nc.no_chg, (0)::double precision))) / (max(hh.tot_hour))::double precision) * (100)::double precision) AS chg,
    (((max(hh.tot_hour))::double precision * max(ct.chg_t)) / (100)::double precision) AS hh_chg,
    max(COALESCE(nc.no_chg, (0)::double precision)) AS hh_no_chg,
    ((max(hh.tot_hour))::double precision - (((max(hh.tot_hour))::double precision * max(ct.chg_t)) / (100)::double precision)) AS calc_meeting_time,
    (((max(hh.tot_hour))::double precision - (((max(hh.tot_hour))::double precision * max(ct.chg_t)) / (100)::double precision)) - max(COALESCE(nc.no_chg, (0)::double precision))) AS hh_no_chg_to_assign
   FROM ((((hours hh
     JOIN chargeability_manager.time_report tr ON (((hh.yy_cal = tr.yy_cal) AND ((hh.mm_cal)::text = (tr.mm_cal)::text) AND (hh.fortnight = tr.fortnight))))
     JOIN chargeability_manager.resources r ON (((tr.eid)::text = (r.eid)::text)))
     JOIN chargeability_manager.chg_target ct ON ((ct.level = r.level)))
     LEFT JOIN no_chg nc ON ((((nc.eid)::text = (tr.eid)::text) AND (nc.yy_cal = tr.yy_cal) AND ((nc.mm_cal)::text = (tr.mm_cal)::text) AND (nc.fortnight = tr.fortnight))))
  WHERE (tr.fl_forecast = true)
  GROUP BY tr.yy_cal, tr.mm_cal, tr.fortnight, tr.eid;


ALTER VIEW chargeability_manager.check_forecast OWNER TO postgres;

--
-- Name: check_no_chg; Type: VIEW; Schema: chargeability_manager; Owner: postgres
--

CREATE VIEW chargeability_manager.check_no_chg AS
 WITH hours AS (
         SELECT calendar.yy_cal,
            calendar.mm_cal,
            calendar.fortnight,
            (count(calendar.dd_cal) * 8) AS tot_hour
           FROM chargeability_manager.calendar
          WHERE (calendar.work_day = true)
          GROUP BY calendar.yy_cal, calendar.mm_cal, calendar.fortnight
        ), no_chg AS (
         SELECT tr_1.eid,
            tr_1.yy_cal,
            tr_1.mm_cal,
            tr_1.fortnight,
            sum(tr_1.work_hh) AS no_chg
           FROM (chargeability_manager.time_report tr_1
             JOIN chargeability_manager.wbs w ON (((tr_1.wbs)::text = (w.wbs)::text)))
          WHERE ((w.wbs_type)::text = 'NOCHG'::text)
          GROUP BY tr_1.eid, tr_1.yy_cal, tr_1.mm_cal, tr_1.fortnight
        )
 SELECT tr.yy_cal,
    tr.mm_cal,
    tr.fortnight,
    tr.eid,
    sum(tr.work_hh) AS work_hh,
    max(hh.tot_hour) AS tot_hour,
    (((sum(tr.work_hh) - max(COALESCE(nc.no_chg, (0)::double precision))) / (max(hh.tot_hour))::double precision) * (100)::double precision) AS chg,
    (((max(hh.tot_hour))::double precision * max(ct.chg_t)) / (100)::double precision) AS hh_chg,
    max(COALESCE(nc.no_chg, (0)::double precision)) AS hh_no_chg,
    ((max(hh.tot_hour))::double precision - (((max(hh.tot_hour))::double precision * max(ct.chg_t)) / (100)::double precision)) AS calc_meeting_time,
    (((max(hh.tot_hour))::double precision - (((max(hh.tot_hour))::double precision * max(ct.chg_t)) / (100)::double precision)) - max(COALESCE(nc.no_chg, (0)::double precision))) AS hh_no_chg_to_assign
   FROM ((((hours hh
     JOIN chargeability_manager.time_report tr ON (((hh.yy_cal = tr.yy_cal) AND ((hh.mm_cal)::text = (tr.mm_cal)::text) AND (hh.fortnight = tr.fortnight))))
     JOIN chargeability_manager.resources r ON (((tr.eid)::text = (r.eid)::text)))
     JOIN chargeability_manager.chg_target ct ON ((ct.level = r.level)))
     LEFT JOIN no_chg nc ON ((((nc.eid)::text = (tr.eid)::text) AND (nc.yy_cal = tr.yy_cal) AND ((nc.mm_cal)::text = (tr.mm_cal)::text) AND (nc.fortnight = tr.fortnight))))
  GROUP BY tr.yy_cal, tr.mm_cal, tr.fortnight, tr.eid;


ALTER VIEW chargeability_manager.check_no_chg OWNER TO postgres;

--
-- Name: chg_mm; Type: VIEW; Schema: chargeability_manager; Owner: postgres
--

CREATE VIEW chargeability_manager.chg_mm AS
 WITH tot_hours AS (
         SELECT calendar.fiscal_year,
            calendar.yy_cal,
            calendar.mm_cal,
            sum(
                CASE
                    WHEN (calendar.work_day = true) THEN 8
                    ELSE 0
                END) AS tot_hours
           FROM chargeability_manager.calendar
          GROUP BY calendar.fiscal_year, calendar.yy_cal, calendar.mm_cal
        ), tr AS (
         SELECT tr_1.eid,
            tr_1.yy_cal,
            tr_1.mm_cal,
            tr_1.fl_forecast,
            sum(tr_1.work_hh) AS work_hh,
            sum(
                CASE
                    WHEN ((wbs.wbs_type)::text = 'CHG'::text) THEN tr_1.work_hh
                    ELSE (0)::double precision
                END) AS work_hh_chg,
            sum(
                CASE
                    WHEN ((wbs.wbs_type)::text = 'NOCHG'::text) THEN tr_1.work_hh
                    ELSE (0)::double precision
                END) AS work_hh_nochg,
            sum(
                CASE
                    WHEN ((wbs.wbs_type)::text = '-'::text) THEN tr_1.work_hh
                    ELSE (0)::double precision
                END) AS work_hh_no_impact
           FROM (chargeability_manager.time_report tr_1
             LEFT JOIN chargeability_manager.wbs wbs ON (((tr_1.wbs)::text = (wbs.wbs)::text)))
          GROUP BY tr_1.eid, tr_1.yy_cal, tr_1.mm_cal, tr_1.fl_forecast
        )
 SELECT tr.eid,
    c.fiscal_year,
    tr.yy_cal,
    tr.mm_cal,
    tr.fl_forecast,
    max(c.tot_hours) AS tot_hours,
    max(tr.work_hh) AS work_hh,
    max(tr.work_hh_chg) AS work_hh_chg,
    max(tr.work_hh_nochg) AS work_hh_nochg,
    max(tr.work_hh_no_impact) AS work_hh_no_impact,
    ((max(tr.work_hh_chg) / (max(tr.work_hh) - max(tr.work_hh_no_impact))) * (100)::double precision) AS chg
   FROM (tr
     JOIN tot_hours c ON ((((tr.mm_cal)::text = (c.mm_cal)::text) AND (c.yy_cal = tr.yy_cal))))
  GROUP BY tr.eid, c.fiscal_year, tr.yy_cal, tr.mm_cal, tr.fl_forecast;


ALTER VIEW chargeability_manager.chg_mm OWNER TO postgres;

--
-- Name: chg_forecast_yy; Type: VIEW; Schema: chargeability_manager; Owner: postgres
--

CREATE VIEW chargeability_manager.chg_forecast_yy AS
 SELECT eid,
    fiscal_year,
    sum(tot_hours) AS tot_hours,
    sum(work_hh) AS work_hh,
    sum(work_hh_chg) AS work_hh_chg,
    sum(work_hh_nochg) AS work_hh_nochg,
    sum(work_hh_no_impact) AS work_hh_no_impact,
    ((sum(work_hh_chg) / (sum(tot_hours))::double precision) * (100)::double precision) AS chg
   FROM chargeability_manager.chg_mm
  GROUP BY eid, fiscal_year;


ALTER VIEW chargeability_manager.chg_forecast_yy OWNER TO postgres;

--
-- Name: chg_mm_old; Type: VIEW; Schema: chargeability_manager; Owner: postgres
--

CREATE VIEW chargeability_manager.chg_mm_old AS
 WITH tot_hours AS (
         SELECT calendar.fiscal_year,
            calendar.yy_cal,
            calendar.mm_cal,
            sum(
                CASE
                    WHEN (calendar.work_day = true) THEN 8
                    ELSE 0
                END) AS tot_hours
           FROM chargeability_manager.calendar
          GROUP BY calendar.fiscal_year, calendar.yy_cal, calendar.mm_cal
        ), tr AS (
         SELECT tr_1.eid,
            tr_1.yy_cal,
            tr_1.mm_cal,
            sum(tr_1.work_hh) AS work_hh,
            sum(
                CASE
                    WHEN ((wbs.wbs_type)::text = 'CHG'::text) THEN tr_1.work_hh
                    ELSE (0)::double precision
                END) AS work_hh_chg,
            sum(
                CASE
                    WHEN ((wbs.wbs_type)::text = 'NOCHG'::text) THEN tr_1.work_hh
                    ELSE (0)::double precision
                END) AS work_hh_nochg,
            sum(
                CASE
                    WHEN ((wbs.wbs_type)::text = '-'::text) THEN tr_1.work_hh
                    ELSE (0)::double precision
                END) AS work_hh_no_impact
           FROM (chargeability_manager.time_report tr_1
             LEFT JOIN chargeability_manager.wbs wbs ON (((tr_1.wbs)::text = (wbs.wbs)::text)))
          GROUP BY tr_1.eid, tr_1.yy_cal, tr_1.mm_cal
        )
 SELECT tr.eid,
    c.fiscal_year,
    tr.yy_cal,
    tr.mm_cal,
    max(c.tot_hours) AS tot_hours,
    max(tr.work_hh) AS work_hh,
    max(tr.work_hh_chg) AS work_hh_chg,
    max(tr.work_hh_nochg) AS work_hh_nochg,
    max(tr.work_hh_no_impact) AS work_hh_no_impact,
    ((max(tr.work_hh_chg) / (max(tr.work_hh) - max(tr.work_hh_no_impact))) * (100)::double precision) AS chg
   FROM (tr
     JOIN tot_hours c ON ((((tr.mm_cal)::text = (c.mm_cal)::text) AND (c.yy_cal = tr.yy_cal))))
  GROUP BY tr.eid, c.fiscal_year, tr.yy_cal, tr.mm_cal;


ALTER VIEW chargeability_manager.chg_mm_old OWNER TO postgres;

--
-- Name: chg_yy; Type: VIEW; Schema: chargeability_manager; Owner: postgres
--

CREATE VIEW chargeability_manager.chg_yy AS
 SELECT eid,
    fiscal_year,
    sum(tot_hours) AS tot_hours,
    fl_forecast,
    sum(work_hh) AS work_hh,
    sum(work_hh_chg) AS work_hh_chg,
    sum(work_hh_nochg) AS work_hh_nochg,
    sum(work_hh_no_impact) AS work_hh_no_impact,
    ((sum(work_hh_chg) / (sum(tot_hours))::double precision) * (100)::double precision) AS chg
   FROM chargeability_manager.chg_mm
  WHERE (fl_forecast = false)
  GROUP BY eid, fiscal_year, fl_forecast;


ALTER VIEW chargeability_manager.chg_yy OWNER TO postgres;

--
-- Name: forecast_ferie; Type: TABLE; Schema: chargeability_manager; Owner: postgres
--

CREATE TABLE chargeability_manager.forecast_ferie (
    eid character varying(100),
    yy_cal integer,
    mm_cal character varying(2),
    fortnight integer,
    wbs text,
    work_hh double precision
);


ALTER TABLE chargeability_manager.forecast_ferie OWNER TO postgres;

--
-- Name: holidays; Type: TABLE; Schema: chargeability_manager; Owner: postgres
--

CREATE TABLE chargeability_manager.holidays (
    dd_cal date NOT NULL,
    holiday character varying(100)
);


ALTER TABLE chargeability_manager.holidays OWNER TO postgres;

--
-- Name: prg_budget; Type: TABLE; Schema: chargeability_manager; Owner: postgres
--

CREATE TABLE chargeability_manager.prg_budget (
    eid character varying(100),
    wbs text,
    perc_budget numeric
);


ALTER TABLE chargeability_manager.prg_budget OWNER TO postgres;

--
-- Name: report_tr_mm; Type: VIEW; Schema: chargeability_manager; Owner: postgres
--

CREATE VIEW chargeability_manager.report_tr_mm AS
 SELECT tr.eid,
    tr.yy_cal,
    tr.mm_cal,
    w.project_name,
    sum(
        CASE
            WHEN (tr.fortnight = 1) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS work_hh_tr1,
    sum(
        CASE
            WHEN (tr.fortnight = 2) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS work_hh_tr2
   FROM (chargeability_manager.time_report tr
     JOIN chargeability_manager.wbs w ON (((w.wbs)::text = (tr.wbs)::text)))
  GROUP BY tr.eid, tr.yy_cal, tr.mm_cal, w.project_name
  ORDER BY tr.eid, tr.mm_cal;


ALTER VIEW chargeability_manager.report_tr_mm OWNER TO postgres;

--
-- Name: report_tr_yy; Type: VIEW; Schema: chargeability_manager; Owner: postgres
--

CREATE VIEW chargeability_manager.report_tr_yy AS
 WITH cal_fy AS (
         SELECT DISTINCT c_1.fiscal_year,
            c_1.yy_cal,
            c_1.mm_cal
           FROM chargeability_manager.calendar c_1
        )
 SELECT c.fiscal_year,
    tr.eid,
    w.project_name,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '09'::text) AND (tr.fortnight = 1)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS settembre_tr1,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '09'::text) AND (tr.fortnight = 2)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS settembre_tr2,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '10'::text) AND (tr.fortnight = 1)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS ottobre_tr1,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '10'::text) AND (tr.fortnight = 2)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS ottobre_tr2,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '11'::text) AND (tr.fortnight = 1)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS novembre_tr1,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '11'::text) AND (tr.fortnight = 2)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS novembre_tr2,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '12'::text) AND (tr.fortnight = 1)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS dicembre_tr1,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '12'::text) AND (tr.fortnight = 2)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS dicembre_tr2,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '01'::text) AND (tr.fortnight = 1)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS gennaio_tr1,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '01'::text) AND (tr.fortnight = 2)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS gennaio_tr2,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '02'::text) AND (tr.fortnight = 1)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS febbraio_tr1,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '02'::text) AND (tr.fortnight = 2)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS febbraio_tr2,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '03'::text) AND (tr.fortnight = 1)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS marzo_tr1,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '03'::text) AND (tr.fortnight = 2)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS marzo_tr2,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '04'::text) AND (tr.fortnight = 1)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS aprile_tr1,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '04'::text) AND (tr.fortnight = 2)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS aprile_tr2,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '05'::text) AND (tr.fortnight = 1)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS maggio_tr1,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '05'::text) AND (tr.fortnight = 2)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS maggio_tr2,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '06'::text) AND (tr.fortnight = 1)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS giugno_tr1,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '06'::text) AND (tr.fortnight = 2)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS giugno_tr2,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '07'::text) AND (tr.fortnight = 1)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS luglio_tr1,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '07'::text) AND (tr.fortnight = 2)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS luglio_tr2,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '08'::text) AND (tr.fortnight = 1)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS agosto_tr1,
    sum(
        CASE
            WHEN (((tr.mm_cal)::text = '08'::text) AND (tr.fortnight = 2)) THEN tr.work_hh
            ELSE (0)::double precision
        END) AS agosto_tr2
   FROM ((chargeability_manager.time_report tr
     JOIN chargeability_manager.wbs w ON (((w.wbs)::text = (tr.wbs)::text)))
     JOIN cal_fy c ON (((c.yy_cal = tr.yy_cal) AND ((c.mm_cal)::text = (tr.mm_cal)::text))))
  GROUP BY c.fiscal_year, tr.eid, w.project_name
  ORDER BY c.fiscal_year, tr.eid, (sum(
        CASE
            WHEN (((tr.mm_cal)::text = '09'::text) AND (tr.fortnight = 1)) THEN tr.work_hh
            ELSE (0)::double precision
        END));


ALTER VIEW chargeability_manager.report_tr_yy OWNER TO postgres;

--
-- Name: template_tr; Type: TABLE; Schema: chargeability_manager; Owner: postgres
--

CREATE TABLE chargeability_manager.template_tr (
    eid character varying(100) NOT NULL,
    wbs character varying(20) NOT NULL,
    yy_cal integer,
    mm_cal character varying(2) NOT NULL,
    fortnight integer NOT NULL,
    perc_wbs integer,
    bool boolean
);


ALTER TABLE chargeability_manager.template_tr OWNER TO postgres;

--
-- Data for Name: calendar; Type: TABLE DATA; Schema: chargeability_manager; Owner: postgres
--

COPY chargeability_manager.calendar (dd_cal, dd_desc, mm_cal, mm_desc, yy_cal, work_day, fiscal_year, fortnight) FROM stdin;
2024-01-02	Tuesday	01	January	2024	t	2024	1
2024-01-03	Wednesday	01	January	2024	t	2024	1
2024-01-04	Thursday	01	January	2024	t	2024	1
2024-05-03	Friday	05	May	2024	t	2024	1
2024-09-07	Saturday	09	September	2024	f	2025	1
2024-09-08	Sunday	09	September	2024	f	2025	1
2024-09-09	Monday	09	September	2024	t	2025	1
2025-01-05	Sunday	01	January	2025	f	2025	1
2025-01-06	Monday	01	January	2025	t	2025	1
2025-05-09	Friday	05	May	2025	t	2025	1
2025-09-12	Friday	09	September	2025	t	2026	1
2025-09-13	Saturday	09	September	2025	f	2026	1
2025-09-14	Sunday	09	September	2025	f	2026	1
2026-01-10	Saturday	01	January	2026	f	2026	1
2026-01-11	Sunday	01	January	2026	f	2026	1
2026-01-12	Monday	01	January	2026	t	2026	1
2026-05-14	Thursday	05	May	2026	t	2026	1
2026-09-17	Thursday	09	September	2026	t	2027	2
2026-09-18	Friday	09	September	2026	t	2027	2
2026-09-19	Saturday	09	September	2026	f	2027	2
2027-01-15	Friday	01	January	2027	t	2027	1
2027-01-16	Saturday	01	January	2027	f	2027	2
2027-05-20	Thursday	05	May	2027	t	2027	2
2027-09-22	Wednesday	09	September	2027	t	2028	2
2027-09-23	Thursday	09	September	2027	t	2028	2
2027-09-24	Friday	09	September	2027	t	2028	2
2027-09-25	Saturday	09	September	2027	f	2028	2
2027-09-26	Sunday	09	September	2027	f	2028	2
2027-09-27	Monday	09	September	2027	t	2028	2
2027-09-28	Tuesday	09	September	2027	t	2028	2
2027-09-29	Wednesday	09	September	2027	t	2028	2
2027-09-30	Thursday	09	September	2027	t	2028	2
2027-10-01	Friday	10	October	2027	t	2028	1
2027-10-02	Saturday	10	October	2027	f	2028	1
2027-10-03	Sunday	10	October	2027	f	2028	1
2027-10-04	Monday	10	October	2027	t	2028	1
2027-10-05	Tuesday	10	October	2027	t	2028	1
2024-12-25	Wednesday	12	December	2024	f	2025	2
2025-04-21	Monday	04	April	2025	f	2025	2
2025-04-25	Friday	04	April	2025	f	2025	2
2025-05-01	Thursday	05	May	2025	f	2025	1
2025-08-15	Friday	08	August	2025	f	2025	1
2025-12-26	Friday	12	December	2025	f	2026	2
2026-01-01	Thursday	01	January	2026	f	2026	1
2027-12-08	Wednesday	12	December	2027	f	2028	1
2027-12-26	Sunday	12	December	2027	f	2028	2
2025-12-25	Thursday	12	December	2025	f	2026	2
2026-04-06	Monday	04	April	2026	f	2026	1
2026-04-25	Saturday	04	April	2026	f	2026	2
2026-05-01	Friday	05	May	2026	f	2026	1
2026-08-15	Saturday	08	August	2026	f	2026	1
2026-12-26	Saturday	12	December	2026	f	2027	2
2027-01-01	Friday	01	January	2027	f	2027	1
2026-12-25	Friday	12	December	2026	f	2027	2
2024-01-05	Friday	01	January	2024	t	2024	1
2024-01-06	Saturday	01	January	2024	f	2024	1
2024-01-07	Sunday	01	January	2024	f	2024	1
2024-01-08	Monday	01	January	2024	t	2024	1
2024-01-09	Tuesday	01	January	2024	t	2024	1
2024-01-10	Wednesday	01	January	2024	t	2024	1
2024-01-11	Thursday	01	January	2024	t	2024	1
2024-01-12	Friday	01	January	2024	t	2024	1
2024-01-13	Saturday	01	January	2024	f	2024	1
2024-01-14	Sunday	01	January	2024	f	2024	1
2024-01-15	Monday	01	January	2024	t	2024	1
2024-01-16	Tuesday	01	January	2024	t	2024	2
2024-01-17	Wednesday	01	January	2024	t	2024	2
2024-01-18	Thursday	01	January	2024	t	2024	2
2024-01-19	Friday	01	January	2024	t	2024	2
2024-01-20	Saturday	01	January	2024	f	2024	2
2024-01-21	Sunday	01	January	2024	f	2024	2
2024-01-22	Monday	01	January	2024	t	2024	2
2024-01-23	Tuesday	01	January	2024	t	2024	2
2024-01-24	Wednesday	01	January	2024	t	2024	2
2024-01-25	Thursday	01	January	2024	t	2024	2
2024-01-26	Friday	01	January	2024	t	2024	2
2024-01-27	Saturday	01	January	2024	f	2024	2
2024-01-28	Sunday	01	January	2024	f	2024	2
2024-01-29	Monday	01	January	2024	t	2024	2
2024-01-30	Tuesday	01	January	2024	t	2024	2
2024-01-31	Wednesday	01	January	2024	t	2024	2
2024-02-01	Thursday	02	February	2024	t	2024	1
2024-02-02	Friday	02	February	2024	t	2024	1
2024-02-03	Saturday	02	February	2024	f	2024	1
2024-02-04	Sunday	02	February	2024	f	2024	1
2024-02-05	Monday	02	February	2024	t	2024	1
2024-02-06	Tuesday	02	February	2024	t	2024	1
2024-02-07	Wednesday	02	February	2024	t	2024	1
2024-02-08	Thursday	02	February	2024	t	2024	1
2024-02-09	Friday	02	February	2024	t	2024	1
2024-02-10	Saturday	02	February	2024	f	2024	1
2024-02-11	Sunday	02	February	2024	f	2024	1
2024-02-12	Monday	02	February	2024	t	2024	1
2024-02-13	Tuesday	02	February	2024	t	2024	1
2024-02-14	Wednesday	02	February	2024	t	2024	1
2024-02-15	Thursday	02	February	2024	t	2024	1
2024-02-16	Friday	02	February	2024	t	2024	2
2024-02-17	Saturday	02	February	2024	f	2024	2
2024-02-18	Sunday	02	February	2024	f	2024	2
2024-02-19	Monday	02	February	2024	t	2024	2
2024-02-20	Tuesday	02	February	2024	t	2024	2
2024-02-21	Wednesday	02	February	2024	t	2024	2
2024-02-22	Thursday	02	February	2024	t	2024	2
2024-02-23	Friday	02	February	2024	t	2024	2
2024-02-24	Saturday	02	February	2024	f	2024	2
2027-03-29	Monday	03	March	2027	f	2027	2
2027-04-25	Sunday	04	April	2027	f	2027	2
2027-05-01	Saturday	05	May	2027	f	2027	1
2027-08-15	Sunday	08	August	2027	f	2027	1
2024-11-01	Friday	11	November	2024	f	2025	1
2025-11-01	Saturday	11	November	2025	f	2026	1
2026-11-01	Sunday	11	November	2026	f	2027	1
2027-11-01	Monday	11	November	2027	f	2028	1
2027-12-25	Saturday	12	December	2027	f	2028	2
2024-02-25	Sunday	02	February	2024	f	2024	2
2024-02-26	Monday	02	February	2024	t	2024	2
2024-02-27	Tuesday	02	February	2024	t	2024	2
2024-02-28	Wednesday	02	February	2024	t	2024	2
2024-02-29	Thursday	02	February	2024	t	2024	2
2024-03-01	Friday	03	March	2024	t	2024	1
2024-03-02	Saturday	03	March	2024	f	2024	1
2024-03-03	Sunday	03	March	2024	f	2024	1
2024-03-04	Monday	03	March	2024	t	2024	1
2024-03-05	Tuesday	03	March	2024	t	2024	1
2024-03-06	Wednesday	03	March	2024	t	2024	1
2024-03-07	Thursday	03	March	2024	t	2024	1
2024-03-08	Friday	03	March	2024	t	2024	1
2024-03-09	Saturday	03	March	2024	f	2024	1
2024-03-10	Sunday	03	March	2024	f	2024	1
2024-03-11	Monday	03	March	2024	t	2024	1
2024-03-12	Tuesday	03	March	2024	t	2024	1
2024-03-13	Wednesday	03	March	2024	t	2024	1
2024-03-14	Thursday	03	March	2024	t	2024	1
2024-03-15	Friday	03	March	2024	t	2024	1
2024-03-16	Saturday	03	March	2024	f	2024	2
2024-03-17	Sunday	03	March	2024	f	2024	2
2024-03-18	Monday	03	March	2024	t	2024	2
2024-03-19	Tuesday	03	March	2024	t	2024	2
2024-03-20	Wednesday	03	March	2024	t	2024	2
2024-03-21	Thursday	03	March	2024	t	2024	2
2024-03-22	Friday	03	March	2024	t	2024	2
2024-03-23	Saturday	03	March	2024	f	2024	2
2024-03-24	Sunday	03	March	2024	f	2024	2
2024-03-25	Monday	03	March	2024	t	2024	2
2024-03-26	Tuesday	03	March	2024	t	2024	2
2024-03-27	Wednesday	03	March	2024	t	2024	2
2024-03-28	Thursday	03	March	2024	t	2024	2
2024-03-29	Friday	03	March	2024	t	2024	2
2024-03-30	Saturday	03	March	2024	f	2024	2
2024-03-31	Sunday	03	March	2024	f	2024	2
2024-04-02	Tuesday	04	April	2024	t	2024	1
2024-04-03	Wednesday	04	April	2024	t	2024	1
2024-04-04	Thursday	04	April	2024	t	2024	1
2024-04-05	Friday	04	April	2024	t	2024	1
2024-04-06	Saturday	04	April	2024	f	2024	1
2024-04-07	Sunday	04	April	2024	f	2024	1
2024-04-08	Monday	04	April	2024	t	2024	1
2024-04-09	Tuesday	04	April	2024	t	2024	1
2024-04-10	Wednesday	04	April	2024	t	2024	1
2024-04-11	Thursday	04	April	2024	t	2024	1
2024-04-12	Friday	04	April	2024	t	2024	1
2024-04-13	Saturday	04	April	2024	f	2024	1
2024-04-14	Sunday	04	April	2024	f	2024	1
2024-04-15	Monday	04	April	2024	t	2024	1
2024-04-16	Tuesday	04	April	2024	t	2024	2
2024-04-17	Wednesday	04	April	2024	t	2024	2
2024-04-18	Thursday	04	April	2024	t	2024	2
2024-04-19	Friday	04	April	2024	t	2024	2
2024-04-20	Saturday	04	April	2024	f	2024	2
2024-04-21	Sunday	04	April	2024	f	2024	2
2024-04-22	Monday	04	April	2024	t	2024	2
2024-04-23	Tuesday	04	April	2024	t	2024	2
2024-04-24	Wednesday	04	April	2024	t	2024	2
2024-04-26	Friday	04	April	2024	t	2024	2
2024-04-27	Saturday	04	April	2024	f	2024	2
2024-04-28	Sunday	04	April	2024	f	2024	2
2024-04-29	Monday	04	April	2024	t	2024	2
2024-04-30	Tuesday	04	April	2024	t	2024	2
2024-05-02	Thursday	05	May	2024	t	2024	1
2024-05-04	Saturday	05	May	2024	f	2024	1
2024-05-05	Sunday	05	May	2024	f	2024	1
2024-05-06	Monday	05	May	2024	t	2024	1
2024-05-07	Tuesday	05	May	2024	t	2024	1
2024-05-08	Wednesday	05	May	2024	t	2024	1
2024-05-09	Thursday	05	May	2024	t	2024	1
2024-05-10	Friday	05	May	2024	t	2024	1
2024-05-11	Saturday	05	May	2024	f	2024	1
2024-05-12	Sunday	05	May	2024	f	2024	1
2024-05-13	Monday	05	May	2024	t	2024	1
2024-05-14	Tuesday	05	May	2024	t	2024	1
2024-05-15	Wednesday	05	May	2024	t	2024	1
2024-05-16	Thursday	05	May	2024	t	2024	2
2024-05-17	Friday	05	May	2024	t	2024	2
2024-05-18	Saturday	05	May	2024	f	2024	2
2024-05-19	Sunday	05	May	2024	f	2024	2
2024-05-20	Monday	05	May	2024	t	2024	2
2024-05-21	Tuesday	05	May	2024	t	2024	2
2024-05-22	Wednesday	05	May	2024	t	2024	2
2024-05-23	Thursday	05	May	2024	t	2024	2
2024-05-24	Friday	05	May	2024	t	2024	2
2024-05-25	Saturday	05	May	2024	f	2024	2
2024-05-26	Sunday	05	May	2024	f	2024	2
2024-05-27	Monday	05	May	2024	t	2024	2
2024-05-28	Tuesday	05	May	2024	t	2024	2
2024-05-29	Wednesday	05	May	2024	t	2024	2
2024-05-30	Thursday	05	May	2024	t	2024	2
2024-05-31	Friday	05	May	2024	t	2024	2
2024-06-01	Saturday	06	June	2024	f	2024	1
2024-06-03	Monday	06	June	2024	t	2024	1
2024-06-04	Tuesday	06	June	2024	t	2024	1
2024-06-05	Wednesday	06	June	2024	t	2024	1
2024-06-06	Thursday	06	June	2024	t	2024	1
2024-06-07	Friday	06	June	2024	t	2024	1
2024-06-08	Saturday	06	June	2024	f	2024	1
2024-06-09	Sunday	06	June	2024	f	2024	1
2024-06-10	Monday	06	June	2024	t	2024	1
2024-06-11	Tuesday	06	June	2024	t	2024	1
2024-06-12	Wednesday	06	June	2024	t	2024	1
2024-06-13	Thursday	06	June	2024	t	2024	1
2024-06-14	Friday	06	June	2024	t	2024	1
2024-06-15	Saturday	06	June	2024	f	2024	1
2024-06-16	Sunday	06	June	2024	f	2024	2
2024-06-17	Monday	06	June	2024	t	2024	2
2024-06-18	Tuesday	06	June	2024	t	2024	2
2024-06-19	Wednesday	06	June	2024	t	2024	2
2024-06-20	Thursday	06	June	2024	t	2024	2
2024-06-21	Friday	06	June	2024	t	2024	2
2024-06-22	Saturday	06	June	2024	f	2024	2
2024-06-23	Sunday	06	June	2024	f	2024	2
2024-06-24	Monday	06	June	2024	t	2024	2
2024-06-25	Tuesday	06	June	2024	t	2024	2
2024-06-26	Wednesday	06	June	2024	t	2024	2
2024-06-27	Thursday	06	June	2024	t	2024	2
2024-06-28	Friday	06	June	2024	t	2024	2
2024-06-29	Saturday	06	June	2024	f	2024	2
2024-06-30	Sunday	06	June	2024	f	2024	2
2024-07-01	Monday	07	July	2024	t	2024	1
2024-07-02	Tuesday	07	July	2024	t	2024	1
2024-07-03	Wednesday	07	July	2024	t	2024	1
2024-07-04	Thursday	07	July	2024	t	2024	1
2024-07-05	Friday	07	July	2024	t	2024	1
2024-07-06	Saturday	07	July	2024	f	2024	1
2024-07-07	Sunday	07	July	2024	f	2024	1
2024-07-08	Monday	07	July	2024	t	2024	1
2024-07-09	Tuesday	07	July	2024	t	2024	1
2024-07-10	Wednesday	07	July	2024	t	2024	1
2024-07-11	Thursday	07	July	2024	t	2024	1
2024-07-12	Friday	07	July	2024	t	2024	1
2024-07-13	Saturday	07	July	2024	f	2024	1
2024-07-14	Sunday	07	July	2024	f	2024	1
2024-07-15	Monday	07	July	2024	t	2024	1
2024-07-16	Tuesday	07	July	2024	t	2024	2
2024-07-17	Wednesday	07	July	2024	t	2024	2
2024-07-18	Thursday	07	July	2024	t	2024	2
2024-07-19	Friday	07	July	2024	t	2024	2
2024-07-20	Saturday	07	July	2024	f	2024	2
2024-07-21	Sunday	07	July	2024	f	2024	2
2024-07-22	Monday	07	July	2024	t	2024	2
2024-07-23	Tuesday	07	July	2024	t	2024	2
2024-07-24	Wednesday	07	July	2024	t	2024	2
2024-07-25	Thursday	07	July	2024	t	2024	2
2024-07-26	Friday	07	July	2024	t	2024	2
2024-07-27	Saturday	07	July	2024	f	2024	2
2024-07-28	Sunday	07	July	2024	f	2024	2
2024-07-29	Monday	07	July	2024	t	2024	2
2024-07-30	Tuesday	07	July	2024	t	2024	2
2024-07-31	Wednesday	07	July	2024	t	2024	2
2024-08-01	Thursday	08	August	2024	t	2024	1
2024-08-02	Friday	08	August	2024	t	2024	1
2024-08-03	Saturday	08	August	2024	f	2024	1
2024-08-04	Sunday	08	August	2024	f	2024	1
2024-08-05	Monday	08	August	2024	t	2024	1
2024-08-06	Tuesday	08	August	2024	t	2024	1
2024-08-07	Wednesday	08	August	2024	t	2024	1
2024-08-08	Thursday	08	August	2024	t	2024	1
2024-08-09	Friday	08	August	2024	t	2024	1
2024-08-10	Saturday	08	August	2024	f	2024	1
2024-08-11	Sunday	08	August	2024	f	2024	1
2024-08-12	Monday	08	August	2024	t	2024	1
2024-08-13	Tuesday	08	August	2024	t	2024	1
2024-08-14	Wednesday	08	August	2024	t	2024	1
2024-08-16	Friday	08	August	2024	t	2024	2
2024-08-17	Saturday	08	August	2024	f	2024	2
2024-08-18	Sunday	08	August	2024	f	2024	2
2024-08-19	Monday	08	August	2024	t	2024	2
2024-08-20	Tuesday	08	August	2024	t	2024	2
2024-08-21	Wednesday	08	August	2024	t	2024	2
2024-08-22	Thursday	08	August	2024	t	2024	2
2024-08-23	Friday	08	August	2024	t	2024	2
2024-08-24	Saturday	08	August	2024	f	2024	2
2024-08-25	Sunday	08	August	2024	f	2024	2
2024-08-26	Monday	08	August	2024	t	2024	2
2024-08-27	Tuesday	08	August	2024	t	2024	2
2024-08-28	Wednesday	08	August	2024	t	2024	2
2024-08-29	Thursday	08	August	2024	t	2024	2
2024-08-30	Friday	08	August	2024	t	2024	2
2024-08-31	Saturday	08	August	2024	f	2024	2
2024-09-01	Sunday	09	September	2024	f	2025	1
2024-09-02	Monday	09	September	2024	t	2025	1
2024-09-03	Tuesday	09	September	2024	t	2025	1
2024-09-04	Wednesday	09	September	2024	t	2025	1
2024-09-05	Thursday	09	September	2024	t	2025	1
2024-09-06	Friday	09	September	2024	t	2025	1
2024-06-02	Sunday	06	June	2024	f	2024	1
2024-09-10	Tuesday	09	September	2024	t	2025	1
2024-09-11	Wednesday	09	September	2024	t	2025	1
2024-09-12	Thursday	09	September	2024	t	2025	1
2024-09-13	Friday	09	September	2024	t	2025	1
2024-09-14	Saturday	09	September	2024	f	2025	1
2024-09-15	Sunday	09	September	2024	f	2025	1
2024-09-16	Monday	09	September	2024	t	2025	2
2024-09-17	Tuesday	09	September	2024	t	2025	2
2024-09-18	Wednesday	09	September	2024	t	2025	2
2024-09-19	Thursday	09	September	2024	t	2025	2
2024-09-20	Friday	09	September	2024	t	2025	2
2024-09-21	Saturday	09	September	2024	f	2025	2
2024-09-22	Sunday	09	September	2024	f	2025	2
2024-09-23	Monday	09	September	2024	t	2025	2
2024-09-24	Tuesday	09	September	2024	t	2025	2
2024-09-25	Wednesday	09	September	2024	t	2025	2
2024-09-26	Thursday	09	September	2024	t	2025	2
2024-09-27	Friday	09	September	2024	t	2025	2
2024-09-28	Saturday	09	September	2024	f	2025	2
2024-09-29	Sunday	09	September	2024	f	2025	2
2024-09-30	Monday	09	September	2024	t	2025	2
2024-10-01	Tuesday	10	October	2024	t	2025	1
2024-10-02	Wednesday	10	October	2024	t	2025	1
2024-10-03	Thursday	10	October	2024	t	2025	1
2024-10-04	Friday	10	October	2024	t	2025	1
2024-10-05	Saturday	10	October	2024	f	2025	1
2024-10-06	Sunday	10	October	2024	f	2025	1
2024-10-07	Monday	10	October	2024	t	2025	1
2024-10-08	Tuesday	10	October	2024	t	2025	1
2024-10-09	Wednesday	10	October	2024	t	2025	1
2024-10-10	Thursday	10	October	2024	t	2025	1
2024-10-11	Friday	10	October	2024	t	2025	1
2024-10-12	Saturday	10	October	2024	f	2025	1
2024-10-13	Sunday	10	October	2024	f	2025	1
2024-10-14	Monday	10	October	2024	t	2025	1
2024-10-15	Tuesday	10	October	2024	t	2025	1
2024-10-16	Wednesday	10	October	2024	t	2025	2
2024-10-17	Thursday	10	October	2024	t	2025	2
2024-10-18	Friday	10	October	2024	t	2025	2
2024-10-19	Saturday	10	October	2024	f	2025	2
2024-10-20	Sunday	10	October	2024	f	2025	2
2024-10-21	Monday	10	October	2024	t	2025	2
2024-10-22	Tuesday	10	October	2024	t	2025	2
2024-10-23	Wednesday	10	October	2024	t	2025	2
2024-10-24	Thursday	10	October	2024	t	2025	2
2024-10-25	Friday	10	October	2024	t	2025	2
2024-10-26	Saturday	10	October	2024	f	2025	2
2024-10-27	Sunday	10	October	2024	f	2025	2
2024-10-28	Monday	10	October	2024	t	2025	2
2024-10-29	Tuesday	10	October	2024	t	2025	2
2024-10-30	Wednesday	10	October	2024	t	2025	2
2024-10-31	Thursday	10	October	2024	t	2025	2
2024-11-02	Saturday	11	November	2024	f	2025	1
2024-11-03	Sunday	11	November	2024	f	2025	1
2024-11-04	Monday	11	November	2024	t	2025	1
2024-11-05	Tuesday	11	November	2024	t	2025	1
2024-11-06	Wednesday	11	November	2024	t	2025	1
2024-11-07	Thursday	11	November	2024	t	2025	1
2024-11-08	Friday	11	November	2024	t	2025	1
2024-11-09	Saturday	11	November	2024	f	2025	1
2024-11-10	Sunday	11	November	2024	f	2025	1
2024-11-11	Monday	11	November	2024	t	2025	1
2024-11-12	Tuesday	11	November	2024	t	2025	1
2024-11-13	Wednesday	11	November	2024	t	2025	1
2024-11-14	Thursday	11	November	2024	t	2025	1
2024-11-15	Friday	11	November	2024	t	2025	1
2024-11-16	Saturday	11	November	2024	f	2025	2
2024-11-17	Sunday	11	November	2024	f	2025	2
2024-11-18	Monday	11	November	2024	t	2025	2
2024-11-19	Tuesday	11	November	2024	t	2025	2
2024-11-20	Wednesday	11	November	2024	t	2025	2
2024-11-21	Thursday	11	November	2024	t	2025	2
2024-11-22	Friday	11	November	2024	t	2025	2
2024-11-23	Saturday	11	November	2024	f	2025	2
2024-11-24	Sunday	11	November	2024	f	2025	2
2024-11-25	Monday	11	November	2024	t	2025	2
2024-11-26	Tuesday	11	November	2024	t	2025	2
2024-11-27	Wednesday	11	November	2024	t	2025	2
2024-11-28	Thursday	11	November	2024	t	2025	2
2024-11-29	Friday	11	November	2024	t	2025	2
2024-11-30	Saturday	11	November	2024	f	2025	2
2024-12-01	Sunday	12	December	2024	f	2025	1
2024-12-02	Monday	12	December	2024	t	2025	1
2024-12-03	Tuesday	12	December	2024	t	2025	1
2024-12-04	Wednesday	12	December	2024	t	2025	1
2024-12-05	Thursday	12	December	2024	t	2025	1
2024-12-06	Friday	12	December	2024	t	2025	1
2024-12-09	Monday	12	December	2024	t	2025	1
2024-12-10	Tuesday	12	December	2024	t	2025	1
2024-12-11	Wednesday	12	December	2024	t	2025	1
2024-12-12	Thursday	12	December	2024	t	2025	1
2024-12-13	Friday	12	December	2024	t	2025	1
2024-12-14	Saturday	12	December	2024	f	2025	1
2024-12-15	Sunday	12	December	2024	f	2025	1
2024-12-16	Monday	12	December	2024	t	2025	2
2024-12-17	Tuesday	12	December	2024	t	2025	2
2024-12-18	Wednesday	12	December	2024	t	2025	2
2024-12-19	Thursday	12	December	2024	t	2025	2
2024-12-20	Friday	12	December	2024	t	2025	2
2024-12-21	Saturday	12	December	2024	f	2025	2
2024-12-22	Sunday	12	December	2024	f	2025	2
2024-12-23	Monday	12	December	2024	t	2025	2
2024-12-24	Tuesday	12	December	2024	t	2025	2
2024-12-27	Friday	12	December	2024	t	2025	2
2024-12-28	Saturday	12	December	2024	f	2025	2
2024-12-29	Sunday	12	December	2024	f	2025	2
2024-12-30	Monday	12	December	2024	t	2025	2
2024-12-31	Tuesday	12	December	2024	t	2025	2
2025-01-02	Thursday	01	January	2025	t	2025	1
2025-01-03	Friday	01	January	2025	t	2025	1
2025-01-04	Saturday	01	January	2025	f	2025	1
2024-12-07	Saturday	12	December	2024	f	2025	1
2024-12-08	Sunday	12	December	2024	f	2025	1
2025-01-07	Tuesday	01	January	2025	t	2025	1
2025-01-08	Wednesday	01	January	2025	t	2025	1
2025-01-09	Thursday	01	January	2025	t	2025	1
2025-01-10	Friday	01	January	2025	t	2025	1
2025-01-11	Saturday	01	January	2025	f	2025	1
2025-01-12	Sunday	01	January	2025	f	2025	1
2025-01-13	Monday	01	January	2025	t	2025	1
2025-01-14	Tuesday	01	January	2025	t	2025	1
2025-01-15	Wednesday	01	January	2025	t	2025	1
2025-01-16	Thursday	01	January	2025	t	2025	2
2025-01-17	Friday	01	January	2025	t	2025	2
2025-01-18	Saturday	01	January	2025	f	2025	2
2025-01-19	Sunday	01	January	2025	f	2025	2
2025-01-20	Monday	01	January	2025	t	2025	2
2025-01-21	Tuesday	01	January	2025	t	2025	2
2025-01-22	Wednesday	01	January	2025	t	2025	2
2025-01-23	Thursday	01	January	2025	t	2025	2
2025-01-24	Friday	01	January	2025	t	2025	2
2025-01-25	Saturday	01	January	2025	f	2025	2
2025-01-26	Sunday	01	January	2025	f	2025	2
2025-01-27	Monday	01	January	2025	t	2025	2
2025-01-28	Tuesday	01	January	2025	t	2025	2
2025-01-29	Wednesday	01	January	2025	t	2025	2
2025-01-30	Thursday	01	January	2025	t	2025	2
2025-01-31	Friday	01	January	2025	t	2025	2
2025-02-01	Saturday	02	February	2025	f	2025	1
2025-02-02	Sunday	02	February	2025	f	2025	1
2025-02-03	Monday	02	February	2025	t	2025	1
2025-02-04	Tuesday	02	February	2025	t	2025	1
2025-02-05	Wednesday	02	February	2025	t	2025	1
2025-02-06	Thursday	02	February	2025	t	2025	1
2025-02-07	Friday	02	February	2025	t	2025	1
2025-02-08	Saturday	02	February	2025	f	2025	1
2025-02-09	Sunday	02	February	2025	f	2025	1
2025-02-10	Monday	02	February	2025	t	2025	1
2025-02-11	Tuesday	02	February	2025	t	2025	1
2025-02-12	Wednesday	02	February	2025	t	2025	1
2025-02-13	Thursday	02	February	2025	t	2025	1
2025-02-14	Friday	02	February	2025	t	2025	1
2025-02-15	Saturday	02	February	2025	f	2025	1
2025-02-16	Sunday	02	February	2025	f	2025	2
2025-02-17	Monday	02	February	2025	t	2025	2
2025-02-18	Tuesday	02	February	2025	t	2025	2
2025-02-19	Wednesday	02	February	2025	t	2025	2
2025-02-20	Thursday	02	February	2025	t	2025	2
2025-02-21	Friday	02	February	2025	t	2025	2
2025-02-22	Saturday	02	February	2025	f	2025	2
2025-02-23	Sunday	02	February	2025	f	2025	2
2025-02-24	Monday	02	February	2025	t	2025	2
2025-02-25	Tuesday	02	February	2025	t	2025	2
2025-02-26	Wednesday	02	February	2025	t	2025	2
2025-02-27	Thursday	02	February	2025	t	2025	2
2025-02-28	Friday	02	February	2025	t	2025	2
2025-03-01	Saturday	03	March	2025	f	2025	1
2025-03-02	Sunday	03	March	2025	f	2025	1
2025-03-03	Monday	03	March	2025	t	2025	1
2025-03-04	Tuesday	03	March	2025	t	2025	1
2025-03-05	Wednesday	03	March	2025	t	2025	1
2025-03-06	Thursday	03	March	2025	t	2025	1
2025-03-07	Friday	03	March	2025	t	2025	1
2025-03-08	Saturday	03	March	2025	f	2025	1
2025-03-09	Sunday	03	March	2025	f	2025	1
2025-03-10	Monday	03	March	2025	t	2025	1
2025-03-11	Tuesday	03	March	2025	t	2025	1
2025-03-12	Wednesday	03	March	2025	t	2025	1
2025-03-13	Thursday	03	March	2025	t	2025	1
2025-03-14	Friday	03	March	2025	t	2025	1
2025-03-15	Saturday	03	March	2025	f	2025	1
2025-03-16	Sunday	03	March	2025	f	2025	2
2025-03-17	Monday	03	March	2025	t	2025	2
2025-03-18	Tuesday	03	March	2025	t	2025	2
2025-03-19	Wednesday	03	March	2025	t	2025	2
2025-03-20	Thursday	03	March	2025	t	2025	2
2025-03-21	Friday	03	March	2025	t	2025	2
2025-03-22	Saturday	03	March	2025	f	2025	2
2025-03-23	Sunday	03	March	2025	f	2025	2
2025-03-24	Monday	03	March	2025	t	2025	2
2025-03-25	Tuesday	03	March	2025	t	2025	2
2025-03-26	Wednesday	03	March	2025	t	2025	2
2025-03-27	Thursday	03	March	2025	t	2025	2
2025-03-28	Friday	03	March	2025	t	2025	2
2025-03-29	Saturday	03	March	2025	f	2025	2
2025-03-30	Sunday	03	March	2025	f	2025	2
2025-03-31	Monday	03	March	2025	t	2025	2
2025-04-01	Tuesday	04	April	2025	t	2025	1
2025-04-02	Wednesday	04	April	2025	t	2025	1
2025-04-03	Thursday	04	April	2025	t	2025	1
2025-04-04	Friday	04	April	2025	t	2025	1
2025-04-05	Saturday	04	April	2025	f	2025	1
2025-04-06	Sunday	04	April	2025	f	2025	1
2025-04-07	Monday	04	April	2025	t	2025	1
2025-04-08	Tuesday	04	April	2025	t	2025	1
2025-04-09	Wednesday	04	April	2025	t	2025	1
2025-04-10	Thursday	04	April	2025	t	2025	1
2025-04-11	Friday	04	April	2025	t	2025	1
2025-04-12	Saturday	04	April	2025	f	2025	1
2025-04-13	Sunday	04	April	2025	f	2025	1
2025-04-14	Monday	04	April	2025	t	2025	1
2025-04-15	Tuesday	04	April	2025	t	2025	1
2025-04-16	Wednesday	04	April	2025	t	2025	2
2025-04-17	Thursday	04	April	2025	t	2025	2
2025-04-18	Friday	04	April	2025	t	2025	2
2025-04-19	Saturday	04	April	2025	f	2025	2
2025-04-20	Sunday	04	April	2025	f	2025	2
2025-04-22	Tuesday	04	April	2025	t	2025	2
2025-04-23	Wednesday	04	April	2025	t	2025	2
2025-04-24	Thursday	04	April	2025	t	2025	2
2025-04-26	Saturday	04	April	2025	f	2025	2
2025-04-27	Sunday	04	April	2025	f	2025	2
2025-04-28	Monday	04	April	2025	t	2025	2
2025-04-29	Tuesday	04	April	2025	t	2025	2
2025-04-30	Wednesday	04	April	2025	t	2025	2
2025-05-02	Friday	05	May	2025	t	2025	1
2025-05-03	Saturday	05	May	2025	f	2025	1
2025-05-04	Sunday	05	May	2025	f	2025	1
2025-05-05	Monday	05	May	2025	t	2025	1
2025-05-06	Tuesday	05	May	2025	t	2025	1
2025-05-07	Wednesday	05	May	2025	t	2025	1
2025-05-08	Thursday	05	May	2025	t	2025	1
2025-05-10	Saturday	05	May	2025	f	2025	1
2025-05-11	Sunday	05	May	2025	f	2025	1
2025-05-12	Monday	05	May	2025	t	2025	1
2025-05-13	Tuesday	05	May	2025	t	2025	1
2025-05-14	Wednesday	05	May	2025	t	2025	1
2025-05-15	Thursday	05	May	2025	t	2025	1
2025-05-16	Friday	05	May	2025	t	2025	2
2025-05-17	Saturday	05	May	2025	f	2025	2
2025-05-18	Sunday	05	May	2025	f	2025	2
2025-05-19	Monday	05	May	2025	t	2025	2
2025-05-20	Tuesday	05	May	2025	t	2025	2
2025-05-21	Wednesday	05	May	2025	t	2025	2
2025-05-22	Thursday	05	May	2025	t	2025	2
2025-05-23	Friday	05	May	2025	t	2025	2
2025-05-24	Saturday	05	May	2025	f	2025	2
2025-05-25	Sunday	05	May	2025	f	2025	2
2025-05-26	Monday	05	May	2025	t	2025	2
2025-05-27	Tuesday	05	May	2025	t	2025	2
2025-05-28	Wednesday	05	May	2025	t	2025	2
2025-05-29	Thursday	05	May	2025	t	2025	2
2025-05-30	Friday	05	May	2025	t	2025	2
2025-05-31	Saturday	05	May	2025	f	2025	2
2025-06-01	Sunday	06	June	2025	f	2025	1
2025-06-03	Tuesday	06	June	2025	t	2025	1
2025-06-04	Wednesday	06	June	2025	t	2025	1
2025-06-05	Thursday	06	June	2025	t	2025	1
2025-06-06	Friday	06	June	2025	t	2025	1
2025-06-07	Saturday	06	June	2025	f	2025	1
2025-06-08	Sunday	06	June	2025	f	2025	1
2025-06-09	Monday	06	June	2025	t	2025	1
2025-06-10	Tuesday	06	June	2025	t	2025	1
2025-06-11	Wednesday	06	June	2025	t	2025	1
2025-06-12	Thursday	06	June	2025	t	2025	1
2025-06-13	Friday	06	June	2025	t	2025	1
2025-06-14	Saturday	06	June	2025	f	2025	1
2025-06-15	Sunday	06	June	2025	f	2025	1
2025-06-16	Monday	06	June	2025	t	2025	2
2025-06-17	Tuesday	06	June	2025	t	2025	2
2025-06-18	Wednesday	06	June	2025	t	2025	2
2025-06-19	Thursday	06	June	2025	t	2025	2
2025-06-20	Friday	06	June	2025	t	2025	2
2025-06-21	Saturday	06	June	2025	f	2025	2
2025-06-22	Sunday	06	June	2025	f	2025	2
2025-06-23	Monday	06	June	2025	t	2025	2
2025-06-24	Tuesday	06	June	2025	t	2025	2
2025-06-25	Wednesday	06	June	2025	t	2025	2
2025-06-26	Thursday	06	June	2025	t	2025	2
2025-06-27	Friday	06	June	2025	t	2025	2
2025-06-28	Saturday	06	June	2025	f	2025	2
2025-06-29	Sunday	06	June	2025	f	2025	2
2025-06-30	Monday	06	June	2025	t	2025	2
2025-07-01	Tuesday	07	July	2025	t	2025	1
2025-07-02	Wednesday	07	July	2025	t	2025	1
2025-07-03	Thursday	07	July	2025	t	2025	1
2025-07-04	Friday	07	July	2025	t	2025	1
2025-07-05	Saturday	07	July	2025	f	2025	1
2025-07-06	Sunday	07	July	2025	f	2025	1
2025-07-07	Monday	07	July	2025	t	2025	1
2025-07-08	Tuesday	07	July	2025	t	2025	1
2025-07-09	Wednesday	07	July	2025	t	2025	1
2025-07-10	Thursday	07	July	2025	t	2025	1
2025-07-11	Friday	07	July	2025	t	2025	1
2025-07-12	Saturday	07	July	2025	f	2025	1
2025-07-13	Sunday	07	July	2025	f	2025	1
2025-07-14	Monday	07	July	2025	t	2025	1
2025-07-15	Tuesday	07	July	2025	t	2025	1
2025-07-16	Wednesday	07	July	2025	t	2025	2
2025-07-17	Thursday	07	July	2025	t	2025	2
2025-07-18	Friday	07	July	2025	t	2025	2
2025-07-19	Saturday	07	July	2025	f	2025	2
2025-07-20	Sunday	07	July	2025	f	2025	2
2025-07-21	Monday	07	July	2025	t	2025	2
2025-07-22	Tuesday	07	July	2025	t	2025	2
2025-07-23	Wednesday	07	July	2025	t	2025	2
2025-07-24	Thursday	07	July	2025	t	2025	2
2025-07-25	Friday	07	July	2025	t	2025	2
2025-07-26	Saturday	07	July	2025	f	2025	2
2025-07-27	Sunday	07	July	2025	f	2025	2
2025-07-28	Monday	07	July	2025	t	2025	2
2025-07-29	Tuesday	07	July	2025	t	2025	2
2025-07-30	Wednesday	07	July	2025	t	2025	2
2025-07-31	Thursday	07	July	2025	t	2025	2
2025-08-01	Friday	08	August	2025	t	2025	1
2025-08-02	Saturday	08	August	2025	f	2025	1
2025-08-03	Sunday	08	August	2025	f	2025	1
2025-08-04	Monday	08	August	2025	t	2025	1
2025-08-05	Tuesday	08	August	2025	t	2025	1
2025-08-06	Wednesday	08	August	2025	t	2025	1
2025-08-07	Thursday	08	August	2025	t	2025	1
2025-08-08	Friday	08	August	2025	t	2025	1
2025-08-09	Saturday	08	August	2025	f	2025	1
2025-08-10	Sunday	08	August	2025	f	2025	1
2025-08-11	Monday	08	August	2025	t	2025	1
2025-08-12	Tuesday	08	August	2025	t	2025	1
2025-08-13	Wednesday	08	August	2025	t	2025	1
2025-08-14	Thursday	08	August	2025	t	2025	1
2025-08-16	Saturday	08	August	2025	f	2025	2
2025-08-17	Sunday	08	August	2025	f	2025	2
2025-08-18	Monday	08	August	2025	t	2025	2
2025-08-19	Tuesday	08	August	2025	t	2025	2
2025-08-20	Wednesday	08	August	2025	t	2025	2
2025-08-21	Thursday	08	August	2025	t	2025	2
2025-08-22	Friday	08	August	2025	t	2025	2
2025-08-23	Saturday	08	August	2025	f	2025	2
2025-08-24	Sunday	08	August	2025	f	2025	2
2025-08-25	Monday	08	August	2025	t	2025	2
2025-08-26	Tuesday	08	August	2025	t	2025	2
2025-08-27	Wednesday	08	August	2025	t	2025	2
2025-08-28	Thursday	08	August	2025	t	2025	2
2025-08-29	Friday	08	August	2025	t	2025	2
2025-08-30	Saturday	08	August	2025	f	2025	2
2025-08-31	Sunday	08	August	2025	f	2025	2
2025-09-01	Monday	09	September	2025	t	2026	1
2025-09-02	Tuesday	09	September	2025	t	2026	1
2025-09-03	Wednesday	09	September	2025	t	2026	1
2025-09-04	Thursday	09	September	2025	t	2026	1
2025-09-05	Friday	09	September	2025	t	2026	1
2025-09-06	Saturday	09	September	2025	f	2026	1
2025-09-07	Sunday	09	September	2025	f	2026	1
2025-09-08	Monday	09	September	2025	t	2026	1
2025-09-09	Tuesday	09	September	2025	t	2026	1
2025-09-10	Wednesday	09	September	2025	t	2026	1
2025-09-11	Thursday	09	September	2025	t	2026	1
2025-06-02	Monday	06	June	2025	f	2025	1
2025-09-15	Monday	09	September	2025	t	2026	1
2025-09-16	Tuesday	09	September	2025	t	2026	2
2025-09-17	Wednesday	09	September	2025	t	2026	2
2025-09-18	Thursday	09	September	2025	t	2026	2
2025-09-19	Friday	09	September	2025	t	2026	2
2025-09-20	Saturday	09	September	2025	f	2026	2
2025-09-21	Sunday	09	September	2025	f	2026	2
2025-09-22	Monday	09	September	2025	t	2026	2
2025-09-23	Tuesday	09	September	2025	t	2026	2
2025-09-24	Wednesday	09	September	2025	t	2026	2
2025-09-25	Thursday	09	September	2025	t	2026	2
2025-09-26	Friday	09	September	2025	t	2026	2
2025-09-27	Saturday	09	September	2025	f	2026	2
2025-09-28	Sunday	09	September	2025	f	2026	2
2025-09-29	Monday	09	September	2025	t	2026	2
2025-09-30	Tuesday	09	September	2025	t	2026	2
2025-10-01	Wednesday	10	October	2025	t	2026	1
2025-10-02	Thursday	10	October	2025	t	2026	1
2025-10-03	Friday	10	October	2025	t	2026	1
2025-10-04	Saturday	10	October	2025	f	2026	1
2025-10-05	Sunday	10	October	2025	f	2026	1
2025-10-06	Monday	10	October	2025	t	2026	1
2025-10-07	Tuesday	10	October	2025	t	2026	1
2025-10-08	Wednesday	10	October	2025	t	2026	1
2025-10-09	Thursday	10	October	2025	t	2026	1
2025-10-10	Friday	10	October	2025	t	2026	1
2025-10-11	Saturday	10	October	2025	f	2026	1
2025-10-12	Sunday	10	October	2025	f	2026	1
2025-10-13	Monday	10	October	2025	t	2026	1
2025-10-14	Tuesday	10	October	2025	t	2026	1
2025-10-15	Wednesday	10	October	2025	t	2026	1
2025-10-16	Thursday	10	October	2025	t	2026	2
2025-10-17	Friday	10	October	2025	t	2026	2
2025-10-18	Saturday	10	October	2025	f	2026	2
2025-10-19	Sunday	10	October	2025	f	2026	2
2025-10-20	Monday	10	October	2025	t	2026	2
2025-10-21	Tuesday	10	October	2025	t	2026	2
2025-10-22	Wednesday	10	October	2025	t	2026	2
2025-10-23	Thursday	10	October	2025	t	2026	2
2025-10-24	Friday	10	October	2025	t	2026	2
2025-10-25	Saturday	10	October	2025	f	2026	2
2025-10-26	Sunday	10	October	2025	f	2026	2
2025-10-27	Monday	10	October	2025	t	2026	2
2025-10-28	Tuesday	10	October	2025	t	2026	2
2025-10-29	Wednesday	10	October	2025	t	2026	2
2025-10-30	Thursday	10	October	2025	t	2026	2
2025-10-31	Friday	10	October	2025	t	2026	2
2025-11-02	Sunday	11	November	2025	f	2026	1
2025-11-03	Monday	11	November	2025	t	2026	1
2025-11-04	Tuesday	11	November	2025	t	2026	1
2025-11-05	Wednesday	11	November	2025	t	2026	1
2025-11-06	Thursday	11	November	2025	t	2026	1
2025-11-07	Friday	11	November	2025	t	2026	1
2025-11-08	Saturday	11	November	2025	f	2026	1
2025-11-09	Sunday	11	November	2025	f	2026	1
2025-11-10	Monday	11	November	2025	t	2026	1
2025-11-11	Tuesday	11	November	2025	t	2026	1
2025-11-12	Wednesday	11	November	2025	t	2026	1
2025-11-13	Thursday	11	November	2025	t	2026	1
2025-11-14	Friday	11	November	2025	t	2026	1
2025-11-15	Saturday	11	November	2025	f	2026	1
2025-11-16	Sunday	11	November	2025	f	2026	2
2025-11-17	Monday	11	November	2025	t	2026	2
2025-11-18	Tuesday	11	November	2025	t	2026	2
2025-11-19	Wednesday	11	November	2025	t	2026	2
2025-11-20	Thursday	11	November	2025	t	2026	2
2025-11-21	Friday	11	November	2025	t	2026	2
2025-11-22	Saturday	11	November	2025	f	2026	2
2025-11-23	Sunday	11	November	2025	f	2026	2
2025-11-24	Monday	11	November	2025	t	2026	2
2025-11-25	Tuesday	11	November	2025	t	2026	2
2025-11-26	Wednesday	11	November	2025	t	2026	2
2025-11-27	Thursday	11	November	2025	t	2026	2
2025-11-28	Friday	11	November	2025	t	2026	2
2025-11-29	Saturday	11	November	2025	f	2026	2
2025-11-30	Sunday	11	November	2025	f	2026	2
2025-12-01	Monday	12	December	2025	t	2026	1
2025-12-02	Tuesday	12	December	2025	t	2026	1
2025-12-03	Wednesday	12	December	2025	t	2026	1
2025-12-04	Thursday	12	December	2025	t	2026	1
2025-12-05	Friday	12	December	2025	t	2026	1
2025-12-06	Saturday	12	December	2025	f	2026	1
2025-12-09	Tuesday	12	December	2025	t	2026	1
2025-12-10	Wednesday	12	December	2025	t	2026	1
2025-12-11	Thursday	12	December	2025	t	2026	1
2025-12-12	Friday	12	December	2025	t	2026	1
2025-12-13	Saturday	12	December	2025	f	2026	1
2025-12-14	Sunday	12	December	2025	f	2026	1
2025-12-15	Monday	12	December	2025	t	2026	1
2025-12-16	Tuesday	12	December	2025	t	2026	2
2025-12-17	Wednesday	12	December	2025	t	2026	2
2025-12-18	Thursday	12	December	2025	t	2026	2
2025-12-19	Friday	12	December	2025	t	2026	2
2025-12-20	Saturday	12	December	2025	f	2026	2
2025-12-21	Sunday	12	December	2025	f	2026	2
2025-12-22	Monday	12	December	2025	t	2026	2
2025-12-23	Tuesday	12	December	2025	t	2026	2
2025-12-24	Wednesday	12	December	2025	t	2026	2
2025-12-27	Saturday	12	December	2025	f	2026	2
2025-12-28	Sunday	12	December	2025	f	2026	2
2025-12-29	Monday	12	December	2025	t	2026	2
2025-12-30	Tuesday	12	December	2025	t	2026	2
2025-12-31	Wednesday	12	December	2025	t	2026	2
2026-01-02	Friday	01	January	2026	t	2026	1
2026-01-03	Saturday	01	January	2026	f	2026	1
2026-01-04	Sunday	01	January	2026	f	2026	1
2026-01-05	Monday	01	January	2026	t	2026	1
2026-01-06	Tuesday	01	January	2026	t	2026	1
2026-01-07	Wednesday	01	January	2026	t	2026	1
2026-01-08	Thursday	01	January	2026	t	2026	1
2026-01-09	Friday	01	January	2026	t	2026	1
2025-12-07	Sunday	12	December	2025	f	2026	1
2025-12-08	Monday	12	December	2025	f	2026	1
2026-01-13	Tuesday	01	January	2026	t	2026	1
2026-01-14	Wednesday	01	January	2026	t	2026	1
2026-01-15	Thursday	01	January	2026	t	2026	1
2026-01-16	Friday	01	January	2026	t	2026	2
2026-01-17	Saturday	01	January	2026	f	2026	2
2026-01-18	Sunday	01	January	2026	f	2026	2
2026-01-19	Monday	01	January	2026	t	2026	2
2026-01-20	Tuesday	01	January	2026	t	2026	2
2026-01-21	Wednesday	01	January	2026	t	2026	2
2026-01-22	Thursday	01	January	2026	t	2026	2
2026-01-23	Friday	01	January	2026	t	2026	2
2026-01-24	Saturday	01	January	2026	f	2026	2
2026-01-25	Sunday	01	January	2026	f	2026	2
2026-01-26	Monday	01	January	2026	t	2026	2
2026-01-27	Tuesday	01	January	2026	t	2026	2
2026-01-28	Wednesday	01	January	2026	t	2026	2
2026-01-29	Thursday	01	January	2026	t	2026	2
2026-01-30	Friday	01	January	2026	t	2026	2
2026-01-31	Saturday	01	January	2026	f	2026	2
2026-02-01	Sunday	02	February	2026	f	2026	1
2026-02-02	Monday	02	February	2026	t	2026	1
2026-02-03	Tuesday	02	February	2026	t	2026	1
2026-02-04	Wednesday	02	February	2026	t	2026	1
2026-02-05	Thursday	02	February	2026	t	2026	1
2026-02-06	Friday	02	February	2026	t	2026	1
2026-02-07	Saturday	02	February	2026	f	2026	1
2026-02-08	Sunday	02	February	2026	f	2026	1
2026-02-09	Monday	02	February	2026	t	2026	1
2026-02-10	Tuesday	02	February	2026	t	2026	1
2026-02-11	Wednesday	02	February	2026	t	2026	1
2026-02-12	Thursday	02	February	2026	t	2026	1
2026-02-13	Friday	02	February	2026	t	2026	1
2026-02-14	Saturday	02	February	2026	f	2026	1
2026-02-15	Sunday	02	February	2026	f	2026	1
2026-02-16	Monday	02	February	2026	t	2026	2
2026-02-17	Tuesday	02	February	2026	t	2026	2
2026-02-18	Wednesday	02	February	2026	t	2026	2
2026-02-19	Thursday	02	February	2026	t	2026	2
2026-02-20	Friday	02	February	2026	t	2026	2
2026-02-21	Saturday	02	February	2026	f	2026	2
2026-02-22	Sunday	02	February	2026	f	2026	2
2026-02-23	Monday	02	February	2026	t	2026	2
2026-02-24	Tuesday	02	February	2026	t	2026	2
2026-02-25	Wednesday	02	February	2026	t	2026	2
2026-02-26	Thursday	02	February	2026	t	2026	2
2026-02-27	Friday	02	February	2026	t	2026	2
2026-02-28	Saturday	02	February	2026	f	2026	2
2026-03-01	Sunday	03	March	2026	f	2026	1
2026-03-02	Monday	03	March	2026	t	2026	1
2026-03-03	Tuesday	03	March	2026	t	2026	1
2026-03-04	Wednesday	03	March	2026	t	2026	1
2026-03-05	Thursday	03	March	2026	t	2026	1
2026-03-06	Friday	03	March	2026	t	2026	1
2026-03-07	Saturday	03	March	2026	f	2026	1
2026-03-08	Sunday	03	March	2026	f	2026	1
2026-03-09	Monday	03	March	2026	t	2026	1
2026-03-10	Tuesday	03	March	2026	t	2026	1
2026-03-11	Wednesday	03	March	2026	t	2026	1
2026-03-12	Thursday	03	March	2026	t	2026	1
2026-03-13	Friday	03	March	2026	t	2026	1
2026-03-14	Saturday	03	March	2026	f	2026	1
2026-03-15	Sunday	03	March	2026	f	2026	1
2026-03-16	Monday	03	March	2026	t	2026	2
2026-03-17	Tuesday	03	March	2026	t	2026	2
2026-03-18	Wednesday	03	March	2026	t	2026	2
2026-03-19	Thursday	03	March	2026	t	2026	2
2026-03-20	Friday	03	March	2026	t	2026	2
2026-03-21	Saturday	03	March	2026	f	2026	2
2026-03-22	Sunday	03	March	2026	f	2026	2
2026-03-23	Monday	03	March	2026	t	2026	2
2026-03-24	Tuesday	03	March	2026	t	2026	2
2026-03-25	Wednesday	03	March	2026	t	2026	2
2026-03-26	Thursday	03	March	2026	t	2026	2
2026-03-27	Friday	03	March	2026	t	2026	2
2026-03-28	Saturday	03	March	2026	f	2026	2
2026-03-29	Sunday	03	March	2026	f	2026	2
2026-03-30	Monday	03	March	2026	t	2026	2
2026-03-31	Tuesday	03	March	2026	t	2026	2
2026-04-01	Wednesday	04	April	2026	t	2026	1
2026-04-02	Thursday	04	April	2026	t	2026	1
2026-04-03	Friday	04	April	2026	t	2026	1
2026-04-04	Saturday	04	April	2026	f	2026	1
2026-04-05	Sunday	04	April	2026	f	2026	1
2026-04-07	Tuesday	04	April	2026	t	2026	1
2026-04-08	Wednesday	04	April	2026	t	2026	1
2026-04-09	Thursday	04	April	2026	t	2026	1
2026-04-10	Friday	04	April	2026	t	2026	1
2026-04-11	Saturday	04	April	2026	f	2026	1
2026-04-12	Sunday	04	April	2026	f	2026	1
2026-04-13	Monday	04	April	2026	t	2026	1
2026-04-14	Tuesday	04	April	2026	t	2026	1
2026-04-15	Wednesday	04	April	2026	t	2026	1
2026-04-16	Thursday	04	April	2026	t	2026	2
2026-04-17	Friday	04	April	2026	t	2026	2
2026-04-18	Saturday	04	April	2026	f	2026	2
2026-04-19	Sunday	04	April	2026	f	2026	2
2026-04-20	Monday	04	April	2026	t	2026	2
2026-04-21	Tuesday	04	April	2026	t	2026	2
2026-04-22	Wednesday	04	April	2026	t	2026	2
2026-04-23	Thursday	04	April	2026	t	2026	2
2026-04-24	Friday	04	April	2026	t	2026	2
2026-04-26	Sunday	04	April	2026	f	2026	2
2026-04-27	Monday	04	April	2026	t	2026	2
2026-04-28	Tuesday	04	April	2026	t	2026	2
2026-04-29	Wednesday	04	April	2026	t	2026	2
2026-04-30	Thursday	04	April	2026	t	2026	2
2026-05-02	Saturday	05	May	2026	f	2026	1
2026-05-03	Sunday	05	May	2026	f	2026	1
2026-05-04	Monday	05	May	2026	t	2026	1
2026-05-05	Tuesday	05	May	2026	t	2026	1
2026-05-06	Wednesday	05	May	2026	t	2026	1
2026-05-07	Thursday	05	May	2026	t	2026	1
2026-05-08	Friday	05	May	2026	t	2026	1
2026-05-09	Saturday	05	May	2026	f	2026	1
2026-05-10	Sunday	05	May	2026	f	2026	1
2026-05-11	Monday	05	May	2026	t	2026	1
2026-05-12	Tuesday	05	May	2026	t	2026	1
2026-05-13	Wednesday	05	May	2026	t	2026	1
2026-05-15	Friday	05	May	2026	t	2026	1
2026-05-16	Saturday	05	May	2026	f	2026	2
2026-05-17	Sunday	05	May	2026	f	2026	2
2026-05-18	Monday	05	May	2026	t	2026	2
2026-05-19	Tuesday	05	May	2026	t	2026	2
2026-05-20	Wednesday	05	May	2026	t	2026	2
2026-05-21	Thursday	05	May	2026	t	2026	2
2026-05-22	Friday	05	May	2026	t	2026	2
2026-05-23	Saturday	05	May	2026	f	2026	2
2026-05-24	Sunday	05	May	2026	f	2026	2
2026-05-25	Monday	05	May	2026	t	2026	2
2026-05-26	Tuesday	05	May	2026	t	2026	2
2026-05-27	Wednesday	05	May	2026	t	2026	2
2026-05-28	Thursday	05	May	2026	t	2026	2
2026-05-29	Friday	05	May	2026	t	2026	2
2026-05-30	Saturday	05	May	2026	f	2026	2
2026-05-31	Sunday	05	May	2026	f	2026	2
2026-06-01	Monday	06	June	2026	t	2026	1
2026-06-03	Wednesday	06	June	2026	t	2026	1
2026-06-04	Thursday	06	June	2026	t	2026	1
2026-06-05	Friday	06	June	2026	t	2026	1
2026-06-06	Saturday	06	June	2026	f	2026	1
2026-06-07	Sunday	06	June	2026	f	2026	1
2026-06-08	Monday	06	June	2026	t	2026	1
2026-06-09	Tuesday	06	June	2026	t	2026	1
2026-06-10	Wednesday	06	June	2026	t	2026	1
2026-06-11	Thursday	06	June	2026	t	2026	1
2026-06-12	Friday	06	June	2026	t	2026	1
2026-06-13	Saturday	06	June	2026	f	2026	1
2026-06-14	Sunday	06	June	2026	f	2026	1
2026-06-15	Monday	06	June	2026	t	2026	1
2026-06-16	Tuesday	06	June	2026	t	2026	2
2026-06-17	Wednesday	06	June	2026	t	2026	2
2026-06-18	Thursday	06	June	2026	t	2026	2
2026-06-19	Friday	06	June	2026	t	2026	2
2026-06-20	Saturday	06	June	2026	f	2026	2
2026-06-21	Sunday	06	June	2026	f	2026	2
2026-06-22	Monday	06	June	2026	t	2026	2
2026-06-23	Tuesday	06	June	2026	t	2026	2
2026-06-24	Wednesday	06	June	2026	t	2026	2
2026-06-25	Thursday	06	June	2026	t	2026	2
2026-06-26	Friday	06	June	2026	t	2026	2
2026-06-27	Saturday	06	June	2026	f	2026	2
2026-06-28	Sunday	06	June	2026	f	2026	2
2026-06-29	Monday	06	June	2026	t	2026	2
2026-06-30	Tuesday	06	June	2026	t	2026	2
2026-07-01	Wednesday	07	July	2026	t	2026	1
2026-07-02	Thursday	07	July	2026	t	2026	1
2026-07-03	Friday	07	July	2026	t	2026	1
2026-07-04	Saturday	07	July	2026	f	2026	1
2026-07-05	Sunday	07	July	2026	f	2026	1
2026-07-06	Monday	07	July	2026	t	2026	1
2026-07-07	Tuesday	07	July	2026	t	2026	1
2026-07-08	Wednesday	07	July	2026	t	2026	1
2026-07-09	Thursday	07	July	2026	t	2026	1
2026-07-10	Friday	07	July	2026	t	2026	1
2026-07-11	Saturday	07	July	2026	f	2026	1
2026-07-12	Sunday	07	July	2026	f	2026	1
2026-07-13	Monday	07	July	2026	t	2026	1
2026-07-14	Tuesday	07	July	2026	t	2026	1
2026-07-15	Wednesday	07	July	2026	t	2026	1
2026-07-16	Thursday	07	July	2026	t	2026	2
2026-07-17	Friday	07	July	2026	t	2026	2
2026-07-18	Saturday	07	July	2026	f	2026	2
2026-07-19	Sunday	07	July	2026	f	2026	2
2026-07-20	Monday	07	July	2026	t	2026	2
2026-07-21	Tuesday	07	July	2026	t	2026	2
2026-07-22	Wednesday	07	July	2026	t	2026	2
2026-07-23	Thursday	07	July	2026	t	2026	2
2026-07-24	Friday	07	July	2026	t	2026	2
2026-07-25	Saturday	07	July	2026	f	2026	2
2026-07-26	Sunday	07	July	2026	f	2026	2
2026-07-27	Monday	07	July	2026	t	2026	2
2026-07-28	Tuesday	07	July	2026	t	2026	2
2026-07-29	Wednesday	07	July	2026	t	2026	2
2026-07-30	Thursday	07	July	2026	t	2026	2
2026-07-31	Friday	07	July	2026	t	2026	2
2026-08-01	Saturday	08	August	2026	f	2026	1
2026-08-02	Sunday	08	August	2026	f	2026	1
2026-08-03	Monday	08	August	2026	t	2026	1
2026-08-04	Tuesday	08	August	2026	t	2026	1
2026-08-05	Wednesday	08	August	2026	t	2026	1
2026-08-06	Thursday	08	August	2026	t	2026	1
2026-08-07	Friday	08	August	2026	t	2026	1
2026-08-08	Saturday	08	August	2026	f	2026	1
2026-08-09	Sunday	08	August	2026	f	2026	1
2026-08-10	Monday	08	August	2026	t	2026	1
2026-08-11	Tuesday	08	August	2026	t	2026	1
2026-08-12	Wednesday	08	August	2026	t	2026	1
2026-08-13	Thursday	08	August	2026	t	2026	1
2026-08-14	Friday	08	August	2026	t	2026	1
2026-08-16	Sunday	08	August	2026	f	2026	2
2026-08-17	Monday	08	August	2026	t	2026	2
2026-08-18	Tuesday	08	August	2026	t	2026	2
2026-08-19	Wednesday	08	August	2026	t	2026	2
2026-08-20	Thursday	08	August	2026	t	2026	2
2026-08-21	Friday	08	August	2026	t	2026	2
2026-08-22	Saturday	08	August	2026	f	2026	2
2026-08-23	Sunday	08	August	2026	f	2026	2
2026-08-24	Monday	08	August	2026	t	2026	2
2026-08-25	Tuesday	08	August	2026	t	2026	2
2026-08-26	Wednesday	08	August	2026	t	2026	2
2026-08-27	Thursday	08	August	2026	t	2026	2
2026-08-28	Friday	08	August	2026	t	2026	2
2026-08-29	Saturday	08	August	2026	f	2026	2
2026-08-30	Sunday	08	August	2026	f	2026	2
2026-08-31	Monday	08	August	2026	t	2026	2
2026-09-01	Tuesday	09	September	2026	t	2027	1
2026-09-02	Wednesday	09	September	2026	t	2027	1
2026-09-03	Thursday	09	September	2026	t	2027	1
2026-09-04	Friday	09	September	2026	t	2027	1
2026-09-05	Saturday	09	September	2026	f	2027	1
2026-09-06	Sunday	09	September	2026	f	2027	1
2026-09-07	Monday	09	September	2026	t	2027	1
2026-09-08	Tuesday	09	September	2026	t	2027	1
2026-09-09	Wednesday	09	September	2026	t	2027	1
2026-09-10	Thursday	09	September	2026	t	2027	1
2026-09-11	Friday	09	September	2026	t	2027	1
2026-09-12	Saturday	09	September	2026	f	2027	1
2026-09-13	Sunday	09	September	2026	f	2027	1
2026-09-14	Monday	09	September	2026	t	2027	1
2026-09-15	Tuesday	09	September	2026	t	2027	1
2026-09-16	Wednesday	09	September	2026	t	2027	2
2026-06-02	Tuesday	06	June	2026	f	2026	1
2026-09-20	Sunday	09	September	2026	f	2027	2
2026-09-21	Monday	09	September	2026	t	2027	2
2026-09-22	Tuesday	09	September	2026	t	2027	2
2026-09-23	Wednesday	09	September	2026	t	2027	2
2026-09-24	Thursday	09	September	2026	t	2027	2
2026-09-25	Friday	09	September	2026	t	2027	2
2026-09-26	Saturday	09	September	2026	f	2027	2
2026-09-27	Sunday	09	September	2026	f	2027	2
2026-09-28	Monday	09	September	2026	t	2027	2
2026-09-29	Tuesday	09	September	2026	t	2027	2
2026-09-30	Wednesday	09	September	2026	t	2027	2
2026-10-01	Thursday	10	October	2026	t	2027	1
2026-10-02	Friday	10	October	2026	t	2027	1
2026-10-03	Saturday	10	October	2026	f	2027	1
2026-10-04	Sunday	10	October	2026	f	2027	1
2026-10-05	Monday	10	October	2026	t	2027	1
2026-10-06	Tuesday	10	October	2026	t	2027	1
2026-10-07	Wednesday	10	October	2026	t	2027	1
2026-10-08	Thursday	10	October	2026	t	2027	1
2026-10-09	Friday	10	October	2026	t	2027	1
2026-10-10	Saturday	10	October	2026	f	2027	1
2026-10-11	Sunday	10	October	2026	f	2027	1
2026-10-12	Monday	10	October	2026	t	2027	1
2026-10-13	Tuesday	10	October	2026	t	2027	1
2026-10-14	Wednesday	10	October	2026	t	2027	1
2026-10-15	Thursday	10	October	2026	t	2027	1
2026-10-16	Friday	10	October	2026	t	2027	2
2026-10-17	Saturday	10	October	2026	f	2027	2
2026-10-18	Sunday	10	October	2026	f	2027	2
2026-10-19	Monday	10	October	2026	t	2027	2
2026-10-20	Tuesday	10	October	2026	t	2027	2
2026-10-21	Wednesday	10	October	2026	t	2027	2
2026-10-22	Thursday	10	October	2026	t	2027	2
2026-10-23	Friday	10	October	2026	t	2027	2
2026-10-24	Saturday	10	October	2026	f	2027	2
2026-10-25	Sunday	10	October	2026	f	2027	2
2026-10-26	Monday	10	October	2026	t	2027	2
2026-10-27	Tuesday	10	October	2026	t	2027	2
2026-10-28	Wednesday	10	October	2026	t	2027	2
2026-10-29	Thursday	10	October	2026	t	2027	2
2026-10-30	Friday	10	October	2026	t	2027	2
2026-10-31	Saturday	10	October	2026	f	2027	2
2026-11-02	Monday	11	November	2026	t	2027	1
2026-11-03	Tuesday	11	November	2026	t	2027	1
2026-11-04	Wednesday	11	November	2026	t	2027	1
2026-11-05	Thursday	11	November	2026	t	2027	1
2026-11-06	Friday	11	November	2026	t	2027	1
2026-11-07	Saturday	11	November	2026	f	2027	1
2026-11-08	Sunday	11	November	2026	f	2027	1
2026-11-09	Monday	11	November	2026	t	2027	1
2026-11-10	Tuesday	11	November	2026	t	2027	1
2026-11-11	Wednesday	11	November	2026	t	2027	1
2026-11-12	Thursday	11	November	2026	t	2027	1
2026-11-13	Friday	11	November	2026	t	2027	1
2026-11-14	Saturday	11	November	2026	f	2027	1
2026-11-15	Sunday	11	November	2026	f	2027	1
2026-11-16	Monday	11	November	2026	t	2027	2
2026-11-17	Tuesday	11	November	2026	t	2027	2
2026-11-18	Wednesday	11	November	2026	t	2027	2
2026-11-19	Thursday	11	November	2026	t	2027	2
2026-11-20	Friday	11	November	2026	t	2027	2
2026-11-21	Saturday	11	November	2026	f	2027	2
2026-11-22	Sunday	11	November	2026	f	2027	2
2026-11-23	Monday	11	November	2026	t	2027	2
2026-11-24	Tuesday	11	November	2026	t	2027	2
2026-11-25	Wednesday	11	November	2026	t	2027	2
2026-11-26	Thursday	11	November	2026	t	2027	2
2026-11-27	Friday	11	November	2026	t	2027	2
2026-11-28	Saturday	11	November	2026	f	2027	2
2026-11-29	Sunday	11	November	2026	f	2027	2
2026-11-30	Monday	11	November	2026	t	2027	2
2026-12-01	Tuesday	12	December	2026	t	2027	1
2026-12-02	Wednesday	12	December	2026	t	2027	1
2026-12-03	Thursday	12	December	2026	t	2027	1
2026-12-04	Friday	12	December	2026	t	2027	1
2026-12-05	Saturday	12	December	2026	f	2027	1
2026-12-06	Sunday	12	December	2026	f	2027	1
2026-12-09	Wednesday	12	December	2026	t	2027	1
2026-12-10	Thursday	12	December	2026	t	2027	1
2026-12-11	Friday	12	December	2026	t	2027	1
2026-12-12	Saturday	12	December	2026	f	2027	1
2026-12-13	Sunday	12	December	2026	f	2027	1
2026-12-14	Monday	12	December	2026	t	2027	1
2026-12-15	Tuesday	12	December	2026	t	2027	1
2026-12-16	Wednesday	12	December	2026	t	2027	2
2026-12-17	Thursday	12	December	2026	t	2027	2
2026-12-18	Friday	12	December	2026	t	2027	2
2026-12-19	Saturday	12	December	2026	f	2027	2
2026-12-20	Sunday	12	December	2026	f	2027	2
2026-12-21	Monday	12	December	2026	t	2027	2
2026-12-22	Tuesday	12	December	2026	t	2027	2
2026-12-23	Wednesday	12	December	2026	t	2027	2
2026-12-24	Thursday	12	December	2026	t	2027	2
2026-12-27	Sunday	12	December	2026	f	2027	2
2026-12-28	Monday	12	December	2026	t	2027	2
2026-12-29	Tuesday	12	December	2026	t	2027	2
2026-12-30	Wednesday	12	December	2026	t	2027	2
2026-12-31	Thursday	12	December	2026	t	2027	2
2027-01-02	Saturday	01	January	2027	f	2027	1
2027-01-03	Sunday	01	January	2027	f	2027	1
2027-01-04	Monday	01	January	2027	t	2027	1
2027-01-05	Tuesday	01	January	2027	t	2027	1
2027-01-06	Wednesday	01	January	2027	t	2027	1
2027-01-07	Thursday	01	January	2027	t	2027	1
2027-01-08	Friday	01	January	2027	t	2027	1
2027-01-09	Saturday	01	January	2027	f	2027	1
2027-01-10	Sunday	01	January	2027	f	2027	1
2027-01-11	Monday	01	January	2027	t	2027	1
2027-01-12	Tuesday	01	January	2027	t	2027	1
2027-01-13	Wednesday	01	January	2027	t	2027	1
2027-01-14	Thursday	01	January	2027	t	2027	1
2026-12-07	Monday	12	December	2026	f	2027	1
2026-12-08	Tuesday	12	December	2026	f	2027	1
2027-01-17	Sunday	01	January	2027	f	2027	2
2027-01-18	Monday	01	January	2027	t	2027	2
2027-01-19	Tuesday	01	January	2027	t	2027	2
2027-01-20	Wednesday	01	January	2027	t	2027	2
2027-01-21	Thursday	01	January	2027	t	2027	2
2027-01-22	Friday	01	January	2027	t	2027	2
2027-01-23	Saturday	01	January	2027	f	2027	2
2027-01-24	Sunday	01	January	2027	f	2027	2
2027-01-25	Monday	01	January	2027	t	2027	2
2027-01-26	Tuesday	01	January	2027	t	2027	2
2027-01-27	Wednesday	01	January	2027	t	2027	2
2027-01-28	Thursday	01	January	2027	t	2027	2
2027-01-29	Friday	01	January	2027	t	2027	2
2027-01-30	Saturday	01	January	2027	f	2027	2
2027-01-31	Sunday	01	January	2027	f	2027	2
2027-02-01	Monday	02	February	2027	t	2027	1
2027-02-02	Tuesday	02	February	2027	t	2027	1
2027-02-03	Wednesday	02	February	2027	t	2027	1
2027-02-04	Thursday	02	February	2027	t	2027	1
2027-02-05	Friday	02	February	2027	t	2027	1
2027-02-06	Saturday	02	February	2027	f	2027	1
2027-02-07	Sunday	02	February	2027	f	2027	1
2027-02-08	Monday	02	February	2027	t	2027	1
2027-02-09	Tuesday	02	February	2027	t	2027	1
2027-02-10	Wednesday	02	February	2027	t	2027	1
2027-02-11	Thursday	02	February	2027	t	2027	1
2027-02-12	Friday	02	February	2027	t	2027	1
2027-02-13	Saturday	02	February	2027	f	2027	1
2027-02-14	Sunday	02	February	2027	f	2027	1
2027-02-15	Monday	02	February	2027	t	2027	1
2027-02-16	Tuesday	02	February	2027	t	2027	2
2027-02-17	Wednesday	02	February	2027	t	2027	2
2027-02-18	Thursday	02	February	2027	t	2027	2
2027-02-19	Friday	02	February	2027	t	2027	2
2027-02-20	Saturday	02	February	2027	f	2027	2
2027-02-21	Sunday	02	February	2027	f	2027	2
2027-02-22	Monday	02	February	2027	t	2027	2
2027-02-23	Tuesday	02	February	2027	t	2027	2
2027-02-24	Wednesday	02	February	2027	t	2027	2
2027-02-25	Thursday	02	February	2027	t	2027	2
2027-02-26	Friday	02	February	2027	t	2027	2
2027-02-27	Saturday	02	February	2027	f	2027	2
2027-02-28	Sunday	02	February	2027	f	2027	2
2027-03-01	Monday	03	March	2027	t	2027	1
2027-03-02	Tuesday	03	March	2027	t	2027	1
2027-03-03	Wednesday	03	March	2027	t	2027	1
2027-03-04	Thursday	03	March	2027	t	2027	1
2027-03-05	Friday	03	March	2027	t	2027	1
2027-03-06	Saturday	03	March	2027	f	2027	1
2027-03-07	Sunday	03	March	2027	f	2027	1
2027-03-08	Monday	03	March	2027	t	2027	1
2027-03-09	Tuesday	03	March	2027	t	2027	1
2027-03-10	Wednesday	03	March	2027	t	2027	1
2027-03-11	Thursday	03	March	2027	t	2027	1
2027-03-12	Friday	03	March	2027	t	2027	1
2027-03-13	Saturday	03	March	2027	f	2027	1
2027-03-14	Sunday	03	March	2027	f	2027	1
2027-03-15	Monday	03	March	2027	t	2027	1
2027-03-16	Tuesday	03	March	2027	t	2027	2
2027-03-17	Wednesday	03	March	2027	t	2027	2
2027-03-18	Thursday	03	March	2027	t	2027	2
2027-03-19	Friday	03	March	2027	t	2027	2
2027-03-20	Saturday	03	March	2027	f	2027	2
2027-03-21	Sunday	03	March	2027	f	2027	2
2027-03-22	Monday	03	March	2027	t	2027	2
2027-03-23	Tuesday	03	March	2027	t	2027	2
2027-03-24	Wednesday	03	March	2027	t	2027	2
2027-03-25	Thursday	03	March	2027	t	2027	2
2027-03-26	Friday	03	March	2027	t	2027	2
2027-03-27	Saturday	03	March	2027	f	2027	2
2027-03-28	Sunday	03	March	2027	f	2027	2
2027-03-30	Tuesday	03	March	2027	t	2027	2
2027-03-31	Wednesday	03	March	2027	t	2027	2
2027-04-01	Thursday	04	April	2027	t	2027	1
2027-04-02	Friday	04	April	2027	t	2027	1
2027-04-03	Saturday	04	April	2027	f	2027	1
2027-04-04	Sunday	04	April	2027	f	2027	1
2027-04-05	Monday	04	April	2027	t	2027	1
2027-04-06	Tuesday	04	April	2027	t	2027	1
2027-04-07	Wednesday	04	April	2027	t	2027	1
2027-04-08	Thursday	04	April	2027	t	2027	1
2027-04-09	Friday	04	April	2027	t	2027	1
2027-04-10	Saturday	04	April	2027	f	2027	1
2027-04-11	Sunday	04	April	2027	f	2027	1
2027-04-12	Monday	04	April	2027	t	2027	1
2027-04-13	Tuesday	04	April	2027	t	2027	1
2027-04-14	Wednesday	04	April	2027	t	2027	1
2027-04-15	Thursday	04	April	2027	t	2027	1
2027-04-16	Friday	04	April	2027	t	2027	2
2027-04-17	Saturday	04	April	2027	f	2027	2
2027-04-18	Sunday	04	April	2027	f	2027	2
2027-04-19	Monday	04	April	2027	t	2027	2
2027-04-20	Tuesday	04	April	2027	t	2027	2
2027-04-21	Wednesday	04	April	2027	t	2027	2
2027-04-22	Thursday	04	April	2027	t	2027	2
2027-04-23	Friday	04	April	2027	t	2027	2
2027-04-24	Saturday	04	April	2027	f	2027	2
2027-04-26	Monday	04	April	2027	t	2027	2
2027-04-27	Tuesday	04	April	2027	t	2027	2
2027-04-28	Wednesday	04	April	2027	t	2027	2
2027-04-29	Thursday	04	April	2027	t	2027	2
2027-04-30	Friday	04	April	2027	t	2027	2
2027-05-02	Sunday	05	May	2027	f	2027	1
2027-05-03	Monday	05	May	2027	t	2027	1
2027-05-04	Tuesday	05	May	2027	t	2027	1
2027-05-05	Wednesday	05	May	2027	t	2027	1
2027-05-06	Thursday	05	May	2027	t	2027	1
2027-05-07	Friday	05	May	2027	t	2027	1
2027-05-08	Saturday	05	May	2027	f	2027	1
2027-05-09	Sunday	05	May	2027	f	2027	1
2027-05-10	Monday	05	May	2027	t	2027	1
2027-05-11	Tuesday	05	May	2027	t	2027	1
2027-05-12	Wednesday	05	May	2027	t	2027	1
2027-05-13	Thursday	05	May	2027	t	2027	1
2027-05-14	Friday	05	May	2027	t	2027	1
2027-05-15	Saturday	05	May	2027	f	2027	1
2027-05-16	Sunday	05	May	2027	f	2027	2
2027-05-17	Monday	05	May	2027	t	2027	2
2027-05-18	Tuesday	05	May	2027	t	2027	2
2027-05-19	Wednesday	05	May	2027	t	2027	2
2027-05-21	Friday	05	May	2027	t	2027	2
2027-05-22	Saturday	05	May	2027	f	2027	2
2027-05-23	Sunday	05	May	2027	f	2027	2
2027-05-24	Monday	05	May	2027	t	2027	2
2027-05-25	Tuesday	05	May	2027	t	2027	2
2027-05-26	Wednesday	05	May	2027	t	2027	2
2027-05-27	Thursday	05	May	2027	t	2027	2
2027-05-28	Friday	05	May	2027	t	2027	2
2027-05-29	Saturday	05	May	2027	f	2027	2
2027-05-30	Sunday	05	May	2027	f	2027	2
2027-05-31	Monday	05	May	2027	t	2027	2
2027-06-01	Tuesday	06	June	2027	t	2027	1
2027-06-03	Thursday	06	June	2027	t	2027	1
2027-06-04	Friday	06	June	2027	t	2027	1
2027-06-05	Saturday	06	June	2027	f	2027	1
2027-06-06	Sunday	06	June	2027	f	2027	1
2027-06-07	Monday	06	June	2027	t	2027	1
2027-06-08	Tuesday	06	June	2027	t	2027	1
2027-06-09	Wednesday	06	June	2027	t	2027	1
2027-06-10	Thursday	06	June	2027	t	2027	1
2027-06-11	Friday	06	June	2027	t	2027	1
2027-06-12	Saturday	06	June	2027	f	2027	1
2027-06-13	Sunday	06	June	2027	f	2027	1
2027-06-14	Monday	06	June	2027	t	2027	1
2027-06-15	Tuesday	06	June	2027	t	2027	1
2027-06-16	Wednesday	06	June	2027	t	2027	2
2027-06-17	Thursday	06	June	2027	t	2027	2
2027-06-18	Friday	06	June	2027	t	2027	2
2027-06-19	Saturday	06	June	2027	f	2027	2
2027-06-20	Sunday	06	June	2027	f	2027	2
2027-06-21	Monday	06	June	2027	t	2027	2
2027-06-22	Tuesday	06	June	2027	t	2027	2
2027-06-23	Wednesday	06	June	2027	t	2027	2
2027-06-24	Thursday	06	June	2027	t	2027	2
2027-06-25	Friday	06	June	2027	t	2027	2
2027-06-26	Saturday	06	June	2027	f	2027	2
2027-06-27	Sunday	06	June	2027	f	2027	2
2027-06-28	Monday	06	June	2027	t	2027	2
2027-06-29	Tuesday	06	June	2027	t	2027	2
2027-06-30	Wednesday	06	June	2027	t	2027	2
2027-07-01	Thursday	07	July	2027	t	2027	1
2027-07-02	Friday	07	July	2027	t	2027	1
2027-07-03	Saturday	07	July	2027	f	2027	1
2027-07-04	Sunday	07	July	2027	f	2027	1
2027-07-05	Monday	07	July	2027	t	2027	1
2027-07-06	Tuesday	07	July	2027	t	2027	1
2027-07-07	Wednesday	07	July	2027	t	2027	1
2027-07-08	Thursday	07	July	2027	t	2027	1
2027-07-09	Friday	07	July	2027	t	2027	1
2027-07-10	Saturday	07	July	2027	f	2027	1
2027-07-11	Sunday	07	July	2027	f	2027	1
2027-07-12	Monday	07	July	2027	t	2027	1
2027-07-13	Tuesday	07	July	2027	t	2027	1
2027-07-14	Wednesday	07	July	2027	t	2027	1
2027-07-15	Thursday	07	July	2027	t	2027	1
2027-07-16	Friday	07	July	2027	t	2027	2
2027-07-17	Saturday	07	July	2027	f	2027	2
2027-07-18	Sunday	07	July	2027	f	2027	2
2027-07-19	Monday	07	July	2027	t	2027	2
2027-07-20	Tuesday	07	July	2027	t	2027	2
2027-07-21	Wednesday	07	July	2027	t	2027	2
2027-07-22	Thursday	07	July	2027	t	2027	2
2027-07-23	Friday	07	July	2027	t	2027	2
2027-07-24	Saturday	07	July	2027	f	2027	2
2027-07-25	Sunday	07	July	2027	f	2027	2
2027-07-26	Monday	07	July	2027	t	2027	2
2027-07-27	Tuesday	07	July	2027	t	2027	2
2027-07-28	Wednesday	07	July	2027	t	2027	2
2027-07-29	Thursday	07	July	2027	t	2027	2
2027-07-30	Friday	07	July	2027	t	2027	2
2027-07-31	Saturday	07	July	2027	f	2027	2
2027-08-01	Sunday	08	August	2027	f	2027	1
2027-08-02	Monday	08	August	2027	t	2027	1
2027-08-03	Tuesday	08	August	2027	t	2027	1
2027-08-04	Wednesday	08	August	2027	t	2027	1
2027-08-05	Thursday	08	August	2027	t	2027	1
2027-08-06	Friday	08	August	2027	t	2027	1
2027-08-07	Saturday	08	August	2027	f	2027	1
2027-08-08	Sunday	08	August	2027	f	2027	1
2027-08-09	Monday	08	August	2027	t	2027	1
2027-08-10	Tuesday	08	August	2027	t	2027	1
2027-08-11	Wednesday	08	August	2027	t	2027	1
2027-08-12	Thursday	08	August	2027	t	2027	1
2027-08-13	Friday	08	August	2027	t	2027	1
2027-08-14	Saturday	08	August	2027	f	2027	1
2027-08-16	Monday	08	August	2027	t	2027	2
2027-08-17	Tuesday	08	August	2027	t	2027	2
2027-08-18	Wednesday	08	August	2027	t	2027	2
2027-08-19	Thursday	08	August	2027	t	2027	2
2027-08-20	Friday	08	August	2027	t	2027	2
2027-08-21	Saturday	08	August	2027	f	2027	2
2027-08-22	Sunday	08	August	2027	f	2027	2
2027-08-23	Monday	08	August	2027	t	2027	2
2027-08-24	Tuesday	08	August	2027	t	2027	2
2027-08-25	Wednesday	08	August	2027	t	2027	2
2027-08-26	Thursday	08	August	2027	t	2027	2
2027-08-27	Friday	08	August	2027	t	2027	2
2027-08-28	Saturday	08	August	2027	f	2027	2
2027-08-29	Sunday	08	August	2027	f	2027	2
2027-08-30	Monday	08	August	2027	t	2027	2
2027-08-31	Tuesday	08	August	2027	t	2027	2
2027-09-01	Wednesday	09	September	2027	t	2028	1
2027-09-02	Thursday	09	September	2027	t	2028	1
2027-09-03	Friday	09	September	2027	t	2028	1
2027-09-04	Saturday	09	September	2027	f	2028	1
2027-09-05	Sunday	09	September	2027	f	2028	1
2027-09-06	Monday	09	September	2027	t	2028	1
2027-09-07	Tuesday	09	September	2027	t	2028	1
2027-09-08	Wednesday	09	September	2027	t	2028	1
2027-09-09	Thursday	09	September	2027	t	2028	1
2027-09-10	Friday	09	September	2027	t	2028	1
2027-09-11	Saturday	09	September	2027	f	2028	1
2027-09-12	Sunday	09	September	2027	f	2028	1
2027-09-13	Monday	09	September	2027	t	2028	1
2027-09-14	Tuesday	09	September	2027	t	2028	1
2027-09-15	Wednesday	09	September	2027	t	2028	1
2027-09-16	Thursday	09	September	2027	t	2028	2
2027-09-17	Friday	09	September	2027	t	2028	2
2027-09-18	Saturday	09	September	2027	f	2028	2
2027-09-19	Sunday	09	September	2027	f	2028	2
2027-09-20	Monday	09	September	2027	t	2028	2
2027-09-21	Tuesday	09	September	2027	t	2028	2
2027-06-02	Wednesday	06	June	2027	f	2027	1
2027-10-06	Wednesday	10	October	2027	t	2028	1
2027-10-07	Thursday	10	October	2027	t	2028	1
2027-10-08	Friday	10	October	2027	t	2028	1
2027-10-09	Saturday	10	October	2027	f	2028	1
2027-10-10	Sunday	10	October	2027	f	2028	1
2027-10-11	Monday	10	October	2027	t	2028	1
2027-10-12	Tuesday	10	October	2027	t	2028	1
2027-10-13	Wednesday	10	October	2027	t	2028	1
2027-10-14	Thursday	10	October	2027	t	2028	1
2027-10-15	Friday	10	October	2027	t	2028	1
2027-10-16	Saturday	10	October	2027	f	2028	2
2027-10-17	Sunday	10	October	2027	f	2028	2
2027-10-18	Monday	10	October	2027	t	2028	2
2027-10-19	Tuesday	10	October	2027	t	2028	2
2027-10-20	Wednesday	10	October	2027	t	2028	2
2027-10-21	Thursday	10	October	2027	t	2028	2
2027-10-22	Friday	10	October	2027	t	2028	2
2027-10-23	Saturday	10	October	2027	f	2028	2
2027-10-24	Sunday	10	October	2027	f	2028	2
2027-10-25	Monday	10	October	2027	t	2028	2
2027-10-26	Tuesday	10	October	2027	t	2028	2
2027-10-27	Wednesday	10	October	2027	t	2028	2
2027-10-28	Thursday	10	October	2027	t	2028	2
2027-10-29	Friday	10	October	2027	t	2028	2
2027-10-30	Saturday	10	October	2027	f	2028	2
2027-10-31	Sunday	10	October	2027	f	2028	2
2027-11-02	Tuesday	11	November	2027	t	2028	1
2027-11-03	Wednesday	11	November	2027	t	2028	1
2027-11-04	Thursday	11	November	2027	t	2028	1
2027-11-05	Friday	11	November	2027	t	2028	1
2027-11-06	Saturday	11	November	2027	f	2028	1
2027-11-07	Sunday	11	November	2027	f	2028	1
2027-11-08	Monday	11	November	2027	t	2028	1
2027-11-09	Tuesday	11	November	2027	t	2028	1
2027-11-10	Wednesday	11	November	2027	t	2028	1
2027-11-11	Thursday	11	November	2027	t	2028	1
2027-11-12	Friday	11	November	2027	t	2028	1
2027-11-13	Saturday	11	November	2027	f	2028	1
2027-11-14	Sunday	11	November	2027	f	2028	1
2027-11-15	Monday	11	November	2027	t	2028	1
2027-11-16	Tuesday	11	November	2027	t	2028	2
2027-11-17	Wednesday	11	November	2027	t	2028	2
2027-11-18	Thursday	11	November	2027	t	2028	2
2027-11-19	Friday	11	November	2027	t	2028	2
2027-11-20	Saturday	11	November	2027	f	2028	2
2027-11-21	Sunday	11	November	2027	f	2028	2
2027-11-22	Monday	11	November	2027	t	2028	2
2027-11-23	Tuesday	11	November	2027	t	2028	2
2027-11-24	Wednesday	11	November	2027	t	2028	2
2027-11-25	Thursday	11	November	2027	t	2028	2
2027-11-26	Friday	11	November	2027	t	2028	2
2027-11-27	Saturday	11	November	2027	f	2028	2
2027-11-28	Sunday	11	November	2027	f	2028	2
2027-11-29	Monday	11	November	2027	t	2028	2
2027-11-30	Tuesday	11	November	2027	t	2028	2
2027-12-01	Wednesday	12	December	2027	t	2028	1
2027-12-02	Thursday	12	December	2027	t	2028	1
2027-12-03	Friday	12	December	2027	t	2028	1
2027-12-04	Saturday	12	December	2027	f	2028	1
2027-12-05	Sunday	12	December	2027	f	2028	1
2027-12-06	Monday	12	December	2027	t	2028	1
2027-12-09	Thursday	12	December	2027	t	2028	1
2027-12-10	Friday	12	December	2027	t	2028	1
2027-12-11	Saturday	12	December	2027	f	2028	1
2027-12-12	Sunday	12	December	2027	f	2028	1
2027-12-13	Monday	12	December	2027	t	2028	1
2027-12-14	Tuesday	12	December	2027	t	2028	1
2027-12-15	Wednesday	12	December	2027	t	2028	1
2027-12-16	Thursday	12	December	2027	t	2028	2
2027-12-17	Friday	12	December	2027	t	2028	2
2027-12-18	Saturday	12	December	2027	f	2028	2
2027-12-19	Sunday	12	December	2027	f	2028	2
2027-12-20	Monday	12	December	2027	t	2028	2
2027-12-21	Tuesday	12	December	2027	t	2028	2
2027-12-22	Wednesday	12	December	2027	t	2028	2
2027-12-23	Thursday	12	December	2027	t	2028	2
2027-12-24	Friday	12	December	2027	t	2028	2
2027-12-27	Monday	12	December	2027	t	2028	2
2027-12-28	Tuesday	12	December	2027	t	2028	2
2027-12-29	Wednesday	12	December	2027	t	2028	2
2027-12-30	Thursday	12	December	2027	t	2028	2
2027-12-31	Friday	12	December	2027	t	2028	2
2027-12-07	Tuesday	12	December	2027	f	2028	1
2024-01-01	Monday	01	January	2024	f	2024	1
2024-04-01	Monday	04	April	2024	f	2024	1
2024-04-25	Thursday	04	April	2024	f	2024	2
2024-05-01	Wednesday	05	May	2024	f	2024	1
2024-08-15	Thursday	08	August	2024	f	2024	1
2024-12-26	Thursday	12	December	2024	f	2025	2
2025-01-01	Wednesday	01	January	2025	f	2025	1
\.


--
-- Data for Name: chg_target; Type: TABLE DATA; Schema: chargeability_manager; Owner: postgres
--

COPY chargeability_manager.chg_target (level, chg_t) FROM stdin;
6	74.5
7	86.2
8	90.5
9	90.5
10	90.9
11	90.9
12	89.3
\.


--
-- Data for Name: forecast_ferie; Type: TABLE DATA; Schema: chargeability_manager; Owner: postgres
--

COPY chargeability_manager.forecast_ferie (eid, yy_cal, mm_cal, fortnight, wbs, work_hh) FROM stdin;
pietro.resmini	2024	12	2	Ferie	32
gianluca.borchielli	2024	12	2	Ferie	32
domenico.bellone	2024	12	2	Ferie	32
salvatore.esposito	2024	12	2	Ferie	32
paul.zaha	2024	12	2	Ferie	32
valerio.del.vecchio	2024	12	2	Ferie	32
giovanna.rosa	2024	12	2	Ferie	32
leonardo.matrigiano	2024	12	2	Ferie	32
ciro.a.borrelli	2024	12	2	Ferie	32
g.barbato	2024	12	2	Ferie	32
valerio.del.vecchio	2024	11	1	Training	24
francesco.venezia	2024	12	2	Ferie	32
giovanna.rosa	2024	11	1	Ferie	4
francesco.venezia	2024	11	1	Ferie	16
leonardo.matrigiano	2024	11	2	Ferie	4
domenico.bellone	2024	11	2	Malattia	8
\.


--
-- Data for Name: holidays; Type: TABLE DATA; Schema: chargeability_manager; Owner: postgres
--

COPY chargeability_manager.holidays (dd_cal, holiday) FROM stdin;
2025-12-25	Natale
2024-12-25	Natale
2026-12-25	Natale
2027-12-25	Natale
2024-11-01	Tutti i Santi
2025-11-01	Tutti i Santi
2026-11-01	Tutti i Santi
2027-11-01	Tutti i Santi
2024-04-25	Liberazione
2025-04-25	Liberazione
2026-04-25	Liberazione
2027-04-25	Liberazione
2024-05-01	Lavoratori
2025-05-01	Lavoratori
2026-05-01	Lavoratori
2027-05-01	Lavoratori
2024-08-15	Assunzione
2025-08-15	Assunzione
2026-08-15	Assunzione
2027-08-15	Assunzione
2024-12-08	Immacolata
2025-12-08	Immacolata
2026-12-08	Immacolata
2027-12-08	Immacolata
2024-12-26	Santo Stefano
2025-12-26	Santo Stefano
2026-12-26	Santo Stefano
2027-12-26	Santo Stefano
2024-04-01	Lunedì dell'Angelo
2025-04-21	Lunedì dell'Angelo
2026-04-06	Lunedì dell'Angelo
2027-03-29	Lunedì dell'Angelo
2024-01-01	Capodanno
2025-01-01	Capodanno
2026-01-01	Capodanno
2027-01-01	Capodanno
2024-12-07	Sant'Ambrogio
2025-12-07	Sant'Ambrogio
2026-12-07	Sant'Ambrogio
2027-12-07	Sant'Ambrogio
2024-06-02	Repubblica
2025-06-02	Repubblica
2026-06-02	Repubblica
2027-06-02	Repubblica
\.


--
-- Data for Name: prg_budget; Type: TABLE DATA; Schema: chargeability_manager; Owner: postgres
--

COPY chargeability_manager.prg_budget (eid, wbs, perc_budget) FROM stdin;
pietro.resmini	B6N3000A	81.42
gianluca.borchielli	B6N3000A	4.62
domenico.bellone	B6N3000A	6
salvatore.esposito	B6N3000A	7.94
pietro.resmini	BVZTM001	90.63
gianluca.borchielli	BVZTM001	4.08
domenico.bellone	BVZTM001	5.28
\.


--
-- Data for Name: resources; Type: TABLE DATA; Schema: chargeability_manager; Owner: postgres
--

COPY chargeability_manager.resources (eid, last_name, first_name, level, loaded_cost, office, dte) FROM stdin;
gianluca.borchielli	Borchielli	Gianluca	11	24.92	Milano	Google
domenico.bellone	Bellone	Domenico	11	32.3	Milano	Google
salvatore.esposito	Esposito	Salvatore	5	128.3	Milano	Google
pietro.resmini	Resmini	Pietro	7	69.22	Milano	Google
francesco.ioli	Ioli	Francesco	8	61.6	Milano	Google
paul.zaha	Zaha	Paul	9	40.8	Milano	Google
valerio.del.vecchio	Del Vecchio	Valerio	9	33.38	Milano	Google
giovanna.rosa	Rosa	Giovanna	11	27.82	Milano	Google
leonardo.matrigiano	Matrigiano	Leonardo	11	27.82	Milano	Google
ciro.a.borrelli	Borrelli	Ciro	11	28.75	Napoli	ATC
g.barbato	Barbato	Giovanni	9	43.58	Milano	Google
francesco.venezia	Venezia	Francesco	9	33.38	Napoli	ATC
\.


--
-- Data for Name: template_tr; Type: TABLE DATA; Schema: chargeability_manager; Owner: postgres
--

COPY chargeability_manager.template_tr (eid, wbs, yy_cal, mm_cal, fortnight, perc_wbs, bool) FROM stdin;
ciro.a.borrelli	CAI8W001	2024	09	1	100	t
domenico.bellone	CAI8W001	2024	09	1	100	t
g.barbato	CAI8W001	2024	09	1	100	t
gianluca.borchielli	CAI8W001	2024	09	1	100	t
giovanna.rosa	CAI8W001	2024	09	1	100	t
leonardo.matrigiano	CAI8W001	2024	09	1	100	t
paul.zaha	CAI8W001	2024	09	1	100	t
valerio.del.vecchio	CAI8W001	2024	09	1	100	t
ciro.a.borrelli	CAI8W001	2024	09	2	100	t
domenico.bellone	CAI8W001	2024	09	2	100	t
g.barbato	CAI8W001	2024	09	2	100	t
gianluca.borchielli	CAI8W001	2024	09	2	100	t
giovanna.rosa	CAI8W001	2024	09	2	100	t
leonardo.matrigiano	CAI8W001	2024	09	2	100	t
paul.zaha	CAI8W001	2024	09	2	100	t
valerio.del.vecchio	CAI8W001	2024	09	2	100	t
pietro.resmini	CAI8W001	2024	09	1	100	t
pietro.resmini	CAI8W001	2024	09	2	100	t
francesco.venezia	CAI8W001	2024	09	1	100	t
francesco.venezia	CAI8W001	2024	09	2	100	t
\.


--
-- Data for Name: time_report; Type: TABLE DATA; Schema: chargeability_manager; Owner: postgres
--

COPY chargeability_manager.time_report (eid, wbs, yy_cal, mm_cal, fortnight, work_hh, fl_forecast) FROM stdin;
pietro.resmini	CCIOH009	2024	10	1	14	f
pietro.resmini	Z028SJ43	2024	10	1	16	f
pietro.resmini	B8IHZ00A	2024	10	1	16	f
pietro.resmini	B6N3000A	2024	10	1	18	f
pietro.resmini	Training	2024	10	1	24	f
pietro.resmini	CCIOH009	2024	10	2	14	f
pietro.resmini	BXT1G001	2024	10	2	16	f
pietro.resmini	B8PW6002	2024	10	2	16	f
pietro.resmini	B6N3000A	2024	10	2	42	f
pietro.resmini	Training	2024	10	2	4	f
pietro.resmini	Meeting	2024	10	2	4	f
gianluca.borchielli	BVZTM001	2024	09	1	2	f
gianluca.borchielli	BVZTM001	2024	09	2	2	f
gianluca.borchielli	BVZTM001	2024	10	1	2	f
gianluca.borchielli	BVZTM001	2024	10	2	2	f
gianluca.borchielli	CAI8W001	2024	09	1	72	f
gianluca.borchielli	CAI8W001	2024	09	2	80	f
gianluca.borchielli	CAI8W001	2024	10	1	53	f
gianluca.borchielli	CAI8W001	2024	10	2	64	f
gianluca.borchielli	B6N3000A	2024	09	1	6	f
gianluca.borchielli	B6N3000A	2024	09	2	6	f
gianluca.borchielli	B6N3000A	2024	10	1	25	f
gianluca.borchielli	B6N3000A	2024	10	2	6	f
gianluca.borchielli	Meeting	2024	10	1	8	f
gianluca.borchielli	Meeting	2024	10	2	8	f
gianluca.borchielli	Malattia	2024	10	2	16	f
domenico.bellone	BVZTM001	2024	09	1	2	f
domenico.bellone	BVZTM001	2024	09	2	2	f
domenico.bellone	BVZTM001	2024	10	1	2	f
domenico.bellone	BVZTM001	2024	10	2	2	f
domenico.bellone	CAI8W001	2024	09	1	72	f
domenico.bellone	CAI8W001	2024	09	2	80	f
domenico.bellone	CAI8W001	2024	10	1	53	f
domenico.bellone	CAI8W001	2024	10	2	80	f
domenico.bellone	B6N3000A	2024	09	1	6	f
domenico.bellone	B6N3000A	2024	09	2	6	f
domenico.bellone	B6N3000A	2024	10	1	25	f
domenico.bellone	B6N3000A	2024	10	2	6	f
domenico.bellone	Meeting	2024	10	1	8	f
domenico.bellone	Meeting	2024	10	2	8	f
pietro.resmini	CCIOH009	2024	09	1	30	f
pietro.resmini	BVZTM001	2024	09	1	16	f
pietro.resmini	B6N3000A	2024	09	1	34	f
pietro.resmini	CCIOH009	2024	09	2	30	f
pietro.resmini	BVZTM001	2024	09	2	16	f
pietro.resmini	B6N3000A	2024	09	2	42	f
valerio.del.vecchio	CAI8W001	2024	09	1	72	f
valerio.del.vecchio	CAI8W001	2024	09	2	72	f
valerio.del.vecchio	CAI8W001	2024	10	1	80	f
valerio.del.vecchio	CAI8W001	2024	10	2	84	f
valerio.del.vecchio	Meeting	2024	09	1	8	f
valerio.del.vecchio	Meeting	2024	09	2	16	f
valerio.del.vecchio	Meeting	2024	10	1	8	f
valerio.del.vecchio	Meeting	2024	10	2	12	f
giovanna.rosa	CAI8W001	2024	09	1	80	f
giovanna.rosa	CAI8W001	2024	09	2	80	f
giovanna.rosa	CAI8W001	2024	10	1	82	f
giovanna.rosa	CAI8W001	2024	10	2	84	f
giovanna.rosa	Meeting	2024	09	2	8	f
giovanna.rosa	Meeting	2024	10	1	6	f
giovanna.rosa	Meeting	2024	10	2	12	f
leonardo.matrigiano	CAI8W001	2024	09	1	72	f
leonardo.matrigiano	CAI8W001	2024	09	2	79	f
leonardo.matrigiano	CAI8W001	2024	10	1	80	f
leonardo.matrigiano	CAI8W001	2024	10	2	84	f
leonardo.matrigiano	Meeting	2024	09	1	8	f
leonardo.matrigiano	Meeting	2024	09	2	9	f
leonardo.matrigiano	Meeting	2024	10	1	8	f
leonardo.matrigiano	Meeting	2024	10	2	12	f
pietro.resmini	B6N3000A	2024	12	1	34	t
pietro.resmini	BVZTM001	2024	12	1	16	t
pietro.resmini	B6N3000A	2024	12	2	26	t
pietro.resmini	BVZTM001	2024	12	2	11	t
pietro.resmini	Ferie	2024	12	2	32	t
gianluca.borchielli	B6N3000A	2024	12	1	6	t
gianluca.borchielli	BVZTM001	2024	12	1	2	t
gianluca.borchielli	B6N3000A	2024	12	2	29	t
gianluca.borchielli	BVZTM001	2024	12	2	9	t
domenico.bellone	B6N3000A	2024	12	1	6	t
domenico.bellone	BVZTM001	2024	12	1	2	t
domenico.bellone	B6N3000A	2024	12	2	23	t
domenico.bellone	BVZTM001	2024	12	2	9	t
salvatore.esposito	B6N3000A	2024	12	1	2	t
salvatore.esposito	B6N3000A	2024	12	2	2	t
pietro.resmini	CAI8W001	2024	12	1	19	t
pietro.resmini	CAI8W001	2024	12	2	11	t
gianluca.borchielli	CAI8W001	2024	12	1	65	t
gianluca.borchielli	CAI8W001	2024	12	2	10	t
gianluca.borchielli	Ferie	2024	12	2	32	t
domenico.bellone	CAI8W001	2024	12	1	65	t
domenico.bellone	CAI8W001	2024	12	2	16	t
domenico.bellone	Ferie	2024	12	2	32	t
pietro.resmini	B6N3000A	2024	11	1	38	f
pietro.resmini	BVZTM001	2024	11	1	16	f
gianluca.borchielli	B6N3000A	2024	11	1	6	f
gianluca.borchielli	BVZTM001	2024	11	1	2	f
domenico.bellone	B6N3000A	2024	11	1	6	f
domenico.bellone	BVZTM001	2024	11	1	2	f
salvatore.esposito	B6N3000A	2024	11	1	2	f
pietro.resmini	CAI8W001	2024	11	1	15	f
gianluca.borchielli	CAI8W001	2024	11	1	65	f
domenico.bellone	CAI8W001	2024	11	1	65	f
domenico.bellone	Meeting	2024	11	1	7	f
domenico.bellone	Meeting	2024	12	1	7	t
gianluca.borchielli	Meeting	2024	12	1	7	t
pietro.resmini	Meeting	2024	12	1	11	t
paul.zaha	Meeting	2024	10	2	12	f
paul.zaha	CAI8W001	2024	10	2	84	f
paul.zaha	Meeting	2024	10	1	8	f
paul.zaha	CAI8W001	2024	10	1	80	f
paul.zaha	Meeting	2024	09	2	16	f
paul.zaha	CAI8W001	2024	09	2	72	f
paul.zaha	Meeting	2024	09	1	8	f
paul.zaha	CAI8W001	2024	09	1	72	f
ciro.a.borrelli	CAI8W001	2024	09	1	80	f
ciro.a.borrelli	CAI8W001	2024	09	2	88	f
ciro.a.borrelli	CAI8W001	2024	10	1	91	f
ciro.a.borrelli	CAI8W001	2024	10	2	97	f
g.barbato	CAI8W001	2024	10	2	79	f
g.barbato	Meeting	2024	10	2	9	f
g.barbato	Ferie	2024	10	2	8	f
g.barbato	Meeting	2024	10	1	8	f
g.barbato	CAI8W001	2024	10	1	80	f
g.barbato	CAI8W001	2024	09	2	69	f
g.barbato	Meeting	2024	09	2	16	f
g.barbato	Ferie	2024	09	2	3	f
g.barbato	CAI8W001	2024	09	1	69	f
g.barbato	Meeting	2024	09	1	8	f
g.barbato	Ferie	2024	09	1	3	f
paul.zaha	CAI8W001	2024	12	2	43	t
valerio.del.vecchio	CAI8W001	2024	12	2	43	t
giovanna.rosa	CAI8W001	2024	12	2	44	t
leonardo.matrigiano	CAI8W001	2024	12	2	44	t
ciro.a.borrelli	CAI8W001	2024	12	2	44	t
g.barbato	CAI8W001	2024	12	2	43	t
valerio.del.vecchio	CAI8W001	2024	12	1	72	t
leonardo.matrigiano	CAI8W001	2024	12	1	73	t
paul.zaha	CAI8W001	2024	12	1	72	t
giovanna.rosa	CAI8W001	2024	12	1	73	t
g.barbato	CAI8W001	2024	12	1	72	t
ciro.a.borrelli	CAI8W001	2024	12	1	73	t
paul.zaha	Meeting	2024	12	2	5	t
valerio.del.vecchio	Meeting	2024	12	2	5	t
giovanna.rosa	Meeting	2024	12	2	4	t
leonardo.matrigiano	Meeting	2024	12	2	4	t
ciro.a.borrelli	Meeting	2024	12	2	4	t
g.barbato	Meeting	2024	12	2	5	t
valerio.del.vecchio	Meeting	2024	12	1	8	t
leonardo.matrigiano	Meeting	2024	12	1	7	t
paul.zaha	Meeting	2024	12	1	8	t
giovanna.rosa	Meeting	2024	12	1	7	t
g.barbato	Meeting	2024	12	1	8	t
ciro.a.borrelli	Meeting	2024	12	1	7	t
pietro.resmini	Meeting	2024	11	1	11	f
paul.zaha	Ferie	2024	12	2	32	t
valerio.del.vecchio	Ferie	2024	12	2	32	t
giovanna.rosa	Ferie	2024	12	2	32	t
leonardo.matrigiano	Ferie	2024	12	2	32	t
ciro.a.borrelli	Ferie	2024	12	2	32	t
g.barbato	Ferie	2024	12	2	32	t
salvatore.esposito	B6N3000A	2024	09	2	2	t
salvatore.esposito	B6N3000A	2024	09	1	2	t
salvatore.esposito	B6N3000A	2024	10	1	2	t
salvatore.esposito	B6N3000A	2024	10	2	2	t
gianluca.borchielli	Meeting	2024	11	1	6	f
francesco.venezia	CAI8W001	2024	09	2	88	f
francesco.venezia	CAI8W001	2024	09	1	80	f
francesco.venezia	CAI8W001	2024	10	2	92	f
francesco.venezia	Ferie	2024	10	2	4	f
francesco.venezia	CAI8W001	2024	10	1	84	f
francesco.venezia	Ferie	2024	10	1	4	f
gianluca.borchielli	Ferie	2024	11	1	1	f
ciro.a.borrelli	CAI8W001	2024	11	1	80	f
francesco.venezia	CAI8W001	2024	11	1	64	f
francesco.venezia	Ferie	2024	11	1	16	f
francesco.venezia	CAI8W001	2024	12	2	43	t
francesco.venezia	CAI8W001	2024	12	1	72	t
francesco.venezia	Meeting	2024	12	2	5	t
francesco.venezia	Meeting	2024	12	1	8	t
francesco.venezia	Ferie	2024	12	2	32	t
g.barbato	CAI8W001	2024	11	1	72	f
g.barbato	Meeting	2024	11	1	8	f
giovanna.rosa	CAI8W001	2024	11	1	68	f
giovanna.rosa	Ferie	2024	11	1	4	f
giovanna.rosa	Meeting	2024	11	1	8	f
leonardo.matrigiano	CAI8W001	2024	11	1	72	f
leonardo.matrigiano	Meeting	2024	11	1	8	f
paul.zaha	CAI8W001	2024	11	1	72	f
paul.zaha	Meeting	2024	11	1	8	f
valerio.del.vecchio	CAI8W001	2024	11	1	56	f
valerio.del.vecchio	Meeting	2024	11	1	0	f
valerio.del.vecchio	Training	2024	11	1	24	f
leonardo.matrigiano	CAI8W001	2024	11	2	69	t
domenico.bellone	CAI8W001	2024	11	2	57	t
francesco.venezia	CAI8W001	2024	11	2	72	t
g.barbato	CAI8W001	2024	11	2	72	t
ciro.a.borrelli	CAI8W001	2024	11	2	73	t
gianluca.borchielli	CAI8W001	2024	11	2	65	t
giovanna.rosa	CAI8W001	2024	11	2	73	t
pietro.resmini	CAI8W001	2024	11	2	15	t
paul.zaha	CAI8W001	2024	11	2	72	t
valerio.del.vecchio	CAI8W001	2024	11	2	72	t
leonardo.matrigiano	Meeting	2024	11	2	7	t
domenico.bellone	Meeting	2024	11	2	7	t
francesco.venezia	Meeting	2024	11	2	8	t
g.barbato	Meeting	2024	11	2	8	t
ciro.a.borrelli	Meeting	2024	11	2	7	t
gianluca.borchielli	Meeting	2024	11	2	7	t
giovanna.rosa	Meeting	2024	11	2	7	t
pietro.resmini	Meeting	2024	11	2	11	t
paul.zaha	Meeting	2024	11	2	8	t
valerio.del.vecchio	Meeting	2024	11	2	8	t
pietro.resmini	B6N3000A	2024	11	2	38	t
gianluca.borchielli	B6N3000A	2024	11	2	6	t
domenico.bellone	B6N3000A	2024	11	2	6	t
salvatore.esposito	B6N3000A	2024	11	2	2	t
pietro.resmini	BVZTM001	2024	11	2	16	t
gianluca.borchielli	BVZTM001	2024	11	2	2	t
domenico.bellone	BVZTM001	2024	11	2	2	t
leonardo.matrigiano	Ferie	2024	11	2	4	t
domenico.bellone	Malattia	2024	11	2	8	t
\.


--
-- Data for Name: wbs; Type: TABLE DATA; Schema: chargeability_manager; Owner: postgres
--

COPY chargeability_manager.wbs (wbs, wbs_type, project_name, budget_mm, budget_tot) FROM stdin;
B6N3000A	CHG	Eni - Energy Management	6500	\N
BVZTM001	CHG	Eni - OpenES	2500	\N
BXT1G001	CHG	Eni - OpenES	2500	\N
B8PW6002	CHG	GEDI - Migrazione Lambda	\N	20400
B8IHZ00A	CHG	GEDI - Migrazione Lambda	\N	20400
CCIOH009	CHG	UCG - Old Data Product	\N	21384
CAI8W001	CHG	C4	\N	\N
Ferie	-	Ferie	\N	\N
Training	NOCHG	Training	\N	\N
Z028SJ43	CHG	Eni - OpenES	2500	\N
Meeting	NOCHG	Meeting	\N	\N
Malattia	-	Malattia	\N	\N
\.


--
-- Name: calendar calendar_pkey; Type: CONSTRAINT; Schema: chargeability_manager; Owner: postgres
--

ALTER TABLE ONLY chargeability_manager.calendar
    ADD CONSTRAINT calendar_pkey PRIMARY KEY (dd_cal);


--
-- Name: chg_target chg_target_pkey; Type: CONSTRAINT; Schema: chargeability_manager; Owner: postgres
--

ALTER TABLE ONLY chargeability_manager.chg_target
    ADD CONSTRAINT chg_target_pkey PRIMARY KEY (level);


--
-- Name: holidays holidays_pkey; Type: CONSTRAINT; Schema: chargeability_manager; Owner: postgres
--

ALTER TABLE ONLY chargeability_manager.holidays
    ADD CONSTRAINT holidays_pkey PRIMARY KEY (dd_cal);


--
-- Name: resources resources_pkey; Type: CONSTRAINT; Schema: chargeability_manager; Owner: postgres
--

ALTER TABLE ONLY chargeability_manager.resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (eid);


--
-- Name: template_tr template_tr_pk; Type: CONSTRAINT; Schema: chargeability_manager; Owner: postgres
--

ALTER TABLE ONLY chargeability_manager.template_tr
    ADD CONSTRAINT template_tr_pk PRIMARY KEY (eid, wbs, mm_cal, fortnight);


--
-- Name: time_report time_report_pkey; Type: CONSTRAINT; Schema: chargeability_manager; Owner: postgres
--

ALTER TABLE ONLY chargeability_manager.time_report
    ADD CONSTRAINT time_report_pkey PRIMARY KEY (eid, wbs, mm_cal, fortnight);


--
-- Name: wbs wbs_pkey; Type: CONSTRAINT; Schema: chargeability_manager; Owner: postgres
--

ALTER TABLE ONLY chargeability_manager.wbs
    ADD CONSTRAINT wbs_pkey PRIMARY KEY (wbs);


--
-- PostgreSQL database dump complete
--

