select scenario, count(id)/2 as gamecount, 
	coalesce(sum(case when length = 1 then 1 end),0) as Round1,
		coalesce(sum(case when condition = 'Assassination' and length = 1 then 1 end),0) as Round1Assassinations,
		coalesce(sum(case when condition = 'Scenario' and length = 1 then 1 end),0) as Round1Scenarios,
		coalesce(sum(case when condition = 'Death Clock' and length = 1 then 1 end),0) as Round1DeathClocks,
		coalesce(sum(case when condition = 'Concession' and length =1 then 1 end),0)  as Round1Concession,
	coalesce(sum(case when length = 2 then 1 end),0) as Round2,
		coalesce(sum(case when condition = 'Assassination' and length = 2 then 1 end),0) as Round2Assassinations,
		coalesce(sum(case when condition = 'Scenario' and length = 2 then 1 end),0) as Round2Scenarios,
		coalesce(sum(case when condition = 'Death Clock' and length = 2 then 1 end),0) as Round2DeathClocks,
		coalesce(sum(case when condition = 'Concession' and length = 2 then 1 end),0)  as Round2Concession,
	coalesce(sum(case when length = 3 then 1 end),0) as Round3,
		coalesce(sum(case when condition = 'Assassination' and length = 3 then 1 end),0) as Round3Assassinations,
		coalesce(sum(case when condition = 'Scenario' and length = 3 then 1 end),0) as Round3Scenarios,
		coalesce(sum(case when condition = 'Death Clock' and length = 3 then 1 end),0) as Round3DeathClocks,
		coalesce(sum(case when condition = 'Concession' and length = 3 then 1 end),0)  as Round3Concession,
	coalesce(sum(case when length = 4 then 1 end),0) as Round4,
		coalesce(sum(case when condition = 'Assassination' and length = 4 then 1 end),0) as Round4Assassinations,
		coalesce(sum(case when condition = 'Scenario' and length = 4 then 1 end),0) as Round4Scenarios,
		coalesce(sum(case when condition = 'Death Clock' and length = 4 then 1 end),0) as Round4DeathClocks,
		coalesce(sum(case when condition = 'Concession' and length = 4 then 1 end),0)  as Round4Concession,
	coalesce(sum(case when length = 5 then 1 end),0) as Round5,
		coalesce(sum(case when condition = 'Assassination' and length = 5 then 1 end),0) as Round5Assassinations,
		coalesce(sum(case when condition = 'Scenario' and length =5 then 1 end),0) as Round5Scenarios,
		coalesce(sum(case when condition = 'Death Clock' and length = 5 then 1 end),0) as Round5DeathClocks,
		coalesce(sum(case when condition = 'Concession' and length = 5 then 1 end),0)  as Round5Concession,
	coalesce(sum(case when length = 6 then 1 end),0) as Round6,
		coalesce(sum(case when condition = 'Assassination' and length = 6 then 1 end),0) as Round6Assassinations,
		coalesce(sum(case when condition = 'Scenario' and length = 6 then 1 end),0) as Round6Scenarios,
		coalesce(sum(case when condition = 'Death Clock' and length = 6 then 1 end),0) as Round6DeathClocks,
		coalesce(sum(case when condition = 'Concession' and length = 6 then 1 end),0)  as Round6Concession,
	coalesce(sum(case when length = 7 then 1 end),0) as Round7,
		coalesce(sum(case when condition = 'Assassination' and length = 7 then 1 end),0) as Round7Assassinations,
		coalesce(sum(case when condition = 'Scenario' and length = 7 then 1 end),0) as Round7Scenarios,
		coalesce(sum(case when condition = 'Death Clock' and length = 7 then 1 end),0) as Round7DeathClocks,
		coalesce(sum(case when condition = 'Concession' and length = 7 then 1 end),0)  as Round7Concession,
		coalesce(sum(case when condition = 'Tie Breakers' and length = 7 then 1 end),0)  as Round7TieBreakers
from pgscrawl
where faction <> ''
and length > 0
group by scenario
order by Scenario

select distinct condition from PGSCrawl

select Scenario,count(id)/2 as gamecount, 
		round(cast(coalesce(sum(case when condition = 'Assassination' then 1 end),0) as float)/cast(count(id) as float),4) as Assassinations,
		round(cast(coalesce(sum(case when condition = 'Scenario' then 1 end),0) as float)/cast(count(id) as float),4) as Scenarios,
		round(cast(coalesce(sum(case when condition = 'Death Clock' then 1 end),0) as float)/cast(count(id) as float),4) as DeathClocks,
		round(cast(coalesce(sum(case when condition = 'Concession' then 1 end),0) as float)/cast(count(id) as float),4) as Concession,
		round(cast(coalesce(sum(case when condition = 'Tie Breakers' then 1 end),0) as float)/cast(count(id) as float),4) as TieBreakers
from pgscrawl
where faction <> ''
and length > 0
group by scenario
order by Scenario


delete from PGSCrawl where Condition = ''
delete from PGSCrawl where Condition = 'Disqualification'
delete from pgscrawl where gameid='c458a509-a212-4e66-ab2c-b8633e1d1e0f'
update PGSCrawl set faction = 'Trollbloods' where faction = 'Trollblood'
update PGSCrawl set opponentfaction = 'Trollbloods' where opponentfaction = 'Trollblood'
select distinct faction from PGSCrawl where faction like 'troll%'

