using MyKB
using Test

@testset "MyKB.jl" begin
    # Write your tests here.
    fn="rdftest.xvg"
    
    @test_nowarn gr=MyKB.in_RDF(fn)
    gr=MyKB.in_RDF(fn,ave_range=100)
    @test_nowarn MyKB.hr(gr)
    @test_nowarn MyKB.comp_GR(fn,ave_range=100)
    @test_nowarn MyKB.plot_GR(fn,ave_range=100)
    @test_nowarn MyKB.plot_RGR(fn,ave_range=100)
    @test_nowarn MyKB.fit_GR(fn,0.8,1.4,ave_range=100)
    @test_nowarn MyKB.fit_RGR(fn,1/1.4,1/0.8,ave_range=100)
    @test_nowarn MyKB.eval_KB(fn,0.8,1.4,ave_range=100)
    @test_nowarn MyKB.eval_KB2(fn,1/1.4,1/0.8,ave_range=100)
    @test_nowarn MyKB.plot_GR_fit(fn,0.8,1.4,ave_range=100)
    @test_nowarn MyKB.plot_RGR_fit(fn,1/1.4,1/0.8,ave_range=100)

end
