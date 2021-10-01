"""
$(TYPEDEF)

An equality relationship between two expressions.

# Fields
$(FIELDS)
"""
struct Equation
    """The expression on the left-hand side of the equation."""
    lhs
    """The expression on the right-hand side of the equation."""
    rhs
    function Equation(lhs, rhs)
        new(value(lhs), value(rhs))
    end
end
Base.:(==)(a::Equation, b::Equation) = all(isequal.((a.lhs, a.rhs), (b.lhs, b.rhs)))
Base.hash(a::Equation, salt::UInt) = hash(a.lhs, hash(a.rhs, salt))

Base.show(io::IO, eq::Equation) = print(io, eq.lhs, " ~ ", eq.rhs)

SymbolicUtils.simplify(x::Equation; kw...) = simplify(x.lhs; kw...) ~ simplify(x.rhs; kw...)
function SymbolicUtils.substitute(x::Equation, rules; kw...)
    sub = substituter(rules)
    sub(x.lhs; kw...) ~ sub(x.rhs; kw...)
end

function SymbolicUtils.substitute(eqs::Vector{Equation}, rules; kw...)
    sub = substituter(rules)
    sub.(lhss(eqs); kw...) .~ sub.(rhss(eqs); kw...)
end

lhss(xs) = map(x->x.lhs, xs)
rhss(xs) = map(x->x.rhs, xs)

"""
$(TYPEDSIGNATURES)

Create an [`Equation`](@ref) out of two [`Num`](@ref) instances, or an
`Num` and a `Number`.

# Examples

```jldoctest
julia> using Symbolics

julia> @variables x y;

julia> @variables A[1:3, 1:3] B[1:3, 1:3];

julia> x ~ y
x ~ y

julia> x - y ~ 0
x - y ~ 0

julia> A ~ B
(broadcast(~, A, B))[1:3,1:3]

julia> A .~ 3x
(broadcast(~, A, 3x))[1:3,1:3]
```
"""
function Base.:~(lhs, rhs)
    if isarraysymbolic(lhs) || isarraysymbolic(rhs)
        if isarraysymbolic(lhs) && isarraysymbolic(rhs)
            lhs .~ rhs
        else
            throw(ArgumentError("Cannot equate an array with a scalar. Please use broadcast `.~`."))
        end
    else
        Equation(lhs, rhs)
    end
end
for T in [:Num, :Complex, :Number], S in [:Num, :Complex, :Number]
    (T != :Complex && S != :Complex) && continue
    @eval Base.:~(a::$T, b::$S) = let ar = value(real(a)), br = value(real(b)),
                                      ai = value(imag(a)), bi = value(imag(b))
        if ar isa Number && br isa Number && ai isa Number && bi isa Number
            error("Equation $a ~ $b does not contain any symbols")
        elseif ar isa Number && br isa Number
            ai ~ bi
        elseif ai isa Number && bi isa Number
            ar ~ br
        else
            [ar ~ br
            ai ~ bi]
        end
    end
end

struct ConstrainedEquation
  constraints
  eq
end

function expand_derivatives(eq::Equation, simplify=false)
    return Equation(expand_derivatives(eq.lhs, simplify), expand_derivatives(eq.rhs, simplify))
end
