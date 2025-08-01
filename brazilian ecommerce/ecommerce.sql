


-- criar um novo banco no sentido de aplicar o que representa cada coluna (numeric, etc)
-- depois usar o codigo conforme o curso 


-- 1 tabela de criacao 

select
	top 10 *
from [dbo].[olist_customers_dataset]

-- se tem 0 na frente é tipo texto 

-- action: atual - real. tabela final 
-- fact: de fato. 

-- INT - inteiro
-- texto: NVARCHAR

create table tb_act_olist_customers_dataset
(
	customer_id			           nvarchar(150),
	customer_unique_id             nvarchar(150),
	customer_zip_code_prefix       nvarchar(15),
	customer_city                  nvarchar(100),
	customer_state                 nvarchar(2)
)


select 
	*
from tb_act_olist_customers_dataset





insert into tb_act_olist_customers_dataset
select 
	*
from [dbo].[olist_customers_dataset]

-- nao pode rodar 2x se nao vai duplicar


select 
	*
from tb_act_olist_customers_dataset




























-- 2 tabela de criacao 


select
	top 10 *
from [dbo].[olist_geolocation_dataset]






create table tb_act_olist_geolocation
(
	geolocation_zip_code_prefix nvarchar(8),
	geolocation_lat nvarchar(100),
	geolocation_lng nvarchar (100),
	geolocation_city nvarchar (100),
	geolocation_state nvarchar (2)
)



-- percentual e dinheiro por ponto: float
-- int: 1,2, 3 etc
-- date ou datetime: data






select 
	*
from tb_act_olist_geolocation





insert into tb_act_olist_geolocation
select 
	*
from [dbo].[olist_geolocation_dataset]


-- nao pode rodar 2x se nao vai duplicar


select 
	*
from tb_act_olist_geolocation

























-- 3 tabela de criacao 


select
	top 10 *
from [dbo].[olist_order_items_dataset]


create table  tb_act_olist_order_items
(
	order_id nvarchar(100),
	order_item_id int,
	product_id nvarchar(100),
	seller_id nvarchar(100),
	shipping_limit_date datetime,
	price float,
	freight_value float
)



select
	*
from tb_act_olist_order_items




insert into tb_act_olist_order_items
select
	*
from [dbo].[olist_order_items_dataset]




select 
	*
from tb_act_olist_order_items

























-- 4 tabela de criacao 


select
	top 10 *
from [dbo].[olist_order_payments_dataset]

create table tb_act_olist_order_payments
(
	order_id nvarchar(50),
	payment_sequential int,
	payment_type nvarchar(50),
	payment_installments int,
	payment_value float
)


select
	*
from tb_act_olist_order_payments




insert into tb_act_olist_order_payments
select
	*
from [dbo].[olist_order_payments_dataset]





select 
	*
from tb_act_olist_order_payments




























-- 5 tabela de criacao 


select
	top 10 *
from [dbo].[olist_order_reviews_dataset]


create table tb_act_olist_order_reviews
(
	review_id varchar(50),
	order_id varchar(50),
	review_score int,
	review_comment_title varchar(300),
	review_comment_message varchar(300),
	review_creation_date datetime,
	review_answer_timestamp datetime
)




select
	*
from tb_act_olist_order_reviews


insert into tb_act_olist_order_reviews
select
	*
from [dbo].[olist_order_reviews_dataset]




select 
	*
from tb_act_olist_order_reviews
































-- 6 tabela de criacao 

select 
	top 10 *
from [dbo].[olist_orders_dataset]

-- 99.441 linhas

create table tb_act_olist_orders
(
	order_id varchar(50),
	customer_id varchar(50),
	order_status varchar(15),
	order_purchase_timestamp datetime,
	order_approved_at datetime,
	order_delivered_carrier_date datetime,
	order_delivered_customer_date datetime,
	order_estimated_delivery_date datetime
)



select
	*
from tb_act_olist_orders

select 
	*
from [dbo].[olist_orders_dataset]



insert into tb_act_olist_orders
select 
	*
from [dbo].[olist_orders_dataset]




select 
	*
from tb_act_olist_orders




-- 99.441





























-- 7 tabela de criacao 


select
	top 10 *
from [dbo].[olist_products_dataset]

-- 32.951 linhas 


create table tb_act_olist_products
(
	product_id nvarchar(50),
	product_category_name nvarchar(100),
	product_name_lenght int,
	product_description_lenght int,
	product_photos_qty int,
	product_weight_g int,
	product_length_cm int,
	product_height_cm int,
	product_width_cm int
)



