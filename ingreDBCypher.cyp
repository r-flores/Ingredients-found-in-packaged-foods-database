LOAD csv with headers from "file:///small_branded_food.csv" as row
merge (u:UPC {UPcode:row.gtin_upc})
return count(u)

LOAD csv with headers from "file:///small_branded_food.csv" as row
merge (i:ingredients {inge_text:row.ingredients})
return count(i)

LOAD csv with headers from "file:///small_branded_food.csv" as row
match (u:UPC {UPcode:row.gtin_upc})
match (i:ingredients {inge_text:row.ingredients})
merge (u)-[r:Contain]->(i)
return count(*)