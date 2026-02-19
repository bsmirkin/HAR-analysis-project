# run_analysis.R
# This file contains the scripts to read and clearn the HAR Dataset
# Brian Mirkin
# February 18, 2026

# Use readr 
library(readr)

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
        # Use read_table2 because the whitespace in features.txt is not recognized  #
        # by read_table                                                             #
        
        features_df <- read_table2(file.path(directory,"features.txt"),
                                   col_names=c("index","feature"),
                                   col_types="ic")
        
        # read in the activity labels similarly
        activities_df <- read_table2(file.path(directory,"activity_labels.txt"),
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

df <- rbind(parseHAR(directory, subdirectory = "test"), 
            parseHAR(directory, subdirectory = "train")) %>%
        select(grep("mean|std|subject|activity",names(df),ignore.case = TRUE))



