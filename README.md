# Portfólio SQL 📊

## Brazil Delivery Center 

### Contexto e explicação do problema

Tenho me dedicado a aprimorar meus conhecimentos em SQL e recentemente finalizei uma atividade prática focada em análise de dados. Já havia aprendido SQL por conta própria, do zero, complementando com cursos na Udemy. Essa prática compartilhada aqui, reforçou ainda mais meu entendimento da linguagem.

Nesse projeto há três perguntas que busquei responder com dados previamente baixados na plataforma Kaggle. Tive liberdade para escolher qual SGBD utilizar na análise. Baixei e testei três opções: SQL Server, pgAdmin e PostgreSQL. Embora tenha achado o PostgreSQL mais interessante e semelhante ao R, com o qual tenho mais familiaridade, optei pelo SQL Server pela maior disponibilidade de fóruns e materiais de apoio encontrados na internet.

A escolha do banco de dados considerou alguns critérios: [i] que houvesse mais de duas tabelas, já que um dos principais objetivos era praticar o uso de joins, [ii] que existissem colunas em comum entre elas [iii] e que o número de linhas fosse suficientemente representativo. A intenção é, posteriormente, aplicar análises estatísticas mais avançadas, como regressões, utilizando o R, com base nos conhecimentos adquiridos na pós-graduação stricto sensu.

### Vamos ao assunto principal:

Neste projeto, utilizo o banco de dados Delivery Center: Food & Goods orders in Brazil, que contém sete tabelas principais, utilizadas para responder às perguntas propostas. Abaixo, segue a descrição de cada uma:

- channels: contém informações sobre os canais de venda (marketplaces) utilizados pelos lojistas para vender alimentos (food) e produtos (goods).
- deliveries: reúne dados sobre as entregas realizadas por entregadores parceiros.
- drivers: apresenta informações sobre os entregadores parceiros, que atuam a partir dos hubs para entregar os pedidos aos consumidores.
- hubs: contém dados sobre os centros de distribuição (hubs) de onde partem as entregas.
- orders: reúne informações sobre as vendas processadas pela plataforma do Delivery Center.
- payments: apresenta dados sobre os pagamentos feitos ao Delivery Center.
- stores: traz informações sobre os lojistas que utilizam a plataforma para vender seus produtos nos marketplaces.
  
Aqui está a figura disponibilizada pelo autor do diagrama de modelo de dados.

<img width="1489" height="716" alt="Image" src="https://github.com/user-attachments/assets/a7de357a-d315-4948-bff4-4d24cd05c0b4" />
Imagem 1: Explicação da tabela. Fonte: https://www.linkedin.com/in/cleibsonalmeida/

#### As perguntas e as respostas

A seguir, apresento as três perguntas que devem ser respondidas utilizando algumas das tabelas mencionadas acima. Em cada item, trarei a pergunta, a descrição e, em seguida, a respectiva resposta.

### Pergunta, Descrição e Resposta 1
#### Questão 1

Qual a taxa de sucesso de entregas (status = “Entregue”) entre freelancers e operadores? Existe diferença significativa?

#### Descrição 1

A partir da pergunta acima, defini quais colunas precisavam estar presentes no resultado da consulta, e são elas: driver_type, driver_modal, total_entregas, entregas_sucesso, taxa_sucesso_percentual e distancia_media_metros. Para isso, utilizei um LEFT JOIN entre as tabelas tb_act_drivers e tb_act_deliveries, unindo ambas pela chave primária driver_id. A opção pelo LEFT JOIN foi intencional, pois garante que todos os entregadores sejam incluídos no resultado, mesmo aqueles que não realizaram entregas, o que pode indicar inatividade ou baixa demanda.

```
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
```

Em seguida, utilizei a função COUNT() para contabilizar o total de entregas por tipo e modal de entregador. Para somar apenas as entregas com status “DELIVERED”, utilizei a função SUM() combinada com a cláusula CASE WHEN. Isso permitiu filtrar apenas os registros bem-sucedidos e calcular, posteriormente, a taxa de sucesso percentual. Para formatar esse percentual com duas casas decimais e notação brasileira, apliquei a função FORMAT() com os parâmetros ‘N2’ e ‘PT-BR’.

Abaixo, destaco um trecho da consulta SQL desenvolvida para responder à pergunta:

Constata-se que também incluí a média da distância percorrida em metros (delivery_distance_meters) por tipo de entregador e modal, por meio da função AVG(). Essa métrica é útil para entender se o desempenho está relacionado à complexidade logística das rotas.

Agrupei os resultados pelas variáveis driver_type e driver_modal, o que permite cruzar o tipo de entregador com o modal logístico (como bicicleta, moto, etc.) e observar padrões mais específicos.

#### Resposta 1

A análise dos dados revelou que tanto os entregadores freelancers quanto os operadores logísticos apresentam taxas de sucesso nas entregas extremamente altas, todas superiores a 99,8%, o que indica um desempenho operacional bastante consistente.

<div align="center">
<img width="703" height="127" alt="Image" src="https://github.com/user-attachments/assets/214c61b0-c973-4abe-aa85-0284b025c956" />
</div>


Ao segmentar os resultados por tipo de modal, observamos que os freelancers bikers alcançaram uma taxa de sucesso de 99,94%, com um total de 97.500 entregas realizadas. Já os freelancers motoboys, embora com uma taxa ligeiramente inferior (99,81%), concentraram o maior volume de entregas entre todos os perfis analisados, somando mais de 161 mil.

No grupo dos operadores logísticos, os motoboys também apresentaram desempenho elevado, com 99,94% de entregas bem-sucedidas em um universo de mais de 103 mil registros. Por outro lado, os operadores bikers registraram taxa de sucesso de 100%, mas com uma amostra muito pequena (apenas 14 entregas), o que limita a confiabilidade dessa informação para tomada de decisão.

A média de distância percorrida também trouxe insights relevantes. Os modais motoboy, tanto entre freelancers quanto entre operadores, apresentaram as maiores médias de deslocamento (3.179 e 3.863 metros, respectivamente), sugerindo que esse perfil é priorizado em rotas mais longas. Já os bikers, com distâncias médias bem inferiores (1.108 metros para freelancers e 2.326 metros para operadores), parecem atuar majoritariamente em regiões mais próximas dos hubs de distribuição.

