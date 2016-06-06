# Packages
library(readr) ; library(plyr) ; library(lattice) ; library(knitr) ; library(ggplot2)

# Data Processing
fileUrl <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
download.file(fileUrl, "./data/StormData.csv.bz2")
fpath <- file.path("./data")
filelist <- list.files(fpath, recursive = TRUE)
filelist
fileName <- "./data/StormData.csv.bz2"

stormData <- read.csv(fileName)
head(stormData)
rows <- nrow(stormData) ; cols <- ncol(stormData)
rows ; cols

# extracting events for property damage, injuries, and fatalities
eventData <- c("EVTYPE", "FATALITIES", "INJURIES", "PROPDMG", "PROPDMGEXP", "CROPDMG", "CROPDMGEXP")
myData <- stormData[eventData]

# property damage
unique(myData$PROPDMGEXP)

# assign value to property exponent
myData$PROPEXP[myData$PROPDMGEXP == "K"] <- 1000
myData$PROPEXP[myData$PROPDMGEXP == "M"] <- 1e+06
myData$PROPEXP[myData$PROPDMGEXP == ""] <- 1
myData$PROPEXP[myData$PROPDMGEXP == "B"] <- 1e+09
myData$PROPEXP[myData$PROPDMGEXP == "m"] <- 1e+06
myData$PROPEXP[myData$PROPDMGEXP == "0"] <- 1
myData$PROPEXP[myData$PROPDMGEXP == "5"] <- 1e+05
myData$PROPEXP[myData$PROPDMGEXP == "6"] <- 1e+06
myData$PROPEXP[myData$PROPDMGEXP == "4"] <- 10000
myData$PROPEXP[myData$PROPDMGEXP == "2"] <- 100
myData$PROPEXP[myData$PROPDMGEXP == "3"] <- 1000
myData$PROPEXP[myData$PROPDMGEXP == "h"] <- 100
myData$PROPEXP[myData$PROPDMGEXP == "7"] <- 1e+07
myData$PROPEXP[myData$PROPDMGEXP == "H"] <- 100
myData$PROPEXP[myData$PROPDMGEXP == "1"] <- 10
myData$PROPEXP[myData$PROPDMGEXP == "8"] <- 1e+08

# handling invalid data
myData$PROPEXP[myData$PROPDMGEXP == "+"] <- 0
myData$PROPEXP[myData$PROPDMGEXP == "-"] <- 0
myData$PROPEXP[myData$PROPDMGEXP == "?"] <- 0

# calculate property damage
myData$PROPDMGVAL <- myData$PROPDMG * myData$PROPEXP

# exploring the crop exponent data
unique(myData$CROPDMGEXP)

# assign values to crop xponents
myData$CROPEXP[myData$CROPDMGEXP == "M"] <- 1e+06
myData$CROPEXP[myData$CROPDMGEXP == "K"] <- 1000
myData$CROPEXP[myData$CROPDMGEXP == "m"] <- 1e+06
myData$CROPEXP[myData$CROPDMGEXP == "B"] <- 1e+09
myData$CROPEXP[myData$CROPDMGEXP == "0"] <- 1
myData$CROPEXP[myData$CROPDMGEXP == "k"] <- 1000
myData$CROPEXP[myData$CROPDMGEXP == "2"] <- 100
myData$CROPEXP[myData$CROPDMGEXP == ""] <- 1

# handling invalid data
myData$CROPEXP[myData$CROPDMGEXP == "?"] <- 0

# calculate crop damage
myData$CROPDMGVAL <- myData$CROPDMG * myData$CROPEXP

# totals by events
fatality <- aggregate(FATALITIES ~ EVTYPE, myData, FUN = sum)
injury <- aggregate(INJURIES ~ EVTYPE, myData, FUN = sum)
propDamag <- aggregate(PROPDMGVAL ~ EVTYPE, myData, FUN = sum)
cropDamag <- aggregate(CROPDMGVAL ~ EVTYPE, myData, FUN = sum)

# highest fatalities
fatalsTop10 <- fatality[order(-fatality$FATALITIES), ][1:10, ]

# highest injuries
injuryTop10 <- injury[order(-injury$INJURIES), ][1:10, ]

# plots of Top 10s
par(mfrow = c(1, 2), mar = c(12, 4, 3, 2), mgp = c(3, 1, 0), cex = 0.8)

barplot(fatalsTop10$FATALITIES, las = 3, names.arg = fatalsTop10$EVTYPE, main = "Top 10 Events-Highest Fatalities", 
        ylab = "Number of Fatalities", col = "red")

barplot(injuryTop10$INJURIES, las = 3, names.arg = injuryTop10$EVTYPE, main = "Top 10 Events-Highest Injuries", 
        ylab = "Number of Injuries", col = "orange")


# Finding events with highest property damage
propDamag10 <- propDamag[order(-propDamag$PROPDMGVAL), ][1:10, ]
# Finding events with highest crop damage
cropDamag10 <- cropDamag[order(-cropDamag$CROPDMGVAL), ][1:10, ]

par(mfrow = c(1, 2), mar = c(12, 4, 3, 2), mgp = c(3, 1, 0), cex = 0.8)

barplot(propDamag10$PROPDMGVAL/(10^9), las = 3, names.arg = propDamag10$EVTYPE, main = "Events with Highest Property Damage", 
        ylab = "Costs ($ Bil)", col = "darkgreen")

barplot(cropDamag10$CROPDMGVAL/(10^9), las = 3, names.arg = cropDamag10$EVTYPE, main = "Events With Highest Crop Damage", 
        ylab = "Costs ($ Bil)", col = "blue")

