library(dplyr)

# Set wd to dataset
setwd("UCI HAR Dataset")

# read in test data
test_sub <- read.table("test/subject_test.txt")
test_feat <- read.table("test/X_test.txt")
test_act <- read.table("test/Y_test.txt")

# read in training data
train_sub <- read.table("train/subject_train.txt")
train_feat <- read.table("train/X_train.txt")
train_act <- read.table("train/Y_train.txt")

# read in supporting metadata
featureNames <- read.table("features.txt")
activityNames <- read.table("activity_labels.txt")

# merge data for subject, feature and activity
# new data frames are stored in 'subject', 'feature' and 'activity'
subject <- rbind(test_sub, train_sub) 
feature <- rbind(test_feat, train_feat)
activity <- rbind(test_act, train_act)

# rename columns for clarity
colnames(subject) <- "subject"
colnames(feature) <- featureNames[ ,2]
colnames(activity) <- "activity"

# merge all data
complete <- cbind(subject, activity, feature)

# extract only measurements of std.dev and mean for each measurement
cols <- grep("*mean*|*std*", names(complete), ignore.case = T)
new_cols <- c(1, 2, cols)

# extracted data
ext_data <- complete[ ,new_cols]

# add descriptive activity names to dataset
# first, change labels from factors into characters
ext_data$activity <- as.character(ext_data$activity)
activityNames[ ,2] <- as.character(activityNames[,2])

for(i in 1:length(activityNames[,2])) {
  ext_data$activity[ext_data$activity==i] <- activityNames[i,2]
}

# appropriately labeling dataset with descriptive variable names
View(featureNames)

# deceiphering shorthand
# Acc = Acceleration
# t = Time
# Gyro = Gyroscope
# f = Frequency
# BodyBody = Body
# Mag = Magnitude

old_names <- c("Acc", "^t", "Gyro","^f","BodyBody", "Mag", "tBody")
new_names <- c("Acceleration", "Time", "Gyroscope", "Frequency", "Body", "Magnitude", "TimeBody")
for(i in 1:length(old_names)) {
  colnames(ext_data) <- gsub(old_names[i], new_names[i], colnames(ext_data), ignore.case = T)
}

# new, more descriptive names
colnames(ext_data)

# creating independent tidy dataset with average of 
# each variable for each activity and each subject
ext_data$activity <- as.factor(ext_data$activity)
ext_data <-  group_by(ext_data, subject, activity)

new_dataset <- ext_data %>% 
  group_by(subject, activity) %>%
  summarize_each(funs(mean))

write.table(new_dataset, file = "TidyDataset.txt", row.names = F)
