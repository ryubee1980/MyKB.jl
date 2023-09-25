"""
Compute the Kirkwood-Buff integral (KBI) from the dat of radial distribution function (RDF) generated by GROMACS. One can also use a data file of r [nm] vs RDF.

To efficiently evaluate KBIs from data of finite volume systems, the scheme proposed by Kruger et al. [J. Phys. Chem. Lett. vol.4, (2013) 235.] is used.

In each function, the optional variable ``shift`` is introduced so that the pair correlation``h`` approaches 0 as ``r`` goes to infinity (``h`` is simly shifted as ``h+shift`` for all ``r``).
"""

module MyKB

using Plots

"""
Import the data file of rdf generated by simulations.

in_RDF(file)
"""
function in_RDF(file)
    fn=open(file,"r")
    r=Array{Float64}(undef,0)
    g=similar(r)
    while !eof(fn)
        line=readline(fn)
        s=split(line)
        if(sizeof(s)!=0)
            if(s[1][1]!='#' && s[1][1]!='@' && s[1][1]!='"')
                s1=parse(Float64,s[1])
                s2=parse(Float64,s[2])
                r=push!(r,s1)
                g=push!(g,s2)
            end
        end
    end
    close(fn)
    hcat(r,g)
end

"""
Plot RDF from data file. By default, the ``g``-range is not specified, while ``r``-range is specified as ``rmin=0.0`` and ``rmax=3.0``.

    plot_RDF(file;shift=0.0,rmin=0.0,rmax=3.0,gmin=0,gmax=3.0)
"""
function plot_RDF(file;shift=0.0,rmin=0.0,rmax=3.0,gmin=-1.0,gmax=-2.0)
    g=in_RDF(file)
    if(gmin>gmax)
        p=plot(g[:,1],g[:,2] .+ shift,xlabel="\$r\$",ylabel="\$g(r)\$", xlim=(rmin,rmax))
    else
        p=plot(g[:,1],g[:,2] .+ shift,xlabel="\$r\$",ylabel="\$g(r)\$", xlim=(rmin,rmax),ylim=(gmin,gmax))
    end
    p
end



"""
Compute the pair correlation function ``h=g-1`` where ``g`` is the RDF.

    hr(gr;shift=0.0)
"""
function hr(gr;shift=0.0)
    h=similar(gr)
    h[:,1] .= gr[:,1]
    h[:,2] .= gr[:,2] .+ shift .- 1.0
    #plot(h[:,1],h[:,2])
    h
end


"""
Compute ``G(R)`` from a data file of RDF generated by GROMACS.

    comp_GR(file;shift=0.0)
"""
function comp_GR(file;shift=0.0)
    g=in_RDF(file)
    h=hr(g,shift=shift)
    #dr=h[2,1]-h[1,1]
    RRmax=h[end,1]
    r=h[begin,1]
    RR=h[begin+1,2]
    x=r/RR
    GR=Array{Float64}(undef, length(h[:,1])-1,2)
    for i in 3:length(h[:,1])
        RR=h[i,1]
        I=0.0
        for j in 1:i-1
            r=h[j,1]
            dr=h[j+1,1]-h[j,1]
            x=r/RR
            w=4*pi*r^2*(1-(3x/2)+x^3/2)
            I=I+dr*w*h[j,2]
        end
        GR[i-1,1]=RR*0.5
        GR[i-1,2]=I
    end

    GR 
end

"""
Plot ``1/R`` vs ``G(R)`` in the range ``xmin < 1/R < xmax``.

    plot_GR(file;shift=0.0,xmin=0,xmax=4)
"""
function plot_GR(file;shift=0.0,xmin=0,xmax=4)
    GR=comp_GR(file;shift=shift)
    plot((@. 1.0/GR[:,1]), GR[:,2], xlim=(xmin,xmax), xlabel="\$1/R\$  [nm\$^{-1}\$]", ylabel="\$G(R)\$", label=:none)
end


"""
Plot ``R`` vs ``R*G(R)`` in the range ``xmin < R < xmax``.

    plot_RGR(file;shift=0.0,xmin=0,xmax=3)
"""
function plot_RGR(file;shift=0.0,xmin=0,xmax=3)
    GR=comp_GR(file;shift=shift)
    plot((GR[:,1]), GR[:,1] .* GR[:,2], xlim=(xmin,xmax), xlabel="\$R\$  [nm]", ylabel="\$RG(R)\$", label=:none)
end



