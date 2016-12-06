# Mon Dec  5 15:41:31 PST 2016
#
# Performing the regression

traffic = read.csv("traffic.csv")
chp = read.csv("chp_incidents_80W.csv")

# Put the dates in the same format
traffic$day = gsub(".+([0-9]{4})_([0-9]{2})_([0-9]{2}).+", "\\2/\\3/\\1", traffic$day)
chp$day = gsub("([0-9]{2}/[0-9]{2}/[0-9]{4}).+", "\\1", chp[, 4])

# Add an integer key to see if same traffic event mapped to multiple CHP
# incidents
traffic$key = seq(nrow(traffic))

chp$Abs_PM = chp[, 18]

# For each CHP event check if there's associated traffic.
# Pretty sure there can only be one, but might have to check.

associate_chp = function(ch)
{
    # ch is one row of chp dataframe
    tr = (traffic$day == ch$day) &
        (traffic$Abs_PM_min <= ch$Abs_PM) &
        (ch$Abs_PM <= traffic$Abs_PM) &
        (traffic$minute_min <= ch$minute) &
        (ch$minute <= traffic$minute_min)
    sumtr = sum(tr)
    if(sumtr == 0){
        return(NA)
    }
    else if(sumtr == 1){
        return(traffic$key[tr])
    }
    else{
        stop("detected multiple events")
    }
}

links = apply(chp, 1, associate_chp)
