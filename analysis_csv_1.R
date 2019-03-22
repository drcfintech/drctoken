library(gmp)
library(date)
options(scipen = 100)
options(digits = 10)
# filePrefix = "E:\\My Documents"
filePrefix = "d:\\Documents\\工作文档"
filePath = "\\DRC\\documents\\发币相关"
fileName = "\\发币2019-3-4.csv"
fileFullPath = paste(filePrefix, filePath, fileName, sep = "")
input.df = read.csv(fileFullPath, header = FALSE, colClasses = 'character')
input.df[,2] = paste(input.df[,2], "e18", sep = "")
input.df

addresses = c(input.df[,1])
addresses

invalid = addresses[nchar(addresses, type="width") != 42]
invalid
which (substring(addresses, 1, 2) != "0x") 

len = length(input.df[,2])
len

interval = 200
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
serialNo = 1
outputFileName = paste("\\addresses", datetime, "-", serialNo, "-", sep = "")
for (i in 1:end) {
    outputFile = paste(filePrefix, filePath, outputFileName, as.character(i), ".txt", sep = "")
    outputFile
    cat(input.df[,1][m[i]:n[i]], file = outputFile, sep = ",")
    cat("\n", file = outputFile, append = TRUE)
    cat(input.df[,2][m[i]:n[i]], file = outputFile, sep = ",", append = TRUE)
}

