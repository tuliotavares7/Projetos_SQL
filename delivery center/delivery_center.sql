




-- 1 tabela de criacao: [dbo].[channels]


select
	top 10 *
from [dbo].[channels]

-- 10 linhas 



-- se tem 0 na frente é tipo texto 

-- action: atual - real. tabela final 
-- fact: de fato. 

-- INT - inteiro
-- texto: NVARCHAR


create table tb_act_channels
(
	channel_id nvarchar(2),
	channel_name nvarchar(150),
	channel_type nvarchar(150)
)


insert into tb_act_channels
select 
	*
from [dbo].[channels]



select
	*
from tb_act_channels


select
	*
from [dbo].[channels]




-- nao pode rodar 2x se nao vai duplicar



-- 2 tabela de criacao: [dbo].[deliveries]


select
	*
from [dbo].[deliveries]


-- 378.843 linhas 


-- se tem 0 na frente é tipo texto 

-- action: atual - real. tabela final 
-- fact: de fato. 

-- INT - inteiro
-- texto: NVARCHAR

-- analisando se tem na coluna metros, algum valor com casa decimal 

select
	*
from [dbo].[deliveries]

where cast(delivery_distance_meters as varchar) like '%.%'

-- nao tem, portanto, posso deixar essa coluna como int e nao float 

create table tb_act_deliveries
(
	delivery_id nvarchar (50),
	delivery_order_id nvarchar(50),
	driver_id nvarchar(50),
	delivery_distance_meters int,
	delivery_status nvarchar(50)
)







insert into tb_act_deliveries
select 
	*
from [dbo].[deliveries]


select
	*
from [dbo].[deliveries]


select
	*
from tb_act_deliveries


-- nao pode rodar 2x se nao vai duplicar



-- 3 tabela de criacao: [dbo].[drivers]


select
	*
from [dbo].[drivers]

-- 4.824 linhas 



-- se tem 0 na frente é tipo texto 

-- action: atual - real. tabela final 
-- fact: de fato. 

-- INT - inteiro
-- texto: NVARCHAR


create table tb_act_drivers
(
	driver_id nvarchar(15),
	driver_modal nvarchar(50),
	driver_type nvarchar(150)
)

insert into tb_act_drivers
select
	*
from [dbo].[drivers]





select
	*
from [dbo].[drivers]



select
	*
from tb_act_drivers





-- 4 tabela de criacao: [dbo].[hubs]


select
	*
from [dbo].[hubs]

-- 32 linhas 



-- se tem 0 na frente é tipo texto 

-- action: atual - real. tabela final 
-- fact: de fato. 

-- INT - inteiro
-- texto: NVARCHAR

create table tb_act_hubs
(
	hub_id nvarchar (150),
	hub_name nvarchar(150),
	hub_city nvarchar(150),
	hub_state nvarchar(2),
	hub_latitude float,
	hub_longitude float
)


insert into tb_act_hubs
select
	*
from [dbo].[hubs]







select
	*
from [dbo].[hubs]



select
	*
from tb_act_hubs




-- 5 tabela de criacao: [dbo].[orders]


select
	*
from [dbo].[orders]

-- 368.999 linhas 



-- se tem 0 na frente é tipo texto 

-- action: atual - real. tabela final 
-- fact: de fato. 

-- INT - inteiro
-- texto: NVARCHAR


-- excluir a tabela pra recriar 
DROP TABLE IF EXISTS tb_act_orders

create table tb_act_orders
(
	order_id nvarchar(150),
	store_id nvarchar(150),
	channel_id nvarchar(150),
	payment_order_id nvarchar(150),
	delivery_order_id nvarchar(150),
	order_status nvarchar(150),
	order_amount float,
	order_delivery_fee float,
	order_delivery_cost float,
	order_created_hour int,
	order_created_minute int,
	order_created_day int,
	order_created_month int,
	order_created_year int,
	order_moment_created datetime,
	order_moment_accepted datetime,
	order_moment_ready datetime,
	order_moment_collected datetime,
	order_moment_in_expedition datetime,
	order_moment_delivering datetime,
	order_moment_delivered datetime,
	order_moment_finished datetime,
	order_metric_collected_time float,
	order_metric_paused_time float,
	order_metric_production_time float,
	order_metric_walking_time float,
	order_metric_expediton_speed_time float,
	order_metric_transit_time float,
	order_metric_cycle_time float
)


