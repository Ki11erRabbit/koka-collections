

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
    if pos == 0 || pos / 2 == 0 then {
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

pub fun top<a>(heap : binaryheap<a>) : <exn> a {
    heap.data[0].unwrap()
}

pub fun pop<a>(heap: binaryheap<a>) : <pure,hash/hash<a>|_e> binaryheap<a> {
    val ret_node = heap.data[0].unwrap()
    var binaryheap := heap(position = heap.position.remove(ret_node), data = heap.data.drop(1))

    if heap.position.length() >= 1 then {
        val end_node = heap.data[heap.data.length() - 1].unwrap()
        binaryheap := binaryheap(data = heap.data.take(heap.data.length() - 1))
        binaryheap := binaryheap(position = binaryheap.position.insert(end_node, 1), data = Cons(end_node, binaryheap.data))
        binaryheap := binaryheap.sift-down(1)
        binaryheap
    }
    else {
        val end_node = heap.data[heap.data.length() - 1].unwrap()
        binaryheap := binaryheap(data = heap.data.take(heap.data.length() - 1))
        binaryheap := binaryheap(position = binaryheap.position.insert(end_node, 1), data = Cons(end_node, binaryheap.data))
        binaryheap
    }
}


fun sift-down-for-loop<a>(heap: binaryheap<a>, pos: int, i : int, lowest : maybe<a>) : <exn|_e> maybe<a> {
    if i == pos * 2 + 2 then {
        lowest
    }
    elif i > heap.position.length() then {
        lowest
    }
    else {
        match lowest {
            Nothing -> sift-down-for-loop(heap, pos, i + 1, heap.data[i - 1])
            Just(x) -> match (heap.cmp)(x, heap.data[i - 1].unwrap()) {
                Gt -> match heap.min_max {
                    MinHeap -> sift-down-for-loop(heap, pos, i + 1, heap.data[i - 1])
                    MaxHeap -> sift-down-for-loop(heap, pos, i + 1, lowest)
                }
                Lt -> match heap.min_max {
                    MinHeap -> sift-down-for-loop(heap, pos, i + 1, lowest)
                    MaxHeap -> sift-down-for-loop(heap, pos, i + 1, heap.data[i - 1])
                }
                Eq -> sift-down-for-loop(heap, pos, i + 1, lowest)
            }
        }
    }
}


fun sift-down<a>(heap : binaryheap<a>, pos : int) : <div, exn, hash/hash<a>|_e> binaryheap<a> {

    val lowest = sift-down-for-loop(heap, pos, pos * 2 + 1, Nothing)

    match lowest {
        Nothing -> heap
        Just(low) -> {
            match (heap.cmp)(low, heap.data[pos - 1].unwrap()) {
                Gt -> match heap.min_max {
                    MinHeap -> {
                        val node = heap.data[pos - 1].unwrap()
                        val low_pos = heap.position.get(low).unwrap()
                        val temp_pos = heap.position.get(node).unwrap()
                        val binaryheap = heap(position = heap.position.insert(node, heap.position.get(low).unwrap()).insert(low, temp_pos))
                        val binaryheap = binaryheap(data = binaryheap.data.take(pos - 1) ++ Cons(low, binaryheap.data.drop(pos + 1 - 1)))
                        val binaryheap = binaryheap(data = binaryheap.data.take(low_pos - 1) ++ Cons(node, binaryheap.data.drop(low_pos + 1 - 1)))
                        binaryheap.sift-down(binaryheap.position.get(node).unwrap())
                    }
                    MaxHeap -> heap
                }
                Lt -> match heap.min_max {
                    MaxHeap -> {
                        val node = heap.data[pos - 1].unwrap()
                        val low_pos = heap.position.get(low).unwrap()
                        val temp_pos = heap.position.get(node).unwrap()
                        val binaryheap = heap(position = heap.position.insert(node, heap.position.get(low).unwrap()).insert(low, temp_pos))
                        val binaryheap = binaryheap(data = binaryheap.data.take(pos - 1) ++ Cons(low, binaryheap.data.drop(pos + 1 - 1)))
                        val binaryheap = binaryheap(data = binaryheap.data.take(low_pos - 1) ++ Cons(node, binaryheap.data.drop(low_pos + 1 - 1)))
                        binaryheap.sift-down(binaryheap.position.get(node).unwrap())
                    }
                    MinHeap -> heap
                }
                Eq -> heap
            }
        }
    }
}


pub fun list<a>(heap : binaryheap<a>) : list<a> {
    heap.data
}