"""
Perform fitting ``1/R`` vs ``G(R)`` by a linear function ``w[1]+(1/R)*w[2]`` in the range ``recRmin < 1/R < recRmax``. The KB integral in the inifinite volume ``G(∞ )`` is given by the extrapolation, i.e.,  ``w[1]``.

    fit_GR(file,recRmin,recRmax;shift=0.0)
"""
function fit_GR(file,recRmin,recRmax;shift=0.0)
    GR=comp_GR(file,shift=shift)
    x=Array{Float64}(undef,0)
    y=similar(x)
    for i in length(GR[:,1]):(-1):1
        if(recRmin<(1.0/GR[i,1])<recRmax)
            push!(x,1.0/GR[i,1])
            push!(y,GR[i,2])
        end
    end
    X=x.^(0:1)'
    w=X\y
end


"""
Perform fitting ``R`` vs ``R*G(R)`` by a linear function ``w[1]+R*w[2]`` in the range ``Rmin < R < Rmax``. The KB integral in the inifinite volume ``G(∞ )`` is given by the extrapolation, i.e.,  ``w[2]``.

    fit_GR(file,recRmin,recRmax;shift=0.0)
"""
function fit_RGR(file,Rmin,Rmax;shift=0.0)
    GR=comp_GR(file,shift=shift)
    x=Array{Float64}(undef,0)
    y=similar(x)
    for i in 1:length(GR[:,1])
        if(Rmin<GR[i,1]<Rmax)
            push!(x,GR[i,1])
            push!(y,GR[i,1]*GR[i,2])
        end
    end
    X=x.^(0:1)'
    w=X\y
end


"""
Evaluate KB integral using fit_GR.

    eval_KB(file,recRmin,recRmax;shift=0.0)
"""
function eval_KB(file,recRmin,recRmax;shift=0.0)
    w=fit_GR(file,recRmin,recRmax,shift=shift)
    println("G(∞ )=", w[1], " /nm^3")
    w[1]
end


"""
Evaluate KB integral using fit_RGR.

    eval_KB2(file,Rmin,Rmax;shift=0.0)
"""
function eval_KB2(file,Rmin,Rmax;shift=0.0)
    w=fit_RGR(file,Rmin,Rmax,shift=shift)
    println("G(∞ )=", w[2], " /nm^3")
    w[2]
end


"""
Plot ``1/R`` vs ``G(R)`` together with the fitting line in the range ``xmin < 1/R < xmax``.

    plot_GR_fit(file,recRmin,recRmax;shift=0.0,xmin=0,xmax=4,show_range=1)
"""
function plot_GR_fit(file,recRmin,recRmax;shift=0.0,xmin=0,xmax=4,show_range=1)
    GR=comp_GR(file;shift=shift)
    p=plot((@. 1.0/GR[:,1]), GR[:,2], xlim=(xmin,xmax), xlabel="\$1/R\$ [nm\$^{-1}\$]", label="\$G(R)\$",lw=3)
    w=fit_GR(file,recRmin,recRmax,shift=shift)
    x=0:0.1:recRmax+0.5
    plot!(p,x,(@. w[1]+w[2]*x),ls=:dash,label="$(w[1])\$+A/R\$")
    if(show_range==1)
        bound=[[recRmin,recRmax] [w[1]+w[2]*recRmin,w[1]+w[2]*recRmax]]
        scatter!(p,bound[:,1],bound[:,2],label="fit range",ms=6)
    end
    p
end

"""
Plot ``R`` vs ``R*G(R)`` together with the fitting line in the range ``xmin < R < max``.

    plot_RGR_fit(file,Rmin,Rmax;shift=0.0,xmin=0,xmax=3,show_range=1)
"""
function plot_RGR_fit(file,Rmin,Rmax;shift=0.0,xmin=0,xmax=3,show_range=1)
    GR=comp_GR(file;shift=shift)
    GRmin=findmin(GR)[1]
    GRmax=findmax(GR)[1]
    ymin=GRmin-(GRmax-GRmin)*0.2
    ymax=GRmax+(GRmax-GRmin)*0.2
    p=plot((GR[:,1]), GR[:,1] .* GR[:,2], xlim=(xmin,xmax), ylim=(ymin,ymax),xlabel="\$R\$ [nm]", label="\$RG(R)\$",lw=3,legend=:bottomright)
    w=fit_RGR(file,Rmin,Rmax,shift=shift)
    x=Rmin:0.1:Rmax+0.5
    plot!(p,x,(@. w[1]+w[2]*x),ls=:dash,label="\$A+\$$(w[2])\$R\$")
    if(show_range==1)
        bound=[[Rmin,Rmax] [w[1]+w[2]*Rmin,w[1]+w[2]*Rmax]]
        scatter!(p,bound[:,1],bound[:,2],label="fit range",ms=6)
    end
    p
end

end#module