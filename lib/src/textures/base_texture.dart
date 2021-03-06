part of pixi;


class BaseTexture
{
	static Map<String, BaseTexture> _baseCache	= {};
	static List<BaseTexture> _toUpdate			= [];
	static List<BaseTexture> _toDestroy			= [];


	int _width = 100;
	int get width => this._width;

	int _height = 100;
	int get height => this._height;

	bool _hasLoaded = false;
	bool get hasLoaded => this._hasLoaded;

	Element _source;
	Element get source => this._source;

	StreamController _loadedController = new StreamController.broadcast();
	Stream get onLoaded => this._loadedController.stream;

	GL.Texture _glTexture = null;
	bool _powerOf2 = false;


	BaseTexture(Element source)
	{
		this._source = source;

		if (source is ImageElement)
		{
			if (source.complete)
			{
				this._hasLoaded = true;
				this._width		= source.width;
				this._height	= source.height;
				_toUpdate.add(this);
			}
			else source.onLoad.listen((e) {
				this._hasLoaded = true;
				this._width		= source.width;
				this._height	= source.height;
				_toUpdate.add(this);
				this._loadedController.add('loaded');
			});
		}
		else if (source is CanvasElement)
		{
			this._hasLoaded = true;
			this._width		= source.width;
			this._height	= source.height;
			_toUpdate.add(this);
		}
		else this._source = null;
	}


	void destroy()
	{
		if (this._source is ImageElement)
		{
			(this._source as ImageElement).src = null;
		}

		this._source = null;
		_toDestroy.add(this);
	}


	factory BaseTexture.fromImage(String imageUrl, [bool crossorigin = false])
	{
		var result = _baseCache[imageUrl];

		if (result == null)
		{
			var image = new ImageElement();

			if (crossorigin) image.crossOrigin = '';

			image.src = imageUrl;

			_baseCache[imageUrl] = result = new BaseTexture(image);
		}

		return result;
	}
}
