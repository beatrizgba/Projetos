use restaurant_db;

-- Dá uma olhada na tabela de itens do menu
-- (menu_items)

-- Quantos itens tem no menu no total?
SELECT COUNT(menu_item_id)
FROM menu_items;

-- Quais são os itens mais baratos e os mais caros?
SELECT *
FROM menu_items
ORDER BY price;

SELECT *
FROM menu_items
ORDER BY price DESC;

-- Quantos pratos italianos tem no cardápio? 
SELECT COUNT(category)
FROM menu_items
WHERE category = "Italian";

-- Quais são os pratos italianos mais baratos e os mais caros?
SELECT *
FROM menu_items
WHERE category = "Italian"
ORDER BY price;

SELECT *
FROM menu_items
WHERE category = "Italian"
ORDER BY price DESC;

-- Quantos pratos tem em cada categoria? 
SELECT category, COUNT(category)
FROM menu_items
GROUP BY category;

-- Qual é o preço médio dos pratos por categoria?
SELECT category, COUNT(category) AS TOTAL_ITEMS, AVG(price) AS AVG_PRICE
FROM menu_items
GROUP BY category;

-- Agora, vamos olhar a tabela de detalhes dos pedidos
-- (order_details)

-- Qual o período (data inicial e final) que essa tabela cobre?
SELECT MAX(order_date), MIN(order_date)
FROM order_details;

-- Quantos pedidos foram feitos nesse período? 
SELECT COUNT(DISTINCT(order_id))
FROM order_details;

-- Quantos itens individuais foram vendidos nesse período?
SELECT COUNT(item_id)
FROM order_details;

-- Quais pedidos tiveram a maior quantidade de itens?
SELECT order_id, COUNT(item_id)
FROM order_details
GROUP BY order_id
ORDER BY COUNT(item_id) DESC;

-- Quantos pedidos tiveram mais de 12 itens?
SELECT COUNT(*) FROM
(SELECT order_id, COUNT(item_id)
FROM order_details
GROUP BY order_id
HAVING COUNT(item_id) > 12) AS num_orders;

-- Juntando as tabelas de menu e pedidos em uma só
SELECT *
FROM order_details
JOIN menu_items ON order_details.item_id = menu_items.menu_item_id;

-- Quais foram os itens mais e menos pedidos? E de quais categorias eles são?
SELECT menu_items.item_name, menu_items.category, COUNT(order_details.item_id) AS total_orders
FROM order_details
JOIN menu_items ON order_details.item_id = menu_items.menu_item_id
GROUP BY order_details.item_id;

-- Quais foram os 5 pedidos que geraram o maior faturamento?
SELECT order_details.order_id, sum(menu_items.price) as total_order_price
FROM order_details
JOIN menu_items ON order_details.item_id = menu_items.menu_item_id
GROUP BY order_details.order_id
ORDER BY total_order_price DESC
LIMIT 5;


-- Analisando os detalhes desses 5 pedidos mais caros. O que dá pra notar neles?
SELECT order_id, category, COUNT(item_id) AS num_items
FROM order_details od LEFT JOIN menu_items mi
ON od.item_id = mi.menu_item_id
WHERE order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY order_id, category;