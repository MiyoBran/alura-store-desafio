# 📘 Manual de Arquitectura y Modelado de Bases de Datos

**Perfil:** Software Architect & Data Engineer  
**Enfoque:** Diseño conceptual, lógica de negocio y normalización

## 1. Fundamentos de Arquitectura (La Vision Macro)

Antes de escribir una sola linea de SQL, debemos entender la separacion de responsabilidades en la gestion de datos.

### 1.1 Base de Datos vs. SGBD

- **Base de Datos (DB):** conjunto estructurado de datos almacenados (el archivo en disco, los "libros").
- **SGBD (Sistema de Gestion de Bases de Datos):** software intermedio (middleware) que administra el acceso, la concurrencia y la integridad (el "bibliotecario").
- **Ejemplos:** Oracle, MySQL, PostgreSQL, SQL Server.

### 1.2 La Jerarquia de Abstraccion (ANSI/SPARC)

El diseno no es un paso unico, es un proceso de refinamiento progresivo:

- **Nivel conceptual (MER):** enfocado en el negocio. ¿Que es un Cliente? ¿Que es una Venta? Independiente de la tecnologia.
- **Nivel logico:** enfocado en la estructura. Definicion de tablas, claves primarias (PK) y foraneas (FK).
- **Nivel fisico:** enfocado en el rendimiento. Definicion de tipos de datos (VARCHAR, INT), indices y almacenamiento en disco.

## 2. El Modelo Entidad-Relacion (MER)

El MER es la herramienta intelectual para traducir requisitos de negocio en estructuras de datos.

### 2.1 El "Mini-Mundo" (Scope)

Es el recorte de la realidad que nos interesa modelar.

- **Abstraccion:** capacidad de ignorar detalles irrelevantes (ej. el color de ojos del cliente) para enfocarse en los datos transaccionales (ej. su CUIT/DNI).

### 2.2 Elementos del MER

| Elemento | Simbolo (DER) | Descripcion tecnica | Ejemplo PyME |
| --- | --- | --- | --- |
| Entidad | Rectangulo | Objeto del mundo real (tangible o abstracto) con existencia propia. | Cliente, Producto, Factura. |
| Relacion | Rombo | Accion o vinculo semantico entre entidades (verbos). | Solicita, Contiene, Provee. |
| Atributo | Ovalo | Caracteristica o propiedad de una entidad. | Nombre, Precio, Fecha. |

## 3. Tipologia de Entidades

La distincion entre entidades fuertes y debiles es critica para mantener la integridad referencial.

### 3.1 Entidad Fuerte (Independent)

- Tiene existencia propia.
- Posee una clave primaria (PK) unica que la identifica sin ayuda externa.
- **Simbolo:** rectangulo simple.
- **Ejemplo:** Cliente (existe aunque no compre nada), Producto.

### 3.2 Entidad Debil (Dependent)

- Su existencia depende de una "Entidad Padre". Si borras al Padre, la Debil desaparece (cascading delete).
- No tiene una PK completa propia; usa una clave parcial + la PK del Padre.
- **Simbolo:** rectangulo doble.
- **Ejemplo:** Detalle_Factura (no existe sin Factura), Telefonos_Cliente.

## 4. Reglas de Negocio: Cardinalidad

Define la "cantidad" de relaciones permitidas entre dos entidades. Es la traduccion tecnica de las politicas de la empresa.

### 4.1 Tipos de Cardinalidad

- **Uno a uno (1:1):** una entidad A se relaciona exclusivamente con una entidad B.  
	**Ejemplo:** Gerente gestiona Departamento.
- **Uno a muchos (1:N):** la relacion jerarquica mas comun (Padre-Hijo).  
	**Ejemplo:** un Cliente (1) tiene muchas Facturas (N). Una Factura pertenece a un solo Cliente.
- **Muchos a muchos (N:M):** relacion compleja ("Todos contra todos").  
	**Ejemplo:** Factura y Producto. Una factura tiene muchos productos; un producto esta en muchas facturas.

⚠️ **Alerta de Arquitecto:** las bases de datos fisicas NO soportan relaciones N:M directas. Requieren una solucion arquitectonica (ver punto 6).

## 5. Refinamiento de Atributos (Columnas)

No todos los datos son iguales. Debemos clasificarlos para disenar la tabla correcta.

### 5.1 Clasificacion de Atributos

- **Atomicos:** indivisibles (ej. DNI).
- **Compuestos:** se dividen en sub-partes para mejor analisis.  
	**Ejemplo:** Direccion $\to$ Calle, Numero, Localidad, CP.
- **Multivaluados:** pueden tener multiples valores para una misma entidad.  
	**Ejemplo:** Telefono (Tel1, Tel2).  
	**Solucion:** en SQL, esto se extrae a una tabla hija (Telefonos).
- **Derivados:** calculados a partir de otros datos (ej. Edad, Subtotal). Generalmente no se almacenan, se calculan al vuelo (linea punteada).

### 5.2 Identificadores (Claves / Keys)

- **Clave primaria (PK):** identificador unico e irrepetible.
- **Natural Key:** dato real (DNI, CUIT, ISBN). Util pero riesgoso si cambia.
- **Surrogate Key:** ID artificial (autoincremental). Recomendado para sistemas robustos (ID_Cliente).
- **Clave foranea (FK):** copia de la PK del Padre guardada en la tabla Hija para establecer la relacion.

## 6. Patrones Avanzados de Diseno

### 6.1 Resolucion de Relaciones N:M (Entidad Asociativa)

Cuando tenemos una relacion muchos a muchos (ej. Pedidos y Libros), creamos una entidad intermedia.

- **Nombre:** suele llamarse Detalle_X, Items_X, o Rel_A_B.
- **Estructura:** contiene las FK de ambas entidades fuertes (ID_Pedido, ID_Libro).
- **Valor historico:** lugar ideal para guardar datos transaccionales como Precio_Unitario_Historico y Cantidad.

### 6.2 Herencia (Generalizacion/Especializacion)

Cuando entidades comparten atributos pero tienen diferencias clave.

- **Ejemplo:** Cliente (Padre) se divide en Persona_Fisica (Hijo - DNI) y Persona_Juridica (Hijo - CUIT).

## 7. Caso de Estudio: Gestion PyME (Argentina)

Aplicacion del modelo al sistema de facturacion local.

| Entidad | Tipo | Atributos clave (PK/FK) | Notas de arquitectura |
| --- | --- | --- | --- |
| Cliente | Fuerte | ID_Cliente (PK), CUIT_DNI (Unique) | Entidad padre. Maneja condicion IVA. |
| Producto | Fuerte | ID_Producto (PK), SKU | Maneja stock actual y precios de lista. |
| Factura | Debil* | ID_Factura (PK), ID_Cliente (FK) | Cabecera. Debil existencialmente respecto al Cliente, aunque fuerte legalmente (AFIP). |
| Detalle_Factura | Asociativa | ID_Factura (FK), ID_Producto (FK) | Detalle transaccional con cantidad y precio historico. |