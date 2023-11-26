# HOW TO INSTALL WALLET SCRIPT?

# DEPENDENCIES:
ox_inventory
es_extended

# First step:
Go into ox_inventory/web/images and put wallet.png into folder. You can find image in inventory-image folder.

# Second step:
Go into ox_inventory/data/items.lua and add this:

	['wallet'] = {
		label = 'Wallet',
		weight = 120,
		stack = false,
		consume = 0,
		client = {
			export = 'wasabi_wallet.openWallet'
		}
	},

# Third step:
Go into ox_inventory/modules/items/containers.lua and add this.
You can configurate how many slots you want, how much weight, whitelisted items (Like money, your license, documents etc..) 

	setContainerProperties('wallet', {
		slots = 5,
		maxWeight = 100,
		whitelist = { 'money', 'driver_license', 'weaponlicense', 'lawyerpass', 'membership', 'id_card' } 
	})

# Fourth step:
Put all files into resources folder

# Fifth step:
Go into server.cfg and add this line:

ensure grn_wallet

# Sixth step:
Restart your server and enjoy, you have functional wallet script!

