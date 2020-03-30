setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(readr)
library(plyr)
library(dplyr)
library(stringr)
library(data.table)
####Data Download####
download.file("https://static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv", "OFF.csv")
download.file("https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_branded_food_csv_2019-12-17.zip", "FDC.zip")
download.file("https://www.dsld.nlm.nih.gov/dsld/downloads/all_lstIngredients_csv.zip", "DSDL.zip")

###Read in OFF Data###
OFF_data <- read_delim("OFF.csv", "\t", escape_double = FALSE, trim_ws = TRUE)

###Read in FDC Data###
FDC_data <- read.csv(unz("FDC.zip", "branded_food.csv"), header = TRUE, sep = ",")

###Read in DSDL Data###
DSDL_data <- read.csv(unz("DSDL.zip", "lstIngredients.csv"), header = TRUE, sep = ',', skip = 4)

###Select Colnums###
OFF_data <- subset(OFF_data, select = c(1, 8, 13, 15, 34, 35))
###We limit Data to united states for compatability###
OFF_data <- subset(OFF_data, countries_en == "United States")
OFF_data <- subset(OFF_data, select = -c(5))
FDC_data <- subset(FDC_data, select = c(3, 4, 2, 8))

###Make all text lowercase###
OFF_data$product_name <- tolower(OFF_data$product_name)
OFF_data$brands <- tolower(OFF_data$brands)
OFF_data$categories <- tolower(OFF_data$categories)
OFF_data$ingredients_text <- tolower(OFF_data$ingredients_text)
FDC_data$ingredients <- tolower(FDC_data$ingredients)
FDC_data$brand_owner <- tolower(FDC_data$brand_owner)
FDC_data$branded_food_category <- tolower(FDC_data$branded_food_category)

#####Merge OpenFoodFacts Data with FoodDataCentral Data#####
OFF_data = rename(OFF_data, c("ingredients" = "ingredients_text"))
FDC_data = rename(FDC_data, c("code"="gtin_upc", "brands" = "brand_owner", "categories" = "branded_food_category"))
OFF_Data_Temp <- subset(OFF_data, select = c(1, 2))
OFF_data <- subset(OFF_data, select = c(1, 5, 3, 4))

all_Data <- merge(FDC_data, OFF_data, by=c('code'), all.x = T)
###Replace all blanks with NA###
all_Data[all_Data=='']<-NA
###merge both ingredient colnums with FDC taking priority and overwritting NA when possible
all_Data$ingredients <- ifelse(is.na(all_Data$ingredients.x), all_Data$ingredients.y, all_Data$ingredients.x)
all_Data <- subset(all_Data, select = c(1, 8, 3, 4, 6, 7))
###merge both band colnums same as ingredients
all_Data$brands <- ifelse(is.na(all_Data$brands.x), all_Data$brands.y, all_Data$brands.x)
all_Data <- subset(all_Data, select = c(1, 2, 7, 4, 6))
###merge both category colnums same as ingredients###
all_Data$category <- ifelse(is.na(all_Data$categories.x), all_Data$categories.y, all_Data$categories.x)
all_Data <- subset(all_Data, select = c(1, 2, 3, 6))
all_Data$ingredients <- gsub('ingredients: ', '', all_Data$ingredients)
###merge products name back to total data###
all_Data <- merge(all_Data, OFF_Data_Temp, by=c('code'), all.x = T)

####Handeling DSDL Data####
DSDL_data <- subset(DSDL_data, select = c(1, 3))
DSDL_data <- DSDL_data %>% rename("Alt_names" = "Different.spelling.or.synonyms...for.Primary.Ingredient.Group.ID..GRP_ID.")
DSDL_data[DSDL_data=='']<-NA
DSDL_data <- na.omit(DSDL_data)

####reduce the DSDL data to terms associated with the top 8 allergens####
# Milk, Eggs, Fish, shellfish, Tree Nuts, Peanuts, Wheat, soy
## Using parital matching

