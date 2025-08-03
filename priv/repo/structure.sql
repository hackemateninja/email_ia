--
-- PostgreSQL database dump
--

-- Dumped from database version 13.21 (Postgres.app)
-- Dumped by pg_dump version 13.21 (Postgres.app)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id uuid NOT NULL,
    name character varying(255),
    description character varying(255),
    user_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emails (
    id uuid NOT NULL,
    message_id character varying(255),
    subject character varying(255),
    "from" character varying(255),
    "to" character varying(255),
    snippet character varying(255),
    ai_summary text,
    original_body text,
    unsubscribe_link character varying(255),
    imported_at timestamp(0) without time zone,
    archived boolean DEFAULT false NOT NULL,
    google_account_id uuid,
    category_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: google_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.google_accounts (
    id uuid NOT NULL,
    email character varying(255),
    access_token text,
    refresh_token text,
    token_expiry timestamp(0) without time zone,
    user_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(255),
    image character varying(255),
    provider character varying(255) NOT NULL,
    provider_uid character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: google_accounts google_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_accounts
    ADD CONSTRAINT google_accounts_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: categories_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX categories_user_id_index ON public.categories USING btree (user_id);


--
-- Name: emails_category_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX emails_category_id_index ON public.emails USING btree (category_id);


--
-- Name: emails_google_account_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX emails_google_account_id_index ON public.emails USING btree (google_account_id);


--
-- Name: google_accounts_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX google_accounts_user_id_index ON public.google_accounts USING btree (user_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_provider_provider_uid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_provider_provider_uid_index ON public.users USING btree (provider, provider_uid);


--
-- Name: categories categories_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: emails emails_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: emails emails_google_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_google_account_id_fkey FOREIGN KEY (google_account_id) REFERENCES public.google_accounts(id);


--
-- Name: google_accounts google_accounts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.google_accounts
    ADD CONSTRAINT google_accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20250803085937);
INSERT INTO public."schema_migrations" (version) VALUES (20250803085938);
INSERT INTO public."schema_migrations" (version) VALUES (20250803090532);
INSERT INTO public."schema_migrations" (version) VALUES (20250803091858);
