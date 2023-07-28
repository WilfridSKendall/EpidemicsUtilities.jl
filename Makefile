test: .test.stamp
	julia test/runtests.jl
	@touch .test.stamp

.test.stamp: $(wildcard src/*.jl) $(wildcard test/*.jl)
