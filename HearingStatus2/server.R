### TODO
# Only import files that don't already exist and only compile unique tuples



library(shiny)
library(rdrop2)
#library(data.table)
library(tidyverse)
library(lubridate)
library(shinyjs) 

### Output Directories
outputDirData <- "C:/Users/Jeff/Desktop/Utah_Disability_Law/HearingStatus2/uploaded_files"
outputDirLog <- "C:/Users/Jeff/Desktop/Utah_Disability_Law/HearingStatus2/log_files"

### Workflow Order
workflow_order <- c("PENDING FOLDER ASSEMBLY",
                    "FOLDER ASSEMBLY",
                    "PRE HEARING REVIEW",
                    "PRE HEARING DEVELOPMENT",
                    "READY TO SCHEDULE",
                    "SCHEDULED HEARING",
                    "PENDING REVIEW",
                    "POST HEARING REVIEW",
                    "POST HEARING DEVELOPMENT",
                    "PENDING DECISION WRITING",
                    "DECISION WRITING PROCESS",
                    "CASE CLOSED",
                    "CASE PERMANENTLY TRANSFERRED")

### Function that gathers all the files and compiles into a single data table
loadData <- function(outputDir) {
  files <- list.files(outputDir, full.names = TRUE)
  data <- lapply(files, read_csv) 
  data <- do.call(rbind, data)
  data
}

### Function that saves inputs to a file for use in log and data files
saveData <- function(data, fileName, outputDir) {
  write_csv(data, file.path(outputDir, fileName))
}


### Server Logic
shinyServer(function(input, output) {
  
  ### Saves the uploaded file with a few created fields ###
  observeEvent(input$submit, {
    inFile <-input$file_inputter
    if (is.null(inFile)) return(NULL)
    new_data <- read_csv(inFile$datapath)
    new_data$`Status Date` <- mdy(new_data$`Status Date`)
    new_data$`Hearing Request Date` <- mdy(new_data$`Hearing Request Date`)
    new_data$`Hearing Schedule Date` <- mdy(new_data$`Hearing Schedule Date`)
    new_data$`Hearing Held Date` <- mdy(new_data$`Hearing Held Date`)
    new_data$report_date <- ymd(input$report_date)
    new_data$attorney <- input$attorney
    new_data$client <- paste(new_data$`Last Name`,new_data$`Middle Name`,new_data$`First Name`,new_data$`Last 4 SSN`)
    fileName <- input$file_inputter$name
    saveData(data = new_data, fileName = fileName, outputDir = outputDirData)
    reset('file_inputter')
  })
  
  ### Creates the log entry and saves it to the file
  observeEvent(input$submit, {
    log_entry <- tibble(date_time_uploaded = Sys.time(),
                            User = "Jeff",
                            report_date = ymd(input$report_date),
                            attorney = input$attorney,
                            file_uploaded = input$file_inputter$name)
    fileName <- sprintf("%s_%s.csv", as.integer(Sys.time()), digest::digest(input$file_inputter$name))
    saveData(data = log_entry, fileName = fileName, outputDir = outputDirLog)
  })
  
  ### Displays the Log Table
  output$log_output <- renderTable({
    input$submit
    logs <- loadData(outputDir = outputDirLog)
    logs$Log <- paste("Log ",rownames(logs),":",logs$date_time_uploaded,logs$User," uploaded ", logs$file_uploaded," for ",logs$attorney,"with report date", logs$report_date)
    tail(logs$Log,3)
  }, colnames = FALSE)
  
  ### Displays all the Data in the main panel ###
  output$conjoined_table <- renderDataTable({
    input$submit
    loadData(outputDir = outputDirData)
  }) 
  
  ### Displays the current status ###
  output$current_status <- renderPlot({
    input$submit
    loadData(outputDir = outputDirData) %>%
      #filter(report_date == max(report_date)) %>% #Multiple attorney's is causing problems
      filter(ymd(report_date) <= input$caseload_date) %>%
      filter(attorney %in% input$caseload_attorney) %>%
      mutate(`Status of Case` = factor(`Status of Case`,levels = rev(workflow_order))) %>%
      ggplot() + 
      geom_bar(mapping = aes(x = `Status of Case`, fill = attorney),
               position = "dodge") +
      coord_flip() + 
      labs(y = "Last File Received", x = NULL)
  })
  
  ### Displays the Win Rates for the Attorneys ###
  output$win_rates <- renderPlot({
    input$submit
    loadData(outputDir = outputDirData) %>%
      filter(`Status of Case` == 'CASE CLOSED' 
             & (`T2 Decision` == 'Favorable' | `T2 Decision` == 'Unfavorable')
                & report_date >= input$dates[1] & report_date <= input$dates[2] ) %>%
    T2_table <- tibble(table(T2_data[,c('attorney','T2.Decision')]))
    T2 <- ggplot(data = T2_table, aes(x=attorney, y=Freq, fill = T2.Decision, label = Freq)) +
      geom_bar(stat = "identity", position = "dodge") +
      geom_text(aes(y = Freq + 0.05), position = position_dodge(0.9), vjust = 0) + 
      labs(x = NULL, y = NULL, title = "T2 Decisions")
    
    T16_data <- filter(data, Status.of.Case == 'CASE CLOSED' & (T16.Decision == 'Favorable' | T16.Decision == 'Unfavorable')
                      & report_date >= input$dates[1] & report_date <= input$dates[2] )
    T16_table <- as.data.frame(table(T16_data[,c('attorney','T16.Decision')]))
    T16 <- ggplot(data = T16_table, aes(x=attorney, y=Freq, fill = T16.Decision, label = Freq)) +
      geom_bar(stat = "identity", position = "dodge") +
      geom_text(aes(y = Freq + 0.05), position = position_dodge(0.9), vjust = 0) + 
      labs(x = NULL, y = NULL, title = "T16 Decisions")
  })
  
  ### Displays the Log Table ###
  output$log_table <- renderDataTable({
    input$submit
    loadData(outputDir = outputDirLog)
  })
  
})
