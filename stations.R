s = read.table("~/data/pems/d04_text_meta_2016_10_05.txt"
                     , sep = "\t"
                     , header = TRUE
                     , quote = ""
                     )

# I80 West with Mainline station
s2 = s[(s$Fwy == 80) & (s$Dir == "W") & (s$Type == "ML"), ]

write.csv(s2, "station80.csv", row.names = FALSE)
