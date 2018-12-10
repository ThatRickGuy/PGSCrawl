select * from pgscrawl 
select distinct cccode from (
select winnercccode as CCCode from pgscrawl where WinnerCCCode <> '' and winnercaster1 = ''
union 
select OpponentCCCode as CCCode from pgscrawl where OpponentCCCode <> '' and opponentcaster1 = '') tbl1


        

select distinct cccode 
from
(select distinct winnercaster1 as CCCode from pgscrawl where WinnerCCCode <> ''
union
select OpponentCCCode as CCCode from pgscrawl where OpponentCCCode <> '') tbl1


select winnercaster1, winnercaster2, count(id) as NumberOfWins
from pgscrawl
group by winnercaster1, winnercaster2



select 
	case when tblWinner.Caster1 <> null then tblWinner.Caster1 else tblOpponent.Caster1 end as Caster1,
	case when tblWinner.Caster2 <> null then tblWinner.Caster2 else tblOpponent.Caster2 end as Caster2,
	coalesce(NumberOfWins,0) as NumberOfWins,
	coalesce(NumberOfLosses,0) as NumberOfLosses,
	tblWinner.caster1,tblWinner.caster2,
	tblOpponent.caster1,tblOpponent.caster2
from
(
select case when (Winnercaster1<Winnercaster2) then Winnercaster1 else Winnercaster2 end as caster1,
	   case when (Winnercaster1<Winnercaster2) then Winnercaster2 else Winnercaster1 end as caster2, 
	   count(id) as NumberOfWins
from pgscrawl
group by case when (Winnercaster1<Winnercaster2) then Winnercaster1 else Winnercaster2 end,
	   case when (Winnercaster1<Winnercaster2) then Winnercaster2 else Winnercaster1 end  
) as tblWinner
FULL OUTER JOIN
(
select case when (opponentcaster1<opponentcaster2) then opponentcaster1 else opponentcaster2 end as caster1,
	   case when (opponentcaster1<opponentcaster2) then opponentcaster2 else opponentcaster1 end as caster2, 
	   count(id) as NumberOfLosses
from pgscrawl
group by case when (opponentcaster1<opponentcaster2) then opponentcaster1 else opponentcaster2 end,
	   case when (opponentcaster1<opponentcaster2) then opponentcaster2 else opponentcaster1 end  
) as tblOpponent
ON tblWinner.caster1 = tblOpponent.caster1
and tblWinner.caster2 = tblOpponent.caster2


select * from pgscrawl where (OpponentCaster1 = 'Kozlov 1' and OpponentCaster2 = 'Vladimir 2') or (OpponentCaster2 = 'Kozlov 1' and OpponentCaster1 = 'Vladimir 2')
select * from pgscrawl where (WinnerCaster1 = 'Kozlov 1' and WinnerCaster2 = 'Vladimir 2') or (WinnerCaster2 = 'Kozlov 1' and WinnerCaster1 = 'Vladimir 2')

select * from PGSCrawl where eventid='c194cb55-15c3-416a-ae52-57a3844007d1'

select * from PGSCrawl where winnerfaction = OpponentFaction and winnermeta = opponentmeta and WinnerCCCode = OpponentCCCode order by eventdate, roundnumber


Select top 1 * from pgscrawl


select faction, theme, caster, count(*)
from 
(
select winnerfaction as faction, winnertheme1 as theme, winnercaster1 as caster from PGSCrawl 
union all
select winnerfaction as faction, winnertheme2 as theme, winnercaster2 as caster from PGSCrawl 
union all
select OpponentFaction as faction, OpponentTheme1 as theme, OpponentCaster1 as caster from PGSCrawl  
union all
select OpponentFaction as faction, OpponentTheme2 as theme, OpponentCaster2 as caster from PGSCrawl
) tbl1
group by faction, theme, caster
order by count(*) desc

select * from 
--update 
PGSCrawl 
--set WinnerCaster1 = '', WinnerCaster2 = '', OpponentCaster1 = '', OpponentCaster2 = ''
where WinnerCaster1 = 'Grayle 1' or WinnerCaster2 = 'Grayle 1' or 
	  OpponentCaster1 = 'Grayle 1' or OpponentCaster2 = 'Grayle 1'


