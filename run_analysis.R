library("tidyr")
library("plyr")
library("dplyr")

L_WD<-getwd()

###Load Test Files
##Location
L_Field_Names <- paste(L_WD, '/features.txt', sep = '')

L_Test<- paste(L_WD, '/test', sep ='')
L_Test_Subject <- paste(L_Test, '/subject_test.txt', sep = '')
L_Test_X <- paste(L_Test, '/X_test.txt', sep = '')
L_Test_Y <- paste(L_Test, '/Y_test.txt', sep = '')

L_Train<- paste(L_WD, '/train', sep ='')
L_Train_Subject <- paste(L_Train, '/subject_train.txt', sep = '')
L_Train_X <- paste(L_Train, '/X_train.txt', sep = '')
L_Train_Y <- paste(L_Train, '/Y_train.txt', sep = '')


##Data Frame
Field_Names <- read.table(L_Field_Names) 

Test_Subject <- read.table(L_Test_Subject)
Test_X <- read.table(L_Test_X)
Test_Y <- read.table(L_Test_Y)

Train_Subject <- read.table(L_Train_Subject)
Train_X <- read.table(L_Train_X)
Train_Y <- read.table(L_Train_Y)


##Get the name to the Subject, X and Y
colnames(Test_Subject) <- "Subject"
colnames(Train_Subject) <- "Subject"

colnames(Test_X) <- Field_Names$V2
colnames(Train_X) <- Field_Names$V2
View(Test_Subject)

colnames(Test_Y) <- "Activity"
colnames(Train_Y) <- "Activity"

Test_SY <- cbind(Test_Subject, Test_Y)
Test <- cbind(Test_SY, Test_X)

Train_SY <- cbind(Train_Subject, Train_Y)
Train <- cbind(Train_SY, Train_X)

##Add Source Col to Test and Train
Test$Source <- "Test"
Train$Source <- "Train"


## Combine Test and Train
HD_Total <- rbind(Test, Train)

## Extracts only the measurements on the mean and standard deviation for each measurement
HD_names <- names(HD_Total)
HD_names_Sub <- c("Source", "Subject", "Activity", HD_names[grepl("std..$|mean..$", HD_names)])
HD_Total_Sub <- HD_Total[HD_names_Sub]


## Use Descriptive name to name the activities
L_Activity <- paste(L_WD, '/activity_labels.txt', sep = '')
Activity_Name <- read.table(L_Activity)
colnames(Activity_Name) <- c("Activity", "Activity_Des")

HD_Total_Sub_D <- join(HD_Total_Sub, Activity_Name, by="Activity")

HD_Total_Sub_D

## Get the average of each variable for each activity and each subject

HD_T_Sub_D_G <- group_by(HD_Total_Sub_D, Subject, Activity, Activity_Des)
Summarize_list <- names(HD_T_Sub_D_G)[4:21]

HD_Total_Sub_D_2 <- HD_T_Sub_D_G %>% summarize_at(Summarize_list, funs(mean))

Avg_Name <- vapply(Summarize_list, function(x){paste("Avg_", x, sep= "")},"", USE.NAMES = FALSE)
colnames(HD_Total_Sub_D_2)[4:21]<-Avg_Name


## Output Data File

Output_File <- paste(L_WD, '/Human_Movement_Summary.txt', sep = '')
write.table(HD_Total_Sub_D_2, file = Output_File, row.names = FALSE)


