#define ADMINHELP_DELAY 30 // 3 seconds
////////////////////////////////
/mob/verb/adminhelp()
	set category = "Commands"
	set name = "adminhelp"

	if (IsGuestKey(src.key))
		boutput(src, "You are not authorized to communicate over these channels.")
		gib(src)
		return

	if (client.cloud_available() && client.cloud_get("adminhelp_banner"))
		boutput(src, "You have been banned from using this command.")
		return

	if(src.client.last_adminhelp > (world.timeofday - ADMINHELP_DELAY))
		if(abs(world.timeofday - src.client.last_adminhelp) < 1000) // some midnight rollover protection b/c byond is fucking stupid
			boutput(src, "You must wait [round((src.client.last_adminhelp + ADMINHELP_DELAY - world.timeofday)/10)] seconds before requesting help again.")
			return

	var/msg = input("Please enter your help request to admins:") as null|text

	msg = copytext(html_encode(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	if (src.mind)
		src.mind.karma -= 1

//	for_no_raisin(usr, msg)

	if (src && src.client) src.client.last_adminhelp = world.timeofday

	for (var/mob/M in mobs)
		if (M.client && M.client.holder)
			if (M.client.player_mode && !M.client.player_mode_ahelp)
				continue
			else
				boutput(M, "<span style=\"color:blue\"><font size='3'><b><span style='color: red'>HELP: </span>[key_name(src,0,0)][(src.real_name ? "/"+src.real_name : "")] <A HREF='?src=\ref[M.client.holder];action=adminplayeropts;targetckey=[src.client.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: [msg]</font></span>")

#ifdef DATALOGGER
	game_stats.Increment("adminhelps")
	game_stats.ScanText(msg)
#endif
	boutput(usr, "<span style=\"color:blue\"><font size='3'><b><span style='color: red'>HELP: </span> You</b>: [msg]</font></span>")
	logTheThing("admin_help", src, null, "HELP: [msg]")
	logTheThing("diary", src, null, "HELP: [msg]", "ahelp")
	var/ircmsg[] = new()
	ircmsg["key"] = src.key
	ircmsg["name"] = src.real_name
	ircmsg["msg"] = html_decode(msg)
	ircbot.export("help", ircmsg)

/mob/verb/mentorhelp()
	set category = "Commands"
	set name = "mentorhelp"

	if (IsGuestKey(src.key))
		boutput(src, "You are not authorized to communicate over these channels.")
		gib(src)
		return

	if (client.cloud_available() && client.cloud_get("mentorhelp_banner"))
		boutput(src, "You have been banned from using this command.")
		return

	if(src.client.last_adminhelp > (world.timeofday - ADMINHELP_DELAY))
		if(abs(world.timeofday - src.client.last_adminhelp) < 1000) // some midnight rollover protection b/c byond is fucking stupid
			boutput(src, "You must wait [round((src.client.last_adminhelp + ADMINHELP_DELAY - world.timeofday)/10)] seconds before requesting help again.")
			return

	var/msg = input("Please enter your help request to mentors:") as null|text

	msg = copytext(strip_html(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	if (usr.client && usr.client.ismuted())
		return

	src.client.last_adminhelp = world.timeofday

	for (var/mob/M in mobs)
		if (M.client && M.client.holder)
			if (M.client.player_mode && !M.client.player_mode_mhelp)
				continue
			else
				boutput(M, "<span style='color:[mentorhelp_text_color]'><b>MENTORHELP: [key_name(src,0,0,1)][(src.real_name ? "/"+src.real_name : "")] <A HREF='?src=\ref[M.client.holder];action=adminplayeropts;targetckey=[src.client.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: <span class='message'>[msg]</span></span>")
		else if (M.client && M.client.can_see_mentor_pms())
			boutput(M, "<span style='color:[mentorhelp_text_color]'><b>MENTORHELP: [key_name(src,0,0,1)]</b>: <span class='message'>[msg]</span></span>")

	boutput(usr, "<span style='color:[mentorhelp_text_color]'><b>MENTORHELP: You</b>: [msg]</span>")
	logTheThing("mentor_help", src, null, "MENTORHELP: [msg]")
	logTheThing("diary", src, null, "MENTORHELP: [msg]", "mhelp")
	var/ircmsg[] = new()
	ircmsg["key"] = src.key
	ircmsg["name"] = src.real_name
	ircmsg["msg"] = html_decode(msg)
	ircbot.export("mentorhelp", ircmsg)

/mob/living/verb/pray()
	set category = "Commands"
	set name = "pray"
	set desc = "Attempt to gain the attention of a divine being. Note that it's not necessarily the kind of attention you want."
	if (IsGuestKey(src.key))
		boutput(src, "You are not authorized to communicate over these channels.")
		gib(src)
		return

	if(src.client.last_adminhelp > (world.timeofday - ADMINHELP_DELAY))
		if(abs(world.timeofday - src.client.last_adminhelp) < 1000) // some midnight rollover protection b/c byond is fucking stupid
			boutput(src, "You must wait [round((src.client.last_adminhelp + ADMINHELP_DELAY - world.timeofday)/10)] seconds before requesting help again.")
			return

	var/msg = input("Please enter your prayer to any gods that may be listening - be careful what you wish for as the gods may be the vengeful sort!") as null|text

	msg = copytext(strip_html(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	if (src.mind)
		src.mind.karma -= 1

	src.client.last_adminhelp = world.timeofday
	boutput(src, "<B>You whisper a silent prayer,</B> <I>\"[msg]\"</I>")
	logTheThing("admin_help", src, null, "PRAYER: [msg]")
	logTheThing("diary", src, null, "PRAYER: [msg]", "ahelp")
	for (var/mob/M in mobs)
		if (M.client && M.client.holder)
			if (!M.client.holder.hear_prayers || (M.client.player_mode == 1 && M.client.player_mode_ahelp == 0)) //XOR for admin prayer setting and player mode w/ no ahelps
				continue
			else
				boutput(M, "<span style=\"color:blue\"><B>PRAYER: </B><a href='?src=\ref[M.client.holder];action=subtlemsg&targetckey=[usr.ckey]'>[usr.key]</a> / [usr.real_name ? usr.real_name : usr.name] <A HREF='?src=\ref[M.client.holder];action=adminplayeropts;targetckey=[src.client.ckey]' class='popt'><i class='icon-info-sign'>: <I>[msg]</I></span>")


/proc/do_admin_pm(var/C, var/mob/user) //C is a passed ckey

	var/mob/M = whois_ckey_to_mob_reference(C)
	if(M)
		if (!( ismob(M) ))
			return
		if (!user || !user.client)
			return

		if (!user.client.holder && !(M.client && M.client.holder))
			return

		var/t = input("Message:", text("Private message to [admin_key(M.client, 1)]")) as null|text
		if(!(user && user.client && user.client.holder && user.client.holder.rank in list("Host", "Coder")))
			t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN)
		if (!( t ))
			return

		if (user.client.holder)
			// Sender is admin
			boutput(M, {"
				<div style='border: 2px solid red; font-size: 110%;'>
					<div style="background: #f88; font-weight: bold; border-bottom: 1px solid red; text-align: center; padding: 0.2em 0.5em;">
						Admin PM from [key_name(user, 0, 0)]
					</div>
					<div style="padding: 0.2em 0.5em;">
					[t]
					</div>
					<div style="font-size: 90%; background: #fcc; font-weight: bold; border-top: 1px solid red; text-align: center; padding: 0.2em 0.5em;">
						<a href=\"byond://?action=priv_msg&target=[user.ckey]" style='color: #833; font-weight: bold;'>&lt; Click to Reply &gt;</a></div>
					</div>
				</div>
				"})
			M << sound('sound/misc/adminhelp.ogg', volume=100, wait=0)
			boutput(user, "<span style=\"color:blue\" class=\"bigPM\">Admin PM to-<b>[key_name(M, 0, 0)][(M.real_name ? "/"+M.real_name : "")] <A HREF='?src=\ref[user.client.holder];action=adminplayeropts;targetckey=[M.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: [t]</span>")
		else
			// Sender is not admin
			if (M.client && M.client.holder)
				// But recipient is
				boutput(M, "<span style=\"color:blue\" class=\"bigPM\">Reply PM from-<b>[key_name(user, 0, 0)][(user.real_name ? "/"+user.real_name : "")] <A HREF='?src=\ref[M.client.holder];action=adminplayeropts;targetckey=[user.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: [t]</span>")
				M << sound('sound/misc/adminhelp.ogg', volume=100, wait=0)
			else
				boutput(M, "<span style=\"color:red\" class=\"bigPM\">Reply PM from-<b>[key_name(user, 0, 0)]</b>: [t]</span>")
				M << sound('sound/misc/adminhelp.ogg', volume=100, wait=0)
			boutput(user, "<span style=\"color:blue\" class=\"bigPM\">Reply PM to-<b>[key_name(M, 0, 0)]</b>: [t]</span>")

		logTheThing("admin_help", user, M, "<b>PM'd %target%</b>: [t]")
		logTheThing("diary", user, M, "PM'd %target%: [t]", "ahelp")

		var/ircmsg[] = new()
		ircmsg["key"] = user && user.client ? user.client.key : ""
		ircmsg["name"] = user.real_name
		ircmsg["key2"] = (M != null && M.client != null && M.client.key != null) ? M.client.key : ""
		ircmsg["name2"] = (M != null && M.real_name != null) ? M.real_name : ""
		ircmsg["msg"] = html_decode(t)
		ircbot.export("pm", ircmsg)

		//we don't use message_admins here because the sender/receiver might get it too
		for (var/mob/K in mobs)
			if(K && K.client && K.client.holder && K.key != user.key && (M && K.key != M.key))
				if (K.client.player_mode && !K.client.player_mode_ahelp)
					continue
				else
					boutput(K, "<font color='blue'><b>PM: [key_name(user,0,0)][(user.real_name ? "/"+user.real_name : "")] <A HREF='?src=\ref[K.client.holder];action=adminplayeropts;targetckey=[user.ckey]' class='popt'><i class='icon-info-sign'></i></A> <i class='icon-arrow-right'></i> [key_name(M,0,0)][(M.real_name ? "/"+M.real_name : "")] <A HREF='?src=\ref[K.client.holder];action=adminplayeropts;targetckey=[M.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: [t]</font>")
