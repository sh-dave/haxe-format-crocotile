package;

import kha.graphics4.BlendingFactor;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.math.FastMatrix4;
import kha.math.FastVector3;

class Base {
	var cameraDistance = 25.0;
	var cameraPitch = 3.8;
	var cameraRoll = -0.265;

	var tx = 0;
	var ty = 0;
	var tz = 5;

	var mouseDown = false;
	var mdx = 0.0;
	var mdy = 0.0;
	var mx = 0.0;
	var my = 0.0;

	var vs : kha.graphics4.VertexStructure;
	var vb : kha.graphics4.VertexBuffer;
	var ib : kha.graphics4.IndexBuffer;
	var pipe : kha.graphics4.PipelineState;

	var normalId : ConstantLocation;
	var mvId : ConstantLocation;
	var pId : ConstantLocation;
	var tId : TextureUnit;

	var model : FastMatrix4;
	var view : FastMatrix4;
	var projection : FastMatrix4;

	public function new() {
		setupInput();
		setup3d();
	}

	function step() {
		if (mouseDown) {
			cameraPitch += mdx * -0.005;
			cameraRoll += mdy * -0.005;

			var p2 = Math.PI / 2;

			 if (cameraRoll < -p2) {
			 	cameraRoll = -p2;
			 }

			 if (cameraRoll > p2) {
			 	cameraRoll = p2;
			 }
		}

		var target = new FastVector3(tx / 2, ty * 0.25, tz / 2);
		var up = new FastVector3(0, 1, 0);
		var eye = new FastVector3(
			Math.cos(cameraRoll) * Math.sin(cameraPitch),
			Math.sin(cameraRoll),
			Math.cos(cameraRoll) * Math.cos(cameraPitch)
		);

		eye.normalize();
		eye = eye.mult(cameraDistance);
		eye = target.sub(eye);

		view = FastMatrix4.lookAt(
			eye,
			target,
			up
		);

		mdx = 0;
		mdy = 0;
	}

	function setupInput() kha.input.Mouse.get().notify(mouse_downHandler, mouse_upHandler, mouse_moveHandler, mouse_wheelHandler);
	function mouse_downHandler( b : Int, x : Int, y : Int ) mouseDown = true;
	function mouse_upHandler( b : Int, x : Int, y : Int ) mouseDown = false;

	function mouse_moveHandler( x : Int, y : Int, mx : Int, my : Int ) {
		mdx = x - this.mx;
		mdy = y - this.my;

		this.mx = x;
		this.my = y;
	}

	function mouse_wheelHandler( delta : Int ) {
		if (delta < 0) {
			cameraDistance -= 1;
		} else if (delta > 0) {
			cameraDistance += 1;
		}
	}

	function setup3d() {
		projection = FastMatrix4.perspectiveProjection(Math.PI / 4, 4 / 3, 0.1, 1000);
		model = FastMatrix4.identity();

		vs = new kha.graphics4.VertexStructure();
		vs.add('avertexPosition', kha.graphics4.VertexData.Float3);
		vs.add('avertexUV', kha.graphics4.VertexData.Float2);
		// vs.add('aVertexNormal', kha.graphics4.VertexData.Float3);
		vs.add('vertexColor', kha.graphics4.VertexData.Float4);

		pipe = new kha.graphics4.PipelineState();
		pipe.inputLayout = [vs];
		pipe.vertexShader = kha.Shaders.textured_vert;
		pipe.fragmentShader = kha.Shaders.textured_frag;
		// pipe.vertexShader = kha.Shaders.simple_vert;
		// pipe.fragmentShader = kha.Shaders.simple_frag;
		pipe.depthWrite = true;
		pipe.depthMode = kha.graphics4.CompareMode.Less;
		pipe.cullMode = kha.graphics4.CullMode.Clockwise;
		pipe.blendSource = BlendingFactor.BlendOne;
		pipe.blendDestination = BlendingFactor.InverseSourceAlpha;
		pipe.compile();

		// normalId = pipe.getConstantLocation('uNormalMatrix');
		// mvId = pipe.getConstantLocation('uMVMatrix');
		pId = pipe.getConstantLocation('projectionMatrix');
		// pId = pipe.getConstantLocation('uPMatrix');

		tId = pipe.getTextureUnit('textureLocation');
	}

	function render( fb : kha.Framebuffer, tex : kha.Image ) {
		var f4 = fb.g4;

		if (vb != null) {
			var mv = FastMatrix4.identity()
				.multmat(view)
				.multmat(model);

			var mvp = projection.multmat(mv);
			// var normal = mv.inverse().transpose();

			f4.begin();
				f4.clear(kha.Color.Red, 1.0, 0);
				f4.setPipeline(pipe);

				// f4.setMatrix(mvId, mv);
				// f4.setMatrix(pId, projection);
				// f4.setMatrix(normalId, normal);
				f4.setMatrix(pId, mvp);
				f4.setTexture(tId, tex);

				f4.setVertexBuffer(vb);
				f4.setIndexBuffer(ib);
				f4.drawIndexedVertices();
				f4.setTexture(tId, null);
			f4.end();
		}

		var f2 = fb.g2;
		f2.begin(false);
			f2.drawImage(tex, 0, 0);
		f2.end();
	}
}
