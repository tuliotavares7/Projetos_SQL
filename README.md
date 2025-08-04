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

Zoom image will be displayed

Imagem 1: Explicação da tabela. Fonte: https://www.linkedin.com/in/cleibsonalmeida/

#### As perguntas e as respostas

A seguir, apresento as três perguntas que devem ser respondidas utilizando algumas das tabelas mencionadas acima. Em cada item, trarei a pergunta, a descrição e, em seguida, a respectiva resposta.

### Pergunta, Descrição e Resposta 1
#### Questão 1

Qual a taxa de sucesso de entregas (status = “Entregue”) entre freelancers e operadores? Existe diferença significativa?

#### Descrição 1

A partir da pergunta acima, defini quais colunas precisavam estar presentes no resultado da consulta, e são elas: driver_type, driver_modal, total_entregas, entregas_sucesso, taxa_sucesso_percentual e distancia_media_metros. Para isso, utilizei um LEFT JOIN entre as tabelas tb_act_drivers e tb_act_deliveries, unindo ambas pela chave primária driver_id. A opção pelo LEFT JOIN foi intencional, pois garante que todos os entregadores sejam incluídos no resultado, mesmo aqueles que não realizaram entregas, o que pode indicar inatividade ou baixa demanda.

Zoom image will be displayed

Imagem 2: Consulta SQL para a Pergunta 1
Em seguida, utilizei a função COUNT() para contabilizar o total de entregas por tipo e modal de entregador. Para somar apenas as entregas com status “DELIVERED”, utilizei a função SUM() combinada com a cláusula CASE WHEN. Isso permitiu filtrar apenas os registros bem-sucedidos e calcular, posteriormente, a taxa de sucesso percentual. Para formatar esse percentual com duas casas decimais e notação brasileira, apliquei a função FORMAT() com os parâmetros ‘N2’ e ‘PT-BR’.

Abaixo, destaco um trecho da consulta SQL desenvolvida para responder à pergunta:

Constata-se que também incluí a média da distância percorrida em metros (delivery_distance_meters) por tipo de entregador e modal, por meio da função AVG(). Essa métrica é útil para entender se o desempenho está relacionado à complexidade logística das rotas.

Agrupei os resultados pelas variáveis driver_type e driver_modal, o que permite cruzar o tipo de entregador com o modal logístico (como bicicleta, moto, etc.) e observar padrões mais específicos.

#### Resposta 1

A análise dos dados revelou que tanto os entregadores freelancers quanto os operadores logísticos apresentam taxas de sucesso nas entregas extremamente altas, todas superiores a 99,8%, o que indica um desempenho operacional bastante consistente.

Zoom image will be displayed

Imagem 3: Resultado da consulta para a questão 1
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


Imagem 4: Consulta SQL para a questão 2
Já a segunda CTE, analise_faixa_distancia, segmenta as entregas em faixas de distância pré-definidas (de 0–1 km até mais de 10 km), permitindo analisar como o valor médio dos pedidos varia conforme o modal e a distância percorrida.


Imagem 5: Consulta SQL para a questão 2
Essa estrutura modular com CTEs torna a análise mais clara, possibilitando uma melhor organização lógica dos passos do processamento dos dados.

Por fim, selecionei as variáveis relevantes da CTE analise_faixa_distancia e ordenei os resultados por modal e faixa de distância, facilitando a interpretação dos dados.


Imagem 6: Consulta SQL para a questão 3
#### Resposta 2

A análise dos dados revelou padrões interessantes sobre a relação entre o modal logístico, a distância percorrida e o valor médio dos pedidos entregues. Observamos que, para ambos os modais analisados (bikers e motoboys), o valor médio dos pedidos tende a aumentar conforme a distância da entrega se eleva.


Imagem 7: Resultado da consulta para a questão 2
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

Zoom image will be displayed

Imagem 8: Consulta SQL para a questão 3
Utilizei a cláusula WHERE para filtrar apenas os pedidos com status “FINISHED” e pagamentos com status “paid”, garantindo que a análise considere somente transações concluídas e efetivamente pagas.

Para calcular o desconto médio, utilizei uma expressão condicional que compara o valor pago com o valor do pedido, computando a diferença percentual apenas quando o pagamento foi menor que o pedido e o valor do pedido é válido, o que evita distorções. A média desse percentual foi arredondada e formatada para exibir com duas casas decimais e em notação brasileira.

O agrupamento foi feito pelo estado do hub, permitindo identificar quais regiões apresentam maior volume de pedidos, maior receita e melhor margem (menor desconto médio).

#### Resposta 3

A análise do desempenho dos hubs em diferentes estados revela informações estratégicas valiosas para o negócio.


