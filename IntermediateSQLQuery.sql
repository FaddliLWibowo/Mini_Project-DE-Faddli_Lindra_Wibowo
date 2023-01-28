-- 1. Tulis query untuk mendapatkan jumlah customer tiap bulan yang melakukan order pada tahun 1997
SELECT COUNT(CustomerID) AS JumlahCustomer, 
    DATEADD(MONTH, DATEDIFF(MONTH, 0, OrderDate), 0) AS Bulan
FROM Orders 
WHERE OrderDate >= '1997-01-01' AND OrderDate <= '1997-12-31' 
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, OrderDate), 0)

-- 2. Tulis query untuk mendapatkan nama employee yang termasuk Sales Representative
SELECT FirstName, LastName, Title 
FROM Employees 
WHERE Title = 'Sales Representative'

-- 3. Tulis query untuk mendapatkan top 5 nama produk yang quantitynya paling banyak diorder pada bulan Januari 1997
SELECT DISTINCT TOP 5
    x.ProductName,    
    y.Quantity
FROM Products x
INNER JOIN Order_Details y ON x.ProductID = y.ProductID
INNER JOIN Orders z ON y.OrderID = z.OrderID
WHERE z.OrderDate >= '1997-01-01' AND z.OrderDate <= '1997-01-31'
ORDER BY Quantity DESC

-- 4. Tulis query untuk mendapatkan nama company yang melakukan order Chai pada bulan Juni 1997.
SELECT DISTINCT
    x.ProductName,    
    a.CompanyName
FROM Products x
INNER JOIN Order_Details y ON x.ProductID = y.ProductID
INNER JOIN Orders z ON y.OrderID = z.OrderID
INNER JOIN Customers a ON z.CustomerID = a.CustomerID
WHERE z.OrderDate >= '1997-06-01' AND z.OrderDate <= '1997-06-30' AND x.ProductName='Chai'

-- 5. Tulis query untuk mendapatkan jumlah OrderID yang pernah melakukan sales (unit_price dikali quantity) <=100, 100<x<=250, 250<x<=500, dan >500.
SELECT
    y.OrderID, 
    SUM(CASE WHEN (z.UnitPrice * z.Quantity) <= 100 THEN 1 ELSE 0 END) AS '<=100',
    SUM(CASE WHEN (z.UnitPrice * z.Quantity) > 100 AND (z.UnitPrice * z.Quantity) <= 250 THEN 1 ELSE 0 END) AS '100<x<=250',
    SUM(CASE WHEN (z.UnitPrice * z.Quantity) > 250 AND (z.UnitPrice * z.Quantity) <= 500 THEN 1 ELSE 0 END) AS '250<x<=500',
    SUM(CASE WHEN (z.UnitPrice * z.Quantity) > 500 THEN 1 ELSE 0 END) AS '>500',
    COUNT(y.OrderID) AS JumlahOrderID
FROM Orders y
INNER JOIN Order_details z ON y.OrderID = z.OrderID
WHERE y.OrderDate >= '1997-01-01' AND y.OrderDate <= '1997-12-31'
GROUP BY y.OrderID

-- 6. Tulis query untuk mendapatkan Company name yang melakukan sales di atas 500 pada tahun 1997.
SELECT DISTINCT 
    x.CompanyName, 
    COUNT(y.OrderID) AS JumlahOrderID,     
    ROUND(sum(z.UnitPrice * z.Quantity * (1 - z.Discount)), 2) as Sales
FROM Orders y
INNER JOIN Customers x ON y.CustomerID = x.CustomerID
INNER JOIN Order_details z ON y.OrderID = z.OrderID
WHERE y.OrderDate >= '1997-01-01' AND y.OrderDate <= '1997-12-31'
GROUP BY x.CompanyName
HAVING sum(z.UnitPrice * z.Quantity * (1 - z.Discount)) > 500
ORDER BY Sales DESC

-- 7. Tulis query untuk mendapatkan nama produk yang merupakan Top 5 sales tertinggi tiap bulan di tahun 1997.
SELECT Rank, ProductName, Month, ROUND(sum(ProductSales), 0) AS Sales
FROM
(
    SELECT DISTINCT
        y.OrderID, 
        sum(z.UnitPrice * z.Quantity * (1 - z.Discount)) AS ProductSales,
        x.ProductName,
        DATEADD(MONTH, DATEDIFF(MONTH, 0, y.OrderDate), 0) AS Month,
        ROW_NUMBER() OVER(PARTITION BY DATENAME(month, y.OrderDate) ORDER BY sum(z.UnitPrice * z.Quantity * (1 - z.Discount)) DESC) AS Rank
    FROM Orders y
    INNER JOIN Order_details z ON y.OrderID = z.OrderID
    INNER JOIN Products x ON z.ProductID = x.ProductID
    WHERE y.OrderDate >= '1997-01-01' AND y.OrderDate <= '1997-12-31'
    GROUP BY y.OrderID, y.OrderDate, x.ProductName
) AS x
WHERE Rank <= 5
GROUP BY Month, Rank, ProductName 
ORDER BY Month

-- 8. Buatlah view untuk melihat Order Details yang berisi OrderID, ProductID, ProductName, UnitPrice, Quantity, Discount, Harga setelah diskon.
CREATE VIEW OrderDetailsView AS
    SELECT DISTINCT
        y.OrderID,
        x.ProductID,
        x.ProductName,
        z.UnitPrice,
        z.Quantity,
        z.Discount,
        (z.UnitPrice * z.Quantity * (1 - z.Discount)) AS 'DiscountedPrice'
FROM Orders y
INNER JOIN Order_Details z ON y.OrderID = z.OrderID
INNER JOIN Products x ON z.ProductID = x.ProductID;

-- 9. Buatlah procedure Invoice untuk memanggil CustomerID, CustomerName, OrderID, OrderDate, RequiredDate, ShippedDate jika terdapat inputan CustomerID tertentu.
CREATE PROCEDURE Invoice (@customerID INT)AS BEGIN
    SELECT DISTINCT
        x.CustomerID,
        x.CompanyName AS CustomerName,
        y.OrderID,
        y.OrderDate,
        y.RequiredDate,
        y.ShippedDate
    FROM Orders y
INNER JOIN Customers x ON y.CustomerID = x.CustomerID
WHERE x.CustomerID = @customerID;
END
