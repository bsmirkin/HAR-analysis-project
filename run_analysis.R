# run_analysis.R
# This file contains the scripts to read and clearn the HAR Dataset
# Brian Mirkin
# February 18, 2026

# Use readr 
library(readr)
library(dplyr)

#function to read and format a dataset as a data frame
#to be repeated for each directory where the HAR type data is stored

parseHAR <- function(directory = "UCI HAR Dataset",subdirectory = "test") {
        
        # This function assumes the structure of the HAR data:
        # "directory" contains the "features.txt" file that has the column headings
        # of the data
        # "subdirectory" contains 
        #                   "X_{subdirectory}.txt which are the measurements
        #                   "Y_{subdirectory}.txt" which are the activities
        #                   "subject_{subdirectory}.txt" which are the test subjects
        # Returns a dataframe with the data and labels
        
        #############################################################################
        # Read common information from the directory                                #
        # Get the column names from features.txt                                    #

        features_df <- read_table(file.path(directory,"features.txt"),
                                   col_names=c("index","feature"),
                                   col_types="ic")
        
        # read in the activity labels similarly
        activities_df <- read_table(file.path(directory,"activity_labels.txt"),
                                     col_names=c("index","activity"),
                                     col_types="ic")
        # make the labels lowercase 
        activities_df <- activities_df %>% mutate(activity = tolower(activity))
        ############################################################################
        
        # Read in the data, using the column names from the features list
        df <- read_table(
                file.path(directory,subdirectory,
                          paste("X_",subdirectory,".txt",sep="")),
                col_names = features_df$feature,
                col_types=cols(.default = col_double()),
        )
        
        # Read the subjects as an integer vector
        subjects <- as.integer(read_lines(
                file.path(directory,subdirectory,
                          paste("subject_",subdirectory,".txt",sep=""))))
        
        # Read the activities as an integer vector
        activities <- as.integer(read_lines(
                file.path(directory,subdirectory,
                          paste("y_",subdirectory,".txt",sep=""))))
        
        # convert the activities to labeled activites
        # create a lookup table using the labels from the file for flexibility
        activity_lookup <- setNames(activities_df$activity,activities_df$index)
        
        # add columns for subjects and readable activities, then return
        df %>% mutate(
                subject=subjects, 
                activity=activity_lookup[activities],
                .before=1
        )
}

# get the dataframe for the two directories with data
# then select only the columns we added for subject and activity
# and mean and std deviation data

directory = "UCI HAR Dataset"

# 1. Merge the training and test sets to create one dataset
#       uses parseHAR above to assemble the dataframes then merge them

df <- rbind(parseHAR(directory, subdirectory = "test"), 
            parseHAR(directory, subdirectory = "train")) 

# 2. Extract only the measurements on the mean and standard deviation for
#       each measurement. Also the new columns subject and activity which
#.      are from the subject_ and Y_ text files, respectively

# store the original names for documentation
datanames <- names(df)
# get the columns to keep
columnstokeep <- grep("mean|std|subject|activity",names(df),ignore.case = TRUE)
# select the columns 
df <- df %>% select(all_of(columnstokeep))

# 3. Use descriptive activity names to name the activities in the data set
#       This is already done within the parseHAR function (see lines 60,65 above)

# 4. Appropriately label the data set with descriptive variable names

# The following replaces abbreviations used in the column names

names(df) <- names(df) |>
        sub("^t", "timedomain", x = _) |>
        sub("^f", "freqdomain", x = _) |>
        sub("Acc", "Accelerometer", x = _) |>
        sub("Gyro", "Gyroscope", x = _) |>
        sub("\\(t", "\\(timedomain", x = _)

# save the tidy data
write_csv(df,"tidydata/HARtidydata.csv")

### This section is for creating the codebook variable table only
# write a table to map the variable names and whether they were kept or not

originalnames <- datanames[-c(1,2)] #remove subject,test
# perform the same substitations as above but on the entire name list
newnames <- datanames[-c(1,2)] |>
        sub("^t", "timedomain", x = _) |>
        sub("^f", "freqdomain", x = _) |>
        sub("Acc", "Accelerometer", x = _) |>
        sub("Gyro", "Gyroscope", x = _) |>
        sub("\\(t", "\\(timedomain", x = _)
# which measurements were retained in the data
retained <- seq_along(originalnames) %in% columnstokeep[-c(1,2)]
# blank out unretained names for the table
newnames_clean <- ifelse(retained,newnames,"")
# make a table for the document
doc_table <- tibble(
        original_name = originalnames,
        new_name = newnames_clean,
        retained = retained
)
library(knitr)

# create markdown table as a string
md_table <- kable(doc_table, format = "markdown")

# write to a .md file
writeLines(md_table, "variable_documentation.md")

### End codebook generation section



# 5. From the data set in step 4, create a second, independent tidy data set
#       with the average of each variable for each activity and subject

# summarise 
df_summary <- df %>% group_by(subject, activity) %>% 
        summarise( across( everything(), mean, .names = "mean_of_{.col}" ),
        .groups = "drop" )

# save summary per instructions
write.table(df_summary,"tidydata/HAR_summary_table.txt",row.names = FALSE)
