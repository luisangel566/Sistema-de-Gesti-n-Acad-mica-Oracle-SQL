-- ============================================================
-- PROYECTO 3: SISTEMA ESCOLAR
-- Nivel: INTERMEDIO
-- Motor: Oracle Database 19c+
-- Conceptos: Vistas, subconsultas, funciones de fecha,
--            CASE WHEN, funciones analíticas básicas
-- Autor: Luis Angel Tapias Madronero
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE notas CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE matriculas CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE cursos CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE estudiantes CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE docentes CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE periodos CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP VIEW v_rendimiento_estudiantes';
    EXECUTE IMMEDIATE 'DROP VIEW v_cursos_docente';
    EXECUTE IMMEDIATE 'DROP VIEW v_boletin_notas';
    FOR s IN (SELECT sequence_name FROM user_sequences WHERE sequence_name LIKE 'SEQ_ESC%') LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    END LOOP;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE SEQUENCE seq_esc_periodo    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_esc_docente    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_esc_estudiante START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_esc_curso      START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_esc_matricula  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_esc_nota       START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- ============================================================
-- TABLAS
-- ============================================================
CREATE TABLE periodos (
    id_periodo  NUMBER        DEFAULT seq_esc_periodo.NEXTVAL PRIMARY KEY,
    nombre      VARCHAR2(50)  NOT NULL, -- Ej: "2025-1"
    fecha_ini   DATE          NOT NULL,
    fecha_fin   DATE          NOT NULL,
    activo      NUMBER(1)     DEFAULT 0,
    CONSTRAINT chk_periodo_fechas CHECK (fecha_fin > fecha_ini),
    CONSTRAINT chk_periodo_activo CHECK (activo IN (0,1))
);

CREATE TABLE docentes (
    id_docente  NUMBER        DEFAULT seq_esc_docente.NEXTVAL PRIMARY KEY,
    cedula      VARCHAR2(20)  NOT NULL UNIQUE,
    nombre      VARCHAR2(100) NOT NULL,
    apellido    VARCHAR2(100) NOT NULL,
    email       VARCHAR2(100) NOT NULL UNIQUE,
    titulo      VARCHAR2(100),
    especialidad VARCHAR2(150)
);

CREATE TABLE estudiantes (
    id_estudiante NUMBER        DEFAULT seq_esc_estudiante.NEXTVAL PRIMARY KEY,
    codigo        VARCHAR2(15)  NOT NULL UNIQUE,
    cedula        VARCHAR2(20)  NOT NULL UNIQUE,
    nombre        VARCHAR2(100) NOT NULL,
    apellido      VARCHAR2(100) NOT NULL,
    email         VARCHAR2(100),
    fecha_nac     DATE,
    semestre      NUMBER(2)     NOT NULL,
    activo        NUMBER(1)     DEFAULT 1,
    CONSTRAINT chk_semestre CHECK (semestre BETWEEN 1 AND 10)
);

CREATE TABLE cursos (
    id_curso    NUMBER        DEFAULT seq_esc_curso.NEXTVAL PRIMARY KEY,
    codigo      VARCHAR2(10)  NOT NULL UNIQUE,
    nombre      VARCHAR2(150) NOT NULL,
    creditos    NUMBER(2)     NOT NULL,
    id_docente  NUMBER        NOT NULL,
    id_periodo  NUMBER        NOT NULL,
    cupo_max    NUMBER(3)     DEFAULT 30 NOT NULL,
    CONSTRAINT fk_curso_docente FOREIGN KEY (id_docente) REFERENCES docentes(id_docente),
    CONSTRAINT fk_curso_periodo FOREIGN KEY (id_periodo) REFERENCES periodos(id_periodo),
    CONSTRAINT chk_creditos     CHECK (creditos BETWEEN 1 AND 6)
);

CREATE TABLE matriculas (
    id_matricula  NUMBER   DEFAULT seq_esc_matricula.NEXTVAL PRIMARY KEY,
    id_estudiante NUMBER   NOT NULL,
    id_curso      NUMBER   NOT NULL,
    fecha_mat     DATE     DEFAULT SYSDATE NOT NULL,
    estado        VARCHAR2(15) DEFAULT 'ACTIVA',
    CONSTRAINT fk_mat_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante),
    CONSTRAINT fk_mat_curso      FOREIGN KEY (id_curso)      REFERENCES cursos(id_curso),
    CONSTRAINT uq_mat            UNIQUE (id_estudiante, id_curso),
    CONSTRAINT chk_mat_estado    CHECK (estado IN ('ACTIVA','CANCELADA','RETIRADA'))
);

CREATE TABLE notas (
    id_nota       NUMBER        DEFAULT seq_esc_nota.NEXTVAL PRIMARY KEY,
    id_matricula  NUMBER        NOT NULL UNIQUE,
    nota_1        NUMBER(4,2),  -- Primer corte 30%
    nota_2        NUMBER(4,2),  -- Segundo corte 30%
    nota_3        NUMBER(4,2),  -- Tercer corte 40%
    nota_final    NUMBER(4,2),  -- Calculada
    habilitacion  NUMBER(4,2),
    CONSTRAINT fk_nota_matricula FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula),
    CONSTRAINT chk_notas         CHECK (
        (nota_1 IS NULL OR nota_1 BETWEEN 0 AND 5) AND
        (nota_2 IS NULL OR nota_2 BETWEEN 0 AND 5) AND
        (nota_3 IS NULL OR nota_3 BETWEEN 0 AND 5)
    )
);

