# set JULIA_NUM_THREADS=16
# Threads.@threads

using XLSX
using DataStructures
import Missings
using ThreadsX


pwd()

xl = XLSX.readxlsx("data.xlsx")
matrix = xl["Sheet1"]["A1:C200"]
# # matrix = coalesce.(matrix, 0)
# # println(file)




function custom_split(input)
    return parse(Int64,input)
end




function solve(n)
    # transform the numpad into graph
    # 1 2 3
    # 4 5 6
    # 7 8 9
    # 0

    num_pad = zeros(Float64, 10, 10)
    num_pad[1,8] = 1
    num_pad[2,3] = 1
    num_pad[2,5] = 1
    num_pad[3,2] = 1
    num_pad[3,4] = 1
    num_pad[3,6] = 1
    num_pad[4,3] = 1
    num_pad[4,7] = 1
    num_pad[5,2] = 1
    num_pad[5,6] = 1
    num_pad[5,8] = 1
    num_pad[6,3] = 1
    num_pad[6,5] = 1
    num_pad[6,7] = 1
    num_pad[6,9] = 1
    num_pad[7,4] = 1
    num_pad[7,6] = 1
    num_pad[7,10] = 1
    num_pad[8,5] = 1
    num_pad[8,9] = 1
    num_pad[8,1] = 1
    num_pad[9,6] = 1
    num_pad[9,8] = 1
    num_pad[9,10] = 1
    num_pad[10,7] = 1
    num_pad[10,9] = 1

    passwords = Dict()
    #key = [password end with .. , number of digits]
    # value = count
    for i=1:10
        passwords[[i,1]]=1
    end

    i = 2
    while (i <= n)
        # println(passwords)
        temp = Dict()

        # given key ending with 'from', what could be the next digits
        for j in keys(passwords)
            from = j[1]
            for k=1:10
                if num_pad[from,k]==1
                    if [k,i] in keys(temp)
                        temp[[k,i]] =temp[[k,i]] + passwords[[from,i-1]]
                    else
                        temp[[k,i]] =  passwords[[from,i-1]]
                    end
                end
            end
        end

        passwords = copy(temp)
        i+=1
    end

    # println(passwords)
    sum = 0
    for v in values(passwords)
        sum+=v
    end
    return sum
end



function results(matrix)
    # for j in 1:3
    for j in 1:size(matrix)[1]
        # println("\n")
        if !ismissing(matrix[j,1])
            input = matrix[j,2]
            output = parse(Int64,matrix[j,3])

            n = custom_split(input)
            res = solve(n)
            # println(res)
            # # println(output)

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
