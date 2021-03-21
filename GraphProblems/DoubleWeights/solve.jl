# set JULIA_NUM_THREADS=16
# Threads.@threads

using XLSX
using DataStructures
import Missings
using ThreadsX


pwd()

xl = XLSX.readxlsx("data.xlsx")
matrix = xl["Sheet1"]["A1:C200"]
println(matrix)

function custom_split(input)
    na = replace.(input, "}" => "")
    na = replace.(na, " " => "")
    na = replace.(na, '"'  => "")


    na = split(na,"{")
    w1 = na[2]
    w2 = na[3]

    w1 = w1[1:(length(w1)-1)]
    w2 = w2[1:(length(w2))]

    w1 = split(w1, ",")
    w2 = split(w2, ",")

    W1 = Array{Float64}(undef, length(w1), length(w1))
    W2 = Array{Float64}(undef, length(w2), length(w2))
    for i=1:length(w1)
        for j=1:length(w1)
            if w1[i][j:j]=="."
                W1[i,j]=Inf
                W2[i,j]=Inf
            else
                W1[i,j]=parse(Float64,w1[i][j:j])
                W2[i,j]=parse(Float64,w2[i][j:j])
            end
        end
    end
    return W1,W2
end

function solve(W1,W2)

    # Firsly, find all paths from node 0 to node 1 (or node 1 to node 2)

    n = size(W1)[1]

    # Breath First Search
    pq = Queue{Array}()
    enqueue!(pq,[1])
    paths = Dict()

    # println("findinng paths")

    while (!isempty(pq))
        # println(pq)
        get = dequeue!(pq)
        from = get[length(get)]

        for i=1:n
            g = copy(get)
            if (W1[from,i]!=Inf) && !(i in get)
                new = append!(g,i)
                c = cost(W1,W2,new)
                if i!=2
                    if (length(paths)!=0) && (collect(values(paths))[1]) > c
                        enqueue!(pq,new)
                    elseif length(paths)==0
                        enqueue!(pq,new)
                    end
                else
                    if length(paths)==0
                        paths[new] = c
                    elseif collect(values(paths))[1] > c
                        delete!(paths,collect(keys(paths))[1])
                        paths[new] = c
                    end
                end
            end
        end
    end
    # println("Paths from 1 to 2: ", paths)

    if length(paths)==0
        return -1
    end

    result = collect(values(paths))[1]

    # println(sorted_q)
    return result
end


function cost(W1,W2,path)
    total_w1 = 0
    total_w2 = 0

    for i=1:(length(path)-1)
        total_w1+=W1[path[i],path[i+1]]
        total_w2+=W2[path[i],path[i+1]]
    end
    return total_w1*total_w2
end

function results(matrix)
    # for j in 7:7
    for j in 1:size(matrix)[1]
        # println("\n")
        if !ismissing(matrix[j,1])

            println("dd")
            input = matrix[j,2]
            println("ee")
            output = parse(Float64,matrix[j,3])

            W1,W2=custom_split(input)
            res = @time solve(W1,W2)
            # println(res)
            # println(output)

            if (res == output)
                println("Test Case ",j, ": Passed")
                # println("\n\n\n\n")
                continue
            elseif (res != output)
                println("Test Case ",j, ": Failed")
                break
            end
        else
            continue
        end
    end
end

println("DDDDD")
@time results(matrix)


# No paralle loop: runtime ~0.45
# Parallel loop function results and solve ~ 0.50 sec
# Run-time is relatively short already, parallel code adds overhead which makes it slower