insert into tb_act_orders
select 
	*
from [dbo].[orders]





select
	*
from [dbo].[orders]



select
	*
from tb_act_orders



-- 6 tabela de criacao: [dbo].[payments]


select
	*
from [dbo].[payments]

-- 400.834 linhas 



-- se tem 0 na frente é tipo texto 

-- action: atual - real. tabela final 
-- fact: de fato. 

-- INT - inteiro
-- texto: NVARCHAR


create table tb_act_payments
(
	payment_id nvarchar(15),
	payment_order_id nvarchar(30),
	payment_amount float,
	payment_fee float,
	payment_method nvarchar(30),
	payment_status nvarchar(15)
)


insert into tb_act_payments
select
	*
from [dbo].[payments]




select
	*
from tb_act_payments


select
	*
from [dbo].[payments]




-- nao pode rodar 2x se nao vai duplicar




-- 7 tabela de criacao: [dbo].[stores]


select
	*
from [dbo].[stores]

-- 951 linhas 



-- se tem 0 na frente é tipo texto 

-- action: atual - real. tabela final 
-- fact: de fato. 

-- INT - inteiro
-- texto: NVARCHAR

create table tb_act_stores
(
	store_id nvarchar(15),
	hub_id nvarchar(15),
	store_name nvarchar(150),
	store_segment nvarchar(100),
	store_plan_price float,
	store_latitude float,
	store_longitude float
)


insert into tb_act_stores
select
	*
from [dbo].[stores]





select
	*
from [dbo].[stores]


select
	*
from tb_act_stores




-- nao pode rodar 2x se nao vai duplicar
















-- EXECUCAO 



-- 1) Hipótese 1: O tipo de entregador influencia a taxa de sucesso das entregas
-- Objetivo: Avaliar se entregadores do tipo freelancer têm um desempenho (sucesso de entrega) melhor ou pior que operadores.

-- Pergunta de negócio:

-- Qual a taxa de sucesso de entregas (status = "Entregue") entre freelancers e operadores? Existe diferença significativa?

-- Variáveis envolvidas:

-- drivers.tipo_entregador (freelancer ou operador)

-- entregas.status_entrega

-- entregas.distancia_km

-- entregas.modal_logistico




-- Por que é crucial?

-- Afeta diretamente a qualidade do serviço prestado.

-- Pode influenciar a decisão de contratação (freelancers vs operadores fixos).

-- Traz insights sobre eficiência operacional e custos, já que freelancers tendem a ter modelos de remuneração diferentes.

-- Se confirmada, essa hipótese pode levar a decisões estratégicas como:

-- Treinamento específico para um grupo.

-- Redimensionamento da força de entrega.

-- Revisão de políticas de contratação.


select 
	*
from [dbo].[tb_act_drivers]

where driver_type = 'LOGISTIC OPERATOR'

-- 3.939 freelance
-- 885 LOGISTIC OPERATOR 

-- perceba que o numero de logistic operator é bem menor 


-- selecionando as variaveis 


select 
	t1.driver_type,
	t1.driver_modal,
	t2.delivery_status,
	t2.delivery_distance_meters
from [dbo].[tb_act_drivers] as t1

left join [dbo].[tb_act_deliveries] as t2
on t1.driver_id = t2.driver_id



        -- Questão 1) Proporção de entregas com delivery_status = 'DELIVERED' para cada driver_type (freelancer ou operador).
        create view vw_freelance_analise as
        select 
        	t1.driver_type,
        	t1.driver_modal,
        	count(t2.delivery_id) as total_entregas,
        	sum(case when t2.delivery_status = 'DELIVERED' then 1 else 0 end) as entregas_sucesso,
        	format(cast(sum(case when t2.delivery_status = 'DELIVERED' then 1 else 0 end) as float) / count(*) * 100, 'N2', 'PT-BR') as taxa_sucesso_percentual,
        	AVG(t2.delivery_distance_meters) as distancia_media_metros -- distancia media por tipo de modal 
        from [dbo].[tb_act_drivers] as t1
        
        left join [dbo].[tb_act_deliveries] as t2
        on t1.driver_id = t2.driver_id
        
        group by t1.driver_type, t1.driver_modal 
        
        
