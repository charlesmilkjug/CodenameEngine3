package funkin.backend.system.net;

import funkin.backend.assets.ModsFolder;
import funkin.backend.system.macros.GitCommitMacro;

import haxe.Serializer;

import Date;
import StringBuf;
import String;
import Reflect;

/**
* A data object that can be customized for `WebSocketUtil` to send data to the server.
* You will need to handle the custom packet on your server yourself.
*
* GENERAL WEBSOCKET WARNING: Sending data to the server on `update` SHOULD NEVER BE DONE!!
* It will be slow and generally not a good idea. It might overload the server and cause unforseen issues.
*
* Why use a packet class instead of sending your own data? Well this Serializes the data and handles it for you, so all you do is just send the class in the `WebSocketUtil.send` and thats it.
**/
class WebSocketPacket {
	/**
	* Just normal data that is being held for the packet to get stringified.
	**/
	private var packetData:Dynamic = {};

	/**
	* The name of the event the server handles.
	* If null it won't be added in the packet.
	**/
	public var packetEventName(default, set):String;
	private function set_packetEventName(value:String):String {
		if (value == null) return "";
		return this.packetEventName = value;
	}

	@:dox(hide) private var add_meta_data:Bool = true;

	/**
	* @param packetName The name of the event the server handles.
	* @param packetData The data that is being sent to the server. Can also be a stringified JSON.
	* @param add_meta_data If true, adds metadata to the packet. This is useful for data like the time it was sent, 
	**/
	public function new(packetName:Null<String>, packetData:Dynamic, ?_add_meta_data:Bool = true) {
		this.packetEventName = packetName;
		this.add_meta_data = _add_meta_data;

		// in case ig
		try {
			if (packetData is String) packetData = haxe.Json.parse(packetData);
		} catch (e:Dynamic) {
			trace("Error parsing string data to packet: " + e);
		}

		this.packetData = packetData;

		if (this.add_meta_data) {
			try {
				if (ModsFolder.currentModFolder != null) this.packetData.__mod = ModsFolder.currentModFolder;
				this.packetData.__commitHash = GitCommitMacro.commitHash; // for checking outdated action builds on the server. its gonna be peak trust.
			} catch (e:Dynamic) {
				trace("Error adding metadata to packet: " + e);
			}
		}

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
	* Converts the packet to a string. Uses `Serializer` to convert the packet to a data string
	* @return The packet as a string.
	**/
	public function toString():String {
		var cerial = new Serializer();
		var buffer = new StringBuf();

		// if no name is associated with packet, just serialize the data
		if (packetEventName != "") {
			buffer.add('!HXP');
			buffer.add(this.packetEventName);
			buffer.add('=>');
		} else {
			buffer.add('!HXp');
		}

		if (add_meta_data) this.packetData.__timestamp = Date.now().getTime();

		cerial.serialize(this.packetData);
		return '${buffer.toString()}${cerial.toString()}';
	}
}