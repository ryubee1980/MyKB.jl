# MyKB
Package for computing Kirkwood-Buff(KB) integral from radial distribution function. 

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

1.Compute $G(R)$ from the RDF data for sufficiently large $R$'s. In simulations, RDF data is obtained for $r<r_{\rm max}$ with $r_{\rm max}$ being comparable with the box size of the simulation. Then one should note $R$ must be smaller than $r_{\rm max}/2$.

2.Find the $R$-range where $G(R)$ is linear in $1/R$. 

3.In this range, fit the curve (line) $1/R$ vs $G(R)$ by a linear function $B+A/R$. Then we extrapolate the curve to $R\to \infty$, i.e., $G(\infty)=B$.

**Note**
The 2nd procedure should be done manually because the range depends on the molecular species as well as the system. On can use "plot_GR" to plot $1/R$ vs $G(R)$.


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
It is convenient to define the 
