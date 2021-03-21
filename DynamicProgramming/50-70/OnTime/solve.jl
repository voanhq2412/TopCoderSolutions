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
    na = split(input, ",";limit=3)

    N = na[1]
    T = na[2]
    nodes = na[3]

    nodes = replace.(nodes, ['}','{','"']=> "")
    nodes = split(nodes,",")
    # println(nodes)

    # Parse String to Int64
    N = parse(Int64,N)
    T = parse(Int64,T)

    return N,T,nodes
end


function solve(N,T,nodes)

    data = []
    for i = 1:size(nodes)[1]
        temp = split(nodes[i]," ")[2:end]
        temp = [parse(Int64,j) for j in temp]
        append!(data,[temp])
    end
    sort!(data, by = x -> x[1])

    # Initiate hashmap and initial path
    store = Dict()
    for j in data
        if j[1]==0
            # current_time, journey
            key = [j[3]+j[4],0,j[2]]
            # current_time , cost
            value = j[5]
            # add to store


            # If current_time exceeds arrival time, discard to reduce search space
            if key[1] > T
                continue
            else
                store[key] = value
            end
        end
    end
    #
    # println(data)
    # println(store)
    # println("\n")

    while true
        k = collect(keys(store))
        count = 0
        c=0
        for i in k
            if i[end] == (N-1)
                continue
            end
            for j in data
                if (i[1] < j[3]) && (i[end]==j[1])
                    key = append!(copy(i),j[2])
                    key[1] = j[3] + j[4]
                    # println(key)

                    # only accept if current_time < arrival_time
                    if key[1] > T
                        continue
                    end

                    value = store[i] + j[5]

                    # If key already in dict, pick lowest cost,
                    #  dict cannot have duplicate keys, previous key will be overriden
                    if haskey(store,key)
                        if store[key] > value
                            store[key] = value
                        end
                    else
                        store[key] = value
                    end

                    count+=1
                    c+=1
                end
            end

            # delete redundant key
            if c!=0
                delete!(store, i)
            end
            #
            # println("\n")
            # println(store)

        end

        if count==0
            @goto break_out
        end
    end

    @label break_out
    k = collect(keys(store))
    # delete keys that don't lead to final dest
    for i in k
        if i[end]!=(N-1)
            delete!(store,i)
        end
    end

    v = collect(values(store))
    if size(v)[1]==0
        return -1
    else
        return minimum(v)
    end
end


function results(matrix)
    # for j in 22:22
    Threads.@threads for j in 1:size(matrix)[1]
        # println("\n")
        if !ismissing(matrix[j,1])
            input = matrix[j,2]
            output = parse(Int64,matrix[j,3])

            N,T,nodes =custom_split(input)
            res = solve(N,T,nodes)

            # println(res)
            # println(output)
            #
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


# # No paralle loop: runtime ~6.20 seconds
# # Parallel loop function results only: ~5.90 seconds
# # Parallel loop function results and function solve (outermost for loops only): runtime ~6.12 seconds
# # Parallel loop function results and function solve (innermost for loops only): runtime ~6.27 seconds
# Conclusion: parallel result function shows minor speed-Up
