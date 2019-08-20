#!/bin/pwsh

Write-Host ('
  ___  ______ ______ ___  ___  ___   _   _ 
 / _ \ |  _  \|  _  \|  \/  | / _ \ | \ | |
/ /_\ \| | | || | | || .  . |/ /_\ \|  \| |
|  _  || | | || | | || |\/| ||  _  || . ` |
| | | || |/ / | |/ / | |  | || | | || |\  |
\_| |_/|___/  |___/  \_|  |_/\_| |[CLASSIC]
   Simple addons manager for Wow Classic   
')

$addonpath = "C:/Program Files (x86)/World of Warcraft/_classic_/Interface/addons"
$addonupdaterpath = "$home/addman-classic/


$ErrorActionPreference = 'stop'
Set-Location $addonupdaterpath
Import-Module ./testpath.ps1
$test = test-path ./classic-addonlist.txt
if ($test -eq $false)
    {
    New-Item -ItemType file -Name classic-addonlist.txt
    Add-Content ./classic-addonlist.txt 'addonlist'
    }
$test = test-path ./old.txt
if ($test -eq $false)
    {
    New-Item -ItemType file -Name clold.txt
    Add-Content ./clold.txt 'old'
    }

function caddman
    {
    Param(
        [parameter(mandatory=$false)]
        [Switch]
        $update,

        [parameter(mandatory=$false)]
        [Switch]
        $h,

        [parameter(mandatory=$false)]
        [String[]]
        $add,

        [parameter(mandatory=$false)]
        [Switch]
        $cleanup,

        [parameter(mandatory=$false)]
        [String[]]
        $remove,

        [parameter(mandatory=$false)]
        [Switch]
        $list
        )

    #Update addons
    if($update)
        {
        $addons = get-content "./classic-addonlist.txt"
        foreach ($addon in $addons)
            {
            if(($addon -like 'elvui') -or ($addon -like 'tukui'))
                {
                $elvhref = ((invoke-webrequest "https://www.tukui.org/download.php?ui=$addon").links | Where-Object {$_.href -like "/downloads/$addon-*"}).href
                $elvurl = "https://www.tukui.org$elvhref"
                $elvoutput = "./$addon.zip"
                if((Get-Content ./clold.txt).Contains($elvurl))
                    {
                    Write-Host "$addon is already up to date"
                    }
                else
                    {
                    Invoke-WebRequest -Uri $elvurl -OutFile $elvoutput
                    Expand-Archive -Path $elvoutput -DestinationPath $addonpath/ -Force
                    Remove-Item $elvoutput
                    Add-Content ./clold.txt $elvurl
                    Write-Host "$addon updated"
                    }
                }
            if(($addon -ne 'addonlist') -and (($addon -notlike 'elvui') -and ($addon -notlike 'tukui')))
                {
                $href = ((invoke-webrequest "https://www.curseforge.com/wow/addons/$addon/download").links | Where-Object {$_.href -like "*file*"}).href
                $url = "https://www.curseforge.com$href"
                $output = "./$addon.zip"
                if((Get-Content ./clold.txt).Contains($url))
                    {
                    Write-Host "$addon is up to date"
                    }
                else
                    {
                    Invoke-WebRequest -Uri $url -OutFile $output
                    Expand-Archive -path $output -DestinationPath $addonpath -Force
                    Add-Content ./old.txt $url
                    Remove-Item $output
                    Write-Host "$addon updated"
                    }
                }
            }
        }

    #Install new addon
    if($add)
        {
        if(($add -eq 'elvui') -or ($add -eq 'tukui'))
            {
            $elvhref = ((invoke-webrequest "https://www.tukui.org/download.php?ui=$add").links | Where-Object {$_.href -like "/downloads/$add-*"}).href
            $elvurl = "https://www.tukui.org$elvhref"
            $elvoutput = "./$add.zip"
            if((Get-Content ./clold.txt).Contains($elvurl))
                {
                Write-Host "$add is already installed and up to date"
                }
            else
                {
                Invoke-WebRequest -Uri $elvurl -OutFile $elvoutput
                Expand-Archive -Path $elvoutput -DestinationPath $addonpath/ -Force
                Remove-Item $elvoutput
                Add-Content ./clold.txt $elvurl
                Add-Content ./classic-addonlist.txt $add
                Write-Host "$add installed"
                }
            }
        else
            {
            $href = ((invoke-webrequest "https://www.curseforge.com/wow/addons/$add/download").links | Where-Object {$_.href -like "*file*"}).href
            $url = "https://www.curseforge.com$href"
            $output = "$addonpath/$add.zip"
            $testeduri = Test-Uri "https://www.curseforge.com/wow/addons/$add/download"
            if($testeduri -eq $true)
                {
                Invoke-WebRequest -Uri $url -OutFile $output
                Expand-Archive -Path $output -DestinationPath "$addonpath/" -Force
                Remove-Item $output
                Add-Content ./classic-addonlist.txt $add
                Add-Content ./clold.txt $url
                Write-Host "Installed $add"
                return
                }
            if($testeduri -eq $false)
                {
                Write-Host "$add could not be found. Please check spelling"
                }
            }
        }

    #Remove addon
    if($remove)
        {
        get-content ./classic-addonlist.txt | select-string -pattern $remove -notmatch | out-file ./classic-addonlist.txt
        get-content ./clold.txt | select-string -pattern $remove -notmatch | out-file ./clold.txt
        Add-Content ./addonlist.txt 'addonlist'
        Add-Content ./clold.txt 'old'
        write-host "$remove has been removed from the addons list. To completely remove the addon, run 'addman -cleanup' and 'addman -update'"
        }

    #list all addons
    if($list)
        {
        cat ./classic-addonlist.txt
        }

    #Clear the addons folder
    if($cleanup)
        {
        Write-host "WARNING! This option will delete everything inside your addons directory"
        $reply = Read-Host -Prompt "Continue?[y/n]"
        if ( $reply -match "[yY]" )
            {
            Remove-Item -Recurse -Force $addonpath/*
            Write-Host "Addons directory cleaned"
            }
        }




    $manpage = ("
    Addman

    Name
        addman - World of Warcraft addons manager

    Synopsis
        addon [option]

    Description
        Install and update addons from Curseforge
        Options
        -update
            update all addons listed in $home/addman/classic-addonlist.txt

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





    ")

    if($h)
        {
        Write-Host $manpage
        }
    }
