:(function (ˍ₋out, x)
      begin
          ˍ₋out_2_input_1 = (broadcast)(+, x, (adjoint)(x))
          ˍ₋out_1 = (view)(ˍ₋out, 1:6, 1:6)
          ˍ₋out_1 .= 0
          ˍ₋out_2 = (view)(ˍ₋out, 2:5, 2:5)
          for (j, j′) = zip(Base.OneTo(4), reset_to_one(Base.OneTo(4)))
              for (i, i′) = zip(Base.OneTo(4), reset_to_one(Base.OneTo(4)))
                  ˍ₋out_2[i′, j′] = (+)(ˍ₋out_2[i′, j′], (+)(1, (getindex)(ˍ₋out_2_input_1, i, j)))
              end
          end
      end
  end)