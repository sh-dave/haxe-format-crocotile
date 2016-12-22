package format.crocotile;

import format.crocotile.Data;

class Reader {
	var data : String;

	public function new( data : String ) this.data = data;

	public function read() : Scene {
#if tink_json
		var scene : Scene = tink.Json.parse(data);
#else
		var scene : Scene = haxe.Json.parse(data);
#end
		return scene;
	}
}
