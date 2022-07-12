---
title: "Getting and Cleaning Data Course Project"
author: "B. Matarlo"
date: "12-07-2022"
output:
  html_document:
    keep_md: yes
---

## Project Description

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 

You should create one R script called run_analysis.R that does the following. 

1. Merges the training and the test sets to create one data set.

2. Extracts only the measurements on the mean and standard deviation for each measurement. 

3. Uses descriptive activity names to name the activities in the data set

4. Appropriately labels the data set with descriptive variable names. 

5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

This project contains the following files:

1. run_analysis.R : R code

2. TidyDataset.txt : Tidy dataset produced after running R code on original dataset

3. CodeBook.md : Analysis of code run_analysis.R

4. Codebook.html : html version of Codebook.md

### Source of raw data

A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

Data used in project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  

### Notes on the original (raw) data 

Quoting from the README.txt included in raw data:
For each record it is provided:

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

The dataset includes the following files:

- 'README.txt'

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

Notes: 

- Features are normalized and bounded within [-1,1].
- Each feature vector is a row on the text file.

## Assumptions

### Libraries used

Libraries used in this project were [dplyr]. [dplyr] was used to manipulate data frames to create a tidy dataset.

```r
library(dplyr)
```

### Files

First, download files provided in link (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip). 
It is assumed that the working directory is set to one that contains the [UCI HAR Dataset] folder

### Loading data

Both test and training datasets contain files pertaining to subject, features and activities. The column identities are consistent among all files.

### Read in test data.

```r
test_sub <- read.table("UCI HAR Dataset/test/subject_test.txt")
test_feat <- read.table("UCI HAR Dataset/test/X_test.txt")
test_act <- read.table("UCI HAR Dataset/test/Y_test.txt")
```

### Read in training data.

```r
train_sub <- read.table("UCI HAR Dataset/train/subject_train.txt")
train_feat <- read.table("UCI HAR Dataset/train/X_train.txt")
train_act <- read.table("UCI HAR Dataset/train/Y_train.txt")
```

### Metadata

Metadata contains information on the name of the features and the identity of the activities.

```r
featureNames <- read.table("UCI HAR Dataset/features.txt")
activityNames <- read.table("UCI HAR Dataset/activity_labels.txt")
```

## 1. Merges the training and the test sets to create one data set.

Merge data for subject, feature and activity

New data frames are stored in [subject], [feature] and [activity]

```r
subject <- rbind(test_sub, train_sub) 
feature <- rbind(test_feat, train_feat)
activity <- rbind(test_act, train_act)
```

Rename columns for clarity

```r
colnames(subject) <- "subject"
colnames(feature) <- featureNames[ ,2]
colnames(activity) <- "activity"
```

Merge all data into one dataframe called [complete].

```r
complete <- cbind(subject, activity, feature)
```

## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

Standard deviation and mean are indicated in the feature names, now the column names of [complete].
Extract columns with information pertaining to std.dev and mean and store in new dataframe called [ext_data]

```r
cols <- grep("*mean*|*std*", names(complete), ignore.case = T)
new_cols <- c(1, 2, cols)
ext_data <- complete[ ,new_cols]
```

## 3. Uses descriptive activity names to name the activities in the data set

First, change activity labels from factors into characters. Then replace all activity numbers with their corresponding activity label in [activityNames].

```r
ext_data$activity <- as.character(ext_data$activity)
activityNames[ ,2] <- as.character(activityNames[,2])
for(i in 1:length(activityNames[,2])) {
  ext_data$activity[ext_data$activity==i] <- activityNames[i,2]
}
```

## 4. Appropriately labels the data set with descriptive variable names.

First, check current names of features.

```r
View(featureNames)
```

Changing abbreviations to full names:
1. Acc = Acceleration
2. t = Time
3. Gyro = Gyroscope
4. f = Frequency
5. BodyBody = Body
6. Mag = Magnitude


