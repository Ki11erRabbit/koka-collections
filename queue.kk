

module queue

pub import hash

fun unwrap(x : maybe<a>) : <exn> a {
    match x {
        Nothing -> throw("unwrap called on Nothing")
        Just(x) -> x
    }
}

fun expect(x : maybe<a>, msg : string) : <exn> a {
    match x {
        Nothing -> throw(msg)
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

/*pub fun show(map : hashmap<int,int>) : string {
    map.list().map() fn (lst : maybe<list<hash/pair<int,int>>>) {
        lst.map() fn (pair ) {
            "(" ++ (pair.fst).show() ++ ", " ++ (pair.snd).show() ++ ")"
        }.join(", ")
    }.join(", ")
}*/

/*pub fun show(heap : binaryheap<int>) : string {
    "binaryheap(" ++ show(heap.min_max) ++ ", " ++ show(heap.data) ++ ", " ++ show(heap.position) ++ ")"
}*/

pub fun binaryheap(min_max : heaptype, cmp : (a, a) -> order) : binaryheap<a> {
    Binaryheap(min_max, [], hashmap(cmp), cmp)
}


/*
    Weird quirk is that it will fail if you try to insert a list in these conditions:
    1. MinHeap and the list is not sorted in descending order
    2. MaxHeap and the list is not sorted in ascending order
*/
pub fun make-binaryheap<a>(min_max: heaptype, values : list<a>, cmp : (a, a) -> order) : <hash/hash<a>,div, exn|_e> binaryheap<a> {
    val heap = binaryheap(min_max, cmp)
    values.foldl(binaryheap(min_max, cmp), qinsert)
}

pub fun qinsert<a>(binaryheap : binaryheap<a>, value : a) : <hash/hash<a>,div,exn|_e> binaryheap<a> {
    val heap = binaryheap.data ++ [value]
    val position = binaryheap.position.insert(value, heap.length())
    Binaryheap(binaryheap.min_max, heap, position, binaryheap.cmp).bubble-up(value)
}


pub fun bubble-up<a>(heap : binaryheap<a>, value : a) : <hash/hash<a>,div,exn|_e> binaryheap<a> {
    val node_position = heap.position.get(value)
    val cmp = heap.cmp
    match node_position {
        Nothing -> throw("value not found in heap when it should be in heap")
        Just(pos : int) -> {
            bubble-up-loop(heap, value, pos)
        }
    }
}

fun bubble-up-loop<a>(heap : binaryheap<a>, value : a, pos : int ) : <exn,div,hash/hash<a>|e> binaryheap<a> {
    println("pos: " ++ pos.show())
    if pos == 0 || pos / 2 == 0 {
        heap
    }
    else {
        match (heap.cmp)(heap.data[pos - 1].expect("comparison one is bad"), heap.data[(pos / 2) - 1].expect("comparison two is bad")) {
            Lt -> match heap.min_max {
                MinHeap -> {
                    val binaryheap = heap
                    val binaryheap = binaryheap(position = binaryheap.position.insert(value, pos / 2).insert(binaryheap.data[(pos / 2) - 1].unwrap(), pos))
                    
                    val temp_node = binaryheap.data[pos - 1].unwrap()
                    
                    val binaryheap = binaryheap(data = binaryheap.data.take(pos - 1) ++ Cons(binaryheap.data[(pos / 2) - 1].unwrap(), binaryheap.data.drop(pos + 1 - 1)))
                    val binaryheap = binaryheap(data = binaryheap.data.take((pos / 2) - 1) ++ Cons(temp_node, binaryheap.data.drop((pos / 2) + 1 - 1)))
                    
                    bubble-up-loop(binaryheap, value, pos / 2)
                }
                MaxHeap -> heap
            }
            Gt -> match heap.min_max {
                MaxHeap -> {
                    val binaryheap = heap
                    val binaryheap = binaryheap(position = binaryheap.position.insert(value, pos / 2).insert(binaryheap.data[(pos / 2) - 1].unwrap(), pos))
                    
                    val temp_node = binaryheap.data[pos - 1].unwrap()
                    
                    val binaryheap = binaryheap(data = binaryheap.data.take(pos - 1) ++ Cons(binaryheap.data[(pos / 2) - 1].unwrap(), binaryheap.data.drop(pos + 1 - 1)))
                    val binaryheap = binaryheap(data = binaryheap.data.take((pos / 2) - 1) ++ Cons(temp_node, binaryheap.data.drop((pos / 2) + 1 - 1)))
                    
                    bubble-up-loop(binaryheap, value, pos / 2)
                }
                MinHeap -> heap
            }
            Eq -> heap
        }
    }
}


pub fun list<a>(heap : binaryheap<a>) : list<a> {
    heap.data
}


