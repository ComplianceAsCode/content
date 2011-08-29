#Example 2, Set and Filter
definition One-Root-User {
	@class="compliance"
	metadata {
		title="Only One Root User Exists"
		affected { platform="RedHat Enterprise Linux" @family="unix" }		
		description="Ensure only root has a uid of 0."
	}
	criteria {
		@comment="Only root has uid of 0."
		test<=root_uid
	}
}

test unix:password root_uid {
	@comment="Get all users with uid equal to 0 and ensure the username is root."
	@check="all"
	object<=uid_zero_users
	state {
		username="root"
	}
}

object unix:password uid_zero_users {
	@comment="Get all users and filter out uids that are not equal to 0."
	set {
		object<=all_users
		state<=non_root_uids
	}
}

object unix:password all_users {
	@comment="Get all entries in /etc/passwd"
	username=".*" {@operation="pattern match"}
}

state unix:password non_root_uids {
	@comment="Used to filter out all uids not equal to 0."
	user_id="[1-9]" {@operation="pattern match"}
}
#End Example 2