Com base nesses dados, é possível concluir que não há diferença significativa entre freelancers e operadores em termos de taxa de sucesso. No entanto, a distribuição dos modais logísticos evidencia uma estratégia operacional que reserva os motoboys para distâncias maiores e os bikers para entregas mais locais. Esses resultados podem orientar decisões relacionadas à alocação de entregadores, definição de áreas de cobertura, e estratégias de otimização de custo e tempo de entrega.

### Pergunta, Descrição e Resposta 2
#### Questão 2

O modal logístico (motoboy x motociclista) impacta o valor médio dos pedidos?

#### Descrição 2

Neste estudo, o objetivo foi investigar se os modais logísticos mais rápidos tendem a operar com pedidos de maior valor. Para isso, precisei das colunas driver_modal, total_entregas, valor_medio_pedidos e distancia_media_metros, utilizando dados de três tabelas: tb_act_drivers, tb_act_deliveries e tb_act_orders. Como essas informações estão distribuídas entre diferentes tabelas, realizei as junções necessárias para consolidar os dados.

Para organizar a consulta e facilitar a compreensão, utilizei CTEs (Common Table Expressions), que são expressões temporárias nomeadas que funcionam como tabelas virtuais dentro da execução da query. As CTEs permitem dividir consultas complexas em blocos mais legíveis e reutilizáveis.

A primeira CTE, chamada modal, calcula o total de entregas, o valor médio dos pedidos e a distância média percorrida, agrupando os dados por tipo de entregador e modal logístico.

```
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

```



Já a segunda CTE, analise_faixa_distancia, segmenta as entregas em faixas de distância pré-definidas (de 0–1 km até mais de 10 km), permitindo analisar como o valor médio dos pedidos varia conforme o modal e a distância percorrida.

Essa estrutura modular com CTEs torna a análise mais clara, possibilitando uma melhor organização lógica dos passos do processamento dos dados.

Por fim, selecionei as variáveis relevantes da CTE analise_faixa_distancia e ordenei os resultados por modal e faixa de distância, facilitando a interpretação dos dados.


#### Resposta 2

A análise dos dados revelou padrões interessantes sobre a relação entre o modal logístico, a distância percorrida e o valor médio dos pedidos entregues. Observamos que, para ambos os modais analisados (bikers e motoboys), o valor médio dos pedidos tende a aumentar conforme a distância da entrega se eleva.

<div align="center">
<img width="427" height="235" alt="Image" src="https://github.com/user-attachments/assets/ebdfe01d-d6b1-4679-b9af-33cd80a14561" />
</div>


No caso dos bikers, o maior volume de entregas concentra-se nas faixas de distância até 3 km, com valores médios de pedido entre R$85,15 e R$90,14. Entretanto, em distâncias maiores, embora o número de entregas diminua consideravelmente, o valor médio dos pedidos cresce de forma significativa, chegando a R$194,54 para entregas acima de 10 km. Isso indica que, mesmo com menos frequência, pedidos mais caros são realizados em rotas mais longas por bikers.

Para os motoboys, o padrão é semelhante, porém com volumes muito superiores de entregas em todas as faixas, destacando-se especialmente a faixa de 1 a 3 km, que concentra 130 mil entregas. O valor médio dos pedidos para motoboys também cresce conforme a distância, atingindo R$176,53 para entregas acima de 10 km e até R$140,10 na faixa de 5 a 10 km, o que é ainda mais expressivo do que o observado para bikers em faixas similares.

Do ponto de vista de negócios, esses resultados sugerem que os modais mais rápidos, como os motoboys, são utilizados para atender a uma maior demanda, especialmente em distâncias intermediárias, com um ticket médio crescente conforme a complexidade logística aumenta. Já os bikers atuam predominantemente em distâncias curtas e médias, com pedidos de menor valor médio, exceto nos poucos casos de entregas longas, onde o valor sobe significativamente.

Essa compreensão pode ajudar a empresa a otimizar a alocação dos modais logísticos, priorizando motoboys para rotas mais longas e para pedidos de maior valor, garantindo agilidade e eficiência, enquanto os bikers podem focar em entregas locais, onde a rapidez e a agilidade também são importantes, mas com menor custo operacional.

Além disso, o entendimento detalhado do ticket médio por faixa de distância pode auxiliar na definição de políticas comerciais e estratégias de precificação, promovendo a maximização da receita e a melhoria da experiência do cliente.

### Pergunta, Descrição e Resposta 3
#### Questão 3

Quais estados concentram os maiores volumes de pedidos e menores percentuais de desconto?

#### Descrição 3

O foco da análise é relacionar o desempenho de vendas com a localização do hub, usando as variáveis estado do hub, status do pedido, valor do pedido, valor do pagamento e status do pagamento.

Primeiro, selecionei as colunas cruciais para o resultado final: o estado do hub, o total de pedidos finalizados, a receita bruta (soma do valor dos pedidos), a receita líquida (soma dos pagamentos efetivamente realizados) e o desconto médio aplicado. Para isso, realizei joins entre as tabelas de hubs, lojas, pedidos e pagamentos, utilizando as chaves primárias e estrangeiras correspondentes para garantir a integridade dos dados.

```
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

```

Utilizei a cláusula WHERE para filtrar apenas os pedidos com status “FINISHED” e pagamentos com status “paid”, garantindo que a análise considere somente transações concluídas e efetivamente pagas.

Para calcular o desconto médio, utilizei uma expressão condicional que compara o valor pago com o valor do pedido, computando a diferença percentual apenas quando o pagamento foi menor que o pedido e o valor do pedido é válido, o que evita distorções. A média desse percentual foi arredondada e formatada para exibir com duas casas decimais e em notação brasileira.

O agrupamento foi feito pelo estado do hub, permitindo identificar quais regiões apresentam maior volume de pedidos, maior receita e melhor margem (menor desconto médio).

#### Resposta 3

A análise do desempenho dos hubs em diferentes estados revela informações estratégicas valiosas para o negócio.

<div align="center">
<img width="441" height="121" alt="Image" src="https://github.com/user-attachments/assets/14d89f6d-daef-4656-a032-84986d7bbf15" />
</div>


