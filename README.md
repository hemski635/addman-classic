addman - World of Warcraft addons manager


Install and update addons from curseforge.com and tukui.org
    
    Copy the addman -directory to $home (c:\users\username)
    Remember to edit addon path in addman/addman.ps1, if it's not 
    "C:\Program Files (x86)\World of Warcraft\_retail\Interface\addons"
    Previously installed addons are not included. You can manually add them 
    to addman\addonlist.txt, or reinstall them with 'addman -add <addon>'
    (Example: addman -add deadly-boss-mods)

    
    Options
    addman [options]
    
    -update
        update all addons listed in $home\addman\addonlist.txt

    -add [addon name]
        install an addon to your pre-set WoW addons directory

    -remove [addon name]
        Remove an addon from the addonlist

    -list
        List all addons listed in addonlist

    -cleanup
        Delete all addons inside your addons folder ($addonpath)

    -h
        Print this man page


Author
    hemski@hemko.xyz