select
	*
from freelance_analise









-- 2 -  Hipótese 2: Modais logísticos mais rápidos tendem a operar com pedidos de maior valor

-- Objetivo: Investigar se pedidos com maior valor são entregues por motociclistas em vez de outros modais.

-- Pergunta de negócio:

-- O modal logístico (motoboy x motociclista) impacta o valor médio dos pedidos?

-- Variáveis envolvidas:

-- entregas.modal_logistico

-- pedidos.valor_pedido

-- entregas.tempo_entrega (caso exista)

-- entregas.distancia_km






-- Por que é crucial?

-- Permite entender se existe uma associação entre ticket médio e agilidade da entrega, o que pode indicar:

-- Preferência do cliente por rapidez em pedidos mais caros.

-- Estratégias da empresa de priorizar modais mais rápidos para itens de maior valor (redução de risco de perda/avaria).

-- Ajuda a otimizar o uso de recursos logísticos, alocando os modais mais eficientes conforme a importância da entrega.

-- Variáveis como tempo e distância são complementares e importantes para controlar distorções.





             -- Questão 2: O modal logístico (motoboy x motociclista) impacta o valor médio dos pedidos?
             
             create view vw_modal as 
             with modal as (
             
             select
             	t1.driver_type,
             	t1.driver_modal,
             	count(t2.delivery_id) as total_entregas,
             	avg(t3.order_amount) as valor_medio_pedidos,
             	avg(t2.delivery_distance_meters) AS distancia_media_metros
             from [dbo].[tb_act_drivers] as t1
             
             left join [dbo].[tb_act_deliveries] as t2
             on t1.driver_id = t2.driver_id
             
             left join [dbo].[tb_act_orders] as t3
             on t2.delivery_order_id = t3.delivery_order_id
             
             group by t1.driver_type, t1.driver_modal
             ), 

             analise_faixa_distancia as (
             
             select
             	t1.driver_modal,
             case
             	when t2.delivery_distance_meters <= 1000 then '0-1 km'
             	when t2.delivery_distance_meters > 1000 and t2.delivery_distance_meters <= 3000 then '1-3 km'
             	when t2.delivery_distance_meters > 3000 and t2.delivery_distance_meters <= 5000 then '3-5 km'
             	when t2.delivery_distance_meters > 5000 and t2.delivery_distance_meters <= 10000 then '5-10 km'
             	else '10 km+'
             	end as faixa_distancia,
             	count(delivery_id) as total_entregas,
             	AVG(t3.order_amount) as valor_medio_pedidos_faixa
             from [dbo].[tb_act_drivers] as t1
             
               left join [dbo].[tb_act_deliveries] as t2
                 on t1.driver_id = t2.driver_id
             
             
             	left join [dbo].[tb_act_orders] as t3
             		on t2.delivery_order_id = t3.delivery_order_id
             
             group by t1.driver_modal,
             
             case
             	when t2.delivery_distance_meters <= 1000 then '0-1 km'
             	when t2.delivery_distance_meters > 1000 and t2.delivery_distance_meters <= 3000 then '1-3 km'
             	when t2.delivery_distance_meters > 3000 and t2.delivery_distance_meters <= 5000 then '3-5 km'
             	when t2.delivery_distance_meters > 5000 and t2.delivery_distance_meters <= 10000 then '5-10 km'
             	else '10 km+'
             	end
             )
             
             SELECT 
    modal.driver_type,
    modal.driver_modal,
    modal.total_entregas AS total_entregas_modal,
    modal.valor_medio_pedidos,
    modal.distancia_media_metros,
    analise_faixa_distancia.faixa_distancia,
    analise_faixa_distancia.total_entregas AS total_entregas_faixa,
    ROUND(analise_faixa_distancia.valor_medio_pedidos_faixa, 2) AS valor_medio_pedidos_faixa
