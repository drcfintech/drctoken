library(gmp)
library(date)
options(scipen = 100)
options(digits = 10)
filePrefix = "E:\\My Documents"
filePath = "\\DRC\\documents\\发币相关"
fileName = "\\发币2018-4-29-2.csv"
fileFullPath = paste(filePrefix, filePath, fileName, sep = "")
input.df = read.csv(fileFullPath, header = FALSE, colClasses = 'character')
input.df[,2] = paste(input.df[,2], "e18", sep = "")
input.df

len = length(input.df[,2])
len

interval = 150
if (len < interval) {
  m = c(1)
  n = c(len)
} else {
  m = seq(1, len, by = interval)
  n = c(seq(interval, len, by = interval), len)
}
m
n

end = ceiling(len / interval)
end
datetime = format(Sys.Date(), "%Y%m%d")
datetime
serialNo = 2
outputFileName = paste("\\addresses", datetime, "-", serialNo, "-", sep = "")
for (i in 1:end) {
    outputFile = paste(filePrefix, filePath, outputFileName, as.character(i), ".txt", sep = "")
    outputFile
    cat(input.df[,1][m[i]:n[i]], file = outputFile, sep = ",")
    cat("\n", file = outputFile, append = TRUE)
    cat(input.df[,2][m[i]:n[i]], file = outputFile, sep = ",", append = TRUE)
}