Observamos que o estado de São Paulo (SP) lidera em volume de pedidos, com 179.174 pedidos finalizados, gerando uma receita bruta de aproximadamente R$ 19,89 milhões e receita líquida próxima a R$ 19,67 milhões. O desconto médio aplicado nas vendas em SP é de 24%.

O Rio Grande do Sul (RS), embora com um volume menor de pedidos (40.215), apresenta um desconto médio mais elevado, de 31%. Isso pode indicar uma estratégia comercial mais agressiva para atrair clientes ou possíveis desafios de eficiência logística e conversão que impactam a rentabilidade. A receita líquida de RS (R$ 2,99 milhões) representa cerca de 90% da receita bruta.

No Paraná (PR), o volume de pedidos é menor, com 33.584 transações, mas o desconto médio é o menor entre os estados analisados, em 20%. Esse menor percentual de desconto aliado a uma receita líquida de R$ 1,98 milhão em relação a uma receita bruta de R$ 2,25 milhões.

Já o Rio de Janeiro (RJ) mostra um volume expressivo de pedidos, 147.401, com receita bruta de R$ 12,86 milhões e receita líquida de R$ 12,66 milhões, e um desconto médio de 26%.

Do ponto de vista estratégico, esses resultados indicam que os hubs em estados como SP e RJ representam mercados maduros com alto volume e boa rentabilidade, merecendo atenção para investimentos e expansão. Em contrapartida, estados como RS, com descontos mais elevados, podem demandar ações específicas para otimizar margens e melhorar a eficiência comercial. O PR surge como um estado com potencial para crescimento sustentável, dada a baixa taxa de desconto e margens mais favoráveis.

Essas análises são fundamentais para direcionar esforços comerciais e logísticos, ajustar políticas de preço e desconto, e planejar expansões geográficas de forma inteligente, focando em rentabilidade e competitividade do negócio.

### Conclusão

Este projeto prático consolidou meu aprendizado em SQL e reforçou a importância de dominar a linguagem para atuar como analista de dados. Ao longo da análise, utilizei comandos essenciais como JOIN, GROUP BY, CASE WHEN, AVG, SUM, FORMAT, e técnicas mais avançadas como o uso de CTEs (Common Table Expressions), que tornaram as consultas mais organizadas e legíveis, especialmente em análises segmentadas por faixas ou categorias.

Além disso, interpretei os resultados sempre com uma perspectiva de negócios, identificando padrões relevantes de comportamento logístico, desempenho comercial por região e relação entre distância e ticket médio. Isso mostra como SQL vai além da manipulação de dados, ele é uma ferramenta poderosa para extração de insights estratégicos.




## Brazilian Ecommerce

### Contexto e explicação do problema

Como parte do meu processo de aprendizado contínuo em SQL, concluí recentemente esta segunda atividade prática de análise de dados, desta vez utilizando um conjunto de dados do comércio eletrônico brasileiro, disponibilizado pela Olist na plataforma Kaggle e discutido em um curso de SQL.

Esta base é composta por mais de 100 mil pedidos realizados entre 2016 e 2018, abrangendo diversas dimensões relevantes do e-commerce: status do pedido, forma de pagamento, valor do frete, localização do cliente, características do produto e avaliações pós-compra. Além disso, o conjunto inclui dados de geolocalização.

Para essa prática, mantive a escolha do SQL Server como sistema de gerenciamento de banco de dados, devido à sua vasta documentação e à ampla base de usuários, fatores que contribuem bastante na resolução de dúvidas ao longo do desenvolvimento. Também considerei, como critérios para a escolha do conjunto de dados, a existência de diversas tabelas com colunas em comum, um volume de dados representativo, capaz de sustentar análises mais robustas, e a possibilidade de realizar diferentes tipos de junções e filtros, colocando em prática os principais recursos da linguagem SQL.

A intenção, com este segundo portfólio, foi seguir consolidando meu domínio da linguagem SQL e a capacidade de elaborar consultas analíticas mais estruturadas.

Em breve, pretendo complementar esse trabalho com visualizações interativas e dashboards no Power BI, trazendo uma perspectiva mais visual e executiva para os insights obtidos a partir dos dados. Também será possível expandir as análises estatísticas robustas com o uso da linguagem R, aproveitando os conhecimentos adquiridos na pós-graduação stricto sensu.

Para acessar o primeiro portfólio, no qual desenvolvi consultas SQL baseadas em análises comparativas e exploratórias de dados de delivery, integrando múltiplas tabelas com foco em entregas, modais logísticos, valores médios de pedidos e desempenho regional, clique aqui. As consultas envolveram junções (joins), agregações (contagem, soma, média), filtros por status e segmentações por faixas de distância, tipo de entregador e região. Além disso, utilizei CTEs para estruturar a lógica das queries, garantindo organização e clareza no processamento dos dados.

### Vamos ao assunto principal:

Neste projeto, utilizo o banco de dados Olist, que contém oito tabelas principais, algumas a serem usadas para responder às perguntas propostas. Abaixo, segue a descrição de cada uma:

- olist customers contém informações sobre os clientes e sua localização. Permite identificar clientes únicos no conjunto de pedidos e localizar os destinos das entregas. Cada pedido tem um customer ID exclusivo, mas o customer unique ID permite reconhecer clientes que fizeram múltiplas compras.
- olist_geolocation: reúne dados sobre códigos postais brasileiros e suas coordenadas de latitude e longitude. Utilizado para mapear locais e calcular distâncias entre vendedores e clientes.
- olist_order_items: contém dados dos itens comprados em cada pedido.
- olist_order_payments: inclui informações sobre as formas de pagamento usadas em cada pedido.
- olist_order_reviews: traz avaliações e comentários dos clientes, enviados após a entrega, para registrar a satisfação com a compra.
- olist_orders: é o conjunto de dados principal, onde cada pedido pode ser associado a todas as outras informações das tabelas relacionadas.
- olist_products: reúne dados sobre os produtos vendidos na plataforma.
- olist_sellers: contém informações sobre os vendedores que atenderam aos pedidos, incluindo sua localização e associação a cada produto vendido.
- 
Aqui está a figura disponibilizada pelo autor do modelo de dados.

<img width="2486" height="1496" alt="Image" src="https://github.com/user-attachments/assets/341040f0-dbc3-4566-8689-cbd4ce79d770" />
Imagem 1: Explicação da tabela. Fonte: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce?select=product_category_name_translation.csv

