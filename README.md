# Convert GDEMU SD Card to MODE
A utility to convert a [GDEMU](https://gdemu.wordpress.com/)-formatted SD card to one suited for the [MODE](https://shop.terraonion.com/shop/product/terraonion-mode-dreamcast-saturn-ode/view).

This utility will move, rename, and delete files on the target SD card in order to conform to MODE's requirements, including single-folder multi-disc support.

Note that this utility expects the target SD card to have been created with Madsheep's SD Card Maker for GDMenu (or any other management tool that conforms to GDMenu's standards).

![#f03c15](https://via.placeholder.com/15/f03c15/f03c15.png) **IMPORTANT:** *Please do not run this program against a copy of your daily-use GDEMU SD card. Instead, use a copy or backup until you're sure it works with your disc image collection.*

## Current Version
Convert GDEMU SD Card to MODE is currently at version [1.0](https://github.com/DerekPascarella/Convert-GDEMU-SD-Card-to-MODE/raw/main/gdemu_to_mode.exe).

## Supported Features
Below is a specific list of the current features.

* Support for both GDI and CDI disc image formats.
* New `DREAMCAST` folder created in root of SD card.
* All numbered folders (.e.g, `02`, `03`, etc.) renamed based on `name.txt`.
* To take advantage of MODE's automatic disc-queueing abilities, multi-disc games are grouped in the same folder with all of their files renamed for proper alphanumeric sorting.
* Invalid filename characters inherited from `name.txt` are automatically stripped and/or converted.
* Folders that don't contain a valid game disc image are skipped.
* GDMenu folder (`01`) ignored and deleted.
* `GDEMU.ini` configuration file automatically deleted.
* If no `name.txt` file is found, `UNKNOWN X` (where `X` is iterated over) is used as game's folder name.

## Example Usage
Generic usage:
```
gdemu_to_mode <PATH_TO_SD_CARD>
```

## Example Scenario
In this example, our SD card formatted for GDEMU+GDMenu appears as follows.

```
01
02
03
04
05
06
07
08
09
GDEMU.INI
```

At the terminal, we'll execute `gdemu_to_mode.exe` to begin conversion.

```
PS C:\> .\gdemu_to_mode.exe E:\

Convert GDEMU SD Card to MODE v1.0
Written by Derek Pascarella (ateam)

WARNING! This utility will move, rename, and delete files on the target
SD card in order to conform to MODE's requirements. Please do not run
this program against a copy of your daily-use GDEMU SD card. Instead,
use a copy or backup.

Proceed with converting the GDEMU SD card? (Y/N) y

> Creating "DREAMCAST" folder...

> Processing GDEMU SD card...

        Folder number: 02
            Game name: 18 WHEELER - AMERICAN PRO TRUCKER

        Folder number: 03
            Game name: 4 WHEEL THUNDER

        Folder number: 04
            Game name: 4X4 EVOLUTION

        Folder number: 05
            Game name: ALICE DREAMS TOURNAMENT

        Folder number: 06
            Game name: ALIEN FRONT ONLINE

        Folder number: 07
            Game name: ALONE IN THE DARK - THE NEW NIGHTMARE

        Folder number: 08
            Game name: ALONE IN THE DARK - THE NEW NIGHTMARE (DISC 2)

        Folder number: 09
            Game name: AQUA GT

> Initial conversion complete!

> Waiting five seconds before grouping multi-disc games...

      Multi-disc game: ALONE IN THE DARK - THE NEW NIGHTMARE (2 DISCS)

> SD card conversion complete!

Disc images processed: 8
 GDI images processed: 7
 CDI images processed: 1
Multi-disc game count: 1
   Unknown game count: 0

```

After conversion, the following folders appear within the `DREAMCAST` folder in the root of the SD card.

```
18 WHEELER - AMERICAN PRO TRUCKER
4 WHEEL THUNDER
4X4 EVOLUTION
ALICE DREAMS TOURNAMENT
ALIEN FRONT ONLINE
ALONE IN THE DARK - THE NEW NIGHTMARE
AQUA GT
```

Below, we see an example of a single-folder multi-disc game.

```
disc1_disc.gdi
disc1_track01.bin
disc1_track02.raw
disc1_track03.bin
disc1_track04.raw
disc1_track05.bin
disc2_disc.gdi
disc2_track01.bin
disc2_track02.raw
disc2_track03.bin
disc2_track04.raw
disc2_track05.bin
```

Furthermore, the GDI files themselves are modified to reflect the new filenames.

```
5
1 0 4 2352 disc1_track01.bin 0
2 756 0 2352 disc1_track02.raw 0
3 45000 4 2352 disc1_track03.bin 0
4 100806 0 2352 disc1_track04.raw 0
5 101407 4 2352 disc1_track05.bin 0
```

```
5
1 0 4 2352 disc2_track01.bin 0
2 756 0 2352 disc2_track02.raw 0
3 45000 4 2352 disc2_track03.bin 0
4 59804 0 2352 disc2_track04.raw 0
5 60405 4 2352 disc2_track05.bin 0
```
