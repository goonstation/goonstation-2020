proc
	__printable_name(var/path as text)
		var/previous = 1
		var/result = ""
		while (previous > 0)
			var/pos = findtext(path, "_", previous)
			if (pos > 0)
				if (previous > 1)
					result += " "
				result += uppertext(copytext(path, previous, previous + 1))
				result += copytext(path, previous + 1, pos)
				previous = pos + 1
			else
				if (previous > 1)
					result += " "
				result += uppertext(copytext(path, previous, previous + 1))
				result += copytext(path, previous + 1)
				previous = pos
		return result

TestScenario
	var
		name

	proc
		before()

		after()

TestExecution
	var/TestScenario/scenario
	var/test_case
	var/run    = 0
	var/failed = 0

	New(var/TestScenario/scenario, var/path as text)
		src.scenario  = scenario
		src.test_case = __printable_name(copytext(path, findtext(path, "/proc/") + 6))

	proc
		fail()
			failed = 1

		start()
			run = 1

TestPlan
	var/list/scenarios = new()

	New()
		var/list/S = typesof(/TestScenario)
		S -= /TestScenario
		for (var/path in S)
			for (var/path2 in S)
				if (path != path2 && findtext("[path2]", "[path]"))
					S -= path
					break
		for (var/path in S)
			var/TestScenario/T = new path()
			var/list/cases = new()
			for (var/c in typesof("[path]/proc"))
				if (findtext(__printable_name(copytext("[c]", findtext("[c]", "/proc/") + 6)), "Test"))
					cases += new/TestExecution(T, "[c]")
			if (length(cases) > 0)
				src.scenarios[T] = cases

client
	verb
		Test()
			var/TestPlan/P = new()
			var/Reporter/R = new/Reporter/WorldLog()
			R.results(P)

TestScenario/T
	name = "T"

	proc
		test_a()

TestScenario/T/S
	name = "T - S"

	proc
		test_b()

		test_c()

TestScenario/S
	name = "S"

TestScenario/T/H
	name = "T - H"

	proc
		test_d()

		test_e()