As perguntas e as respostas

A seguir, apresento as três perguntas que devem ser respondidas utilizando algumas das tabelas mencionadas acima. Em cada item, trarei a pergunta, a descrição e, em seguida, a respectiva resposta.

### Pergunta, Descrição e Resposta 1
#### Questão 1

Qual é o produto mais comprado por cliente e por vendedor, considerando a categoria do produto, a quantidade de vendas e o valor total vendido, além de quantas compras cada cliente realizou e quanto gastou no total?

#### Descrição 1

A partir da pergunta “Qual é o produto mais comprado por cliente, considerando a categoria, a quantidade e o valor total gasto?”, defini que as colunas necessárias no resultado da consulta seriam: customer unique ID, product category name, quantidade (quantidade de compras da categoria) e valor total (soma dos preços dos produtos dessa categoria).

Para isso, utilizei uma CTE (Common Table Expression) chamada customers, que faz a junção das tabelas clientes, pedidos, itens do pedido e produtos, usando as chaves customer ID, order ID e product ID, respectivamente. Essa junção foi feita com LEFT JOIN, garantindo que todos os clientes sejam considerados, mesmo aqueles com compras incompletas ou com produtos sem categoria definida.

Nessa etapa, apliquei a função COUNT() para contar quantas vezes o cliente comprou produtos de uma determinada categoria, e SUM() para calcular o valor total gasto nessas compras.


```
create view vw_produto_mais_comprado_por_cliente
as


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

```

Em seguida, criei uma segunda CTE chamada rankeamento, onde utilizei a função ROW_NUMBER() com PARTITION BY por customer unique ID e ordenação por quantidade em ordem decrescente e valor total em ordem decrescente. Isso permite identificar, para cada cliente, qual foi a categoria de produto mais comprada, priorizando a quantidade e, em caso de empate, o valor total gasto.

Por fim, selecionei apenas os registros com rank igual a 1, ou seja, a categoria mais comprada por cada cliente, tanto em volume quanto em valor. Isso permite obter insights sobre os hábitos de consumo dos clientes e pode ser utilizado para estratégias de personalização, recomendação de produtos ou campanhas de fidelização.

A consulta foi salva como uma view chamada vw_produto_mais_comprado_por_cliente, facilitando o reuso em análises futuras.


Resposta 1

A análise teve como objetivo identificar a quantidade de compras realizadas por cada cliente, por meio da contagem do número de pedidos registrados na tabela Orders. Além disso, buscou-se calcular o valor total gasto por cada um desses clientes, somando os preços dos produtos presentes em cada pedido, com base nos dados da tabela Order Items. Dessa forma, foi possível mapear o comportamento de compra individual, considerando tanto a frequência quanto o volume financeiro das transações.

<div align="center">
<img width="545" height="776" alt="Image" src="https://github.com/user-attachments/assets/4736b697-4e63-4f57-8add-c76d318e1d87" />
</div>



### Pergunta, Descrição e Resposta 2
#### Questão 2

Qual é o valor total de vendas (considerando preço e frete) realizado por cada vendedor, discriminado por tipo de pagamento (cartão, boleto ou voucher), e qual o percentual que cada forma de pagamento representa no total de vendas de cada vendedor?

#### Descrição 2

Nessa questão, o objetivo foi analisar o comportamento de vendas por tipo de pagamento (cartão de crédito, boleto, voucher e cartão de débito) para cada vendedor da base, identificando o valor total vendido e o percentual correspondente de cada método de pagamento. Para isso, foram utilizadas as tabelas Order Items e Order Payments.

Como os dados de vendas e pagamentos estão distribuídos entre diferentes tabelas, organizei a consulta utilizando CTEs (Common Table Expressions), que permitem estruturar consultas complexas de forma mais legível.

A primeira CTE, chamada Sellers, agrega o valor total de vendas de cada pedido por vendedor, somando os campos price e freight_value (preço do item e valor do frete).

```
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


```

Em seguida, a CTE Tipo Pagamento calcula o valor total pago por pedido e por tipo de pagamento (como crédito, boleto ou voucher), agrupando os dados com base no order_id.


Na CTE Cruzamento, foi realizada uma junção entre essas duas fontes de informação (vendedores e pagamentos), conectando as CTEs anteriores por order_id e associando cada venda ao tipo de pagamento utilizado.


A CTE Tratamento consolida os dados por vendedor, somando os valores totais e discriminando quanto foi pago com cada forma de pagamento, por meio da função CASE WHEN.


Por fim, a query final seleciona os dados de cada vendedor, exibindo o valor total vendido e os valores separados por tipo de pagamento, permitindo observar com clareza o perfil de pagamento dos clientes de cada vendedor.


Essa estrutura com CTEs facilita a leitura da consulta, além de permitir a reutilização dos dados intermediários para novas análises. O resultado pode ser usado para entender preferências de pagamento por vendedor e apoiar estratégias comerciais ou financeiras.


Resposta 2

Nesta questão, o objetivo foi analisar o desempenho de vendas dos vendedores considerando os diferentes tipos de pagamento utilizados pelos clientes. Para isso, foram consolidadas informações de todos os vendedores (identificados por seller_id), detalhando o valor total de vendas de cada um, calculado como a soma do preço dos produtos com o valor do frete.

<div align="center">
<img width="590" height="795" alt="Image" src="https://github.com/user-attachments/assets/cbf6448b-b8ff-4650-9f97-9075ace5a3db" />
</div>


Além disso, as vendas foram segmentadas de acordo com o tipo de pagamento utilizado, como cartão de crédito, boleto, voucher e cartão de débito. Essa estrutura permite compreender não apenas quanto cada vendedor faturou, mas também qual foi a distribuição percentual de seus recebimentos por tipo de pagamento, oferecendo uma visão mais completa sobre o comportamento de consumo e a dependência de cada vendedor em relação aos meios de pagamento.

### Pergunta, Descrição e Resposta 3
#### Questão 3

Quais são os percentuais de vendas por categoria para cada vendedor na base de dados, e como essas distribuições podem ajudar a identificar o foco comercial de cada vendedor?

#### Descrição 3

O objetivo dessa análise foi identificar o percentual de vendas por categoria para cada vendedor, relacionando o valor total vendido em categorias específicas, como alimentos, construção, eletrodomésticos, fashion, livros, móveis, telefonia e outros.

