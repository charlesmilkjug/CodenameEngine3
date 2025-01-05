package funkin.backend.internet;

import String;
import StringBuf;
import Reflect;

/**
* A data object that can be customized for `WebSocketUtil` to send data to the server.
* Srt was the person that made the data idea with first version of Codename Engine Multiplayer Test.
*
* Here is an example of how the default packet looks like:
* `<PACKET::onReady::key=>value::ENDPACKET>`
*
* On the server side its considered as a string so you can use splits to get the data.
**/
class WebSocketPacket {

	/**
	* The starting prefix of the packet.
	**/
	static var startPrefix(default, set):String = "<PACKET";
	private static function set_startPrefix(value:String):String { return value.trim(); }
	/**
	* The ending prefix of the packet.
	**/
	static var endPrefix(default, set):String = "ENDPACKET>";
	private static function set_endPrefix(value:String):String { return value.trim(); }

	/**
	* The pointer to the value.
	* Default example:
	* `key=>value`
	**/
	static var dataPointer(default, set):String = "=>";
	private static function set_dataPointer(value:String):String { return value.trim(); }
	
	/**
	* Splits the packet from key / values.
	* Default example:
	* `key=>value::key2=>value2`
	**/
	static var dataSplit(default, set):String = "::";
	private static function set_dataSplit(value:String):String { return value.trim(); }

	/**
	* Just normal json data that is being held for the packet to stringify.
	**/
	private var packetData:Dynamic = {};
	
	/**
	* The name of the event the server handles.
	* If null it won't be added in the packet.
	**/
	public var packetEventName:String;

	/**
	* @param packetName The name of the event the server handles.
	* @param packetData The data that is being sent to the server. Can also be a stringified JSON.
	**/
	public function new(packetName:Null<String>, packetData:Dynamic) {
		this.packetEventName = (packetName == null) ? "" : packetName; 

		if (packetData is String) packetData = haxe.Json.parse(packetData);
		this.packetData = packetData;
	}

	/**
	* Checks if the packet has the field.
	* @param field The field to check for
	* @return If the packet has the field.
	**/
	public function exists(field:String):Bool {
		return Reflect.hasField(this.packetData, field);
	}

	/**
	* Gets the packet field.
	* @param field The field to get the value.
	* @return the value of the field.
	**/
	public function get(field:String):Dynamic {
		return Reflect.field(this.packetData, field);
	}

	/**
	* Sets a value to the packet.
	* @param field The field to get the value.
	* @param value The value to set.
	* @return the packet data as a JSON structure.
	**/
	public function set(field:String, value:Dynamic) {
		Reflect.setField(this.packetData, field, value);
		return this.packetData;
	}

	/**
	* Converts the packet to a string.
	* @return The packet as a string.
	**/
	public function toString():String {
		var data:StringBuf = new StringBuf();
		if (WebSocketPacket.startPrefix != "" && this.packetEventName != "") data.add('${WebSocketPacket.startPrefix}${WebSocketPacket.dataSplit}${this.packetEventName}');
		for (field in Reflect.fields(this.packetData)) data.add('${WebSocketPacket.dataSplit}${field}${WebSocketPacket.dataPointer}${Reflect.getProperty(this.packetData, field)}');
		if (WebSocketPacket.endPrefix != "") data.add('${WebSocketPacket.dataSplit}${WebSocketPacket.endPrefix}');
		return data.toString();
	}
}