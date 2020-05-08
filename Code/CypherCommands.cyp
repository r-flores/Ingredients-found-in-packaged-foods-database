///Commands for Cypher

////Load Data from all Data////
:auto USING PERIODIC COMMIT 1000 LOAD csv with headers from "file:///all_data.csv" as row 
merge (i:ingredients{ingredient_text:row.ingredients})
merge (b:brands{brand_text:row.brands})
merge (c:category{category_text:row.category})
merge (p:product{product_text:row.product_name, code:row.code}) 
merge (a:alternative{almonds:row.alt_almonds, cashews:row.alt_cashews, egg:row.alt_egg, fish:row.alt_fish, hazelnut:row.alt_hazelnuts, milk:row.alt_milk, peanut:row.alt_peanut, shellfish:row.alt_shellfish, soy:row.alt_soy, wheat:row.alt_wheat})
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
//return 5975//

///Category Relationship///
:auto USING PERIODIC COMMIT 1000
LOAD csv with headers from "file:///all_data.csv" as row
match (p:product{product_text:row.product_name, code:row.code})
match (c:category{category_text:row.category})
merge (c)-[r:encompass]->(p)
return count(*)
//return 5975//

////Match alt names with food categories///
:auto USING PERIODIC COMMIT 1000
LOAD csv with headers from "file:///all_data.csv" as row
match (a:alternative{almonds:row.alt_almonds, cashews:row.alt_cashews, egg:row.alt_egg, fish:row.alt_fish, hazelnut:row.alt_hazelnuts, milk:row.alt_milk, peanut:row.alt_peanut, shellfish:row.alt_shellfish, soy:row.alt_soy, wheat:row.alt_wheat})
match (i:ingredients{ingredient_text:row.ingredients})
merge (i)-[r:known_as]->(a)
return count(*)


///Queries for Analysis
match (n:product)-[r:contain]->(i:ingredients)
where i.ingredient_text contains 'corn' and i.ingredient_text contains 'cumin'
return n.product_text, i.ingredient_text
//should return 29 records

match (a:product)-[b:contain]->(n:ingredients)-[r:known_as]->(i:alternative)
where a.product_text contains 'glazed mini donuts'
return i, n.ingredient_text, a.product_text
//Should return 1 record