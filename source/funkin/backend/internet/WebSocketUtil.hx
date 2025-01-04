package funkin.backend.internet;

import haxe.io.Bytes;
import hx.ws.Log;
import hx.ws.WebSocket;

import funkin.backend.system.Logs;

class WebSocketUtil implements IFlxDestroyable {

	static var loggingEnabled:Bool = false;
	static function toggleLogging(?INFO:Bool = true, ?DEBUG:Bool = true, ?DATA:Bool = true) {
		loggingEnabled = !loggingEnabled;
		if (!loggingEnabled) return Log.mask = 0;

		var _mask = Log.mask;
		if (INFO) _mask = _mask | Log.INFO;
		if (DEBUG) _mask = _mask | Log.DEBUG;
		if (DATA) _mask = _mask | Log.DATA;
		Log.mask = _mask;

		return Log.mask;
	}

	public var onOpen:WebSocket->Void = (webSocket)->{};
	public var onMessage:Void->Void = ()->{};
	public var onClose:Void->Void = ()->{};
	public var onError:Dynamic->Void = (error)->{};

	private var url:String;
	private var webSocket:WebSocket;
    public function new(url:String, ?onOpen:WebSocket->Void, ?immediateOpen:Bool = false) {
		this.onOpen = (onOpen == null) ? this.onOpen : onOpen;

		this.url = url;
		this.webSocket = new WebSocket(this.url, false);

		// TODO: make trace print colors with `Logs.hx`
        this.webSocket.onopen = function() {
			try {
				this.onOpen(webSocket);
			} catch(e) {
				trace('Error: ${e}');
			}
        };

        this.webSocket.onmessage = function(message) {
			try {
				this.onMessage();
			} catch(e) {
				trace('Error: ${e}');
			}
        };

        this.webSocket.onclose = function() {
			try {
				this.onClose();
			} catch(e) {
				trace('Error: ${e}');
			}
        };

        this.webSocket.onerror = function(error) {
			trace('Websocket error: ${error}');
			try {
				this.onError(error);
			} catch(e) {
				trace('Error: ${e}');
			}
        };
		
		if (immediateOpen) this.open();
    }

	public function open() {
		trace('[Connection Status] Connecting to ${this.url}');
		try {
			this.webSocket.open();
		} catch(e) {
			trace("Failed to open websocket: " + e);
			this.onError(e);
		}
	}

	public function close() {
		trace('[Connection Status] Closing connection to ${this.url}');
		try {
			this.webSocket.close();
		} catch(e) {
			trace("Failed to close websocket: " + e);
		}
	}

	public function send(data:String) {
		try {
			this.webSocket.send(data);
		} catch(e) {
			trace("Failed to send data to websocket: " + e);
		}
	}

	public function destroy() {
		this.webSocket.close();
	}
}

