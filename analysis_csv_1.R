library(gmp)
options(scipen = 100)
options(digits = 10)
voiceURL = "C:\\Users\\rcit-001\\Documents\\工作文档\\DRC\\documents\\发币相关\\发币2018-4-23-内部认购.csv"
input.df = read.csv(voiceURL, header = FALSE, colClasses = 'character')
input.df[,2] = paste(input.df[,2], "e18", sep = "")
input.df

len = length(input.df[,2])
len

interval = 150
if (len < interval) {
  m = c(1)
  n = c(len)
} else {
  m = seq(1, len - interval + 1, by = interval)
  n = c(seq(interval, len, by = interval), len)
}
m
n

end = ceiling(len / interval)
end
for (i in 1:end) {
    filename = paste("C:\\Users\\rcit-001\\Documents\\工作文档\\DRC\\documents\\发币相关\\addresses0424-2-", as.character(i), ".txt", sep = "")
    filename
    cat(input.df[,1][m[i]:n[i]], file = filename, sep = ",")
    cat("\n", file = filename, append = TRUE)
    cat(input.df[,2][m[i]:n[i]], file = filename, sep = ",", append = TRUE)
}

filename = "E:\\My Documents\\DRC\\worktemp\\addresses0220-1-2.txt"
cat(input.df[,1][301:400], file = filename, sep = ",")
cat("\n", file = filename, append = TRUE)
cat(input.df[,2][301:400], file = filename, sep = ",", append = TRUE)

filename = "E:\\My Documents\\DRC\\worktemp\\发币临时文档\\addresses0411-1-1.txt"

cat(input.df[,1][1:len], file = filename, sep = ",")
cat("\n", file = filename, append = TRUE)
cat(input.df[,2][1:len], file = filename, sep = ",", append = TRUE)