select 
	*
from tb_act_olist_products

select 
	*
from [dbo].[olist_products_dataset]



insert into tb_act_olist_products
select 
	*
from [dbo].[olist_products_dataset]




select 
	*
from tb_act_olist_products



-- 32951

























-- 8 tabela de criacao 

select 
	*
from [dbo].[olist_sellers_dataset]


-- 3.095 linhas 


create table tb_act_olist_sellers
(
	seller_id nvarchar(50),
	seller_zip_code_prefix nvarchar(15),
	seller_city nvarchar(100),
	seller_state nvarchar(2)
)

select
	*
from tb_act_olist_sellers

select
	*
from [dbo].[olist_sellers_dataset]


insert into tb_act_olist_sellers
select
	*
from [dbo].[olist_sellers_dataset]


-- 3095
















































-- VIEW 3 

create view vw_percentual_categorias_por_vendedor
as 

-- 1) percentual de categorias mais vendidas por vendedor 


-- 1. CTE 'sellers': calcula o valor total vendido por vendedor e categoria


with sellers as (

	SELECT
    t1.seller_id,
    t2.product_category_name,
    SUM(t1.price + t1.freight_value) AS valor_total
FROM tb_act_olist_order_items t1
LEFT JOIN tb_act_olist_products t2
    ON LTRIM(RTRIM(t1.product_id)) = LTRIM(RTRIM(t2.product_id)) -- remove espaços a direita e a esquerda 
GROUP BY t1.seller_id, t2.product_category_name



-- tb_act_olist_order_items - informacao dos vendedores 
-- tenho o seller_id e o valor total. Pq o valor total? 
-- percentual: o valor vendido em construcao dividido pelo valor total, por ex 

-- tabela que tem as categorias: [dbo].[tb_act_olist_products]

-- uma linha para o vendedor de venda em cada categoria - granuralidade diferentes 

),

-- 2. CTE 'tratamento': transforma as categorias em colunas específicas

tratamento as (

-- categorizar as categorias que precisam e o valor de venda d ecada uma dessas categorias por vendedor 

select
	seller_id,
	sum(case when product_category_name like '%alimentos%' then valor_total else 0 end) as alimentos, 
	sum(case when product_category_name like '%construcao%' then valor_total else 0 end) as construcao, 
	sum(case when product_category_name like '%eletrodomesticos%' then valor_total else 0 end) as eletrodomesticos, 
	sum(case when product_category_name like '%fashion%' then valor_total else 0 end) as fashion, 
	sum(case when product_category_name like '%livros%' then valor_total else 0 end) as livros, 
	sum(case when product_category_name like '%moveis%' then valor_total else 0 end) as moveis, 
	sum(case when product_category_name like '%telefonia%' then valor_total else 0 end) as telefonia,
	sum(case when product_category_name not like '%alimentos%'
		and product_category_name not like '%construcao%'
		and product_category_name not like '%eletrodomesticos%'
		and product_category_name not like '%fashion%'
		and product_category_name not like '%livros%'
		and product_category_name not like '%moveis%'
		and product_category_name not like '%telefonia%'
then valor_total
else 0
end) as outros 
from sellers 

group by seller_id

),

-- 3. CTE 'valor_total': valor total vendido por vendedor


-- aqui eu tinha varias linhas para um unico vendedor 

valor_total as (

select 
	seller_id,
	sum(valor_total) as valor_total
from sellers

group by seller_id

),

-- 4. CTE 'percentual': calcula o percentual de vendas por categoria

percentual as (

-- quero uma linha pra cada vendedor 
-- preciso do percentual
-- independnete do produto, que conste em uma linha apenas 


select
	t1.seller_id,
	round((t1.alimentos / t2.valor_total) * 100, 2) as alimentos,
	round((t1.construcao / t2.valor_total) * 100 ,2) as construcao,
	round((t1.eletrodomesticos / t2.valor_total) * 100 ,2) as eletrodomesticos,
	round((t1.fashion / t2.valor_total) * 100 ,2) as fashion, 
	round((t1.livros / t2.valor_total) * 100 ,2) as livros, 
	round((t1.moveis / t2.valor_total) * 100 ,2) as moveis,
	round((t1.telefonia / t2.valor_total) * 100 ,2) as telefonia,
	round((t1.outros / t2.valor_total) * 100 ,2) as outros
from tratamento as t1

left join valor_total as t2
on t1.seller_id = t2.seller_id


-- agora é pegar cada coluna, dividir pelo valor total que terei o percentual 
-- round: quanats casas decimais

) 

