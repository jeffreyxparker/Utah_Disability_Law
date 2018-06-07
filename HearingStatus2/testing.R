### Load the same data
loadData <- function(outputDir) {
  files <- list.files(outputDir, full.names = TRUE)
  data <- lapply(files, read_csv) 
  data <- do.call(rbind, data)
  data
}
outputDirData <- "C:/Users/Jeff/Desktop/Utah_Disability_Law/HearingStatus2/uploaded_files"
data <- loadData(outputDir = outputDirData)

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


### Status
ggplot(data = data) + 
  geom_bar(mapping = aes(x = `Status of Case`, fill = attorney),
           position = "dodge") +
  coord_flip() + 
  labs(y = "Last File Received", x = NULL)


### Win Rates
dates = c(ymd("2015-10-31"),ymd("2016-12-31"))
T2_data <- filter(data, `Status of Case` == 'CASE CLOSED' & (`T2 Decision` == 'Favorable' | `T2 Decision` == 'Unfavorable')
                  & report_date >= dates[1] & report_date <= dates[2] )

T2_table <- table(T2_data$attorney,T2_data$`T2 Decision`)
T2_table
mean(T2_data$`T2 Decision` == 'Favorable')

ggplot(data = T2_data) +
  geom_bar(
    mapping = aes(x = attorney, fill = `T2 Decision`),
    position = "dodge")

T2_data <- data %>%
  filter(`Status of Case` == 'CASE CLOSED' 
       & (`T2 Decision` == 'Favorable' | `T2 Decision` == 'Unfavorable')
       & report_date >= dates[1] 
       & report_date <= dates[2] ) %>%
  mean(`T2 Decision` == 'Favorable')
table(T2_data$attorney,T2_data$`T2 Decision`)
tribble(`Column 1`, `Column 2`, C3,
        "Something", 2, ymd("2016-06-13"),
        )
