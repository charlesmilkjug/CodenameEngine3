/**
 * Hey CodenameCrews, whenever cne internal haxelibs are used (openfl, lime)
 * Please Convert all of these macro codes to that source code!
 */

package funkin.backend.system.macros;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import haxe.macro.ExprTools;

class InternalMacro {
	public static function init() {
		final buildMacro = 'funkin.backend.system.macros.InternalMacro';
		Compiler.addMetadata('@:build($buildMacro.buildNativeHTTPRequest())', 'lime._internal.backend.native.NativeHTTPRequest');
		Compiler.addMetadata('@:build($buildMacro.buildCairoGraphics())', 'openfl.display._internal.CairoGraphics');
		Compiler.addMetadata('@:build($buildMacro.buildBitmapData())', 'openfl.display.BitmapData');
		Compiler.addMetadata('@:build($buildMacro.buildOpenGLRenderer())', 'openfl.display.OpenGLRenderer');
	}

	// fix maxThreads locked to 1
	public static macro function buildNativeHTTPRequest():Array<Field> {
		final fields:Array<Field> = Context.getBuildFields();
		for (f in fields) if (f.name == 'loadData') switch (f.kind) {
			case FFun(func): switch (func.expr.expr) {
				case EBlock(exprs):
					exprs.insert(0, macro if ($i{"localThreadPool"} != null) $i{"localThreadPool"}.maxThreads = 2);
				default:
			}
			default:
		}
		return fields;
	}

	// fix hardware cairo
	public static macro function buildCairoGraphics():Array<Field> {
		final fields:Array<Field> = Context.getBuildFields();
		for (f in fields) if (f.name == 'createImagePattern') switch (f.kind) {
			case FFun(func): switch (func.expr.expr) {
				case EBlock(exprs):
					exprs.insert(0, macro if ($p{["bitmapFill", "__surface"]} == null) return null);
				default:
			}
			default:
		}
		return fields;
	}

	// fix cairo surface
	public static macro function buildBitmapData():Array<Field> {
		final fields:Array<Field> = Context.getBuildFields();
		for (f in fields) if (f.name == 'getSurface') switch (f.kind) {
			case FFun(func): switch (func.expr.expr) {
				case EBlock(exprs):
					exprs.insert(0, macro if ($i{"__surface"} != null) return $i{"__surface"});
				default:
			}
			default:
		}
		return fields;
	}

	// fix innacruate EPSILON on pixel snapping auto something idfk
	// might aswell just make it so it doesnt use Matrix _pool
	public static macro function buildOpenGLRenderer():Array<Field> {
		final fields:Array<Field> = Context.getBuildFields();
		for (f in fields) if (f.name == '__getMatrix') switch (f.kind) {
			case FFun(func): func.expr = macro {
				$i{"__matrix"}[0] = $i{"transform"}.a * $i{"__worldTransform"}.a + $i{"transform"}.b * $i{"__worldTransform"}.c;
				$i{"__matrix"}[1] = $i{"transform"}.a * $i{"__worldTransform"}.b + $i{"transform"}.b * $i{"__worldTransform"}.d;
				$i{"__matrix"}[2] = 0;
				$i{"__matrix"}[3] = 0;
				$i{"__matrix"}[4] = $i{"transform"}.c * $i{"__worldTransform"}.a + $i{"transform"}.d * $i{"__worldTransform"}.c;
				$i{"__matrix"}[5] = $i{"transform"}.c * $i{"__worldTransform"}.b + $i{"transform"}.d * $i{"__worldTransform"}.d;
				$i{"__matrix"}[6] = 0;
				$i{"__matrix"}[7] = 0;
				$i{"__matrix"}[8] = 0;
				$i{"__matrix"}[9] = 0;
				$i{"__matrix"}[10] = 1;
				$i{"__matrix"}[11] = 0;
				$i{"__matrix"}[12] = $i{"transform"}.tx * $i{"__worldTransform"}.a + $i{"transform"}.ty * $i{"__worldTransform"}.c + $i{"__worldTransform"}.tx;
				$i{"__matrix"}[13] = $i{"transform"}.tx * $i{"__worldTransform"}.b + $i{"transform"}.ty * $i{"__worldTransform"}.d + $i{"__worldTransform"}.ty;
				$i{"__matrix"}[14] = 0;
				$i{"__matrix"}[15] = 1;

				if ($i{"pixelSnapping"} == openfl.display.PixelSnapping.ALWAYS ||
					($i{"pixelSnapping"} == openfl.display.PixelSnapping.AUTO
						&& $i{"__matrix"}[1] == 0 && $i{"__matrix"}[4] == 0
						&& $i{"__matrix"}[0] < 1.0000001 && $i{"__matrix"}[0] > 0.9999999
					)	&& $i{"__matrix"}[5] < 1.0000001 && $i{"__matrix"}[5] > 0.9999999
				) {
					$i{"__matrix"}[12] = Math.round($i{"__matrix"}[12]);
					$i{"__matrix"}[13] = Math.round($i{"__matrix"}[13]);
				}

				$i{"__matrix"}.append($i{"__flipped"} ? $i{"__projectionFlipped"} : $i{"__projection"});

				for (i in 0...16) $i{"__values"}[i] = $i{"__matrix"}[i];
				return $i{"__values"};
			}
			default:
		}
		return fields;
	}
}
#else
class InternalMacro {}
#end