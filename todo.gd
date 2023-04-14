extends Node

#todo: use room state to store current host
#todo: host automatic save pushes the current world information to the room state
#todo: /\ might need some way to convert the world to an asset and the upload it.
#todo: /\ look into uploading it in-place so duplicate worlds don't clutter things
#todo: /\ look into other storage hosting solutions (namely: IPFS) for viability
#todo: room type dictates the relative functionality:
#todo: /\ ex: vr-room will only be joinable in vr, no messages
#todo: /\ ex: feed-room will only show Mastodon feed style content
#todo: room types: vr, feed, wiki, files/links, chat, support