Inicialmente, selecionei as informações de vendas dos vendedores e dos produtos, utilizando as tabelas tb_act_olist_order_items e tb_act_olist_products para relacionar cada venda com sua respectiva categoria. Realizei a junção entre essas tabelas com base na coluna product_id, garantindo a correspondência correta.

Para organizar a análise, utilizei Common Table Expressions (CTEs) que facilitaram o cálculo dos valores totais vendidos por vendedor e categoria, a transformação das categorias em colunas específicas, o cálculo do valor total vendido por vendedor e, por fim, o cálculo do percentual que cada categoria representa no total de vendas do vendedor.

A primeira CTE, chamada sellers, calcula o valor total vendido por cada vendedor em cada categoria de produto. Para isso, ela faz um join entre a tabela de itens vendidos e a tabela de produtos para associar o produto à sua categoria, removendo espaços extras nos IDs para garantir a correspondência correta. Em seguida, agrupa os dados por vendedor e categoria, somando o valor total das vendas (preço mais valor do frete) para cada combinação.

```
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
```

A segunda CTE, denominada tratamento, transforma as categorias de produtos em colunas específicas, criando uma visão mais estruturada dos dados. Ela agrupa os valores totais vendidos por categoria para cada vendedor, utilizando expressões condicionais (CASE WHEN) para alocar os valores em colunas como alimentos, construção, eletrodomésticos, fashion, livros, móveis, telefonia, e uma coluna “outros” para categorias que não se enquadram nas anteriores.


A terceira CTE, chamada valor_total, calcula o valor total vendido por cada vendedor, somando todas as categorias. Essa etapa é importante para que, posteriormente, seja possível calcular o percentual de participação de cada categoria no total vendido por vendedor.


Por fim, a quarta CTE, chamada percentual, calcula o percentual que cada categoria representa dentro do total vendido por cada vendedor. Para isso, realiza um join entre a tabela de valores por categoria e a tabela de valor total, dividindo o valor vendido em cada categoria pelo total do vendedor, multiplicando por 100 e arredondando o resultado para duas casas decimais. O resultado final apresenta, para cada vendedor, os percentuais de vendas distribuídos por categoria, permitindo identificar o foco comercial de cada um.



#### Resposta 3

A estrutura dos dados permite identificar claramente quais categorias predominam em cada vendedor, facilitando a segmentação e direcionamento de estratégias comerciais específicas.

<div align="center">
<img width="729" height="783" alt="Image" src="https://github.com/user-attachments/assets/4140146a-1e3a-416a-9c29-2b421527a54b" />
</div>

### Conclusão

Este projeto prático aprofundou meu domínio em SQL, especialmente no uso de CTEs (Common Table Expressions) para estruturar consultas complexas de forma clara e eficiente. Ao longo da análise, trabalhei com múltiplas tabelas relacionando clientes, vendedores, produtos, pagamentos e categorias, aplicando comandos essenciais como JOIN, GROUP BY, CASE WHEN, SUM e funções de ranking para responder perguntas comerciais relevantes.

Além disso, a interpretação dos resultados sempre foi guiada por uma visão de negócio, permitindo identificar o comportamento de compra dos clientes, o desempenho dos vendedores por forma de pagamento e o foco comercial por categoria de produto. Essas análises mostram que o SQL não é apenas uma linguagem para manipulação de dados, mas uma ferramenta fundamental para extrair insights estratégicos que apoiam a tomada de decisão.






## Hospital Management

### Contexto e explicação do problema

Tenho me dedicado a aprimorar meus conhecimentos em SQL e recentemente finalizei uma atividade prática focada em análise de dados. Já havia aprendido SQL de forma autodidata, complementando meu aprendizado com especializações. Essa prática compartilhada aqui reforçou ainda mais meu entendimento da linguagem e sua aplicação prática.

Neste projeto, busquei responder a três perguntas a partir de um conjunto de dados estruturado, previamente baixado na plataforma Kaggle. Tive liberdade para escolher o sistema gerenciador de banco de dados (SGBD) e, após testar três opções (SQL Server, pgAdmin e PostgreSQL), optei por utilizar o SQL Server, principalmente pela maior disponibilidade de fóruns, documentação e materiais de apoio online. Apesar disso, o PostgreSQL me pareceu mais interessante por sua semelhança com o R, linguagem com a qual já tenho mais familiaridade.

A escolha do banco de dados considerou os seguintes critérios:
[i] que houvesse mais de duas tabelas, já que um dos principais objetivos era praticar o uso de joins;
[ii] que existissem colunas em comum entre as tabelas para permitir a junção eficiente dos dados;
[iii] que o número de linhas fosse suficientemente representativo para análises mais robustas.

Além da exploração realizada com SQL, pretendo, em etapas futuras, complementar a análise com visualizações interativas no Power BI. O objetivo é transformar os resultados obtidos em dashboards dinâmicos que facilitem a interpretação e a comunicação dos insights extraídos.

Também planejo aplicar técnicas estatísticas mais avançadas, como regressões, utilizando a linguagem R, aproveitando os conhecimentos adquiridos durante a pós-graduação stricto sensu.

Para acessar o primeiro portfólio, no qual desenvolvi consultas SQL baseadas em análises comparativas e exploratórias de dados de delivery, integrando múltiplas tabelas com foco em entregas, modais logísticos, valores médios de pedidos e desempenho regional, clique aqui. As consultas envolveram junções (joins), agregações (contagem, soma, média), filtros por status e segmentações por faixas de distância, tipo de entregador e região. Além disso, utilizei CTEs para estruturar a lógica das queries, garantindo organização e clareza no processamento dos dados.

Disponibilizo também o segundo projeto, no qual utilizei o banco de dados Olist, composto por oito tabelas principais, para responder a perguntas estratégicas sobre comportamento de clientes, desempenho de vendedores e análise detalhada das vendas por categoria e tipo de pagamento. Por meio de consultas SQL estruturadas com CTEs, junções e agregações, explorei informações sobre clientes, produtos, pedidos, pagamentos e avaliações, aprofundando a análise dos dados de ecommerce para gerar insights comerciais relevantes.

### Vamos ao assunto principal:

