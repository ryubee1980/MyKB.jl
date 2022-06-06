using MyKB
using Test

@testset "MyKB.jl" begin
    # Write your tests here.
    fn="rdftest.xvg"
    s=0.052
    @test_nowarn gr=MyKB.in_RDF(fn)
    gr=MyKB.in_RDF(fn)
    @test_nowarn MyKB.hr(gr,shift=s)
    @test_nowarn MyKB.comp_GR(fn,shift=s)
    @test_nowarn MyKB.plot_GR(fn,shift=s)
    @test_nowarn MyKB.plot_RGR(fn,shift=s)
    @test_nowarn MyKB.fit_GR(fn,0.8,1.4,shift=s)
    @test_nowarn MyKB.fit_RGR(fn,1/1.4,1/0.8,shift=s)
    @test_nowarn MyKB.eval_KB(fn,0.8,1.4,shift=s)
    @test_nowarn MyKB.eval_KB2(fn,1/1.4,1/0.8,shift=s)
    @test_nowarn MyKB.plot_GR_fit(fn,0.8,1.4,shift=s)
    @test_nowarn MyKB.plot_RGR_fit(fn,1/1.4,1/0.8,shift=s)

end
