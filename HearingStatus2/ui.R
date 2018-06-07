library(shiny)
library(shinyjs) 

# Define UI for application that draws a histogram
shinyUI(
  fluidPage(
    useShinyjs(),
  
    # Application title
    titlePanel("Hearing Status Report Dashboard"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
      sidebarPanel(
        h3(strong("File Uploader")),
        fileInput(inputId = "file_inputter", label = "1. Select the .csv file", accept='.csv'),
        radioButtons(inputId = 'attorney', "2. Select the attorney's intials", c(DWP = 'DWP', BAJ = 'BAJ')),
        dateInput(inputId = "report_date", label = "3. Select the date the report was received"),
        h5(strong("4. Upload the file")),
        actionButton(inputId = "submit","Submit!"),
        h5(strong("5. Check the Log")),
        tableOutput("log_output")
      ),
      
      # The Main Panel with different tabs for each report type
      mainPanel(
        tabsetPanel(type = "tabs",
                    tabPanel("Attorney Caseload",
                             dateInput(inputId = "caseload_date", label = "Caseload Date"),
                             checkboxGroupInput("caseload_attorney", 
                                                label = "Caseload Attorney's", 
                                                choices = c('DWP' = 'DWP', 
                                                            'BAJ' = 'BAJ')),
                              plotOutput("current_status")
                             ),
                    tabPanel("Win Rate",
                             dateRangeInput("dates", label = "Date Range"),
                             plotOutput("win_rates")
                             ),
                    tabPanel("All Records",
                             dataTableOutput("conjoined_table")
                             ),
                    tabPanel("Upload Log",
                             dataTableOutput("log_table")
                             )
                    )
        )
    )
  )
)