Imagem 9: Resultado da consulta para a questão 3

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

Zoom image will be displayed

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


Imagem 2: Consulta SQL para a Pergunta 1
Em seguida, criei uma segunda CTE chamada rankeamento, onde utilizei a função ROW_NUMBER() com PARTITION BY por customer unique ID e ordenação por quantidade em ordem decrescente e valor total em ordem decrescente. Isso permite identificar, para cada cliente, qual foi a categoria de produto mais comprada, priorizando a quantidade e, em caso de empate, o valor total gasto.

Zoom image will be displayed

Imagem 3: Consulta SQL para a Pergunta 1
Por fim, selecionei apenas os registros com rank igual a 1, ou seja, a categoria mais comprada por cada cliente, tanto em volume quanto em valor. Isso permite obter insights sobre os hábitos de consumo dos clientes e pode ser utilizado para estratégias de personalização, recomendação de produtos ou campanhas de fidelização.

Zoom image will be displayed

Imagem 4: Consulta SQL para a Pergunta 1
A consulta foi salva como uma view chamada vw_produto_mais_comprado_por_cliente, facilitando o reuso em análises futuras.

Zoom image will be displayed

Imagem 5: Consulta SQL para a Pergunta 1
Resposta 1

A análise teve como objetivo identificar a quantidade de compras realizadas por cada cliente, por meio da contagem do número de pedidos registrados na tabela Orders. Além disso, buscou-se calcular o valor total gasto por cada um desses clientes, somando os preços dos produtos presentes em cada pedido, com base nos dados da tabela Order Items. Dessa forma, foi possível mapear o comportamento de compra individual, considerando tanto a frequência quanto o volume financeiro das transações.


Imagem 6: Resultado da consulta para a questão 1

### Pergunta, Descrição e Resposta 2
#### Questão 2

Qual é o valor total de vendas (considerando preço e frete) realizado por cada vendedor, discriminado por tipo de pagamento (cartão, boleto ou voucher), e qual o percentual que cada forma de pagamento representa no total de vendas de cada vendedor?

#### Descrição 2

Nessa questão, o objetivo foi analisar o comportamento de vendas por tipo de pagamento (cartão de crédito, boleto, voucher e cartão de débito) para cada vendedor da base, identificando o valor total vendido e o percentual correspondente de cada método de pagamento. Para isso, foram utilizadas as tabelas Order Items e Order Payments.

Como os dados de vendas e pagamentos estão distribuídos entre diferentes tabelas, organizei a consulta utilizando CTEs (Common Table Expressions), que permitem estruturar consultas complexas de forma mais legível.

A primeira CTE, chamada Sellers, agrega o valor total de vendas de cada pedido por vendedor, somando os campos price e freight_value (preço do item e valor do frete).

Zoom image will be displayed

Imagem 7: Consulta SQL para a questão 2
Em seguida, a CTE Tipo Pagamento calcula o valor total pago por pedido e por tipo de pagamento (como crédito, boleto ou voucher), agrupando os dados com base no order_id.

Zoom image will be displayed

Imagem 8: Consulta SQL para a questão 2
Na CTE Cruzamento, foi realizada uma junção entre essas duas fontes de informação (vendedores e pagamentos), conectando as CTEs anteriores por order_id e associando cada venda ao tipo de pagamento utilizado.

Zoom image will be displayed

Imagem 9: Consulta SQL para a questão 2
A CTE Tratamento consolida os dados por vendedor, somando os valores totais e discriminando quanto foi pago com cada forma de pagamento, por meio da função CASE WHEN.

Zoom image will be displayed

Imagem 10: Consulta SQL para a questão 2
Por fim, a query final seleciona os dados de cada vendedor, exibindo o valor total vendido e os valores separados por tipo de pagamento, permitindo observar com clareza o perfil de pagamento dos clientes de cada vendedor.

Zoom image will be displayed

Imagem 11: Consulta SQL para a questão 2
Essa estrutura com CTEs facilita a leitura da consulta, além de permitir a reutilização dos dados intermediários para novas análises. O resultado pode ser usado para entender preferências de pagamento por vendedor e apoiar estratégias comerciais ou financeiras.

Zoom image will be displayed

Imagem 12: Consulta SQL para a questão 2
Resposta 2

Nesta questão, o objetivo foi analisar o desempenho de vendas dos vendedores considerando os diferentes tipos de pagamento utilizados pelos clientes. Para isso, foram consolidadas informações de todos os vendedores (identificados por seller_id), detalhando o valor total de vendas de cada um, calculado como a soma do preço dos produtos com o valor do frete.


