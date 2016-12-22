package format.crocotile;

typedef Config = {
	tilesizeX : Int,
	tilesizeY : Int,
	?skybox : String, // same as texture (data:image/png;base64,)
}

typedef Position = {
	x : Float,
	y : Float,
	z : Float,
}

typedef Vertex = {
	x : Float,
	y : Float,
	z : Float,
}

typedef UV = {
	x : Float,
	y : Float,
}

typedef Object = {
	position : Position,
	vertices : Array<Vertex>,
	faces : Array<Array<Int>>,
	uvs : Array<Array<UV>>,
}

typedef ImgFile = {
	path : String,
	name : String,
}

typedef Model = {
	texture : String, // (data:image/png;base64,)
	object : Array<Object>,
	?imgFile : ImgFile,
}

typedef Scene = {
	config : Config,
	model : Array<Model>,
	?prefabs : Array<Dynamic>,
}
