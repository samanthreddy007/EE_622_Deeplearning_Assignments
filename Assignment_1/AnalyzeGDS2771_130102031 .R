# 1. Install packages to read the NCBI's GEO microarray SOFT files in R
# 1.Ref. http://www2.warwick.ac.uk/fac/sci/moac/people/students/peter_cock/r/geo/

# 1.1. Uncomment only onlibrary(Biobase)ce to install stuff

#source("https://bioconductor.org/biocLite.R")
#biocLite("GEOquery")
#biocLite("Affyhgu133aExpr")


# 1.2. Use packages # Comment to save time after first run of the program in an R session

library(Biobase)
library(GEOquery)
library(glmnet)# library used for LASSO,Ridge,Elasticnet models
library(caret)

# Add other libraries that you might need below this line



# 2. Read data and convert to dataframe. Comment to save time after first run of the program in an R session
# 2.1. Once download data from ftp://ftp.ncbi.nlm.nih.gov/geo/datasets/GDS2nnn/GDS2771/soft/GDS2771.soft.gz
# 2.Ref.1. About data: http://www.ncbi.nlm.nih.gov/sites/GDSbrowser?acc=GDS2771
# 2.Ref.2. Study that uses that data http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3694402/pdf/nihms471724.pdf
# 2.Warning. Note that do not use FULL SOFT, only SOFT, as mentioned in the link above. 2.2.R. http://stackoverflow.com/questions/20174284/error-in-gzfilefname-open-rt-invalid-description-argument

gds2771 <- getGEO(filename='C:/Users/karras/Downloads/GDS2771.soft.gz')
# Make sure path is correct as per your working folder. Could be './GDS2771.soft.gz'

eset2771 <- GDS2eSet(gds2771) #function to take GDS data structure to expressionsets
# See gds858 <- getGEO('GDS858', destdir=".")

# 2.2. View data (optional; can be commented). See http://www2.warwick.ac.uk/fac/sci/moac/people/students/peter_cock/r/geo/
eset2771 # View some meta data
featureNames(eset2771)[1:10] 
# View first feature names
sampleNames(eset2771) # View patient IDs. Should be 192
pData(eset2771)$disease.state #View disease state of each patient. Should be 192

# 2.3. Convert to data frame by concatenating disease.state with data, using first row as column names, and deleting first row
data2771 <- cbind2(c('disease.state',pData(eset2771)$disease.state),t(Table(gds2771)[,2:194]))
colnames(data2771) = data2771[1, ] # the first row will be the header
data2771 = data2771[-1, ] 

# 2.4. View data frame (optional; can be commented)
View(data2771)
df<-as.data.frame(data2771)  #data2771 is converted to dataframe
df <- sapply(df,as.numeric)  #sapply is used to convert the data frame values to numeric
df[is.na(df)]<-0      # NA values are made to 0

mymodel.cv<-cv.glmnet(df[1:135,2:ncol(df)],df[1:135,1],alpha=0,nfolds=5)  # cross validation glmnet is used to train the model for the 1st 135 samples
#for normal model use glmnet ,for cross validation use cv.glmnet
#for lasso put alpha=1
#for elasticnet alpha=0.5
#for ridge alpha=0
#for different nfolds change the value of nfolds 


pred<-predict(mymodel.cv,df[1:192,2:ncol(df)])   #samples are tested using the model trained previously

predicted<-pred   
for(i in 1:192)
{if(predicted[i]>=1&&predicted[i]<=1.5){predicted[i]<-1}
  else if (predicted[i]>1.5&&predicted[i]<=2){predicted[i]<-2}
}
s<-0 #temporary variable
for (i in 1:192)
{if(predicted[i]==df[i,1]){s<-s+1}}
meansquareerror<-mean((df[1:192,1]-pred)^2)#for finding meansquare error of the model
  View(meansquareerror)# meansquareerror
  lambdamin<-mymodel.cv$lambda.min  # for cross validation lambda minimum value
  accuracy<-(s/192)*100

  View(accuracy) # final accuracy
  
myforest<-randomForest(df[1:135,2:ncol(dm)],df[1:135,1])# random forest used for training 135 samples 
y<-predict(myforest,df[136:192,2:ncol(dm)])#predict function is used to test 57 samples
rmse <- mean((df[136:192,1] - y)^2)#calculated the mean square error for random forest model
acc<-(1-rmse)*100
View(rmse)

