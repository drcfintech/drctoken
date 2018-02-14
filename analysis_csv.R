options(scipen = 10)
voiceURL = "C:\\Users\\rcit-001\\Documents\\工作文档\\DRC\\worktemp\\第一批病毒糖果发送（1846）.csv"
input.df = read.csv(voiceURL, header = FALSE, colClasses = 'character')
input.df[,2] = as.numeric(input.df[,2]) * 1e18
input.df



filename = "C:\\Users\\rcit-001\\Documents\\工作文档\\DRC\\worktemp\\addresses0214-1.txt"
cat(input.df[,1][1:200], file = filename, sep = ",")
cat("\n", file = filename, append = TRUE)
cat(input.df[,2][1:200], file = filename, sep = ",", append = TRUE)

filename = "C:\\Users\\rcit-001\\Documents\\工作文档\\DRC\\worktemp\\addresses0214-8.txt"
cat(input.df[,1][1601:1700], file = filename, sep = ",")
cat("\n", file = filename, append = TRUE)
cat(input.df[,2][1601:1700], file = filename, sep = ",", append = TRUE)

filename = "C:\\Users\\rcit-001\\Documents\\工作文档\\DRC\\worktemp\\addresses0214-9.txt"
len = length(input.df[,2])
len
cat(input.df[,1][1701:len], file = filename, sep = ",")
cat("\n", file = filename, append = TRUE)
cat(input.df[,2][1701:len], file = filename, sep = ",", append = TRUE)
