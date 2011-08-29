definition telnet-server-installed {
	@class="inventory"
	metadata {
		title="Package telnet-server is Installed"
		affected {
			platform="Red Hat Enterprise Linux"
			@family="unix"
		}
		description="Check if telnet-server is installed"
	}
	criteria {
		@comment="Check if package telnet-server is installed"
		test linux:rpminfo telnet-server {
			@check="all"
			@check_existence="all_exist"
			@comment="Check if telnet-server is installed."
			object {
				name="telnet-server"
			}
		}
	}
}