```r
old_names <- c("Acc", "^t", "Gyro","^f","BodyBody", "Mag", "tBody")
new_names <- c("Acceleration", "Time", "Gyroscope", "Frequency", "Body", "Magnitude", "TimeBody")
for(i in 1:length(old_names)) {
  colnames(ext_data) <- gsub(old_names[i], new_names[i], colnames(ext_data), ignore.case = T)
}
```

New, more descriptive names

```r
colnames(ext_data)
```

```
##  [1] "subject"                                          
##  [2] "activity"                                         
##  [3] "TimeBodyAcceleration-mean()-X"                    
##  [4] "TimeBodyAcceleration-mean()-Y"                    
##  [5] "TimeBodyAcceleration-mean()-Z"                    
##  [6] "TimeBodyAcceleration-std()-X"                     
##  [7] "TimeBodyAcceleration-std()-Y"                     
##  [8] "TimeBodyAcceleration-std()-Z"                     
##  [9] "TimeGravityAcceleration-mean()-X"                 
## [10] "TimeGravityAcceleration-mean()-Y"                 
## [11] "TimeGravityAcceleration-mean()-Z"                 
## [12] "TimeGravityAcceleration-std()-X"                  
## [13] "TimeGravityAcceleration-std()-Y"                  
## [14] "TimeGravityAcceleration-std()-Z"                  
## [15] "TimeBodyAccelerationJerk-mean()-X"                
## [16] "TimeBodyAccelerationJerk-mean()-Y"                
## [17] "TimeBodyAccelerationJerk-mean()-Z"                
## [18] "TimeBodyAccelerationJerk-std()-X"                 
## [19] "TimeBodyAccelerationJerk-std()-Y"                 
## [20] "TimeBodyAccelerationJerk-std()-Z"                 
## [21] "TimeBodyGyroscope-mean()-X"                       
## [22] "TimeBodyGyroscope-mean()-Y"                       
## [23] "TimeBodyGyroscope-mean()-Z"                       
## [24] "TimeBodyGyroscope-std()-X"                        
## [25] "TimeBodyGyroscope-std()-Y"                        
## [26] "TimeBodyGyroscope-std()-Z"                        
## [27] "TimeBodyGyroscopeJerk-mean()-X"                   
## [28] "TimeBodyGyroscopeJerk-mean()-Y"                   
## [29] "TimeBodyGyroscopeJerk-mean()-Z"                   
## [30] "TimeBodyGyroscopeJerk-std()-X"                    
## [31] "TimeBodyGyroscopeJerk-std()-Y"                    
## [32] "TimeBodyGyroscopeJerk-std()-Z"                    
## [33] "TimeBodyAccelerationMagnitude-mean()"             
## [34] "TimeBodyAccelerationMagnitude-std()"              
## [35] "TimeGravityAccelerationMagnitude-mean()"          
## [36] "TimeGravityAccelerationMagnitude-std()"           
## [37] "TimeBodyAccelerationJerkMagnitude-mean()"         
## [38] "TimeBodyAccelerationJerkMagnitude-std()"          
## [39] "TimeBodyGyroscopeMagnitude-mean()"                
## [40] "TimeBodyGyroscopeMagnitude-std()"                 
## [41] "TimeBodyGyroscopeJerkMagnitude-mean()"            
## [42] "TimeBodyGyroscopeJerkMagnitude-std()"             
## [43] "FrequencyBodyAcceleration-mean()-X"               
## [44] "FrequencyBodyAcceleration-mean()-Y"               
## [45] "FrequencyBodyAcceleration-mean()-Z"               
## [46] "FrequencyBodyAcceleration-std()-X"                
## [47] "FrequencyBodyAcceleration-std()-Y"                
## [48] "FrequencyBodyAcceleration-std()-Z"                
## [49] "FrequencyBodyAcceleration-meanFreq()-X"           
## [50] "FrequencyBodyAcceleration-meanFreq()-Y"           
## [51] "FrequencyBodyAcceleration-meanFreq()-Z"           
## [52] "FrequencyBodyAccelerationJerk-mean()-X"           
## [53] "FrequencyBodyAccelerationJerk-mean()-Y"           
## [54] "FrequencyBodyAccelerationJerk-mean()-Z"           
## [55] "FrequencyBodyAccelerationJerk-std()-X"            
## [56] "FrequencyBodyAccelerationJerk-std()-Y"            
## [57] "FrequencyBodyAccelerationJerk-std()-Z"            
## [58] "FrequencyBodyAccelerationJerk-meanFreq()-X"       
## [59] "FrequencyBodyAccelerationJerk-meanFreq()-Y"       
## [60] "FrequencyBodyAccelerationJerk-meanFreq()-Z"       
## [61] "FrequencyBodyGyroscope-mean()-X"                  
## [62] "FrequencyBodyGyroscope-mean()-Y"                  
## [63] "FrequencyBodyGyroscope-mean()-Z"                  
## [64] "FrequencyBodyGyroscope-std()-X"                   
## [65] "FrequencyBodyGyroscope-std()-Y"                   
## [66] "FrequencyBodyGyroscope-std()-Z"                   
## [67] "FrequencyBodyGyroscope-meanFreq()-X"              
## [68] "FrequencyBodyGyroscope-meanFreq()-Y"              
## [69] "FrequencyBodyGyroscope-meanFreq()-Z"              
## [70] "FrequencyBodyAccelerationMagnitude-mean()"        
## [71] "FrequencyBodyAccelerationMagnitude-std()"         
## [72] "FrequencyBodyAccelerationMagnitude-meanFreq()"    
## [73] "FrequencyBodyAccelerationJerkMagnitude-mean()"    
## [74] "FrequencyBodyAccelerationJerkMagnitude-std()"     
## [75] "FrequencyBodyAccelerationJerkMagnitude-meanFreq()"
## [76] "FrequencyBodyGyroscopeMagnitude-mean()"           
## [77] "FrequencyBodyGyroscopeMagnitude-std()"            
## [78] "FrequencyBodyGyroscopeMagnitude-meanFreq()"       
## [79] "FrequencyBodyGyroscopeJerkMagnitude-mean()"       
## [80] "FrequencyBodyGyroscopeJerkMagnitude-std()"        
## [81] "FrequencyBodyGyroscopeJerkMagnitude-meanFreq()"   
## [82] "angle(TimeBodyAccelerationMean,gravity)"          
## [83] "angle(TimeBodyAccelerationJerkMean),gravityMean)" 
## [84] "angle(TimeBodyGyroscopeMean,gravityMean)"         
## [85] "angle(TimeBodyGyroscopeJerkMean,gravityMean)"     
## [86] "angle(X,gravityMean)"                             
## [87] "angle(Y,gravityMean)"                             
## [88] "angle(Z,gravityMean)"
```

## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

First, convert activity labels into factor variables. Then, group data by subject and activity.

```r
ext_data$activity <- as.factor(ext_data$activity)
ext_data <-  group_by(ext_data, subject, activity)
```

Use summarize_each() function to calculate mean for each subject and activity.

```r
new_dataset <- ext_data %>% 
  group_by(subject, activity) %>%
  summarize_each(funs(mean))
```

```
## Warning: `summarise_each_()` was deprecated in dplyr 0.7.0.
## Please use `across()` instead.
```

```
## Warning: `funs()` was deprecated in dplyr 0.8.0.
## Please use a list of either functions or lambdas: 
## 
##   # Simple named list: 
##   list(mean = mean, median = median)
## 
##   # Auto named with `tibble::lst()`: 
##   tibble::lst(mean, median)
## 
##   # Using lambdas
##   list(~ mean(., trim = .2), ~ median(., na.rm = TRUE))
```

Write processed tidy data into file called [TidyDataset.txt].

```r
write.table(new_dataset, file = "TidyDataset.txt", row.names = F)
```
