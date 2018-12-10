

Select Battles.Faction, Battles.OpponentFaction, NumberOfBattles, 
	coalesce(NumberOfVictories,0) Victories, coalesce(Assassination,0) Assassination, coalesce(Scenario,0) ScenarioL, coalesce(DeathClock,0) DeathClock, coalesce(Concession,0) Concession, coalesce(TieBreakers,0) TieBreakers, coalesce(AverageCP,0) AverageCP, coalesce(AverageAPD,0) AverageAPD,
	coalesce(NumberOfLoses,0) Loses, coalesce(AssassinationL,0) AssassinationL, coalesce(ScenarioL,0) ScenarioL, coalesce(DeathClockL,0) DeathClockL, coalesce(ConcessionL,0) ConcessionL, coalesce(TieBreakersL,0) TieBreakersL, coalesce(AverageCPGiven,0) AverageCPGiven, coalesce(AverageAPDGiven,0) AverageAPDGiven
from
(
	select eventdate, faction, opponentfaction, count(id) as NumberOfBattles
	from PGSCrawl
	where faction <> ''
		and OpponentFaction <> ''
	group by eventdate, faction, OpponentFaction
	order by eventdate asc
) as Battles
LEFT JOIN
(
	select faction, opponentfaction, count(id) as NumberOfVictories, 
		coalesce(sum(case when condition = 'Assassination' then 1 end),0) as Assassination,
		coalesce(sum(case when condition = 'Scenario' then 1 end),0) as Scenario,
		coalesce(sum(case when condition = 'Death Clock' then 1 end),0) as DeathClock,
		coalesce(sum(case when condition = 'Concession' then 1 end),0) as Concession,
		coalesce(sum(case when condition = 'Tie Breakers' then 1 end),0) as TieBreakers,
		AVG(CP) as AverageCP,
		AVG(APD) as AverageAPD
	from PGSCrawl
	where faction <> ''
		and OpponentFaction <> ''
		and winner='true'
	group by faction, OpponentFaction
) as Victories
ON Battles.Faction = Victories.Faction
and Battles.OpponentFaction = Victories.OpponentFaction

LEFT JOIN
(
	select faction, opponentfaction, count(id) as NumberOfLoses, 
		coalesce(sum(case when condition = 'Assassination' then 1 end),0) as AssassinationL,
		coalesce(sum(case when condition = 'Scenario' then 1 end),0) as ScenarioL,
		coalesce(sum(case when condition = 'Death Clock' then 1 end),0) as DeathClockL,
		coalesce(sum(case when condition = 'Concession' then 1 end),0) as ConcessionL,
		coalesce(sum(case when condition = 'Tie Breakers' then 1 end),0) as TieBreakersL,
		AVG(OpponentCP) as AverageCPGiven,
		AVG(OpponentAPD) as AverageAPDGiven
	from PGSCrawl
	where faction <> ''
		and OpponentFaction <> ''
		and winner='false'
	group by faction, OpponentFaction
) as Loses
ON Battles.Faction = Loses.Faction
and Battles.OpponentFaction = Loses.OpponentFaction

	order by faction, OpponentFaction




	