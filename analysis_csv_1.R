library(gmp)
options(scipen = 100)
options(digits = 10)
voiceURL = "E:\\My Documents\\DRC\\worktemp\\发币临时文档\\社区激励代币.csv"
input.df = read.csv(voiceURL, header = FALSE, colClasses = 'character')
input.df[,2] = paste(input.df[,2], "e18", sep = "")
input.df

len = length(input.df[,2])
len

m = seq(1, 3451, by = 150)
m
n = c(seq(150, len, by = 150), len)
n
for (i in 1:24) {
    filename = paste("E:\\My Documents\\DRC\\worktemp\\发币临时文档\\addresses0411-2-", as.character(i), ".txt", sep = "")
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