Imagem 13: Resultado da consulta para a questão 2
Além disso, as vendas foram segmentadas de acordo com o tipo de pagamento utilizado, como cartão de crédito, boleto, voucher e cartão de débito. Essa estrutura permite compreender não apenas quanto cada vendedor faturou, mas também qual foi a distribuição percentual de seus recebimentos por tipo de pagamento, oferecendo uma visão mais completa sobre o comportamento de consumo e a dependência de cada vendedor em relação aos meios de pagamento.

### Pergunta, Descrição e Resposta 3
#### Questão 3

Quais são os percentuais de vendas por categoria para cada vendedor na base de dados, e como essas distribuições podem ajudar a identificar o foco comercial de cada vendedor?

#### Descrição 3

O objetivo dessa análise foi identificar o percentual de vendas por categoria para cada vendedor, relacionando o valor total vendido em categorias específicas, como alimentos, construção, eletrodomésticos, fashion, livros, móveis, telefonia e outros.

Inicialmente, selecionei as informações de vendas dos vendedores e dos produtos, utilizando as tabelas tb_act_olist_order_items e tb_act_olist_products para relacionar cada venda com sua respectiva categoria. Realizei a junção entre essas tabelas com base na coluna product_id, garantindo a correspondência correta.

Para organizar a análise, utilizei Common Table Expressions (CTEs) que facilitaram o cálculo dos valores totais vendidos por vendedor e categoria, a transformação das categorias em colunas específicas, o cálculo do valor total vendido por vendedor e, por fim, o cálculo do percentual que cada categoria representa no total de vendas do vendedor.

A primeira CTE, chamada sellers, calcula o valor total vendido por cada vendedor em cada categoria de produto. Para isso, ela faz um join entre a tabela de itens vendidos e a tabela de produtos para associar o produto à sua categoria, removendo espaços extras nos IDs para garantir a correspondência correta. Em seguida, agrupa os dados por vendedor e categoria, somando o valor total das vendas (preço mais valor do frete) para cada combinação.

Zoom image will be displayed

Imagem 14: Consulta SQL para a questão 3

A segunda CTE, denominada tratamento, transforma as categorias de produtos em colunas específicas, criando uma visão mais estruturada dos dados. Ela agrupa os valores totais vendidos por categoria para cada vendedor, utilizando expressões condicionais (CASE WHEN) para alocar os valores em colunas como alimentos, construção, eletrodomésticos, fashion, livros, móveis, telefonia, e uma coluna “outros” para categorias que não se enquadram nas anteriores.

Zoom image will be displayed

Imagem 15: Consulta SQL para a questão 3

A terceira CTE, chamada valor_total, calcula o valor total vendido por cada vendedor, somando todas as categorias. Essa etapa é importante para que, posteriormente, seja possível calcular o percentual de participação de cada categoria no total vendido por vendedor.

Zoom image will be displayed

Imagem 16: Consulta SQL para a questão 3

Por fim, a quarta CTE, chamada percentual, calcula o percentual que cada categoria representa dentro do total vendido por cada vendedor. Para isso, realiza um join entre a tabela de valores por categoria e a tabela de valor total, dividindo o valor vendido em cada categoria pelo total do vendedor, multiplicando por 100 e arredondando o resultado para duas casas decimais. O resultado final apresenta, para cada vendedor, os percentuais de vendas distribuídos por categoria, permitindo identificar o foco comercial de cada um.

Zoom image will be displayed

Imagem 17: Consulta SQL para a questão 3

#### Resposta 3

A estrutura dos dados permite identificar claramente quais categorias predominam em cada vendedor, facilitando a segmentação e direcionamento de estratégias comerciais específicas.

Zoom image will be displayed

Imagem 18: Resultado da consulta para a questão 3

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

Zoom image will be displayed

Imagem 2: Consulta SQL para a Pergunta 1
A segunda parte da consulta, fora da CTE, classifica os valores da coluna amount em três faixas de preço: baixo (<1K), médio (1K–3K) e alto (>3K). Para isso, utilizei a função TRY_CAST() para tentar converter os valores de amount para o tipo numérico DECIMAL(18,2). Essa função é preferida em vez do CAST() tradicional porque, caso o valor de amount seja inválido (por exemplo, texto não numérico), o TRY_CAST() retorna NULL em vez de gerar erro. Isso torna a consulta mais robusta e tolerante a dados sujos ou inconsistentes. Em seguida, utilizei a estrutura CASE para classificar os valores convertidos em faixas, o que permite segmentar a inadimplência também com base no custo dos tratamentos.

Zoom image will be displayed

