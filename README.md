# MyKB
Package for computing Kirkwood-Buff(KB) integral from a data file of radial distribution function. 

Copyright (c) 2021 Ryuichi Okamoto <ryubee@gmail.com>
License: https://opensource.org/licenses/MIT

## Installation
```sh
julia> ]
pkg> add https://github.com/ryubee1980/MyKB.jl.git
```

## Computational scheme
In simulations, RDF data is obtained from a system of finite size, while the KB integral is theoretically defined for a system of infinite size. 
Hence one need to somehow "estimate" the value of the infinite system from that of a finite system.
An efficient extrapolation scheme has been proposed by

P. Krüger, D. Bedeaux, S. Kjelstrup, T. Vlugt, J.-M. Simon, J. Phys. Chem. Lett. vol.4, (2013) 235.

The authors showed the double integral of pair correlation function (PCF) $h(r_{12})=g(r_{12})-1$ within a volume $V$ of a spherical shape is given by

$$
G(R)=\frac{1}{V}\int_V\int_V h(r_{12})dr_1dr_2=\int_0^{2R} h(r) w(r) dr,
$$

where $R$ is the radius of the sphere. The weight function $w(r)$ is given by

$$
w(r)=4\pi r^2(1-3x/2+x^3/2)
$$

with $x=r/2R$. Further, the authors showed that $G(R)$ behaves for large $R$ as

$$
G(R)\to G(\infty)+A/R \quad (R\to\infty),
$$

where $A$ is some constant and $G(\infty)$ is the KB integral that we wish to compute. 

Hence, we can estimate the KB integral $G(\infty)$ by the following procedures:

1.Compute $G(R)$ from the RDF data for sufficiently large $R$'s. In simulations, RDF data is obtained for $r < r_{\rm max}$ with $r_{\rm max}$ being comparable with the box size of the simulation. Then one should note that $G(R)$ can be computed only for finite $R$ such that $R < r_{\rm max}/2$.

2.Find the $R$-range where $G(R)$ is linear in $1/R$. 

3.In this range, fit the curve (line) $1/R$ vs $G(R)$ by a linear function $B+A/R$. Then we extrapolate the curve to $R\to \infty$, i.e., $G(\infty)=B$.

**Note**
The 2nd procedure should be done manually because the range depends on the molecular species as well as the physical conditions of the system. On can use "plot_GR" to plot $1/R$ vs $G(R)$.

Instead of doing 2 and 3 in the above, one may also use the following:

$$
RG(R)\to RG(\infty)+A \quad (R\to\infty).
$$

One may plot $R$ vs $R\times G(R)$ and find the $R$-range where $RG(R)$ grows linearly with $R$. Then fit the line in the range by a linear function $BR+A$. The slope $B$ gives the KB integral, $G(\infty)=B$.


## Radial distribution function (RDF) data
The RDF data should given by the distance values $r$ [nm] and the corresponding RDF $g(r)$ separated by a space. Lines that begin with #, @, or " are ignored.

## Shift of RDF
It is known that RDFs (resp. PCFs) obtained for finite systems often do not exactly approach $1$ (resp. $0$) as $r\to r_{\rm max}$. This can be problematic when computing KB integrals. To avoid this, in each function of this package, an optional variable "shift" is introduced (its default value is 0). For finite value, the PCF $h(r)$ is simply shifted as

$$
h(r)\to h(r)+{\rm shift}
$$

for all $r$. Hence, if the original PCF approaches, for example, $0.95$, then one may set

$$
{\rm shift}=0.05.
$$

## Usage
It is convenient to define the string variable for the input RDF file:
```sh
julia> fn="rdf.xvg"
```

### in_RDF
Read the input file and returns an $N\times 2$ array g[,] such that g[:,1] gives the values of $r$ and g[:,2] the corresponding values of RDF $g(r)$.
```sh
julia> in_RDF(fn)
```

### plot_RDF
Plot the (shifted) RDF from the data file in the range rmin $< r <$ rmax. The default values of rmin and rmax are 0 and 3, respectively.
By default, the $g$-range is not specified, but one can set it by the optional variables gmin and gmax.
```sh
julia> plot_RDF(fn;shift=0.05,rmin=0.1,rmax=2.5,gmin=0.1,gmax=2.3)
```

### comp_GR
Compute the function $G(R)$ from the data file of RDF:
```sh
julia> comp_GR(fn;shift=0.05)
```

### plot_GR
Plot $1/R$ vs $G(R)$ from the data file of RDF in the range xmin$<1/R<$ xmax. The default values of xmin and xmax are 0 and 4, respectively.
```sh
julia> plot_GR(fn;shift=0.05, xmin=0.0, xmax=3.0)
```


### fit_GR
Perform fitting $1/R$ vs $G(R)$ by a linear function $B+A/R$ in the range recRmin$<1/R<$ recRmax.
```sh
julia> fit_GR(fn,recRmin,recRmax;shift=0.05)
```

### eval_KB
Evaluate KB integral.
```sh
julia> eval_KB(fn,recRmin,recRmax;shift=0.05)
```

### plot_GR_fit
Plot $1/R$ vs $G(R)$ together with the fitting line. The plot range is xmin$<1/R<$ xmax.
```sh
julia> fit_GR_fit(fn,recRmin,recRmax;shift=0.05,xmin=0.0,xmax=3.0)
```

The modified methods using the fit of $R$ vs $R\times G(R)$ are implemented by the following functions.

### plot_RGR
Plot $R$ vs $R\times G(R)$ from the data file of RDF in the range xmin$<R<$xmax. The default values of xmin and xmax are 0 and 3, respectively.
```sh
julia> plot_RGR(fn;shift=0.05, xmin=0.0, xmax=3.0)
```

### fit_RGR
Perform fitting $R$ vs $R\times G(R)$ by a linear function $A+BR$ in the range Rmin$<R<$Rmax.
```sh
julia> fit_RGR(fn,Rmin,Rmax;shift=0.05)
```

### eval_KB
Evaluate KB integral using fig_RGR.
```sh
julia> eval_KB2(fn,Rmin,Rmax;shift=0.05)
```


### plot_RGR_fit
Plot $R$ vs $R\times G(R)$ together with the fitting line evaluated by fit_RGR. The plot range is xmin < $R$ < xmax.
```sh
julia> fit_RGR_fit(fn,Rmin,Rmax;shift=0.05,xmin=0.0,xmax=3.0)
```