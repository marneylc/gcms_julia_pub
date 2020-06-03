#cd("/home/marneyl/gcms_julia/")
#mslibrary = mspDict("Fames-msp.txt")

function mspDict(file)
        f = open("Fames-msp.txt")
        lines = readlines(f)

        i = 1
        ID = Array{String,1}()
        RT = Array{Float64,1}()
        mslibrary = Dict{String,Array{Float64,2}}()
        while i < length(lines)
                m = match(r"Name:", lines[i])
                n = match(r"Num Peaks:", lines[i])
                if m == n
                        i = i + 1
                elseif n == nothing
                        name = lines[i][7:length(lines[i])]
                        n = match(r"\+", name)
                        if n == nothing
                                ID = push!(ID, split(name)[1])
                                RT = push!(RT, parse(Float64,split(name)[2]))
                                i = i+1
                        else
                                name = replace(name, r" \+ " => s"&")
                                push!(ID, split(name)[1])
                                push!(RT, parse(Float64,split(name)[2]))
                                i = i+1
                        end
                elseif m == nothing
                        numpeaks = parse(Int,lines[i][12:length(lines[i])])
                        spectraindex = Int[i+1,i+ceil(numpeaks/5)]
                        iteratorindex = 1
                        spectra = Array{Float64,2}(undef, numpeaks, 2)
                        for j = spectraindex[1]:spectraindex[2]
                                specline = split(lines[j], ";")
                                specline = specline[1:length(specline)-1]
                                for k = 1:length(specline)
                                        specpoint = split(specline[k])
                                        mz = parse(Float64,specpoint[1])
                                        I = parse(Float64,specpoint[2])
                                        spectra[iteratorindex,:] = [mz,I]
                                        iteratorindex = iteratorindex + 1
                                end
                        end
                        push!(mslibrary, ID[length(ID)] => spectra)
                        i = i + 1
                end
        end
        return mslibrary
end
