# Thu Dec  1 15:12:00 PST 2016

datadir = "~/data/pems/5min"

file5min = list.files(datadir, full.names = TRUE)

fname = file5min[1]

cols = c(Timestamp = 1, Station = 2, Occupancy = 11)

writeWB80 = function(fname)
{

    d = read.csv(fname, header = FALSE)

    # I80 West with Mainline station
    d2 = d[(d[, 4] == 80) & (d[, 5] == "W"), ]

    newfname = strsplit(fname, "\\.")[[1]]
    newfname = paste(newfname[1], "_WB80.", newfname[2], sep = "")

}