test_DSDL <- DSDL_data[grep("\"MILK\"", DSDL_data$Alt_names),]
test_DSDL$Ingredient.Name <- "MILK"
all_DSDL_Data <- test_DSDL[!duplicated(test_DSDL$Alt_names),]
test_DSDL <- DSDL_data[grep("\"PEANUT\"", DSDL_data$Alt_names),]
test_DSDL$Ingredient.Name <- "PEANUT"
test_DSDL <- test_DSDL[!duplicated(test_DSDL$Alt_names),]
all_DSDL_Data <- rbind(all_DSDL_Data, test_DSDL)
# FIsh and shellfish fell into the same category
test_DSDL <- DSDL_data[grep("\"FISH\"", DSDL_data$Alt_names),]
test_DSDL$Ingredient.Name <- "FISH"
test_DSDL <- test_DSDL[!duplicated(test_DSDL$Alt_names),]
all_DSDL_Data <- rbind(all_DSDL_Data, test_DSDL)

test_DSDL <- DSDL_data[grep("\"SHELLFISH\"", DSDL_data$Alt_names),]
test_DSDL$Ingredient.Name <- "SHELLFISH"
test_DSDL <- test_DSDL[!duplicated(test_DSDL$Alt_names),]
all_DSDL_Data <- rbind(all_DSDL_Data, test_DSDL)

test_DSDL <- DSDL_data[grep("\"EGG\"", DSDL_data$Alt_names),]
test_DSDL$Ingredient.Name <- "EGG"
test_DSDL <- test_DSDL[!duplicated(test_DSDL$Alt_names),]
all_DSDL_Data <- rbind(all_DSDL_Data, test_DSDL)

test_DSDL <- DSDL_data[grep("\"WHEAT\"", DSDL_data$Alt_names),]
test_DSDL$Ingredient.Name <- "WHEAT"
test_DSDL <- test_DSDL[!duplicated(test_DSDL$Alt_names),]
all_DSDL_Data <- rbind(all_DSDL_Data, test_DSDL)

test_DSDL <- DSDL_data[grep("\"SOY\"", DSDL_data$Alt_names),]
test_DSDL$Ingredient.Name <- "SOY"
test_DSDL <- test_DSDL[!duplicated(test_DSDL$Alt_names),]
all_DSDL_Data <- rbind(all_DSDL_Data, test_DSDL)
# Tree nutsd have too many names to fall into the term TREE NUT therefor I will take common tree nuts
test_DSDL <- DSDL_data[grep("\"CASHEWS\"", DSDL_data$Alt_names),]
test_DSDL$Ingredient.Name <- "CASHEWS"
test_DSDL <- test_DSDL[!duplicated(test_DSDL$Alt_names),]
all_DSDL_Data <- rbind(all_DSDL_Data, test_DSDL)
test_DSDL <- DSDL_data[grep("\"ALMONDS\"", DSDL_data$Alt_names),]
test_DSDL$Ingredient.Name <- "ALMONDS"
test_DSDL <- test_DSDL[!duplicated(test_DSDL$Alt_names),]
all_DSDL_Data <- rbind(all_DSDL_Data, test_DSDL)
test_DSDL <- DSDL_data[grep("\"HAZELNUTS\"", DSDL_data$Alt_names),]
test_DSDL$Ingredient.Name <- "HAZELNUTS"
test_DSDL <- test_DSDL[!duplicated(test_DSDL$Alt_names),]
all_DSDL_Data <- rbind(all_DSDL_Data, test_DSDL)

####Data cleaning on DSDL####
all_DSDL_Data$Ingredient.Name <- tolower(all_DSDL_Data$Ingredient.Name)
all_DSDL_Data$Alt_names <- tolower(all_DSDL_Data$Alt_names)



####remove any row with NA####
##This will significantlly reduce the number of entries may or may not be final Mainly for testing purposes as of now###
all_Data <- na.omit(all_Data)

####Write CSV####
write.csv(all_Data, "all_data.csv", row.names = TRUE)
write.csv(all_DSDL_Data, "all_dsdl_data.csv", row.names = TRUE)