return {
	corcomboss = {
		acceleration = 0.18,
		activatewhenbuilt = true,
		autoheal = 1000,
		brakerate = 0.6,
		buildcostenergy = 260000,
		buildcostmetal = 27000,
		builddistance = 145,
		builder = true,
		buildpic = "scavengers/CORCOMBOSS.PNG",
		buildtime = 750000,
		cancapture = true,
		cancloak = true,
		canmanualfire = true,
		canmove = true,
		capturespeed = 6000,
		category = "ALL WEAPON COMMANDER NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE CANBEUW EMPABLE",
		cloakcost = 200,
		cloakcostmoving = 2000,
		collisionvolumeoffsets = "0 7 0",
		collisionvolumescales = "59 125 59",
		collisionvolumetype = "CylY",
		corpse = "DEAD",
		description = "Commander",
		energymake = 250,
		explodeas = "commanderexplosion",
		footprintx = 5,
		footprintz = 5,
		hidedamage = true,
		icontype = "corcommander",
		idleautoheal = 1000,
		idletime = 1800,
		losemitheight = 100,
		mass = 500000,
		maxdamage = 400000,
		maxslope = 25,
		maxvelocity = 0.5,
		maxwaterdepth = 200,
		metalmake = 5,
		mincloakdistance = 120,
		movementclass = "COMMANDERKBOT",
		name = "Commander Boss",
		nochasecategory = "ALL",
		objectname = "Units/scavboss/CORCOMBOSS.s3o",
		pushresistant = true,
		radardistance = 1400,
		radaremitheight = 100,
		reclaimable = false,
		script = "Units/CORCOM.cob",
		seismicsignature = 0,
		selfdestructas = "commanderExplosion",
		selfdestructcountdown = 5,
		showplayername = true,
		sightdistance = 800,
		sonardistance = 800,
		terraformspeed = 10000,
		turninplaceanglelimit = 140,
		turninplacespeedlimit = 0.825,
		turnrate = 500,
		upright = true,
		workertime = 15000,
		buildoptions = {
			[1] = "corsolar",
			[2] = "corwin",
			[3] = "cormstor",
			[4] = "corestor",
			[5] = "cormex",
			[6] = "cormakr",
			[7] = "corlab",
			[8] = "corvp",
			[9] = "corap",
			[10] = "coreyes",
			[11] = "corrad",
			[12] = "cordrag",
			[13] = "corllt",
			[14] = "corrl",
			[15] = "cordl",
			[16] = "cortide",
			[17] = "coruwms",
			[18] = "coruwes",
			[19] = "coruwmex",
			[20] = "corfmkr",
			[21] = "corsy",
			[22] = "corfdrag",
			[23] = "cortl",
			[24] = "corfrt",
			[25] = "corfrad",
		},
		customparams = {
			area_mex_def = "cormex",
			iscommander = true,
			model_author = "Mr Bob",
			normaltex = "unittextures/Core_normal.dds",
			paralyzemultiplier = 0.01,
			subfolder = "",
			techlevel = 4,
		},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "0 0 0",
				collisionvolumescales = "35 12 54",
				collisionvolumetype = "cylY",
				damage = 10000,
				description = "Commander Wreckage",
				energy = 0,
				featuredead = "HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 2,
				footprintz = 2,
				height = 20,
				hitdensity = 100,
				metal = "2500",
				object = "Units/corcom_dead.s3o",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				collisionvolumescales = "35.0 4.0 6.0",
				collisionvolumetype = "cylY",
				damage = 5000,
				description = "Commander Debris",
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 2,
				footprintz = 2,
				height = 4,
				hitdensity = 100,
				metal = 1250,
				object = "Units/cor2X2C.s3o",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:com_sea_laser_bubbles",
				[2] = "custom:barrelshot-medium",
			},
			pieceexplosiongenerators = {
				[1] = "deathceg3",
				[2] = "deathceg4",
			},
		},
		sounds = {
			build = "nanlath2",
			canceldestruct = "cancel2",
			capture = "capture2",
			cloak = "kloak2",
			repair = "repair2",
			uncloak = "kloak2un",
			underattack = "warning2",
			unitcomplete = "kccorsel",
			working = "reclaim1",
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
				[1] = "kcormov",
			},
			select = {
				[1] = "kccorsel",
			},
		},
		weapondefs = {
			corcomlaserboss = {
				areaofeffect = 25,
				avoidfeature = false,
				beamtime = 0.3,
				corethickness = 0.22,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				cylindertargeting = 1,
				edgeeffectiveness = 1,
				explosiongenerator = "custom:laserhit-large-red",
				firestarter = 70,
				impactonly = 1,
				impulseboost = 0,
				impulsefactor = 0,
				laserflaresize = 5,
				name = "J8Laser",
				noselfdamage = true,
				range = 1250,
				reloadtime = 3,
				rgbcolor = "0.7 0.3 1",
				soundhitdry = "",
				soundhitwet = "sizzle",
				soundstart = "xplomas2",
				soundtrigger = 1,
				--sweepFire = true,
				targetmoveerror = 0.05,
				thickness = 12,
				tolerance = 10000,
				turret = true,
				weapontype = "BeamLaser",
				weaponvelocity = 900,
				damage = {
					bombers = 5000,
					commanders = 1900,
					default = 30000,
					fighters = 10000,
					subs = 500,
					vtol = 12500,
				},
			},
			corcomsealaserboss = {
				areaofeffect = 25,
				avoidfeature = false,
				beamtime = 0.3,
				corethickness = 0.22,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				cylindertargeting = 1,
				edgeeffectiveness = 1,
				explosiongenerator = "custom:laserhit-large-blue",
				firestarter = 35,
				firesubmersed = true,
				impactonly = 1,
				impulseboost = 0,
				impulsefactor = 0,
				intensity = 0.3,
				laserflaresize = 5,
				name = "J8NSLaser",
				noselfdamage = true,
				range = 1250,
				reloadtime = 3,
				rgbcolor = "0.7 0.3 1",
				rgbcolor = "0.7 0.3 0.4",
				soundhitdry = "",
				soundhitwet = "sizzle",
				soundstart = "xplomas2",
				soundtrigger = 1,
				targetmoveerror = 0.05,
				thickness = 12,
				tolerance = 10000,
				turret = true,
				waterweapon = true,
				weapontype = "BeamLaser",
				weaponvelocity = 1500,
				damage = {
					bombers = 5000,
					commanders = 1900,
					default = 30000,
					fighters = 10000,
					subs = 5000,
					vtol = 12500,
				},
			},
			disintegratorxl = {
				areaofeffect = 45,
				avoidfeature = false,
				avoidfriendly = false,
				avoidground = false,
				bouncerebound = 0,
				cegtag = "gausscannonprojectilexl",
				commandfire = false,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 1,
				energypershot = 0,
				--explosiongenerator = "custom:expldgun",
				explosiongenerator = "custom:burnblackbiggest",
				firestarter = 100,
				firesubmersed = false,
				gravityaffected = true,
				groundbounce = true,
				impulseboost = 0,
				impulsefactor = 0,
				intensity = 4,
				name = "Darkmatter Photon-Disruptor",
				noexplode = true,
				noselfdamage = true,
				range = 890,
				reloadtime = 6,
				rgbcolor = "0.7 0.3 1.0",
				size = 8.5,
				soundhit = "xplomas2",
				soundhitwet = "sizzle",
				soundstart = "disigun1",
				soundtrigger = true,
				tolerance = 10000,
				turret = true,
				waterweapon = false,
				weapontimer = 4.2,
				weapontype = "DGun",
				weaponvelocity = 400,
				customparams = {
					expl_light_heat_radius_mult = 3.2,
					expl_light_heat_strength_mult = 0.66,
					expl_light_mult = 0.5,
					expl_light_radius_mult = 1.25,
				},
				damage = {
					default = 25000,
				},
			},
			repulsor1 = {
				avoidfeature = false,
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.15,
				name = "PlasmaRepulsor",
				range = 50,
				soundhitwet = "sizzle",
				weapontype = "Shield",
				damage = {
					default = 100,
				},
				shield = {
					alpha = 0.25,
					energyuse = 0,
					force = 2.5,
					intercepttype = 479,
					power = 1000,
					powerregen = 20,
					powerregenenergy = 0,
					radius = 80,
					repulser = false,
					smart = true,
					startingpower = 1000,
					visible = false,
					visiblehitframes = 0,
					badcolor = {
						[1] = 1,
						[2] = 0.2,
						[3] = 0.2,
						[4] = 0.25,
					},
					goodcolor = {
						[1] = 0.2,
						[2] = 1,
						[3] = 0.2,
						[4] = 0.2,
					},
				},
			},
		},
		weapons = {
			[1] = {
				def = "CORCOMLASERBOSS",
				onlytargetcategory = "NOTSUB",
			},
			[2] = {
				badtargetcategory = "VTOL",
				def = "CORCOMSEALASERBOSS",
			},
			[3] = {
				def = "DISINTEGRATORXL",
				onlytargetcategory = "NOTSUB, NOTAIR",
			},
		},
	},
}