XPTemplate priority=personal+
XPTemplateDef

XPT where hidden "where condition ...
WHERE `condition^

XPT sel "select * from table "
SELECT `*^ `col2...^`, `column2^`col2...^ FROM `table^ `where...{{^ `:where:^ `}}^; `cursor^

XPT del "delete data from table " 
DELETE FROM `table^ `:where:^ `cursor^

XPT up "update table columns" 
UPDATE `table^ SET `attr...^ `attr^=`value^ `attr...^ `where...{{^ `:where:^ `}}^ ; `cursor^
