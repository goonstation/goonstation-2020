

var/global/it_is_ass_day = ASS_JAM //set the BUILD_TIME_DAY in __build.dm to 13 for this to be true ~ Warcrimes

// called in world.New()
//proc/is_it_ass_day() // not the fuck any more ~ Warc
/*
#ifdef RP_MODE
	it_is_ass_day = 0
#else
	if (text2num(time2text(world.realtime, "DD")) == 13)
		it_is_ass_day = 1
	else
		it_is_ass_day = 0
#endif
*/

/client/proc/cmd_ass_day_rules()
	set name = "Ass Day Rules"
	set category = "Commands"

#ifdef TWITCH_BOT_ALLOWED
	src.Browse({"<center><h2>!!! ASS DAY !!!</h2></center><hr>

				SPECIAL ANNOUNCEMENT : For this ass day, you can control shitty bill through our Twitch stream!
				<br>
				Join in at : <a href="https://www.twitch.tv/itsmethewonk">https://www.twitch.tv/itsmethewonk</a>
				<br><br>

				You have joined us for Ass Day, an event that occurs on the 13th of every month. During this time, the rules and their enforcement are heavily relaxed on this server. If you choose to join the game, expect complete and total chaos, rampant grief, and levels of violence that would make Joe Pesci cry. Of course, there's nothing stopping you from causing all that yourself if you choose to.<br><br>
				Bear in mind that a few rules are still in effect, however:<br>
				<ol>
					<li>No intentionally crashing the server or causing lag.</li>
					<li>No bigotry.</li>
					<li>No sexual stuff.</li>
					<li>No creepy shit.</li>
					<li>No impersonating the admins.</li>
					<li>No walling off or obliterating arrivals.</li>
					<li>No giving out secret recipes and the like.</li>
					<li>If an admin tells you to quit doing something, quit it.</li>
					<li>No you do not get an antag token.</li>
				</ol>
				If you do not see this popup, that means it is not Ass Day. Rule-breakers invoking Ass Day when it is not Ass Day will be dealt with incredibly severely, so don't fuck this up! A good rule of thumb to keep in mind - Ass Day begins and ends when the admins or the game itself say it is, not when you say it is.<br><br>
				Does all this sound like it doesn't appeal to you? No problem, Ass Day is a feature of our non-RP server only, so if you'd like a bit of peace and quiet go ahead and check the RP server out. We won't mind.<br>
				"}, "window=assday;size=500x650;title=ASS DAY;fade_in=1")
#else
	src.Browse({"<center><h2>!!! ASS DAY !!!</h2></center><hr>
				You have joined us for Ass Day, an event that occurs on the 13th of every month. During this time, the rules and their enforcement are heavily relaxed on this server. If you choose to join the game, expect complete and total chaos, rampant grief, and levels of violence that would make Joe Pesci cry. Of course, there's nothing stopping you from causing all that yourself if you choose to.<br><br>
				Bear in mind that a few rules are still in effect, however:<br>
				<ol>
					<li>No intentionally crashing the server or causing lag.</li>
					<li>No bigotry.</li>
					<li>No sexual stuff.</li>
					<li>No creepy shit.</li>
					<li>No impersonating the admins.</li>
					<li>No walling off or obliterating arrivals.</li>
					<li>No giving out secret recipes and the like.</li>
					<li>If an admin tells you to quit doing something, quit it.</li>
					<li>No you do not get an antag token.</li>
				</ol>
				If you do not see this popup, that means it is not Ass Day. Rule-breakers invoking Ass Day when it is not Ass Day will be dealt with incredibly severely, so don't fuck this up! A good rule of thumb to keep in mind - Ass Day begins and ends when the admins or the game itself say it is, not when you say it is.<br><br>
				Does all this sound like it doesn't appeal to you? No problem, Ass Day is a feature of our non-RP server only, so if you'd like a bit of peace and quiet go ahead and check the RP server out. We won't mind.<br>
				"}, "window=assday;size=500x650;title=ASS DAY;fade_in=1")
#endif



