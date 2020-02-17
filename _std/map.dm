/proc/get_area(atom/A)
	if (!istype(A))
		return
	for(A, A && !isarea(A), A=A.loc);
	return A
