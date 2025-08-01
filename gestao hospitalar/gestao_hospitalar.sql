


-- 1 tabela de criacao: [dbo].[appointments]


select
	*
from [dbo].[appointments]

-- 200 linhas 



-- se tem 0 na frente é tipo texto 

-- action: atual - real. tabela final 
-- fact: de fato. 

-- INT - inteiro
-- texto: NVARCHAR


create table tb_act_appointments
(
	appointment_id nvarchar(15),
	patient_id nvarchar(15),
	doctor_id nvarchar(15),
	appointment_date datetime,
	appointment_time datetime,
	reason_for_visit nvarchar(100),
	status nvarchar(100)
)


insert into tb_act_appointments
select 
	*
from [dbo].[appointments]

-- 200 linhas 

select
	*
from tb_act_channels


select
	*
from [dbo].[channels]




-- nao pode rodar 2x se nao vai duplicar



-- 2) tabela de criacao: [dbo].[billing]


select
	*
from [dbo].[billing]

-- 200 linhas 



-- se tem 0 na frente é tipo texto 

-- action: atual - real. tabela final 
-- fact: de fato. 

-- INT - inteiro
-- texto: NVARCHAR


create table tb_act_billing
(
	bill_id nvarchar(15),
	patient_id nvarchar(15),
	treatment_id nvarchar(15),
	bill_date datetime,
	amount float,
	payment_method nvarchar(100),
	payment_status nvarchar(100)
)

insert into tb_act_billing
select
	*
from [dbo].[billing]

-- 200 linhas 





-- 3) tabela de criacao: [dbo].[doctors]


select
	*
from [dbo].[doctors]

-- 10 linhas 


create table tb_act_doctors
(
	doctor_id nvarchar(15),
	first_name nvarchar(100),
	last_name nvarchar(100),
	specialization nvarchar(150),
	phone_number nvarchar(50),
	years_experience int,
	hospital_branch nvarchar(150),
	email nvarchar(100)
)

insert into tb_act_doctors
select
	*
from [dbo].[doctors]


-- 10 linhas 




-- 4) tabela de criacao: [dbo].[patients]


select
	*
from [dbo].[patients]

-- 50 linhas 

create table tb_act_patients
(
	patient_id nvarchar(15),
	first_name nvarchar(150),
	last_name nvarchar(150),
	gender nvarchar(1),
	date_of_birth datetime,
	contact_number nvarchar(15),
	address nvarchar(100),
	registration_date datetime,
	insurance_provider nvarchar(100),
	insurance_number nvarchar(100),
	email nvarchar(100)
)


insert into tb_act_patients
select 
	*
from [dbo].[patients]

-- 50 linhas








-- 5) tabela de criacao: [dbo].[treatments]


select
	*
from [dbo].[treatments]

-- 200 linhas 

create table tb_act_treatments
(
	treatment_id nvarchar(15),
	appointment_id nvarchar(15),
	treatment_type nvarchar(150),
	description nvarchar(150),
	cost float,
	treatment_date datetime
)

insert into tb_act_treatments
select
	*
from [dbo].[treatments]

-- 200 linhas 





-- 1) "Certos tipos de tratamento apresentam maior taxa de inadimplência?"
-- Justificativa empresarial:
-- Entender quais tratamentos têm maior índice de pagamentos pendentes ou falhos pode ajudar:
-- 
-- A rever políticas de cobrança
-- 
-- Avaliar viabilidade de parcelamentos
-- 
-- Melhorar negociação com seguradoras





-- Hipótese:
-- "Certos tipos de tratamento apresentam maior taxa de inadimplência?"
-- 
-- Objetivo:
-- Descobrir quais tratamentos têm maior proporção de faturas com status "Pendente" ou "Falha", a partir da junção dos dados de tratamento e cobrança.

-- Revisar políticas de cobrança
-- 
-- Avaliar viabilidade de parcelamentos
-- 
-- Negociar melhor com seguradoras

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







-- 2) Hipótese 2 (nova):
-- "Há médicos cuja maioria dos atendimentos resulta em cancelamento?"
-- Justificativa empresarial:
-- Identificar se certos médicos (ou especialidades) têm muitos cancelamentos pode indicar:
-- 
-- Problemas de agenda ou comunicação
-- 
-- Baixa confiança do paciente
-- 
-- Problemas operacionais na filial

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



-- 3) Hipótese 3:
-- "Quantos pacientes registrados nunca agendaram consulta?"
-- Justificativa empresarial:
-- Pacientes sem nenhuma consulta são clientes inativos, o que pode indicar:
-- 
-- Falha na captação ou comunicação
-- 
-- Problemas de acesso ou confiança
-- 
-- Oportunidade para ações de marketing ou CRM


-- Nao marcaram consultas pacientes mais novos? 

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
