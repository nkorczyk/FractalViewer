package fractals {
	public class Shader {
		private var _gradientColors : Array;
		private var _gradientPositions : Array = [];
		
		public function Shader() {
		}
		
		public function lookup( percentage : Number ) : uint {
			var i : int = 0;
			for each( var p : Number in _gradientPositions ) {
				if( percentage < p ) {
					break;
				}
				i++;
			}
			var startColor : uint = _gradientColors[ i - 1 ];
			var endColor : uint = _gradientColors[ i ];
			
			percentage = percentage / _gradientPositions[i]; // translate to 0.0 - 1.0 scale.
			var r : uint = gradient( red( startColor ), red( endColor ), percentage );
			var g : uint = gradient( green( startColor ), green( endColor ), percentage );
			var b : uint = gradient( blue( startColor ), blue( endColor ), percentage );
			
			return rgba( r,g,b );
		}
		
		private function red( color : uint ) : uint {
			return (color >> 16) & 0xff;
		}
		
		private function green( color : uint ) : uint {
			return (color >> 8) & 0xff;
		}
		
		private function blue( color : uint ) : uint {
			return color & 0xff;
		}
		
		private function rgba( r : uint, g : uint, b : uint, a : uint = 0xff ) : uint {
			return (a << 24) + (r << 16) + (g << 8) + b;			
		}
		
		private function gradient( start : uint, end : uint, p : Number ) : uint {
			return start * (1.0 - p) + end * p;
		}
		
		public function get gradientColors() : Array {
			return _gradientColors;
		}
		
		public function set gradientColors( value : Array ) : void {
			_gradientColors = value;
		}
		
		public function get gradientPositions() : Array {
			return _gradientPositions;
		}

		public function set gradientPositions( value : Array ) : void {
			_gradientPositions = value;
		}
		
	}
}