select count(*) from PGSCrawl --Total Games Recorded: 3012 
select count(*) from PGSCrawl where WinnerCaster1 <> '' or OpponentCaster1 <> '' --Total Pre-registered Games: 858
select count(*) from PGSCrawl where EventDate > '2016-07-01' and EventDate <= '2017-07-16' -- SR2016 Games Recorded: 0
--SR2017
select count(*) from PGSCrawl where EventDate > '2017-07-16' and EventDate <= '2018-06-25' -- SR2017 Games Recorded: 2743
select count(*) from PGSCrawl where EventDate > '2017-07-16' and EventDate <= '2018-06-25' and (WinnerCaster1 <> '' or OpponentCaster1 <> '') -- SR2017 Games Recorded with prereg: 781

--SR2018
select count(*) from PGSCrawl where EventDate > '2018-06-25' and EventDate <= '2019-07-01' -- SR2018 Games Recorded: 269

select count(*) from PGSCrawl where EventDate > '2018-06-25' and EventDate <= '2019-07-01' and (WinnerCaster1 <> '' or OpponentCaster1 <> '') -- SR2017 Games Recorded with prereg: 77

select * --yearmonth, [Circle Orboros], [Convergence of Cyriss], [Crucible Guard], Cryx, Cygnar, Grymkin, Khador, [Legion of Everblight], Mercenaries, Minions, [Protectorate of Menoth], [Retribution of Scyrah], Skorne, Trollbloods
from 
(
	select * 
	from
	(
		select winnerfaction as Faction, cast(datepart(yyyy,eventdate) as varchar(4)) + '-' + dbo.LPAD(cast(datepart(mm,eventdate) as varchar(2)),2,'0') + '-01' as yearmonth from PGSCrawl
		union all
		select opponentfaction as Faction, cast(datepart(yyyy,eventdate) as varchar(4)) + '-' + dbo.LPAD(cast(datepart(mm,eventdate) as varchar(2)),2,'0') + '-01' as yearmonth from PGSCrawl
	) tbl1
) src
pivot
(
	count(faction)
	for faction in ([Circle Orboros], [Convergence of Cyriss], [Crucible Guard], Cryx, Cygnar, Grymkin, Khador, [Legion of Everblight], Mercenaries, Minions, [Protectorate of Menoth], [Retribution of Scyrah], Skorne, Trollbloods)
) piv


update PGSCrawl set opponentfaction = 'Trollbloods' where opponentfaction = 'Trollblood'

select PGSCrawl.Scenario, PGSCrawl.Condition, count(*) from PGSCrawl where EventDate > '2017-06-25' and EventDate <= '2018-07-01' group by Scenario, Condition order by Scenario, Condition -- SR2016 Game Results by Scenario: 

select * from pgscrawl where opponentfaction = ''
delete from pgscrawl where winnerfaction = ''

tcp:s11.winhost.com
DB_98488_ringdev_user

select wins.WinnerFaction, wins.OpponentFaction--, coalesce(wins,0) / (coalesce(wins,0)+coalesce(losses,0) +0.0) as WinPercent 
from 
(
select WinnerFaction, OpponentFaction, count(*) as Wins
from pgscrawl
group by WinnerFaction, OpponentFaction
) wins
full outer join
(
select OpponentFaction, WinnerFaction, count(*) as Losses
from PGSCrawl
group by OpponentFaction, WinnerFaction
) losses
on losses.OpponentFaction = wins.WinnerFaction
and losses.WinnerFaction = wins.OpponentFaction
where wins.OpponentFaction != ''
order by wins.WinnerFaction, wins.OpponentFaction

select * from PGSCrawl where WinnerFaction='Crucible Guard' or OpponentFaction='Crucible Guard'


select allgames.faction1, allgames.faction2, allgames.TotalGames, count(wins.GameID) as wins
from 
(
	select faction1, faction2, count(*) as TotalGames
	from
	(
		 select winnerfaction as faction1, opponentfaction as faction2 from PGSCrawl where EventDate > '2018-04-1' 
 		 union all
		 select opponentfaction as faction1, winnerfaction as faction1 from pgscrawl where EventDate > '2018-04-1' 
	) tbl
	group by faction1, faction2
) allgames
left join PGSCrawl wins
	on faction1 = wins.WinnerFaction and faction2 = wins.OpponentFaction
	and EventDate > '2018-04-1'
where faction1 <> '' and faction2 <> ''
group by faction1, faction2, TotalGames
order by faction1, faction2