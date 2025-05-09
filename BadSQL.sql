SELECT
    a.productkey AS a,
    c.englishproductname AS c,
    (
        SELECT AVG(salesamount)
        FROM (
            SELECT TOP 10 salesamount
            FROM factinternetsales
            ORDER BY salesordernumber DESC
        ) AS x
    ) AS b,
    (
        SELECT COUNT(DISTINCT customerkey)
        FROM (
            SELECT customerkey
            FROM factinternetsales
            WHERE
                orderquantity
                > (
                    SELECT MAX(orderquantity)
                    FROM (
                        SELECT orderquantity
                        FROM factinternetsales
                        WHERE
                            unitprice
                            > (
                                SELECT MIN(unitprice)
                                FROM factinternetsales
                                WHERE unitprice > 100
                            )
                    ) AS w
                )
        ) AS y
    ) AS d,
    (
        SELECT MAX(totalproductcost)
        FROM (
            SELECT TOP 5 totalproductcost
            FROM factproductinventory
            ORDER BY datekey DESC
        ) AS z
    ) AS e,
    (
        SELECT MIN(orderquantity)
        FROM (
            SELECT orderquantity
            FROM factinternetsales
            WHERE unitprice > 100
        ) AS w
    ) AS f
FROM
    dimproduct AS c
INNER JOIN factinternetsales AS a ON c.productkey = a.productkey
WHERE
    a.orderdatekey BETWEEN 20140101 AND 20141231
    AND a.salesamount
    > (
        SELECT AVG(salesamount)
        FROM factinternetsales
        WHERE orderdatekey BETWEEN 20140101 AND 20141231
    )
GROUP BY
    a.productkey, c.englishproductname, a.totalproductcost
HAVING
    COUNT(a.salesordernumber) > 5
    AND SUM(a.salesamount)
    > (
        SELECT SUM(salesamount) * 0.1
        FROM factinternetsales
        WHERE orderdatekey BETWEEN 20140101 AND 20141231
    )
ORDER BY
    SUM(a.salesamount) DESC, a.productkey
