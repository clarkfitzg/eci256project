# Thu Dec  1 15:12:00 PST 2016

datadir = "~/data/pems/5min"

file5min = list.files(datadir, full.names = TRUE)

fname = file5min[1]

cols = c(Timestamp = 1, Station = 2, Occupancy = 11)

station = read.csv("station80.csv")


extract_minutes = function(x){
    ts = as.POSIXct(x, format = "%m/%d/%Y %H:%M:%S")
    hours = as.integer(format(ts, "%H"))
    minutes = as.integer(format(ts, "%M"))
    60L * hours + minutes
}


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

    d4 = reshape(d3
                 , idvar = "Abs_PM"
                 , timevar = "minute"
                 , direction = "wide"
                 )


    newfname = strsplit(fname, "\\.")[[1]]
    newfname = paste(newfname[1], "_WB80.", newfname[2], sep = "")

}
