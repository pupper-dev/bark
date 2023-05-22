
#TODO: instead of joined_rooms array, use dictionary and cache the room info and maybe messages
#donow: add the rest of the api calls before continue

#idea: use room state to store current host
#idea: host automatic save pushes the current world information to the room state
#idea: /\ might need some way to convert the world to an asset and the upload it.
#idea: /\ look into uploading it in-place so duplicate worlds don't clutter things
#idea: /\ look into other storage hosting solutions (namely: IPFS) for viability
#idea: room type dictates the relative functionality:
#idea: /\ ex: vr-room will only be joinable in vr, no messages
#idea: /\ ex: feed-room will only show Mastodon feed style content
#idea: room types: vr, feed, wiki, files/links, chat, support
