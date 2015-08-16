/obj/machinery/computer/shuttle
	name = "Shuttle"
	desc = "For shuttle control."
	icon_keyboard = "tech_key"
	icon_screen = "shuttle"
	var/auth_need = 3.0
	var/list/authorized = list(  )

	light_color = LIGHT_COLOR_CYAN


	attackby(var/obj/item/weapon/card/W as obj, var/mob/user as mob, params)
		if(stat & (BROKEN|NOPOWER))	return
		if ((!( istype(W, /obj/item/weapon/card) ) || !( ticker ) || emergency_shuttle.location() || !( user )))	return
		if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
			if (istype(W, /obj/item/device/pda))
				var/obj/item/device/pda/pda = W
				W = pda.id
			if (!W:access) //no access
				user << "The access level of [W:registered_name]\'s card is not high enough. "
				return

			var/list/cardaccess = W:access
			if(!istype(cardaccess, /list) || !cardaccess.len) //no access
				user << "The access level of [W:registered_name]\'s card is not high enough. "
				return

			if(!(access_heads in W:access)) //doesn't have this access
				user << "The access level of [W:registered_name]\'s card is not high enough. "
				return 0

			var/choice = alert(user, text("Would you like to (un)authorize a shortened launch time? [] authorization\s are still needed. Use abort to cancel all authorizations.", src.auth_need - src.authorized.len), "Shuttle Launch", "Authorize", "Repeal", "Abort")
			if(emergency_shuttle.location() && user.get_active_hand() != W)
				return 0
			switch(choice)
				if("Authorize")
					src.authorized -= W:registered_name
					src.authorized += W:registered_name
					if (src.auth_need - src.authorized.len > 0)
						message_admins("[key_name_admin(user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) ([admin_jump_link(user, "holder")]) has authorized early shuttle launch ",0,1)
						log_game("[key_name(user)] has authorized early shuttle launch in ([x],[y],[z])")
						world << text("\blue <B>Alert: [] authorizations needed until shuttle is launched early</B>", src.auth_need - src.authorized.len)
					else
						message_admins("[key_name_admin(user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) ([admin_jump_link(user, "holder")]) has launched the emergency shuttle before launch.",0,1)
						log_game("[key_name(user)] has launched the emergency shuttle before launch in ([x],[y],[z]).")
						world << "\blue <B>Alert: Shuttle launch time shortened to 10 seconds!</B>"
						emergency_shuttle.set_launch_countdown(10)
						//src.authorized = null
						qdel(src.authorized)
						src.authorized = list(  )

				if("Repeal")
					src.authorized -= W:registered_name
					world << text("\blue <B>Alert: [] authorizations needed until shuttle is launched early</B>", src.auth_need - src.authorized.len)

				if("Abort")
					world << "\blue <B>All authorizations to shortening time for shuttle launch have been revoked!</B>"
					src.authorized.len = 0
					src.authorized = list(  )
		return

	emag_act(mob/user as mob)
		if (!emagged)
			var/choice = alert(user, "Would you like to launch the shuttle?","Shuttle control", "Launch", "Cancel")

			if(!emagged && !emergency_shuttle.location())
				switch(choice)
					if("Launch")
						message_admins("[key_name_admin(user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) ([admin_jump_link(user, "holder")]) has emagged the emergency shuttle before launch.",0,1)
						log_game("[key_name(user)] has emagged the emergency shuttle in ([x],[y],[z]) before launch.")
						world << "\blue <B>Alert: Shuttle launch time shortened to 10 seconds!</B>"
						emergency_shuttle.set_launch_countdown(10)
						emagged = 1
					if("Cancel")
						return
