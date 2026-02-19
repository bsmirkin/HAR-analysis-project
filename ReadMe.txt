HAR (Human Activity Recognition using Smartphones) analysis project
Brian Mirkin
February 2026

This project contains my submission for the Getting and Cleaning Data Course
Project on Coursera 
(https://www.coursera.org/learn/data-cleaning/peer/FIZtT/getting-and-cleaning-data-course-project)

The submission contains the following files:
        - ReadMe.txt - This file describing the project and contents
        - codebook.md - Codebook describing the data and the changes to convert
                to tidy data for the assignment
        - run_analysis.R - R scripts used to manipulate the data and prepare 
                assignment deliverables.
                
The original data is expected to be in a subdirectory "UCI HAR Dataset".
It may be obtained at  

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Additional information about the data is available at
https://archive.ics.uci.edu/dataset/240/human+activity+recognition+using+smartphones

The original data contains subdirectories "test" and "train" which contain portions
of the overall dataset. These are expected to be present by the run_analysis script.


When run, the run_analysis.R script will perform the following actions
        1. Merge the training and test data sets into a single dataset 
        2. Extract only the measurements of the mean and standard deviation
                for each measurement
        3. Uses descriptive activity names to name the activities in the data set
        4. Labels the data set with descriptive variable names
        5. From the data set in step 4, creates a second, independent tidy data 
                set with the average of each variable for each activity and each 
                subject.