# Set working directory
setwd("F:/UZH/21Fall/UST/Data"); 

# Set environment language
Sys.setenv(lang = "us_en"); 

# Clear working directory
rm(list=ls()); 

# Clear graphics
graphics.off()

# Load packages
library(stargazer)
library(plm)
library(reshape2)
library(ggplot2)
library(dplyr)
library(lmtest)
library(sandwich)
library(xtable)
library(latex2exp)

# Export summary tables in latex
stations <- read.csv('stations.csv')
samples <- read.csv('samples.csv')

stations1 <- stations[, c(4, 8:20)]
names(stations1) <- c("station_name", "station_id", "community_id", "community", 
                     "2010", "2011", "2012", "2013", "2014", 
                     "2015", "2016", "2017", "2018", "2019")

names(samples) <- c("sampling_id", "coordinate_x", "coordinate_y", 
                    "2010", "2011", "2012", "2013", "2014", 
                    "2015", "2016", "2017", "2018", "2019")

xtable(stations1)
xtable(samples)

# Data preprocessing
stations <- stations[, 11:20]
samples <- samples[, 4:13]

names(stations) <- as.factor(2010:2019)
names(samples) <- as.factor(2010:2019)

stations <- cbind(id=1:16, stations)
samples <- cbind(id=17:32, samples)

stations$station <- 1
samples$station <- 0

crime <- rbind(stations, samples)
crime <- melt(crime, id.vars = c("id", "station"))
names(crime) <- c("id", "station", "year", "crime")

# Write in csv file
write.csv(x=long, file="crime.csv", row.names=FALSE)

##--------------------------------------------------------

# Data analysis
d.crime <- read.csv("crime.csv")
d.crime$year <- as.factor(d.crime$year)
d.crime$station <- as.factor(d.crime$station)
d.crime$lncrime <- log(d.crime$crime)

model1 <- lm(crime ~ station, data=d.crime)
model2 <- lm(lncrime ~ station, data=d.crime)
stargazer(model1, model2, keep.stat=c("n", "rsq"), header=F)

par(mfrow=c(2, 2))
plot(model2)
graphics.off()

# Data visualization
ate <- rep(0, 10)
se <- rep(0, 10)
models <- vector("list", 10)
for (i in 1:10) {
  indicator <- d.crime$year == (2009+i)
  lm.fit <- lm(lncrime ~ station, data=d.crime, subset=indicator)
  ate[i] <- coef(summary(lm.fit))[2, 1]
  se[i] <- coef(summary(lm.fit))[2, 2]
  models[[i]] <- lm.fit
}
se.bands <- cbind(ate+2*se, ate-2*se) # 95% confidence interval

plot(2010:2019, ate, xlab="Year", ylab=TeX("$\\log Y_1 - \\log Y_0$"), ylim=c(0.0, 1.5))
lines(2010:2019, ate, lwd=2, col=2)
abline(h=0, col=5, lwd=3)
matlines(2010:2019, se.bands, lwd=1, col=2, lty=3)
legend(x="topleft", legend=c("Effect", "95% CI", "Zero"), 
       lty=c(1, 3, 1), col=c(2, 2, 5), lwd=c(2, 1, 3))

# ggplot
d.plot <- d.crime %>% 
  group_by(station, year) %>% 
  summarise(lncrime=mean(lncrime), .groups="drop")

ggplot(d.plot, aes(x=year, y=lncrime), group=station) + 
  geom_line(aes(color=station, group=station)) + 
  geom_point(aes(color=station)) + 
  # geom_smooth(aes(color=station, group=station)) + 
  xlab("Year") + ylab(TeX("$\\log Y$")) +
  scale_color_manual(values=c("red", "blue")) +
  theme_minimal()

# Print table
stargazer(models, keep.stat=c("n", "rsq"), header=F, model.numbers=F, 
          column.labels=as.character(2010:2019), font.size="tiny", no.space=T)
