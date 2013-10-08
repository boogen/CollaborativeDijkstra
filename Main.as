package {

    import flash.display.*;
    import flash.geom.*;
    import flash.events.*;
    
    public class Main extends Sprite {

        private var map_h:int = 64;
        private var map_w:int = 64;
        private var field_size:int = 16;
        private var fieldtypes:Vector.<Vector.<int>>;
        
        private const target_color:uint = 0xff0000;
        private const obstacle_color:uint = 0x60a0ff;
        private const path_color:uint = 0x00a000;
        private const border_color:uint = 0x404040;
        private const field_color:uint = 0x010101;

        private var scent:Scent;
        private var path:Vector.<Point>;

        public function Main() {

            fieldtypes = new Vector.<Vector.<int> >();
            for (var i:int = 0; i < map_h; ++i) {
                fieldtypes.push(new Vector.<int>());
                for (var j:int = 0; j < map_w; ++j) {
                    fieldtypes[i].push(FieldType.FT_PLAIN);
                }
            }

            path = new Vector.<Point>();

            stage.addEventListener(Event.ENTER_FRAME, tick);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

            scent = new Scent(map_w, map_h, fieldtypes);
            scent.init();
            scent.loop();
        }


        private function onMouseUp(e:MouseEvent):void {
            var mx:int = e.stageX / field_size;
            var my:int = e.stageY / field_size;

            if (mx < 0 || mx >= map_w || my < 0 || my >= map_h) {
                return;
            }

            if (fieldtypes[my][mx] == FieldType.FT_PLAIN) {
                fieldtypes[my][mx] = FieldType.FT_OBSTACLE;
            }
            else if (fieldtypes[my][mx] == FieldType.FT_OBSTACLE) {
                fieldtypes[my][mx] = FieldType.FT_TARGET;
            }
            else if (fieldtypes[my][mx] == FieldType.FT_TARGET) {
                fieldtypes[my][mx] = FieldType.FT_PLAIN;
            }

            scent = new Scent(map_w, map_h, fieldtypes);
            scent.init();
            scent.loop();
        }

        public function onMouseMove(e:MouseEvent):void {
            var mx:int = e.stageX / field_size;
            var my:int = e.stageY / field_size;

            walk( mx - 0.5, my - 0.5);
        }


        private function walk(x0:Number, y0:Number):void {
            path.length = 0;
            
            while(true) {
                x0 = (int)(32 * x0) * 0.03125;
                y0 = (int)(32 * y0) * 0.03125;

                if (x0 < 0 || x0 >= map_w || y0 < 0 || y0 >= map_h || path.length > 1000) {
                    return;
                }


                path.push(new Point(x0, y0));

                var xi:int = Math.round(x0);
                var yi:int = Math.round(y0);

                if (fieldtypes[yi][xi] == FieldType.FT_TARGET) {
                    return;
                }

                var sel:Number = ipo(x0, y0);
                var seldx:Number = 0;
                var seldy:Number = 0;
                
                for (var i:int = 0; i < 64; ++i) {
                    var fdx:Number = 0.125 * Math.cos(i * Math.PI / 32 );
                    var fdy:Number = 0.125 * Math.sin(i * Math.PI / 32 );
                    
                    var there:Number = ipo(x0 + fdx, y0 + fdy);

                    if (there < sel) {
                        sel = there;
                        seldx = fdx;
                        seldy = fdy;
                    }
                }

                if (seldx == 0 && seldy == 0) {
                    return;
                }

                x0 += seldx;
                y0 += seldy;
            }
        }

        public function linear(k:Number, a:Number, b:Number):Number {
            return a * (1 - k) + b * k;
        }

        public function ipo(x:Number, y:Number):Number {
            var x0:int = x;
            var y0:int = y;

            var dx:Number = x - x0;
            var dy:Number = y - y0;

            var v00:Number = scent.scent[y0][x0];
            var v01:Number = scent.scent[y0][x0 + 1];
            var v10:Number = scent.scent[y0 + 1][x0];
            var v11:Number = scent.scent[y0 + 1][x0 + 1];

            return linear(dy, linear(dx, v00, v01), linear(dx, v10, v11));
        }

        public function tick(e:Event) {
            this.graphics.clear();
            
            this.graphics.lineStyle(1, border_color);
            for (var my:int = 0; my < map_h; ++my) {
                for (var mx:int = 0; mx < map_w; ++mx) {
                    if (fieldtypes[my][mx] == FieldType.FT_PLAIN) {
                        this.graphics.beginFill(field_color);
                    }
                    else if (fieldtypes[my][mx] == FieldType.FT_OBSTACLE) {
                        this.graphics.beginFill(obstacle_color);
                    }
                    else if (fieldtypes[my][mx] == FieldType.FT_TARGET) {
                        this.graphics.beginFill(target_color);
                    }

                    this.graphics.drawRect(mx * field_size, my * field_size, field_size, field_size);
                    this.graphics.endFill();
                    
                }
            }

            if (path && path.length > 0) {
                var x:int = (path[0].x + 0.5) * field_size;
                var y:int = (path[0].y + 0.5) * field_size;

                this.graphics.lineStyle(1, path_color);
                this.graphics.moveTo(x, y);
                for (var i:int = 1; i < path.length; ++i) {
                    x = (path[i].x + 0.5) * field_size;
                    y = (path[i].y + 0.5) * field_size;
                    
                    this.graphics.lineTo(x, y);
                    
                }
            }
        }
    }
}