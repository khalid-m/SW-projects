3;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) Silvia Syefanova
;;;
;;; Description: SPARQL OPTIONAL regression test
;;; =============================================================


(osql "< 'BSBM_Optional.osql';")

(checkequal "OPTIONAL queries from BSBM "
	    ((sparql "LOAD('data/berlin1.ttl',true)") nil))

(checkequal "BSBM Q2: four OPTIONAL, one-after-each-other "
	    ((sorttuples (osql "sparql(:q2);")) (sorttuples '((#(#[USTR "maxillae"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil)) 
							      (#(#[USTR "bootstraps vies"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil)) 
							      (#(#[USTR "espanoles"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil))
	                                                      (#(#[USTR "dogsbodies pouffs sadisms"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil))
                                                              (#(#[USTR "dyspeptics indubitably redrafted"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil))
                                                              (#(#[USTR "fumaroles"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil))
                                                              (#(#[USTR "gadgeteers glaceed noninductive"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil))
                                                              (#(#[USTR "hellholes"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil))
                                                              (#(#[USTR "homerooms mountebanks"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil))
                                                              (#(#[USTR "kirigami"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil))
                                                              (#(#[USTR "misrepresentations convection matrilinearly"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil))
                                                              (#(#[USTR "orthoepist brats searing"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil))
                                                              (#(#[USTR "outvoted"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil))
                                                              (#(#[USTR "repossession energize"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil))
                                                              (#(#[USTR "tops"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil))
                                                              (#(#[USTR "valerian"] nil #[USTR "exhalation paraguayan alcaldes foulings"] nil))  ))))
(checkequal "BSBM Q3: one OPTIONAL "
	    ((sorttuples (osql "sparql(:q3m);")) (sorttuples '((#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromProducer1/Product1"] #[USTR "manner gatemen"] #[USTR "manner gatemen"]))))))


(quote (checkequal "BSBM Q8: four OPTIONAL, one-after-each-other "
	    ((sorttuples (osql "sparql(:q8);")) (sorttuples '((#(#[USTR "compartmented appearers undercurrents gunnel hopes launchings"] 2008-03-04 00:00:00 #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] nil 3 6 nil)))))))


(checkequal "More BSBM Q8: four OPTIONAL, one-after-each-other "
	    ((sorttuples (osql "sparql(:q8_0);")) 
	     (sorttuples '((#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] 7 7 10 1))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] nil 3 6 nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] nil 10 10 nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] nil 2 nil nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] nil 8 1 nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] nil 10 7 6))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] 2 nil nil 8))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] 1  8 nil nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] 10 10 10 nil ))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] 1 8 4 nil))))))




(checkequal "BSBM Q7: two OPTIONAL: 1 OPT + 1 OPT having 2 nested OPT "
	    ((sorttuples (osql "sparql(:q7);")) 
	     (sorttuples '((#(#[USTR "manner gatemen"] nil nil nil nil #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Review1"] #[USTR "loftless refractoriness nonhabitual paperer aridness jingliest sportswriters gained efficiently marshals tomogram tambura"] #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] nil 10))
			   (#(#[USTR "manner gatemen"] nil nil nil nil #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Review10"] #[USTR "viced bruising hetero romps polymerically undecided runners libidinal fustic escapements obols sandlots channelizes notational gongs"] #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] 7 7))
			   (#(#[USTR "manner gatemen"] nil nil nil nil #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Review2"] #[USTR "compartmented appearers undercurrents gunnel hopes launchings"] #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] nil 3))
			   (#(#[USTR "manner gatemen"] nil nil nil nil #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Review3"] #[USTR "grimacer spoilt admiringly hyperbolas knouted eulogists"] #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] 2 nil))
			   (#(#[USTR "manner gatemen"] nil nil nil nil #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Review4"] #[USTR "runways tressiest obeyable lapps mooch defamatory whirs stealer pyramided motivates lapidates syllables showily"] #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] 1 8))
			   (#(#[USTR "manner gatemen"] nil nil nil nil #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Review5"] #[USTR "fetters sensuality revalidate elflock bucketful"] #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] nil 10))
			   (#(#[USTR "manner gatemen"] nil nil nil nil #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Review6"] #[USTR "chilblains intertribal balsamic exotism"] #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] nil 2))
			   (#(#[USTR "manner gatemen"] nil nil nil nil #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Review7"] #[USTR "rehinge mitigative defamers naturalist accustoms reclean valiancies pilled bearcats tents demultiplexes skulking publicized"] #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] 10 10))
			   (#(#[USTR "manner gatemen"] nil nil nil nil #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Review8"] #[USTR "reconsolidate clapping enunciators championed nigglingly tongers liquoring reminder podiatrists tussocks reprice renovating chevrolets"] #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] 1 8))
			   (#(#[USTR "manner gatemen"] nil nil nil nil #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Review9"] #[USTR "sharks bannock resuscitative motets"] #[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] nil 8))))))

 
(checkequal "Modified BSBM Q8: two OPTIONAL:rating1 bounded from the 1st OPT, rating2 cab be bounded only if rating1 bounded  "
	    ((sorttuples (osql "sparql(:q81);"))
	     (sorttuples '((#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] 7 7))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil))
			   
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  2  nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  1 8))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  10 10))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  1 8)) ))))

(checkequal "Modified BSBM Q8: Both rating1 and rating2 are NULLs or both are bounded  "
	    ((sorttuples (osql "sparql(:q82);"))
	     (sorttuples '((#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] 7 7))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] 2 nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  1 8))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  10 10))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  1 8)) ))))



(checkequal "Modified BSBM Q8: four nested OPTIONALs  "
	    ((sorttuples (osql "sparql(:q83);"))
	     (sorttuples '((#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"] 7 7 10 1))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil nil nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil nil nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil nil nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil nil nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  nil  nil nil nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  2  nil nil nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  1  8 nil nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  10 10 10 nil))
			   (#(#[URI "http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/dataFromRatingSite1/Reviewer1"] #[USTR "Ruggiero-Delane"]  1 8 4 nil))))))

	    

	     
 