Imagem 3: Consulta SQL para a Pergunta 1
Por fim, os resultados foram ordenados de forma decrescente pela taxa_inadimplencia_percentual, destacando os tipos de tratamento com maiores taxas de inadimplência e possibilitando à empresa revisar políticas de cobrança, avaliar a viabilidade de parcelamentos e buscar melhores condições com seguradoras. Essa abordagem torna a análise mais estratégica e orientada à tomada de decisão.

Zoom image will be displayed

Imagem 4: Consulta SQL para a Pergunta 1
#### Resposta 1

Os resultados indicam que a taxa de inadimplência é alta em praticamente todos os tipos de tratamento, variando conforme a faixa de valor dos procedimentos. No caso do ECG, os tratamentos com custo acima de 3 mil reais apresentam uma inadimplência extremamente elevada, com 93,33% dos casos em atraso ou não pagos. Já para a quimioterapia, mesmo os tratamentos mais baratos, com valor abaixo de 1 mil reais, apresentam uma inadimplência alta, de 87,5%, enquanto os tratamentos caros dessa modalidade têm uma taxa de 75%. Tratamentos de fisioterapia na faixa média, entre 1 e 3 mil reais, também mostram uma inadimplência significativa, de aproximadamente 73,7%. Em geral, mesmo os tratamentos com valores médios e baixos apresentam taxas altas, na faixa de 50% a 70%. Essa situação sugere que a inadimplência não está restrita apenas aos tratamentos mais caros, mas afeta de forma ampla diferentes tipos e faixas de valor. Esses dados indicam a necessidade de atenção especial para os processos de cobrança e acompanhamento financeiro, especialmente para os tratamentos de maior custo, que acumulam as maiores taxas de inadimplência. Essa análise pode servir para direcionar esforços e políticas que visem a redução da inadimplência, visando melhorar a sustentabilidade financeira do serviço.


Imagem 5: Resultado da consulta para a questão 1
### Pergunta, Descrição e Resposta 2
#### Questão 2

Existem médicos ou especialidades em que a maioria dos atendimentos agendados resulta em cancelamento?

#### Descrição 2

Nesta questão, o objetivo foi analisar a taxa de cancelamento de atendimentos médicos por médico, especialidade e filial hospitalar. Para isso, utilizei as tabelas tb_act_appointments, que contém os agendamentos e seus status, e tb_act_doctors, que traz informações sobre os médicos, como a especialidade e a filial onde atendem. Como essas informações estão em tabelas diferentes, realizei uma junção do tipo LEFT JOIN, relacionando os registros pelo campo doctor_id. A consulta conta o total de atendimentos realizados e soma os atendimentos que foram cancelados, identificados pelo status ‘cancelled’. Para calcular a taxa de cancelamento percentual, dividi o número de cancelamentos pelo total de atendimentos, multiplicando o resultado por 100 e formatando para exibir duas casas decimais. Também usei a função NULLIF para evitar divisão por zero, caso não haja atendimentos registrados para algum médico. O agrupamento foi feito por médico, especialidade e filial, permitindo assim observar detalhadamente onde e por quem os cancelamentos ocorrem com maior frequência. Dessa forma, a view facilita o monitoramento e a análise dos padrões de cancelamento nas diferentes áreas e locais de atendimento.

Zoom image will be displayed

Imagem 6: Consulta SQL para a questão 2
#### Resposta 2

Os dados mostram a taxa de cancelamento de atendimentos para diferentes médicos, suas especialidades e as filiais onde atuam. O médico D007, da especialidade Oncologia na filial Westside Clinic, apresenta a maior taxa de cancelamento, com 38,46% dos seus 13 atendimentos cancelados. Em seguida, o médico D002, de Pediatria na Eastside Clinic, tem uma taxa semelhante, com 38,10% de cancelamentos em 21 atendimentos. Outros médicos da especialidade Dermatologia e Pediatria também apresentam taxas relevantes, variando entre cerca de 20% e 31%, indicando que uma parcela significativa dos atendimentos agendados por esses profissionais foi cancelada. Médicos como D010, da Oncologia na Eastside Clinic, apresentam uma taxa menor, com 15,79%.


Imagem 7: Resultado da consulta para a questão 2
Esses resultados podem sinalizar problemas específicos relacionados à agenda, comunicação ou confiança dos pacientes, especialmente para os médicos com taxas de cancelamento mais elevadas. Além disso, a variação das taxas entre filiais sugere que questões operacionais locais podem influenciar o volume de cancelamentos. Essa análise pode ajudar a identificar médicos e unidades que necessitam de atenção para reduzir cancelamentos e melhorar o atendimento.

