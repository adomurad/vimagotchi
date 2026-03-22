return {
	check = function()
		vim.health.start("vimagotchi.nvim")

		vim.health.info([[VIMAGOTCHI healthcheck]])

		vim.health.ok("Vimagotchi is healthy :)")
	end,
}
