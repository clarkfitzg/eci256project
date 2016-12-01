# Thu Dec  1 14:02:58 PST 2016
#
# Working quickly now to get freeway incidents

chp = read.csv("~/data/pems/chp/all_text_chp_incidents_month_2016_04.txt"
               , header = FALSE)

chp2 = data.frame(fwy = chp[, 15], dir = chp[, 16], district = chp[, 12])

# How many incidents occurred on I80? If we download 10 days worth and we
# want 100 data points then we need 10 incidents per day.

I80W = (chp2$fwy == 80) & (chp2$dir == "W") & (chp2$district == 4)

# Around 18 incidents per day. OK, that's sufficient.
# But there's 46 collisions which works out to about 1 per
sum(I80W) / 30

chp3 = chp[I80W, ]

chp3$collision = grepl("collision", chp3[, 5], ignore.case = TRUE)

date = sub(".*([0-9]{2}/[0-9]{2}/[0-9]{4}).*", "\\1", chp3[, 4])

chp3$weekday = weekdays(as.Date(date, "%m/%d/%Y"))

table(chp3[, c("weekday", "collision")])

chp3$bizday = !(chp3$weekday %in% c("Saturday", "Sunday"))

# Interesting. More incidents on Friday than other weekdays.
# So we'll grab all the Fridays. Jan 1 2016 was a Friday.

# Actually Tuesday has the second largest number of collisions with 43
# compared to Friday. Might be better to choose this since it won't be
# affected by 3 day weekends.
2 + 0:4 * 7

# How about I just do all weekdays in the first month with no holidays?
# That's April

chp4 = chp3[chp3$collision & chp3$bizday, ]

# In the location we see that many of these are onramp / offramps.
# Might want to remove those.

chp4$onoff = grepl("(onr)|(ofr)", chp4[, 6], ignore.case = TRUE)

write.csv(chp4, "chp_incidents_80W.csv", row.names = FALSE)