Neste projeto, utilizo o banco de dados Hospital Management Dataset, que contém cinco tabelas principais, utilizadas para responder às perguntas propostas. Abaixo, segue a descrição de cada uma:

- atients.csv — Dados demográficos, contatos, informações de registro e seguro dos pacientes;
- doctors.csv — Perfis dos médicos, especializações, experiência e contatos;
- appointments.csv — Datas, horários, motivos das visitas e status dos agendamentos;
- treatments.csv — Tipos de tratamento, descrições, datas e custos associados;
- billing.csv — Valores cobrados, formas de pagamento e status das transações.

#### As perguntas e as respostas

A seguir, apresento as três perguntas que devem ser respondidas utilizando algumas das tabelas mencionadas acima. Em cada item, trarei a pergunta, a descrição e, em seguida, a respectiva resposta.

### Pergunta, Descrição e Resposta 1
#### Questão 1

Quais tipos de tratamento estão associados às maiores taxas de inadimplência (pagamentos pendentes ou falhos)?

#### Descrição 1

Para responder à pergunta “Certos tipos de tratamento apresentam maior taxa de inadimplência?”, iniciei a análise construindo uma CTE chamada inadimplencia_por_tratamento. Nessa etapa, defini as colunas treatment_type, amount, total_tratamentos, inadimplentes e taxa_inadimplencia_percentual. A CTE realiza um LEFT JOIN entre as tabelas treatments (que contém os registros dos procedimentos realizados) e billing (com as informações de faturamento), unindo-as pela chave primária treatment_id. O uso do LEFT JOIN foi intencional para garantir que todos os tratamentos fossem considerados, mesmo aqueles que ainda não possuíam cobrança registrada. Isso permite identificar possíveis falhas ou atrasos no processo de faturamento.

Dentro dessa mesma CTE, utilizei a função COUNT() para contabilizar o total de tratamentos por tipo (treatment_type). Em seguida, apliquei a função SUM() combinada com CASE WHEN para somar os tratamentos cujo status de pagamento fosse “pending” ou “failed”, considerados inadimplentes. A taxa de inadimplência foi então calculada com base na proporção desses casos em relação ao total de tratamentos, utilizando a fórmula (inadimplentes / total_tratamentos) * 100 e formatada com duas casas decimais por meio da função ROUND(). O uso do NULLIF() garante que divisões por zero sejam evitadas, retornando NULL nos casos em que o número de tratamentos é igual a zero.

```
CREATE VIEW vw_inadimplencia AS

WITH inadimplencia_por_tratamento AS (
    SELECT
        t1.treatment_type,
        t2.amount,
        COUNT(t1.treatment_id) AS total_tratamentos,
        SUM(CASE WHEN t2.payment_status IN ('pending', 'failed') THEN 1 ELSE 0 END) AS inadimplentes,
        CAST(ROUND(
            100.0 * SUM(CASE WHEN t2.payment_status IN ('pending', 'failed') THEN 1 ELSE 0 END) /
            NULLIF(COUNT(t1.treatment_id), 0), 2
        ) AS decimal(5,2)) as taxa_inadimplencia_percentual
    FROM [dbo].[treatments] t1
    LEFT JOIN [dbo].[billing] t2 ON t1.treatment_id = t2.treatment_id
    GROUP BY t1.treatment_type, t2.amount
)

SELECT
    treatment_type,
    CASE    
        WHEN TRY_CAST(amount AS decimal(18,2)) < 1000 THEN 'baixo (<1K)'
        WHEN TRY_CAST(amount AS decimal(18,2)) BETWEEN 1000 AND 3000 THEN 'medio (1K-3K)'
        ELSE 'alto (>3k)'
    END AS faixa_valor,
    SUM(total_tratamentos) AS total_tratamentos,
    SUM(inadimplentes) AS inadimplentes,
    ROUND(
        100.0 * SUM(inadimplentes) / NULLIF(SUM(total_tratamentos), 0), 2
    ) AS taxa_inadimplencia_percentual
FROM inadimplencia_por_tratamento
GROUP BY
    treatment_type,
    CASE    
        WHEN TRY_CAST(amount AS decimal(18,2)) < 1000 THEN 'baixo (<1K)'
        WHEN TRY_CAST(amount AS decimal(18,2)) BETWEEN 1000 AND 3000 THEN 'medio (1K-3K)'
        ELSE 'alto (>3k)'
    END

----------------------------------

ALTER VIEW vw_inadimplencia AS

WITH inadimplencia_por_tratamento AS (
    select
        t1.treatment_type,
        t2.amount,
        count(t1.treatment_id) as total_tratamentos,
        sum(case when t2.payment_status in ('pending', 'failed') then 1 else 0 end) as inadimplentes,
        cast(round(
            100.0 * sum(case when t2.payment_status in ('pending', 'failed') then 1 else 0 end) /
            nullif(count(t1.treatment_id), 0), 2
        ) as decimal(5,2)) as taxa_inadimplencia_percentual
    from [dbo].[treatments] t1
    left join [dbo].[billing] t2 on t1.treatment_id = t2.treatment_id
    group by t1.treatment_type, t2.amount
)

select
    treatment_type,
    case    
        when try_cast(amount as decimal(18,2)) < 1000 then 'baixo (<1K)'
        when try_cast(amount as decimal(18,2)) between 1000 and 3000 then 'medio (1K-3K)'
        else 'alto (>3k)'
    end as faixa_valor,
    sum(total_tratamentos) as total_tratamentos,
    sum(inadimplentes) as inadimplentes,
    cast(round(
        100.0 * sum(inadimplentes) / nullif(sum(total_tratamentos), 0), 2
    ) as decimal(5,2)) as taxa_inadimplencia_percentual
from inadimplencia_por_tratamento
group by
    treatment_type,
    case    
        when try_cast(amount as decimal(18,2)) < 1000 then 'baixo (<1K)'
        when try_cast(amount as decimal(18,2)) between 1000 and 3000 then 'medio (1K-3K)'
        else 'alto (>3k)'
    end



----------------------------------



	SELECT *
FROM vw_inadimplencia
ORDER BY taxa_inadimplencia_percentual DESC;
```

