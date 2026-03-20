# 🎓 Sistema Escolar — Oracle SQL (Intermedio)

Base de datos relacional desarrollada en Oracle para la gestión académica de estudiantes, cursos, docentes y notas, incluyendo análisis de rendimiento mediante vistas y consultas avanzadas.

---

## 🎯 Objetivo del Proyecto

Simular un sistema académico institucional que permita gestionar matrículas, calificaciones y generar reportes de rendimiento estudiantil y docente.

---

## 🧠 Conceptos Aplicados

* Modelado relacional (1:N)
* Constraints:

  * PRIMARY KEY
  * FOREIGN KEY
  * UNIQUE
  * CHECK
* Secuencias (`SEQUENCE`)
* Vistas (`VIEW`)
* Subconsultas
* Funciones de fecha:

  * `SYSDATE`
  * `ADD_MONTHS`
* Funciones de agregación:

  * `AVG`
  * `COUNT`
  * `SUM`
* `CASE WHEN` para lógica de negocio
* Funciones analíticas básicas
* JOINs (INNER JOIN, LEFT JOIN)

---

## 🧱 Modelo de Datos

### Tablas principales:

* **periodos** → Control de periodos académicos
* **docentes** → Información de profesores
* **estudiantes** → Datos de estudiantes
* **cursos** → Materias dictadas por docentes
* **matriculas** → Relación estudiantes–cursos
* **notas** → Calificaciones por estudiante

---

## ⚙️ Funcionalidades Implementadas

* Gestión de estudiantes, docentes y cursos
* Registro de matrículas por periodo
* Cálculo de nota final ponderada (30% - 30% - 40%)
* Clasificación del estado académico (Aprobado, Reprobado, Habilitación)
* Generación de reportes académicos

---

## 📊 Vistas Implementadas

### 🔹 v_boletin_notas

Boletín académico completo por estudiante:

* Notas por corte
* Nota final
* Estado académico

---

### 🔹 v_rendimiento_estudiantes

Análisis de rendimiento:

* Promedio general
* Cursos aprobados y reprobados
* Total de cursos

---

### 🔹 v_cursos_docente

Estadísticas por docente:

* Número de estudiantes por curso
* Promedio de notas del curso

---

## 🔍 Consultas Destacadas

### 🔹 Estudiantes con alto rendimiento

* Comparación contra promedio general
* Uso de subconsultas

---

### 🔹 Mejor estudiante por curso

* Subconsulta correlacionada
* Uso de `MAX()`

---

### 🔹 Distribución de calificaciones

* Clasificación por rangos con `CASE WHEN`
* Análisis estadístico de notas

---

## 🚀 Ejecución

Ejecutar el script completo en Oracle:

```sql id="k8n1pq"
@03_sistema_escolar.sql
```

---

## 🧪 Datos de Prueba

Incluye:

* Estudiantes de diferentes semestres
* Docentes con especialidades
* Cursos con créditos y cupos
* Notas con cálculo automático

---

## 🏗️ Estructura del Proyecto

```id="l3x9fw"
03-sistema-escolar/
├── sql/
│   └── 03_sistema_escolar.sql
└── README.md
```

---

## 💡 Lo que demuestra este proyecto

* Diseño de bases de datos académicas reales
* Uso de vistas para análisis de información
* Aplicación de lógica de negocio en SQL (`CASE WHEN`)
* Capacidad de generar reportes complejos
* Manejo de relaciones y cálculos agregados

---

## 👨‍💻 Autor

Luis Ángel Tapias Madroñero
Ingeniero de Sistemas — Bogotá, Colombia

🔗 https://github.com/luisangel566
