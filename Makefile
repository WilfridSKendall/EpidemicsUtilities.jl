runtests: .test.stamp

.test.stamp: $(wildcard src/*.jl) $(wildcard test/*.jl)
	julia test/runtests.jl
	@touch .test.stamp