-- ============================================================
-- DATOS DE PRUEBA
-- ============================================================
INSERT INTO periodos VALUES (seq_esc_periodo.NEXTVAL, '2025-1', DATE '2025-01-20', DATE '2025-06-15', 0);
INSERT INTO periodos VALUES (seq_esc_periodo.NEXTVAL, '2025-2', DATE '2025-07-14', DATE '2025-11-28', 1);

INSERT INTO docentes (cedula, nombre, apellido, email, titulo, especialidad) VALUES
('10111222', 'Marco',    'Palacios',  'marco.p@colegio.edu.co',   'Magíster',    'Bases de Datos');
INSERT INTO docentes (cedula, nombre, apellido, email, titulo, especialidad) VALUES
('10222333', 'Patricia', 'Salamanca', 'patricia.s@colegio.edu.co','Especialista', 'Programación');
INSERT INTO docentes (cedula, nombre, apellido, email, titulo, especialidad) VALUES
('10333444', 'Ricardo',  'Ospina',    'ricardo.o@colegio.edu.co', 'PhD',          'Redes');

INSERT INTO estudiantes (codigo, cedula, nombre, apellido, email, semestre) VALUES
('EST-001','1011223344','Laura',   'Gómez',    'laura.g@uni.edu.co',   3);
INSERT INTO estudiantes (codigo, cedula, nombre, apellido, email, semestre) VALUES
('EST-002','1022334455','Sebastián','Vargas',  'sebastian.v@uni.edu.co',5);
INSERT INTO estudiantes (codigo, cedula, nombre, apellido, email, semestre) VALUES
('EST-003','1033445566','Valentina','Ríos',    'valentina.r@uni.edu.co',3);
INSERT INTO estudiantes (codigo, cedula, nombre, apellido, email, semestre) VALUES
('EST-004','1044556677','Nicolás',  'Castro',  'nicolas.c@uni.edu.co',  7);
INSERT INTO estudiantes (codigo, cedula, nombre, apellido, email, semestre) VALUES
('EST-005','1055667788','Camila',   'Herrera', 'camila.h@uni.edu.co',   5);

INSERT INTO cursos (codigo, nombre, creditos, id_docente, id_periodo, cupo_max) VALUES
('BD-201',  'Bases de Datos I',      4, 1, 2, 30);
INSERT INTO cursos (codigo, nombre, creditos, id_docente, id_periodo, cupo_max) VALUES
('PRG-301', 'Programación Avanzada', 3, 2, 2, 25);
INSERT INTO cursos (codigo, nombre, creditos, id_docente, id_periodo, cupo_max) VALUES
('RD-401',  'Redes y Comunicaciones',4, 3, 2, 20);

-- Matrículas
INSERT INTO matriculas (id_estudiante, id_curso) VALUES (1,1);
INSERT INTO matriculas (id_estudiante, id_curso) VALUES (1,2);
INSERT INTO matriculas (id_estudiante, id_curso) VALUES (2,1);
INSERT INTO matriculas (id_estudiante, id_curso) VALUES (3,1);
INSERT INTO matriculas (id_estudiante, id_curso) VALUES (3,3);
INSERT INTO matriculas (id_estudiante, id_curso) VALUES (4,2);
INSERT INTO matriculas (id_estudiante, id_curso) VALUES (4,3);
INSERT INTO matriculas (id_estudiante, id_curso) VALUES (5,1);

-- Notas (cortes 30%, 30%, 40%)
INSERT INTO notas (id_matricula, nota_1, nota_2, nota_3, nota_final) VALUES (1, 3.8, 4.2, 4.0, 3.8*0.3 + 4.2*0.3 + 4.0*0.4);
INSERT INTO notas (id_matricula, nota_1, nota_2, nota_3, nota_final) VALUES (2, 2.5, 3.0, 2.8, 2.5*0.3 + 3.0*0.3 + 2.8*0.4);
INSERT INTO notas (id_matricula, nota_1, nota_2, nota_3, nota_final) VALUES (3, 4.5, 4.8, 5.0, 4.5*0.3 + 4.8*0.3 + 5.0*0.4);
INSERT INTO notas (id_matricula, nota_1, nota_2, nota_3, nota_final) VALUES (4, 3.0, 2.8, 3.5, 3.0*0.3 + 2.8*0.3 + 3.5*0.4);
INSERT INTO notas (id_matricula, nota_1, nota_2, nota_3, nota_final) VALUES (5, 4.0, 4.2, 4.5, 4.0*0.3 + 4.2*0.3 + 4.5*0.4);
INSERT INTO notas (id_matricula, nota_1, nota_2, nota_3, nota_final) VALUES (6, 3.5, 3.8, 4.0, 3.5*0.3 + 3.8*0.3 + 4.0*0.4);
INSERT INTO notas (id_matricula, nota_1, nota_2, nota_3, nota_final) VALUES (7, 4.8, 4.5, 4.9, 4.8*0.3 + 4.5*0.3 + 4.9*0.4);
INSERT INTO notas (id_matricula, nota_1, nota_2, nota_3, nota_final) VALUES (8, 1.5, 2.0, 1.8, 1.5*0.3 + 2.0*0.3 + 1.8*0.4);

