library(shiny)
library(googleVis)
library(ggplot2)
library(GGally)
library(plotly)
library(d3heatmap)
library(shinythemes)
library(dplyr)
library(tidyr)


#======================================== load data =============================================
census.data = read.csv("censusdata.csv") # data was pre-prossessed (see codes in prototyope folder)
colnames(census.data) = c("State", "Year", "Median_House_Price", "Upper_House_Price",
                          "Divorce_Percent", "Separate_Percent", "Highschool_Percent", 
                          "Bachelor_Percent", "Median_Income", "Mean_Income")

#======================================== shiny UI =============================================
ui <- fluidPage(
    #shinythemes::themeSelector(),
    titlePanel('Coding Artists'),
    h4('(Comparison of 10 Year US Census data among 52 States)'),
    
    sidebarLayout(
    sidebarPanel(
        h5('Please drag to select the ranges:'),
        fluidRow(
        sliderInput("Median_Income.select", "Median Income Range",
                    min = min(census.data$Median_Income),
                    max = max(census.data$Median_Income),
                    value = c(min, max),
                    width = 250)),
        fluidRow(
        sliderInput("education.select", "Bachelor Percentage Range",
                    min = min(census.data$Bachelor_Percent),
                    max = max(census.data$Bachelor_Percent),
                    value = c(min, max),
                    width = 250)),
        fluidRow(
        sliderInput("Divorce_Percent.select", "Divorce Percentage Range",
                    min = min(census.data$Divorce_Percent),
                    max = max(census.data$Divorce_Percent),
                    value = c(min, max),
        width = 250)),
        fluidRow(
        sliderInput("Median_House_Price.select", "Median House Price",
                    min = min(census.data$Median_House_Price),
                    max = max(census.data$Median_House_Price),
                    value = c(min, max),
                    width = 250))),
    
    mainPanel(
            tabsetPanel(type = "tabs", 
                        tabPanel("Overall comparison", htmlOutput("Motion_plot")), 
                        
                        tabPanel("Geographical plot", 
                                 fluidRow(
                                 sliderInput("Year", "Year", 
                                             min = min(census.data$Year), 
                                             max = max(census.data$Year), 
                                             value = 1, step=1, 
                                             sep='',
                                             animate = FALSE)),
                                 
                                 fluidRow(
                                   column(1),
                                   column(5, 
                                          h6("Median income"),
                                          htmlOutput("GeoStates_plot_Median_Income")),
                                   column(5, 
                                          h6("Bachelor degree or higher percent"),
                                          htmlOutput("GeoStates_plot_Bachelor_Percent"))
                                 ),
                                 br(),
                                 
                                 fluidRow(
                                 column(1),
                                 column(5, 
                                        h6("Divorce percent"),
                                        htmlOutput("GeoStates_plot_Divorce_Percent")),
                                 column(5, 
                                        h6("Median house price"),
                                        htmlOutput("GeoStates_plot_Median_House_Price"))
                                 )
                        ),
                        
                        tabPanel("Heatmap",
                                 fluidRow(
                                     sliderInput("Year.heat", "Year",
                                                 min = min(census.data$Year),
                                                 max = max(census.data$Year),
                                                 value = 1, step=1,
                                                 sep='',
                                                 animate = FALSE)),
                                 fluidRow(d3heatmapOutput("heatmap", 
                                                          width = "100%", height = "500px"))
                        ),
            
                      tabPanel("Parallel Plot",
                               fluidRow(
                              selectInput("State", "Choose a state:",
                                          choices = unique(census.data$State),
                                          selected = "California")),
                              fluidRow(plotlyOutput("parallel_plot", 
                                                    width = "100%", height = "400px")))
))))




