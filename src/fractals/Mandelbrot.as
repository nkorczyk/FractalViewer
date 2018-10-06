package fractals {
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import mx.controls.Alert;
	import mx.core.Application;
	
	import org.greenthreads.GreenThread;
	
	[Event(name='progress', type='flash.events.ProgressEvent')]
	[Event(name='complete', type='flash.events.Event')]
	public class Mandelbrot extends GreenThread {
		
		private var _bitmap : BitmapData;
		private var _maxIteration : uint = 100;
		private var _realMin : Number = -2.0;
		private var _realMax : Number = 1.0;
		private var _imaginaryMin : Number = -1.0;
		private var _imaginaryMax : Number = 1.0;
		private var _shader : Shader;
		
		private var _realStep : Number;
		private var _imaginaryStep : Number;
		private var screenx : int = 0;
		private var screeny : int = 0;
		
		public function Mandelbrot() {
			super(true);
		}
		
		override protected function initialize():void {
			maximum = 100.0;
		}
		
		override protected function run():Boolean {
			if( screenx > _bitmap.width ) {
				screenx = 0;
				screeny++;
			}
			if( screeny < _bitmap.height ) {
				var x : Number = screenx * _realStep + _realMin;
				var y : Number = screeny * _imaginaryStep + _imaginaryMin;
				var x0 : Number = x;
				var y0 : Number = y;
				var iteration : int = 0;
				while( x * x + y * y <= (2 * 2) && iteration < _maxIteration ) {
					var xtemp : Number = x * x - y * y + x0;
					y = 2 * x * y + y0;
					x = xtemp;
					iteration = iteration + 1;
				}
				
				if( iteration == _maxIteration ) {
					_bitmap.setPixel( screenx, screeny, 0x000000 );
				} else {
					_bitmap.setPixel( screenx, screeny, shader.lookup( Number(iteration) / Number(maxIteration) ) );
				}
				screenx++;
				return true;
			} else {
				return false;
			}
		}
		
		override public function get progress() : Number {
			return Number(screeny * _bitmap.width + screenx) / Number(_bitmap.width * _bitmap.height) * 100.0;
		}

		public function calculateAsync( width : int, height : int ) : void {
			_bitmap = new BitmapData( width, height, false, 0x020202 );
			screenx = screeny = 0;
			_realStep = (_realMax - _realMin) / Number(_bitmap.width);
			_imaginaryStep = ( _imaginaryMax - _imaginaryMin ) / Number( _bitmap.height );
			addEventListener( Event.COMPLETE, function( event : Event ) : void {
				trace( statisitcs.print() );
			});
			maximum = 100.0;
			start();
		}
		
		public function calculate( width : int, height : int ) : void {
			_bitmap = new BitmapData( width, height, false, 0x020202 );
		
			var realStep : Number = (_realMax - _realMin) / Number(_bitmap.width);
			var imaginaryStep : Number = ( _imaginaryMax - _imaginaryMin ) / Number( _bitmap.height );
			
			for( var screeny : int = 0; screeny < _bitmap.height; screeny++ ) {
				for( var screenx : int = 0; screenx < _bitmap.width; screenx++ ) {
					var x : Number = screenx * realStep + _realMin;
					var y : Number = screeny * imaginaryStep + _imaginaryMin;
					var x0 : Number = x;
					var y0 : Number = y;
					var iteration : int = 0;
					while( x * x + y * y <= (2 * 2) && iteration < _maxIteration ) {
						var xtemp : Number = x * x - y * y + x0;
						y = 2 * x * y + y0;
						x = xtemp;
						iteration = iteration + 1;
					}
					
					if( iteration == _maxIteration ) {
						_bitmap.setPixel( screenx, screeny, 0x000000 );
					} else {
						_bitmap.setPixel( screenx, screeny, shader.lookup( Number(iteration) / Number(maxIteration) ) );
					}
				}
			}
			var evt : Event = new Event( Event.COMPLETE );
			dispatchEvent( evt );
		}
		
		public function calculateSlowly( width : int, height : int ) : void {
			_bitmap = new BitmapData( width, height, false, 0x020202 );
			screenx = screeny = 0;
			_realStep = (_realMax - _realMin) / Number(_bitmap.width);
			_imaginaryStep = ( _imaginaryMax - _imaginaryMin ) / Number( _bitmap.height );
			maximum = 100.0;
			slowRenderer();
		}
		
		public function slowRenderer() : void {
			if( run() ) {
				var evt : ProgressEvent = new ProgressEvent( ProgressEvent.PROGRESS );
				evt.bytesLoaded = progress;
				evt.bytesTotal = maximum;
				dispatchEvent( evt );
				Application.application.callLater( this.slowRenderer );
			} else {
				dispatchEvent( new Event( Event.COMPLETE ) );
			}
		}
		
		public function get maxIteration() : int {
			return _maxIteration;
		}
		
		public function set maxIteration( value : int ) : void {
			_maxIteration = value;
		}
		
		public function get shader() : Shader {
			return _shader;
		}		
		
		public function set shader( value : Shader ) : void {
			_shader = value;
		}
		
		public function get realMin() : Number {
			return _realMin;
		}
		
		public function set realMin( value : Number ) : void {
			_realMin = value;
		}
		
		public function get realMax() : Number {
			return _realMax;
		}
		
		public function set realMax( value : Number ) : void {
			_realMax = value;
		}
		
		public function get imaginaryMin() : Number {
			return _imaginaryMin;
		}
		
		public function set imaginaryMin( value : Number ) : void {
			_imaginaryMin = value;
		}
		
		public function get imaginaryMax() : Number {
			return _imaginaryMax;
		}
		
		public function set imaginaryMax( value : Number ) : void {
			_imaginaryMax = value;
		}
		
		public function get bitmap() : BitmapData {
			return _bitmap;
		}
		
		public function get history() : MandelbrotHistory {
			return new MandelbrotHistory( realMin, imaginaryMin, realMax, imaginaryMax, bitmap );
		}
		
		public function zoom( x : int, y : int, width : int, height : int ) : MandelbrotHistory {
			var last : MandelbrotHistory = history;
			
			var newRealMin : Number = Number(x) * (realMax - realMin ) / Number(_bitmap.width); 
			var newRealMax : Number = Number(x + width) * (realMax - realMin ) / Number(_bitmap.width);
			var newImaginaryMin : Number = Number( y) * (imaginaryMax - imaginaryMin) / Number( _bitmap.height ); 
			var newImaginaryMax : Number = Number( y + height ) * (imaginaryMax - imaginaryMin) / Number( _bitmap.height );
			
			realMax = realMin + newRealMax;
			realMin += newRealMin;
			imaginaryMax = imaginaryMin + newImaginaryMax;
			imaginaryMin += newImaginaryMin;
			
			trace( 'zoom', '(', realMin, imaginaryMin,')', '(', realMax, imaginaryMax, ')' );
			return last; 
		}
		
		public function restore( history : MandelbrotHistory ) : void {
			realMin = history.realMin;
			realMax = history.realMax;
			imaginaryMin = history.imaginaryMin;
			imaginaryMax = history.imaginaryMax;
			_bitmap = history.bitmapData;
		}
	}
}
