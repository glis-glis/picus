# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

(import ./picus) 
(import spork/argparse)

(defn main [& args]
  (def res
	(argparse/argparse "Command-line spaced repetion program"
					   :default {:kind :option
								 :help "Picus-File"}
					   "morse" {:kind :option
								:short "m"
								:help "Create morse-learning Picus-File with given name"}
					   "10x10" {:kind :flag
								:help "Create 10x10 Picus-File 10x10.json"}
					   "20x20" {:kind :flag
								:help "Create 20x20 (without 10x10 part) Picus-File 20x20.json"}
					   "teach" {:kind :option
								:short "t"
								:help "Teach untrainted entries in unit"}))
  (unless res
	(os/exit 1))

  (cond
	(res "morse") (picus/write (picus/make-morse) (res "morse"))
	(res "10x10") (picus/write  (picus/make-axb) "10x10.json")
	(res "20x20") (picus/write (picus/make-axb 2 20 11 20) "20x20.json")
	(res :default) (let [entries (picus/read (res :default))]
	  (if (res "teach")
		(picus/teach entries (res "teach"))
		(picus/quiz entries (picus/make-pool entries)))
	  (print (os/strftime "%Y-%m-%d, %H:%M" (picus/next entries)))
	  (picus/write entries (res :default)))
	(print "Picus-File needed without other arguments!")))
