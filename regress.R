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

# Computed columns
chp$type = chp$V5
traffic$Abs_PM_total = traffic$Abs_PM_max - traffic$Abs_PM_min
traffic$minute_total = traffic$minute_max - traffic$minute_min

traffic$Abs_PM_mean = rowMeans(cbind(traffic$Abs_PM_max, traffic$Abs_PM_min))
traffic$minute_mean = rowMeans(cbind(traffic$minute_max, traffic$minute_min))

traffic$bbox_area = with(traffic, Abs_PM_total * minute_total)

# Suppose we only look at large traffic events
#traffic = traffic[traffic$bbox_area >= 60, ]

chp$Abs_PM = chp[, 18]

chp$rush_hour = (6 * 60 < chp$minute) & (10 * 60 < chp$minute)
chp$busy_area = chp$Abs_PM < 15

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

# We're being sloppy with about 8 warnings, no big deal.
links = sapply(split(chp, seq(nrow(chp))), associate_chp)

# Loosening up the tolerances detects around twice as many events, ie we
# can associate about 17% of the CHP incidents with the easily detectable
# traffic events we found.
bp = c(chp = mean(!is.na(links)))

# Conversely, about 24% of the traffic events have associated CHP incidents
traffic$has_incident = traffic$key %in% links
bp["traffic"] = mean(traffic$has_incident)

pdf("percent_events.pdf")

barplot(100 * bp, main = "Percentage of events associated", ylim = c(0, 100))

dev.off()

# One detected traffic event had from 7-9 chp incidents associated with it.
table(links)

chp$key = links

# Not totally sure if we should be taking all of them here
linked = merge(chp, traffic, by = "key", all.x = TRUE, all.y = FALSE)

# Check the relationship between pixels and actual area
fit_pix = lm(pixels ~ bbox_area, linked)
# Looks like excellent linear relationship, so lets just use bbox_area
# since it has units, unlike pixels

keeper_cols = c("bbox_area")

# Assume it's 0 if we didn't find anything
linked[is.na(linked[, keeper_cols[1]]), keeper_cols] = 0

# Interesting negative result:
# There's no evidence that the type of incident influences the area of the
# impact.
fit1 = lm(bbox_area ~ collision, linked)

summary(fit1)

# We can do descriptive statistics and say things about the pixels now.
# What is the difference between traffic events associated with CHP
# incidents and those which are not? Might be good to do this as a logistic
# regression.
fit2 = lm(bbox_area ~ has_incident, traffic)


# This is an intuitive result, it says that events with larger impacts are
# more likely to be associated with a CHP traffic incident.
fit2b = glm(has_incident ~ bbox_area, traffic, family = "binomial")

summary(fit2b)

confint(fit2b)

pdf("logistic.pdf")

with(traffic, plot(bbox_area, has_incident
     , main = "Fitted Logistic Regression Curve"))
xy = data.frame(x = traffic$bbox_area, y = fitted(fit2b))
xy = xy[order(xy$x), ]
lines(xy$x, xy$y, col = "red")

dev.off()

# So a delay over 0.5 mile for 20 minutes will increase the odds that
# there was an associated CHP incident by 1.13.
exp(0.5 * 20 * coef(fit2b)['bbox_area'])

# And if there's a traffic incident affecting traffic for 3 miles and 2
# hours then there's a 90% chance that it will be associated with a CHP
# event.
predict(fit2b, data.frame(bbox_area = 3 * 120), type = "response")

# bbox_area of 240 corresponds to an event affecting
# 1 hour and 4 miles of highway
250 / 60

# 67% here affect an area less than 1 mile for 1 hour
mean(traffic$bbox_area < 60)

# Not seeing any relationship here
fit3 = lm(bbox_area ~ type, linked)
summary(fit3)

# So offramp doesn't seem to affect this
fit4 = lm(has_incident ~ onoff, linked)
summary(fit4)

pdf("pointplot.pdf")
with(chp, plot(minute, Abs_PM), type = "point")
with(traffic, points(minute_mean, Abs_PM_mean, pch = 2))
legend("topright", pch = 1:2
       , legend = c("CHP incidents", "traffic events")
       , bg = "white"
       )
dev.off()


# No relationship here
fit5 = glm(has_incident ~ rush_hour + busy_area, linked, family = "binomial")
summary(fit5)

# This shows something, but it could be an artifact of detecting too many
# traffic events in the busy area
# Appears to be a large increase in the impact during regions of high
# traffic
fit6 = lm(bbox_area ~ rush_hour * busy_area, linked)
summary(fit6)

# Possibly the most non normal residual ever seen
#plot(fit6)

linked$logbbox_area = log(linked$bbox_area + 1)
fit7 = lm(logbbox_area ~ rush_hour * busy_area, linked)
summary(fit7)

# Also crazy
#plot(fit7)

# Mile resolution
with(traffic, median(diff(sort(unique(c(Abs_PM_max, Abs_PM_min))))))


