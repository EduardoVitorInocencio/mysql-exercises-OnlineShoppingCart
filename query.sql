-- Query to search about Address, Start time and End time whose user id is equal 5
SELECT (streetaddr, startTime, endTime
FROM servicepoint
WHERE servicepoint.city IN (SELECT address.city FROM address WHERE userid = 5))

-- Selecionar todos os produtos que são do tipo laptop
SELECT *
FROM product
WHERE type = 'laptop'

-- Calcular o total de itens salvos no carrinho, cujo o id da loja (sid) é igual a 8
Select SUM(quantity) from save_to_shopping_cart
(SELECT Product.pid from product WHERE sid = 8)


-- Consultar o endereço dos pedidos entregues em 17-02-2017
SELECT name,streetaddr,city from address WHERE addrid IN
(SELECT addrid from deliver_to WHERE `TimeDelivered` = '2017-02-17')

-- Consultar os comentários do produto 12345678
SELECT *
FROM comments WHERE pid = 12345678

-- Insira o id de usuário dos vendedores cujo nome começa com A na tabela comprador (buyer)
INSERT INTO buyer
SELECT * FROM seller
WHERE userid IN (SELECT userid FROM users WHERE name LIKE 'A%');

-- Atualizar o estado de pagamento de pedidos não pagos criados após o ano de 2017 e com valor total superior a 50.
UPDATE Orders
SET paymentState = 'Unpaid'
WHERE creationTime > '2017-01-01' AND totalAmount > 50;



-- Atualize o nome e o telefone de contato do endereço onde o estado é Quebec e a cidade é Montreal.
UPDATE address
SET name = 'Awesome Lady', contactPhoneNumber ='1234567'
WHERE province = 'Quebec' AND city = 'Montreal';

-- Excluir a loja aberta antes do ano de 2017
DELETE FROM save_to_shopping_cart
WHERE addTime < '2017-01-01';

-------------------------------------------- Views --------------------------------------------------------
---------------------- Create view of all products whose price above average price ------------------------
CREATE VIEW Products_Above_Average_Price AS
SELECT pid, name, price 
FROM Product
WHERE price > (SELECT AVG(price) FROM Product);

select * from products_above_average_price;

-- Update the view ***
UPDATE Products_Above_Average_Price
SET price = 1
WHERE pid = 5;

-- Create view of all products sales in 2016.
CREATE VIEW Product_Sales_For_2016 AS
SELECT pid, name, price
FROM Product
WHERE pid IN (SELECT pid FROM OrderItem WHERE itemid IN 
              (SELECT itemid FROM Contain WHERE orderNumber IN
               (SELECT orderNumber FROM Payment WHERE payTime > '2016-01-01' AND payTime < '2016-12-31')
              )
             );

SELECT * FROM product_sales_for_2016;

-- Update the view
UPDATE product_sales_for_2016
SET price = 2
WHERE name = 'GoPro HERO5';

----------------------------------------------Check Constraints-------------------------------------------------
---- Verifique se os produtos salvos no carrinho de compras após o ano de 2017 possuem quantidades menores que 10.
DROP TABLE Save_to_Shopping_Cart;
CREATE TABLE Save_to_Shopping_Cart
(
    userid INT NOT NULL
    ,pid INT NOT NULL
    ,addTime DATE
    ,quantity INT
    ,PRIMARY KEY (userid,pid)
    ,FOREIGN KEY(userid) REFERENCES Buyer(userid)
    ,FOREIGN KEY(pid) REFERENCES Product(pid)
    ,CHECK (quantity <= 10 OR addTime > '2017-01-01')
);

INSERT INTO Save_to_Shopping_Cart VALUES(18,67890123,'2015-02-23',50); -- error
INSERT INTO Save_to_Shopping_Cart VALUES(24,67890123,'2017-02-22',8); -- error
INSERT INTO Save_to_Shopping_Cart VALUES(5,56789012,'2016-10-17',11); -- error


------------------------------- Verifique se o item pedido possui quantidades de 0 a 10
DROP VIEW Product_Sales_For_2016; -- Antes de criar esta visualização, temos que excluí-la antes
DROP TABLE Contain;
CREATE TABLE Contain
(
    orderNumber INT NOT NULL
    ,itemid INT NOT NULL
    ,quantity INT CHECK(quantity > 0 AND quantity <= 10)
    ,PRIMARY KEY (orderNumber,itemid)
    ,FOREIGN KEY(orderNumber) REFERENCES Orders(orderNumber)
    ,FOREIGN KEY(itemid) REFERENCES OrderItem(itemid)
);

INSERT INTO Contain VALUES (76023921,23543245,11); -- error
INSERT INTO Contain VALUES (23924831,65738929,8);