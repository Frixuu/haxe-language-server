package haxeLanguageServer.helper;

final class ZedHelper {
	public static function removeOneRepeat<T>(arr:Array<T>):Array<T> {
		final length = arr.length;
		if (length <= 1) {
			return arr;
		}

		if (length % 2 == 1) {
			return arr;
		}

		final halfLength = Std.int(length / 2);
		for (i in 0...halfLength) {
			if (arr[i] != arr[halfLength + i]) {
				return arr;
			}
		}

		return arr.slice(0, halfLength);
	}
}
