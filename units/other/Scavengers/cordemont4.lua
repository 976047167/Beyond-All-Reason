return {
	cordemont4 = {
		acceleration = 0.2208,
		brakerate = 1,
		buildcostenergy = 1600000,
		buildcostmetal = 16000,
		buildpic = "CORKARG.PNG",
		buildtime = 100609,
		canmove = true,
		category = "BOT WEAPON ALL NOTSUB NOTAIR NOTHOVER SURFACE EMPABLE",
		collisionvolumeoffsets = "0.0 -2.0 1",
		collisionvolumescales = "56.0 60.0 40.0",
		collisionvolumetype = "box",
		corpse = "DEAD",
		description = "All-Terrain BRRRRRT Mech",
		explodeas = "explosiont3med",
		footprintx = 4,
		footprintz = 4,
		idleautoheal = 5,
		idletime = 1800,
		mass = 200000,
		maxdamage = 50000,
		maxslope = 160,
		maxvelocity = 3,
		maxwaterdepth = 12,
		movementclass = "HTBOT4",
		name = "Demon",
		nochasecategory = "VTOL",
		objectname = "Units/scavboss/cordemont4.s3o",
		script = "Units/scavboss/cordemont4.COB",
		seismicsignature = 0,
		selfdestructas = "explosiont3",
		sightdistance = 500,
		turninplace = true,
		turninplaceanglelimit = 90,
		turninplacespeedlimit = 0.99,
		turnrate = 607.20001,
		upright = true,
		customparams = {
			model_author = "FireStorm",
			normaltex = "unittextures/cor_normal.dds",
			subfolder = "corgantry",
			techlevel = 3,
		},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "3.89811706543 -12.9994070068 -38.2052841187",
				collisionvolumescales = "77.9624938965 23.0893859863 76.4105682373",
				collisionvolumetype = "Box",
				damage = 1200,
				description = "Demon Wreckage",
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 3,
				footprintz = 3,
				height = 40,
				hitdensity = 100,
				metal = 1014,
				object = "Units/scavboss/cordemont4_dead.s3o",
				reclaimable = true,
				world = "All Worlds",
			},
		},
		sfxtypes = {
			pieceexplosiongenerators = {
				[1] = "deathceg2",
				[2] = "deathceg3",
				[3] = "deathceg4",
			},
		},
		sounds = {
			canceldestruct = "cancel2",
			underattack = "warning1",
			cant = {
				[1] = "cantdo4",
			},
			count = {
				[1] = "count6",
				[2] = "count5",
				[3] = "count4",
				[4] = "count3",
				[5] = "count2",
				[6] = "count1",
			},
			ok = {
				[1] = "mavbok1",
			},
			select = {
				[1] = "mavbsel1",
			},
		},
		weapondefs = {
			--karg_head = {
			--	areaofeffect = 16,
			--	avoidfeature = false,
			--	burnblow = true,
			--	canattackground = false,
			--	cegtag = "missiletrailaa",
			--	craterareaofeffect = 0,
			--	craterboost = 0,
			--	cratermult = 0,
			--	edgeeffectiveness = 0.15,
			--	explosiongenerator = "custom:genericshellexplosion-tiny-aa",
			--	firestarter = 72,
			--	flighttime = 1.75,
			--	impulseboost = 0,
			--	impulsefactor = 0,
			--	model = "cormissile.s3o",
			--	name = "HeadRockets",
			--	noselfdamage = true,
			--	proximitypriority = -1,
			--	range = 650,
			--	reloadtime = 4,
			--	smoketrail = false,
			--	soundhit = "packohit",
			--	soundhitwet = "splshbig",
			--	soundstart = "packolau",
			--	soundtrigger = true,
			--	startvelocity = 480,
			--	texture1 = "trans",
			--	texture2 = "coresmoketrail",
			--	tolerance = 9950,
			--	tracks = true,
			--	turnrate = 68000,
			--	turret = true,
			--	weaponacceleration = 200,
			--	weapontimer = 2,
			--	weapontype = "MissileLauncher",
			--	weaponvelocity = 900,
			--	customparams = {
			--		expl_light_color = "1 0.4 0.5",
			--		expl_light_mult = 0.4,
			--		expl_light_radius_mult = 0.66,
			--		light_color = "1 0.5 0.6",
			--		light_skip = true,
			--	},
			--	damage = {
			--		bombers = 150,
			--		fighters = 120,
			--		vtol = 150,
			--	},
			--},
			machinegun                   = {
				accuracy				 = 50,
				AreaOfEffect             = 25,
				avoidFriendly            = false,
				avoidFeature             = false,
				collideFriendly          = false,
				collideFeature           = true,
				beamTime                 = 0.1,
				coreThickness            = 0.5,
				duration                 = 0.1,
				explosionGenerator       = "custom:genericshellexplosion-tiny-aa",
				energypershot            = 0,
				fallOffRate              = 0,
				fireStarter              = 50,
				interceptedByShieldType  = 4,
				minintensity             = "1",
				name                     = "Machine Gun",
				range                    = 750,
				reloadtime               = 0.1,
				WeaponType               = "LaserCannon",
				rgbColor                 = "0.95 0.32 1",
				rgbColor2                = "1 0.8 1",
				soundTrigger             = true,
				soundstart               = "weapons/tgunshipfire.wav",
				texture1                 = "shot",
				texture2                 = "empty",
				thickness                = 8,
				tolerance                = 1000,
				turret                   = true,
				weaponVelocity           = 750,
				customparams             = {
					--isupgraded			 = isUpgraded,
					--damagetype		     = "ehbotkarganneth", 
				}, 
				damage                   = {
					default              = 200,
					bombers				 = 1000,
					fighters 			 = 1000,
					vtol				 = 1000,
				},
			},
			
			karg_shoulder = {
				areaofeffect = 16,
				avoidfeature = false,
				burnblow = true,
				canattackground = false,
				cegtag = "missiletrailaa",
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.15,
				explosiongenerator = "custom:genericshellexplosion-tiny-aa",
				firestarter = 72,
				flighttime = 1.75,
				impulseboost = 0,
				impulsefactor = 0,
				model = "cormissile.s3o",
				name = "ShoulderRockets",
				noselfdamage = true,
				proximitypriority = 1,
				range = 700,
				reloadtime = 5,
				smoketrail = false,
				soundhit = "packohit",
				soundhitwet = "splshbig",
				soundstart = "packolau",
				soundtrigger = false,
				startvelocity = 520,
				texture1 = "trans",
				texture2 = "coresmoketrail",
				tolerance = 9950,
				tracks = true,
				turnrate = 68000,
				turret = true,
				weaponacceleration = 160,
				weapontimer = 2,
				weapontype = "MissileLauncher",
				weaponvelocity = 820,
				customparams = {
					expl_light_color = "1 0.4 0.5",
					expl_light_mult = 0.4,
					expl_light_radius_mult = 0.66,
					light_color = "1 0.5 0.6",
					light_skip = true,
				},
				damage = {
					bombers = 150,
					fighters = 120,
					vtol = 150,
				},
			},
			kargkick = {
				areaofeffect = 32,
				avoidfeature = false,
				camerashake = 500,
				collidefriendly = false,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				cylindertargeting = 1,
				edgeeffectiveness = 0.15,
				explosiongenerator = "custom:crusherkrog",
				firestarter = 40,
				impulseboost = 1.5,
				impulsefactor = 1.5,
				name = "KargCrush",
				noselfdamage = true,
				proximitypriority = 5,
				range = 55,
				reloadtime = 0.2,
				rgbcolor = "0 0 0",
				soundhitwet = "splssml",
				soundstart = "xplosml2",
				thickness = 0,
				tolerance = 9000,
				turnrate = 50000,
				turret = true,
				weapontype = "Cannon",
				weaponvelocity = 1650,
				customparams = {
					expl_light_skip = true,
					nofire = true,
				},
				damage = {
					default = 1,
				},
			},
			super_missile = {
				areaofeffect = 64,
				avoidfeature = false,
				cegtag = "missiletrailsmall-simple",
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.15,
				explosiongenerator = "custom:genericshellexplosion-medium",
				firestarter = 5,
				flighttime = 2.5,
				impulseboost = 0.123,
				impulsefactor = 0.123,
				model = "cormissile2.s3o",
				name = "KarganethMissiles",
				noselfdamage = true,
				range = 600,
				reloadtime = 0.3,
				smoketrail = false,
				soundhit = "xplosml2",
				soundhitwet = "splssml",
				soundstart = "rocklit1",
				startvelocity = 180,
				texture1 = "trans",
				texture2 = "coresmoketrail",
				tolerance = 15000,
				tracks = true,
				turnrate = 65384,
				turret = true,
				weaponacceleration = 250,
				weapontimer = 5,
				weapontype = "MissileLauncher",
				weaponvelocity = 600,
				damage = {
					bombers = 150,
					default = 120,
					subs = 5,
					vtol = 150,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "GROUNDSCOUT NOTAIR",
				def = "MACHINEGUN",
				onlytargetcategory = "NOTSUB",
			},
			[2] = {
				badtargetcategory = "GROUNDSCOUT",
				def = "KARG_SHOULDER",
				onlytargetcategory = "VTOL",
			},
			--[3] = {
			--	def = "KARG_HEAD",
			--	onlytargetcategory = "VTOL",
			--},
		},
	},
}