### Pergunta, Descrição e Resposta 3
#### Questão 3

Como se distribuem os pacientes, considerando gênero e faixas etárias, em relação ao status das consultas (canceladas ou no-show), e qual o total de pacientes que ainda não realizaram nenhuma consulta?

#### Descrição 3

O objetivo dessa análise é compreender o perfil etário e de gênero dos pacientes que não comparecem às consultas ou que têm suas consultas canceladas, além de identificar quantos pacientes ainda não realizaram nenhum atendimento no sistema de saúde.

Primeiramente, utilizei duas CTEs (Common Table Expressions) para organizar os dados em blocos distintos e facilitar a interpretação.

A primeira CTE, chamada pacientes_sem_consulta, identifica os pacientes que ainda não realizaram nenhuma consulta, ou seja, cujos registros não aparecem na tabela de agendamentos. Para isso, fiz um LEFT JOIN entre a tabela de pacientes e a de agendamentos, filtrando os casos em que o paciente não possui correspondência na tabela de consultas (t2.patient_id IS NULL). Os dados foram agrupados por paciente, gênero e data de nascimento, permitindo calcular o total de pacientes sem consulta.

Zoom image will be displayed

Imagem 8: Consulta SQL para a questão 3
A segunda CTE, pacientes_com_cancelamento_ou_noshow, analisa os pacientes que tiveram consultas com status “Cancelled” ou “No-show”, ou seja, não compareceram ou cancelaram. Também foi utilizada a junção entre as tabelas de pacientes e agendamentos, com um filtro específico para esses dois status. Em seguida, foi calculada a idade dos pacientes com base na data de nascimento, e os dados foram agrupados por gênero, status da consulta e idade.

Zoom image will be displayed

Imagem 9: Consulta SQL para a questão 3
A terceira CTE, faixas_etarias, categoriza os pacientes da CTE anterior em faixas etárias pré-definidas (como “Menor de 18”, “18–29 anos”, etc.), permitindo visualizar a distribuição de cancelamentos e no-shows de forma segmentada por idade e gênero. O agrupamento por status, gender e faixa_etaria permite uma análise cruzada entre essas variáveis.


Imagem 10: Consulta SQL para a questão 3
Por fim, a consulta final seleciona todos os dados da CTE faixas_etarias, retornando uma tabela que mostra, para cada combinação de faixa etária, gênero e status da consulta, o total de ocorrências registradas. Essa estrutura facilita a identificação de padrões de comportamento entre grupos específicos de pacientes, como maior incidência de no-show entre jovens ou maior número de cancelamentos entre pacientes idosos, por exemplo.


Imagem 11: Consulta SQL para a questão 3
#### Resposta 3

Os resultados revelam que pacientes do sexo masculino entre 18 e 29 anos concentram a maior quantidade de cancelamentos (7) e no-shows (5), quando comparados às mulheres da mesma faixa (2 cancelamentos e 1 no-show). Esse padrão de maior taxa de ausência masculina se mantém, embora com menor intensidade, nas faixas de 30 a 44 anos e de 45 a 59 anos. Já na faixa dos 60 anos ou mais, o comportamento é mais equilibrado entre homens e mulheres, tanto em cancelamentos quanto em faltas, ambos com 3 ocorrências cada.


Imagem 12: Resultado da consulta para a questão 3
Esses dados sugerem que jovens adultos do sexo masculino apresentam maior propensão a não comparecer às consultas agendadas, o que pode impactar a eficiência do serviço e a gestão da agenda médica.

### Conclusão

A análise desenvolvida a partir do Hospital Management Dataset permitiu não apenas responder a três questões relevantes sobre inadimplência, cancelamentos e perfil dos pacientes, mas também demonstrar a aplicação prática de conceitos de modelagem relacional, uso de CTEs, tratamento de dados nulos e segmentações por faixa etária e financeira. Por meio de consultas SQL otimizadas e estruturadas, foi possível identificar gargalos operacionais que afetam diretamente a sustentabilidade financeira e a qualidade do atendimento no ambiente hospitalar.

Destacam-se, por exemplo, os altos índices de inadimplência associados a determinados tratamentos, como quimioterapia e ECG, e taxas significativas de cancelamento entre médicos de determinadas especialidades e unidades, além da concentração de no-shows entre homens jovens. Essas informações oferecem subsídios importantes para decisões estratégicas de gestão, como revisão de políticas de cobrança, ajustes nas agendas médicas e campanhas de engajamento voltadas a grupos específicos de pacientes.

O projeto demonstra, assim, a importância de uma abordagem orientada a dados para melhorar processos, reduzir perdas e promover maior eficiência no setor da saúde.