-- Resultado final da view

select 
	*
from percentual


-- AQUI TERMINA A CTE ###################################################################################################################################################



-- TABLE VIEW da CTE criada 

-- criar uma visualizacao da CTE 
-- salvar essa consulta 

select 
	*
from vw_percentual_categorias_por_vendedor

-- se fizer alguma alteração nessa consulta - na CTE - é só usar esse comando

-- alter (no lugar do view)
-- alter vw_percentual_categorias_por_vendedor

-- também posso usar where para filtrar nessa visualização criada 



-- #########################################################################################################################################

-- VIEW 1

create view vw_produto_mais_comprado_por_cliente
as

-- 3) produto mais comprado por cliente 

-- mostra o seller_id, a categoria do produto mais vendido, a quantidade de vendas desse produto e o valor total de vendas (fazer no 2: case I)
-- na perspectiva do vendedor 

-- mostre o customer_id, a categoria do produto mais vendido, a quantidade de vendas desse produto e o valor total de vendas 
-- ou seja, na perspectiva do cliente 

-- a quantidade de compras que cada cliente fez: identificação - quantas vezes essse cliente comprou
-- contar a quantidade de pedidos que cada cliente fez na tb_orders  
-- quanto gastaram: preco do valor de vendas que está na tb_order_items


with customers as (
   select
   		t1.customer_unique_id,
		t4.product_category_name,
   		count(t2.order_id) as qntd,
		sum(t3.price) as valor_total
   from [dbo].[tb_act_olist_customers_dataset] as t1
   
   left join [dbo].[tb_act_olist_orders] as t2
on t1.customer_id = t2. customer_id

	left join [dbo].[tb_act_olist_order_items] as t3
	on t2.order_id = t3.order_id

	left join [dbo].[tb_act_olist_products] as t4
	on t3.product_id = t4.product_id

group by t1.customer_unique_id, t4.product_category_name


),

rankeamento as (
-- rankear pra saber quais dos produtos ele comprou mais vezes: quais produtos foram mais vendidos

select
	*,
	row_number() over(partition by customer_unique_id order by qntd desc, valor_total desc) as rank
from customers 

)
-- filtrar so quem tem ranking = 1
select
	*
from rankeamento 

where rank = 1

-- só o principal produto que ele comprou em termo de quantidade



-- ##################################################################

-- consultando a view criada


select
	*
from vw_produto_mais_comprado_por_cliente


-- ######################################################################################################

-- VIEW 2)

create view vw_tipo_pagamento_por_vendedor
as 

-- 3) vendas por tipo de cada vendedor - cartao, boleto ou voucher 


-- informação de todos os vendedores (seller_id), o valor total d evendas de cada um desses vendedores, percentual de acordo com o tipo de pagamento 


-- informacao dos vendedores e do tipo de pagamento 

-- valor total: preço + frete


with sellers as (

select
	seller_id,
	order_id,
	sum(price + freight_value) as valor_total
from [dbo].[tb_act_olist_order_items] as t1

group by seller_id, order_id

),

tipo_pagamento as (

select
	order_id,
	payment_type,
	sum(payment_value) as valor_pago
from [dbo].[tb_act_olist_order_payments] 

group by order_id, payment_type 


),

cruzamento as (

select
	t1.seller_id,
	t1.valor_total,
	t2.payment_type
from sellers as t1

left join tipo_pagamento as t2
on t1.order_id = t2.order_id

),

tratamento as (

-- eu quero uma so linha pra cada vendedor 
select
	seller_id,
	sum(valor_total) as valor_total,
	sum(case when payment_type = 'credit_card' then valor_total else 0 end) as cartao_credito,
	sum(case when payment_type = 'boleto' then valor_total else 0 end) as boleto,
	sum(case when payment_type = 'voucher' then valor_total else 0 end) as voucher,
	sum(case when payment_type = 'debit_card' then valor_total else 0 end) as cartao_debito
from cruzamento 

group by seller_id


-- ainda nao ta agrupando por vendedor 

)

select 
	seller_id,
	sum(valor_total) as valor_total,
	sum(cartao_credito) as cartao_credito,
	sum(boleto) as boleto,
	sum(voucher) as voucher,
	sum(cartao_debito) as cartao_debito
from tratamento 

group by seller_id
-- qual foi o tipo de pagamento por seller_id


-- ########################################################33


select 
	*
from vw_tipo_pagamento_por_vendedor

