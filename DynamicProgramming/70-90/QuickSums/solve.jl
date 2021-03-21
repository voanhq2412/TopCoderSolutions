# set JULIA_NUM_THREADS=16
# Threads.@threads

using XLSX
using DataStructures
import Missings
using ThreadsX


pwd()

xl = XLSX.readxlsx("data.xlsx")
matrix = xl["Sheet1"]["A1:C200"]




function custom_split(input)
    na = rsplit(input, ",";limit=2)

    N = replace(na[1],['"',' '] => "")
    Y = na[2]

    Y =parse(Int64,Y)
    return N,Y
end
# N is (remaining) digits
# d = sum we need (max is 100)

function solve(N,d,prev=nothing)
    # println(N)
    if length(N)==0
        # println("Prev: ", prev)
        if d==0
            if prev==0
                return 0
            else
                return -1
            end
        else
            return Inf
        end
    else
        one_digit = parse(Int64,N[1:1])
        if one_digit==0
            return solve(N[2:end],d,one_digit)
        end 
    end

    # println("\n")
    if length(N)>=3
        one_digit = parse(Int64,N[1:1])
        two_digit = parse(Int64,N[1:2])
        three_digit = parse(Int64,N[1:3])

        if three_digit<=d
            return 1+ min( solve(N[2:end],d-one_digit,one_digit) , solve(N[3:end],d-two_digit,two_digit) , solve(N[4:end],d-three_digit,three_digit)   )
        elseif two_digit <=d
            return 1+ min( solve(N[2:end],d-one_digit,one_digit) , solve(N[3:end],d-two_digit,two_digit)    )
        elseif one_digit <=d 
            return 1+ min( solve(N[2:end],d-one_digit,one_digit)    )
        else 
            # println(N, "  " ,  d)
            return Inf
        end

    elseif length(N)==2
        one_digit = parse(Int64,N[1:1])
        two_digit = parse(Int64,N[1:2])
        # println(N)
        # println(two_digit)
        # println(one_digit)
        if two_digit <=d
            return 1+ min( solve(N[2:end],d-one_digit,one_digit) , solve(N[3:end],d-two_digit,two_digit)    )
        elseif one_digit <=d
            return 1+ min( solve(N[2:end],d-one_digit,one_digit)    )
        else 
            return Inf
        end

    elseif length(N)==1
        one_digit = parse(Int64,N[1:1])
        # println(N)
        # println(one_digit)
        if one_digit <=d
            return 1+ min( solve(N[2:end],d-one_digit,one_digit)    )
        else 
            return Inf
        end
    else
    end
end




function results(matrix)
    # for j in 1:20
    for j in 1:size(matrix)[1]
        # println("\n")
        if !ismissing(matrix[j,1])
            input = matrix[j,2]
            output = parse(Int64,matrix[j,3])

            N,d =custom_split(input)
            res = solve(N,d) 
            if res == Inf res=-1 end 

            if res == output
                println("Test Case ",j, ": Passed")
                # println("\n\n\n\n")
                continue
            else
                println("Test Case ",j, ": Failed")
                break
            end
        else
            continue
        end
    end
end

@time results(matrix)


# # No paralle loop: runtime ~0.5 seconds
# runtime so low already, parallel will add overhead costs and make it slower
