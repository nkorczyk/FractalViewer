package fractals {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	
	public class MandelbrotHistory {
		
		public var realMin : Number;
		public var imaginaryMin : Number;
		public var realMax : Number;
		public var imaginaryMax : Number;
		public var bitmap : Bitmap;
		
		public function MandelbrotHistory( realMin : Number, imaginaryMin : Number, realMax : Number, imaginaryMax : Number, bitmap : BitmapData ) {
			this.realMin = realMin;
			this.realMax = realMax;
			this.imaginaryMin = imaginaryMin;
			this.imaginaryMax = imaginaryMax;
			this.bitmap = new Bitmap( bitmap );
		}
		
		public function get bitmapData() : BitmapData {
			return this.bitmap.bitmapData;
		}

	}
}