A segunda parte da consulta, fora da CTE, classifica os valores da coluna amount em três faixas de preço: baixo (<1K), médio (1K–3K) e alto (>3K). Para isso, utilizei a função TRY_CAST() para tentar converter os valores de amount para o tipo numérico DECIMAL(18,2). Essa função é preferida em vez do CAST() tradicional porque, caso o valor de amount seja inválido (por exemplo, texto não numérico), o TRY_CAST() retorna NULL em vez de gerar erro. Isso torna a consulta mais robusta e tolerante a dados sujos ou inconsistentes. Em seguida, utilizei a estrutura CASE para classificar os valores convertidos em faixas, o que permite segmentar a inadimplência também com base no custo dos tratamentos.


Por fim, os resultados foram ordenados de forma decrescente pela taxa_inadimplencia_percentual, destacando os tipos de tratamento com maiores taxas de inadimplência e possibilitando à empresa revisar políticas de cobrança, avaliar a viabilidade de parcelamentos e buscar melhores condições com seguradoras. Essa abordagem torna a análise mais estratégica e orientada à tomada de decisão.


#### Resposta 1

Os resultados indicam que a taxa de inadimplência é alta em praticamente todos os tipos de tratamento, variando conforme a faixa de valor dos procedimentos. No caso do ECG, os tratamentos com custo acima de 3 mil reais apresentam uma inadimplência extremamente elevada, com 93,33% dos casos em atraso ou não pagos. Já para a quimioterapia, mesmo os tratamentos mais baratos, com valor abaixo de 1 mil reais, apresentam uma inadimplência alta, de 87,5%, enquanto os tratamentos caros dessa modalidade têm uma taxa de 75%. Tratamentos de fisioterapia na faixa média, entre 1 e 3 mil reais, também mostram uma inadimplência significativa, de aproximadamente 73,7%. Em geral, mesmo os tratamentos com valores médios e baixos apresentam taxas altas, na faixa de 50% a 70%. Essa situação sugere que a inadimplência não está restrita apenas aos tratamentos mais caros, mas afeta de forma ampla diferentes tipos e faixas de valor. Esses dados indicam a necessidade de atenção especial para os processos de cobrança e acompanhamento financeiro, especialmente para os tratamentos de maior custo, que acumulam as maiores taxas de inadimplência. Essa análise pode servir para direcionar esforços e políticas que visem a redução da inadimplência, visando melhorar a sustentabilidade financeira do serviço.

<div align="center">
<img width="549" height="334" alt="Image" src="https://github.com/user-attachments/assets/61839800-4862-4bbf-ae5b-47fe359e1952" />
</div>


### Pergunta, Descrição e Resposta 2
#### Questão 2

Existem médicos ou especialidades em que a maioria dos atendimentos agendados resulta em cancelamento?

#### Descrição 2

Nesta questão, o objetivo foi analisar a taxa de cancelamento de atendimentos médicos por médico, especialidade e filial hospitalar. Para isso, utilizei as tabelas tb_act_appointments, que contém os agendamentos e seus status, e tb_act_doctors, que traz informações sobre os médicos, como a especialidade e a filial onde atendem. Como essas informações estão em tabelas diferentes, realizei uma junção do tipo LEFT JOIN, relacionando os registros pelo campo doctor_id. A consulta conta o total de atendimentos realizados e soma os atendimentos que foram cancelados, identificados pelo status ‘cancelled’. Para calcular a taxa de cancelamento percentual, dividi o número de cancelamentos pelo total de atendimentos, multiplicando o resultado por 100 e formatando para exibir duas casas decimais. Também usei a função NULLIF para evitar divisão por zero, caso não haja atendimentos registrados para algum médico. O agrupamento foi feito por médico, especialidade e filial, permitindo assim observar detalhadamente onde e por quem os cancelamentos ocorrem com maior frequência. Dessa forma, a view facilita o monitoramento e a análise dos padrões de cancelamento nas diferentes áreas e locais de atendimento.

```
create view vw_cancelamento as 

select 
	t2.doctor_id,
	t2.specialization,
	t2.hospital_branch,
	count (*) as total_atendimentos,
	sum(case 
			when t1.status = 'cancelled' then 1
			else 0
			end) as total_cancelado,
			format(100.0 * -- round: arredondar numeros  format: formatar o numero para texto 
				sum (case
						when t1.status = 'cancelled' then 1
						else 0
						end) / nullif(count(*), 0), 'N2') as taxa_cancelamento_percentual -- nullif: nao dividir por zero: se tiver zero amigos, nem tente dividir
from [dbo].[tb_act_appointments] as t1

left join [dbo].[tb_act_doctors] as t2
on t1.doctor_id = t2.doctor_id

group by t2.doctor_id, t2.specialization, t2.hospital_branch




select
	*
from vw_cancelamento

order by taxa_cancelamento_percentual desc
```

#### Resposta 2

Os dados mostram a taxa de cancelamento de atendimentos para diferentes médicos, suas especialidades e as filiais onde atuam. O médico D007, da especialidade Oncologia na filial Westside Clinic, apresenta a maior taxa de cancelamento, com 38,46% dos seus 13 atendimentos cancelados. Em seguida, o médico D002, de Pediatria na Eastside Clinic, tem uma taxa semelhante, com 38,10% de cancelamentos em 21 atendimentos. Outros médicos da especialidade Dermatologia e Pediatria também apresentam taxas relevantes, variando entre cerca de 20% e 31%, indicando que uma parcela significativa dos atendimentos agendados por esses profissionais foi cancelada. Médicos como D010, da Oncologia na Eastside Clinic, apresentam uma taxa menor, com 15,79%.

<div align="center">
<img width="632" height="236" alt="Image" src="https://github.com/user-attachments/assets/15fbe945-3bdc-4a3b-9606-7f74aec729a4" />
</div>


Esses resultados podem sinalizar problemas específicos relacionados à agenda, comunicação ou confiança dos pacientes, especialmente para os médicos com taxas de cancelamento mais elevadas. Além disso, a variação das taxas entre filiais sugere que questões operacionais locais podem influenciar o volume de cancelamentos. Essa análise pode ajudar a identificar médicos e unidades que necessitam de atenção para reduzir cancelamentos e melhorar o atendimento.

### Pergunta, Descrição e Resposta 3
#### Questão 3

Como se distribuem os pacientes, considerando gênero e faixas etárias, em relação ao status das consultas (canceladas ou no-show), e qual o total de pacientes que ainda não realizaram nenhuma consulta?

