//Commands for Cypher
////Load Data and build nodes////
:auto USING PERIODIC COMMIT 1000 LOAD csv with headers from "file:///all_data.csv" as row merge (i:ingredients{ingredient_text:row.ingredients})
merge (b:brands{brand_text:row.brands})
merge (c:category{category_text:row.category})
merge (p:product{product_text:row.product_name, code:row.code}) return count(i,b,c,p)
////Build First Relation/////
/////UPC --> Ingredients/////
:auto USING PERIODIC COMMIT 1000
LOAD csv with headers from "file:///all_data.csv" as row
match (p:product{product_text:row.product_name, code:row.code})
match (i:ingredients{ingredient_text:row.ingredients})
merge (p)-[r:contain]->(i)
return count(*)

///Brand Relationship///
:auto USING PERIODIC COMMIT 1000
LOAD csv with headers from "file:///all_data.csv" as row
match (p:product{product_text:row.product_name, code:row.code})
match (b:brands{brand_text:row.brands})
merge (b)-[r:owns]->(p)
return count(*)

///Category Relationship///
:auto USING PERIODIC COMMIT 1000
LOAD csv with headers from "file:///all_data.csv" as row
match (p:product{product_text:row.product_name, code:row.code})
match (c:category{category_text:row.category})
merge (c)-[r:encompass]->(p)
return count(*)

////Load Data from Only DSDL////
:auto USING PERIODIC COMMIT 1000 LOAD csv with headers from "file:///all_dsdl_data.csv" as row merge (ic:ingredient_category{ic:row.Ingredient_Name})
merge (an:alt_names{an:row.Alt_names})
////Match alt names with food categories///
:auto USING PERIODIC COMMIT 1000
LOAD csv with headers from "file:///all_dsdl_data.csv" as row
match (ic:ingredient_category{ic:row.Ingredient_Name})
match (an:alt_names{an:row.Alt_names})
merge (ic)-[r:known_as]->(an)
return count(*)
