# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

(import spork/math)
(import spork/randgen)
(import spork/json)

(def minute 60)
(def hour (* 60 minute))
(def day (* 24 hour))
(def dt_min (* 6 hour))
(def growth 1.5)

(defn swap [ar i j]
  (def tmp (ar i))
  (put ar i (ar j))
  (put ar j tmp))

(defn swap-end [ar i]
  (swap ar i (- (length ar) 1)))

(defn axb-unit [entries a bmin bmax]
  (def key (string a "x"))
  (put entries key @[])
  (def unit (entries key))

  (for b bmin (inc bmax)
	(array/push unit @{:Q (string a "x" b " =") :A (string (* a b))})))

(defn make-axb [&opt amin amax bmin bmax]
  (default amin 1)
  (default amax 10)
  (default bmin 1)
  (default bmax 10)
  (def entries @{})
  (for a amin (inc amax)
	(axb-unit entries a bmin bmax))
  entries)

(defn make-morse []
  (def entries @{})
  (put entries :1 @[@{:Q "E" :A "."} @{:Q "T" :A "-"}])
  (put entries :2 @[@{:Q "I" :A ".."} @{:Q "A" :A ".-"} @{:Q "N" :A "-."} @{:Q "M" :A "--"}])
  (put entries :3 @[@{:Q "S" :A "..."} @{:Q "U" :A "..-"} @{:Q "R" :A ".-."} @{:Q "W" :A ".--"}
					@{:Q "D" :A "-.."} @{:Q ";" :A "-.-"} @{:Q "G" :A "--."} @{:Q "O" :A "---"}])
  (put entries :4a @[@{:Q "H" :A "...."} @{:Q "V" :A "...-"} @{:Q "F" :A "..-."} 
					@{:Q "L" :A ".-.."} @{:Q "P" :A ".--."} @{:Q "J" :A ".---"}])
  (put entries :4b @[@{:Q "B" :A "-..."} @{:Q "X" :A "-..-"} @{:Q "C" :A "-.-."} 
					@{:Q "Y" :A "-.--"} @{:Q "Z" :A "--.."} @{:Q "Q" :A "--.-"}])
  (put entries :5 @[@{:Q "1" :A ".----"} @{:Q "2" :A "..---"} @{:Q "3" :A "...--"} @{:Q "4" :A "....-"} @{:Q "4" :A "....."}
					@{:Q "6" :A "-...."} @{:Q "7" :A "--..."} @{:Q "8" :A "---.."} @{:Q "9" :A "----."} @{:Q "0" :A "-----"}])
  entries)

(defn ask [entry]
  (string/trim(getline (string (entry :Q) " "))))

(defn ask-loop [entry]
  (var count 0)
  (while (not= (ask entry) (entry :A))
	(++ count)
	(print ":-( " (entry :A) "!"))
  count)

(defn teach [entries unitName]

  (def key (keyword unitName))
  (def unit
	(if (entries key) # may be key or string
	  (entries key)
	  (entries (string key))))

  (def N (- (length unit) (count |($ :next) unit)))
  (print (string unitName ": " N))
  (unless (= N 0)
	# In order with answer
	(print "")
	(loop [entry :in unit :unless (entry :next)]
	  (print (entry :Q) " " (entry :A))
	  (ask-loop entry))
	(print)

	# In order without answer
	(loop [entry :in unit :unless (entry :next)]
	  (ask-loop entry))
	(print)

	# Out of order without answer
	(def iis (math/shuffle-in-place (range (length unit))))
	(loop [i :in iis :let [entry (unit i)] :unless (entry :next)]
	  (ask-loop entry)
	  # Learned -> put into pool
	  (set (entry :dt) dt_min)
	  (set (entry :next) (+ (os/time) (entry :dt))))
	(print)
	(print ":-)")))

(defn quiz [entries ids]
  (def now (ids :now))

  (while (not (empty? now))
	(swap-end now (randgen/rand-index now))
	(def id (array/peek now))
	(def entry (get-in entries [(id :key) (id :idx)]))
	(if (= (ask-loop entry) 0)
	  (do
		(set (entry :next) (+ (os/time) (entry :dt)))
		(set (entry :dt) (* growth (entry :dt)))
		(array/pop now))
	  # else
	  (do 
		(set (entry :next) (os/time))
		(set (entry :dt) dt_min)))))

(defn make-pool [entries]
  (def now @[])
  (def later @[])
  (loop [[key unit] :pairs entries
		 i :range [0 (length unit)]
		 :let [next ((unit i) :next)]
		 :when next]
	(def delta (- next (os/time)))
	(cond
	  (<= delta 0) (array/push now {:key key :idx i})
	  (< delta dt_min) (array/push later {:key key :idx i})))
  (sort later (fn [a b]
				(> (get-in entries [(a :key) (a :idx) :next])
				   (get-in entries [(b :key) (b :idx) :next]))))
  {:now now :later later})

(defn next [entries]
  (var t math/int32-max)
  (loop [unit :in entries
		 entry :in unit
		 :when (entry :next)]
	(set t (min t (entry :next))))
  t)

(defn write [entries fileName]
(spit fileName (json/encode entries "\t" "\n")))

(defn read [fileName]
  (json/decode (slurp fileName) true))
