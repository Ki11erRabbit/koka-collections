

module queue

pub import hash

fun unwrap(x : maybe<a>) : <exn> a {
    match x {
        Nothing -> throw("unwrap called on Nothing")
        Just(x) -> x
    }
}




pub type heaptype
    MinHeap
    MaxHeap

pub fun show(ht : heaptype) : string {
    match ht {
        MinHeap -> "MinHeap"
        MaxHeap -> "MaxHeap"
    }
}

pub struct binaryheap<a>
    min_max : heaptype
    data : list<a>
    position : hashmap<a, int>
    cmp : (a, a) -> order

pub fun show(map : hashmap<int,int>) : string {
    map.list().map() fn (lst) {
        lst.map() fn (pair) {
            "(" ++ (pair.fst).show() ++ ", " ++ (pair.snd).show() ++ ")"
        }.join(", ")
    }.join(", ")
}

pub fun show(heap : binaryheap<int>) : string {
    "binaryheap(" ++ show(heap.min_max) ++ ", " ++ show(heap.heap) ++ ", " ++ show(heap.position) ++ ")"
}

pub fun binaryheap(min_max : heaptype, cmp : (a, a) -> order) : binaryheap<a> {
    Binaryheap(min_max, [], hashmap(cmp), cmp)
}

pub fun make-binaryheap<a>(min_max: heaptype, values : list<a>, cmp : (a, a) -> order) : <hash/hash<a>,div, exn|_e> binaryheap<a> {
    val heap = binaryheap(min_max, cmp)
    values.foldl(binaryheap(min_max, cmp), qinsert)
}

pub fun qinsert<a>(binaryheap : binaryheap<a>, value : a) : <hash/hash<a>,div,exn|_e> binaryheap<a> {
    val heap = binaryheap.heap ++ [value]
    val position = binaryheap.position.insert(value, heap.length())
    binaryheap(heap, position).bubble-up(value)
}


pub fun bubble-up<a>(heap : binaryheap<a>, value : a) : <hash/hash<a>,div,exn|_e> binaryheap<a> {
    val node_position = heap.position.get(value)
    var binaryheap := heap
    val cmp = heap.cmp
    match node_position {
        Nothing -> throw("value not found in heap when it should be in heap")
        Just(r_pos : int) -> {
            var pos :int := r_pos
            while { (pos != 0) || (pos / 2 != 0) } {
                match cmp(binaryheap.data[pos - 1].unwrap(), binaryheap.data[(pos / 2) - 1].unwrap()) {
                    Lt -> match binaryheap.min_max {
                        MinHeap -> {
                            val temp_pos = binaryheap.position.get(binaryheap.data[pos - 1].unwrap()).unwrap()
                            binaryheap := binaryheap(position = binaryheap.position.insert(binaryheap.data[pos - 1].unwrap(), pos / 2).insert(binaryheap.data[(pos / 2) - 1].unwrap(), temp_pos))
                            val temp_node = binaryheap.data[pos - 1].unwrap()
                            binaryheap := binaryheap(data = binaryheap.data.take(pos - 1) ++ Cons(binaryheap.data[(pos / 2) - 1].unwrap(), binaryheap.data.drop(pos + 1 - 1)))
                            binaryheap := binaryheap(data = binaryheap.data.take((pos / 2) - 1) ++ Cons(temp_node, binaryheap.data.drop((pos / 2) + 1 - 1)))
                            pos := pos / 2
                        }
                        MaxHeap -> ()
                    }
                    Gt -> match binaryheap.min_max {
                        MaxHeap -> {
                            val temp_pos = binaryheap.position.get(binaryheap.data[pos - 1].unwrap()).unwrap()
                            binaryheap := binaryheap(position = binaryheap.position.insert(binaryheap.data[pos - 1].unwrap(), pos / 2).insert(binaryheap.data[(pos / 2) - 1].unwrap(), temp_pos))
                            val temp_node = binaryheap.data[pos - 1].unwrap()
                            binaryheap := binaryheap(data = binaryheap.data.take(pos - 1) ++ Cons(binaryheap.data[(pos / 2) - 1].unwrap(), binaryheap.data.drop(pos + 1 - 1)))
                            binaryheap := binaryheap(data = binaryheap.data.take((pos / 2) - 1) ++ Cons(temp_node, binaryheap.data.drop((pos / 2) + 1 - 1)))
                            pos := pos / 2
                        }
                        MinHeap -> ()
                    }
                    Eq -> ()
                }
            }
            binaryheap
        }
    }
}