#======================================== shiny server =============================================
server <- function(input, output, session) {
    # data input
    dataInput <- reactive({
                 filter.census.data <- filter(census.data, Median_Income >= input$Median_Income.select[1] & Median_Income <= input$Median_Income.select[2])
                 filter.census.data <- filter(filter.census.data, Bachelor_Percent >= input$education.select[1] & Bachelor_Percent <= input$education.select[2])
                 filter.census.data <- filter(filter.census.data, Divorce_Percent >= input$Divorce_Percent.select[1] & Divorce_Percent <= input$Divorce_Percent.select[2])
                 filter.census.data <- filter(filter.census.data, Median_House_Price >= input$Median_House_Price.select[1] & Median_House_Price <= input$Median_House_Price.select[2])
   })
    
    dataInput2 <- reactive({
        filter.census.data <- dataInput()
        filter.census.data2 <- filter(filter.census.data, Year == input$Year)
    })
    
    dataInput3 <- reactive({
        filter.census.data <- dataInput()
        filter.census.data3 <- filter(filter.census.data, Year == input$Year.heat)
        row.names(filter.census.data3) <- filter.census.data3$State
        filter.census.data3 <- filter.census.data3[,-c(1,2)]
    })
    
    dataInput4 <- reactive({
      filter.census.data4 <- filter(census.data, State == input$State)
      row.names(filter.census.data4) <- filter.census.data4$Year
      filter.census.data4 <- filter.census.data4[,-c(1)]
    })
    
    
    # overall plot
    output$Motion_plot <- renderGvis({
        gvisMotionChart(dataInput(), idvar="State", timevar="Year")})
    
    # geographical -- US map
    output$GeoStates_plot_Median_House_Price <- renderGvis({
        gvisGeoChart(dataInput2(), "State", "Median_House_Price",
                     options=list(region="US", 
                     displayMode="regions", 
                     resolution="provinces",
                     width=300, height=200))
    })
    output$GeoStates_plot_Upper_House_Price <- renderGvis({
        gvisGeoChart(dataInput2(), "State", "Upper_House_Price",
                     options=list(region="US", 
                                  displayMode="regions", 
                                  resolution="provinces",
                                  width=300, height=200))
    })
    
    output$GeoStates_plot_Divorce_Percent <- renderGvis({
        gvisGeoChart(dataInput2(), "State", "Divorce_Percent",
                     options=list(region="US", 
                                  displayMode="regions", 
                                  resolution="provinces",
                                  width=300, height=200))
    })
    output$GeoStates_plot_Separate_Percent <- renderGvis({
        gvisGeoChart(dataInput2(), "State", "Separate_Percent",
                     options=list(region="US", 
                                  displayMode="regions", 
                                  resolution="provinces",
                                  width=300, height=200))
    })
    output$GeoStates_plot_Highschool_Percent <- renderGvis({
        gvisGeoChart(dataInput2(), "State", "Highschool_Percent",
                     options=list(region="US", 
                                  displayMode="regions", 
                                  resolution="provinces",
                                  width=300, height=200))
    })
    output$GeoStates_plot_Bachelor_Percent <- renderGvis({
        gvisGeoChart(dataInput2(), "State", "Bachelor_Percent",
                     options=list(region="US", 
                                  displayMode="regions", 
                                  resolution="provinces",
                                  width=300, height=200))
    })
    output$GeoStates_plot_Median_Income <- renderGvis({
        gvisGeoChart(dataInput2(), "State", "Median_Income",
                     options=list(region="US", 
                                  displayMode="regions", 
                                  resolution="provinces",
                                  width=300, height=200))
    })
    output$GeoStates_plot_Mean_Income <- renderGvis({
        gvisGeoChart(dataInput2(), "State", "Mean_Income",
                     options=list(region="US", 
                                  displayMode="regions", 
                                  resolution="provinces",
                                  width=300, height=200))
    })
    
    # heatmap
    output$heatmap <- renderD3heatmap({
        d3heatmap(dataInput3(), scale = "column", colors = "Spectral", 
                  xaxis_font_size = "7pt", 
                  labCol = c("Separate PCT", "Divorce PCT", "Bachelor PCT", "highschool PCT",
                             "Median Income", "Mean Income", "Median House", "Upper House"))
    })

    # parallel_plot
    output$parallel_plot <- renderPlotly({
        df <- dataInput4()
        df <- df[, c("Year", "Median_Income", "Bachelor_Percent", 
                             "Divorce_Percent", "Median_House_Price")]
        df <- gather(df, condition, measurement, Median_Income:Median_House_Price, factor_key=TRUE)
        ggplot(data = df,
               mapping = aes(x = Year, y = measurement, shape = condition, colour = condition)) +
          geom_point() +
          geom_line() +
          facet_grid(facets = condition ~ ., scale = "free_y")  +
          theme(axis.text.x = element_text(size = 5, angle = 90),
                axis.text.y = element_text(size = 8),
                axis.title.x = element_text(vjust = 0),
                axis.ticks = element_blank(),
                panel.grid.minor = element_blank())
    })
}

shinyApp(ui = ui, server = server)
