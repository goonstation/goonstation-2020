Reporter
	proc
		info(var/string as text, var/TestExecution/T)

		failure(var/TestExecution/T)

		success(var/TestExecution/T)

		results(var/TestPlan/P)

Reporter/WorldLog
	results(var/TestPlan/P)
		for (var/TestScenario/T in P.scenarios)
			world.log << "== Scenario : [T.name] =="
			for (var/TestExecution/E in P.scenarios[T])
				world.log << "\t[E.test_case] :: [E.run ? (E.failed ? "FAIL" : "Passed") : "Did not Run"]"