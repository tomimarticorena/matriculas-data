# Dashboard de Matrículas: Enseñanza Básica y Media (Chile, 2018-2025)

[![Shiny](https://img.shields.io/badge/Shiny-App-blue?style=flat-square&logo=r)](https://shiny.rstudio.com/)
[![R](https://img.shields.io/badge/R-4.4.0-276DC3?style=flat-square&logo=r&logoColor=white)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Live Demo](https://img.shields.io/badge/🚀-Live_Demo-brightgreen?style=flat-square)](https://tomas-marticorena.shinyapps.io/data-matriculas/)

> Visualización interactiva de matrículas de enseñanza básica y media del sistema chileno, basada en datos abiertos del MINEDUC.

🔗 **[Probar la app en vivo](https://tomas-marticorena.shinyapps.io/data-matriculas/)**
---
## Objetivo del Proyecto

Este dashboard permite explorar de manera interactiva la evolución de las matrículas en enseñanza básica y media en Chile entre 2018 y 2025, facilitando:
- 🔍 Análisis por **región**, **comuna** y **tipo de establecimiento** (Municipal, Particular Subvencionado, Particular Pagado, etc.)
- 📈 Visualización de tendencias anuales con gráficos interactivos
- 📥 Descarga de los datos filtrados en formato CSV para análisis posterior

**Fuente de datos**: [Datos Abiertos MINEDUC - SIGE](https://datosabiertos.mineduc.cl/)
- Se descargan para cada año
- Las bases de datos originales contienen más variables. En este caso, solo se centra en región, comuna y tipo de establecimiento.
---
## ✨ Características Principales

| Funcionalidad | Descripción |
|--------------|-------------|
| 🌐 **Filtros en cascada** | Selecciona Región → Comuna → Tipo de Establecimiento con actualización reactiva |
| 📊 **Gráfico interactivo** | Barras anuales con etiquetas de valores y paleta cromática semántica |
| 📥 **Exportación de datos** | Descarga los datos filtrados en CSV compatible con Excel (UTF-8, separador `;`) |
| ♿ **Accesibilidad visual** | Tipografía Source Sans Pro, contraste adecuado y diseño responsive |
| ⚡ **Optimización para la nube** | Procesamiento previo de 28M+ registros → 6K filas (4,650x compresión) |

---
## 🛠️ Paquetes Utilizados

```r
# Paquetes principales
- shiny          # Framework para aplicaciones web interactivas
- tidyverse      # Ecosistema para ciencia de datos (dplyr, ggplot2, readr, etc.)
- sjmisc         # Funciones utilitarias para manipulación de datos
- stringi/stringr # Procesamiento de texto y normalización
- openxlsx       # Exportación a formatos Office (opcional)
- rsconnect      # Despliegue en shinyapps.io
```
<img width="1905" height="750" alt="filtros" src="https://github.com/user-attachments/assets/5a1e1c1b-85b3-45b3-97c7-0863cb8a3805" />
<img width="1908" height="847" alt="selección" src="https://github.com/user-attachments/assets/e3f116c0-e825-4c86-9ead-4a98290e6268" />
<img width="1902" height="1051" alt="descarga csv" src="https://github.com/user-attachments/assets/53827fe2-6773-442d-b393-babc6ff0c43e" />
