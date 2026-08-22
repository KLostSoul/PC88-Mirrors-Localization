Mirrors (NEC PC-8801 MC) English translation.

1. Game description.

Mirrors is a visual novel (VN) game, originally released for NEC PC-8801 MC (the last model in NEC PC-88 series, which was equipped with CD drive). It eventually saw a graphically revamped re-release in 1992 for the Fujitsu FM-Towns computer.
The story, written by Hiroyuki Kitahara, tells the player a story of David Astley, the lead singer of promising "Eleno Vision", who is being haunted by nightmares about mysterious man who is going to kill him. While he and his bandmates are preparing for their first tour of Europe, David's dreams are getting worse and just on the eve of tour something ominous happens…

2. Project background.
The work on game began in 2019 by cybermind, who in search for NEC PC-88 games found this game and decided to play it. Since the game text strings weren't hard to extract, he decided to reverse-engineer and prepare a Russian machine translation (yes, this game also does have a Russian translation, though it still remains uncomplete) in order to understand the plot. Later, celcion who saw this translation attempt, offered a help with complete English re-translation, thus joining cybermind into Nebulous group.
The translation began at early 2020.  Due to a really long plot (more than 5000 lines of text), the project got delayed for a year.

3. Translation and editing notes 
(by TheMajinZenki)
"Mirrors" was an interesting project to tackle, as I usually translate more "straightforward" games targeted towards a younger audience. This game is definitely targeted towards an adult audience, and as a classic Japanese adventure game it features a lot of descriptive text. Definitely a project outside my usual comfort zone! Still, as I went through the translation, I was hooked to the plot. My favorite characters to write were Detective Clark and his assistant Vince.
Since the game features a lot of real world locations (but also fictional), one of the major hurdles of the project was making sure the descriptions felt as correct as possible. Some of the names of the characters were meant to be fictional on purpose, while others were meant to be realistic... but as you can imagine, it's not easy to tell from katakana. 
At any rate, I hope you enjoy this mystery adventure as much as I did translating it!
(by cccmar)
Mirrors is a pretty interesting and unique game for the time. The band members are based on Depeche Mode and similar acts of the time, the setting is basically 'Europe' in general, so it is essentially a globetrotting trip of massive proportions. Personally, I quite enjoyed the story, even if it can get somewhat disturbing at times. It's also a fairly long visual novel for the time. The standout is definitely some of the music, I really enjoyed some of the themes. As far as editing/proofreading goes, it was a challenge in parts, due to the volume of text/mixture of real and made-up locations. Overall, I found it surprisingly engaging as a story. 

4. Hacking notes (by cybermind)
There are not so much translated PC-8801 games, and it's next to none documentation about NEC PC-8801 MC even on Japanese, let me write in detail about how the game was hacked.
First, few words about how the game runs on PC-8801 MC and how the computer works with CD. The whole game data is stored on CD, which is a mixed-mode CD, similar to storage format used in NEC PC Engine CD games (track 1 is warning speech, track 2 is MODE1/2352 track holding every game program/script/graphics and the other tracks are CDDA music). To play the game, it's also required to have 3 extra floppy disks (not included with game):
1: "Main" – holds the most used data (character portraits, some of the sounds)
2: "Game" – holds the current scenario data (used as a CD data buffer)
3: "Save" – holds the save data (replaces the "Main" floppy when saving)
All data on CD is aligned by sectors (2048 bytes), and PC-8801 MC CD read operations can only work with sectors, which are numbered from track 1 (so in case of Mirrors, the first sector of track 1 is sector 13350).
 The game internally uses N88-BASIC to manage the user interface and to control script flow. It extends the standard N88-BASIC commands by replacing several built-in commands (like FOR, ISET, COMMON etc.) with custom handlers for disk operations, FM and ADPCM sound, CD loading and such, thus implementing all high-load operations in assembly (a common practice for majority of games using BASIC).
So, since all game-essential data is located on track 2, it's simply a matter of extracting it, working with it and then putting the modified track back on to CD image.
The structure of track 2 is pretty simple. It starts with 2-sector header with magic string and description of the IPL (initial program loader) load offset and size. When computer starts, the IPL loads the BASIC extensions, the menu script and starts the game. The rest of track 2 data are raw floppy disk images, stacked together.
Since the translation progress took a lot of time, in the meanwhile I've extended the game with some additional features:
- There is no more separate Save disk, so all game progress is saved to Main disk. In addition, there are 9 save slots instead of one.
- Game uses 2HD disks instead of 2D ones, resulting in larger gameplay buffer (at cost of longer loading times from CD)
- New font system, allowing the game to show several custom variable width fonts instead of computer's built-in ROM font.
- In the options menu it's possible to select between different text printing sounds: FM-based, beeper or disable it completely.

5. How to patch and play the game:
(If you don't want to bother with configuring the emulator and patching the game, the ready-to play version is available on archive.org) 

You'll need the game CD image in Clone CD format:
Mirrors.ccd: 80273154a2daf2d107a282b353a86246 (MD5)
Mirrors.img: 84e583ec62372ca9dd0d737dce38b5d8 (MD5)
Mirrors.sub: e45923398b1d150f71e6056bd0974d15 (MD5)

Place all three files in "patcher" folder and run "patch.bat". If everything is done correctly, you'll find the translated image in the same folder.

Download ePC8801MA emulator, it's the only PC-8801 emulator, that's capable of playing CD games with CDDA audio. The last version is available on the author's page: http://takeda-toshiya.my.coocan.jp
Then obtain NEC PC-8801 MC BIOS files and place them next to the emulator. 

Place the "pc8801ma.ini" file (that's included with translation) file next to the "pc8801ma.exe" file - this will give you the recommended settings for emulator.
Launch "pc8801ma.exe". When emulator makes a beep sound and shows "CD-System..." message, select "CD-ROM->Insert" from menu and select "Mirrors eng v1.0.ccd" file. Select "5inch-FD1->Insert" and choose "disk1main.d88" disk image. Then select "FD2->Insert" and choose "disk2game.d88" disk image.

If the game hasn't booted, select "Control->Reset" and wait until emulator loads the game from CD.

6. Disclaimer.
You can redistribute this translation freely as long as you don't ask money for it and include this readme.txt file with it. We don't condone any form of commercial redistribution. Please, keep that in mind. 

7. Staff:
cybermind – hacking, graphics.
TheMajinZenki – lead translator, additional help.
cccmar – editing, proofreading, beta-testing.
celcion – testing on real NEC PC-8801 MC.

8. Contacts:
cybermind – cybermindid@gmail.com
PC-88 Series Discussion channel on Discord: https://discord.gg/pD6gy3M8KU 
