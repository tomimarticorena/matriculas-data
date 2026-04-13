
##########################################################################
#                                                                        #
# Procesamiento de las matrículas de enseñanza básica y media            #
# 2018-2025                                                              #
# Datos abiertos MINEDUC: https://datosabiertos.mineduc.cl/              #
# Fuente de la información Sistema de Información general de Estudiantes #
#                                                                        #
##########################################################################


# CARGA DE PAQUETES -------------------------------------------------------

library(readxl)
library(ggplot2)
library(tidyverse)
library(openxlsx)
library(shiny)
library(dplyr)
library(sjmisc)
library(stringi)
library(stringr)


# CARGA DE LOS DATOS YA PROCESADOS ----------------------------------------

#data_total <- readRDS("data/matriculas_total.rds")
data_total <- readRDS("data/matriculas_agregadas.rds")
colnames(data_total)

# Vector con el orden de las regiones (norte a sur)
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

# Función para inyectar estilos UNESCO
unesco_theme <- function() {
  tags$head(
    tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@300;400;600&display=swap');
      
      body {
        font-family: 'Source Sans Pro', -apple-system, BlinkMacSystemFont, sans-serif;
        background-color: #f8f9fa;
        color: #333;
      }
      
      .well {
        background-color: #fff;
        border: 1px solid #e0e0e0;
        border-radius: 4px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
      }
      
      .selectize-input, .form-control {
        border: 1px solid #ccc;
        border-radius: 4px;
        font-size: 14px;
      }
      
      .selectize-input.focus {
        border-color: #0092D6;
        box-shadow: 0 0 0 2px rgba(0,146,214,0.2);
      }
      
      h1, h2, h3, h4 {
        color: #006699;
        font-weight: 600;
      }
      
      .plot-container {
        background: white;
        padding: 15px;
        border-radius: 6px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
      }
    "))
  )
}

# Interfaz UI
ui <- fluidPage(
  unesco_theme(),
  titlePanel(
    tags$div(
      tags$h2("Matrículas: Enseñanza Básica y Media", 
              style = "color: #006699; font-weight: 600; margin-bottom: 0.2rem;"),
      tags$p("Por Región, Comuna y Tipo de Establecimiento", 
             style = "color: #555; font-size: 1.1rem; margin-top: 0;"),
      tags$small("Fuente: Datos Abiertos MINEDUC", 
                 style = "color: #888; font-style: italic;")
    )
  ),
  sidebarLayout(
    sidebarPanel(
      selectInput("region", "Región:", 
                  choices = orden_regiones,
                  selected = "Región Metropolitana de Santiago"),
      uiOutput("comuna_ui"),
      selectInput("tipo_establecimiento", "Tipo de Establecimiento:", 
                  choices = sort(unique(data_total$COD_DEPE))),
      downloadButton("descargar_datos", "📥 Descargar datos (.csv)", 
                     class = "btn-primary", style = "width: 100%; margin-top: 10px;")
    ),
    mainPanel(
      plotOutput("matriculaPlot")
    )
  )
)

# Lógica server
server <- function(input, output, session) {
  
  # Comunas disponibles por región
  output$comuna_ui <- renderUI({
    req(input$region)
    comunas <- data_total %>%
      filter(COD_REG_RBD == input$region) %>%
      select(NOM_COM_RBD) %>%
      distinct() %>%
      arrange(NOM_COM_RBD)
    selectInput("comuna", "Comuna:", choices = comunas$NOM_COM_RBD)
  })
  
  # Plot de matrículas
  # Plot de matrículas
  output$matriculaPlot <- renderPlot({
    req(input$region, input$comuna, input$tipo_establecimiento)
    
    # Filtrar datos YA AGREGADOS (no hacer count de nuevo)
    data_filtered <- data_total %>%
      filter(COD_REG_RBD == input$region,
             NOM_COM_RBD == input$comuna,
             COD_DEPE == input$tipo_establecimiento)
    
    validate(need(nrow(data_filtered) > 0, "No hay datos disponibles para esta combinación de filtros."))
    
    ggplot(data_filtered, aes(x = factor(AGNO), y = n, fill = factor(AGNO))) +  # ← Usar columna 'n'
      geom_col(show.legend = FALSE) +
      geom_text(aes(label = n), vjust = -0.5, size = 3) +
      scale_fill_manual(values = c(
        "2018" = "#B0BEC5", "2019" = "#78909C", "2020" = "#0092D6",
        "2021" = "#00B4D8", "2022" = "#0077B6", "2023" = "#023E8A",
        "2024" = "#03045E", "2025" = "#000000"
      )) +
      labs(title = paste("Matrículas en", input$comuna),
           subtitle = input$tipo_establecimiento,
           x = "Año", y = "Cantidad de matrículas") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Datos reactivos filtrados (reutilizables para gráfico y descarga)
  # Datos reactivos filtrados (ya vienen agregados)
  datos_filtrados <- reactive({
    req(input$region, input$comuna, input$tipo_establecimiento)
    
    data_total %>%
      filter(COD_REG_RBD == input$region,
             NOM_COM_RBD == input$comuna,
             COD_DEPE == input$tipo_establecimiento) %>%
      select(AGNO, n)
  })
  # Descarga de los datos
  output$descargar_datos <- downloadHandler(
    filename = function() {
      # Limpiar el nombre de las comunas: sin espacios, minúsculas, sin tildes
      comuna_limpia <- tolower(input$comuna) %>%
        stringi::stri_trans_general("Latin-ASCII") %>%
        gsub("\\s+", "_", .)
      paste0("matriculas_", comuna_limpia, "_", format(Sys.Date(), "%Y%m%d"), ".csv")
    },
    content = function(file) {
      df <- datos_filtrados()
      # write.csv2 usa ";" como separador y "," para decimales (estándar Excel en español)
      write.csv2(df, file, row.names = FALSE, na = "", fileEncoding = "UTF-8")
    },
    contentType = "text/csv; charset=UTF-8"
  )
}

# Lanzar app
shinyApp(ui = ui, server = server)

