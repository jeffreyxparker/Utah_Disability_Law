library(shiny)
library(data.table)
library(plyr)
#base <- read.csv("C:/Users/Jeff/Desktop/Utah_Disability_Law/HearingStatus/data/base.csv")
#log_file <- read.csv("C:/Users/Jeff/Desktop/Utah_Disability_Law/HearingStatus/log_file.csv")


outputDir <- "C:/Users/Jeff/Desktop/Utah_Disability_Law/HearingStatus/data"

# saveData <- function(data) {
#   # Create a unique file name
#   fileName <- sprintf("%s_%s.csv", as.integer(Sys.time()), digest::digest(data))
#   # Write the file to the local system
#   write.csv(
#     x = data,
#     file = file.path(outputDir, fileName), 
#     row.names = FALSE, quote = TRUE
#   )
# }

loadData <- function() {
  # Read all the files into a list
  files <- list.files(outputDir, full.names = TRUE)
  data <- lapply(files, read.csv, stringsAsFactors = FALSE) 
  # Concatenate all data together into one data.frame
  data <- do.call(rbind, data)
  data
}


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  ### Saves the uploaded file ###
  saveData <- eventReactive(input$submit, {
    inFile <-input$file_inputter
    if (is.null(inFile)) return(NULL)
    new_data <- read.csv(inFile$datapath)
    new_data$Status.Date <- as.Date(new_data$Status.Date, format = "%m/%d/%Y")
    new_data$Hearing.Request.Date <- as.Date(new_data$Hearing.Request.Date, format = "%m/%d/%Y")
    new_data$Hearing.Schedule.Date <- as.Date(new_data$Hearing.Schedule.Date, format = "%m/%d/%Y")
    new_data$Hearing.Held.Date <- as.Date(new_data$Status.Date, format = "%m/%d/%Y")
    new_data$report_date <- as.Date(input$report_date)
    new_data$attorney <- input$attorney
    new_data$client <- paste(new_data$First.Name,new_data$Middle.Name,new_data$First.Name,new_data$Last.4.SSN)
    write.csv(x = new_data,"C:/Users/Jeff/Desktop/Utah_Disability_Law/HearingStatus/uploaded_files/test1.csv", row.names = FALSE)
    #saveData(new_data)
    
    # ### Creates the log entry and saves it to the file
    # log_entry <- data.frame(date_time_uploaded = Sys.time(),
    #                         User = "Jeff",
    #                         report_date = as.Date(input$report_date),
    #                         attorney = input$attorney,
    #                         file_uploaded = input$file_inputter$name)
    # log_entry$text <- paste("LogX:",log_entry$date_time_uploaded,log_entry$User," uploaded ", log_entry$file_uploaded," for ",log_entry$attorney,"with report date: ", log_entry$report_date)
    # log_file <- rbind(log_file, log_entry)
    # write.csv(log_file, "C:/Users/Jeff/Desktop/Utah_Disability_Law/HearingStatus/data/log_file.csv", row.names = FALSE)
    # 
    # master <- as.data.table(master)
    # master <- master[master[, .I[which.max(Status.Date)], by=client]$V1]
    # master
  })
  
  ### Plots a chart from the uploaded file ###
  output$current_status <- renderPlot({
    base <- loadData()
    subsetted_data <- subset(base,as.Date(base$report_date) <= as.Date(input$caseload_date)) 
    subsetted_data <- subset(subsetted_data,as.Date(subsetted_data$report_date) == max(as.Date(subsetted_data$report_date)))
    subsetted_data <- subset(subsetted_data, subsetted_data$attorney %in% input$caseload_attorney)
    y <- count(subsetted_data, 'Status.of.Case')
    par(las=2)
    barplot(y$freq,
            names.arg = y$Status.of.Case,
            main = "Number of Cases in Each Status",
            horiz = TRUE,
            cex.names=0.8)
    
  })
  
  ### Prints the Master Table ###
  output$master <- renderTable({
    head(master())
  })
  
  ### Prints the log table ###
  output$log_output <- renderTable({
    tail(log_file[,6])
  })
  
  ### Prints the base table ###
  output$base <- renderTable({
    head(base)
  })
})
