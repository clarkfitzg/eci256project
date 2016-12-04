# Thu Dec  1 15:12:00 PST 2016

source("helpers.R")

datadir = "~/data/pems/5min"

newdatadir = "~/data/pems/5min80"

file5min = list.files(datadir, full.names = TRUE)

cols = c(Timestamp = 1, Station = 2, Occupancy = 11)

station = read.csv("station80.csv")



writeWB80 = function(fname)
{

    d = read.csv(fname, header = FALSE)

    # I80 West with Mainline station
    #d2 = d[(d[, 4] == 80) & (d[, 5] == "W") & (d[, 6] == "ML"), ]
    # The filtering happened from the stations
    d2 = merge(d, station[, c("ID", "Abs_PM")], by.x = "V2", by.y = "ID")

    d3 = data.frame(Abs_PM = d2$Abs_PM
                    , minute = extract_minutes(d2[, "V1"])
                    , occupancy = d2[, "V11"]
                    )

    #d4 = reshape(d3[order(d3$minute, d3$Abs_PM), ]
    #             , idvar = "Abs_PM"
    #             , timevar = "minute"
    #             , direction = "wide"
    #             )

    #d5 = d4[order(d4$Abs_PM, decreasing = TRUE), ]

    #colnames(d5) = gsub("occupancy\\.", "m", colnames(d5))

    # Just want the date part
    dt = gsub(".+5min_(.+)\\.txt", "\\1", fname)
    newfname = paste0(newdatadir, "/", dt, ".csv")

    write.csv(d3, newfname, row.names = FALSE)
}

fname = file5min[2]

lapply(file5min, writeWB80)
