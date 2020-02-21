# Wolcen-Socket-Roller v1.9.2 [![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/K3K314GUP)
Download here:
<br/>
https://github.com/Crypto90/Wolcen-Socket-Roller/releases
<br/>
Reddit discussion:
<br/>
https://www.reddit.com/r/Wolcen/comments/f6fm0q/wolcen_socket_roller_download_source_now_updated/
<br/>
<br/>

![Image of Yaktocat](https://raw.githubusercontent.com/Crypto90/Wolcen-Socket-Roller/master/screenshot_1.9.1.png)
<br/>
<br/>
<br/>
# Introduction
Hello guys, if you love Wolcen as much as I do, I have a little tool for you all.
<br/>
I created a little tool, which rerolls item sockets at the npc as long as the configured combination not matches. I made this, to be able to do something else while the item is rerolling and I do not click reroll once more accidentally. It clicks reroll until the wanted socket combination gets found. On finish the tool plays a 2 second beep sound.
To stop a running reroll process, press ALT+TAB and ALT some times. Hotkeys are set to stop for: ALT, TAB, ESCAPE.
<br/>
The tool is made in Autoit, fully pixel based by matching colors of the sockets. It works with all resolutions I have tested. To stop a running rolling process, simply tab out of the game.
<br/>
If you like my work, you can donate me a coffe. Happy looting :)
<br/>
<br/>
# How to use:
1. Make sure you run your game in borderless window (fullscreen does not work because the npc window closes on ALT+TAB).
2. Talk with "ZANAFER STARK" NPC where you can reroll your item sockets and place your item for rolling.
3. Run the Wolcen_Socket_Roller.exe and select your wanted sockets.
4. Click the Start button, your game will automatically come to foreground and it starts rolling (if your mouse is not moving, run the tool with admin rights).
<br/>
To stop it while its looping, ALT-TAB out of the game to a different program, this will stop the loop.
<br/>
<br/>

# Resolutions & Aspect ratios
With version 1.8.2 support for all common aspect rations got added to support more resolutions dynamically:
<br/>
21:9 (ultrawide 3440x1440)<br/>
21:9 (wide 2560x1080)  <br/>
16:10 and 8:5<br/>
16:9<br/>
5:3<br/>
5:4<br/>
4:3<br/>
All others fallback to default 16:9 aspect ratio, coordinates get calculated on the aspect ratio base multiplied with your resolution.
<br/>
<br/>

If your resolution does not work, please create in issue here on github and upload a screenshot of your game so it can get fixed.
<br/>
<br/>

# Socket order
The result order does not matter, all combinations of your wanted socket get matched.
<br/>
defense II -- defense II -- defense I
<br/>
matches the same as
<br/>
defense I -- defense II -- defense II
<br/>
matches the same as
<br/>
defense II -- defense I -- defense II
<br/>

![Image of Yaktocat](https://raw.githubusercontent.com/Crypto90/Wolcen-Socket-Roller/master/screenshot_ingame_1.9.1_scan_area.jpg)

<br/>

# FAQ & Known issues:
<br/>

###### Q: Mouse does not move after it switches to the game. The reroll button does not get clicked.
A: Its a permission issue on your pc, run the tool as administrator.
<br/>
<br/>
• Make sure your windows desktop scaling settings is at 100%, higher scaling does not work currently.
<br/>
• Smaller game resolutions do blurry and shrink the socket text which makes it harder for the tool to detect the correct color if they are very similar. Larger resolutions work fine. Im currently reworking the color matching to a "highest matching percentage of color in area" logic instead of "first color found in area" which will fix this issue.

