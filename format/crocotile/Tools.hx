package format.crocotile;

class Tools {
	public static function getTextureData( s : String ) : String
		return s.split('data:image/png;base64,')[1];
}
