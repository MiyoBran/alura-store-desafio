# 📊 Análisis Estratégico: Alura Store Latam

## 📝 Descripción del Proyecto
Este proyecto consiste en un Análisis Exploratorio de Datos (EDA) para la cadena de retail **Alura Store**.
El objetivo principal fue asistir a la gerencia en la toma de decisiones basada en datos para determinar **qué sucursal vender** debido a la necesidad de reestructuración del negocio.

## 🎯 Objetivo de Negocio
Identificar la tienda con el desempeño más bajo ("La menos eficiente") evaluando tres pilares:
1.  **Facturación:** Ingresos totales.
2.  **Operaciones:** Costos logísticos y eficiencia de envío.
3.  **Satisfacción:** Calidad del servicio (Rating/NPS).

## 🛠 Tecnologías Utilizadas
* **Python:** Lenguaje principal.
* **Pandas:** Manipulación y limpieza de datos (ETL).
* **Matplotlib & Seaborn:** Visualización de datos y storytelling.
* **Jupyter Notebook / Google Colab:** Entorno de desarrollo.

## 🔍 Principales Hallazgos (Insights)

Tras procesar los datasets de las 4 sucursales, descubrimos los siguientes patrones clave:

### 1. Jerarquía de Ingresos 💰
Existe una diferencia clara en la facturación. La **Tienda 1** lidera el mercado, mientras que la **Tienda 4** se encuentra rezagada.
* **Líder (Tienda 1):** ~$1,150 Millones
* **Último lugar (Tienda 4):** ~$1,038 Millones (~10% menos que el líder).

### 2. El Problema Oculto: Ticket Promedio 📉
Aunque todas las tiendas tienen acceso a inventario similar (productos de alto valor), la **Tienda 4** tiene el **Ticket Promedio más bajo ($440k)**.
Esto indica una dificultad para concretar ventas de productos "Premium" o realizar ventas cruzadas (cross-selling) efectivas en comparación con la Tienda 1 ($487k).

### 3. Mito Logístico y Calidad 🚚⭐
* **Logística:** El costo de envío representa el ~5.3% de las ventas en *todas* las tiendas. La tienda con menos ingresos no tiene una ventaja operativa que la salve.
* **Satisfacción:** Todas las tiendas tienen un rating promedio de ~4.0. El problema no es la atención al cliente.

## 🚀 Conclusión y Recomendación

**Recomendación: Venta de la Sucursal 4.**

Basado en los datos, la Tienda 4 es el activo menos eficiente del portafolio.
* Genera el menor flujo de caja.
* No posee ventajas competitivas en costos.
* Tiene la menor capacidad de generar valor por cliente (Bajo Ticket Promedio).

La desinversión en esta unidad permitirá reasignar capital a las Tiendas 1 y 2, que demuestran mayor solidez financiera y comercial.

---
*Proyecto realizado como parte del Challenge Data Science de Alura Latam.*
*Desarrollado por: [Brandolino Carlos / MiyoBran]*