FROM modal
LEFT JOIN analise_faixa_distancia
    ON modal.driver_modal = analise_faixa_distancia.driver_modal



	select
		*
	from vw_modal








             SELECT 
             	driver_modal,
             	faixa_distancia,
             	total_entregas,
             	round(valor_medio_pedidos_faixa, 2) as valor_medio_pedidos_faixa
             FROM analise_faixa_distancia 
             
             ORDER BY driver_modal, 
               CASE 
                 WHEN faixa_distancia = '0-1 km' THEN 1
                 WHEN faixa_distancia = '1-3 km' THEN 2
                 WHEN faixa_distancia = '3-5 km' THEN 3
                 WHEN faixa_distancia = '5-10 km' THEN 4
                 ELSE 5
               END
             
             









-- 3) Hipótese 3: Hubs em estados mais desenvolvidos têm maiores volumes de vendas e menores taxas de desconto
-- Objetivo: Relacionar o desempenho de vendas com a localização do hub.
-- 
-- Pergunta de negócio:
-- 
-- Quais estados concentram os maiores volumes de pedidos e menores percentuais de desconto?
-- 
-- Variáveis envolvidas:
-- 
-- hubs.estado
-- 
-- pedidos.status_pedido - 
-- 
-- pedidos.valor_pedido - 
-- 
-- pagamentos.valor_pagamento
-- 
-- 
-- pagamentos.status_pagamento





-- Por que essa pergunta é crucial?
-- 1. Tomada de decisão estratégica
-- Saber onde se vende mais e com maior margem (menor desconto) permite que a empresa:
-- 
-- Foque investimento nos hubs mais rentáveis.
-- 
-- Revise estratégias onde há muito desconto para manter competitividade.
-- 
-- -- 2. Eficiência comercial
-- Se hubs em estados menos desenvolvidos vendem menos, mas com mais desconto, isso pode indicar:
-- 
-- Estratégia agressiva para atrair clientes.
-- 
-- Ineficiência na logística ou na conversão.
-- 
-- -- 3. Segmentação geográfica inteligente
-- Os estados com maior volume e menor desconto podem representar mercados mais maduros, o que é valioso para decisões de:
-- 
-- Expansão de portfólio,
-- 
-- Lançamento de produtos,
-- 
-- Estratégias de fidelização


        -- Questão 3: Quais estados concentram os maiores volumes de pedidos e menores percentuais de desconto?
        
		create view vw_uf_pedidos as
        select
        	t1.hub_state,
        	count(t3.order_id) as 'total pedidos',
        	format(round(sum(cast(t3.order_amount as float)), 2), 'N2', 'pt-BR') as 'receita bruta', 
        	format(round(sum(t4.payment_amount), 2), 'N2', 'pt-BR') as 'receita liquida',  
        	format(round(avg(
        		case
        			when t4.payment_amount <= try_cast(t3.order_amount as float) and try_cast(t3.order_amount as float) > 0 -- try_cast as float para converter um 
        			-- tipo especifico retornando null se a conversao falhar 
        				then 1.0 - (t4.payment_amount /  try_cast(t3.order_amount as float)) 
        				end ), 2) * 100, 'N2', 'pt-BR') as 'desconto medio'
        from [dbo].[tb_act_hubs] as t1
        
        left join [dbo].[tb_act_stores] as t2
        on t1.hub_id = t2.hub_id
        
        left join [dbo].[orders] as t3
        on t2.store_id = t3.store_id
        
        left join [dbo].[tb_act_payments] as t4
        on t3.payment_order_id = t4.payment_order_id
        
        where t3.order_status = 'FINISHED' and t4.payment_status = 'paid' -- pedidos e pagamentos finalizados 
        
        group by t1.hub_state







select
	*
from [dbo].[tb_act_orders]

-- maiores numeros de pedidos
-- menores percentuais de desconto . quais estados 