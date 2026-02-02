# 📊 Análisis Estratégico: Alura Store Latam

## 📝 Descripción del Proyecto
Este proyecto consiste en un Análisis Exploratorio de Datos (EDA) para la cadena de retail **Alura Store**.
El objetivo principal fue asistir a la gerencia en la toma de decisiones basada en datos para determinar **qué sucursal vender** debido a la necesidad de reestructuración del negocio.

## 🎯 Objetivo de Negocio
Identificar la tienda con el desempeño más bajo ("La menos eficiente") evaluando cuatro pilares clave:
1.  **Facturación:** Ingresos totales.
2.  **Rentabilidad:** Ticket promedio y valor por cliente.
3.  **Operaciones:** Costos logísticos y alcance geográfico.
4.  **Satisfacción:** Calidad del servicio (Rating/NPS).

## 🛠 Tecnologías Utilizadas
* **Python:** Lenguaje principal.
* **Pandas:** Manipulación, limpieza y agregación de datos (ETL).
* **Matplotlib & Seaborn:** Visualización de datos estática (Boxplots, Barplots).
* **Folium:** Visualización geoespacial interactiva (Mapas de calor).
* **Jupyter Notebook / Google Colab:** Entorno de desarrollo.

## 🔍 Principales Hallazgos (Insights)

Tras procesar los datasets de las 4 sucursales y cruzar variables financieras con geográficas, descubrimos los siguientes patrones:

### 1. Jerarquía de Ingresos 💰
Existe una brecha financiera clara. La **Tienda 1** lidera el mercado, mientras que la **Tienda 4** se encuentra rezagada.
* **Líder (Tienda 1):** ~$1,150 Millones
* **Último lugar (Tienda 4):** ~$1,038 Millones (~10% menos que el líder).

### 2. El Problema Oculto: Ticket Promedio 📉
Aunque todas las tiendas comparten inventario, la **Tienda 4** tiene el **Ticket Promedio más bajo ($440k)**.
Esto indica una dificultad estructural para concretar ventas de productos "Premium" o realizar *cross-selling* efectivo en comparación con la Tienda 1 ($487k).

### 3. Mito Logístico y Calidad 🚚⭐
* **Logística:** El costo de envío representa el ~5.3% de las ventas en *todas* las tiendas. La tienda con menos ingresos no tiene una ventaja operativa que la "salve".
* **Satisfacción:** Todas las tiendas tienen un rating promedio de ~4.0. El problema es transaccional, no de atención al cliente.

### 4. Paradoja Geo-Estratégica (Dispersión vs. Eficiencia) 🌍
El análisis de geolocalización reveló que la **Tienda 4** sufre de "sobre-expansión improductiva".
* **Modelo Ganador (Tienda 1):** Opera con **baja dispersión geográfica** (clientes concentrados) pero logra el máximo ticket promedio. "Domina su zona" eficientemente.
* **Modelo Ineficiente (Tienda 4):** Opera con **alta dispersión** (territorio muy amplio, casi nacional) pero captura el menor valor por cliente.
* **Conclusión:** La Tienda 4 gasta recursos cubriendo un área vasta sin lograr la rentabilidad que justifique esa expansión logística.

---

## 🚀 Conclusión y Recomendación

**Recomendación Definitiva: Venta de la Sucursal 4.**

Basado en la evidencia multifactorial, la Tienda 4 es el activo menos eficiente del portafolio:
* Genera el **menor flujo de caja** del grupo.
* Tiene la **menor capacidad de generar valor** por cliente (Ticket bajo).
* Sufre de **ineficiencia geográfica**: abarca mucho territorio para vender productos baratos.

La desinversión en esta unidad permitirá reasignar capital a las Tiendas 1 y 2, que han demostrado un modelo de "Dominio de Zona" mucho más rentable.

---
*Proyecto realizado como parte del Challenge Data Science de Alura Latam.*
*Desarrollado por: [Brandolino Carlos / MiyoBran]*