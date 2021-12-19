# Clear memory and graphics
rm(list = ls());
graphics.off();
# Set environment language
Sys.setenv(lang="us_en"); 
# Set working directory
setwd("F:/UZH/21Fall/Meta-Analysis/R");

# Packages
packs <- c("meta", "metafor", "stargazer", "dplyr", "ggplot2")
# Install packages
lapply(packs, install.packages, character.only = FALSE, repos = "http://cran.us.r-project.org")
# Load packages
lapply(packs, library, character.only = TRUE)



# Read in data
dta <- read.csv("meta.csv")

# Create dummies for South America and for after 2014
dta <- dta %>% 
  mutate(SouthAmerica = (Continent=="South America"), 
         after2014 = (Year>2014))

dta.gen <- metagen(TE = Effect, 
                   seTE = SE, 
                   studlab = Study, 
                   data = dta, 
                   sm = "MD", 
                   method.tau = "DL", 
                   title = "CCT on school attendance")

# Forest plot

forest.meta(dta.gen, 
            sortvar = TE,
            predict = FALSE, 
            print.tau2 = TRUE,
            fixed = TRUE,
            text.fixed = "Fixed effects model",
            random = TRUE,
            leftlabs = c("Study", "TE", "seTE"),
            rightlabs = c("MD", "95%-CI", "Weight\n(fixed)", "Weight\n(random)"))



# Funnel plot

col.contour = c("gray75", "gray85", "gray95")

funnel.meta(dta.gen, xlim = c(-0.1, 0.3),
            contour = c(0.9, 0.95, 0.99),
            col.contour = col.contour,
            studlab = FALSE,
            fixed = FALSE,
            random = TRUE)

legend(x = 0.2, y = 0.005, 
       legend = c("p < 0.1", "p < 0.05", "p < 0.01"),
       fill = col.contour)



# Histogram of t-stat distribution

dta %>% ggplot(aes(x=Effect/SE)) + 
  geom_histogram(aes(y=..density..), bins = 10, 
                 colour="black", fill="white") + 
  stat_function(fun = dnorm,
                args = list(mean = mean(dta$Effect/dta$SE),
                            sd = sd(dta$Effect/dta$SE)), 
                size = 2, aes(colour = "Estimated\nnormal\ndistribution")) + 
  xlab("t-stat") +
  ylab("Density") +
  scale_colour_manual("", values = c("red"))



mean(dta$Effect/dta$SE)
sd(dta$Effect/dta$SE)



# Effect dependency on SE

mod1 = lm(Effect ~ SE, data = dta)
summary(mod1) # The intercept is an estimate for the true effect
stargazer(mod1)

dta %>% ggplot(aes(x=SE, y=Effect)) + 
  geom_point(size = 2) +
  geom_smooth(method = "lm", se = FALSE, colour = "red") +
  xlab("Standard Error") +
  ylab("Effect") +
  xlim(0.00, 0.125) +
  theme_bw()



# p-curve

# vpcurve(dta.gen)



# Other attempts at isolating the real effect

mod2 = lm(Effect ~ SE + SouthAmerica, data = dta)
summary(mod2) # The intercept is an estimate for the true effect
stargazer(mod1, mod2)

mod3 = lm(Effect ~ SE + after2014, data = dta)

mod4 = lm(Effect ~ SE + SouthAmerica + after2014, data = dta)

stargazer(mod1, mod2, mod3, mod4, omit.stat = c("f", "ser"))

