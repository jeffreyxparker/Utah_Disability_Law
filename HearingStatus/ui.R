library(shiny)

shinyUI(fluidPage(
  
  # Application Title
  titlePanel("Hearing Status Report Dashboard"),
  
  # The Sidebar for file uploading
  sidebarLayout(
    sidebarPanel(
      h3(strong("File Uploader")),
      fileInput(inputId = "file_inputter", label = "1. Select the .csv file", accept='.csv'),
      radioButtons(inputId = 'attorney', "2. Select the attorney's intials",
                   c(DWP = 'DWP', BAJ = 'BAJ')),
      dateInput(inputId = "report_date", label = "3. Select the date the report was received"),
      h5(strong("4. Upload the file")),
      actionButton(inputId = "submit","Submit!"),
      br(),
      tableOutput("log_output")
    ),
    
    # The Main Panel with different tabs for each report type
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Attorney Caseload",
                           dateInput(inputId = "caseload_date", label = "Caseload Date"),
                           checkboxGroupInput(inputId = 'caseload_attorney', "Caseload Attorney's",choices = list(DWP = 'DWP', BAJ = 'BAJ'), selected = c('DWP','BAJ')),
                           plotOutput("current_status")
                  ),
                  tabPanel("Master File",tableOutput("master")),
                  tabPanel("Base File", tableOutput("base"))
      )
    )
  )
))
