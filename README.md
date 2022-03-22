# Convert GDEMU SD Card to MODE
A utility to convert a [GDEMU](https://gdemu.wordpress.com/)-formatted SD card to one suited for the [MODE](https://shop.terraonion.com/shop/product/terraonion-mode-dreamcast-saturn-ode/view).

This utility will move, rename, and delete files on the target SD card in order to conform to MODE's requirements, including single-folder multi-disc support. Please do not run this program against a copy of your daily-use GDEMU SD card. Instead, use a copy or backup.

Note that this utility expects the target SD card to have been created with [SD Card Maker for GDMenu](https://github.com/sonik-br/GDMENUCardManager).

## Current Version
Convert GDEMU SD Card to MODE is currently at version 1.0.

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

## Example Usage
Generic usage:
```
gdemu_to_mode <PATH_TO_SD_CARD>
```

## Example Scenario
In this example, our SD card formatted for GDEMU+GDMenu appears as follows.

IMAGE GOES HERE

At the terminal, we'll execute `gdemu_to_mode.exe` to begin conversion.

IMAGE GOES HERE

After conversion, the following folders appear within the `DREAMCAST` folder in the root of the SD card.

IMAGE GOES HERE

Below, we see an example of a single-folder multi-disc game.

IMAGE GOES HERE
