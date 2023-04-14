extends Node

## Gets a specific event for a room
## Url: /_matrix/client/v3/rooms/{roomId}/event/{eventId}
func get_event_by_id(event_id:String, room_id:String):
	pass
	
## This API returns a map of MXIDs to member info objects for members of the room. The current user must be in the room for it to work, unless it is an Application Service in which case any of the AS’s users must be in the room. This API is primarily for Application Services and should be faster to respond than 
## Url: /_matrix/client/v3/rooms/{roomId}/joined_members
func get_room_joined_members(room_id:String):
	pass
	
## Get the list of members for this room
## Url: /_matrix/client/v3/rooms/{roomId}/members
func get_room_members(room_id:String, at:String='',membership:String='',not_membership:String=''):
	pass
	
## Get the state events for the current state of a room
## Url: /_matrix/client/v3/rooms/{roomId}/state
func get_room_state(room_id:String):
	var res
	if Vector.client.get_status() == HTTPClient.STATUS_CONNECTED:
		res = Vector.client.request(
			HTTPClient.METHOD_GET,
			"/_matrix/client/v3/rooms/{0}/state".format([room_id]),
			Vector.headers)
		var msg = await Vector.readRequestBytes()
		var pmsg = JSON.parse_string(msg)
		return pmsg
		
## Looks up the contents of a state event in a room. If the user is joined to the room then the state is taken from the current state of the room. If the user has left the room then the state is taken from the state of the room when they left.
## Url: /_matrix/client/v3/rooms/{roomId}/state/{eventType}/{stateKey}
func get_room_event_state(event_type:String, room_id:String, state_key:String):
	pass
	
## Gets a list of message and state events for a room. It uses pagination query parameters to paginate history in the room.
## Url: /_matrix/client/v3/rooms/{roomId}/messages
func get_room_messages(room_id:String, dir:String='', filter:String='',from:String='', limit:int=-1, to:String=''):
	var res
	if Vector.client.get_status() == HTTPClient.STATUS_CONNECTED:
		res = Vector.client.request(HTTPClient.METHOD_GET, "/_matrix/client/v3/rooms/{0}/messages?limit={1}".format([
			room_id,
			limit if limit<-1 else 100
			]),Vector.headers)
		var msg = await Vector.readRequestBytes()
		return JSON.parse_string(msg)

## Get the ID of the event closest to the given timestamp, in the direction specified by the dir parameter.
## Url: /_matrix/client/v1/rooms/{roomId}/timestamp_to_event
func get_closest_event_to_timestamp(room_id:String):
	pass
	
## Gets a list of aliases for the specified room
## Url: /_matrix/client/v3/rooms/{roomId}/aliases
func get_room_aliases(room_id:String):
	var res
	if Vector.client.get_status() == HTTPClient.STATUS_CONNECTED:
		res = Vector.client.request(
			HTTPClient.METHOD_GET,
			"/_matrix/client/v3/rooms/{0}/aliases".format([room_id]),
			Vector.headers)
		var msg = await Vector.readRequestBytes()
		var pmsg = JSON.parse_string(msg)
		return pmsg
