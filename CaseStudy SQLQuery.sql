-- ==================Mencari RFM=======================
SELECT DISTINCT
    x.OrderID,
	MAX(x.OrderDate) as lastOrderDate_Recency,
	COUNT(*) as countOrder_Frequency,
	AVG(y.UnitPrice) as avgAmount_Monetary,
	CASE 
		WHEN DATEDIFF(DAY, x.OrderDate, '1997-12-01') < 30 THEN '1'
     	WHEN DATEDIFF(DAY, x.OrderDate, '1997-12-01') >= 30 AND DATEDIFF(DAY, x.OrderDate, '1997-12-01') < 60 THEN '2'
     	ELSE '3'
	END AS R,
	CASE
		WHEN COUNT(*) < 2 THEN '3'
    	WHEN COUNT(*) >=2 AND COUNT(*) <4 THEN '2'
       	ELSE '1'
  	END AS F,
	CASE 
		WHEN AVG(y.UnitPrice) < 10 THEN '3'
     	WHEN AVG(y.UnitPrice) >= 10 AND AVG(y.UnitPrice) < 30 THEN '2'
     	ELSE '1'
	END AS M
FROM Orders x
INNER JOIN Order_Details y ON x.OrderID = y.OrderID
WHERE x.OrderDate >= '1997-01-01' AND x.OrderDate <= '1997-12-31'
GROUP BY x.OrderID, x.OrderDate

-- =============20 Produk Termahal===========================
SELECT DISTINCT y.CategoryName, x.ProductName as Expensive_Products, x.UnitPrice
FROM Products AS x
INNER JOIN Categories AS y ON x.CategoryID = y.CategoryID
WHERE 20 >= (SELECT COUNT(DISTINCT UnitPrice)
                    FROM Products AS y
                    WHERE y.UnitPrice >= x.UnitPrice)
ORDER BY UnitPrice desc;


-- =======Produk Out Stock==================================
SELECT x.ProductID, 
    x.ProductName, 
    y.ContactName as SupplierName, 
    y.Phone, 
    x.UnitsInStock, 
    x.UnitsOnOrder, 
    x.Discontinued
FROM Products x
INNER JOIN Suppliers y ON x.SupplierID = y.SupplierID
WHERE UnitsInStock<UnitsOnOrder;

-- =======Mencari Total Penjualan by Kategori=====================
SELECT CategoryName, ROUND(sum(ProductSales), 0) AS CategorySales
FROM
(
    SELECT a.CategoryName, 
        b.ProductName, 
        ROUND(sum(c.UnitPrice * c.Quantity * (1 - c.Discount)), 2) AS ProductSales
    FROM Categories AS a
    INNER JOIN Products AS b ON a.CategoryID = b.CategoryID
    INNER JOIN Order_Details AS c ON b.ProductID = c.ProductID
    INNER JOIN Orders AS d ON d.OrderID = c.OrderID 
    WHERE d.OrderDate >= '1997-01-01' AND d.OrderDate <= '1997-12-31'
    GROUP BY a.CategoryName, 
        b.ProductName
) AS x
GROUP BY CategoryName
ORDER BY CategoryName

-- ==========supplier yang paling banyak memberikan sales========
SELECT CompanyName, ContactName, ROUND(sum(ProductSales), 0) AS Sales
FROM
(
    SELECT DISTINCT
        s.CompanyName,
        s.ContactName,
        p.ProductName,
        ROUND(sum(a.UnitPrice * a.Quantity * (1 - a.Discount)), 0) AS ProductSales
    FROM Suppliers s
    INNER JOIN Products p ON s.SupplierID = p.SupplierID
    INNER JOIN Order_Details a ON p.ProductID = a.ProductID
    INNER JOIN Orders o ON a.OrderID = o.OrderID
    WHERE o.OrderDate >= '1997-01-01' AND o.OrderDate <= '1997-12-31'
    GROUP BY s.SupplierID, s.CompanyName, s.ContactName, p.ProductName
) AS x
GROUP BY CompanyName, ContactName
ORDER BY Sales DESC


-- ==========Kota yang paling banyak memberikan order========
SELECT ShipCity, ShipCountry, CompanyName, ROUND(sum(ProductSales), 0) AS Sales
FROM
(
    SELECT DISTINCT   
        ROUND(sum(z.UnitPrice * z.Quantity * (1 - z.Discount)), 0) as ProductSales,
        COUNT(y.OrderID) AS JumlahOrderID,
        y.ShipCity,
        y.ShipCountry,
        x.CompanyName
    FROM Orders y
    INNER JOIN Customers x ON y.CustomerID = x.CustomerID
    INNER JOIN Order_details z ON y.OrderID = z.OrderID
    WHERE y.OrderDate >= '1997-01-01' AND y.OrderDate <= '1997-12-31'
    GROUP BY y.ShipCity, x.CompanyName, y.ShipCountry
) AS x
GROUP BY CompanyName, ShipCity, ShipCountry
ORDER BY Sales DESC

-- ==========Produk terlaris========
SELECT ProductName, JumlahOrder, ROUND(sum(ProductSales), 0) AS Sales
FROM
(
    SELECT
        y.ProductName,
        ROUND(sum(x.UnitPrice * x.Quantity * (1 - x.Discount)), 0) as ProductSales,
        COUNT(z.OrderID) AS JumlahOrder
    FROM Order_details x
    JOIN Products y ON x.ProductID = y.ProductID
    JOIN Orders z ON x.OrderID = z.OrderID
    WHERE z.OrderDate >= '1997-01-01' AND z.OrderDate <= '1997-12-31'
    GROUP BY y.ProductName 
) AS x
GROUP BY ProductName, JumlahOrder
ORDER BY JumlahOrder DESC

-- ==========Customer yang paling banyak memberikan sales========
SELECT CompanyName, ContactName, JumlahOrderID, ROUND(sum(ProductSales), 0) AS Sales
FROM
(
    SELECT
        x.CompanyName,
        x.ContactName,
        COUNT(y.OrderID) AS JumlahOrderID,   
        ROUND(sum(z.UnitPrice * z.Quantity * (1 - z.Discount)), 0) AS ProductSales
    FROM Orders y
    INNER JOIN Customers x ON y.CustomerID = x.CustomerID
    INNER JOIN Order_details z ON y.OrderID = z.OrderID
    WHERE y.OrderDate >= '1997-01-01' AND y.OrderDate <= '1997-12-31'
    GROUP BY x.CompanyName, x.ContactName
) AS x
GROUP BY CompanyName, ContactName, JumlahOrderID
ORDER BY Sales DESC