package {

    import flash.utils.*;

    public class Scent {

        var map_w:int;
        var map_h:int;
        var source:Vector.<Vector.<Vector2i>>;
        var relaxed:Vector.<Vector.<Boolean>>;
        public var scent:Vector.<Vector.<Number>>;
        var fieldtypes:Vector.<Vector.<int>>;

        var H:BinaryHeap;
        var idgen:int;
        var list:Array = [];

        public function Scent(map_w:int, map_h:int, fieldtypes:Vector.<Vector.<int>>) {
            this.map_w = map_w;
            this.map_h = map_h;
            this.fieldtypes = fieldtypes;
        }

        public function cmp(lhs:hentry, rhs:hentry):Number {
            if (lhs.distance != rhs.distance) {
                return lhs.distance - rhs.distance;
            }

            return rhs.id - lhs.id;
        }

        public function init():void {
            source = new Vector.<Vector.<Vector2i>>();
            relaxed = new Vector.<Vector.<Boolean>>();
            scent = new Vector.<Vector.<Number>>();

            H = new BinaryHeap(cmp);
            

            for (var my:int = 0; my < map_h; ++my) {
                source.push(new Vector.<Vector2i>());
                relaxed.push(new Vector.<Boolean>());
                scent.push(new Vector.<Number>());
                for (var mx:int = 0; mx < map_w; ++mx) {
                    source[my].push(new Vector2i(-1, -1));
                    relaxed[my].push(false);
                    scent[my].push(1000);

                    if (fieldtypes[my][mx] != FieldType.FT_TARGET) {
                        continue;
                    }

                    var he:hentry = new hentry();
                    he.distance = 0;
                    he.offset = 0;
                    he.pt = new Vector2i(mx, my);
                    H.put(he);


                   // list.push(he);
                   // list.sort(cmp);

                    scent[my][mx] = 0;
                    source[my][mx] = he.pt;

                }
            }
        }

        public function loop():void {
            while (!H.isEmpty()) {
                var v:Array = [];
                var h:hentry = H.pop() as hentry;
//                h = list.shift();

                if (relaxed[h.pt.y][h.pt.x]) {
                    continue;
                }

                relaxed[h.pt.y][h.pt.x] = true;

                for (var dy:int = -1; dy <= 1; ++dy) {
                    for (var dx:int = -1; dx <= 1; ++dx) {
                        relax(h, dx, dy);
                    }
                }
            }
        }

        public function relax(h:hentry, dx:int, dy:int):void {
            var here:Vector2i = h.pt;
            var there:Vector2i = new Vector2i(h.pt.x + dx, h.pt.y + dy);
            
            if ( ( (dx != 0 && dy != 0) || (dx == 0 && dy == 0) ) ||
                there.x < 0 || there.x >= map_w ||
                there.y < 0 || there.y >= map_h ||
                relaxed[there.y][there.x] ||
                FieldType.FT_OBSTACLE == fieldtypes[there.y][there.x]) {
                return;
            }

            var s:Vector2i = source[here.y][here.x];

            var hh:hentry = new hentry();
            hh.pt = there;
            hh.offset = h.offset;
            if (!visible(s, there)) {
                hh.offset += here.sub(s).len();
                s = here;
            }
            hh.distance = hh.offset + there.sub(s).len();

            if (hh.distance > scent[there.y][there.x]) {
                return;
            }

            hh.id = ++idgen;
            H.put(hh);
//                    list.push(hh);
//                    list.sort(cmp);

            scent[there.y][there.x] = hh.distance;
            source[there.y][there.x] = s;
            
        }
        

        public function visible(s:Vector2i, p:Vector2i):Boolean {
            var dirs:Array = [ new Vector2i(0, -1),
                new Vector2i(1, -1),
                new Vector2i(1, 0),
                new Vector2i(1, 1),
                new Vector2i(0, 1),
                new Vector2i(-1, 1),
                new Vector2i(-1, 0),
                new Vector2i(-1, -1),
                new Vector2i(0, -1) ];


            var vec:Vector2i = s.sub(p);

            for (var i:int = 0; i < 8; ++i) {
                if (vec.cross(dirs[i]) == 0 && vec.dot(dirs[i]) > 0) {
                    return vis_check(s, p, dirs[i]);
                }
            }

            for (var i:int = 0; i < 8; ++i) {
                if ( dirs[i + 1].cross(vec) < 0 && vec.cross(dirs[i]) < 0) {
                    return vis_check(s, p, dirs[i]) && vis_check(s, p, dirs[i + 1]);
                }
            }

            return false;
        }

        public function vis_check(s:Vector2i, p:Vector2i, dir:Vector2i):Boolean {
            var q:Vector2i = p.add(dir);
            var ret:Boolean = (q.equal(s) || source[q.y][q.x].equal(s));
            
            return ret;
        }
    }
}



class hentry {
    var distance:Number;
    var offset:Number;
    var id:int;
    var pt:Vector2i;

}