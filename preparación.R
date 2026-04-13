
library(readxl)
library(ggplot2)
library(tidyverse)
library(openxlsx)
library(shiny)
library(dplyr)
library(sjmisc)
library(stringi)
library(stringr)

data_total |> 
  filter(COD_REG_RBD=="Región Metropolitana de Santiago") |>
  frq(COD_DEPE) |> 
  print()


# # CARGA Y PROCESAMIENTO DATOS -------------------------------------------
# Al cargar la información, se seleccionaron solamente las variables:
# COD_REG_RBD: Código región en que se ubica el establecimiento
# NOM_COM_RBD: Nombre de la comuna en que se ubica el establecimiento
# COD_DEPE: Dependencia del establecimiento
# AGNO: Año escolar
#
# Para mayor detalle de las variables disponibles: 
# https://datosabiertos.mineduc.cl/ --> Estudiantes y párvulos # --> Matrícula por estudiante

#data_2018 <- readRDS("data/matriculas_2018_total.rds")
#data_2019 <- readRDS("data/matriculas_2019_total.rds")
#data_2020 <- readRDS("data/matriculas_2020_total.rds")
#data_2021 <- readRDS("data/matriculas_2021_total.rds")
#data_2022 <- readRDS("data/matriculas_2022_total.rds")
#data_2023 <- readRDS("data/matriculas_2023_total.rds")
#
## Función para cargar CSVs 2024 y 2025
#
#cargar_csv_matricula <- function(archivo) {
#  read.csv(archivo, sep = ";") |>
#    select(COD_REG_RBD, NOM_COM_RBD, COD_DEPE, AGNO) |>
#    mutate(AGNO = as.integer(AGNO))  # Forza tipo numérico consistente
#}
#
#data_2024 <- cargar_csv_matricula("data/matricula_unica_2024.csv")
#data_2025 <- cargar_csv_matricula("data/matricula_unica_2025.csv")
#
## Unir (ejecutar UNA SOLA VEZ)
#
#data_total <- bind_rows(
#  data_2018, data_2019, data_2020, data_2021,
#  data_2022, data_2023, data_2024, data_2025
#)
#
#cat("Total filas:", nrow(data_total), "\n")
#print(table(data_total$AGNO))
#
## Unificar nombres de las comunas
#
#data_total |> 
#  filter(COD_REG_RBD==13) |>
#  frq(NOM_COM_RBD) |> 
#  print()
#
#data_total <- data_total %>%
#  mutate(NOM_COM_RBD = NOM_COM_RBD %>%
#           str_trim() %>%                      # 1. Elimina espacios al inicio/final
#           stri_trans_general("Latin-ASCII") %>% # 2. Quita tildes, diéresis, ñ→N, etc.
#           str_to_upper()                      # 3. Estandariza a MAYÚSCULAS
#  )
#
# Recode de las variables
#data_total <- data_total %>%
#  mutate(COD_DEPE = recode(COD_DEPE,
#                           "1" = "Corporación Municipal",
#                           "2" = "Municipal DAEM",
#                           "3" = "Particular Subvencionado",
#                           "4" = "Particular Pagado (o no subvencionado)",
#                           "5" = "Corporación de Administración Delegada (DL 3166)",
#                           "6" = "Servicio Local de Educación"),
#         COD_REG_RBD = recode(COD_REG_RBD,
#                              "15" = "Región de Arica y Parinacota",
#                              "1" = "Región de Tarapacá",
#                              "2" = "Región de Antofagasta",
#                              "3" = "Región de Atacama", 
#                              "4" = "Región de Coquimbo",
#                              "5" = "Región de Valparaíso",
#                              "6" = "Región del Libertador Gral. Bernardo O’Higgins",
#                              "7" = "Región del Maule",
#                              "16" = "Región de Ñuble",
#                              "8" = "Región del Biobío", 
#                              "9" = "Región de la Araucanía",
#                              "14" = "Región de los Ríos",
#                              "10" = "Región de Los Lagos", 
#                              "11" = "Región de Aysén del Gral. Carlos Ibáñez del Campo",
#                              "12" = "Región de Magallanes y de la Antártica Chilena", 
#                              "13" = "Región Metropolitana de Santiago"))
#
## Convertir a factores
#data_total$COD_REG_RBD <- as.factor(data_total$COD_REG_RBD)
#data_total$NOM_COM_RBD <- as.factor(data_total$NOM_COM_RBD)
#data_total$COD_DEPE <- as.factor(data_total$COD_DEPE)

# Vector con orden geográfico Norte → Sur
orden_regiones <- c(
  "Región de Arica y Parinacota",
  "Región de Tarapacá", 
  "Región de Antofagasta",
  "Región de Atacama",
  "Región de Coquimbo",
  "Región de Valparaíso",
  "Región Metropolitana de Santiago",  # Centro
  "Región del Libertador Gral. Bernardo O'Higgins",
  "Región del Maule",
  "Región de Ñuble",
  "Región del Biobío",
  "Región de la Araucanía",
  "Región de los Ríos",
  "Región de Los Lagos",
  "Región de Aysén del Gral. Carlos Ibáñez del Campo",
  "Región de Magallanes y de la Antártica Chilena"
)

# Aplicar orden como factor (hazlo UNA VEZ al cargar los datos)
data_total <- data_total %>%
  mutate(COD_REG_RBD = factor(COD_REG_RBD, levels = orden_regiones))

# Guardar con compresión

saveRDS(data_total, "data/matriculas_total.rds", compress = "xz")

file.remove("data/matriculas_2018_total.rds", 
            "data/matriculas_2019_total.rds",
            "data/matriculas_2020_total.rds",
            "data/matriculas_2021_total.rds",
            "data/matriculas_2022_total.rds",
            "data/matriculas_2023_total.rds",
            "data/matricula_unica_2024.csv",
            "data/matricula_unica_2025.csv")

# 01_preparar_datos.R
# Ejecuta esto LOCALMENTE una sola vez

library(dplyr)
library(readr)

# Carga el dato crudo (solo localmente)
cat("Cargando datos crudos...\n")
data_crudo <- readRDS("data/matriculas_total.rds")

# Pre-agrega: reduce de 28M filas a ~500-1000 filas
cat("Agregando datos por año, región, comuna y tipo...\n")
data_agregada <- data_crudo %>%
  group_by(COD_REG_RBD, NOM_COM_RBD, COD_DEPE, AGNO) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(
    COD_REG_RBD = as.factor(COD_REG_RBD),
    NOM_COM_RBD = as.factor(NOM_COM_RBD),
    COD_DEPE = as.factor(COD_DEPE),
    AGNO = as.integer(AGNO)
  )

# Verifica la reducción
cat("Filas originales:", nrow(data_crudo), "\n")
cat("Filas agregadas:", nrow(data_agregada), "\n")
cat("Ratio de compresión:", round(nrow(data_crudo)/nrow(data_agregada), 1), "x\n")

# Guarda la versión ligera
saveRDS(data_agregada, "data/matriculas_agregadas.rds", compress = TRUE)

# Verifica el tamaño
tamano_mb <- file.info("data/matriculas_agregadas.rds")$size / 1024^2
cat("Tamaño del archivo agregado:", round(tamano_mb, 2), "MB\n")

cat("✅ ¡Listo! Usa 'data/matriculas_agregadas.rds' en tu app\n")

