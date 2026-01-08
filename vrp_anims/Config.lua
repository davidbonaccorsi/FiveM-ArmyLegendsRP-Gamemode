Config = {
-- Change the language of the menu here!.
-- Note fr and de are google translated, if you would like to help out with translation / just fix it for your server check below and change translations yourself
-- try en, fr, de or sv.
	MenuLanguage = 'en',	
-- Set this to true to enable some extra prints
	DebugDisplay = false,
-- Set this to false if you have something else on X, and then just use /e c to cancel emotes.
	EnableXtoCancel = true,
-- Set this to true if you want to disarm the player when they play an emote.
	DisarmPlayer= false,
-- Set this if you really wanna disable emotes in cars, as of 1.7.2 they only play the upper body part if in vehicle
    AllowedInCars = true,
-- You can disable the (F3) menu here / change the keybind.
	MenuKeybindEnabled = true,
	MenuKeybind = 170, -- Get the button number here https://docs.fivem.net/game-references/controls/
-- You can disable the Favorite emote keybinding here.
	FavKeybindEnabled = true,
	FavKeybind = 171, -- Get the button number here https://docs.fivem.net/game-references/controls/
-- You can change the header image for the f3 menu here
-- Use a 512 x 128 image!
-- NOte this might cause an issue of the image getting stuck on peoples screens
	CustomMenuEnabled = true,
	MenuImage = "https://cdn.armylegends.ro/fivem/bganimatii.png",
-- You can change the menu position here
	MenuPosition = "right", -- (left, right)
-- You can disable the Ragdoll keybinding here.
	RagdollEnabled = true,
	RagdollKeybind = 303, -- Get the button number here https://docs.fivem.net/game-references/controls/
-- You can disable the Facial Expressions menu here.
	ExpressionsEnabled = true,
-- You can disable the Walking Styles menu here.
	WalkingStylesEnabled = true,	
-- You can disable the Shared Emotes here.
    SharedEmotesEnabled = true,
    CheckForUpdates = true,
-- If you have the SQL imported enable this to turn on keybinding.
    SqlKeybinding = false,
}

Config.KeybindKeys = {
    ['num4'] = 108,
    ['num5'] = 110,
    ['num6'] = 109,
    ['num7'] = 117,
    ['num8'] = 111,
    ['num9'] = 118
}

Config.Languages = {
  ['en'] = {
        ['emotes'] = 'Emotii',
        ['danceemotes'] = "🕺 Dansuri",
        ['propemotes'] = "📦 Obiecte",
        ['favoriteemotes'] = "🌟 Favorite",
        ['favoriteinfo'] = "Selecteaza o emotie pentru a o seta ca favorita.",
        ['rfavorite'] = "Reseteaza favoritele",
        ['prop2info'] = "❓ Obiectele pot fi plasate la sfarsitul listei",
        ['set'] = "Setezi (",
        ['setboundemote'] = ") ca emote binduit?",
        ['newsetemote'] = "~w~ este acum emote binduit, apasa ~g~CapsLock~w~ pentru emote.",
        ['cancelemote'] = "Anuleaza emotie",
        ['cancelemoteinfo'] = "~r~X~w~ Anuleaza emote-ul activ",
        ['walkingstyles'] = "Stiluri de mers",
        ['resetdef'] = "Reseteaza la valoarea implicita",
        ['normalreset'] = "Normal",
        ['moods'] = "Stari",
        ['infoupdate'] = "Informatii",
        ['infoupdateav'] = "Informatie (Update available)",
        ['infoupdateavtext'] = "Este disponibil un update, obtineti cea mai recenta versiune de pe ~y~https://github.com/andristum/dpemotes~w~",
        ['suggestions'] = "Sugestii?",
        ['suggestionsinfo'] = "(Josh's-Works)Suntem deschisi la sugestii Intra pe Discord. ✉️",
        ['notvaliddance'] = "nu este un dans valid.",
        ['notvalidemote'] = "nu este un emote valid",
        ['nocancel'] = "Nici un emote de anulat.",
        ['maleonly'] = "Acest emote este doar pentru barbati!",
        ['emotemenucmd'] = "Foloseste /emotemenu pentru un meniu.",
        ['shareemotes'] = "👫 Emotii impreuna",
        ['shareemotesinfo'] = "Invita persoana de langa tine sa faca un emote",
        ['sharedanceemotes'] = "🕺 Dansuri impreuna",
        ['notvalidsharedemote'] = "nu este un emote partajat valid.",
        ['sentrequestto'] = "Cerere trimisa catre ~y~",
        ['nobodyclose'] = "Nimeni ~r~nu este~w~ suficient de aproape.",
        ['doyouwanna'] = "~y~Y~w~ pentru a accepta, ~r~L~w~ pentru a refuza (~g~",
        ['refuseemote'] = "Emote refuzat.",
        ['makenearby'] = "Animeaza jucatorul de langa",
        ['camera'] = "Apasa ~y~G~w~ pentru a utiliza blitul camerei.",
        ['makeitrain'] = "Apasa ~y~G~w~ pentru a face sa ploua.",
        ['pee'] = "Tine ~y~G~w~ pentru a face pipi.",
        ['spraychamp'] = "Tine ~y~G~w~ pentru a stropi cu sampania",
        ['bound'] = "Bound ",
        ['to'] = "catre",
        ['currentlyboundemotes'] = " Currently bound emotes:",
        ['notvalidkey'] = "is not a valid key.",
        ['keybinds'] = "🔢 Keybinds",
        ['keybindsinfo'] = "Foloseste"
  },
}