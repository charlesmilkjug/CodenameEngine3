package funkin.backend.internet;

import hx.ws.*;

import funkin.backend.system.Logs;

/**
* Basically a Utility for HScript to use WebSockets. Adds safeguards, error handling, and logging to debug your WebSockets.
* ItsLJcool wanted to make CodenameEngine Online / Multiplayer. This will make it easier to do so.
*
* This does NOT support making a Server Side WebSocket. Its only for Client Side WebSockets. If you want to make a Server you need to that yourself.
* I'd suggest using JavaScript for it. Though any program will do.
**/
class WebSocketUtil implements IFlxDestroyable {
	/**
	* Used for the `toggleLogging` function. this is more of a data handler for the function.
	**/
	static var loggingEnabled:Bool = false;
	
	/**
	* Call this function to toggle debugging for the WebSocket.
	**/
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

	/**
	* Function calls after the WebSocket has been opened.
	* @param webSocket Returns the instance of the WebSocket.
	**/
	public var onOpen:WebSocket->Void = (webSocket)->{};
	
	/**
	* Whenever the WebSocket receives a message sent from the server.
	* @param message Returns the message sent from the server.
	**/
	public var onMessage:Dynamic->Void = (message)->{};
	
	/**
	* Runs whenever the WebSocket closes.
	**/
	public var onClose:Void->Void = ()->{};
	
	/**
	* Runs whenever the WebSocket encounters an error.
	**/
	public var onError(default, set):Dynamic->Void = (error)->{};
	private function set_onError(_errorFunc):Dynamic->Void {
		var func = (error)->{
			Logs.traceColored([
				Logs.logText("[WebSocket Error] ", RED),
				Logs.logText('${error}'),
			], ERROR);
			if (_errorFunc != null) _errorFunc(error);
		};
		return this.onError = func;
	}

	@:dox(hide) private var url:String;
	@:dox(hide) private var webSocket:WebSocket;
	
	/**
	* @param url The URL of the WebSocket. Usually `ws://localhost:port`.
	* @param onOpen sets the `onOpen` function directly to the class.
	* @param immediateOpen If true, the WebSocket will open immediately. Hence why `onOpen` is a function in the parameters.
	**/
	public function new(url:String, ?onOpen:WebSocket->Void, ?immediateOpen:Bool = false) {
		this.onOpen = (onOpen == null) ? this.onOpen : onOpen;
		this.onError = this.onError;

		this.url = url;
		this.webSocket = new WebSocket(this.url, false);

		this.webSocket.onopen = function() {
			try {
				this.onOpen(webSocket);
			} catch(error) {
				this.onError(error);
			}
		};

		this.webSocket.onmessage = function(message) {
			var data:Dynamic = null;
			try {
				switch(message) {
					case StrMessage(str):
						data = str;
					case BytesMessage(bytes):
						data = bytes;
				}
				this.onMessage(data);
			} catch(e) {
				this.onError(e);
			}
		};

		this.webSocket.onclose = function() {
			try {
				this.onClose();
			} catch(e) {
				this.onError(e);
			}
		};

		this.webSocket.onerror = this.onError;
		
		if (immediateOpen) this.open();
	}

	/**
	* Opens the WebSocket.
	**/
	public function open() {
		Logs.traceColored([
			Logs.logText("[WebSocket Connection] ", BLUE),
			Logs.logText('Connecting to ${this.url}'),
		], INFO);
		try {
			this.webSocket.open();
		} catch(e) {
			this.onError(e);
		}
	}

	/**
	* Closes the WebSocket.
	**/
	public function close() {
		Logs.traceColored([
			Logs.logText("[WebSocket Connection] ", BLUE),
			Logs.logText('Closing connection to ${this.url}'),
		], INFO);
		try {
			this.webSocket.close();
		} catch(e) {
			this.onError(e);
		}
	}

	/**
	* Sends data to the server
	**/
	public function send(data) {
		try {
			this.webSocket.send(data);
		} catch(e) {
			this.onError(e);
		}
	}

	/**
	* Closes the WebSocket and destroys the class instance.
	**/
	public function destroy() {
		this.webSocket.close();
	}
}