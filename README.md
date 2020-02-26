# Ingredients-found-in-packaged-foods-database
Repository for packaged foods ingredients database<br>
Create a directory for the data
```bash
$ mkdir -p $HOME/IngreDB/Data
```
Move into that directory
```bash
$ cd IngreDB/Data
```
Download the data directory
```bash
$ wget https://static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv
$ wget https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_branded_food_csv_2019-12-17.zip
$ unzip FoodData_Central_branded_food_csv_2019-12-17.zip
$ wget https://www.dsld.nlm.nih.gov/dsld/downloads/all_lstProducts_csv.zip
$ unzip all_lstProducts_csv.zip
$ wget https://www.dsld.nlm.nih.gov/dsld/downloads/all_lstIngredients_csv.zip
$ unzip all_lstIngredients_csv.zip
```
