using MyKB
using Test

@testset "MyKB.jl" begin
    # Write your tests here.
    fn="rdftest.xvg"
    s=0.052
    gr=MyKB.in_RDF(fn)
    MyKB.hr(gr,shift=s)
    MyKB.comp_GR(fn,shift=s)
    MyKB.plot_GR(fn,shift=s)
    MyKB.fit_GR(fn,0.8,1.4,shift=s)
    MyKB.eval_KB(fn,0.8,1.4,shift=s)
    MyKB.plot_GR_fit(fn,0.8,1.4,shift=s)

end
