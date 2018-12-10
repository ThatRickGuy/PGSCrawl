select faction, caster1, theme1, caster2, theme2, sum(game) as games, round(sum(win)*1.0 / sum(game),2) as winrate
from
(
select	winnerfaction as Faction, 
		case when winnercaster1 < winnercaster2 then winnercaster1 else winnercaster2 end as Caster1, 
		case when winnercaster1 < winnercaster2 then winnercaster2 else winnercaster1 end as Caster2,
		case when winnercaster1 < winnercaster2 then winnertheme1 else winnertheme2 end as Theme1, 
		case when winnercaster1 < winnercaster2 then winnertheme2 else winnertheme1 end as Theme2,
		1 as win, 1 as game
from pgscrawl
union all
select	Opponentfaction as Faction, 
		case when Opponentcaster1 < Opponentcaster2 then Opponentcaster1 else Opponentcaster2 end as Caster1, 
		case when Opponentcaster1 < Opponentcaster2 then Opponentcaster2 else Opponentcaster1 end as Caster2,
		case when Opponentcaster1 < Opponentcaster2 then Opponenttheme1 else Opponenttheme2 end as Theme1, 
		case when Opponentcaster1 < Opponentcaster2 then Opponenttheme2 else Opponenttheme1 end as Theme2,
		0 as win, 1 as game
from pgscrawl
) tbl
where caster1<>'' or caster2<>''
group by faction, caster1, theme1, caster2, theme2
order by faction, caster1, theme1, caster2, theme2


select 1 as Win,
	Condition,
	Length,
	WinnerAPD as Faction1APD,
	WinnerCP as Faction1CP,
	WinnerCaster1 as Faction1Caster1,
	WinnerCaster2 as Faction1Caster1,
	WinnerTheme1 as Faction1Theme1,
	WinnerTheme2 as Faction1Theme2,
	WinnerCCCode as Faction1CCCode,
	OpponentAPD as Faction2APD,
	OpponentCP as Faction2CP,
	OpponentCaster1 as Faction2Caster1,
	OpponentCaster2 as Faction2Caster1,
	OpponentTheme1 as Faction2Theme1,
	OpponentTheme2 as Faction2Theme2,
	OpponentCCCode as Faction2CCCode
from pgscrawl
where WinnerFaction = 'Cryx'
and OpponentFaction = 'Khador'
and eventdate >= ''
and eventdate <= ''
union all
select 0 as Win,
	Condition,
	Length,
	OpponentAPD as Faction1APD,
	OpponentCP as Faction1CP,
	OpponentCaster1 as Faction1Caster1,
	OpponentCaster2 as Faction1Caster1,
	OpponentTheme1 as Faction1Theme1,
	OpponentTheme2 as Faction1Theme2,
	OpponentCCCode as Faction1CCCode,
	WinnerAPD as Faction2APD,
	WinnerCP as Faction2CP,
	WinnerCaster1 as Faction2Caster1,
	WinnerCaster2 as Faction2Caster1,
	WinnerTheme1 as Faction2Theme1,
	WinnerTheme2 as Faction2Theme2,
	WinnerCCCode as Faction2CCCode
from pgscrawl
where WinnerFaction = 'Khador'
and OpponentFaction = 'Cryx'
and eventdate >= ''
and eventdate <= ''


select * from pgscrawl where opponentfaction='trollblood'
update pgscrawl set opponentfaction = 'Trollbloods' where opponentfaction = 'trollblood'

select distinct condition from PGSCrawl