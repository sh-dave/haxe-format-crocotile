package;

// import kha.math.FastVector3;

class Main extends Base {
	public static function main()
		kha.System.init(
				{ title: 'crocotile3d-viewer-kha', width : 1024, height : 768 },
				kha.Assets.loadEverything.bind(setup)
		);

	public static function setup()
		new Main();

	function new() {
		super();
		init();
	}

	function init() {
		var scene = new format.crocotile.Reader(kha.Assets.blobs.swamp_crocotile.toString()).read();
		var tilesetB64 = format.crocotile.Tools.getTextureData(scene.model[0].texture);
		var tilesetData = haxe.crypto.Base64.decode(tilesetB64);
		var png = new format.png.Reader(new haxe.io.BytesInput(tilesetData)).read();
		var pngHeader = format.png.Tools.getHeader(png);
		var pngBytes = format.png.Tools.extract32(png);
		var rgba = haxe.io.Bytes.alloc(pngBytes.length);

		for (y in 0...pngHeader.height) {
			for (x in 0...pngHeader.width) {
				var at = y * pngHeader.width * 4;

				var b = pngBytes.get(at + x * 4 + 0);
				var g = pngBytes.get(at + x * 4 + 1);
				var r = pngBytes.get(at + x * 4 + 2);
				var a = pngBytes.get(at + x * 4 + 3);
				var af = a / 255;

#if flash
		// flash actually uses bgra
				rgba.set(at + x * 4 + 0, b);
				rgba.set(at + x * 4 + 1, g);
				rgba.set(at + x * 4 + 2, r);
				rgba.set(at + x * 4 + 3, a);
#else
		// bgra -> rgba
				rgba.set(at + x * 4 + 0, r);
				rgba.set(at + x * 4 + 1, g);
				rgba.set(at + x * 4 + 2, b);
				rgba.set(at + x * 4 + 3, a);
#end
			}
		}

		var tileset = kha.Image.fromBytes(rgba, pngHeader.width, pngHeader.height);

		var vertexCount = Lambda.fold(scene.model[0].object, function( o, l ) return l + o.vertices.length * 3, 0);
		var indexCount = Lambda.fold(scene.model[0].object, function( o, l ) return l + o.faces.length * 3, 0);

		vb = new kha.graphics4.VertexBuffer(vertexCount, vs, kha.graphics4.Usage.StaticUsage);
		ib = new kha.graphics4.IndexBuffer(indexCount, kha.graphics4.Usage.StaticUsage);

		var vbi = 0;
		var ibi = 0;
		var vc = 0;
		var ibd = ib.lock();
		var vbd = vb.lock();

			for (o in scene.model[0].object) {
				for (faceIndex in 0...o.faces.length) {
					// var vx1 = o.vertices[o.faces[faceIndex][0]];
					// var vx2 = o.vertices[o.faces[faceIndex][1]];
					// var vx3 = o.vertices[o.faces[faceIndex][2]];
					// var v1 = new FastVector3(vx1.x, vx1.y, vx1.z);
					// var v2 = new FastVector3(vx2.x, vx2.y, vx2.z);
					// var v3 = new FastVector3(vx3.x, vx3.y, vx3.z);
					// var n1 = v2.sub(v1);
					// var n2 = v3.sub(v1);
					// var n = n2.cross(n1);
					// n.normalize();

					for (fi in 0...o.faces[faceIndex].length) {
						var vertex = o.vertices[o.faces[faceIndex][fi]];
						var uv = o.uvs[faceIndex][fi];

						vbd.set(vbi++, o.position.x + vertex.x);
						vbd.set(vbi++, o.position.y + vertex.y);
						vbd.set(vbi++, o.position.z + vertex.z);
						vbd.set(vbi++, uv.x);
						vbd.set(vbi++, 1 - uv.y); // uv's in kha are top/left 0;0 -> bottom/right 1;1?
						vbd.set(vbi++, 1.0);
						vbd.set(vbi++, 1.0);
						vbd.set(vbi++, 1.0);
						vbd.set(vbi++, 1.0);
						// vbd.set(vbi++, n.x);
						// vbd.set(vbi++, n.y);
						// vbd.set(vbi++, n.z);

						ibd[ibi++] = vc++;
					}
				}
			}

		vb.unlock();
		ib.unlock();

		kha.System.notifyOnRender(render.bind(_, tileset));
		kha.Scheduler.addTimeTask(step, 0, 1 / 60);
	}
}
