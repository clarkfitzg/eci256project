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

associate_chp = function(ch, mile_tol = 1, min_tol = 10)
{
    # ch is one row of chp dataframe
    # We just check if time t and position x are inside (a, b)
    x = ch$Abs_PM
    xa = traffic$Abs_PM_min - mile_tol
    xb = traffic$Abs_PM_max + mile_tol
    t = ch$minute
    ta = traffic$minute_min - mile_tol
    tb = traffic$minute_max + mile_tol
    tr = (traffic$day == ch$day) &
        (xa <= x) &
        (x <= xb) &
        (ta <= t) &
        (t <= tb)
    sumtr = sum(tr)
    if(sumtr == 0){
        return(NA)
    }
    else if(sumtr == 1){
        return(traffic$key[tr])
    }
    else{
        warning("detected multiple events, returning first")
        return(traffic$key[tr][1])
    }
}

links = sapply(split(chp, seq(nrow(chp))), associate_chp)

# Loosening up the tolerances detects around twice as many events.
mean(is.na(links))

# So one detected traffic event had from 7-9 chp incidents associated with it.
table(links)

chp$key = links

linked = merge(chp, traffic, by = "key")