#### Descrição 3

O objetivo dessa análise é compreender o perfil etário e de gênero dos pacientes que não comparecem às consultas ou que têm suas consultas canceladas, além de identificar quantos pacientes ainda não realizaram nenhum atendimento no sistema de saúde.

Primeiramente, utilizei duas CTEs (Common Table Expressions) para organizar os dados em blocos distintos e facilitar a interpretação.

A primeira CTE, chamada pacientes_sem_consulta, identifica os pacientes que ainda não realizaram nenhuma consulta, ou seja, cujos registros não aparecem na tabela de agendamentos. Para isso, fiz um LEFT JOIN entre a tabela de pacientes e a de agendamentos, filtrando os casos em que o paciente não possui correspondência na tabela de consultas (t2.patient_id IS NULL). Os dados foram agrupados por paciente, gênero e data de nascimento, permitindo calcular o total de pacientes sem consulta.

```

create view vw_agendamento_consulta as 

with pacientes_sem_consulta as (

select
	t1.patient_id,
	t1.gender,
	convert(date,t1.date_of_birth) as birth_date, -- remove a hora 
	count(*) as total_pacientes_sem_consulta
from [dbo].[tb_act_patients] as t1

left join [dbo].[tb_act_appointments] as t2
on t1.patient_id = t2.patient_id

where t2.patient_id is null 

group by t1.patient_id, t1.gender, t1.date_of_birth

), 

-- pacientes por idade e consultas canceladas ou no-show 

pacientes_com_cancelamento_ou_noshow as (
select
	t1.gender,
	count (*) as total_cancelamento_no_show,
	datediff(year, t1.date_of_birth, getdate()) as idade,
	t2.status 
from [dbo].[tb_act_patients] as t1

left join [dbo].[tb_act_appointments] as t2
on t1.patient_id = t2.patient_id

where t2.status in ('Cancelled', 'No-show')

group by t1.gender, t2.status, 	datediff(year, t1.date_of_birth, getdate())



	

), 


-- consultas_por_faixa_etaria_e_status

faixas_etarias as (
select
	gender,
	case
		when idade < 18 then 'Menor de 18'
		when idade between 18 and 29 then '18-29 anos'
		when idade between 30 and 44 then '30-44 anos'
		when idade between 45 and 59 then '45-59 anos'
		when idade >= 60 then '60 ou mais'
		else 'idade desconhecida'
		end as faixa_etaria,
		status, 
		count(*) as total
		from pacientes_com_cancelamento_ou_noshow

	group by 
			case
		when idade < 18 then 'Menor de 18'
		when idade between 18 and 29 then '18-29 anos'
		when idade between 30 and 44 then '30-44 anos'
		when idade between 45 and 59 then '45-59 anos'
		when idade >= 60 then '60 ou mais'
		else 'idade desconhecida'
		end,
		status,
		gender
)


-- resultado final 

select 
	*
from faixas_etarias



select	
	*
from vw_agendamento_consulta

order by faixa_etaria, status
```

A segunda CTE, pacientes_com_cancelamento_ou_noshow, analisa os pacientes que tiveram consultas com status “Cancelled” ou “No-show”, ou seja, não compareceram ou cancelaram. Também foi utilizada a junção entre as tabelas de pacientes e agendamentos, com um filtro específico para esses dois status. Em seguida, foi calculada a idade dos pacientes com base na data de nascimento, e os dados foram agrupados por gênero, status da consulta e idade.


A terceira CTE, faixas_etarias, categoriza os pacientes da CTE anterior em faixas etárias pré-definidas (como “Menor de 18”, “18–29 anos”, etc.), permitindo visualizar a distribuição de cancelamentos e no-shows de forma segmentada por idade e gênero. O agrupamento por status, gender e faixa_etaria permite uma análise cruzada entre essas variáveis.



Por fim, a consulta final seleciona todos os dados da CTE faixas_etarias, retornando uma tabela que mostra, para cada combinação de faixa etária, gênero e status da consulta, o total de ocorrências registradas. Essa estrutura facilita a identificação de padrões de comportamento entre grupos específicos de pacientes, como maior incidência de no-show entre jovens ou maior número de cancelamentos entre pacientes idosos, por exemplo.



#### Resposta 3

Os resultados revelam que pacientes do sexo masculino entre 18 e 29 anos concentram a maior quantidade de cancelamentos (7) e no-shows (5), quando comparados às mulheres da mesma faixa (2 cancelamentos e 1 no-show). Esse padrão de maior taxa de ausência masculina se mantém, embora com menor intensidade, nas faixas de 30 a 44 anos e de 45 a 59 anos. Já na faixa dos 60 anos ou mais, o comportamento é mais equilibrado entre homens e mulheres, tanto em cancelamentos quanto em faltas, ambos com 3 ocorrências cada.

<div align="center">
<img width="264" height="350" alt="Image" src="https://github.com/user-attachments/assets/0646d08e-eb82-4cc5-987b-443bb5cfcb54" />
</div>

Esses dados sugerem que jovens adultos do sexo masculino apresentam maior propensão a não comparecer às consultas agendadas, o que pode impactar a eficiência do serviço e a gestão da agenda médica.

### Conclusão

A análise desenvolvida a partir do Hospital Management Dataset permitiu não apenas responder a três questões relevantes sobre inadimplência, cancelamentos e perfil dos pacientes, mas também demonstrar a aplicação prática de conceitos de modelagem relacional, uso de CTEs, tratamento de dados nulos e segmentações por faixa etária e financeira. Por meio de consultas SQL otimizadas e estruturadas, foi possível identificar gargalos operacionais que afetam diretamente a sustentabilidade financeira e a qualidade do atendimento no ambiente hospitalar.

Destacam-se, por exemplo, os altos índices de inadimplência associados a determinados tratamentos, como quimioterapia e ECG, e taxas significativas de cancelamento entre médicos de determinadas especialidades e unidades, além da concentração de no-shows entre homens jovens. Essas informações oferecem subsídios importantes para decisões estratégicas de gestão, como revisão de políticas de cobrança, ajustes nas agendas médicas e campanhas de engajamento voltadas a grupos específicos de pacientes.

O projeto demonstra, assim, a importância de uma abordagem orientada a dados para melhorar processos, reduzir perdas e promover maior eficiência no setor da saúde.
