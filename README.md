# bark
Godot matrix client with VR support (WIP)

## the goal

My goal is to create a matrix client designed specifically to rival both Discord and social VR apps (like VRChat, Neos, etc.)
Open source from the start, using matrix, and will provide thorough documentation on features/changes. 
Facilitates work on my "vector_sdk" a godot SDK to make it easier to implement matrix into games. This will eventually be accompanied by a solution I'm architecting for various methods of indie devs to host their games on MMMat.



## features

### planned

- e2e encryption
- room management
- space management
- custom rooms with dedicated ui
- cross compat with Element calls (hopefully)
- special calls for bark users (VR, e2e group calls, etc)
- Launch modes for flat, VR, AR, MR


# community features

I've been very annoyed how communities on Discord try to use it as their whole community hub when it just isn't good for that.
I'm going to change that. I will be building various custom room specifications so that users of bark will be able to have a community hub that's secure and supports the ui and features they want.

Here are some planned custom rooms that will load a dedicated ui instead of a chat messaging interface when opened:

- about us
- links
- forums
- wiki
- timeline (think mastodon/twitter but embedded directly into your community)
- chat
- support
- VR
- files
- potentially more on request
- other gimmick room types for fun (if this project takes off, and I have the time, I will make a new temporary gimmick surprise room type every month)



This is still very early in development, I plan to have feature parody with Element sometime soon. Any support will help speed this up.
After I acheive feature parody with Element, I will begin working on the various custom features. 

I am sick of lazy projects using Electron or systems built on the concept of Apache Cordova for everything and services like Discord shoving AI into everything and datamining every user. 
I'm hoping to build a native Matrix client with some fun features and functionality directed at attracting Discord users to hopefully change this.
If Mastodon can become mostly mainstream, I believe that Matrix has the potential to become mainstream... but element is just not gonna cut it.


### other platforms/tools/systems currently marked as targets for federation or at least minimal support:

A list of things I want to add functionality into Godot/bark to support as extensively as possible.

- [thirdroom](https://github.com/matrix-org/thirdroom/)
- [all OMI extensions](https://github.com/omigroup)
- [bitECS](https://github.com/NateTheGreatt/bitECS)
- more...