COMMIT;

-- ============================================================
-- VISTAS
-- ============================================================

-- Vista 1: Boletín de notas completo
CREATE OR REPLACE VIEW v_boletin_notas AS
SELECT
    e.codigo                            AS cod_estudiante,
    e.nombre || ' ' || e.apellido       AS estudiante,
    c.nombre                            AS curso,
    c.creditos,
    n.nota_1, n.nota_2, n.nota_3,
    ROUND(n.nota_final, 2)              AS nota_final,
    CASE
        WHEN n.nota_final >= 3.0 THEN 'APROBADO'
        WHEN n.nota_final >= 2.5 THEN 'HABILITACIÓN'
        ELSE 'REPROBADO'
    END                                 AS estado_academico
FROM notas n
INNER JOIN matriculas  m ON n.id_matricula  = m.id_matricula
INNER JOIN estudiantes e ON m.id_estudiante = e.id_estudiante
INNER JOIN cursos      c ON m.id_curso      = c.id_curso;

-- Vista 2: Rendimiento general por estudiante
CREATE OR REPLACE VIEW v_rendimiento_estudiantes AS
SELECT
    e.codigo,
    e.nombre || ' ' || e.apellido   AS estudiante,
    e.semestre,
    COUNT(n.id_nota)                AS cursos_cursados,
    ROUND(AVG(n.nota_final), 2)     AS promedio_general,
    SUM(CASE WHEN n.nota_final >= 3.0 THEN 1 ELSE 0 END) AS cursos_aprobados,
    SUM(CASE WHEN n.nota_final < 3.0  THEN 1 ELSE 0 END) AS cursos_reprobados
FROM estudiantes e
LEFT JOIN matriculas m ON e.id_estudiante = m.id_estudiante
LEFT JOIN notas     n ON m.id_matricula  = n.id_matricula
GROUP BY e.codigo, e.nombre, e.apellido, e.semestre;

-- Vista 3: Estadísticas por docente
CREATE OR REPLACE VIEW v_cursos_docente AS
SELECT
    d.nombre || ' ' || d.apellido   AS docente,
    d.especialidad,
    c.nombre                         AS curso,
    c.creditos,
    COUNT(m.id_matricula)            AS estudiantes_matriculados,
    c.cupo_max,
    ROUND(AVG(n.nota_final), 2)      AS promedio_curso
FROM docentes d
INNER JOIN cursos      c ON d.id_docente    = c.id_docente
LEFT  JOIN matriculas  m ON c.id_curso      = m.id_curso
LEFT  JOIN notas       n ON m.id_matricula  = n.id_matricula
GROUP BY d.nombre, d.apellido, d.especialidad, c.nombre, c.creditos, c.cupo_max;

-- ============================================================
-- CONSULTAS CON SUBCONSULTAS Y CASE WHEN
-- ============================================================

-- 1. Estudiantes con promedio mayor al promedio general
SELECT codigo, estudiante, promedio_general
FROM v_rendimiento_estudiantes
WHERE promedio_general > (SELECT AVG(nota_final) FROM notas)
ORDER BY promedio_general DESC;

-- 2. Mejor estudiante por curso
SELECT curso, estudiante, nota_final
FROM v_boletin_notas b1
WHERE nota_final = (
    SELECT MAX(nota_final)
    FROM v_boletin_notas b2
    WHERE b2.curso = b1.curso
)
ORDER BY curso;

-- 3. Distribución de calificaciones con CASE
SELECT
    CASE
        WHEN nota_final >= 4.5 THEN 'Excelente (4.5-5.0)'
        WHEN nota_final >= 4.0 THEN 'Muy Bueno (4.0-4.4)'
        WHEN nota_final >= 3.5 THEN 'Bueno (3.5-3.9)'
        WHEN nota_final >= 3.0 THEN 'Aprobado (3.0-3.4)'
        WHEN nota_final >= 2.5 THEN 'Habilitación (2.5-2.9)'
        ELSE 'Reprobado (< 2.5)'
    END AS rango,
    COUNT(*) AS cantidad
FROM notas
GROUP BY
    CASE
        WHEN nota_final >= 4.5 THEN 'Excelente (4.5-5.0)'
        WHEN nota_final >= 4.0 THEN 'Muy Bueno (4.0-4.4)'
        WHEN nota_final >= 3.5 THEN 'Bueno (3.5-3.9)'
        WHEN nota_final >= 3.0 THEN 'Aprobado (3.0-3.4)'
        WHEN nota_final >= 2.5 THEN 'Habilitación (2.5-2.9)'
        ELSE 'Reprobado (< 2.5)'
    END
ORDER BY MIN(nota_final) DESC;
