(defmacro checkit (text form1 form2)
  (list 'checkequal text 
	(list (list 'sorttuples (if (stringp form1)
				    (list 'osql form1)
				  form1))
	      (list 'sorttuples (if (stringp form2)
				    (list 'osql form2)
				  form2)))))

(checkit "Q1 Amos" "q1_amos('Water Boiler');" '(("France") ("Sweden") 
						("Sweden")))

(checkit "Q1 SparQL" "q1_sparql('Water Boiler');" "q1_amos('Water Boiler');")

(checkit "Q1 SparQL 2" "q1_sparql2('Water Boiler');" 
	 "q1_amos('Water Boiler');")

(checkit "Q1 Amos" "q1_amos('Air Freshener');" '(("Atlantis")))

(checkit "Q1 SparQL" "q1_sparql('Air Freshener');" "q1_amos('Air Freshener');")

(checkit "Q1 SparQL 2" "q1_sparql2('Air Freshener');" 
	 "q1_amos('Air Freshener');")


(checkit "Q2 Amos" "q2_amos('Europe');" 
	 '(("AquaSens Technologies" "WS1ABC") 
	   ("AquaSens Technologies" "WS3ABC") 
	   ("AquaSens Technologies, Korea Division" "WS2ABC")))

(checkit "Q2 SparQL" "q2_sparql('Europe');" "q2_amos('Europe');")

(checkit "Q2 Amos" "q2_amos('Pangea');" '(("Zephyr Ltd" "AS1ABC")))

(checkit "Q2 SparQL" "q2_sparql('Pangea');" "q2_amos('Pangea');")


(checkit "Q3 SparQL" 
	 "select c,o from charstring c, object o, uri u 
          where u=resource(o) and (c,u) in q3_sparql('Water Boiler');"
	 "q3_amos('Water Boiler');")

(checkit "Q3 SparQL" 
	 "select c,o from charstring c, object o, uri u 
          where u=resource(o) and (c,u) in q3_sparql('Air Freshener');"
	 "q3_amos('Air Freshener');")


;;; relational tests

(unless (getenv "NOREL")
  (checkit "QQ1 Amos" "qq1_amos('Water Boiler');" '(("France") ("Sweden") 
						    ("Sweden")))
  
  (checkit "QQ1 SparQL" "qq1_sparql('Water Boiler');" 
	   "qq1_amos('Water Boiler');")
  
  (checkit "QQ1 Amos 2" "qq1_amos2('Water Boiler');" '(("France") ("Sweden") 
						       ("Sweden")))
  
  (checkit "QQ1 SparQL 2" "qq1_sparql2('Water Boiler');" 
	   "qq1_amos2('Water Boiler');")
  
  (checkit "QQ1 Amos 3" "qq1_amos3('Water Boiler');" '(("France") ("Sweden") 
						       ("Sweden")))
  
  (checkit "QQ1 SparQL 3" "qq1_sparql3('Water Boiler');" 
	   "qq1_amos3('Water Boiler');")
  
  
  (checkit "QQ2 Amos" "qq2_amos('Europe');" 
	   '(("Water Sensor" "AquaSens Technologies" "1.1e" 1.0 0.1) 
	     ("Water Sensor" "AquaSens Technologies" "1.1e" 1.0 0.1) 
	     ("Water Sensor" "AquaSens Technologies, Korea Division" "0.2b" 
	      1.0 0.5)))
  
  (checkit "QQ2 SparQL" "qq2_sparql('Europe');" "qq2_amos('Europe');")
  
  (checkit "QQ2 Amos 2" "qq2_amos2('Europe');" 
	   '(("Water Sensor" "AquaSens Technologies" "1.1e" 1.0 0.5) 
	     ("Water Sensor" "AquaSens Technologies" "1.1e" 1.0 0.5) 
	     ("Water Sensor" "AquaSens Technologies, Korea Division" "0.2b" 
	      1.0 0.1)))
  
  (checkit "QQ2 SparQL 2" "qq2_sparql2('Europe');" "qq2_amos2('Europe');"))

(quit)
