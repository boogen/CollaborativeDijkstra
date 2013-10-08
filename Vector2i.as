package {
    public class Vector2i {
        public var x:int;
        public var y:int;
        
        public function Vector2i(x:int = 0, y:int = 0) {
            this.x = x;
            this.y = y;
        }

        public function add(v:Vector2i):Vector2i {
            return new Vector2i(x + v.x, y + v.y);
        }

        public function sub(v:Vector2i):Vector2i {
            return new Vector2i(x - v.x, y - v.y);
        }

        public function dot(v:Vector2i):Number {
            return x * v.x + y * v.y;
        }

        public function cross(v:Vector2i):Number {
            return x * v.y - y * v.x;
        }


        public function equal(v:Vector2i):Boolean {
            return x == v.x && y == v.y;
        }

        public function len():Number {
            return Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
        }
    }
}