(progn (delay-emit nil)
(osql "select w[0], w[1], round(w[3 + compare(0, w[0])] - start)
from vector of number v, vector of number w, number start
where v in lread({'data/ultralite1.out', 'data/ultralite2.out'}, 1)
and start = rnow()
and w = tslr(v);"))

;; newsp

(progn (delay-emit nil)
(osql "select ev[0], ev[1], round(ew[3 + compare(0, ew[0])] - ev[4])
from vector of number ev, vector of number ew
where ev in extract(newsp(streamof(select {v[0], v[1], 0, 0, start}
from vector of number v, number start
where v in lread({'data/ultralite1.out', 'data/ultralite2.out'}, 1)
and start = rnow())))
and ew = tslr(ev);"))

;; split - merge

(progn (delay-emit nil)
(osql "select ev[0], ev[1], round(ew[3 + compare(0, ew[0])] - ev[4])
from vector of number ev, vector of number ew
where ev in mergestreams(splitstream(streamof(select {v[0], v[1], 0, 0, start}
from vector of number v, number start
where v in lread({'data/ultralite1.out', 'data/ultralite2.out'}, 1)
and start = rnow()), 1, #'dhpartition'))
and ew = tslr(ev);"))

;; split - map - merge. heralds removed on top of merge

(progn (delay-emit t)
(osql "select ev[0], ev[1], roundto(ew[3 + compare(0, ew[0])] - ev[4], 1)
from vector of number ev, vector of number ew
where ev in mergestreams(mapstreams(splitstream(streamof(select {v[0], v[1], 0, 0, start}
from vector of number v, number start
where v in lread({'data/ultralite1.out', 'data/ultralite2.out'}, 1)
and start = rnow()), 1, #'dhpartition'), #'id'))
and ew = tslr(ev)
and ew[0] != 4;"))

;; split - map - merge. heralds are removed in mapstreams

(progn (delay-emit t)
(osql "select ev[0], ev[1], roundto(ew[3 + compare(0, ew[0])] - ev[4], 1)
from vector of number ev, vector of number ew
where ev in mergestreams(mapstreams(splitstream(streamof(select {v[0], v[1], 0, 0, start}
from vector of number v, number start
where v in lread({'data/ultralite1.out', 'data/ultralite2.out'}, 1)
and start = rnow()), 1, #'dhpartition'), #'snoheralds'))
and ew = tslr(ev)
and ew[0] != 4;"))

;; two mapstreams. heralds are removed on top of merge

(progn (delay-emit t)
(osql "select ev[0], ev[1], roundto(ew[3 + compare(0, ew[0])] - ev[4], 1)
from vector of number ev, vector of number ew
where ev in mergestreams(mapstreams(mapstreams(splitstream(streamof(select {v[0], v[1], 0, 0, start}
from vector of number v, number start
where v in lread({'data/ultralite1.out', 'data/ultralite2.out'}, 1)
and start = rnow()), 1, #'dhpartition'), #'id'), #'id'))
and ew = tslr(ev)
and ew[0] != 4;")) 

;; two mapstreams. heralds are removed in 2nd mapstreams

(progn (delay-emit t)
(osql "select ev[0], ev[1], roundto(ew[3 + compare(0, ew[0])] - ev[4], 1)
from vector of number ev, vector of number ew
where ev in mergestreams(mapstreams(mapstreams(splitstream(streamof(select {v[0], v[1], 0, 0, start}
from vector of number v, number start
where v in lread({'data/ultralite1.out', 'data/ultralite2.out'}, 1)
and start = rnow()), 1, #'dhpartition'), #'id'), #'snoheralds'))
and ew = tslr(ev)
and ew[0] != 4;"))

;; two mapstreams. heralds are removed in 1st mapstreams.

(progn (delay-emit t)
(osql "select ev[0], ev[1], roundto(ew[3 + compare(0, ew[0])] - ev[4], 1)
from vector of number ev, vector of number ew
where ev in mergestreams(mapstreams(mapstreams(splitstream(streamof(select {v[0], v[1], 0, 0, start}
from vector of number v, number start
where v in lread({'data/ultralite1.out', 'data/ultralite2.out'}, 1)
and start = rnow()), 1, #'dhpartition'), #'snoheralds'), #'id'))
and ew = tslr(ev)
and ew[0] != 4;"))
