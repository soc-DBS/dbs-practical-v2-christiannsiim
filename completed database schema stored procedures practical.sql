PGDMP  :         	            }            highgarden_university    16.8    16.8 6    k           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            l           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            m           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            n           1262    16923    highgarden_university    DATABASE     {   CREATE DATABASE highgarden_university WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en-US';
 %   DROP DATABASE highgarden_university;
                postgres    false            �            1255    17059    calculate_students_gpa() 	   PROCEDURE       CREATE PROCEDURE public.calculate_students_gpa()
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_adm_no CHAR(4);
    v_mod_performance RECORD;
    total_credit_units INT;
    total_weighted_grade_points NUMERIC;
    computed_gpa NUMERIC;
BEGIN
    -- Loop through distinct students
    FOR v_adm_no IN (
        SELECT DISTINCT adm_no FROM stud_mod_performance
    )
    LOOP
        total_credit_units := 0;
        total_weighted_grade_points := 0;
        
        -- Nested loop for each student's modules
        FOR v_mod_performance IN
            SELECT smp.grade, m.credit_unit
            FROM stud_mod_performance smp
            JOIN module m ON smp.mod_registered = m.mod_code
            WHERE smp.adm_no = v_adm_no
        LOOP
            -- Calculate totals using the grade point function
            total_credit_units := total_credit_units + v_mod_performance.credit_unit;
            total_weighted_grade_points := total_weighted_grade_points + 
                (get_grade_point(v_mod_performance.grade) * v_mod_performance.credit_unit);
        END LOOP;
        
        -- Calculate and update GPA
        IF total_credit_units > 0 THEN
            computed_gpa := total_weighted_grade_points / total_credit_units;
            UPDATE student 
            SET gpa = computed_gpa, gpa_last_updated = CURRENT_DATE
            WHERE adm_no = v_adm_no;
        END IF;
    END LOOP;
END;
$$;
 0   DROP PROCEDURE public.calculate_students_gpa();
       public          postgres    false            �            1255    17053 <   create_module(character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.create_module(IN p_code character varying, IN p_name character varying, IN p_credit integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (SELECT * FROM module WHERE mod_code = p_code) THEN
        RAISE EXCEPTION 'Module % already exists', p_code;
    END IF;
    INSERT INTO module (mod_code, mod_name, credit_unit) VALUES (p_code, p_name, p_credit);
END;
$$;
 t   DROP PROCEDURE public.create_module(IN p_code character varying, IN p_name character varying, IN p_credit integer);
       public          postgres    false            �            1255    17056     delete_module(character varying) 	   PROCEDURE     i  CREATE PROCEDURE public.delete_module(IN p_code character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if the module exists
    IF NOT EXISTS (SELECT * FROM module WHERE mod_code = p_code) THEN
        RAISE EXCEPTION 'Module % not found', p_code;
    END IF;
    
    -- Delete the module
    DELETE FROM module WHERE mod_code = p_code;
END;
$$;
 B   DROP PROCEDURE public.delete_module(IN p_code character varying);
       public          postgres    false            �            1255    17058    get_grade_point(character)    FUNCTION     �  CREATE FUNCTION public.get_grade_point(grade_input character) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    grade_point NUMERIC;
BEGIN
    grade_point := CASE
        WHEN grade_input = 'AD' THEN 4.0
        WHEN grade_input = 'A' THEN 4.0
        WHEN grade_input = 'B+' THEN 3.5
        WHEN grade_input = 'B' THEN 3.0
        WHEN grade_input = 'C+' THEN 2.5
        WHEN grade_input = 'C' THEN 2.0
        WHEN grade_input = 'D+' THEN 1.5
        WHEN grade_input = 'D' THEN 1.0
        WHEN grade_input = 'F' THEN 0.0
        ELSE NULL
    END;
    
    IF grade_point IS NULL THEN
        RAISE EXCEPTION 'Invalid Grade: %', grade_input;
    END IF;
    
    RETURN grade_point;
END;
$$;
 =   DROP FUNCTION public.get_grade_point(grade_input character);
       public          postgres    false            �            1255    17057    get_modules_performance()    FUNCTION     �  CREATE FUNCTION public.get_modules_performance() RETURNS TABLE(mod_registered character varying, grade character, grade_count bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        smp.mod_registered,
        smp.grade,
        COUNT(*)::BIGINT as grade_count
    FROM stud_mod_performance smp
    GROUP BY smp.mod_registered, smp.grade
    ORDER BY smp.grade, COUNT(*);
END;
$$;
 0   DROP FUNCTION public.get_modules_performance();
       public          postgres    false            �            1255    17055 )   update_module(character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.update_module(IN p_code character varying, IN p_credit integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if the module exists
    IF NOT EXISTS (SELECT * FROM module WHERE mod_code = p_code) THEN
        RAISE EXCEPTION 'Module % not found', p_code;
    END IF;
    
    -- Update the module
    UPDATE module SET credit_unit = p_credit WHERE mod_code = p_code;
END;
$$;
 W   DROP PROCEDURE public.update_module(IN p_code character varying, IN p_credit integer);
       public          postgres    false            �            1255    17054 <   update_module(character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.update_module(IN p_code character varying, IN p_name character varying, IN p_credit integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT * FROM module WHERE mod_code = p_code) THEN
        RAISE EXCEPTION 'Module % not found', p_code;
    END IF;
    UPDATE module SET mod_name = p_name, credit_unit = p_credit WHERE mod_code = p_code;
END;
$$;
 t   DROP PROCEDURE public.update_module(IN p_code character varying, IN p_name character varying, IN p_credit integer);
       public          postgres    false            �            1259    16924    country    TABLE     �   CREATE TABLE public.country (
    country_name character varying(30) NOT NULL,
    language character varying(30) NOT NULL,
    region character varying(30) NOT NULL
);
    DROP TABLE public.country;
       public         heap    postgres    false            �            1259    16927    course    TABLE     �   CREATE TABLE public.course (
    crse_code character varying(5) NOT NULL,
    crse_name character varying(100) NOT NULL,
    offered_by character varying(5) NOT NULL,
    crse_fee numeric(7,2) NOT NULL,
    lab_fee numeric(7,2)
);
    DROP TABLE public.course;
       public         heap    postgres    false            �            1259    16930 
   department    TABLE     &  CREATE TABLE public.department (
    dept_code character varying(5) NOT NULL,
    dept_name character varying(100) NOT NULL,
    hod character(4) NOT NULL,
    no_of_staff integer,
    max_staff_strength integer,
    budget numeric(9,2),
    expenditure numeric(9,2),
    hod_appt_date date
);
    DROP TABLE public.department;
       public         heap    postgres    false            �            1259    16933    module    TABLE     �   CREATE TABLE public.module (
    mod_code character varying(10) NOT NULL,
    mod_name character varying(100) NOT NULL,
    credit_unit integer NOT NULL,
    mod_coord character(4)
);
    DROP TABLE public.module;
       public         heap    postgres    false            �            1259    16936    pre_requisite    TABLE     �   CREATE TABLE public.pre_requisite (
    mod_code character varying(10) NOT NULL,
    requisite character varying(10) NOT NULL
);
 !   DROP TABLE public.pre_requisite;
       public         heap    postgres    false            �            1259    16939    staff    TABLE     �  CREATE TABLE public.staff (
    staff_no character(4) NOT NULL,
    staff_name character varying(100) NOT NULL,
    supervisor_staff_no character(4),
    dob date NOT NULL,
    grade character varying(5) NOT NULL,
    marital_status character varying(1) NOT NULL,
    pay numeric(7,2),
    allowance numeric(7,2),
    hourly_rate numeric(7,2),
    gender character(1) NOT NULL,
    citizenship character varying(10) NOT NULL,
    join_yr integer NOT NULL,
    dept_code character varying(5) NOT NULL,
    type_of_employment character varying(2) NOT NULL,
    highest_qln character varying(10) NOT NULL,
    designation character varying(20) NOT NULL
);
    DROP TABLE public.staff;
       public         heap    postgres    false            �            1259    16942    staff_backup    TABLE     �  CREATE TABLE public.staff_backup (
    staff_no character(4) NOT NULL,
    staff_name character varying(100) NOT NULL,
    supervisor character(4),
    dob date NOT NULL,
    grade character varying(5) NOT NULL,
    marital_status character varying(1) NOT NULL,
    pay numeric(7,2),
    allowance numeric(7,2),
    hourly_rate numeric(7,2),
    gender character(1) NOT NULL,
    citizenship character varying(10) NOT NULL,
    join_yr integer NOT NULL,
    dept_code character varying(5) NOT NULL,
    type_of_employment character varying(2) NOT NULL,
    highest_qln character varying(10) NOT NULL,
    designation character varying(20) NOT NULL
);
     DROP TABLE public.staff_backup;
       public         heap    postgres    false            �            1259    16945    staff_dependent    TABLE     �   CREATE TABLE public.staff_dependent (
    staff_no character(4) NOT NULL,
    dependent_name character varying(30) NOT NULL,
    relationship character varying(20) NOT NULL
);
 #   DROP TABLE public.staff_dependent;
       public         heap    postgres    false            �            1259    16948    stud_mod_performance    TABLE     �   CREATE TABLE public.stud_mod_performance (
    adm_no character(4) NOT NULL,
    mod_registered character varying(10) NOT NULL,
    mark integer,
    grade character(2)
);
 (   DROP TABLE public.stud_mod_performance;
       public         heap    postgres    false            �            1259    16951    student    TABLE     �  CREATE TABLE public.student (
    adm_no character(4) NOT NULL,
    stud_name character varying(30) NOT NULL,
    gender character(1) NOT NULL,
    address character varying(100) NOT NULL,
    mobile_phone character(8),
    home_phone character(8),
    dob date NOT NULL,
    nationality character varying(30) NOT NULL,
    crse_code character varying(5) NOT NULL,
    gpa numeric(4,2),
    gpa_last_updated date
);
    DROP TABLE public.student;
       public         heap    postgres    false            �            1259    16954    user_account    TABLE     �   CREATE TABLE public.user_account (
    id integer NOT NULL,
    account_no character varying(6) NOT NULL,
    role integer NOT NULL,
    password character varying(255)
);
     DROP TABLE public.user_account;
       public         heap    postgres    false            �            1259    16957    user_account_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.user_account_id_seq;
       public          postgres    false    225            o           0    0    user_account_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.user_account_id_seq OWNED BY public.user_account.id;
          public          postgres    false    226            �            1259    16958 	   user_role    TABLE     d   CREATE TABLE public.user_role (
    id integer NOT NULL,
    name character varying(25) NOT NULL
);
    DROP TABLE public.user_role;
       public         heap    postgres    false            �            1259    16961    user_role_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.user_role_id_seq;
       public          postgres    false    227            p           0    0    user_role_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.user_role_id_seq OWNED BY public.user_role.id;
          public          postgres    false    228            �           2604    16962    user_account id    DEFAULT     r   ALTER TABLE ONLY public.user_account ALTER COLUMN id SET DEFAULT nextval('public.user_account_id_seq'::regclass);
 >   ALTER TABLE public.user_account ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    226    225            �           2604    16963    user_role id    DEFAULT     l   ALTER TABLE ONLY public.user_role ALTER COLUMN id SET DEFAULT nextval('public.user_role_id_seq'::regclass);
 ;   ALTER TABLE public.user_role ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    228    227            �           2606    16965    country country_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_name);
 >   ALTER TABLE ONLY public.country DROP CONSTRAINT country_pkey;
       public            postgres    false    215            �           2606    16967    course course_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (crse_code);
 <   ALTER TABLE ONLY public.course DROP CONSTRAINT course_pkey;
       public            postgres    false    216            �           2606    16969    department department_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (dept_code);
 D   ALTER TABLE ONLY public.department DROP CONSTRAINT department_pkey;
       public            postgres    false    217            �           2606    16971    module module_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.module
    ADD CONSTRAINT module_pkey PRIMARY KEY (mod_code);
 <   ALTER TABLE ONLY public.module DROP CONSTRAINT module_pkey;
       public            postgres    false    218            �           2606    16973     pre_requisite pre_requisite_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.pre_requisite
    ADD CONSTRAINT pre_requisite_pkey PRIMARY KEY (mod_code, requisite);
 J   ALTER TABLE ONLY public.pre_requisite DROP CONSTRAINT pre_requisite_pkey;
       public            postgres    false    219    219            �           2606    16975    staff_backup staff_backup_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.staff_backup
    ADD CONSTRAINT staff_backup_pkey PRIMARY KEY (staff_no);
 H   ALTER TABLE ONLY public.staff_backup DROP CONSTRAINT staff_backup_pkey;
       public            postgres    false    221            �           2606    16977 $   staff_dependent staff_dependent_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.staff_dependent
    ADD CONSTRAINT staff_dependent_pkey PRIMARY KEY (staff_no, dependent_name);
 N   ALTER TABLE ONLY public.staff_dependent DROP CONSTRAINT staff_dependent_pkey;
       public            postgres    false    222    222            �           2606    16979    staff staff_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (staff_no);
 :   ALTER TABLE ONLY public.staff DROP CONSTRAINT staff_pkey;
       public            postgres    false    220            �           2606    16981 .   stud_mod_performance stud_mod_performance_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.stud_mod_performance
    ADD CONSTRAINT stud_mod_performance_pkey PRIMARY KEY (adm_no, mod_registered);
 X   ALTER TABLE ONLY public.stud_mod_performance DROP CONSTRAINT stud_mod_performance_pkey;
       public            postgres    false    223    223            �           2606    16983    student student_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (adm_no);
 >   ALTER TABLE ONLY public.student DROP CONSTRAINT student_pkey;
       public            postgres    false    224            �           2606    16985    user_account user_account_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT user_account_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.user_account DROP CONSTRAINT user_account_pkey;
       public            postgres    false    225            �           2606    16987    user_role user_role_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT user_role_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.user_role DROP CONSTRAINT user_role_pkey;
       public            postgres    false    227            �           2606    16988    course course_offered_by_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_offered_by_fk FOREIGN KEY (offered_by) REFERENCES public.department(dept_code);
 E   ALTER TABLE ONLY public.course DROP CONSTRAINT course_offered_by_fk;
       public          postgres    false    216    217    4794            �           2606    16993    department dept_hod_fk    FK CONSTRAINT     w   ALTER TABLE ONLY public.department
    ADD CONSTRAINT dept_hod_fk FOREIGN KEY (hod) REFERENCES public.staff(staff_no);
 @   ALTER TABLE ONLY public.department DROP CONSTRAINT dept_hod_fk;
       public          postgres    false    220    4800    217            �           2606    16998    user_account fk_account_no    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT fk_account_no FOREIGN KEY (account_no) REFERENCES public.staff(staff_no);
 D   ALTER TABLE ONLY public.user_account DROP CONSTRAINT fk_account_no;
       public          postgres    false    220    4800    225            �           2606    17003    user_account fk_role    FK CONSTRAINT     t   ALTER TABLE ONLY public.user_account
    ADD CONSTRAINT fk_role FOREIGN KEY (role) REFERENCES public.user_role(id);
 >   ALTER TABLE ONLY public.user_account DROP CONSTRAINT fk_role;
       public          postgres    false    4812    225    227            �           2606    17008    module mod_mod_coord_fk    FK CONSTRAINT     ~   ALTER TABLE ONLY public.module
    ADD CONSTRAINT mod_mod_coord_fk FOREIGN KEY (mod_coord) REFERENCES public.staff(staff_no);
 A   ALTER TABLE ONLY public.module DROP CONSTRAINT mod_mod_coord_fk;
       public          postgres    false    218    220    4800            �           2606    17013 '   pre_requisite pre_requisite_mod_code_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.pre_requisite
    ADD CONSTRAINT pre_requisite_mod_code_fk FOREIGN KEY (mod_code) REFERENCES public.module(mod_code);
 Q   ALTER TABLE ONLY public.pre_requisite DROP CONSTRAINT pre_requisite_mod_code_fk;
       public          postgres    false    219    218    4796            �           2606    17018 (   pre_requisite pre_requisite_requisite_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.pre_requisite
    ADD CONSTRAINT pre_requisite_requisite_fk FOREIGN KEY (requisite) REFERENCES public.module(mod_code);
 R   ALTER TABLE ONLY public.pre_requisite DROP CONSTRAINT pre_requisite_requisite_fk;
       public          postgres    false    219    4796    218            �           2606    17023 +   staff_dependent staff_dependent_staff_no_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.staff_dependent
    ADD CONSTRAINT staff_dependent_staff_no_fk FOREIGN KEY (staff_no) REFERENCES public.staff(staff_no);
 U   ALTER TABLE ONLY public.staff_dependent DROP CONSTRAINT staff_dependent_staff_no_fk;
       public          postgres    false    222    220    4800            �           2606    17028    staff staff_dept_code_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_dept_code_fk FOREIGN KEY (dept_code) REFERENCES public.department(dept_code);
 B   ALTER TABLE ONLY public.staff DROP CONSTRAINT staff_dept_code_fk;
       public          postgres    false    220    4794    217            �           2606    17033 5   stud_mod_performance stud_mod_performance_adm_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stud_mod_performance
    ADD CONSTRAINT stud_mod_performance_adm_no_fkey FOREIGN KEY (adm_no) REFERENCES public.student(adm_no);
 _   ALTER TABLE ONLY public.stud_mod_performance DROP CONSTRAINT stud_mod_performance_adm_no_fkey;
       public          postgres    false    224    4808    223            �           2606    17038 =   stud_mod_performance stud_mod_performance_mod_registered_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.stud_mod_performance
    ADD CONSTRAINT stud_mod_performance_mod_registered_fkey FOREIGN KEY (mod_registered) REFERENCES public.module(mod_code);
 g   ALTER TABLE ONLY public.stud_mod_performance DROP CONSTRAINT stud_mod_performance_mod_registered_fkey;
       public          postgres    false    218    223    4796            �           2606    17043    student student_crse_code_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_crse_code_fk FOREIGN KEY (crse_code) REFERENCES public.course(crse_code);
 F   ALTER TABLE ONLY public.student DROP CONSTRAINT student_crse_code_fk;
       public          postgres    false    4792    224    216            �           2606    17048    student student_nationality_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_nationality_fk FOREIGN KEY (nationality) REFERENCES public.country(country_name);
 H   ALTER TABLE ONLY public.student DROP CONSTRAINT student_nationality_fk;
       public          postgres    false    4790    215    224           